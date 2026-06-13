# Epic 03 — Draft System

> Prerequisite: Epic 02 complete and tested.
> Goal: After each wave, a 3-card draft opens. Player picks a spell or stat upgrade. Tower gains the spell and fires it. Synergy tags accumulate and bonuses fire at thresholds. All 25 spells have .tres resource files.
> Completed epic delivers: a full run loop — fight, draft, fight, draft, with synergies building up.

---

## Task 03-01 — Create All 25 Spell Resource Files

**Folder**: `res://resources/spells/`
**Ref**: `mechanics.md` Section 5, `assets.md` Section 6 (Spell Icons)

Create one `.tres` file per spell. Use the `SpellData` resource class. For icons, use `null` for now (art in Epic 06).

### Normal Damage Spells
- [ ] `spell_throwing_axes.tres`: id=`throwing_axes`, damage=80, cooldown=1.2, range=400, type=NORMAL, category=PROJECTILE, tags=[OFFENSE], rarity=COMMON, stackable=false.
- [ ] `spell_hammer_strike.tres`: id=`hammer_strike`, damage=150, cooldown=2.5, range=350, type=NORMAL, category=AOE_BURST, aoe_radius=100, tags=[OFFENSE, HEAVY], rarity=RARE, stackable=false.
- [ ] `spell_ricochet_shot.tres`: id=`ricochet_shot`, damage=60, cooldown=0.9, range=420, type=NORMAL, category=PROJECTILE, pierce_count=0, chain_count=2, tags=[OFFENSE, CHAIN], rarity=RARE, stackable=false.
- [ ] `spell_armor_shred.tres`: id=`armor_shred`, damage=40, cooldown=1.0, range=380, type=NORMAL, category=PROJECTILE, tags=[OFFENSE], rarity=COMMON, stackable=true, stack_max=3.
- [ ] `spell_double_strike.tres`: id=`double_strike`, damage=55, cooldown=0.7, range=400, type=NORMAL, category=PROJECTILE, tags=[OFFENSE], rarity=COMMON, stackable=false.

### Piercing Damage Spells
- [ ] `spell_arrow_volley.tres`: id=`arrow_volley`, damage=45, cooldown=0.8, range=500, type=PIERCING, category=PROJECTILE, pierce_count=2, tags=[PIERCING, OFFENSE], rarity=COMMON, stackable=false.
- [ ] `spell_needle_storm.tres`: id=`needle_storm`, damage=25, cooldown=0.4, range=450, type=PIERCING, category=PROJECTILE, tags=[PIERCING], rarity=COMMON, stackable=true, stack_max=2.
- [ ] `spell_spear_throw.tres`: id=`spear_throw`, damage=120, cooldown=2.0, range=480, type=PIERCING, category=PROJECTILE, pierce_count=5, tags=[PIERCING, HEAVY], rarity=RARE, stackable=false.
- [ ] `spell_long_shot.tres`: id=`long_shot`, damage=90, cooldown=1.5, range=700, type=PIERCING, category=PROJECTILE, tags=[PIERCING, OFFENSE], rarity=RARE, stackable=false.
- [ ] `spell_penetrating_bolt.tres`: id=`penetrating_bolt`, damage=70, cooldown=1.1, range=460, type=PIERCING, category=PROJECTILE, pierce_count=3, tags=[PIERCING, CHAIN], rarity=EPIC, stackable=false.

### Magic Damage Spells
- [ ] `spell_fireball.tres`: id=`fireball`, damage=110, cooldown=1.8, range=380, type=MAGIC, category=AOE_BURST, aoe_radius=120, tags=[FIRE, OFFENSE], rarity=COMMON, stackable=false.
- [ ] `spell_chain_lightning.tres`: id=`chain_lightning`, damage=70, cooldown=1.2, range=400, type=MAGIC, category=PROJECTILE, chain_count=3, tags=[FIRE, CHAIN], rarity=RARE, stackable=false.
- [ ] `spell_blizzard.tres`: id=`blizzard`, damage=40, cooldown=0.5, range=360, type=MAGIC, category=PERSISTENT_ZONE, aoe_radius=140, tags=[UTILITY, PIERCING], rarity=RARE, stackable=false.
- [ ] `spell_arcane_nova.tres`: id=`arcane_nova`, damage=200, cooldown=5.0, range=300, type=MAGIC, category=AOE_BURST, aoe_radius=200, tags=[OFFENSE, FIRE], rarity=EPIC, stackable=false.
- [ ] `spell_mana_shield.tres`: id=`mana_shield`, damage=0, cooldown=0.0, range=0, type=MAGIC, category=PASSIVE, tags=[ARMOR, UTILITY], rarity=RARE, stackable=false.

