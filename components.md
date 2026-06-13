# Tower's Last Stand — Components Reference

> Every scene, script, autoload, and resource in the project.
> Engine: Godot 4.x, Compatibility renderer (OpenGL ES 3.0), portrait 1080×1920.
> All code is GDScript 4. Node types are Godot 4 node names.

---

## 1. Project Folder Structure

```
res://
├── autoloads/
│   ├── GameState.gd
│   ├── WaveManager.gd
│   ├── DraftManager.gd
│   ├── SpellRegistry.gd
│   ├── MetaManager.gd
│   ├── ObjectPool.gd
│   ├── AudioManager.gd
│   └── EventBus.gd
├── scenes/
│   ├── main/
│   │   ├── GameWorld.tscn          # root scene during a run
│   │   ├── WorldMap.tscn           # chapter select screen
│   │   ├── TowerGarage.tscn        # tower collection & upgrade
│   │   ├── SpellCodex.tscn         # spell collection & rank-up
│   │   ├── DefeatScreen.tscn
│   │   └── VictoryScreen.tscn
│   ├── tower/
│   │   ├── TowerBase.tscn          # shared base
│   │   ├── TowerIronclad.tscn
│   │   ├── TowerEmber.tscn
│   │   ├── TowerTide.tscn
│   │   ├── TowerSentinel.tscn
│   │   └── TowerPhantom.tscn
│   ├── enemies/
│   │   ├── EnemyBase.tscn
│   │   ├── EnemyGrunt.tscn
│   │   ├── EnemyRunner.tscn
│   │   ├── EnemyBrute.tscn
│   │   ├── EnemyFlyer.tscn
│   │   ├── EnemyElite.tscn
│   │   └── EnemyBoss.tscn
│   ├── spells/
│   │   ├── ProjectileBase.tscn
│   │   ├── AoEZone.tscn
│   │   ├── PersistentZone.tscn
│   │   └── LandMine.tscn
│   └── ui/
│       ├── HUD.tscn
│       ├── DraftUI.tscn
│       ├── DraftCard.tscn
│       ├── SynergyBanner.tscn
│       └── TagRowWidget.tscn
├── scripts/
│   ├── CombatUtils.gd
│   ├── Constants.gd
│   └── SaveData.gd
├── resources/
│   ├── spells/
│   │   ├── SpellData.gd            # base Resource class
│   │   ├── spell_throwing_axes.tres
│   │   └── ... (one .tres per spell)
│   ├── towers/
│   │   ├── TowerData.gd            # base Resource class
│   │   ├── tower_ironclad.tres
│   │   └── ...
│   ├── waves/
│   │   ├── WaveConfig.gd
│   │   └── chapter_01.tres
│   └── chapters/
│       └── ChapterConfig.gd
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── export_presets.cfg
```

---

## 2. Constants & Enums

**File**: `res://scripts/Constants.gd`
**Type**: Static script (class_name Constants)

```gdscript
enum GamePhase      { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType     { NORMAL, PIERCING, MAGIC, SIEGE, CHAOS }
enum ArmorType      { UNARMORED, LIGHT, MEDIUM, HEAVY }
enum SpellCategory  { PROJECTILE, AOE_BURST, PERSISTENT_ZONE, CHAIN, MINE, PASSIVE, STAT_BOOST }
enum EnemyType      { GRUNT, RUNNER, BRUTE, FLYER, ELITE, BOSS }
enum TargetMode     { CLOSEST, LOWEST_HP, HIGHEST_HP, FIRST }
enum CardRarity     { COMMON, RARE, EPIC }
enum SynergyTag     { FIRE, CHAIN, PIERCING, HEAVY, ARMOR, OFFENSE, UTILITY, GOLD, CHAOS_TAG }
enum TowerID        { IRONCLAD, EMBER, TIDE, SENTINEL, PHANTOM }
enum MaterialType   { CHAPTER_MAT, UNIVERSAL_MAT }

const WAVE_DURATION_MAX:        float = 30.0   # fallback if kill-based clear stalls
const TOTAL_WAVES:              int   = 20
const DRAFT_CARDS_SHOWN:        int   = 3
const ENEMY_HP_SCALE:           float = 1.12
const ENEMY_DMG_SCALE:          float = 1.08
const XP_PER_KILL_BASE:         int   = 10
const XP_PER_LEVEL_BASE:        int   = 100    # scales up per level
const MAX_SPELL_SLOTS:          int   = 12     # max spells active at once
const MAX_MINES:                int   = 10
const SYNERGY_THRESHOLD_LOW:    int   = 3
const SYNERGY_THRESHOLD_HIGH:   int   = 5
const TOWER_MAX_STARS:          int   = 5
const SPELL_MAX_RANK:           int   = 5
const MAX_ENERGY:               int   = 5
```

