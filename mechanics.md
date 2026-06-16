# Tower's Last Stand — Mechanics Reference

> This document describes every gameplay mechanic in the game.
> Priority: [MVP] = first playable | [v1.1] = second pass | [v2] = post-launch
> Cross-references: see `components.md` for implementation nodes, `assets.md` for required art/audio.

---

## 1. Core Game Loop

### Run Structure [MVP]
- A run = one chapter attempt, ~10 minutes, ~20 waves.
- Each wave lasts 20–30 seconds of active combat.
- Between every wave: a 3-card upgrade draft (pick 1 of 3 random options).
- Every N kills (level-up threshold): another 3-card draft mid-run.
- Run ends on: tower death (defeat) | all waves cleared (victory) | boss killed (bonus victory).
- On defeat: restart chapter from wave 1. No mid-run saves. Full permadeath per run.
- Meta upgrades (tower stars, spell ranks) persist across runs permanently.

### Phase State Machine [MVP]
Three phases per run managed by `GameState`:
- `WAVE` — enemies active, tower auto-firing, wave timer running.
- `DRAFT` — wave ended or level-up triggered, 3-card UI shown, all combat paused.
- `BOSS` — final wave of the chapter, boss enemy active, special music.

Transitions: `WAVE → DRAFT` on wave clear or level-up. `DRAFT → WAVE` on card picked. `WAVE → BOSS` on wave 20. `BOSS → VICTORY` on boss death. `WAVE/BOSS → DEFEAT` on tower HP = 0.

---

## 2. Tower Mechanics

### Tower as Character [MVP]
- The tower sits fixed at the center of the arena. It never moves.
- The tower is the player's "hero" — chosen before a run from the player's collection.
- Each tower has: base attack, stat profile (HP / DPS / range / fire rate), and a unique passive.
- Tower auto-attacks the nearest enemy within range every `fire_rate` seconds.
- Player never manually aims or fires.

### Tower Base Attacks [MVP]
Each tower fires a different default projectile with no upgrades:
- Single bolt (most towers) — one projectile per fire, tracks nearest enemy.
- Spread shot — fires 3 projectiles in a cone.
- 360 pulse — fires 8 projectiles in all directions simultaneously.
- No attack (Phantom Tower) — relies entirely on drafted spells.
- Bouncing bolt — projectile bounces to a second enemy on hit.

### Tower Stats [MVP]
| Stat | Description |
|------|-------------|
| `max_hp` | Total HP before tower dies |
| `base_damage` | Base damage per projectile |
| `fire_rate` | Seconds between auto-attacks |
| `base_range` | Pixel radius of attack range |
| `armor` | Flat damage reduction per hit |

All stats are modified by drafted upgrades and star-level bonuses during a run.

### Tower Unique Passives [MVP]
Baked into the tower, cannot be drafted or removed. Examples:
- **Ironclad**: every 5th shot fires in all 8 directions.
- **Ember**: base attack applies Burn (1-sec DoT). Fire synergies trigger on Burn stacks.
- **Tide**: base attack bounces between 2 enemies. Chain synergies jump +1 extra.
- **Sentinel**: +50% base range. Long-range spell types deal +15% damage.
- **Phantom**: no base attack. All spells gain +30% damage to compensate.

At **Star 3**: passive enhances (e.g. Ember Burn spreads to adjacent enemies on death).
At **Star 5**: second passive unlocks (e.g. Ember — every 10th shot detonates all active Burn stacks).

### Tower HP & Death [MVP]
- Tower has a visible HP bar in the HUD.
- Enemies deal damage on contact with the tower collision area.
- At HP < 30%: visual damage state activates (cracked sprite, warning SFX loops).
- At HP = 0: trigger defeat sequence. No revive mechanic.

### HP Regeneration [MVP]
- Tower does not regenerate HP by default.
- Regen is granted only through drafted upgrades or synergy tag thresholds.
- Regen ticks every 1 second via a Timer node.

---

## 3. Enemy Mechanics

