# Epic 04 — Waves, Enemy Variety & Boss

> Prerequisite: Epic 03 complete and tested.
> Goal: All 6 enemy types implemented. Wave scaling applied. Chapter config drives enemy pools per wave. Boss spawns on wave 20 with two HP phases. Win/lose screens functional.
> Completed epic delivers: a complete run from wave 1 to wave 20, with escalating difficulty, a boss fight, and proper victory/defeat screens.

---

## Task 04-01 — WaveConfig & ChapterConfig Resource Files

**Folder**: `res://resources/waves/`
**Ref**: `components.md` Section 9, `mechanics.md` Section 7

- [ ] Implement `WaveConfig.gd` (if not already done in Epic 01 — replace stub):
  ```gdscript
  class_name WaveConfig
  extends Resource

  @export var wave_number: int
  @export var burst_count: int          # enemies spawned instantly at wave start
  @export var trickle_count: int        # total enemies that trickle in
  @export var trickle_interval: float   # seconds between trickle spawns
  @export var enemy_pool: Array[int]    # EnemyType values — one entry per enemy in burst+trickle
  @export var is_boss_wave: bool = false
  ```
- [ ] Implement `ChapterConfig.gd`:
  ```gdscript
  class_name ChapterConfig
  extends Resource

  @export var chapter_id: int
  @export var chapter_name: String
  @export var modifier_description: String
  @export var background_scene: PackedScene
  @export var music_track: AudioStream
  @export var waves: Array[WaveConfig]
  @export var material_type: int
  @export var chapter_mat_drop_range: Vector2i
  ```
- [ ] Create `chapter_01.tres`: 20 WaveConfig entries. Guidelines:
  - Waves 1–4: burst=5, trickle=3, interval=4.0, pool = GRUNT only.
  - Waves 5–9: burst=6, trickle=4, interval=3.5, pool = GRUNT×3 + RUNNER×1.
  - Waves 10–14: burst=7, trickle=4, interval=3.0, pool = GRUNT×2 + RUNNER×2 + BRUTE×1.
  - Waves 15–19: burst=8, trickle=5, interval=2.5, pool = GRUNT×2 + RUNNER×2 + BRUTE×1 + FLYER×1.
  - Wave 20: `is_boss_wave=true`, burst=0, trickle=0 (boss handled separately).

---

## Task 04-02 — WaveManager Full Implementation

**File**: `res://autoloads/WaveManager.gd`
**Ref**: `components.md` Section 3, `mechanics.md` Section 3

Replace the Epic 01 stub with the full implementation:

- [ ] Add vars:
  ```gdscript
  var _active_enemies: Array[Node]
  var _trickle_timer: Timer
  var _enemy_container: Node
  var _tower_ref: Node
  var _current_wave_config: WaveConfig
  var _chapter_config: ChapterConfig
  var _trickle_remaining: int
  var _wave_number: int
  ```
- [ ] In `_ready()`: create `_trickle_timer` as a child Timer. Connect its `timeout` to `_on_trickle_timer_timeout`. Connect `EventBus.enemy_died` to `_on_enemy_died`.
- [ ] Implement `setup(enemy_container: Node, tower: Node, chapter: ChapterConfig)`:
  - Set `_enemy_container = enemy_container`, `_tower_ref = tower`, `_chapter_config = chapter`.
- [ ] Implement `start_wave(wave_number: int)`:
  - Set `_wave_number = wave_number`.
  - Load `_current_wave_config = _chapter_config.waves[wave_number - 1]`.
  - Clear `_active_enemies`.
  - If `_current_wave_config.is_boss_wave`: call `_spawn_boss()`. Emit `EventBus.wave_started(wave_number)`. Return.
  - Call `_spawn_burst()` with `_current_wave_config.burst_count`.
  - Set `_trickle_remaining = _current_wave_config.trickle_count`.
  - Start `_trickle_timer` with `_current_wave_config.trickle_interval`.
  - Emit `EventBus.wave_started(wave_number)`.
- [ ] Implement `_spawn_burst()`:
  - Pick `burst_count` enemies randomly from `_current_wave_config.enemy_pool`.
  - Call `_spawn_enemy(type)` for each. Add staggered 0.1-second delays between spawns to prevent overlap.
- [ ] Implement `_on_trickle_timer_timeout()`:
  - If `_trickle_remaining <= 0`: stop timer. Return.
  - Pick one enemy type from `_current_wave_config.enemy_pool` at random.
  - Call `_spawn_enemy(type)`.
  - Decrement `_trickle_remaining`.
