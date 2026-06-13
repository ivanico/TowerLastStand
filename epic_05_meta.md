# Epic 05 — Meta Progression

> Prerequisite: Epic 04 complete and tested.
> Goal: The meta game loop works. Player returns to world map after a run, spends materials to upgrade towers and spells, picks a tower, and starts the next run with persistent star/rank bonuses applied.
> Completed epic delivers: a full game loop — run → result → upgrade → run.

---

## Task 05-01 — SaveData Resource & SaveManager

**File**: `res://scripts/SaveData.gd`
**Ref**: `components.md` Section 10

- [ ] Ensure `SaveData.gd` matches the spec exactly:
  ```gdscript
  class_name SaveData
  extends Resource

  @export var owned_towers: Array[int]
  @export var tower_stars: Dictionary
  @export var spell_ranks: Dictionary
  @export var discovered_spells: Array[String]
  @export var materials: Dictionary          # { MaterialType: int }
  @export var energy: int
  @export var energy_last_regen_time: int    # Unix timestamp (seconds)
  @export var premium_currency: int
  @export var selected_tower_id: int
  @export var chapters_completed: Array[int]
  @export var best_wave_per_chapter: Dictionary
  ```
- [ ] Create `res://scripts/SaveManager.gd` as a static class:
  - `const SAVE_PATH = "user://save.tres"`.
  - `static func save(data: SaveData) -> void`: call `ResourceSaver.save(data, SAVE_PATH)`.
  - `static func load() -> SaveData`:
    - If `FileAccess.file_exists(SAVE_PATH)`: return `ResourceLoader.load(SAVE_PATH)` as `SaveData`.
    - Else: return `_create_default_save()`.
  - `static func _create_default_save() -> SaveData`:
    - Create new `SaveData`. Set `owned_towers = [Constants.TowerID.IRONCLAD]`, `tower_stars = {Constants.TowerID.IRONCLAD: 1}`, `energy = 5`, `energy_last_regen_time = Time.get_unix_time_from_system()`, `selected_tower_id = Constants.TowerID.IRONCLAD`. Return.
  - `static func delete() -> void`: call `DirAccess.remove_absolute(SAVE_PATH)`.

---

## Task 05-02 — MetaManager Full Implementation

**File**: `res://autoloads/MetaManager.gd`
**Ref**: `components.md` Section 3, `mechanics.md` Section 8

Replace the Epic 01 stub:

- [ ] Add vars:
  ```gdscript
  var owned_towers: Array[int]
  var tower_stars: Dictionary
  var spell_ranks: Dictionary
  var discovered_spells: Array[String]
  var materials: Dictionary
  var energy: int
  var premium_currency: int
  var selected_tower_id: int
  var chapters_completed: Array[int]
  var best_wave_per_chapter: Dictionary
  var _energy_regen_timer: Timer
  const ENERGY_REGEN_INTERVAL: int = 3600  # 1 hour in seconds
  ```
- [ ] Implement `_ready()`:
  - Load save via `SaveManager.load()` and populate all vars.
  - Create `_energy_regen_timer` as a child Timer (wait=60.0, autostart=true). Connect `timeout` to `_on_energy_regen_tick`.
  - On ready, immediately call `_apply_offline_energy_regen()`.
- [ ] Implement `save()`: populate a `SaveData` resource from current vars, call `SaveManager.save(data)`.
- [ ] Implement `load()`: call `SaveManager.load()`, assign all fields to local vars.
- [ ] Implement `_apply_offline_energy_regen()`:
  - Get current Unix time. Calculate elapsed = `now - save.energy_last_regen_time`.
  - Compute ticks earned: `int(elapsed / ENERGY_REGEN_INTERVAL)`.
  - Call `restore_energy(ticks_earned)`.
  - Update `energy_last_regen_time` to `now - (elapsed % ENERGY_REGEN_INTERVAL)` so partial time is preserved.
- [ ] Implement `_on_energy_regen_tick()`:
  - If `energy < Constants.MAX_ENERGY`: call `restore_energy(1)`. Emit signal `energy_changed`.