---

## 3. Autoload Singletons

### `EventBus.gd`
Decoupled signal relay. Any node emits or connects here without direct references.

```gdscript
# Combat
signal enemy_died(enemy: Node, position: Vector2)
signal enemy_reached_tower(enemy: Node)
signal tower_damaged(amount: float)
signal tower_healed(amount: float)
signal tower_died

# XP & leveling
signal xp_gained(amount: int)
signal level_up(new_level: int)

# Wave & phase
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal phase_changed(new_phase: int)
signal boss_spawned
signal boss_died

# Draft
signal draft_opened
signal draft_closed
signal card_selected(card_data: Resource)

# Synergy
signal synergy_threshold_reached(tag: int, level: int)   # level = 3 or 5

# Meta
signal run_ended(victory: bool, wave_reached: int)
signal materials_earned(chapter_mat: int, universal_mat: int)
signal tower_upgraded(tower_id: int, new_star: int)
signal spell_ranked_up(spell_id: String, new_rank: int)
```

---

### `GameState.gd`
Single source of truth for all live run data.

```gdscript
# Run state
var phase: int                  # GamePhase enum
var wave_number: int            # 1–20
var run_level: int              # tower level this run
var run_xp: int
var run_xp_to_next: int

# Tower live stats (base + all draft bonuses applied)
var tower_hp: int
var tower_max_hp: int
var tower_regen_per_sec: float
var tower_damage_multiplier: float
var tower_fire_rate_multiplier: float
var tower_range_bonus: float
var tower_armor: int

# Active spells this run
var active_spells: Array[SpellData]

# Synergy tag counts
var tag_counts: Dictionary       # { SynergyTag: int }
var active_synergies: Dictionary # { SynergyTag: Array[int] }  (which thresholds hit)

# Run stats (for end screen)
var total_kills: int
var waves_cleared: int
var damage_dealt: float

# Methods
func start_run(tower_data: TowerData) -> void
func end_run(victory: bool) -> void
func gain_xp(amount: int) -> void
func apply_card(card: Resource) -> void      # SpellData or StatUpgradeData
func add_tag(tag: int) -> void               # checks thresholds, emits synergy signal
func take_damage(amount: float) -> void
func heal(amount: float) -> void
func reset() -> void

# Signals
signal hp_changed(new_hp: int, max_hp: int)
signal xp_bar_updated(current: int, needed: int)
signal tag_count_changed(tag: int, new_count: int)
```

---

### `WaveManager.gd`
Controls enemy spawning per wave. Reads WaveConfig resources.

```gdscript
var _active_enemies: Array[Node]
var _trickle_timer: Timer
var _wave_config: WaveConfig

func start_wave(wave_number: int, chapter_config: ChapterConfig) -> void
func stop_wave() -> void            # pause spawning, clear remaining enemies on phase end
func clear_all_enemies() -> void    # instant kill all (no XP), used on run end

func _spawn_burst(count: int, enemy_pool: Array) -> void
func _spawn_enemy(type: int) -> Node
func _get_spawn_position() -> Vector2   # random point on arena perimeter
func _apply_wave_scaling(enemy: Node, wave: int) -> void

func _on_enemy_died(enemy: Node) -> void
    # Remove from _active_enemies. If array empty: emit wave_cleared.
```

---

### `DraftManager.gd`
Handles card pool, weighted random draw, and synergy-aware card generation.