- [ ] Implement `_spawn_enemy(type: int) -> Node`:
  - Select the correct scene based on `type` (use a match statement with preloaded scenes).
  - Get from pool: `var enemy = ObjectPool.get(scene)`.
  - Call `enemy.reset()`.
  - Set `enemy.global_position = _get_spawn_position()`.
  - Set `enemy._tower_ref = _tower_ref`.
  - Call `_apply_wave_scaling(enemy, _wave_number)`.
  - Add to `_enemy_container` if not in scene tree.
  - Append to `_active_enemies`.
  - Return `enemy`.
- [ ] Implement `_apply_wave_scaling(enemy: Node, wave: int)`:
  - `enemy.base_hp *= CombatUtils.calculate_wave_hp_scale(wave)`.
  - `enemy.hp = enemy.base_hp`.
  - `enemy.base_damage *= CombatUtils.calculate_wave_dmg_scale(wave)`.
- [ ] Implement `_get_spawn_position() -> Vector2`:
  - Randomly pick one of 4 edges (top, bottom, left, right).
  - Return a random point on that edge with 60px inset from screen bounds (1080×1920).
  - Clamp so enemy never spawns inside the tower's 200px center zone.
- [ ] Implement `_on_enemy_died(enemy: Node, _pos: Vector2)`:
  - Remove from `_active_enemies` (use `erase()`).
  - If `_active_enemies.is_empty()` and `_trickle_remaining <= 0`: emit `EventBus.wave_cleared(GameState.wave_number)`.
- [ ] Implement `stop_wave()`: stop `_trickle_timer`. Set `_trickle_remaining = 0`.
- [ ] Implement `clear_all_enemies()`:
  - For each enemy in `_active_enemies`: call `ObjectPool.release(enemy)`.
  - Clear `_active_enemies`.
- [ ] Preload all 5 enemy scenes as constants at top of script.

---

## Task 04-03 — EnemyRunner Scene & Script

**File**: `res://scenes/enemies/EnemyRunner.tscn`
**Ref**: `mechanics.md` Section 3

- [ ] Inherit from `EnemyBase.tscn`.
- [ ] Override sprite: 64×64 yellow placeholder.
- [ ] Create `EnemyRunner.gd` extending `EnemyBase`:
  - Override `@export` defaults: `base_hp = 80.0`, `base_speed = 140.0`, `base_damage = 15.0`, `armor_type = ArmorType.LIGHT`, `xp_value = 8`.
  - Add `_zigzag_timer: float = 0.0` and `_zigzag_direction: float = 1.0`.
  - Override `_move_toward_tower(delta)`:
    - Tick `_zigzag_timer += delta`.
    - Every 0.6 seconds, flip `_zigzag_direction *= -1.0`.
    - Compute base direction toward tower. Add perpendicular offset: `direction += direction.rotated(PI/2) * _zigzag_direction * 0.4`.
    - Normalize, apply speed, call `move_and_slide()`.
- [ ] Add to group `"enemies"`.

---

## Task 04-04 — EnemyBrute Scene & Script

**File**: `res://scenes/enemies/EnemyBrute.tscn`
**Ref**: `mechanics.md` Section 3

- [ ] Inherit from `EnemyBase.tscn`.
- [ ] Override sprite: 128×128 dark grey placeholder.
- [ ] Create `EnemyBrute.gd` extending `EnemyBase`:
  - Override defaults: `base_hp = 800.0`, `base_speed = 35.0`, `base_damage = 60.0`, `armor_type = ArmorType.HEAVY`, `xp_value = 40`.
  - Override `CollisionShape2D` capsule size to height=110, radius=35 to match larger sprite.
  - No special movement. Standard `_move_toward_tower`.
  - Add a `_slow_stack: int = 0` var (for future slow effect from hits — clamp movement speed: `effective_speed = base_speed * max(0.3, 1.0 - _slow_stack * 0.15)`).
- [ ] Add to group `"enemies"`.

---

## Task 04-05 — EnemyFlyer Scene & Script

**File**: `res://scenes/enemies/EnemyFlyer.tscn`
**Ref**: `mechanics.md` Section 3

- [ ] Inherit from `EnemyBase.tscn`.
- [ ] Override sprite: 80×80 cyan/light blue placeholder.
- [ ] Create `EnemyFlyer.gd` extending `EnemyBase`:
  - Override defaults: `base_hp = 150.0`, `base_speed = 90.0`, `base_damage = 20.0`, `armor_type = ArmorType.MEDIUM`, `xp_value = 15`.
  - Override `_move_toward_tower(delta)`:
    - **Flyers ignore separation steering and other enemies.**
    - Compute direction to tower, set velocity directly, call `move_and_slide()`.
    - Flyers do NOT call `_apply_separation()`.
  - Flyers use the same `AttackZone` and attack logic from EnemyBase.
- [ ] Add to group `"enemies"`.

---

## Task 04-06 — EnemyBoss Scene & Script