### Siege Damage Spells
- [ ] `spell_cannon_shot.tres`: id=`cannon_shot`, damage=250, cooldown=3.5, range=420, type=SIEGE, category=PROJECTILE, tags=[HEAVY, OFFENSE], rarity=COMMON, stackable=false.
- [ ] `spell_land_mines.tres`: id=`land_mines`, damage=180, cooldown=4.0, range=0, type=SIEGE, category=MINE, aoe_radius=100, tags=[HEAVY, UTILITY], rarity=COMMON, stackable=true, stack_max=2.
- [ ] `spell_bunker_buster.tres`: id=`bunker_buster`, damage=400, cooldown=6.0, range=350, type=SIEGE, category=AOE_BURST, aoe_radius=160, tags=[HEAVY], rarity=EPIC, stackable=false.
- [ ] `spell_tremor.tres`: id=`tremor`, damage=90, cooldown=2.0, range=320, type=SIEGE, category=AOE_BURST, aoe_radius=250, tags=[HEAVY, UTILITY], rarity=RARE, stackable=false.
- [ ] `spell_shockwave.tres`: id=`shockwave`, damage=130, cooldown=3.0, range=500, type=SIEGE, category=PROJECTILE, pierce_count=10, tags=[HEAVY, PIERCING], rarity=RARE, stackable=false.

### Chaos Damage Spells
- [ ] `spell_demonfire.tres`: id=`demonfire`, damage=95, cooldown=1.4, range=380, type=CHAOS, category=AOE_BURST, aoe_radius=90, tags=[FIRE, CHAOS_TAG], rarity=RARE, stackable=false.
- [ ] `spell_black_arrow.tres`: id=`black_arrow`, damage=140, cooldown=2.0, range=500, type=CHAOS, category=PROJECTILE, tags=[CHAOS_TAG, PIERCING], rarity=RARE, stackable=false.
- [ ] `spell_cursed_ground.tres`: id=`cursed_ground`, damage=30, cooldown=0.4, range=300, type=CHAOS, category=PERSISTENT_ZONE, aoe_radius=150, tags=[CHAOS_TAG, UTILITY], rarity=EPIC, stackable=false.
- [ ] `spell_soul_rip.tres`: id=`soul_rip`, damage=200, cooldown=4.0, range=420, type=CHAOS, category=PROJECTILE, tags=[CHAOS_TAG, OFFENSE], rarity=EPIC, stackable=false.
- [ ] `spell_entropy_bolt.tres`: id=`entropy_bolt`, damage=80, cooldown=1.0, range=440, type=CHAOS, category=PROJECTILE, tags=[CHAOS_TAG, CHAIN], rarity=RARE, stackable=false.

---

## Task 03-02 — Create Stat Upgrade Resource Files

**Folder**: `res://resources/upgrades/`
**Ref**: `mechanics.md` Section 4 (Stat Upgrade Cards)

Create a `StatUpgradeData.gd` folder sibling called `res://resources/upgrades/`. Create one `.tres` per upgrade:

- [ ] `upgrade_hp.tres`: id=`upgrade_hp`, name="Fortify", hp_bonus=300, tags=[ARMOR], rarity=COMMON, stackable=true, stack_max=5.
- [ ] `upgrade_regen.tres`: id=`upgrade_regen`, name="Regeneration", regen_bonus=8.0, tags=[ARMOR], rarity=RARE, stackable=true, stack_max=3.
- [ ] `upgrade_damage.tres`: id=`upgrade_damage`, name="Sharpening", damage_multiplier=1.15, tags=[OFFENSE], rarity=COMMON, stackable=true, stack_max=4.
- [ ] `upgrade_fire_rate.tres`: id=`upgrade_fire_rate`, name="Quickened", fire_rate_multiplier=0.88, tags=[OFFENSE, UTILITY], rarity=RARE, stackable=true, stack_max=3.
- [ ] `upgrade_range.tres`: id=`upgrade_range`, name="Eagle Eye", range_bonus=80.0, tags=[UTILITY], rarity=COMMON, stackable=true, stack_max=3.
- [ ] `upgrade_armor.tres`: id=`upgrade_armor`, name="Plate Mail", armor_bonus=15, tags=[ARMOR], rarity=RARE, stackable=true, stack_max=3.
- [ ] `upgrade_xp.tres`: id=`upgrade_xp`, name="Scholar", xp_multiplier=1.25, tags=[UTILITY, GOLD], rarity=COMMON, stackable=false.
- [ ] `upgrade_reroll.tres`: id=`upgrade_reroll`, name="Second Chance", is_reroll=true, tags=[UTILITY], rarity=EPIC, stackable=false.