```gdscript
var _card_pool: Array[Resource]     # all SpellData + StatUpgradeData resources
var _taken_cards: Array[Resource]   # cards picked this run

func open_draft() -> void
    # Draw DRAFT_CARDS_SHOWN cards. Emit draft_opened.
func get_draft_cards() -> Array[Resource]
    # Weighted random draw. Guarantees 1 card matches existing tag if player has 2+.
func select_card(card: Resource) -> void
    # Apply card via GameState.apply_card(). Add tags. Emit card_selected. Close draft.
func _weighted_draw(pool: Array, count: int) -> Array
func _is_excluded(card: Resource) -> bool
    # Returns true for non-stackable cards already at max in active_spells.
```

---

### `SpellRegistry.gd`
Loads and serves all spell and stat upgrade resources.

```gdscript
var all_spells: Array[SpellData]
var all_stat_upgrades: Array[StatUpgradeData]

func _ready() -> void
    # Load all .tres from res://resources/spells/ and res://resources/upgrades/

func get_spell(id: String) -> SpellData
func get_spells_by_tag(tag: int) -> Array[SpellData]
func get_all_cards() -> Array[Resource]   # spells + stat upgrades combined
```

---

### `MetaManager.gd`
Handles all persistent data: tower stars, spell ranks, materials, unlocks.

```gdscript
var owned_towers: Array[int]        # TowerID values
var tower_stars: Dictionary         # { TowerID: int }
var spell_ranks: Dictionary         # { spell_id: int }
var discovered_spells: Array[String]
var materials: Dictionary           # { MaterialType: int }
var energy: int
var premium_currency: int
var selected_tower_id: int

func save() -> void
func load() -> void

func upgrade_tower(tower_id: int) -> bool
func rank_up_spell(spell_id: String) -> bool
func spend_materials(type: int, amount: int) -> bool
func add_materials(type: int, amount: int) -> void
func spend_energy() -> bool
func restore_energy(amount: int) -> void
func discover_spell(spell_id: String) -> void   # called first time spell is drafted
func get_upgrade_cost(tower_id: int, target_star: int) -> Dictionary
func get_rank_cost(spell_id: String, target_rank: int) -> Dictionary
```

---

### `ObjectPool.gd`
Reuse projectile, enemy, and VFX nodes to avoid per-frame instantiation.

```gdscript
var _pools: Dictionary      # { scene_path: Array[Node] }

func get(scene: PackedScene) -> Node
func release(node: Node) -> void
func preload_pool(scene: PackedScene, count: int) -> void
func release_all(scene: PackedScene) -> void
```

---

### `AudioManager.gd`
Pooled audio playback. Manages SFX pool and single music player.

```gdscript
var _sfx_pool: Array[AudioStreamPlayer]     # pool of 12
var _music_player: AudioStreamPlayer
var _music_target: AudioStream              # for crossfade

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void
func play_music(stream: AudioStream, crossfade: bool = true) -> void
func stop_music() -> void
func set_sfx_volume(db: float) -> void
func set_music_volume(db: float) -> void
func _crossfade(from: AudioStreamPlayer, to_stream: AudioStream) -> void
```

---

## 4. Main Scenes

### `GameWorld.tscn`
**Root**: Node2D
**Children**:
- `Background` (Sprite2D) — arena floor/background art
- `TilemapArena` (TileMap) — ground tiles
- `TowerNode` (instance of selected tower scene)
- `EnemyContainer` (Node2D) — parent for all active enemies
- `ProjectileContainer` (Node2D) — parent for all active projectiles
- `ZoneContainer` (Node2D) — parent for AoE/persistent zones
- `MineContainer` (Node2D) — parent for active mines
- `VFXContainer` (Node2D) — particles and floating labels
- `HUD` (CanvasLayer, instance of HUD.tscn)
- `DraftUI` (CanvasLayer, instance of DraftUI.tscn, hidden by default)
- `SynergyBanner` (CanvasLayer, instance of SynergyBanner.tscn, hidden by default)

