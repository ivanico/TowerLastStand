# Epic 01 — Foundation

> Goal: A running Godot project with an arena, a static tower placeholder, one enemy that walks toward it, and a wave timer counting down.
> No combat yet. No art. Colored rectangles and circles only.
> Completed epic delivers: Claude Code can run the project and see an enemy moving toward a tower.

---

## Task 01-01 — Create Godot Project

- [ ] Create a new Godot 4 project named `TowerLastStand`.
- [ ] Set display resolution: Width = 1080, Height = 1920.
- [ ] Set Stretch Mode to `canvas_items`, Stretch Aspect to `keep`.
- [ ] Set renderer to Compatibility (Project > Rendering > Renderer).
- [ ] Set 2D default gravity to 0 (Project > Physics > 2D > Default Gravity).
- [ ] Create the full folder structure as listed in `components.md` Section 1.
- [ ] Set the main scene to `res://scenes/main/GameWorld.tscn` (create it empty for now).

---

## Task 01-02 — Constants Script

**File**: `res://scripts/Constants.gd`
**Ref**: `components.md` Section 2

- [ ] Create `Constants.gd` as a static script with `class_name Constants`.
- [ ] Add all enums: `GamePhase`, `DamageType`, `ArmorType`, `SpellCategory`, `EnemyType`, `TargetMode`, `CardRarity`, `SynergyTag`, `TowerID`, `MaterialType`.
- [ ] Add all const values: `WAVE_DURATION_MAX`, `TOTAL_WAVES`, `DRAFT_CARDS_SHOWN`, `ENEMY_HP_SCALE`, `ENEMY_DMG_SCALE`, `XP_PER_KILL_BASE`, `XP_PER_LEVEL_BASE`, `MAX_SPELL_SLOTS`, `MAX_MINES`, `SYNERGY_THRESHOLD_LOW`, `SYNERGY_THRESHOLD_HIGH`, `TOWER_MAX_STARS`, `SPELL_MAX_RANK`, `MAX_ENERGY`.
- [ ] Add `Constants` as the first Autoload in Project Settings > Autoload.

---

## Task 01-03 — EventBus Autoload

**File**: `res://autoloads/EventBus.gd`
**Ref**: `components.md` Section 3

- [ ] Create `EventBus.gd` as a Node script.
- [ ] Declare all signals listed in `components.md` EventBus section:
  - Combat group: `enemy_died`, `enemy_reached_tower`, `tower_damaged`, `tower_healed`, `tower_died`.
  - XP group: `xp_gained`, `level_up`.
  - Wave group: `wave_started`, `wave_cleared`, `phase_changed`, `boss_spawned`, `boss_died`.
  - Draft group: `draft_opened`, `draft_closed`, `card_selected`.
  - Synergy group: `synergy_threshold_reached`.
  - Meta group: `run_ended`, `materials_earned`, `tower_upgraded`, `spell_ranked_up`.
- [ ] Add `EventBus` as Autoload (order 2).

---

## Task 01-04 — GameState Autoload

**File**: `res://autoloads/GameState.gd`
**Ref**: `components.md` Section 3

- [ ] Create `GameState.gd` as a Node script.
- [ ] Declare all variables: `phase`, `wave_number`, `run_level`, `run_xp`, `run_xp_to_next`, `tower_hp`, `tower_max_hp`, `tower_regen_per_sec`, `tower_damage_multiplier`, `tower_fire_rate_multiplier`, `tower_range_bonus`, `tower_armor`, `active_spells`, `tag_counts`, `active_synergies`, `total_kills`, `waves_cleared`, `damage_dealt`.
- [ ] Declare all signals: `hp_changed`, `xp_bar_updated`, `tag_count_changed`.
- [ ] Implement `start_run(tower_data)`: set phase to WAVE, reset all counters, set HP from tower_data, emit `phase_changed`.
- [ ] Implement `gain_xp(amount)`: add to `run_xp`, check if `run_xp >= run_xp_to_next`, if so increment `run_level`, reset xp, open draft. Emit `xp_bar_updated`.
- [ ] Implement `take_damage(amount)`: subtract from `tower_hp` (floor at 0), emit `hp_changed`, if 0 emit `EventBus.tower_died`.
- [ ] Implement `heal(amount)`: add to `tower_hp` (cap at `tower_max_hp`), emit `hp_changed`, emit `EventBus.tower_healed`.
- [ ] Implement `add_tag(tag)`: increment `tag_counts[tag]`, emit `tag_count_changed`, check if count == 3 or 5, if so add to `active_synergies` and emit `EventBus.synergy_threshold_reached`.
- [ ] Implement `apply_card(card)`: stub only for now (full implementation in Epic 03).
- [ ] Implement `end_run(victory)`: set phase to VICTORY or DEFEAT, emit `EventBus.run_ended`.
- [ ] Implement `reset()`: set all variables back to defaults.
- [ ] Add `GameState` as Autoload (order 3).

