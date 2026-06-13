# Epic 02 — Combat

> Prerequisite: Epic 01 complete and tested.
> Goal: Tower auto-fires projectiles at enemies. Enemies take damage and die. XP is awarded. Object pooling replaces queue_free for projectiles and enemies.
> Completed epic delivers: a full damage loop — tower shoots, enemies die, XP bar fills, level-up draft stub triggers.

---

## Task 02-01 — ProjectileBase Scene & Script

**File**: `res://scenes/spells/ProjectileBase.tscn`
**Ref**: `components.md` Section 7, `mechanics.md` Section 5

- [ ] Create `ProjectileBase.tscn` with root `Area2D`.
- [ ] Add children:
  - `Sprite2D` — 32×12 yellow ColorRect placeholder.
  - `CollisionShape2D` — CircleShape2D radius 8.
  - `VisibleOnScreenNotifier2D`.
- [ ] Create `ProjectileBase.gd`:
  - Vars: `damage: float`, `damage_type: int`, `speed: float = 700.0`, `pierce_count: int = 0`, `_direction: Vector2`, `_hits: int = 0`, `_target: Node`.
  - `initialize(target: Node, spell: SpellData)`:
    - Set `damage = spell.damage * GameState.tower_damage_multiplier`.
    - Set `damage_type = spell.damage_type`.
    - Set `pierce_count = spell.pierce_count`.
    - Set `_target = target`.
    - Set `_direction = (target.global_position - global_position).normalized()`.
    - Set `rotation = _direction.angle()`.
    - Reset `_hits = 0`.
  - `_physics_process(delta)`: move `global_position += _direction * speed * delta`.
  - `_on_body_entered(body)`:
    - If body is not in group `"enemies"`: return.
    - Call `body.take_damage(damage, damage_type)`.
    - Increment `_hits`.
    - If `_hits > pierce_count`: call `ObjectPool.release(self)`.
  - `_on_screen_exited()`: call `ObjectPool.release(self)`.
- [ ] Connect `CollisionShape2D` monitoring to `_on_body_entered`. Connect `VisibleOnScreenNotifier2D.screen_exited` to `_on_screen_exited`.
- [ ] Ensure `CollisionShape2D` is on layer `"projectiles"`, detects layer `"enemies"`.

---

## Task 02-02 — AoEZone Scene & Script

**File**: `res://scenes/spells/AoEZone.tscn`
**Ref**: `components.md` Section 7, `mechanics.md` Section 5

- [ ] Create `AoEZone.tscn` with root `Area2D`.
- [ ] Add children:
  - `Sprite2D` — 128×128 semi-transparent orange ColorRect placeholder.
  - `CollisionShape2D` — CircleShape2D (radius set at runtime).
- [ ] Create `AoEZone.gd`:
  - Vars: `damage: float`, `damage_type: int`.
  - `initialize(pos: Vector2, radius: float, spell: SpellData)`:
    - Set `global_position = pos`.
    - Set `damage = spell.damage * GameState.tower_damage_multiplier`.
    - Set `damage_type = spell.damage_type`.
    - Set `CollisionShape2D.shape.radius = radius`.
  - `_ready()`: call `_apply_damage()`, then start a 0.3-second `Timer` that calls `ObjectPool.release(self)` on timeout.
  - `_apply_damage()`: call `get_overlapping_bodies()`, filter for group `"enemies"`, call `body.take_damage(damage, damage_type)` on each.

---

## Task 02-03 — Tower Fires Projectiles

**File**: `res://scenes/tower/TowerBase.gd`
**Ref**: `mechanics.md` Section 2 (Tower Auto-Combat)

- [ ] Implement `_fire_spell(spell: SpellData)`:
  - If `spell.spell_category == SpellCategory.PROJECTILE`: call `_fire_projectile(spell)`.
  - If `spell.spell_category == SpellCategory.AOE_BURST`: call `_fire_aoe(spell)`.
  - If `spell.spell_category == SpellCategory.PASSIVE`: call `_fire_passive(spell)` (stub).
- [ ] Implement `_fire_projectile(spell: SpellData)`:
  - Call `_get_target(spell.range, TargetMode.CLOSEST)`. If null, return.
  - Get a projectile from pool: `var proj = ObjectPool.get(preload("res://scenes/spells/ProjectileBase.tscn"))`.
  - Add `proj` to `ProjectileContainer` if not already in scene tree.
  - Set `proj.global_position = global_position`.
  - Call `proj.initialize(target, spell)`.