### Enemy Spawning [MVP]
- `WaveManager` reads the chapter config and current wave number.
- Enemies spawn from the 4 edges of the arena at randomised positions.
- Each wave has a burst (instant spawn of N enemies at wave start) and a trickle (1 enemy every X seconds during the wave).
- Wave clears when all enemies are dead. Timer does not end the wave — kills do.

### Enemy Movement [MVP]
- All enemies move toward the tower (center of arena).
- Movement: `CharacterBody2D.move_and_slide()` with velocity = `direction * speed`.
- Separation steering: small repulsion force between nearby enemies to prevent stacking.
- Flyers move in a straight line and ignore other enemies and ground obstacles.

### Enemy Attack [MVP]
- When an enemy reaches the tower (within attack range): stop moving, begin attacking.
- Attack ticks every `attack_cooldown` seconds, calls `tower.take_damage(enemy.damage)`.
- If killed mid-attack: attack cancelled.

### Enemy Types [MVP for Grunt/Runner, v1.1 for others]
| Type | HP | Speed | Damage | Armor Type | Special |
|------|----|-------|--------|-----------|---------|
| Grunt | 200 | 60 | 25 | Medium | None |
| Runner | 80 | 140 | 15 | Light | Zigzag movement |
| Brute | 800 | 35 | 60 | Heavy | Slows on hit |
| Flyer | 150 | 90 | 20 | Medium | Straight line, ignores ground |
| Elite | varies | varies | varies | varies | Spawns from chapter 3+, has a special ability |
| Boss | unique | 40 | 150 | Chaos | Multi-phase, chapter-end only |

### Enemy Scaling Per Wave [MVP]
- `enemy_hp = base_hp * (1.12 ^ wave_number)`
- `enemy_damage = base_damage * (1.08 ^ wave_number)`
- Enemy type pool expands at milestone waves: wave 5+ adds Runner, wave 10+ adds Brute, wave 15+ adds Flyer.

### Enemy Death [MVP]
- Play death animation.
- Spawn death VFX (dust/explosion particle burst).
- Add XP to player's run XP bar (triggers level-up draft when threshold reached).
- Add kill to wave kill counter.
- Return enemy node to object pool.

### Enemy Armor Types & Damage Table [MVP]
Four armor types on enemies. Damage dealt = `base_damage * multiplier`:

| Damage Type | Unarmored | Light | Medium | Heavy |
|-------------|-----------|-------|--------|-------|
| Normal | 1.0× | 1.5× | 2.0× | 0.7× |
| Piercing | 2.0× | 1.5× | 0.5× | 0.35× |
| Magic | 1.0× | 1.0× | 1.25× | 0.35× |
| Siege | 0.5× | 0.5× | 0.5× | 2.0× |
| Chaos | 1.0× | 1.0× | 1.0× | 1.0× |

---

## 4. Spell & Upgrade Draft System

### Draft Trigger [MVP]
Two events trigger a draft:
1. **Wave clear**: every wave that ends cleanly triggers a 3-card draft.
2. **Level-up**: tower earns XP per kill. When XP bar fills, immediately pause combat and show a draft (mid-wave if needed — enemies freeze).

### Draft Card Pool [MVP]
- Pool contains all spells + stat upgrade cards.
- Cards are drawn using weighted random: Common (weight 60), Rare (weight 30), Epic (weight 10).
- Cards already taken at max stack are excluded from the pool.
- At least 1 card is guaranteed to match a tag the player already has (if they have 2+ tags).

### Picking a Card [MVP]
- Player taps one of the 3 cards. It highlights briefly, then the draft closes.
- Combat resumes (or next wave begins if it was a wave-clear draft).
- No skipping, no rerolling (reroll is a rare epic card that can be drafted itself).

### Spell Cards [MVP]
Each spell card adds a new auto-cast ability to the tower. The tower fires it automatically on its own cooldown, independent of the base attack. Multiple spells fire simultaneously.

Spell card data:
- `spell_name`, `description`, `icon`
- `damage_type` (Normal / Piercing / Magic / Siege / Chaos)
- `damage`, `cooldown`, `range`, `aoe_radius`
- `tags[]` (e.g. [Fire, Chain])
- `rarity` (Common / Rare / Epic)
- `is_stackable` (if true, same card can be drafted again for a stacking bonus)