**Script** `GameWorld.gd`:
```gdscript
func _ready() -> void
    # Connect EventBus signals. Preload object pools. Start run.
func _on_phase_changed(phase: int) -> void
    # DRAFT → show DraftUI. WAVE → hide DraftUI, start wave.
func _on_boss_died() -> void
    # Transition to VICTORY.
func _on_tower_died() -> void
    # Transition to DEFEAT.
func _on_synergy_threshold_reached(tag, level) -> void
    # Show SynergyBanner briefly.
func _on_run_ended(victory: bool, wave: int) -> void
    # Calculate materials, save via MetaManager, load result screen.
```

---

### `WorldMap.tscn`
**Root**: Control (CanvasLayer)
**Children**:
- `ChapterList` (VBoxContainer) — scrollable list of chapter buttons
- `EnergyDisplay` (HBoxContainer) — shows current energy + regen timer
- `GarageButton` (Button) → opens TowerGarage
- `CodexButton` (Button) → opens SpellCodex
- `SettingsButton` (Button)

**Script** `WorldMap.gd`:
```gdscript
func _ready() -> void
    # Populate chapter list from ChapterConfig resources. Grey out locked chapters.
func _on_chapter_pressed(chapter_id: int) -> void
    # Check energy. If ok: spend energy, load GameWorld with chapter config.
```

---

## 5. Tower Scenes

### `TowerBase.tscn`
**Root**: Area2D
**Children**:
- `Sprite2D` — idle animation (AnimatedSprite2D for multi-frame)
- `DamagedSprite` (Sprite2D, hidden by default) — shown at HP < 30%
- `CollisionShape2D` — circle, radius ~50px
- `AttackRangeArea` (Area2D + CollisionShape2D) — detects enemies in range
- `RangeIndicator` (Node2D) — draws range circle, shown during draft phase
- `RegenTimer` (Timer) — 1 sec interval
- `HPBar` (ProgressBar or custom Control) — shown in HUD, not above tower

**Script** `TowerBase.gd`:
```gdscript
@export var tower_data: TowerData

var _spell_cooldowns: Dictionary    # { spell_id: float }
var _enemies_in_range: Array[Node]

func _ready() -> void
    # Load stats from tower_data + MetaManager star bonuses.

func _physics_process(delta: float) -> void
    # Tick all spell cooldowns. Fire when ready.

func take_damage(amount: float) -> void
    # Apply armor reduction. Call GameState.take_damage(). Check damaged state.

func add_spell(spell: SpellData) -> void
func remove_all_spells() -> void

func _fire_spell(spell: SpellData) -> void
    # Dispatch to correct method by spell.spell_category.

func _fire_projectile(spell: SpellData) -> void
func _fire_aoe(spell: SpellData) -> void
func _fire_passive(spell: SpellData) -> void

func _get_target(range: float, mode: int) -> Node
    # Returns enemy node using TargetMode. Returns null if none in range.

func _on_regen_timer_timeout() -> void
func _on_attack_range_body_entered(body: Node) -> void
func _on_attack_range_body_exited(body: Node) -> void
func _draw() -> void
    # Draws range circle when RangeIndicator is visible.
```

**Subclass scripts** (extend TowerBase, override passive behavior):
- `TowerIronclad.gd` — overrides `_fire_projectile()` to fire 8-direction burst every 5th shot.
- `TowerEmber.gd` — overrides `_fire_projectile()` to apply Burn status on hit.
- `TowerTide.gd` — overrides `_fire_projectile()` to bounce to second target.
- `TowerSentinel.gd` — overrides `_ready()` to apply +50% range multiplier.
- `TowerPhantom.gd` — overrides `_fire_projectile()` to do nothing (no base attack).

---

## 6. Enemy Scenes

### `EnemyBase.tscn`
**Root**: CharacterBody2D
**Children**:
- `AnimatedSprite2D` — walk / attack / death animations
- `CollisionShape2D` — capsule
- `HitArea` (Area2D + CollisionShape2D) — receives projectile collisions
- `AttackZone` (Area2D + CollisionShape2D) — small circle, detects tower proximity
- `HPBar` (Control, small bar above enemy) — hidden until first hit

