# Tower's Last Stand — Project Overview

> This is the master reference file. Read this first before touching any other file.
> All other files in this folder are referenced from here.

---

## What We Are Building

A mobile tower defense roguelite for Android and iOS built in Godot 4.x.

The player owns a collection of towers (their "heroes"). They pick one and enter a chapter. The tower sits fixed in the center of the arena. Waves of enemies stream in from all sides. The tower auto-attacks. Between waves and on level-up, the player drafts one of three random upgrade cards — spells or stat boosts. Tags on cards accumulate and unlock synergy bonuses. After the run, materials are spent in the meta layer to star up towers and rank up spells.

The core loop is: draft → fight → draft → fight → boss → result → meta upgrade → repeat.

---

## Reference Files

| File | Purpose |
|------|---------|
| `mechanics.md` | Every gameplay mechanic described in detail with priority labels |
| `components.md` | Every Godot scene, script, autoload, and resource in the project |
| `assets.md` | Every sprite, audio file, font, and VFX texture needed |
| `epic_01_foundation.md` | Sprint tasks: project setup, constants, autoloads, arena, basic enemy |
| `epic_02_combat.md` | Sprint tasks: tower fires, enemies die, damage system, object pool |
| `epic_03_draft.md` | Sprint tasks: draft UI, card system, synergy tags, spell behaviors |
| `epic_04_waves.md` | Sprint tasks: wave manager, enemy variety, scaling, boss |
| `epic_05_meta.md` | Sprint tasks: world map, tower garage, spell codex, save/load, energy |
| `epic_06_art.md` | Sprint tasks: replace all placeholder art, animations, VFX particles |
| `epic_07_audio.md` | Sprint tasks: all SFX and music wired, AudioManager, crossfading |
| `epic_08_polish.md` | Sprint tasks: damage numbers, synergy banner, performance, export |

---

## Tech Stack

| | Choice |
|---|---|
| Engine | Godot 4.x |
| Renderer | Compatibility (OpenGL ES 3.0 — best mobile performance) |
| Language | GDScript 4 |
| Resolution | 1080×1920 portrait |
| Stretch | canvas_items / keep |
| Target platforms | Android first, iOS second |
| Min Android | API 24 (Android 7.0) |
| Art style | Low-poly 3D rendered to sprites (Blender → PNG spritesheet) OR clean 2D vector |

---

## Asset Strategy & Swap Policy

> **Starting assets**: Quaternius.com free packs (CC0 license — free for commercial use, no attribution required).
> **Future swaps**: All art is designed to be swapped at any time without touching game logic.

### Quaternius Packs In Use

| Pack | URL | Used For |
|------|-----|----------|
| Ultimate Fantasy RTS | quaternius.com/packs/ultimatefantasyrts.html | Tower models (Ironclad, Sentinel), arena environment |
| Steampunk Turret Pack | quaternius.com/packs/turretpack.html | Tower models (Ember, Tide, Phantom variants) |
| Ultimate Monsters | quaternius.com/packs/ultimatemonsters.html | Enemy types: Grunt, Brute, Boss |
| Cute Animated Monsters Pack | quaternius.com/packs/cutemonsters.html | Enemy types: Runner, Flyer |
| RPG Character Pack | quaternius.com/packs/rpgcharacters.html | Elite enemy |
| Animated Monster Pack | quaternius.com/packs/animatedmonster.html | Additional enemy variants, Boss alternate |
| Medieval Village MegaKit | quaternius.com/packs/medievalvillagemegakit.html | Chapter 1 arena background |
| Ultimate Modular Ruins Pack | quaternius.com/packs/ultimatemodularruins.html | Chapter 2+ arena backgrounds |
| Stylized Nature MegaKit | quaternius.com/packs/stylizednaturemegakit.html | Arena decoration (trees, rocks, props) |
| Universal Animation Library | quaternius.com/packs/universalanimationlibrary.html | Retarget walk/attack/death animations onto any humanoid |

### Pipeline: 3D Model → Godot Sprite

All Quaternius models are rendered in Blender before importing into Godot:

1. Import the `.FBX` or `.glTF` model into Blender.
2. Set up an orthographic camera at ~60° top-down angle (matching Archero's look).
3. Apply flat/cel shading with a soft rim light.
4. Render each animation (walk, attack, death) frame by frame at 128×128 px (enemies) or 160×160 px (towers).
5. Pack rendered frames into a horizontal spritesheet PNG using Blender's compositor or a free tool like TexturePacker / free.texturepacker.com.
6. Place the spritesheet in `res://assets/sprites/` with the exact filename from `assets.md`.
7. Import into Godot as `AnimatedSprite2D` (see Epic 06 for full wiring instructions).

### How to Swap an Asset Later

Swapping any sprite never requires code changes. Only do these steps:

1. Render the new model or generate the new sprite using the same pipeline above.
2. Name the output file **exactly the same** as the file it replaces (e.g. `enemy_grunt.png`).
3. Drop it into `res://assets/sprites/` — Godot will auto-reimport.
4. If frame count or frame size changed: open the `AnimatedSprite2D` in the Godot editor, update the frame count and region settings in the SpriteFrames panel. No script editing needed.
5. If collision shape needs resizing for a larger/smaller sprite: adjust the `CollisionShape2D` radius in the scene editor only. No script editing needed.

### Asset Swap Difficulty Rating

| Asset Type | Difficulty | What to Change |
|------------|-----------|----------------|
| Enemy sprite | ⭐ Very Easy | Drop new PNG in folder, update frame count if different |
| Tower sprite | ⭐ Very Easy | Drop new PNG in folder |
| Projectile sprite | ⭐ Very Easy | Drop new PNG in folder |
| Arena background | ⭐ Very Easy | Drop new PNG in folder |
| Spell icon (UI) | ⭐ Very Easy | Drop new PNG in folder |
| VFX particle texture | ⭐⭐ Easy | Drop new PNG, may need to tweak GPUParticles2D scale |
| Enemy with different frame count | ⭐⭐ Easy | Update SpriteFrames panel in editor |
| Enemy with very different collision size | ⭐⭐ Easy | Resize CollisionShape2D in scene editor |
| Completely different animation set (e.g. adding a new `stun` animation) | ⭐⭐⭐ Medium | Add new animation in SpriteFrames + one `play("stun")` call in script |

### Key Rule for Claude Code

> Every `AnimatedSprite2D` node in this project MUST reference its texture via a named file path in `res://assets/sprites/`. Never hardcode pixel colors or generate textures procedurally in final art code. This ensures any artist can swap a file without reading any GDScript.

---

## Game Structure

```
World Map
  └── Chapter Select
        └── Run Start (spend 1 energy, pick tower)
              └── GameWorld
                    ├── Wave 1
                    │     ├── Combat (auto-attack + spells)
                    │     └── Wave Clear → Draft (pick 1 of 3 cards)
                    ├── Wave 2
                    │     ├── Combat
                    │     ├── Level Up mid-wave → Draft (combat pauses)
                    │     └── Wave Clear → Draft
                    ├── ...
                    ├── Wave 20 (Boss Wave)
                    │     └── Boss killed → Victory
                    └── Tower dies at any point → Defeat
              └── Result Screen (materials earned, stats)
        └── Tower Garage (upgrade tower stars with materials)
        └── Spell Codex (rank up spells with materials)
```

---

## Core Mechanics Summary

**Tower**: Fixed at arena center. Auto-attacks. Chosen before run. 5 tower types at launch.

**Waves**: Kill-based (wave ends when all enemies dead, not on a timer). 20 waves per chapter. Enemies scale per wave.

**Draft**: 3 random cards offered after each wave clear and on each level-up. Pick 1. No gold. No shop. Pure draft.

**Spells**: 25 at launch across 5 damage type families (Normal, Piercing, Magic, Siege, Chaos). Each fires independently on its own cooldown.

**Synergy Tags**: Every card has 1–2 tags. Hitting ×3 and ×5 of a tag unlocks passive bonuses for the run.

**Meta**: Materials earned from runs. Spent to star up towers (Star 1–5) and rank up spells (Rank 1–5). Stars improve stats and enhance passives. Ranks add new behaviors to spells.

**Monetization**: Energy system (5/day), cosmetic tower skins, tower unlock packs (time-saving not power), battle pass (v2).

---

## Enemy Types

| Type | Armor | Introduced |
|------|-------|-----------|
| Grunt | Medium | Wave 1 |
| Runner | Light | Wave 5+ |
| Brute | Heavy | Wave 10+ |
| Flyer | Medium | Wave 15+ |
| Elite | Random | Chapter 3+ |
| Boss | Chaos | Wave 20 |

---

## Damage Type vs Armor Table (Quick Reference)

| | Unarmored | Light | Medium | Heavy |
|---|---|---|---|---|
| Normal | 1.0× | 1.5× | 2.0× | 0.7× |
| Piercing | 2.0× | 1.5× | 0.5× | 0.35× |
| Magic | 1.0× | 1.0× | 1.25× | 0.35× |
| Siege | 0.5× | 0.5× | 0.5× | 2.0× |
| Chaos | 1.0× | 1.0× | 1.0× | 1.0× |

---

## Synergy Tags Quick Reference

| Tag | ×3 | ×5 |
|-----|----|----|
| [Fire] | Fire spells +25% dmg | Killed enemies leave Burn patch |
| [Chain] | Chains jump +1 extra | Chain jumps apply damage type debuff |
| [Piercing] | Pierce +1 extra enemy | Pierce kills restore 0.5% max HP |
| [Heavy] | Siege +40% vs high-HP enemies | Siege attacks stun 0.3s |
| [Armor] | Take 15% less damage | Regen 1% max HP / 5 sec |
| [Offense] | All damage +10% | Every 10th attack fires bonus projectile |
| [Utility] | Spell cooldowns -10% | Draft shows 4 cards instead of 3 |
| [Gold] | +30% materials end of run | Bonus cache if run cleared without dying |
| [Chaos] | Chaos ignores 50% extra armor | 15% chance to instantly kill non-boss |

---

## Towers Quick Reference

| Tower | Passive | Star 3 Enhancement | Star 5 Second Passive |
|-------|---------|-------------------|----------------------|
| Ironclad | Every 5th shot fires 8-way | 8-way burst also applies slow | Gains 20% damage reduction |
| Ember | Base attack applies Burn | Burn spreads on death | Every 10th shot detonates all Burn stacks |
| Tide | Base attack bounces to 2nd enemy | Bounce hits a 3rd enemy | Chain synergies jump +1 extra always |
| Sentinel | +50% base range | Long-range spells +15% dmg | Ignores 30% of all enemy armor |
| Phantom | No base attack, spells +30% dmg | Spells gain +15% crit chance | One random spell fires twice per cooldown |

---

## Epic Summary & Build Order

Work epics in order. Each epic builds on the previous one. Do not start an epic until all tasks in the prior epic are complete and tested.

| Epic | Description | Deliverable |
|------|-------------|-------------|
| 01 Foundation | Project setup, constants, autoloads, arena, one enemy walks toward tower | Playable skeleton |
| 02 Combat | Tower fires, damage system, enemies die, gold XP rewards, object pool | Combat works |
| 03 Draft | Draft UI, card selection, spells fire, synergy tags, stat upgrades | Full run loop works |
| 04 Waves | All enemy types, wave scaling, boss, chapter config, win/lose | Complete run works |
| 05 Meta | World map, tower garage, spell codex, MetaManager, save/load, energy | Full game loop works |
| 06 Art | All placeholder art replaced with real sprites and animations | Looks like a game |
| 07 Audio | All SFX and music wired, AudioManager, crossfading | Sounds like a game |
| 08 Polish | Damage numbers, synergy banner, targeting, performance, mobile export | Shippable |

---

## Godot Project Settings

```
Display > Window > Size: 1080 × 1920
Display > Window > Stretch Mode: canvas_items
Display > Window > Stretch Aspect: keep
Rendering > Renderer: Compatibility
Physics > 2D > Default Gravity: 0
```

**Autoload order** (set in Project > Project Settings > Autoload):
1. Constants
2. EventBus
3. GameState
4. MetaManager
5. SpellRegistry
6. WaveManager
7. DraftManager
8. ObjectPool
9. AudioManager

---

## Folder Structure

```
res://
├── autoloads/
├── scenes/
│   ├── main/
│   ├── tower/
│   ├── enemies/
│   ├── spells/
│   └── ui/
├── scripts/
├── resources/
│   ├── spells/
│   ├── towers/
│   ├── waves/
│   └── chapters/
└── assets/
    ├── sprites/
    ├── audio/
    └── fonts/
```

Full file list with node types and script signatures: see `components.md`.
Full asset list with sizes and formats: see `assets.md`.
Full mechanic descriptions with priority labels: see `mechanics.md`.