### Stat Upgrade Cards [MVP]
Non-spell cards that directly boost tower stats. Examples:
- +200 Max HP [Armor]
- +15% Damage [Offense]
- +10% Fire Rate [Offense]
- +80 Range [Utility]
- +5 HP/sec Regen [Armor]
- +20% XP Gain [Utility]
- Reroll (shuffle the current 3 cards for 3 new ones) [Utility]

---

## 5. Spell Types & Behaviors

### Single-Target Projectile [MVP]
- Spawns a projectile aimed at the nearest enemy within range.
- Projectile moves at fixed speed toward last-known target position.
- On collision: apply damage → return to pool.
- If target dies mid-flight: projectile continues in same direction, hits first thing it touches.

### AoE Burst [MVP]
- On cast: spawn a short-lived Area2D at target position.
- Instantly damages all enemies within `aoe_radius`.
- Visual: expanding ring + particle burst, lasts 0.3 seconds.
- Examples: Fireball, Arcane Nova, Shockwave.

### Persistent Zone [v1.1]
- Spawns a lingering Area2D zone at cast position.
- Ticks damage to all enemies inside every 0.5 seconds.
- Zone lasts 4–6 seconds then disappears.
- Examples: Blizzard, Cursed Ground.

### Chain / Bounce [v1.1]
- Fires at primary target. On hit, jumps to nearest enemy within bounce radius (excluding already-hit).
- Chain count defined per spell (default: 3 jumps).
- Each jump draws a Line2D lightning arc that fades over 0.2 seconds.
- Examples: Chain Lightning, Entropy Bolt.

### Land Mine [v1.1]
- Every `cooldown` seconds, places a mine at a random position 300–600px from tower.
- Mine sits idle. Triggered when enemy enters its detection radius.
- Explodes for AoE damage, then disappears.
- Max 10 active mines. Oldest removed if cap exceeded.

### Passive / Aura [MVP]
- No projectile. Effect applied on draft and runs continuously.
- Examples: Immolation Aura (deals Magic damage to all enemies within 150px every 1 sec), Mana Shield (reflects 10% of damage taken back at attacker).

---

## 6. Synergy Tag System

### How Tags Work [MVP]
- Every draft card (spell or stat) has 1–2 tags.
- Tags accumulate across all cards picked during the run.
- When a tag count hits a threshold, a bonus activates permanently for the rest of the run.
- Thresholds are checked automatically — no UI management needed by the player.
- Bonuses stack: hitting ×3 and then ×5 gives BOTH bonuses.

### Tag Thresholds [MVP]
| Tag | ×3 Bonus | ×5 Bonus |
|-----|----------|----------|
| [Fire] | All Fire spells +25% damage | Enemies killed by Fire leave a 1-sec Burn patch |
| [Chain] | Chain effects jump +1 extra time | Chain jumps apply primary spell's damage type debuff |
| [Piercing] | Piercing projectiles pass through +1 extra enemy | Piercing kills restore 0.5% max HP |
| [Heavy] | Siege attacks +40% damage vs high-HP enemies | Siege attacks stun for 0.3 sec |
| [Armor] | Tower takes 15% less damage | Tower regens 1% max HP every 5 sec |
| [Offense] | All damage +10% | Every 10th attack fires a free bonus projectile |
| [Utility] | Spell cooldowns -10% | Draft pool shows 4 cards instead of 3 |
| [Gold] | +30% materials earned end of run | Bonus material cache if run cleared without dying |
| [Chaos] | Chaos spells ignore 50% of armor on top of existing table | Chaos spells have 15% chance to instantly kill non-boss enemies |

### Synergy Display [MVP]
- HUD shows a small row of tag icons with current counts.
- Tags that are 1 away from a threshold pulse subtly to hint at the payoff.
- When a threshold is hit: brief screen flash + "SYNERGY UNLOCKED" banner for 1.5 seconds.

---

## 7. Chapter & World Map