---

## Task 03-03 — Load Resources into SpellRegistry

**File**: `res://autoloads/SpellRegistry.gd`
**Ref**: `components.md` Section 3

- [ ] In `_ready()`, use `DirAccess` to scan `res://resources/spells/` and load all `.tres` files into `all_spells`.
- [ ] Use `DirAccess` to scan `res://resources/upgrades/` and load all `.tres` files into `all_stat_upgrades`.
- [ ] Implement `get_all_cards() -> Array`: return `all_spells + all_stat_upgrades`.
- [ ] Implement `get_spells_by_tag(tag: int) -> Array`: filter `all_spells` by `spell.tags.has(tag)`.
- [ ] Print total count of loaded spells and upgrades in `_ready()` to verify.

---

## Task 03-04 — DraftManager Full Implementation

**File**: `res://autoloads/DraftManager.gd`
**Ref**: `components.md` Section 3, `mechanics.md` Section 4

- [ ] Add `_draft_trigger: String` var (value: `"wave_clear"` or `"level_up"`).
- [ ] Implement `open_draft(trigger: String = "wave_clear")`:
  - Set `_draft_trigger = trigger`.
  - Set `GameState.phase = GamePhase.DRAFT`.
  - Emit `EventBus.phase_changed(GamePhase.DRAFT)`.
  - Call `get_draft_cards()` → store result.
  - Emit `EventBus.draft_opened`.
- [ ] Implement `get_draft_cards() -> Array[Resource]`:
  - Get `SpellRegistry.get_all_cards()`.
  - Filter out non-stackable cards already in `GameState.active_spells` that are at `stack_max`.
  - Call `_weighted_draw(pool, Constants.DRAFT_CARDS_SHOWN)`.
  - If player has 2+ active tags, guarantee at least 1 card shares a tag they already have.
  - Return array of 3 (or 4 if [Utility]×5 synergy is active).
- [ ] Implement `_weighted_draw(pool, count) -> Array`:
  - Build weighted list: COMMON weight 60, RARE weight 30, EPIC weight 10.
  - Use random weighted selection without replacement.
  - Return `count` cards.
- [ ] Implement `select_card(card: Resource)`:
  - Call `GameState.apply_card(card)`.
  - Append card to `_taken_cards`.
  - Set `GameState.phase = GamePhase.WAVE`.
  - Emit `EventBus.card_selected(card)`.
  - Emit `EventBus.draft_closed`.
  - Emit `EventBus.phase_changed(GamePhase.WAVE)`.
  - If draft was triggered by `wave_clear`: call `WaveManager.start_wave(GameState.wave_number)`.

---

## Task 03-05 — GameState Apply Card

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 4

- [ ] Implement `apply_card(card: Resource)`:
  - If card is `SpellData`:
    - If `active_spells.size() < Constants.MAX_SPELL_SLOTS`: append to `active_spells`.
    - Emit `EventBus.card_selected(card)`.
    - For each tag in `card.tags`: call `add_tag(tag)`.
    - Find tower node and call `tower.add_spell(card)`.
  - If card is `StatUpgradeData`:
    - If `card.is_reroll`: do not apply stats, return (DraftManager handles reroll).
    - Apply all non-zero stat deltas:
      - `tower_max_hp += card.hp_bonus` → also add to `tower_hp`.
      - `tower_regen_per_sec += card.regen_bonus`.
      - `tower_damage_multiplier *= card.damage_multiplier`.
      - `tower_fire_rate_multiplier *= card.fire_rate_multiplier`.
      - `tower_range_bonus += card.range_bonus`.
      - `tower_armor += card.armor_bonus`.
    - For each tag in `card.tags`: call `add_tag(tag)`.
    - Emit `hp_changed(tower_hp, tower_max_hp)`.

