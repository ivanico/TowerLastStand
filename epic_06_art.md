# Epic 06 — Art

> Prerequisite: Epic 05 complete and tested. The game must be fully playable with
> placeholder art before touching this epic.
> Goal: Replace every colored rectangle placeholder with real sprites and animations.
> Game looks like a finished product.
> Completed epic delivers: all sprites, animations, and particle VFX wired up.
> No ColorRect or Image.create() placeholders remain.

---

## Pipeline Overview — The Archero Hybrid Approach

This game uses the same method Archero uses:

**3D models for towers and enemies. 2D sprites for terrain, floor, and effects.**

Archero is a 2D game. The characters look 3D because of how they were made,
not because the engine runs 3D. The 3D model is used like a camera — you pose it,
render a PNG of each animation frame from a fixed top-down angle, pack those PNGs
into a spritesheet, and drop it into Godot as a normal 2D sprite (AnimatedSprite2D).
The 3D model never enters Godot. Godot only ever sees flat PNG images.

```
Meshy (AI generates 3D model)
        ↓
    Blender
    - orthographic camera, fixed ~60° top-down angle
    - render each animation frame as a PNG
    - pack frames into a horizontal spritesheet
        ↓
    Drop spritesheet PNG into res://assets/sprites/
        ↓
    Godot — AnimatedSprite2D reads it as a normal 2D sprite
```

The Godot project stays 100% 2D. No Camera3D, no MeshInstance3D, no Y-axis.
When an enemy walks left, it is not rotating a 3D mesh — it is flipping a flat PNG.
The image looks 3D because it was rendered from a 3D model at an angle.

For terrain, arena floors, zone effects, and UI — use 2D tools (Photoshop, Aseprite,
Affinity Designer) or free asset packs from the sources in `assets.md` Section 10.
These do not go through the 3D pipeline at all.

---

## Step 0 — AI Tools for Creating 3D Models (Solo Dev Workflow)

You do not need a team or Blender modeling skills from scratch. Use an AI tool to
generate the 3D model, then use Blender only for the render step.

| Tool | What it does | Notes |
|------|-------------|-------|
| **Meshy** (meshy.ai) | Text or image → 3D model | Best overall for cartoon low-poly. Already set up in `meshy_art_guide.md`. Use this first. |
| **Tripo3D** (tripo3d.ai) | Text or image → 3D model | Fast alternative if Meshy result is not good. Same workflow after export. |
| **Rodin / Hyper3D** (hyper3d.ai) | Text or image → 3D model | Third option, good for characters. |

All three export `.glTF` or `.OBJ` — both import into Blender.

**Always follow the prompts and style rules in `meshy_art_guide.md` for every model.**
Style consistency across all assets is the most important visual decision in the game.

### Full Asset Creation Pipeline Per Model

```
1. Open Meshy (or Tripo3D)
2. Paste the full prompt from meshy_art_guide.md
   (Master Style Block + asset block + evolution block)
3. Upload an Archero Chapter 11 screenshot as the image style reference
4. Generate — pick the best result
5. Export as .glTF or .OBJ
6. Open in Blender — import the model
7. Set camera: Orthographic, ~60° top-down angle
8. Apply cel/flat shade if the Meshy texture looks too realistic
9. Render each animation state frame by frame at the correct size:
   - Towers:  160×160 px per frame
   - Enemies: 64–256 px per frame (see assets.md per enemy type)
10. Pack all frames into one horizontal spritesheet PNG
11. Name the file exactly as listed in assets.md
12. Drop into res://assets/sprites/
```

---

## Task 06-01 — Remove All Placeholder Texture Code

**Do this before importing any real sprites.**

Every enemy file and TowerBase.gd contains code like this in `_ready()`:

```gdscript
var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
img.fill(Color.RED)
$Sprite2D.texture = ImageTexture.create_from_image(img)
```

- [ ] Delete those three lines from every file that has them:
      `TowerBase.gd`, `EnemyBase.gd`, `EnemyRunner.gd`, `EnemyBrute.gd`,
      `EnemyFlyer.gd`, `EnemyElite.gd`, `EnemyBoss.gd`.
- [ ] Do not add replacement code here. The `AnimatedSprite2D` nodes carry their
      own texture references set directly in the scene editor.

---

## Task 06-02 — Import All Sprites & Set Import Settings

**Ref**: `assets.md` — full sprite list

- [ ] Place all sprites in `res://assets/sprites/` with exact filenames from `assets.md`.
- [ ] For **rendered sprites** (towers, enemies — from the Meshy pipeline):
      `Filter: Linear`, `Compress: VRAM Compressed`.
- [ ] For **2D drawn sprites** (terrain, UI, zone effects, VFX):
      `Filter: Linear`, `Compress: VRAM Compressed`.
- [ ] For **spritesheets** (enemies, VFX): set horizontal frame count and row
      assignments in the SpriteFrames panel of each `AnimatedSprite2D`.