### World Map Structure [v1.1 for multi-chapter, MVP for single chapter]
- Linear map: Chapter 1 → Chapter 2 → … → Chapter N.
- Each chapter = 10 stages (e.g. 1-1 through 1-10). Stage 10 is always a boss stage.
- Chapters unlock sequentially — complete chapter N to unlock chapter N+1.
- Any previously completed chapter can be replayed for materials (with diminishing returns).

### Launch Chapter Scope [ADDED]
- Target: **4 chapters at launch**. This is consistent with how similar mobile roguelites (e.g. Archero) shipped their initial content — a small but complete chapter set, expanded post-launch via updates.
- 4 chapters maps cleanly to the tower unlock system: one Blueprint per chapter completion means the player earns all 4 non-Ironclad towers by the time they finish the launch content.
- Exact chapter count subject to change during balance testing — this is the current target, not a hard constraint.

### Chapter Modifiers [v1.1]
Each chapter has a passive environmental modifier active for the entire run:
- *Chapter 1 (Plains)*: no modifier.
- *Chapter 2 (Frost Wastes)*: enemies +20% HP, −15% speed.
- *Chapter 3 (Volcanic Ridge)*: lava patches deal Magic damage to ground enemies (helps player).
- *Chapter 4 (Dark Fortress)*: enemy armor type randomises each wave.

### Boss Mechanics [MVP for basic boss, v1.1 for multi-phase]
- Boss is a single massive enemy that spawns alone on wave 10 (or 20 in longer chapters).
- Boss has multiple HP phases. At each phase threshold (e.g. 66% HP, 33% HP): brief invincibility, visual change, mechanic shift.
- Each boss has one mechanic that counters a common build (e.g. Frost boss heals when hit by Magic).
- Boss death triggers victory, bonus material drop, and chapter complete screen.

---

## 8. Meta Progression

### Tower Stars [MVP]
- Each tower upgrades from Star 1 to Star 5.
- Cost: Chapter Materials + Universal Materials (increasing per star).
- Star 3: enhances unique passive.
- Star 5: unlocks second passive.
- Stars improve base stats (HP, damage, range) by a fixed % per star.

### Tower Unlocks [ADDED — post-launch design, replaces v1.1 stub]
- Starting roster: Ironclad only. Additional towers are locked and must be crafted.
- Locked towers are visible in the Tower Garage but their stats, passive, and base attack are fully hidden. Only the tower's name and silhouette are shown.
- Each locked tower shows a "How to Unlock" hint in place of stats (e.g. "Complete Chapter 2 to earn the Blueprint").
- **Blueprint System**: completing a chapter drops a Tower Blueprint for the next locked tower. Pacing (every chapter vs every 2 chapters) to be tuned during balance testing.
- Blueprints are crafted in the Tower Garage to permanently add the tower to your roster. No other cost beyond the Blueprint itself.
- Once crafted, the tower can be star-upgraded normally with Chapter Materials.
- New towers are never strictly better — they offer different playstyles.
- No rarity system on towers. Towers use a **complexity label** instead (Basic / Advanced / Specialist) to signal how difficult they are to pilot, not how powerful they are.
  - Basic: Ironclad, Tide (straightforward stats and passives)
  - Advanced: Ember, Sentinel (synergy-dependent, skill rewarded)
  - Specialist: Phantom (no base attack — relies entirely on drafted spells)

### Tower Base Attacks per Tower [ADDED]
Each tower has a unique starting base attack that is baked in and cannot be removed or drafted. It is revealed only after the tower is crafted:
- **Ironclad**: single Normal bolt — fires one projectile at nearest enemy.
- **Ember**: Fire bolt — single Chaos/Magic projectile that applies Burn on hit.
- **Tide**: Bouncing bolt — Normal projectile that bounces to a second nearby enemy.
- **Sentinel**: Long bolt — single Piercing projectile with extended range.
- **Phantom**: No base attack — compensated by all drafted spells dealing +30% damage.

### Spell Ranks [v1.1]
- Each of the 25 spells has ranks 1–5, upgraded with materials.
- Rank does not just increase numbers — each rank adds behavior.
- Example (Arrow Volley): Rank 1 = 3 arrows | Rank 3 = arrows pierce 1 enemy | Rank 5 = piercing arrows leave a 1-sec slow field.
- Only spells the player has drafted at least once can be ranked up (discovery system).