- [ ] Implement `_fire_aoe(spell: SpellData)`:
  - Call `_get_target(spell.range, TargetMode.CLOSEST)`. If null, return.
  - Get an AoEZone from pool.
  - Call `zone.initialize(target.global_position, spell.aoe_radius, spell)`.
- [ ] Preload the projectile and AoE scenes as constants at top of script.

---

## Task 02-04 — Wire Tower to GameWorld

**File**: `res://scenes/main/GameWorld.gd`

- [ ] In `_ready()`, after setting up WaveManager, also pass references to `ProjectileContainer` and `ZoneContainer` to the tower node (or let tower find them via `get_tree().get_nodes_in_group()`).
- [ ] In `_ready()`, preload the object pool: call `ObjectPool.preload_pool(ProjectileBase_scene, 30)` and `ObjectPool.preload_pool(AoEZone_scene, 10)`.
- [ ] Verify the tower node has `active_spells` populated with at least one test spell (hardcode a SpellData inline for now — no .tres file needed yet).

---

## Task 02-05 — First Test Spell (Hardcoded)

**File**: `res://scenes/main/GameWorld.gd` (temporary, removed in Epic 03)

- [ ] In `GameWorld._ready()`, create a SpellData inline:
  ```gdscript
  var test_spell = SpellData.new()
  test_spell.spell_id = "test_bolt"
  test_spell.spell_name = "Test Bolt"
  test_spell.damage = 50.0
  test_spell.damage_type = Constants.DamageType.NORMAL
  test_spell.spell_category = Constants.SpellCategory.PROJECTILE
  test_spell.cooldown = 1.0
  test_spell.range = 450.0
  test_spell.pierce_count = 0
  ```
- [ ] Call `TowerNode.add_spell(test_spell)`.
- [ ] Run project and verify the tower fires yellow rectangles at approaching red squares.

---

## Task 02-06 — Enemy Takes Damage & Dies

**File**: `res://scenes/enemies/EnemyBase.gd`
**Ref**: `mechanics.md` Section 3 (Enemy Death), Section 5 (Damage Table)

- [ ] Verify `take_damage(amount, damage_type)` calls `CombatUtils.calculate_damage(amount, damage_type, armor_type)` correctly.
- [ ] Verify `die()` emits `EventBus.enemy_died(self, global_position)` before freeing.
- [ ] Verify `EventBus.xp_gained(xp_value)` is emitted from `die()`.
- [ ] Verify WaveManager's `_on_enemy_died` removes the enemy from `_active_enemies` and emits `wave_cleared` when array is empty.
- [ ] Add HPBar update in `take_damage()`: show HPBar if hidden, set `HPBar.value = (hp / base_hp) * 100`.

---

## Task 02-07 — XP & Level-Up Stub

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 4 (Draft Trigger)

- [ ] Connect to `EventBus.xp_gained` in `_ready()`.
- [ ] In `_on_xp_gained(amount)`:
  - Add to `run_xp`.
  - Emit `xp_bar_updated(run_xp, run_xp_to_next)`.
  - If `run_xp >= run_xp_to_next`:
    - Increment `run_level`.
    - Subtract `run_xp_to_next` from `run_xp`.
    - Scale `run_xp_to_next` up by 1.2 (each level needs more XP).
    - Emit `EventBus.level_up(run_level)`.
    - Call `DraftManager.open_draft()` (still a stub — just prints for now).
- [ ] Set initial `run_xp_to_next = Constants.XP_PER_LEVEL_BASE` in `start_run()`.

---

## Task 02-08 — HUD XP Bar

**File**: `res://scenes/ui/HUD.tscn` + `HUD.gd`
**Ref**: `components.md` Section 8, `mechanics.md` Section 10

- [ ] In `HUD.tscn`, add:
  - `XPBar` (ProgressBar) — anchored top center, width 600, height 20.
  - `LevelLabel` (Label) — "Lv.1", next to XP bar.
  - `HPBar` (ProgressBar, styled red/green) — left side.
  - `HPLabel` (Label) — "2000 / 2000".
  - `WaveLabel` (Label) — "Wave 1 / 20", top right.
- [ ] Create `HUD.gd`:
  - `_ready()`: connect to `GameState.hp_changed`, `GameState.xp_bar_updated`.
  - `_on_hp_changed(hp, max_hp)`: create a Tween, animate `HPBar.value` to `(hp / max_hp) * 100`.
  - `_on_xp_bar_updated(current, needed)`: animate `XPBar.value` to `(current / needed) * 100`. Update `LevelLabel`.