- [ ] Verify no import errors in Godot's FileSystem panel (red icons = bad import).

---

## Task 06-03 — Tower Sprites

**Files**: `res://scenes/tower/TowerBase.tscn` and all tower variants

For each tower (Ironclad, Ember, Tide, Sentinel, Phantom):
- [ ] In the scene editor: replace the `Sprite2D` node with `AnimatedSprite2D`.
- [ ] Assign the correct spritesheet (`tower_X.png`) in the SpriteFrames panel.
- [ ] Configure animations in SpriteFrames:
  - `idle`: frames 0–1 (or 0–3), loop=true, fps=4.
  - `attack`: fire flash frames, loop=false, fps=12.
  - `damaged`: single alternate frame, loop=true, fps=2.
- [ ] In `TowerBase.gd`:
  - Play `idle` in `_ready()`.
  - In `_fire_spell()`: play `attack`, connect `animation_finished` to return to `idle`.
  - Via `GameState.hp_changed` signal: if `hp < max_hp * 0.3`, switch to `damaged`.
- [ ] Fix the hardcoded `400.0` in `_draw()` — replace with
      `base_range + GameState.tower_range_bonus` so the range circle matches reality.
- [ ] Add `tower_X_base.png` as a separate `Sprite2D` child below the tower (`z_index=-1`).

---

## Task 06-04 — Enemy Sprites

**Files**: `res://scenes/enemies/EnemyBase.tscn` and all variants

For each enemy type (Grunt, Runner, Brute, Flyer, Elite, Boss):
- [ ] In the scene editor: replace `Sprite2D` with `AnimatedSprite2D`.
- [ ] Assign the correct spritesheet in SpriteFrames.
- [ ] Configure animations: `walk` (loop), `attack` (loop while attacking), `death` (one-shot).
- [ ] In `EnemyBase.gd` inside `_move_toward_tower()`, add this one line so the
      sprite flips to face the direction of travel (same technique Archero uses):
  ```gdscript
  $AnimatedSprite2D.flip_h = velocity.x < 0
  ```
- [ ] In `EnemyBase.gd`:
  - Play `walk` when moving.
  - Switch to `attack` when `_is_attacking = true`.
  - In `die()`: play `death` animation, connect `animation_finished` to
    `ObjectPool.release(self)` so the full death animation plays before the node
    disappears.
- [ ] Resize `CollisionShape2D` to match the actual sprite size of each enemy variant.
- [ ] For `EnemyBoss.tscn`: use a 256×256 animated sprite. On phase transition,
      flash white with a `Modulate` Tween (`Color.WHITE` → original over 0.15s).

---

## Task 06-05 — Projectile Sprites

**Files**: `res://scenes/spells/ProjectileBase.tscn`

- [ ] Replace the placeholder `ColorRect` with `Sprite2D`.
- [ ] Assign `proj_bolt.png` as the default on the base scene.
- [ ] Per-spell override: if `spell.projectile_scene` is set on the SpellData resource,
      instance it as a child. Otherwise fall back to the default bolt sprite.
- [ ] For animated projectiles (fireball): use `AnimatedSprite2D` with 3-frame flicker loop.
- [ ] Sprite faces direction of travel via `rotation` (already applied in code).
      For non-rotating projectiles (cannonball): set `rotate = false` on the sprite node.

---

## Task 06-06 — Zone & Mine Sprites

**Files**: `res://scenes/spells/AoEZone.tscn`, `PersistentZone.tscn`, `LandMine.tscn`

These are pure 2D sprites — not from the 3D pipeline.

- [ ] `AoEZone.tscn`: replace `ColorRect` with `AnimatedSprite2D`. Pick sprite based on
      `damage_type` in `initialize()` — add a `_set_visuals(damage_type)` method.
- [ ] `PersistentZone.tscn`: replace `ColorRect` with looping `AnimatedSprite2D`.
      Scale to match radius at runtime: `sprite.scale = Vector2.ONE * (radius / 64.0)`.
- [ ] `LandMine.tscn`: `Sprite2D` for idle, swap to pulsing `AnimatedSprite2D` on arming.

---

## Task 06-07 — VFX Particle Systems

**Ref**: `assets.md` Section 5

VFX textures are 2D — drawn or sourced from free packs. Do not use the 3D pipeline.

Create a `GPUParticles2D` subscene for each VFX type in `res://scenes/spells/`
or `res://scenes/enemies/`:

- [ ] `VFXHitSpark.tscn` — 8 sparks, burst, one_shot, lifetime=0.3s.
      Texture: `vfx_spark_white.png`, tinted at runtime by damage type color.
- [ ] `VFXEnemyDeath.tscn` — 12 dust particles, burst, lifetime=0.6s.
      Texture: `vfx_death_dust.png`.