**Script** `EnemyBase.gd`:
```gdscript
@export var base_hp: float
@export var base_speed: float
@export var base_damage: float
@export var attack_cooldown: float
@export var armor_type: int
@export var xp_value: int
@export var enemy_type: int

var hp: float
var _attack_timer: float
var _is_attacking: bool
var _tower_ref: Node      # set by WaveManager on spawn

func _ready() -> void
    # Scale stats via WaveManager current wave scaling.

func _physics_process(delta: float) -> void
    # If not attacking: move toward tower + apply separation.
    # If attacking: tick attack timer, fire on expire.

func take_damage(amount: float, damage_type: int) -> void
    # CombatUtils.calculate_damage() → subtract → update HP bar → die() if <= 0.

func die() -> void
    # Play death anim → emit EventBus.enemy_died → release to pool.

func _apply_separation(delta: float) -> Vector2
func _move_toward_tower(delta: float) -> void

func _on_attack_zone_body_entered(body: Node) -> void
func _on_hit_area_body_entered(body: Node) -> void
    # Called by projectile Area2D — projectile calls take_damage directly, this is backup.
```

**Subclass scenes** override `@export` stats and optionally movement behavior:
- `EnemyGrunt.tscn` — default stats, Medium armor
- `EnemyRunner.tscn` — high speed, Light armor, zigzag override
- `EnemyBrute.tscn` — high HP, Heavy armor, applies slow on tower hit
- `EnemyFlyer.tscn` — straight line movement, no separation, Medium armor
- `EnemyElite.tscn` — random armor each wave, has a special ability (e.g. shield that must be broken)
- `EnemyBoss.tscn` — multi-phase, Chaos armor, triggers phase changes at HP thresholds

---

## 7. Spell / Projectile Scenes

### `ProjectileBase.tscn`
**Root**: Area2D
**Children**:
- `Sprite2D` — projectile art
- `CollisionShape2D` — small circle
- `VisibleOnScreenNotifier2D` — returns to pool if off-screen

**Script** `ProjectileBase.gd`:
```gdscript
var damage: float
var damage_type: int
var speed: float = 700.0
var pierce_count: int = 0       # 0 = no pierce, 1+ = passes through N enemies
var _direction: Vector2
var _hits: int = 0

func initialize(target: Node, spell: SpellData) -> void
    # Set damage, type, rotate toward target, set direction.

func _physics_process(delta: float) -> void
    # Move in _direction * speed.

func _on_body_entered(body: Node) -> void
    # Call body.take_damage(damage, damage_type).
    # Increment _hits. If _hits > pierce_count: release to pool.

func _on_screen_exited() -> void
    # Release to pool.
```

---

### `AoEZone.tscn`
**Root**: Area2D
**Children**:
- `GPUParticles2D` — burst visual
- `CollisionShape2D` — circle, radius set at runtime

**Script** `AoEZone.gd`:
```gdscript
func initialize(pos: Vector2, radius: float, spell: SpellData) -> void
func _apply_damage() -> void
    # get_overlapping_bodies() → filter enemies → call take_damage on each.
    # Then release to pool.
```

---

### `PersistentZone.tscn`
**Root**: Area2D
**Children**:
- `Sprite2D` or `GPUParticles2D` — looping visual
- `CollisionShape2D`
- `TickTimer` (Timer) — 0.5 sec interval

**Script** `PersistentZone.gd`:
```gdscript
var damage: float
var damage_type: int
var duration: float

func initialize(pos: Vector2, radius: float, spell: SpellData) -> void
func _on_tick_timer_timeout() -> void
    # Damage all overlapping enemies.
func _on_duration_expired() -> void
    # Release to pool.
```

---

### `LandMine.tscn`
**Root**: Area2D
**Children**:
- `Sprite2D` — mine sprite
- `CollisionShape2D` — trigger radius

**Script** `LandMine.gd`:
```gdscript
var damage: float
var damage_type: int
var aoe_radius: float

func _on_body_entered(body: Node) -> void
    # Spawn AoEZone at position → queue_free self.
```

---

## 8. UI Scenes

### `HUD.tscn`
**Root**: CanvasLayer
**Children**:
- `TopBar` (HBoxContainer)
  - `WaveLabel` (Label) — "Wave 7 / 20"
  - `XPBar` (ProgressBar) — shows current run XP
  - `LevelLabel` (Label) — "Lv.4"
