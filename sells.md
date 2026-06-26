# Tower's Last Stand — Spell Visual Reference

25 spells mapped to free particle/trace asset shapes. Each spell lists which shapes to layer (trace = flight motion, muzzle/spark/star/circle = flavor or impact), what color tint to apply, and the mechanic type for gameplay logic.

---

## Quick Reference — By Mechanic

| Mechanic | Spells in this Category |
|---|---|
| Single Target | Quickshot, Twinshot, Shred, True Strike, Holy Shock |
| Chain | Lightning Spark, Slashing Disk, Spinning Disk, Cleave |
| AoE / Blast | Firebolt, Ember Bolt, Arcane Blast, Shockwave, Frostbolt, Glacier Shard, Chaos Bolt, Holy Bolt |
| Zone | Venom Bolt, Toxic Cloud, Chrono Ring |
| Shield (Orbit) | Spinning Shield, Fire Shield, Void Orbit |

---

## Physical

| Spell | Mechanic | Shapes Used | Tint | Notes |
|---|---|---|---|---|
| Quickshot | Single Target | trace_01 | White | Baseline attack, fastest to make. |
| Twinshot | Single Target | trace_01 ×2 | White | Fires the same bolt twice in quick succession. |
| Shred | Single Target | scratch_01 | Grey | Claw-mark slash appears on hit. |
| True Strike | Single Target | trace_01 (flight) + star_02 + trace_07 (impact) | White | Precision/crit hit — compass star flashes on landing. |
| Shockwave | AoE / Blast | slash_02 (stretched wide) | Grey-white | Flat wave travels forward instead of a point projectile. |
| Cleave | Chain | slash_02 | White-grey | Bounces enemy to enemy, 3 jumps total. |
| Spinning Disk | Chain | twirl_03 | Grey-silver | Rotating disk flies through and ricochets between enemies in its path. |
| Spinning Shield | Shield (Orbit) | circle_02 ×2, orbiting tower | Grey-blue | Defensive rings circle the tower. |

## Magic

| Spell | Mechanic | Shapes Used | Tint | Notes |
|---|---|---|---|---|
| Lightning Spark | Chain | spark_07 (full bolt) | Blue-white | Lighter/common chain bolt — arcs between enemies, smaller jump count than Chain Lightning. |
| Firebolt | AoE / Blast | muzzle_04 + trace_01 | Orange-red | Rare-tier fire bolt — muzzle shape already reads as a burst, so it explodes on impact. |
| Ember Bolt | AoE / Blast | muzzle_01 + trace_01 | Dim orange | Common-tier weaker fire bolt, smaller blast radius than Firebolt. |
| Arcane Blast | AoE / Blast | magic_02 / magic_03 + thin trace | Purple | Magic bolt that detonates into a blast on impact. |
| Chain Lightning | Chain | spark_05 + trace_04 (jump fx) | Blue-white | Arcs and jumps between enemies. |
| Fire Shield | Shield (Orbit) | smoke_07 / smoke_04 ×2, orbiting tower | Orange | Flame puffs circle the tower. |

## Frost

| Spell | Mechanic | Shapes Used | Tint | Notes |
|---|---|---|---|---|
| Frostbolt | AoE / Blast | muzzle_02 + trace_03 | Pale blue | Rare-tier frost bolt — bursts into a frost blast on impact. |
| Glacier Shard | AoE / Blast | muzzle_05 + trace_05 | Icy white-blue | Heavier frost projectile, shatters outward on impact — bigger blast than Frostbolt. |

## Chaos

| Spell | Mechanic | Shapes Used | Tint | Notes |
|---|---|---|---|---|
| Chaos Bolt | AoE / Blast | muzzle_04 + trace_04 | Dark purple | Corrupted-fire bolt — explodes into a dark blast on impact. |
| Venom Bolt | Zone | trace_03 (cast) + lingering pool | Sickly green | Poison logically pools rather than single-hitting — leaves a small lingering patch on landing. |
| Toxic Cloud | Zone | smoke ring shape (static at target) | Sickly green | Larger, longer-lasting lingering ground effect than Venom Bolt. |
| Slashing Disk | Chain | circle_02 | Dark red | Spinning blade ricochets between enemies instead of stopping at the first hit. |
| Void Orbit | Shield (Orbit) | circle_05, slow orbit | Dark purple | Chaos-themed defensive ring around the tower. |

## Holy

| Spell | Mechanic | Shapes Used | Tint | Notes |
|---|---|---|---|---|
| Holy Bolt | AoE / Blast | star_02 + trace_07 | Gold-white | Star-tipped bolt — flashes outward into a small radiant burst on impact. |
| Holy Shock | Single Target | trace_05 | White-gold | Clean beam-like holy strike. |
| Halo Ring | AoE / Blast | circle_03 (static ring) | Gold | Simple holy ring burst on hit, no orbit. |
| Chrono Ring | Zone | circle_03, slow rotation | Pale gold | Time-slow themed utility zone, not pure damage. |

---

## Production Notes

- "Trace" shapes provide the flying motion (tower → enemy). "Muzzle / spark / star / circle" shapes provide flavor, either layered onto the trace mid-flight or shown as the impact flash on landing.
- Shield (Orbit) spells do not fly — they rotate continuously around the tower as a passive visual, using 2–3 copies of the same shape spaced evenly apart.
- Zone spells are static at the target location with a slow pulse or rotation — no travel animation needed beyond the initial cast.
- Tint is applied in Photopea/Godot via Hue-Saturation adjustment or a "Color" blend-mode layer over the greyscale source asset.