- [ ] Implement `spend_energy() -> bool`:
  - If `energy > 0`: decrement. Call `save()`. Return true. Else return false.
- [ ] Implement `restore_energy(amount: int)`:
  - `energy = mini(energy + amount, Constants.MAX_ENERGY)`. Call `save()`.
- [ ] Implement `get_tower_star(tower_id: int) -> int`:
  - Return `tower_stars.get(tower_id, 1)`.
- [ ] Implement `upgrade_tower_star(tower_id: int) -> bool`:
  - Get current star. If >= `Constants.TOWER_MAX_STARS`: return false.
  - Compute cost (see Task 05-03). If insufficient materials: return false.
  - Deduct materials. Increment `tower_stars[tower_id]`. Call `save()`.
  - Emit `EventBus.tower_upgraded(tower_id, tower_stars[tower_id])`.
  - Return true.
- [ ] Implement `get_spell_rank(spell_id: String) -> int`:
  - Return `spell_ranks.get(spell_id, 1)`.
- [ ] Implement `upgrade_spell_rank(spell_id: String) -> bool`:
  - If spell not in `discovered_spells`: return false.
  - Get rank. If >= `Constants.SPELL_MAX_RANK`: return false.
  - Compute cost. If insufficient materials: return false.
  - Deduct materials. Increment `spell_ranks[spell_id]`. Call `save()`.
  - Emit `EventBus.spell_ranked_up(spell_id, spell_ranks[spell_id])`.
  - Return true.
- [ ] Implement `discover_spell(spell_id: String)`:
  - If not in `discovered_spells`: append. Call `save()`.
- [ ] Implement `add_materials(type: int, amount: int)`:
  - Increment `materials[type]` by `amount`. Call `save()`.
- [ ] Add signal `energy_changed(new_energy: int, max_energy: int)`.
- [ ] In `GameState.apply_card()`: after applying a SpellData card, call `MetaManager.discover_spell(card.spell_id)`.

---

## Task 05-03 — Upgrade Cost Tables

**File**: `res://autoloads/MetaManager.gd`

- [ ] Implement `get_tower_upgrade_cost(tower_id: int, to_star: int) -> Dictionary`:
  - Returns `{ MaterialType.CHAPTER_MAT: int, MaterialType.UNIVERSAL_MAT: int }`.
  - Table (to_star = target star level):
    | to_star | Chapter Mat | Universal Mat |
    |---------|-------------|---------------|
    | 2 | 10 | 0 |
    | 3 | 25 | 1 |
    | 4 | 50 | 3 |
    | 5 | 100 | 5 |
- [ ] Implement `get_spell_rank_cost(spell_id: String, to_rank: int) -> Dictionary`:
  - Table (to_rank = target rank):
    | to_rank | Chapter Mat | Universal Mat |
    |---------|-------------|---------------|
    | 2 | 8 | 0 |
    | 3 | 18 | 1 |
    | 4 | 35 | 2 |
    | 5 | 60 | 4 |

---

## Task 05-04 — Apply Star Bonuses to Tower at Run Start

**File**: `res://autoloads/GameState.gd`, `res://scenes/tower/TowerBase.gd`

- [ ] In `GameState.start_run(tower_data: TowerData)`:
  - Get `star = MetaManager.get_tower_star(MetaManager.selected_tower_id)`.
  - Apply star HP bonus: for each star above 1, add `tower_data.star_hp_bonus[star - 2]` to `tower_max_hp`.
  - Apply star damage bonus: sum `tower_data.star_damage_bonus` up to current star into `tower_damage_multiplier`.
- [ ] Create `res://resources/towers/tower_ironclad.tres` using `TowerData.gd`:
  - `tower_id = IRONCLAD`, `tower_name = "Ironclad"`, `base_hp = 2000`, `base_damage = 50.0`, `base_fire_rate = 1.0`, `base_range = 450.0`, `base_armor = 0`, `base_attack_type = DamageType.NORMAL`.
  - `star_hp_bonus = [200, 300, 400, 500]` (Star 2 through Star 5).
  - `star_damage_bonus = [0.05, 0.08, 0.10, 0.15]` (multiplied cumulatively).