---

## Task 01-05 — MetaManager Autoload (Stub)

**File**: `res://autoloads/MetaManager.gd`
**Ref**: `components.md` Section 3

- [ ] Create `MetaManager.gd` as a Node script.
- [ ] Declare all variables: `owned_towers`, `tower_stars`, `spell_ranks`, `discovered_spells`, `materials`, `energy`, `premium_currency`, `selected_tower_id`.
- [ ] Implement `save()` and `load()` as stubs (print "save/load called" for now — full implementation in Epic 05).
- [ ] Implement `spend_energy() -> bool`: if `energy > 0`, decrement and return true. Else return false.
- [ ] Implement `restore_energy(amount)`: add to `energy`, cap at `Constants.MAX_ENERGY`.
- [ ] Set defaults: `energy = 5`, `selected_tower_id = TowerID.IRONCLAD`, `owned_towers = [TowerID.IRONCLAD]`.
- [ ] Add `MetaManager` as Autoload (order 4).

---

## Task 01-06 — SpellRegistry Autoload (Stub)

**File**: `res://autoloads/SpellRegistry.gd`
**Ref**: `components.md` Section 3

- [ ] Create `SpellRegistry.gd` as a Node script.
- [ ] Declare `all_spells: Array` and `all_stat_upgrades: Array`.
- [ ] Implement `_ready()` as stub (arrays stay empty until Epic 03 creates resource files).
- [ ] Implement `get_all_cards() -> Array`: return `all_spells + all_stat_upgrades`.
- [ ] Add `SpellRegistry` as Autoload (order 5).

---

## Task 01-07 — WaveManager Autoload (Stub)

**File**: `res://autoloads/WaveManager.gd`
**Ref**: `components.md` Section 3

- [ ] Create `WaveManager.gd` as a Node script.
- [ ] Declare `_active_enemies: Array`, `_trickle_timer: Timer`, `_enemy_container: Node`.
- [ ] Implement `start_wave(wave_number)`:
  - Clear `_active_enemies`.
  - Spawn 5 Grunt enemies at random perimeter positions (hardcode `EnemyGrunt.tscn` for now).
  - Start `_trickle_timer` to spawn 1 enemy every 3 seconds.
  - Emit `EventBus.wave_started(wave_number)`.
- [ ] Implement `stop_wave()`: stop `_trickle_timer`, call `clear_all_enemies()`.
- [ ] Implement `clear_all_enemies()`: iterate `_active_enemies`, call `queue_free()` on each, clear array.
- [ ] Implement `_get_spawn_position() -> Vector2`: return a random point on a rectangle perimeter 900px wide × 1600px tall centered on `Vector2(540, 960)`.
- [ ] Implement `_on_enemy_died(enemy, position)`: remove from `_active_enemies`. If array is empty, emit `EventBus.wave_cleared(GameState.wave_number)`.
- [ ] Connect to `EventBus.enemy_died` in `_ready()`.
- [ ] Add `WaveManager` as Autoload (order 6).

---

## Task 01-08 — DraftManager Autoload (Stub)

**File**: `res://autoloads/DraftManager.gd`
**Ref**: `components.md` Section 3