**File**: `res://scenes/enemies/EnemyBoss.tscn`
**Ref**: `mechanics.md` Section 7

- [ ] Create `EnemyBoss.tscn` with root `CharacterBody2D`. Do NOT inherit EnemyBase (boss has unique logic).
- [ ] Add children:
  - `Sprite2D` — 256×256 dark red/black placeholder.
  - `CollisionShape2D` — CircleShape2D radius 80.
  - `HitArea` (Area2D + CircleShape2D radius 90).
  - `AttackZone` (Area2D + CircleShape2D radius 120).
  - `HPBar` (ProgressBar) — top of screen (full width 900px, height 30) — placed in scene, NOT above sprite.
  - `PhaseLabel` (Label) — shows current phase, hidden by default.
- [ ] Create `EnemyBoss.gd`:
  - Vars: `max_hp = 5000.0`, `hp`, `base_speed = 40.0`, `base_damage = 150.0`, `armor_type = ArmorType.CHAOS` (treat as unarmored for damage calc), `xp_value = 200`.
  - Phase vars: `_phase: int = 1`, `_is_transitioning: bool = false`.
  - Phase thresholds: phase 2 at 66% HP, phase 3 at 33% HP.
  - `_ready()`: set `hp = max_hp`. Apply wave scaling. Update HPBar.
  - `_physics_process(delta)`: move toward tower (no separation). Tick attack timer.
  - `take_damage(amount, damage_type)`:
    - Apply damage table (use CombatUtils, treat as UNARMORED).
    - Subtract from `hp`. Update HPBar (`HPBar.value = (hp / max_hp) * 100`).
    - Check phase thresholds — if `hp <= max_hp * threshold` and `_phase < N` and not `_is_transitioning`: call `_start_phase_transition(N)`.
    - If `hp <= 0` and not `_is_transitioning`: call `die()`.
  - `_start_phase_transition(new_phase: int)`:
    - Set `_is_transitioning = true`.
    - Stop movement (zero velocity).
    - Show `PhaseLabel` with "PHASE 2" or "PHASE 3" text.
    - Create a Tween: brief 0.5s pause, flash sprite white, then resume.
    - On transition complete: set `_phase = new_phase`, set `_is_transitioning = false`.
    - Phase 2 bonus: `base_speed *= 1.3`, `base_damage *= 1.2`.
    - Phase 3 bonus: `base_speed *= 1.5`, base attack cooldown halved.
  - `die()`:
    - Emit `EventBus.enemy_died(self, global_position)`.
    - Emit `EventBus.xp_gained(xp_value)`.
    - Emit `EventBus.boss_died`.
    - Queue_free (boss does NOT use object pool).
- [ ] In `WaveManager._spawn_boss()`:
  - Instance `EnemyBoss.tscn` (not from pool).
  - Set position off-screen top: `Vector2(540, -150)`.
  - Set `_tower_ref`.
  - Add to `_enemy_container`.
  - Append to `_active_enemies`.
  - Emit `EventBus.boss_spawned`.

---

## Task 04-07 — Connect GameWorld to New WaveManager API

**File**: `res://scenes/main/GameWorld.gd`

- [ ] In `_ready()`:
  - Load `chapter_01.tres`: `var chapter = preload("res://resources/waves/chapter_01.tres")`.
  - Call `WaveManager.setup(EnemyContainer, TowerNode, chapter)`.
  - Call `GameState.start_run(null)` (null TowerData until Epic 05).
  - Call `WaveManager.start_wave(1)`.
  - Connect `EventBus.boss_spawned` to `_on_boss_spawned`.
  - Connect `EventBus.boss_died` to `_on_boss_died`.
- [ ] In `_on_wave_cleared(wave_number)`:
  - If `wave_number >= Constants.TOTAL_WAVES`: call `_trigger_victory()`. Return.
  - Else: call `DraftManager.open_draft("wave_clear")`.
- [ ] Implement `_on_boss_spawned()`:
  - Play boss music (AudioManager stub call for now).
  - Update WaveLabel: "BOSS WAVE".
- [ ] Implement `_on_boss_died()`:
  - Call `_trigger_victory()`.
- [ ] Implement `_trigger_victory()`:
  - Call `GameState.end_run(true)`.
  - Transition to `VictoryScreen.tscn` after a 1-second delay.

---

## Task 04-08 — VictoryScreen Scene & Script

**File**: `res://scenes/main/VictoryScreen.tscn`
**Ref**: `mechanics.md` Section 10