### Materials [MVP]
Two material types:
- **Chapter Materials**: specific to each chapter theme. Used to upgrade towers and spells tied to that chapter. Drops from completing stages.
- **Universal Materials**: rare. Drop from boss kills only. Can be used for any upgrade.

Material storage shown in the Tower Garage between runs.

---

## 9. Monetization Mechanics

### Energy System [MVP]
- Each run costs 1 Energy.
- Max 5 Energy. Regenerates 1 per hour.
- Extra energy purchasable with premium currency.
- Energy is not required for practice mode (a special no-reward mode for experimenting with builds — v2).

### Premium Currency [MVP]
- Earned slowly through chapter completion milestones.
- Purchased with real money.
- Used for: extra energy, cosmetic tower skins, occasional material bundles.
- Never directly purchases stat power.

### Tower Packs [ADDED — replaces v1.1 stub]
- New towers are earned through chapter progression via the Blueprint system (see Meta Progression section).
- Premium currency can skip the Blueprint grind (buy the Blueprint directly) but cannot bypass the crafting step or the chapter requirement gate — this prevents new players from buying power they can't use.
- All towers are earnable free with enough play. Premium only saves time.

### Cosmetics [v1.1]
- Tower skins: change idle animation, projectile visuals, impact VFX, death animation.
- Skin rarity: Standard (earnable), Deluxe (premium), Legendary (battle pass exclusive).
- No stat effect ever.

### Battle Pass [v2]
- Seasonal (8 weeks). 50 tiers.
- Rewards: materials, premium currency, cosmetic skin at tier 50.
- Free track exists with reduced rewards. Paid track accelerates everything.
- Never contains exclusive stat-affecting content.

### Hard Caps (Anti-Whale Protection) [MVP]
- Spell ranks and tower stars are gated by chapter progress, not just materials.
- A new player who spends money cannot outpace chapter unlock requirements.
- Chapters 1–3 content capped at Star 3 / Rank 3 regardless of materials owned.

---

## 10. UI & UX Mechanics

### HUD During Wave [MVP]
- Top: wave counter (Wave 7 / 20), XP bar with level indicator.
- Left: tower HP bar with numeric value.
- Right: tag synergy row (icon + count per active tag).
- No gold counter during runs (gold replaced by materials earned post-run).
- No manual fire button — all combat is automatic.

### Draft UI [MVP]
- Full-screen overlay with 3 cards.
- Each card shows: icon, name, type tag(s), rarity, description.
- Cards that would complete a synergy threshold are highlighted with a glow.
- Tap card to select. No timer — player can take as long as they want.

### Damage Numbers [v1.1]
- Float upward from enemy hit position, fade over 0.8 seconds.
- Color-coded by damage type: white=Normal, yellow=Piercing, red=Magic, grey=Siege, purple=Chaos.
- Critical/synergy-boosted hits show larger numbers.

### Chapter Complete Screen [MVP]
- Shows: waves cleared, enemies killed, synergies achieved, materials earned.
- Breakdown of material drops. Continue button returns to world map.

### Defeat Screen [MVP]
- Shows: wave reached, best run comparison, materials earned (partial even on loss).
- "Try Again" button restarts chapter from wave 1.
- "Return to Map" button goes back to world map.

### Tower Garage (Meta UI) [MVP + ADDED]
- Shows ALL towers (owned and locked) in a single scrollable list.
- **Owned towers**: show current star level, stats, passive description, upgrade cost, and a Select button.
- **Locked towers** [ADDED]: shown as a silhouette with name and complexity label visible. Stats, passive, and base attack are fully hidden. Shows "How to Unlock" text in place of stats (e.g. "Complete Chapter 2 to receive the Blueprint"). If player has the Blueprint in hand, shows a "Craft Tower" button instead.
- Upgrade button (greyed if insufficient materials).
- Select button to bring an owned tower into next run.

### Spell Codex (Meta UI) [v1.1]
- Shows all 25 spells with lock/unlock state, current rank, rank-up preview.
- Filter by damage type tag.
- Rank-up button with material cost shown.