- [ ] Create `DraftManager.gd` as a Node script.
- [ ] Declare `_card_pool: Array`, `_taken_cards: Array`.
- [ ] Implement `open_draft()`: stub — emit `EventBus.draft_opened` (full implementation in Epic 03).
- [ ] Implement `select_card(card)`: stub — emit `EventBus.draft_closed`.
- [ ] Add `DraftManager` as Autoload (order 7).

---

## Task 01-09 — ObjectPool Autoload (Stub)

**File**: `res://autoloads/ObjectPool.gd`
**Ref**: `components.md` Section 3

- [ ] Create `ObjectPool.gd` as a Node script.
- [ ] Declare `_pools: Dictionary`.
- [ ] Implement `get(scene: PackedScene) -> Node`: check `_pools[scene.resource_path]` for an available node. If none, instantiate one. Add to scene tree under a hidden `_pool_root` Node2D. Return node.
- [ ] Implement `release(node: Node)`: hide node, disable its collision shapes, return to pool array.
- [ ] Implement `preload_pool(scene: PackedScene, count: int)`: instantiate `count` nodes and add to pool immediately.
- [ ] Add `ObjectPool` as Autoload (order 8).

---

## Task 01-10 — AudioManager Autoload (Stub)

**File**: `res://autoloads/AudioManager.gd`
**Ref**: `components.md` Section 3

- [ ] Create `AudioManager.gd` as a Node script.
- [ ] Declare `_sfx_pool: Array`, `_music_player: AudioStreamPlayer`.
- [ ] In `_ready()`: create 12 `AudioStreamPlayer` nodes, add as children, push to `_sfx_pool`. Create `_music_player` as a child.
- [ ] Implement `play_sfx(stream, volume_db)`: find an idle player from pool, set its stream, play. If none idle, use oldest.
- [ ] Implement `play_music(stream, crossfade)`: stub for now — just set `_music_player.stream = stream` and play.
- [ ] Implement `stop_music()`: `_music_player.stop()`.
- [ ] Add `AudioManager` as Autoload (order 9).

---

## Task 01-11 — CombatUtils Script

**File**: `res://scripts/CombatUtils.gd`
**Ref**: `components.md` Section 10

- [ ] Create `CombatUtils.gd` with `class_name CombatUtils`.
- [ ] Add the full `DAMAGE_TABLE` dictionary as a const (all 5 damage types × 4 armor types).
- [ ] Implement `static func calculate_damage(base: float, dtype: int, atype: int) -> float`: look up multiplier, return `base * multiplier`.
- [ ] Implement `static func get_damage_color(dtype: int) -> Color`: return White for Normal, Yellow for Piercing, Red for Magic, Grey for Siege, Purple for Chaos.
- [ ] Implement `static func calculate_wave_hp_scale(wave: int) -> float`: return `pow(Constants.ENEMY_HP_SCALE, wave - 1)`.
- [ ] Implement `static func calculate_wave_dmg_scale(wave: int) -> float`: return `pow(Constants.ENEMY_DMG_SCALE, wave - 1)`.

---

## Task 01-12 — SpellData Resource Class

**File**: `res://resources/spells/SpellData.gd`
**Ref**: `components.md` Section 9

- [ ] Create `SpellData.gd` extending `Resource` with `class_name SpellData`.
- [ ] Add all `@export` fields: `spell_id`, `spell_name`, `description`, `icon`, `rarity`, `spell_category`, `damage_type`, `tags`, `damage`, `cooldown`, `range`, `aoe_radius`, `pierce_count`, `chain_count`, `projectile_scene`, `is_stackable`, `stack_max`.

---

## Task 01-13 — StatUpgradeData Resource Class

**File**: `res://resources/spells/StatUpgradeData.gd`
**Ref**: `components.md` Section 9

- [ ] Create `StatUpgradeData.gd` extending `Resource` with `class_name StatUpgradeData`.
- [ ] Add all `@export` fields: `upgrade_id`, `upgrade_name`, `description`, `icon`, `rarity`, `tags`, `hp_bonus`, `regen_bonus`, `damage_multiplier`, `fire_rate_multiplier`, `range_bonus`, `armor_bonus`, `xp_multiplier`, `is_reroll`.