- [ ] Create `VictoryScreen.tscn` with root `CanvasLayer`.
- [ ] Add children:
  - `BG` (ColorRect) — full screen, dark blue/gold color.
  - `TitleLabel` (Label) — "VICTORY!", large font, centered.
  - `StatsPanel` (VBoxContainer) — centered:
    - `WavesLabel` (Label) — "Waves Cleared: 20 / 20".
    - `KillsLabel` (Label) — "Enemies Killed: 127".
    - `SynergiesLabel` (Label) — "Synergies Achieved: 3".
    - `MaterialsLabel` (Label) — "Chapter Materials: +12  Universal Materials: +3".
  - `ContinueButton` (Button) — "Return to Map".
- [ ] Create `VictoryScreen.gd`:
  - `_ready()`:
    - Populate labels from `GameState` end-of-run stats.
    - Compute material rewards: `var mats = randi_range(chapter.chapter_mat_drop_range.x, chapter.chapter_mat_drop_range.y)`. Add to MetaManager (stub).
    - Connect `ContinueButton.pressed` to `_on_continue_pressed`.
  - `_on_continue_pressed()`:
    - Call `MetaManager.restore_energy(0)` (no energy restore on victory — player used it).
    - Call `get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")`. Use `WorldMap.tscn` stub if not built yet.

---

## Task 04-09 — DefeatScreen Scene & Script (Replaces Epic 02 stub)

**File**: `res://scenes/main/DefeatScreen.tscn`
**Ref**: `mechanics.md` Section 10

- [ ] Create `DefeatScreen.tscn` with root `CanvasLayer`.
- [ ] Add children:
  - `BG` (ColorRect) — full screen, dark red/black.
  - `TitleLabel` (Label) — "DEFEATED", large font, red.
  - `StatsPanel` (VBoxContainer):
    - `WaveLabel` (Label) — "Reached: Wave 7 / 20".
    - `KillsLabel` (Label) — "Enemies Killed: 43".
    - `MaterialsLabel` (Label) — "Partial Materials: +4" (60% of normal drop on loss).
  - `RetryButton` (Button) — "Try Again".
  - `MapButton` (Button) — "Return to Map".
- [ ] Create `DefeatScreen.gd`:
  - `_ready()`: populate labels. Connect buttons.
  - `_on_retry_pressed()`: call `get_tree().reload_current_scene()`.
  - `_on_map_pressed()`: call `get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")`.
- [ ] In `GameWorld._on_tower_died()`:
  - Replace the print stub with: `GameState.end_run(false)`.
  - Wait 0.5 seconds then call `get_tree().change_scene_to_file("res://scenes/main/DefeatScreen.tscn")`.

---

## Task 04-10 — EnemyElite Scene & Script (Stub for Chapter 3+)

**File**: `res://scenes/enemies/EnemyElite.tscn`

- [ ] Inherit from `EnemyBase.tscn`.
- [ ] Override sprite: 96×96 orange/gold placeholder with an outline.
- [ ] Create `EnemyElite.gd` extending `EnemyBase`:
  - Override defaults: `base_hp = 600.0`, `base_speed = 70.0`, `base_damage = 45.0`, `armor_type = ArmorType.LIGHT`, `xp_value = 60`.
  - Add `_shield_active: bool = false` and `_shield_hp: float = 200.0` vars.
  - Override `take_damage(amount, damage_type)`:
    - If `_shield_active`:
      - Subtract from `_shield_hp`. If `_shield_hp <= 0`: `_shield_active = false`. Show shield-break visual (modulate flash).
      - Return (shield absorbs all damage).
    - Else: call `super.take_damage(amount, damage_type)`.
  - `_ready()`: set `_shield_active = true`. Shield is a stub — no visual yet (Epic 06).
- [ ] Add to group `"enemies"`. Not used in Chapter 1 wave configs (pool entry added in Chapter 3+ configs).

---

## Task 04-11 — Integration Test

- [ ] Run the project.
- [ ] Verify: waves 1–4 spawn only Grunts. Wave 5 starts spawning Runners. Wave 10 introduces Brutes.
- [ ] Verify: Runners zigzag while moving toward tower. Brutes are slow and take much less damage from Piercing.
- [ ] Verify: Flyers do not push against other enemies — they path straight through.
- [ ] Verify: wave 20 spawns the boss. Boss HP bar appears at top of screen.
- [ ] Verify: boss transitions to phase 2 at 66% HP (moves faster) and phase 3 at 33% HP.
- [ ] Verify: killing the boss triggers VictoryScreen.
- [ ] Verify: tower death at any wave triggers DefeatScreen with correct wave number.
- [ ] Verify: DefeatScreen "Try Again" restarts from wave 1 with reset stats.
- [ ] Verify: enemy count never hits negative or throws array errors in Output.
- [ ] Check Godot Profiler: ensure no memory leak — enemy pool reuse visible on wave 2+.
- [ ] Fix all errors before moving to Epic 05.