---

## Task 03-06 — Tower Applies Stat Upgrades

**File**: `res://scenes/tower/TowerBase.gd`

- [ ] Connect to `EventBus.card_selected` in `_ready()`.
- [ ] In `_on_card_selected(card)`:
  - If card is `SpellData` and not already in `active_spells`: the `GameState.apply_card()` already called `tower.add_spell()` — no double-add.
  - Recalculate effective range: `var effective_range = base_range + GameState.tower_range_bonus`.
  - Update `AttackRangeArea.CollisionShape2D.shape.radius = effective_range`.
- [ ] In `_fire_projectile(spell)`, apply `GameState.tower_fire_rate_multiplier` to spell cooldown:
  - Effective cooldown = `spell.cooldown * GameState.tower_fire_rate_multiplier`.
  - Store effective cooldown in `_spell_cooldowns` dict, not raw `spell.cooldown`.

---

## Task 03-07 — Implement Remaining Spell Categories in Tower

**File**: `res://scenes/tower/TowerBase.gd`
**Ref**: `mechanics.md` Section 5

- [ ] Implement `_fire_passive(spell: SpellData)`:
  - Passive spells fire once on add, not on cooldown.
  - Override `add_spell()` to detect PASSIVE category and call `_apply_passive_effect(spell)` immediately.
  - `_apply_passive_effect(spell)`: for Mana Shield — store a reflect % var on tower (10% damage returned to attacker). Connect to `tower_damaged` signal, reflect on each hit.
- [ ] Implement chain logic in `ProjectileBase.gd`:
  - Add `chain_count: int` and `_chained_targets: Array` vars.
  - In `_on_body_entered`, after dealing damage: if `chain_count > 0` and there are nearby enemies not in `_chained_targets`, find nearest, move projectile toward them, decrement `chain_count`.
  - Chain only works if `spell.chain_count > 0` (set during `initialize()`).

---

## Task 03-08 — PersistentZone Scene & Script

**File**: `res://scenes/spells/PersistentZone.tscn`
**Ref**: `components.md` Section 7, `mechanics.md` Section 5

- [ ] Create `PersistentZone.tscn` with root `Area2D`.
- [ ] Add children: `Sprite2D` (placeholder), `CollisionShape2D` (circle), `TickTimer` (Timer, wait=0.5), `DurationTimer` (Timer, one-shot).
- [ ] Create `PersistentZone.gd`:
  - Vars: `damage`, `damage_type`, `duration`.
  - `initialize(pos, radius, spell)`: set position, set shape radius, set damage, start `DurationTimer` with `spell.duration` (add duration field to SpellData if missing, default 5.0).
  - `_on_tick_timer_timeout()`: damage all overlapping enemies.
  - `_on_duration_timer_timeout()`: release to pool.
- [ ] Update `TowerBase._fire_spell()` to handle `PERSISTENT_ZONE` category: get from pool, initialize, add to `ZoneContainer`.

---

## Task 03-09 — LandMine Scene & Script

**File**: `res://scenes/spells/LandMine.tscn`
**Ref**: `components.md` Section 7, `mechanics.md` Section 5

- [ ] Create `LandMine.tscn` with root `Area2D`. Children: `Sprite2D` (small grey square), `CollisionShape2D` (CircleShape2D radius 40).
- [ ] Create `LandMine.gd`:
  - Vars: `damage`, `damage_type`, `aoe_radius`.
  - `_on_body_entered(body)`: if group `"enemies"` — get AoEZone from pool, initialize at `global_position` with `aoe_radius`, play explosion VFX, call `queue_free()` on self.
- [ ] In `TowerBase._fire_spell()`, handle `MINE` category:
  - Check active mine count (count children of `MineContainer`).
  - If at `Constants.MAX_MINES`: remove oldest mine first.
  - Spawn mine at random position 300–600px from tower.

---

## Task 03-10 — DraftCard Scene & Script

**File**: `res://scenes/ui/DraftCard.tscn`
**Ref**: `components.md` Section 8