---

## Task 01-14 — TowerData Resource Class

**File**: `res://resources/towers/TowerData.gd`
**Ref**: `components.md` Section 9

- [ ] Create `TowerData.gd` extending `Resource` with `class_name TowerData`.
- [ ] Add all `@export` fields: `tower_id`, `tower_name`, `description`, `icon`, `tower_scene`, `base_hp`, `base_damage`, `base_fire_rate`, `base_range`, `base_armor`, `base_attack_type`, `star_hp_bonus`, `star_damage_bonus`, `passive_description`, `passive_star3_description`, `passive_star5_description`.

---

## Task 01-15 — EnemyBase Scene & Script

**File**: `res://scenes/enemies/EnemyBase.tscn`
**Ref**: `components.md` Section 6, `mechanics.md` Section 3

- [ ] Create `EnemyBase.tscn` with root `CharacterBody2D`.
- [ ] Add children:
  - `Sprite2D` — 64×64 red ColorRect placeholder (use a solid-color texture generated in code).
  - `CollisionShape2D` — CapsuleShape2D, height 60, radius 20.
  - `HitArea` (Area2D) with its own `CollisionShape2D` (CircleShape2D radius 35).
  - `AttackZone` (Area2D) with `CollisionShape2D` (CircleShape2D radius 55).
  - `HPBar` (ProgressBar) — anchored above sprite, width 60, height 8, hidden by default.
- [ ] Create `EnemyBase.gd` script:
  - `@export` vars: `base_hp = 200.0`, `base_speed = 60.0`, `base_damage = 25.0`, `attack_cooldown = 1.0`, `armor_type = ArmorType.MEDIUM`, `xp_value = 10`, `enemy_type = EnemyType.GRUNT`.
  - Runtime vars: `hp`, `_attack_timer`, `_is_attacking`, `_tower_ref`.
  - `_ready()`: set `hp = base_hp`. Apply wave scaling via `CombatUtils.calculate_wave_hp_scale(GameState.wave_number)`.
  - `_physics_process(delta)`: if not attacking — call `_move_toward_tower(delta)`. If attacking — tick `_attack_timer`, deal damage on expire.
  - `_move_toward_tower(delta)`: calculate direction to `Vector2(540, 960)`, add `_apply_separation(delta)`, set velocity, call `move_and_slide()`.
  - `_apply_separation(delta) -> Vector2`: get nearby CharacterBody2D nodes within 40px (use overlap test or manual distance check on `_active_enemies` from WaveManager), push away.
  - `take_damage(amount, damage_type)`: call `CombatUtils.calculate_damage()`, subtract from `hp`, show HPBar, update fill. If `hp <= 0` call `die()`.
  - `die()`: emit `EventBus.enemy_died(self, global_position)`, emit `EventBus.xp_gained(xp_value)`, call `queue_free()` (pool in Epic 02).
  - `_on_attack_zone_body_entered(body)`: if body is in group `"tower"` — set `_is_attacking = true`, stop movement.

---

## Task 01-16 — EnemyGrunt Scene

**File**: `res://scenes/enemies/EnemyGrunt.tscn`

- [ ] Inherit from `EnemyBase.tscn`.
- [ ] Override no stats (Grunt uses base defaults).
- [ ] Add to group `"enemies"`.
- [ ] Assign a distinct red color to its Sprite2D placeholder.

---

## Task 01-17 — TowerBase Scene & Script (Placeholder)

**File**: `res://scenes/tower/TowerBase.tscn`
**Ref**: `components.md` Section 5, `mechanics.md` Section 2

- [ ] Create `TowerBase.tscn` with root `Area2D`.
- [ ] Add to group `"tower"`.
- [ ] Add children:
  - `Sprite2D` — 128×128 blue ColorRect placeholder.
  - `CollisionShape2D` — CircleShape2D radius 50.
  - `AttackRangeArea` (Area2D + CircleShape2D radius 400) — for tracking enemies in range.
  - `RangeIndicator` (Node2D) — empty for now, draws range circle in `_draw()`.
  - `RegenTimer` (Timer) — wait_time = 1.0, autostart = false.