- [ ] `VFXExplosion.tscn` — `AnimatedSprite2D`, 6-frame `vfx_explosion_sheet.png`,
      one-shot, then `queue_free`.
- [ ] `VFXXPGem.tscn` — 1–3 gems that Tween toward the XP bar position, then `queue_free`.
      Texture: `vfx_xp_gem.png`.
- [ ] `VFXLevelUpRing.tscn` — ring centered on tower. Scale tween 0.2→2.0 over 0.5s,
      fade alpha to 0, then `queue_free`. Texture: `vfx_level_up_ring.png`.

Wiring:
- [ ] `ProjectileBase._on_body_entered()` → instance `VFXHitSpark` at impact position.
- [ ] `EnemyBase.die()` → instance `VFXEnemyDeath` at `global_position`.
- [ ] `AoEZone._apply_damage()` → instance `VFXExplosion` at position.
- [ ] `GameState._on_level_up()` → instance `VFXLevelUpRing` at tower position.
- [ ] `EnemyBase.die()` → instance 1–2 `VFXXPGem`, target = HUD XP bar global position.

---

## Task 06-08 — Arena Background

**File**: `res://scenes/main/GameWorld.tscn`

Pure 2D — not from the 3D pipeline.

- [ ] Replace the plain `ColorRect` background with `arena_ch1_plains.png` as a
      `TextureRect` (expand_mode=EXPAND_IGNORE_SIZE, anchors fill full screen).
- [ ] Set `z_index = -10` so all gameplay nodes render above it.
- [ ] Optional: add a `TileMap` layer above the background for ground variation
      tiles (64×64 tiles from Chapter 1 tileset).

---

## Task 06-09 — HUD Visual Polish

**File**: `res://scenes/ui/HUD.tscn`

- [ ] Replace `ProgressBar` nodes with `TextureProgressBar`:
  - HP bar: `ui_hp_bar_bg.png` / `ui_hp_bar_fill.png`. Tint green→yellow→red by HP%.
  - XP bar: `ui_xp_bar_bg.png` / `ui_xp_bar_fill.png`. Tint gold.
- [ ] Replace placeholder tag icons in `TagRowWidget` with `tag_X.png` textures.
- [ ] Import and apply fonts from `assets.md` Section 8.
- [ ] Add `ui_wave_icon.png` next to `WaveLabel`.
- [ ] Add `ui_level_icon.png` next to `LevelLabel`.

---

## Task 06-10 — Draft UI Visual Polish

**File**: `res://scenes/ui/DraftCard.tscn`, `DraftUI.tscn`

- [ ] Replace `RarityBorder` `ColorRect` with 9-slice `TextureRect` using
      `ui_card_bg_X.png` per rarity.
- [ ] Replace `CardIcon` placeholder with actual spell icon textures (`spell_X.png`).
      Fall back to a colored square if icon is null.
- [ ] Replace stat upgrade icon placeholders with `upgrade_X.png` textures.
- [ ] Add `ui_card_synergy_glow.png` overlay on cards that complete a synergy threshold.
- [ ] Add `ui_draft_title_bg.png` behind the "Choose an Upgrade" label.
- [ ] Set `Label.autowrap_mode = WORD` on card description text.

---

## Task 06-11 — Victory & Defeat Screen Polish

**Files**: `res://scenes/main/VictoryScreen.tscn`, `DefeatScreen.tscn`

- [ ] Replace `ColorRect` backgrounds with `screen_victory_bg.png` / `screen_defeat_bg.png`.
- [ ] Replace `Button` nodes with `TextureButton` using `ui_button_primary.png` (9-slice)
      for main actions, `ui_button_secondary.png` for secondary.
- [ ] Wrap stat panels in `ui_panel_dark.png` (9-slice `PanelContainer`).
- [ ] Apply display font for title labels, sans-serif for stat text.

---

## Task 06-12 — Integration Test

- [ ] Run the project. Confirm zero `ColorRect` or `Image.create()` placeholders visible.
- [ ] All enemy animations play: `walk` → `attack` → `death`. Death animation completes
      fully before node disappears (ObjectPool release fires on `animation_finished`).
- [ ] Enemy sprites flip horizontally when moving left vs right.
- [ ] Tower plays `attack` animation when firing, returns to `idle` after.
- [ ] Tower switches to `damaged` frame when HP drops below 30%.
- [ ] Hit sparks appear on enemy hits, color matches damage type.
- [ ] Death dust particle burst plays on enemy kill.
- [ ] XP gem floats from kill position toward the XP bar.
- [ ] Level-up ring expands from tower on level-up event.
- [ ] Boss phase transition plays white flash.
- [ ] Draft cards show spell icons and rarity borders.
- [ ] Synergy glow overlay appears on threshold-completing cards.
- [ ] Open Godot Profiler — confirm one-shot VFX nodes do not accumulate
      (each must `queue_free` after playing).
- [ ] Fix all visual glitches before moving to Epic 07.
