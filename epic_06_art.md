# Epic 06 — Art

> Prerequisite: Epic 05 complete and tested. The game must be fully playable with placeholder art before touching this epic.
> Goal: Replace every colored rectangle placeholder with real sprites and animations. Game looks like a finished product.
> Completed epic delivers: all sprites, animations, and particle VFX wired up. No ColorRect placeholders remain in the gameplay scene.

---

## Task 06-01 — Import All Sprites & Set Import Settings

**Ref**: `assets.md` — full sprite list

- [ ] Place all sprites in `res://assets/sprites/` with the exact filenames from `assets.md`.
- [ ] For **pixel art sprites**: set all textures to `Filter: Nearest`, `Compress: Lossless`.
- [ ] For **rendered/vector sprites**: set `Filter: Linear`, `Compress: VRAM Compressed`.
- [ ] For **spritesheets** (enemies, VFX): set `Filter: Nearest`, region frames using `AtlasTexture` or `AnimatedSprite2D` frame data.
- [ ] Set all tower and enemy spritesheets to `AnimatedSprite2D` with named animations: `idle`, `attack`, `damaged`, `death`.
- [ ] Verify no import errors in Godot's FileSystem panel (red icons = bad import).

---

## Task 06-02 — Tower Sprites

**Files**: `res://scenes/tower/TowerBase.tscn` and all tower variants

For each tower (Ironclad, Ember, Tide, Sentinel, Phantom):
- [ ] Replace `Sprite2D` with `AnimatedSprite2D`.
- [ ] Assign the correct spritesheet (`tower_X.png`).
- [ ] Configure animations:
  - `idle`: frames 0–1 (or 0–3), loop=true, fps=4.
  - `attack`: frames for fire flash, loop=false, fps=12.
  - `damaged`: single alternate frame, loop=true, fps=2.
- [ ] In `TowerBase.gd`:
  - Play `idle` in `_ready()`.
  - In `_fire_spell()`: play `attack` animation, then return to `idle` on finish (connect `animation_finished`).
  - In `GameState._on_hp_changed()` (or via signal): if `tower_hp < tower_max_hp * 0.3`, switch tower to `damaged` animation.
- [ ] Replace the `RangeIndicator` placeholder with a proper `_draw()` call:
  - Draw a semi-transparent circle outline (alpha=0.15, white) at `base_range + GameState.tower_range_bonus` radius.
  - Redraw on range change (call `queue_redraw()` when range updates).
- [ ] Add `tower_X_base.png` as a separate `Sprite2D` child below the tower (z_index=-1).

---

## Task 06-03 — Enemy Sprites

**Files**: `res://scenes/enemies/EnemyBase.tscn` and all variants

For each enemy type (Grunt, Runner, Brute, Flyer, Elite, Boss):
- [ ] Replace `Sprite2D` with `AnimatedSprite2D`.
- [ ] Assign the correct spritesheet.
- [ ] Configure animations: `walk` (loop), `attack` (loop while attacking), `death` (one-shot).
- [ ] In `EnemyBase.gd`:
  - Play `walk` when moving.
  - Switch to `attack` when `_is_attacking = true`.
  - Play `death` in `die()` before releasing to pool. Connect `animation_finished` to `ObjectPool.release(self)` so the death animation completes before the node disappears.
- [ ] Resize `CollisionShape2D` to match the actual sprite size of each enemy variant.
- [ ] For `EnemyBoss.tscn`: use a 256×256 animated sprite. On phase transition, play a one-shot transition animation (flash white using `Modulate` Tween).

---

## Task 06-04 — Projectile Sprites

**Files**: `res://scenes/spells/ProjectileBase.tscn`

- [ ] Replace the yellow ColorRect placeholder with `Sprite2D`.
- [ ] Make `ProjectileBase` use a `projectile_scene` override: if `spell.projectile_scene` is set, instance it as a child. Otherwise fall back to a default bolt sprite.
- [ ] Apply correct sprite per spell category:
  - Normal projectiles: `proj_bolt.png`.
  - Per-spell overrides: set `projectile_scene` in each `.tres` spell resource to a small subscene that holds the correct sprite.
  - For animated projectiles (fireball): use `AnimatedSprite2D` with 3-frame flicker loop.
- [ ] Ensure `rotation` is applied correctly — sprite should face the direction of travel. For sprites that shouldn't rotate (cannonball): set `rotate = false` on the sprite node and handle visually.

---

## Task 06-05 — Zone & Mine Sprites

**Files**: `res://scenes/spells/AoEZone.tscn`, `PersistentZone.tscn`, `LandMine.tscn`

- [ ] In `AoEZone.tscn`: replace ColorRect with `AnimatedSprite2D`. Use the appropriate zone sprite based on `damage_type` (set in `initialize()` based on spell — add a `_set_visuals(damage_type)` method).
- [ ] In `PersistentZone.tscn`: replace ColorRect with looping `AnimatedSprite2D`. Scale to match `CollisionShape2D` radius at runtime: `sprite.scale = Vector2.ONE * (radius / 64.0)`.
- [ ] In `LandMine.tscn`: replace ColorRect with `Sprite2D` for idle and `AnimatedSprite2D` for the armed pulse (swap on enter).

---

## Task 06-06 — VFX Particle Systems

**Ref**: `assets.md` Section 5

For each VFX type, create a `GPUParticles2D` subscene in `res://scenes/spells/` or `res://scenes/enemies/`:

- [ ] `VFXHitSpark.tscn` — triggered on projectile impact. 8 sparks, burst=true, one_shot=true, lifetime=0.3s. Texture: `vfx_spark_white.png` (tinted at runtime by damage type color from `CombatUtils.get_damage_color()`).
- [ ] `VFXEnemyDeath.tscn` — triggered on enemy death. 12 dust particles, burst, lifetime=0.6s. Texture: `vfx_death_dust.png`.
- [ ] `VFXExplosion.tscn` — for AoE bursts. Play `vfx_explosion_sheet.png` as `AnimatedSprite2D` (6 frames), one-shot, then queue_free.
- [ ] `VFXXPGem.tscn` — on enemy death, spawn 1–3 gem particles that float upward toward the XP bar position. Texture: `vfx_xp_gem.png`. Tween toward XP bar position, then queue_free.
- [ ] `VFXLevelUpRing.tscn` — expanding `AnimatedSprite2D` ring centered on tower when level-up fires. Scale tween: 0.2 → 2.0 over 0.5s, fade alpha. queue_free after.

Wiring:
- [ ] In `ProjectileBase._on_body_entered()`: instance `VFXHitSpark` at impact position, add to `VFXContainer`.
- [ ] In `EnemyBase.die()`: instance `VFXEnemyDeath` at `global_position`, add to `VFXContainer`.
- [ ] In `AoEZone._apply_damage()`: instance `VFXExplosion` at position.
- [ ] In `GameState._on_level_up()` (or `GameWorld._on_level_up()`): instance `VFXLevelUpRing` at tower position.
- [ ] In `EnemyBase.die()`: instance 1–2 `VFXXPGem` nodes. Set their target position to the HUD XP bar's global position.

---

## Task 06-07 — HUD Visual Polish

**File**: `res://scenes/ui/HUD.tscn`
**Ref**: `assets.md` Section 6

- [ ] Replace ProgressBar nodes with `TextureProgressBar`:
  - HP bar: `ui_hp_bar_bg.png` for under, `ui_hp_bar_fill.png` for fill. Tint fill green → yellow → red based on HP %.
  - XP bar: `ui_xp_bar_bg.png` / `ui_xp_bar_fill.png`. Tint gold.
- [ ] Replace placeholder tag icons in `TagRowWidget` with actual `tag_X.png` textures from `assets.md`.
- [ ] Replace fonts:
  - HUD numbers (HP, wave): monospaced pixel font.
  - Labels (wave text, level): clean sans-serif bold.
  - Import all fonts as `.ttf` resources.
- [ ] Add the wave icon (`ui_wave_icon.png`) next to `WaveLabel`.
- [ ] Add the level icon (`ui_level_icon.png`) next to `LevelLabel`.

---

## Task 06-08 — Draft UI Visual Polish

**File**: `res://scenes/ui/DraftCard.tscn`, `DraftUI.tscn`

- [ ] Replace `RarityBorder` ColorRect with a 9-slice `TextureRect` using the correct `ui_card_bg_X.png` per rarity.
- [ ] Replace the `CardIcon` solid color placeholder with actual spell icon textures (`spell_X.png`). Fall back to a colored square if icon is null.
- [ ] Replace stat upgrade card icon placeholders with `upgrade_X.png` textures.
- [ ] Add `ui_card_synergy_glow.png` as an overlay on cards that would complete a synergy — show/hide via `SynergyHint` logic already in place.
- [ ] In `DraftUI.tscn`: add `ui_draft_title_bg.png` behind the "Choose an Upgrade" label.
- [ ] Ensure card `description` text wraps correctly (set `Label.autowrap_mode = WORD`).

---

## Task 06-09 — Arena Background

**File**: `res://scenes/main/GameWorld.tscn`
**Ref**: `assets.md` Section 7

- [ ] Replace the plain ColorRect background with `arena_ch1_plains.png` as a `TextureRect` (expand_mode=EXPAND_IGNORE_SIZE, anchors fill full screen).
- [ ] Set the `TextureRect` z_index to -10 so all gameplay nodes render above it.
- [ ] Optional (if tileset available): add a `TileMap` layer above the background for ground variation tiles (64×64 tiles from Chapter 1 tileset).

---

## Task 06-10 — Victory & Defeat Screen Polish

**Files**: `res://scenes/main/VictoryScreen.tscn`, `DefeatScreen.tscn`

- [ ] Replace ColorRect backgrounds with `screen_victory_bg.png` and `screen_defeat_bg.png`.
- [ ] Replace Button nodes with `TextureButton` using `ui_button_primary.png` (9-slice) for main actions and `ui_button_secondary.png` for secondary.
- [ ] Wrap stat panels in a `ui_panel_dark.png` (9-slice PanelContainer).
- [ ] Apply the display font for title labels and sans-serif for stat text.

---

## Task 06-11 — Integration Test

- [ ] Run the project. Confirm zero ColorRect placeholders visible during gameplay.
- [ ] Verify all enemy animations play: walk → attack → death. Confirm death animation completes before node disappears.
- [ ] Verify tower plays attack animation when firing.
- [ ] Verify tower switches to damaged frame when HP < 30%.
- [ ] Verify hit sparks appear on enemy hits (color matches damage type).
- [ ] Verify death dust particle burst on enemy kill.
- [ ] Verify XP gem floats from enemy kill toward XP bar.
- [ ] Verify level-up ring expands from tower on level-up.
- [ ] Verify boss phase transition plays white flash correctly.
- [ ] Verify draft cards show spell icons (or fallback squares) and rarity borders.
- [ ] Verify synergy glow overlay appears on cards that would complete a threshold.
- [ ] Check Godot Profiler: confirm no VFX particle systems accumulate (they should queue_free after one-shot).
- [ ] Fix all visual glitches before moving to Epic 07.