- [ ] Create placeholder `.tres` files for the other 4 towers (Ember, Tide, Sentinel, Phantom) with reasonable base stats. These will be tuned in Epic 08.
- [ ] In `GameWorld._ready()`: load `tower_ironclad.tres` and pass to `GameState.start_run()` instead of null.

---

## Task 05-05 — WorldMap Scene & Script (Single Chapter Stub)

**File**: `res://scenes/main/WorldMap.tscn`
**Ref**: `mechanics.md` Section 7

- [ ] Create `WorldMap.tscn` with root `Node2D`.
- [ ] Add children:
  - `BG` (ColorRect) — full screen, dark green/map color.
  - `TitleLabel` (Label) — "Tower's Last Stand", top center.
  - `EnergyBar` (HBoxContainer, top right):
    - `EnergyIcon` (TextureRect) — placeholder lightning bolt ColorRect.
    - `EnergyLabel` (Label) — "5 / 5".
  - `ChapterNode` (VBoxContainer, center screen):
    - `ChapterLabel` (Label) — "Chapter 1 — Plains".
    - `BestWaveLabel` (Label) — "Best: Wave 20 ✓" or "Not cleared yet".
    - `StartButton` (Button) — "Start Run".
  - `GarageButton` (Button, bottom left) — "Tower Garage".
  - `CodexButton` (Button, bottom right) — "Spell Codex".
- [ ] Create `WorldMap.gd`:
  - `_ready()`:
    - Update `EnergyLabel` from `MetaManager.energy`.
    - Update `BestWaveLabel` from `MetaManager.best_wave_per_chapter.get(1, 0)`.
    - Connect buttons to handlers.
    - Connect `MetaManager.energy_changed` to `_on_energy_changed`.
  - `_on_start_button_pressed()`:
    - If `MetaManager.spend_energy()` returns false: show "Not enough energy" (Label or brief popup). Return.
    - Call `get_tree().change_scene_to_file("res://scenes/main/GameWorld.tscn")`.
  - `_on_garage_button_pressed()`: `get_tree().change_scene_to_file("res://scenes/main/TowerGarage.tscn")`.
  - `_on_codex_button_pressed()`: `get_tree().change_scene_to_file("res://scenes/main/SpellCodex.tscn")`.
  - `_on_energy_changed(e, max_e)`: update `EnergyLabel.text = str(e) + " / " + str(max_e)`.

---

## Task 05-06 — Tower Garage Scene & Script

**File**: `res://scenes/main/TowerGarage.tscn`
**Ref**: `mechanics.md` Section 10

- [ ] Create `TowerGarage.tscn` with root `Node2D`.
- [ ] Add children:
  - `BG` (ColorRect) — full screen, dark grey.
  - `TitleLabel` (Label) — "Tower Garage".
  - `TowerList` (HBoxContainer, center) — populated dynamically.
  - `DetailPanel` (VBoxContainer, right side):
    - `TowerNameLabel` (Label).
    - `StarRow` (HBoxContainer) — 5 star slots (ColorRect placeholders for empty/filled).
    - `StatsLabel` (Label) — HP / DMG / Range.
    - `PassiveLabel` (Label) — passive description.
    - `UpgradeCostLabel` (Label) — "Cost: 25 Chapter Mats, 1 Universal Mat".
    - `UpgradeButton` (Button) — "Upgrade to ★3".
    - `SelectButton` (Button) — "Select Tower".
    - `MaterialsLabel` (Label) — "Your Materials: 12 Chapter / 2 Universal".
  - `BackButton` (Button) — top left, "← Back".