- [ ] Create `DraftCard.tscn` with root `PanelContainer`.
- [ ] Add children:
  - `RarityBorder` (ColorRect) — colored by rarity: grey=Common, blue=Rare, purple=Epic.
  - `CardIcon` (TextureRect) — 64×64, placeholder solid color.
  - `CardName` (Label) — bold, centered.
  - `TagContainer` (HBoxContainer) — small Label chips per tag.
  - `Description` (Label) — small font, multiline, wrapping enabled.
  - `SynergyHint` (Label) — hidden by default, shows "Completes [Tag]×3!" in gold color.
  - `SelectButton` (Button) — full-width, "Choose".
- [ ] Create `DraftCard.gd`:
  - Signal: `card_selected(card_data: Resource)`.
  - `setup(data: Resource)`:
    - Set `CardName.text = data.spell_name` (or `data.upgrade_name`).
    - Set `Description.text = data.description`.
    - Set `RarityBorder.color` by rarity.
    - Create tag chips: for each tag in `data.tags`, add a Label with the tag name.
    - Check synergy hint: for each tag in `data.tags`, if `GameState.tag_counts.get(tag, 0) == 2` (one away from ×3) or `== 4` (one away from ×5), show `SynergyHint`.
  - `_on_select_button_pressed()`:
    - Animate: Tween scale to 0.95 then back.
    - Emit `card_selected(card_data)`.

---

## Task 03-11 — DraftUI Scene & Script

**File**: `res://scenes/ui/DraftUI.tscn`
**Ref**: `components.md` Section 8

- [ ] Create `DraftUI.tscn` with root `CanvasLayer`. Set `layer = 10` (above HUD).
- [ ] Add children:
  - `DimBG` (ColorRect) — full screen, `Color(0, 0, 0, 0.6)`.
  - `Panel` (VBoxContainer) — centered, width 960.
    - `TriggerLabel` (Label) — "Wave 3 Complete!" or "Level Up!".
    - `SubLabel` (Label) — "Choose an Upgrade".
    - `CardContainer` (HBoxContainer) — space_separation 20, centered.
    - *(Cards instanced dynamically)*.
- [ ] Hide `DraftUI` by default (`visible = false`).
- [ ] Create `DraftUI.gd`:
  - `_ready()`: connect `EventBus.draft_opened` to `_on_draft_opened`. Connect `EventBus.draft_closed` to `_on_draft_closed`.
  - `_on_draft_opened()`:
    - Get cards from `DraftManager.get_draft_cards()`.
    - Clear `CardContainer` children.
    - For each card: instance `DraftCard.tscn`, call `setup(card)`, connect `card_selected` to `_on_card_selected`, add to `CardContainer`.
    - Set `TriggerLabel.text` based on `DraftManager._draft_trigger`.
    - Show panel: `visible = true`. Tween alpha from 0 to 1.
  - `_on_card_selected(card)`:
    - Call `DraftManager.select_card(card)`.
  - `_on_draft_closed()`:
    - Tween alpha to 0, then `visible = false`.
    - Free all DraftCard children.

---

## Task 03-12 — Wire Draft into Game Loop

**File**: `res://scenes/main/GameWorld.gd`

- [ ] In `_on_wave_cleared(wave_number)`: replace the "start next wave after 1 second" stub with `DraftManager.open_draft("wave_clear")`.
- [ ] In `_on_phase_changed(phase)`:
  - `DRAFT`: pause `WaveManager` trickle timer, show DraftUI (already handled by EventBus).
  - `WAVE`: ensure enemies resume and WaveManager is active.
- [ ] Connect `EventBus.level_up` to `_on_level_up(level)`.
- [ ] In `_on_level_up(level)`:
  - If `GameState.phase == GamePhase.WAVE`: freeze all enemies (set `_is_attacking = false` and zero velocity on all active enemies).
  - Call `DraftManager.open_draft("level_up")`.
  - On `EventBus.draft_closed`: unfreeze enemies.

---

## Task 03-13 — Synergy Tag System Full Implementation

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 6