- [ ] Create `TowerBase.gd` script:
  - Vars: `active_spells: Array`, `_spell_cooldowns: Dictionary`, `_enemies_in_range: Array`.
  - `_ready()`: connect `RegenTimer.timeout` to `_on_regen_timer_timeout`. Connect `AttackRangeArea.body_entered` and `body_exited`.
  - `_physics_process(delta)`: iterate `active_spells`, tick cooldowns, call `_fire_spell(spell)` when cooldown reaches 0 and reset.
  - `take_damage(amount)`: call `GameState.take_damage(amount)`.
  - `add_spell(spell)`: append to `active_spells`, set `_spell_cooldowns[spell.spell_id] = 0.0`.
  - `_get_target(range, mode)`: iterate `_enemies_in_range`, filter by distance <= range, return closest (CLOSEST mode only for now).
  - `_fire_spell(spell)`: stub — print "fire [spell_name]" (full wiring in Epic 02).
  - `_on_attack_range_body_entered(body)`: if body in group `"enemies"`, append to `_enemies_in_range`.
  - `_on_attack_range_body_exited(body)`: remove from `_enemies_in_range`.
  - `_on_regen_timer_timeout()`: call `GameState.heal(GameState.tower_regen_per_sec)`.

---

## Task 01-18 — TowerIronclad Scene (Placeholder)

**File**: `res://scenes/tower/TowerIronclad.tscn`

- [ ] Inherit from `TowerBase.tscn`.
- [ ] Override Sprite2D color to dark blue/grey.
- [ ] Create `TowerIronclad.gd` extending `TowerBase.gd` — empty for now (passive implemented in Epic 02).

---

## Task 01-19 — GameWorld Scene & Script

**File**: `res://scenes/main/GameWorld.tscn`
**Ref**: `components.md` Section 4

- [ ] Create `GameWorld.tscn` with root `Node2D`.
- [ ] Add children:
  - `Background` (ColorRect) — fills 1080×1920, dark green color.
  - `TowerNode` (instance of `TowerIronclad.tscn`) — position `Vector2(540, 960)`.
  - `EnemyContainer` (Node2D).
  - `ProjectileContainer` (Node2D).
  - `ZoneContainer` (Node2D).
  - `MineContainer` (Node2D).
  - `VFXContainer` (Node2D).
  - `HUD` (CanvasLayer) — empty Label children for now: `WaveLabel`, `HPLabel`, `XPLabel`.
- [ ] Create `GameWorld.gd`:
  - `_ready()`:
    - Give `WaveManager` a reference to `EnemyContainer` (set `WaveManager._enemy_container`).
    - Call `GameState.start_run(null)` (null tower_data until Epic 05).
    - Call `WaveManager.start_wave(1)`.
    - Connect `EventBus.wave_cleared` to `_on_wave_cleared`.
    - Connect `EventBus.phase_changed` to `_on_phase_changed`.
    - Connect `EventBus.tower_died` to `_on_tower_died`.
  - `_on_wave_cleared(wave_number)`:
    - Increment `GameState.wave_number`.
    - Update `WaveLabel` text.
    - Call `DraftManager.open_draft()` (stub for now — just starts next wave immediately).
  - `_on_phase_changed(phase)`: stub.
  - `_on_tower_died()`: print "GAME OVER" for now.
  - `_process(delta)`:
    - Update `HPLabel` text to show `GameState.tower_hp`.
    - Update `WaveLabel` text to show wave number.

---

## Task 01-20 — Integration Test

- [ ] Run the project.
- [ ] Verify: 5 red squares spawn at the arena edges and walk toward the blue square tower at center.
- [ ] Verify: enemies do not overlap perfectly (separation steering working).
- [ ] Verify: when all 5 enemies reach the tower, `enemy_reached_tower` signal fires (check Output panel).
- [ ] Verify: after ~30 seconds, WaveManager spawns another trickle enemy.
- [ ] Verify: HP label and Wave label are visible on screen.
- [ ] Fix any errors before moving to Epic 02.