- [ ] Create `TowerGarage.gd`:
  - `_ready()`:
    - For each tower in `MetaManager.owned_towers`: instantiate a tower card (Panel + Label + star icons). Connect tap to `_on_tower_selected(tower_id)`.
    - Call `_on_tower_selected(MetaManager.selected_tower_id)` to pre-select current tower.
    - Connect `BackButton.pressed` to back handler.
  - `_on_tower_selected(tower_id: int)`:
    - Load `TowerData` resource for this tower.
    - Populate `DetailPanel`: name, stats scaled by current star, passive text.
    - Compute star cost via `MetaManager.get_tower_upgrade_cost()`. Update `UpgradeCostLabel`.
    - Grey out `UpgradeButton` if at max star or insufficient materials.
  - `_on_upgrade_button_pressed()`:
    - Call `MetaManager.upgrade_tower_star(selected_tower_id)`. If true: refresh panel. Show brief "Upgraded!" Label.
  - `_on_select_button_pressed()`:
    - Set `MetaManager.selected_tower_id = selected_id`. Call `MetaManager.save()`.
  - `_on_back_pressed()`: `get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")`.

---

## Task 05-07 — Spell Codex Scene & Script

**File**: `res://scenes/main/SpellCodex.tscn`
**Ref**: `mechanics.md` Section 10

- [ ] Create `SpellCodex.tscn` with root `Node2D`.
- [ ] Add children:
  - `BG` (ColorRect) — full screen.
  - `TitleLabel` (Label) — "Spell Codex".
  - `FilterRow` (HBoxContainer) — one Button per DamageType + "All". Highlight active filter.
  - `SpellGrid` (GridContainer, columns=3) — populated dynamically.
  - `DetailPanel` (VBoxContainer, bottom half):
    - `SpellNameLabel` (Label).
    - `RankRow` (HBoxContainer) — 5 rank dots.
    - `DescriptionLabel` (Label) — rank-specific description.
    - `RankUpCostLabel` (Label).
    - `RankUpButton` (Button) — "Rank Up".
    - Locked overlay: "Draft this spell to unlock".
  - `BackButton` (Button).
- [ ] Create `SpellCodex.gd`:
  - `_ready()`: populate grid from `SpellRegistry.all_spells`. Show lock overlay for spells not in `MetaManager.discovered_spells`. Connect filter buttons.
  - `_on_spell_selected(spell_id)`: populate detail panel. Compute rank-up cost.
  - `_on_rank_up_pressed()`: call `MetaManager.upgrade_spell_rank(spell_id)`. Refresh.
  - `_on_filter_pressed(damage_type)`: filter grid to show only spells of that type.
  - `_on_back_pressed()`: return to WorldMap.

---

## Task 05-08 — End-of-Run Material Rewards

**File**: `res://scenes/main/VictoryScreen.gd`, `res://scenes/main/DefeatScreen.gd`
**Ref**: `mechanics.md` Section 8

- [ ] In `VictoryScreen._ready()`:
  - Load `chapter_01.tres` to get `chapter_mat_drop_range`.
  - Roll: `var chapter_mats = randi_range(range.x, range.y)`.
  - Roll universal: boss killed = `randi_range(1, 3)`, else 0.
  - Apply [Gold]×3 synergy: if `GameState.active_synergies.has(SynergyTag.GOLD)` and level 3 in synergy: `chapter_mats = int(chapter_mats * 1.30)`.
  - Apply [Gold]×5 bonus cache: if tower never hit 0 HP (track `GameState.perfect_run` bool), add 5 extra chapter mats.
  - Call `MetaManager.add_materials(MaterialType.CHAPTER_MAT, chapter_mats)`.
  - Call `MetaManager.add_materials(MaterialType.UNIVERSAL_MAT, universal_mats)`.
  - Update `MaterialsLabel`.
  - Update `MetaManager.best_wave_per_chapter[1] = Constants.TOTAL_WAVES`. Save.
- [ ] Add `perfect_run: bool` to `GameState`. Set to `true` in `start_run()`. Set to `false` in `take_damage()` if `tower_hp` drops below `tower_max_hp`.
- [ ] In `DefeatScreen._ready()`:
  - Partial mats (60% of normal roll): `int(randi_range(range.x, range.y) * 0.6)`.
  - Call `MetaManager.add_materials(...)`.
  - Update `MetaManager.best_wave_per_chapter[1] = max(current_best, GameState.wave_number)`. Save.