- [ ] Implement `_apply_synergy_bonus(tag: int, level: int)`:
  - Use a match statement on `tag` and `level`.
  - [Fire]×3: set a `fire_damage_bonus = 1.25` float stored in GameState. Used in `CombatUtils.calculate_damage()` when damage_type is MAGIC and a [Fire] tag is active.
  - [Fire]×5: set a flag `fire_leaves_burn_patch = true`. Handle in `EnemyBase.die()`.
  - [Chain]×3: increment `global_chain_bonus` by 1. Applied in `ProjectileBase` chain logic.
  - [Chain]×5: set `chain_applies_debuff = true`.
  - [Piercing]×3: increment `global_pierce_bonus` by 1. Applied in `ProjectileBase.initialize()`.
  - [Piercing]×5: set `pierce_heals_on_kill = true`.
  - [Heavy]×3: set `siege_vs_high_hp_bonus = 1.4`.
  - [Heavy]×5: set `siege_stuns = true`.
  - [Armor]×3: set `damage_reduction = 0.15`.
  - [Armor]×5: set `armor_regen_active = true`, start a 5-second timer in GameState that ticks `heal(tower_max_hp * 0.01)`.
  - [Offense]×3: `tower_damage_multiplier *= 1.10`.
  - [Offense]×5: set `bonus_projectile_every_n = 10`, track shot count in TowerBase.
  - [Utility]×3: `tower_fire_rate_multiplier *= 0.90`.
  - [Utility]×5: set `draft_shows_four_cards = true`.
  - [Gold]×2: set `materials_bonus_multiplier = 1.30`.
  - [Gold]×4: set `bonus_cache_on_perfect_run = true`.
  - [Chaos]×3: set `chaos_extra_armor_ignore = 0.50`.
  - [Chaos]×5: set `chaos_insta_kill_chance = 0.15`.
- [ ] In `CombatUtils.calculate_damage()`, check `GameState` synergy flags and apply modifiers to final damage.

---

## Task 03-14 — SynergyBanner Scene & Script

**File**: `res://scenes/ui/SynergyBanner.tscn`
**Ref**: `components.md` Section 8

- [ ] Create `SynergyBanner.tscn` with root `CanvasLayer`, `layer = 20`.
- [ ] Add children:
  - `BannerPanel` (PanelContainer) — centered top-center, hidden by default.
    - `TagIcon` (TextureRect) — 40×40 placeholder.
    - `BannerLabel` (Label) — e.g. "[Fire]×3 — Fire spells +25% damage!".
- [ ] Create `SynergyBanner.gd`:
  - `_ready()`: connect `EventBus.synergy_threshold_reached` to `show_synergy`.
  - `show_synergy(tag: int, level: int)`:
    - Set `BannerLabel.text` from a lookup dictionary of tag+level → description strings.
    - Show panel: `visible = true`.
    - Tween: slide down from top, hold 2 seconds, slide back up.
    - Set `visible = false` on tween complete.

---

## Task 03-15 — TagRowWidget Scene & Script

**File**: `res://scenes/ui/TagRowWidget.tscn`
**Ref**: `components.md` Section 8

- [ ] Create `TagRowWidget.tscn` with root `HBoxContainer`.
- [ ] Create `TagRowWidget.gd`:
  - `_ready()`: connect `GameState.tag_count_changed` to `update_tag`.
  - `update_tag(tag: int, count: int)`:
    - Find existing tag widget or create a new one (HBoxContainer: ColorRect + Label "×N").
    - Update count label.
    - If count == threshold - 1 (2 or 4): start a pulse Tween on the widget.
  - `highlight_tag(tag: int)`: brief glow color tween on that tag's widget.
- [ ] Add `TagRowWidget` instance to `HUD.tscn` (right side of HUD, below wave label).

---

## Task 03-16 — Integration Test

- [ ] Run the project.
- [ ] Kill all 5 enemies in wave 1. Verify DraftUI appears with 3 cards.
- [ ] Pick a card. Verify:
  - If spell: tower starts firing a second projectile type.
  - If stat: tower HP or damage visibly changes.
- [ ] Verify tag count increments in TagRow widget.
- [ ] Pick enough [Fire] cards to hit ×3. Verify SynergyBanner appears with correct text.
- [ ] Reach level 2 mid-combat. Verify enemies freeze and DraftUI opens mid-wave.
- [ ] After picking a card mid-wave: enemies unfreeze and combat resumes.
- [ ] Verify [Utility]×5 shows 4 cards in the draft instead of 3.
- [ ] Verify all 25 spells appear in the draft pool across multiple runs (check SpellRegistry loaded count in Output).
- [ ] Fix all errors before moving to Epic 04.