- [ ] Connect `EventBus.wave_started` → update `WaveLabel`.

---

## Task 02-09 — Object Pool for Enemies

**File**: `res://autoloads/WaveManager.gd`, `res://scenes/enemies/EnemyBase.gd`
**Ref**: `components.md` Section 3 (ObjectPool)

- [ ] Preload enemy scenes in `GameWorld._ready()`: call `ObjectPool.preload_pool(EnemyGrunt_scene, 30)`.
- [ ] In `WaveManager._spawn_enemy(type)`:
  - Get from pool: `var e = ObjectPool.get(EnemyGrunt_scene)`.
  - Set `e.global_position = _get_spawn_position()`.
  - Add to `EnemyContainer` if not in scene tree.
  - Enable collision shapes (they are disabled when released to pool).
  - Call `e._ready()` equivalent to reset HP (add a `reset()` method to EnemyBase).
  - Append to `_active_enemies`.
  - Return `e`.
- [ ] Add `reset()` to `EnemyBase.gd`: reset `hp = base_hp`, `_is_attacking = false`, `_attack_timer = 0`, hide HPBar.
- [ ] In `EnemyBase.die()`: replace `queue_free()` with `ObjectPool.release(self)`.

---

## Task 02-10 — Tower Takes Damage

**File**: `res://scenes/enemies/EnemyBase.gd`, `res://scenes/tower/TowerBase.gd`
**Ref**: `mechanics.md` Section 2 (Tower HP & Death)

- [ ] In `EnemyBase._physics_process(delta)` when `_is_attacking`:
  - Tick `_attack_timer += delta`.
  - When `_attack_timer >= attack_cooldown`:
    - Reset `_attack_timer = 0`.
    - Call `_tower_ref.take_damage(base_damage)` (pass damage type too — use `DamageType.NORMAL` for all enemies for now).
- [ ] Ensure `_tower_ref` is set when enemy spawns: in `WaveManager._spawn_enemy()`, set `enemy._tower_ref = GameWorld's TowerNode`.
- [ ] In `TowerBase.take_damage(amount)`: call `GameState.take_damage(amount)`.
- [ ] In `GameState.take_damage(amount)`: emit `hp_changed` → HUD updates bar.
- [ ] Verify HUD HP bar decreases as enemies hit tower.

---

## Task 02-11 — Game Over Stub

**File**: `res://scenes/main/GameWorld.gd`

- [ ] Connect `EventBus.tower_died` to `_on_tower_died()`.
- [ ] In `_on_tower_died()`:
  - Call `WaveManager.clear_all_enemies()`.
  - Print "GAME OVER — Wave reached: " + str(GameState.wave_number).
  - Pause the scene tree: `get_tree().paused = true`.
  - Show a simple Label in the center screen: "GAME OVER — Tap to retry".
  - On tap: unpause, call `GameState.reset()`, call `get_tree().reload_current_scene()`.
- [ ] Full DefeatScreen scene comes in Epic 04.

---

## Task 02-12 — Wave Clear & Next Wave Stub

**File**: `res://scenes/main/GameWorld.gd`

- [ ] In `_on_wave_cleared(wave_number)`:
  - If `wave_number >= Constants.TOTAL_WAVES`: trigger boss (stub: print "BOSS TIME").
  - Else: increment `GameState.wave_number`, start brief 1-second pause, then call `WaveManager.start_wave(GameState.wave_number)`.
- [ ] Draft will be inserted here in Epic 03 — for now just go straight to next wave after 1 second.

---

## Task 02-13 — Integration Test

- [ ] Run the project.
- [ ] Verify: tower fires yellow projectiles at red enemy squares.
- [ ] Verify: enemies lose HP and die after enough hits. HPBar appears above them on first hit.
- [ ] Verify: XP bar fills as enemies die. Level counter increments. "open_draft called" prints in Output.
- [ ] Verify: HP bar decreases when enemies reach and attack the tower.
- [ ] Verify: when tower HP hits 0, game pauses and "GAME OVER" label appears.
- [ ] Verify: wave clears when all enemies are dead and next wave spawns after 1 second.
- [ ] Verify: no `queue_free` on projectiles or enemies — they return to pool and are reused.
- [ ] Check Godot Profiler: physics process time should be < 5ms with 20 active enemies.
- [ ] Fix all errors before moving to Epic 03.