---

## Task 05-09 — Apply Spell Rank Bonuses at Run Start

**File**: `res://autoloads/SpellRegistry.gd`
**Ref**: `mechanics.md` Section 8

- [ ] Implement `get_spell_for_run(spell_id: String) -> SpellData`:
  - Get base `SpellData`. Get `rank = MetaManager.get_spell_rank(spell_id)`.
  - Clone the resource: `var s = spell.duplicate()`.
  - Apply rank bonuses (hardcoded per spell, simple scaling for now):
    - Rank 2: `s.damage *= 1.15`, `s.cooldown *= 0.95`.
    - Rank 3: `s.pierce_count += 1`.
    - Rank 4: `s.damage *= 1.20`, `s.cooldown *= 0.90`.
    - Rank 5: `s.pierce_count += 1`, `s.chain_count += 1`.
  - Return `s`.
- [ ] In `DraftManager.get_draft_cards()`: replace direct resource references with `SpellRegistry.get_spell_for_run(spell.spell_id)` so cards shown to player reflect rank bonuses.

---

## Task 05-10 — GameState Start Run with Tower Data

**File**: `res://autoloads/GameState.gd`

- [ ] Implement `start_run(tower_data: TowerData)` fully:
  ```gdscript
  func start_run(tower_data: TowerData) -> void:
      phase = Constants.GamePhase.WAVE
      wave_number = 1
      run_level = 1
      run_xp = 0
      run_xp_to_next = Constants.XP_PER_LEVEL_BASE
      active_spells.clear()
      tag_counts.clear()
      active_synergies.clear()
      total_kills = 0
      waves_cleared = 0
      damage_dealt = 0.0
      perfect_run = true

      if tower_data:
          var star = MetaManager.get_tower_star(MetaManager.selected_tower_id)
          tower_max_hp = tower_data.base_hp
          for i in range(star - 1):
              tower_max_hp += tower_data.star_hp_bonus[i]
          tower_hp = tower_max_hp
          tower_regen_per_sec = 0.0
          tower_damage_multiplier = 1.0
          for i in range(star - 1):
              tower_damage_multiplier += tower_data.star_damage_bonus[i]
          tower_fire_rate_multiplier = 1.0
          tower_range_bonus = 0.0
          tower_armor = tower_data.base_armor
      else:
          tower_max_hp = 2000
          tower_hp = 2000
          tower_regen_per_sec = 0.0
          tower_damage_multiplier = 1.0
          tower_fire_rate_multiplier = 1.0
          tower_range_bonus = 0.0
          tower_armor = 0

      emit_signal("hp_changed", tower_hp, tower_max_hp)
      emit_signal("xp_bar_updated", run_xp, run_xp_to_next)
      EventBus.emit_signal("phase_changed", phase)
  ```

---

## Task 05-11 — Integration Test

- [ ] Run the project from WorldMap.
- [ ] Verify: energy shows "5 / 5". Pressing "Start Run" deducts 1 energy. Verify "4 / 5" on return.
- [ ] Verify: completing a run (killing the boss) shows VictoryScreen with material rewards.
- [ ] Verify: materials are saved. Return to TowerGarage and confirm materials show correctly.
- [ ] Upgrade Ironclad to Star 2. Start a new run. Verify tower has the higher max HP.
- [ ] Die on a run. Verify DefeatScreen shows correct wave. Verify partial materials awarded.
- [ ] Verify: with 0 energy, "Start Run" shows the "Not enough energy" message and does NOT start a run.
- [ ] Verify: after 60 real seconds, energy ticks (check with shortened ENERGY_REGEN_INTERVAL = 10 for testing, then reset).
- [ ] Verify: closing and reopening the app restores save data (test by running the project twice).
- [ ] Fix all errors before moving to Epic 06.