- `HPBarContainer` (VBoxContainer, anchored left)
  - `HPBarBG` + `HPBarFill` (TextureProgressBar)
  - `HPLabel` (Label) — "1450 / 2000"
- `TagRow` (instance of TagRowWidget.tscn, anchored right)

**Script** `HUD.gd`:
```gdscript
func _ready() -> void
    # Connect GameState signals.
func _on_hp_changed(hp, max_hp) -> void
    # Tween HP bar fill.
func _on_xp_bar_updated(current, needed) -> void
    # Tween XP bar fill.
func _on_tag_count_changed(tag, count) -> void
    # Update TagRow.
func _on_phase_changed(phase) -> void
    # Show/hide elements based on phase.
```

---

### `TagRowWidget.tscn`
**Root**: HBoxContainer
**Children**: dynamically instanced tag icons (TextureRect + Label per active tag)

**Script** `TagRowWidget.gd`:
```gdscript
func update_tag(tag: int, count: int) -> void
    # Add icon if new. Update count label.
    # Pulse icon if count == threshold - 1 (one away from reward).
func highlight_tag(tag: int) -> void
    # Brief glow tween when synergy fires.
```

---

### `DraftUI.tscn`
**Root**: CanvasLayer (hidden by default)
**Children**:
- `DimBG` (ColorRect) — semi-transparent black
- `TitleLabel` (Label) — "Choose an Upgrade"
- `CardContainer` (HBoxContainer) — holds 3 DraftCard instances
- `WaveLabel` (Label) — "Wave 7 complete" or "Level Up!"

**Script** `DraftUI.gd`:
```gdscript
func open(cards: Array[Resource], trigger: String) -> void
    # Populate 3 DraftCard children. Show panel.
func _on_card_selected(card: Resource) -> void
    # Call DraftManager.select_card(). Close panel.
```

---

### `DraftCard.tscn`
**Root**: PanelContainer
**Children**:
- `RarityBorder` (ColorRect or TextureRect) — tinted by rarity
- `CardIcon` (TextureRect) — 64×64 spell icon or stat icon
- `CardName` (Label)
- `TagRow` (HBoxContainer) — small tag chips
- `Description` (Label)
- `SynergyHint` (Label, hidden unless card completes a threshold) — "Completes [Fire]×3!"

**Script** `DraftCard.gd`:
```gdscript
signal card_selected(card_data: Resource)

func setup(data: Resource) -> void
    # Populate from SpellData or StatUpgradeData.
    # Check if card would complete a synergy threshold → show SynergyHint.

func _on_pressed() -> void
    # Emit card_selected. Tween scale down briefly.
```

---

### `SynergyBanner.tscn`
**Root**: CanvasLayer (hidden by default)
**Children**:
- `BannerPanel` (PanelContainer, center screen)
  - `TagIcon` (TextureRect)
  - `BannerLabel` (Label) — "[Fire]×3 — All Fire spells +25% damage!"

**Script** `SynergyBanner.gd`:
```gdscript
func show_synergy(tag: int, level: int) -> void
    # Set icon and label text. Tween slide-in → hold 1.5s → slide-out.
```

---

## 9. Resources

### `SpellData.gd`
```gdscript
class_name SpellData
extends Resource

@export var spell_id: String
@export var spell_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: int               # CardRarity enum
@export var spell_category: int       # SpellCategory enum
@export var damage_type: int          # DamageType enum
@export var tags: Array[int]          # SynergyTag enum values
@export var damage: float
@export var cooldown: float
@export var range: float
@export var aoe_radius: float = 0.0
@export var pierce_count: int = 0
@export var chain_count: int = 0
@export var projectile_scene: PackedScene
@export var is_stackable: bool = false
@export var stack_max: int = 1
```

---

### `StatUpgradeData.gd`
```gdscript
class_name StatUpgradeData
extends Resource

@export var upgrade_id: String
@export var upgrade_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: int
@export var tags: Array[int]

# Stat deltas (applied to GameState on pick)
@export var hp_bonus: int = 0
@export var regen_bonus: float = 0.0
@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var range_bonus: float = 0.0
@export var armor_bonus: int = 0
@export var xp_multiplier: float = 1.0
@export var is_reroll: bool = false
```

---

### `TowerData.gd`
```gdscript
class_name TowerData
extends Resource

@export var tower_id: int             # TowerID enum
@export var tower_name: String
@export var description: String
@export var icon: Texture2D
@export var tower_scene: PackedScene

# Base stats (Star 1)
@export var base_hp: int
@export var base_damage: float
@export var base_fire_rate: float     # seconds between shots
@export var base_range: float
@export var base_armor: int
@export var base_attack_type: int     # DamageType enum

# Star bonuses (index 0 = Star 2, index 4 = Star 5)
@export var star_hp_bonus: Array[int]
@export var star_damage_bonus: Array[float]

# Passive descriptions (for UI display)
@export var passive_description: String
@export var passive_star3_description: String
@export var passive_star5_description: String
```

---

### `WaveConfig.gd`
```gdscript
class_name WaveConfig
extends Resource

@export var wave_number: int
@export var burst_count: int
@export var trickle_interval: float
@export var enemy_pool: Array[int]    # EnemyType values and their weights
@export var is_boss_wave: bool = false
```

---

### `ChapterConfig.gd`
```gdscript
class_name ChapterConfig
extends Resource

@export var chapter_id: int
@export var chapter_name: String
@export var modifier_description: String
@export var background_scene: PackedScene
@export var music_track: AudioStream
@export var waves: Array[WaveConfig]
@export var material_type: int        # MaterialType — which mat drops here
@export var chapter_mat_drop_range: Vector2i   # min/max on victory
```

---

## 10. Utility Scripts

### `CombatUtils.gd`
```gdscript
class_name CombatUtils

const DAMAGE_TABLE: Dictionary = {
    DamageType.NORMAL:   {ArmorType.UNARMORED:1.0, ArmorType.LIGHT:1.5, ArmorType.MEDIUM:2.0, ArmorType.HEAVY:0.7},
    DamageType.PIERCING: {ArmorType.UNARMORED:2.0, ArmorType.LIGHT:1.5, ArmorType.MEDIUM:0.5, ArmorType.HEAVY:0.35},
    DamageType.MAGIC:    {ArmorType.UNARMORED:1.0, ArmorType.LIGHT:1.0, ArmorType.MEDIUM:1.25,ArmorType.HEAVY:0.35},
    DamageType.SIEGE:    {ArmorType.UNARMORED:0.5, ArmorType.LIGHT:0.5, ArmorType.MEDIUM:0.5, ArmorType.HEAVY:2.0},
    DamageType.CHAOS:    {ArmorType.UNARMORED:1.0, ArmorType.LIGHT:1.0, ArmorType.MEDIUM:1.0, ArmorType.HEAVY:1.0},
}

static func calculate_damage(base: float, dtype: int, atype: int) -> float
static func get_damage_color(dtype: int) -> Color
static func calculate_wave_hp_scale(wave: int) -> float
static func calculate_wave_dmg_scale(wave: int) -> float
```

### `SaveData.gd`
```gdscript
class_name SaveData
extends Resource

@export var owned_towers: Array[int]
@export var tower_stars: Dictionary
@export var spell_ranks: Dictionary
@export var discovered_spells: Array[String]
@export var materials: Dictionary
@export var energy: int
@export var energy_last_regen_time: int    # Unix timestamp
@export var premium_currency: int
@export var selected_tower_id: int
@export var chapters_completed: Array[int]
@export var best_wave_per_chapter: Dictionary
```

---

## 11. Godot Project Settings

| Setting | Value |
|---------|-------|
| Renderer | Compatibility (OpenGL ES 3.0) |
| Window Width | 1080 |
| Window Height | 1920 |
| Stretch Mode | `canvas_items` |
| Stretch Aspect | `keep` |
| 2D Physics Gravity | 0 |
| Pixel Snap | On (if pixel art style) |
| Main Scene | `res://scenes/main/WorldMap.tscn` |

**Autoload order**:
1. Constants
2. EventBus
3. GameState
4. MetaManager
5. SpellRegistry
6. WaveManager
7. DraftManager
8. ObjectPool
9. AudioManager
