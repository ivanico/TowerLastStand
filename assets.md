# Tower's Last Stand — Assets Reference

> All art targets 1080×1920 portrait, Godot 4 Compatibility renderer.
> Art style: 3D-rendered sprites (Blender low-poly → render → spritesheet) OR clean vector 2D with soft shading.
> Pick one style and commit — mixing them kills visual cohesion.
> Sprites: PNG with transparency. Audio: OGG for music/long SFX, WAV for short SFX.

---

## Art Style Notes

Archero uses low-poly 3D models rendered from a top-down angle and exported as spritesheets.
To replicate this in Blender:
1. Model simple low-poly character/enemy (500–1500 tris).
2. Apply flat/cel shading with a slight rim light.
3. Set camera to orthographic, top-down angle (~60° from above for the Archero look).
4. Render animation frames (walk, attack, death) at 128×128 or 256×256 px per frame.
5. Pack frames into a spritesheet. Import into Godot as AnimatedSprite2D.

Alternative: 2D vector art (Adobe Illustrator, Affinity Designer, or free Inkscape) with thick outlines and soft inner shading. Faster to produce, slightly less polished.

---

## 1. Tower Sprites

Each tower needs: `idle` (2–4 frames), `attack` (fire flash, 2 frames), `damaged` (static alt frame shown at HP < 30%).

| Tower | Idle Size | Notes |
|-------|-----------|-------|
| `tower_ironclad` | 160×160 px | Armored stone/metal tower. Solid, imposing. |
| `tower_ember` | 160×160 px | Fire-themed. Glowing cracks, small flame particles. |
| `tower_tide` | 160×160 px | Water/ocean themed. Smooth curves, blue glow. |
| `tower_sentinel` | 160×160 px | Tall, narrow. Sniper aesthetic. Long barrel. |
| `tower_phantom` | 160×160 px | Ghostly, semi-transparent. Dark mist at base. |

Each tower also has:
- `tower_X_base.png` — decorative ground piece under tower (200×80 px)
- `tower_X_damaged.png` — cracked/damaged alternate idle frame
- `tower_X_icon.png` — 128×128 px portrait used in Tower Garage and WorldMap

### Tower Skins (Cosmetics)
Each skin is a full replacement spritesheet for one tower. Minimum at launch: 1 standard skin per tower (earnable), 1 deluxe skin per tower (premium). Same sprite dimensions and animation frame counts as base tower.

---

## 2. Enemy Sprites

Each enemy needs 3 animation states. Frame counts below are per animation.

| Enemy | Sprite Size | Walk Frames | Attack Frames | Death Frames | Armor Color Hint |
|-------|-------------|-------------|---------------|--------------|-----------------|
| `enemy_grunt` | 80×80 px | 4 | 3 | 4 | None (no color hint) |
| `enemy_runner` | 64×64 px | 6 | 2 | 3 | Light glow (yellow tint) |
| `enemy_brute` | 128×128 px | 4 | 4 | 5 | Heavy plates (grey/iron) |
| `enemy_flyer` | 80×80 px | 4 (hover bob) | 3 | 4 | Wings, floats above ground |
| `enemy_elite` | 96×96 px | 4 | 3 | 4 | Shield aura outline |
| `enemy_boss_ch1` | 256×256 px | 4 | 4 | 6 | Chapter 1 boss. Unique design per chapter. |

Enemy spritesheets are horizontal strips: all walk frames, then attack, then death in one PNG.
Example: `enemy_grunt.png` = 320×240 (4 walk + 3 attack + 4 death × 80px wide, 80px tall each row).

---

## 3. Projectile Sprites

Small, clean. Rotate toward travel direction in code.

| File | Size | Notes |
|------|------|-------|
| `proj_bolt.png` | 32×12 px | Default tower projectile. Pointed oval. |
| `proj_throwing_axe.png` | 28×28 px | Rotates on flight. Axe shape. |
| `proj_arrow.png` | 40×8 px | Thin pointed arrow. |
| `proj_fireball.png` | 32×32 px | 3-frame flicker animation. Orange/red. |
| `proj_arcane_bolt.png` | 24×24 px | Glowing purple orb. |
| `proj_cannonball.png` | 22×22 px | Dark sphere, no rotation. |
| `proj_needle.png` | 36×6 px | Thin needle, very fast visual. |
| `proj_spear.png` | 48×10 px | Longer than arrow. Wooden shaft + tip. |
| `proj_chaos_bolt.png` | 28×28 px | Dark swirling orb. 2-frame animation. |
| `proj_bunker_buster.png` | 36×36 px | Large bomb shape, slow rotation. |

---

## 4. AoE & Zone Visuals

| File | Size | Notes |
|------|------|-------|
| `zone_fire_ring.png` | 128×128 px | Ring shape, looping 4-frame fire animation |
| `zone_blizzard.png` | 160×160 px | Frost circle, looping shimmer |
| `zone_cursed.png` | 128×128 px | Dark purple pulsing circle |
| `zone_immolation_aura.png` | 200×200 px | Fire ring around tower base, looping |
| `zone_mine.png` | 32×32 px | Small mine sitting on ground, idle |
| `zone_mine_armed.png` | 32×32 px | Same mine, slight pulse animation (2 frames) |
| `zone_lava_patch.png` | 96×96 px | Environment tile for Chapter 3 modifier |

---

## 5. VFX / Particle Textures

Used by `GPUParticles2D`. Godot handles animation — only the texture is needed.

| File | Size | Notes |
|------|------|-------|
| `vfx_spark_white.png` | 16×16 px | Generic hit spark |
| `vfx_spark_fire.png` | 16×16 px | Orange/red tint spark |
| `vfx_spark_ice.png` | 16×16 px | Blue/white tint spark |
| `vfx_smoke_puff.png` | 32×32 px | Grey puff, enemy hit impact |
| `vfx_explosion_sheet.png` | 384×64 px | 6-frame spritesheet, 64×64 per frame |
| `vfx_death_dust.png` | 32×32 px | Dust cloud, enemy death |
| `vfx_heal_orb.png` | 20×20 px | Green glowing orb, floats up during HP regen |
| `vfx_xp_gem.png` | 20×20 px | Small gem/orb that floats from enemy to XP bar |
| `vfx_chain_lightning_node.png` | 8×8 px | Dot texture used on Line2D for chain effect |
| `vfx_synergy_burst.png` | 64×64 px | Star/starburst flash shown when synergy unlocks |
| `vfx_level_up_ring.png` | 200×200 px | Expanding ring on level-up event |
| `vfx_mine_explosion.png` | 96×96 px | 4-frame explosion sheet for mine detonation |

---

## 6. UI Assets

### HUD
| File | Size | Notes |
|------|------|-------|
| `ui_hp_bar_bg.png` | 400×28 px | Background track |
| `ui_hp_bar_fill.png` | 400×28 px | Colored fill (tinted green→red in code as HP drops) |
| `ui_xp_bar_bg.png` | 500×18 px | Narrower XP bar background |
| `ui_xp_bar_fill.png` | 500×18 px | XP fill, tinted blue/gold |
| `ui_wave_icon.png` | 36×36 px | Shield/wave icon |
| `ui_level_icon.png` | 36×36 px | Star or up-arrow icon |

### Tag Icons (Synergy Row)
One 40×40 px icon per tag. Used in HUD tag row and draft cards.

| File | Tag |
|------|-----|
| `tag_fire.png` | [Fire] |
| `tag_chain.png` | [Chain] |
| `tag_piercing.png` | [Piercing] |
| `tag_heavy.png` | [Heavy] |
| `tag_armor.png` | [Armor] |
| `tag_offense.png` | [Offense] |
| `tag_utility.png` | [Utility] |
| `tag_gold.png` | [Gold] |
| `tag_chaos.png` | [Chaos] |

### Draft UI
| File | Size | Notes |
|------|------|-------|
| `ui_card_bg_common.png` | 280×380 px | 9-slice. Grey/white border. |
| `ui_card_bg_rare.png` | 280×380 px | 9-slice. Blue/silver border. |
| `ui_card_bg_epic.png` | 280×380 px | 9-slice. Purple/gold border. |
| `ui_card_synergy_glow.png` | 280×380 px | Overlay glow for cards that complete a threshold |
| `ui_draft_title_bg.png` | 800×80 px | Banner behind "Choose an Upgrade" text |

### Spell Icons
48×48 px per spell. 25 total at launch.

| File | Spell | Type |
|------|-------|------|
| `spell_throwing_axes.png` | Throwing Axes | Normal |
| `spell_hammer_strike.png` | Hammer Strike | Normal |
| `spell_ricochet_shot.png` | Ricochet Shot | Normal |
| `spell_armor_shred.png` | Armor Shred | Normal |
| `spell_double_strike.png` | Double Strike | Normal |
| `spell_arrow_volley.png` | Arrow Volley | Piercing |
| `spell_needle_storm.png` | Needle Storm | Piercing |
| `spell_spear_throw.png` | Spear Throw | Piercing |
| `spell_long_shot.png` | Long Shot | Piercing |
| `spell_penetrating_bolt.png` | Penetrating Bolt | Piercing |
| `spell_fireball.png` | Fireball | Magic |
| `spell_chain_lightning.png` | Chain Lightning | Magic |
| `spell_blizzard.png` | Blizzard | Magic |
| `spell_arcane_nova.png` | Arcane Nova | Magic |
| `spell_mana_shield.png` | Mana Shield | Magic |
| `spell_cannon_shot.png` | Cannon Shot | Siege |
| `spell_land_mines.png` | Land Mines | Siege |
| `spell_bunker_buster.png` | Bunker Buster | Siege |
| `spell_tremor.png` | Tremor | Siege |
| `spell_shockwave.png` | Shockwave | Siege |
| `spell_demonfire.png` | Demonfire | Chaos |
| `spell_black_arrow.png` | Black Arrow | Chaos |
| `spell_cursed_ground.png` | Cursed Ground | Chaos |
| `spell_soul_rip.png` | Soul Rip | Chaos |
| `spell_entropy_bolt.png` | Entropy Bolt | Chaos |

### Stat Upgrade Icons
| File | Upgrade |
|------|---------|
| `upgrade_hp.png` | +Max HP |
| `upgrade_regen.png` | +HP Regen |
| `upgrade_damage.png` | +Damage |
| `upgrade_fire_rate.png` | +Fire Rate |
| `upgrade_range.png` | +Range |
| `upgrade_armor.png` | +Armor |
| `upgrade_xp.png` | +XP Gain |
| `upgrade_reroll.png` | Reroll Draft |

### Meta UI (Tower Garage & Spell Codex)
| File | Size | Notes |
|------|------|-------|
| `ui_star_filled.png` | 32×32 px | Filled star for tower star rating |
| `ui_star_empty.png` | 32×32 px | Empty/greyed star |
| `ui_lock_icon.png` | 40×40 px | Shown over locked towers/spells |
| `ui_upgrade_button_bg.png` | 260×72 px | 9-slice button background |
| `ui_mat_chapter_icon.png` | 32×32 px | Chapter material icon |
| `ui_mat_universal_icon.png` | 32×32 px | Universal material icon (glowing gem) |
| `ui_garage_panel_bg.png` | 9-slice | Background panel for garage card |
| `ui_codex_panel_bg.png` | 9-slice | Background panel for spell codex entry |

### World Map
| File | Size | Notes |
|------|------|-------|
| `worldmap_bg.png` | 1080×1920 px | Stylized map background |
| `chapter_node_locked.png` | 80×80 px | Greyed chapter select node |
| `chapter_node_unlocked.png` | 80×80 px | Active chapter select node |
| `chapter_node_complete.png` | 80×80 px | Completed chapter (star overlay) |
| `chapter_path_line.png` | — | Line texture connecting chapter nodes |
| `ui_energy_icon.png` | 36×36 px | Lightning bolt icon for energy |

### Screens
| File | Size | Notes |
|------|------|-------|
| `screen_victory_bg.png` | 1080×1920 px | Victory screen background |
| `screen_defeat_bg.png` | 1080×1920 px | Defeat screen background |
| `ui_button_primary.png` | 9-slice | Main action button (Start, Try Again, etc.) |
| `ui_button_secondary.png` | 9-slice | Secondary action button (Return to Map, etc.) |
| `ui_panel_dark.png` | 9-slice | Dark semi-transparent panel for stat displays |

---

## 7. Environment / Arena Backgrounds

Each chapter needs its own arena background. The arena is always the same layout — only the visuals change.

| File | Chapter | Notes |
|------|---------|-------|
| `arena_ch1_plains.png` | Chapter 1 | Green grass, simple dirt path, border fence |
| `arena_ch2_frost.png` | Chapter 2 | Snow and ice ground, frozen border |
| `arena_ch3_volcanic.png` | Chapter 3 | Dark rock, glowing lava cracks |
| `arena_ch4_fortress.png` | Chapter 4 | Stone fortress floor, dark stone border |

Plus tilesets for ground variation within each chapter (64×64 px tiles, standard Godot TileSet format).

---

## 8. Fonts

| Font | Style | Usage |
|------|-------|-------|
| A bold display font (e.g. `Cinzel`, `Bebas Neue`) | Bold, slightly fantasy | Title screen, chapter names, level-up banner |
| A clean sans-serif (e.g. `Nunito`, `Roboto`) | Regular + Bold weights | Spell descriptions, card text, stats |
| A monospaced or pixel font (e.g. `Press Start 2P`, `Share Tech Mono`) | Bold | HUD numbers (HP, wave counter) |

All available free from Google Fonts. Import as `.ttf` into Godot.

---

## 9. Audio

### Music
| File | Length | Loop | Usage |
|------|--------|------|-------|
| `music_main_menu.ogg` | 2 min | Yes | World map / main menu |
| `music_ch1_wave.ogg` | 2.5 min | Yes | Chapter 1 wave combat |
| `music_ch2_wave.ogg` | 2.5 min | Yes | Chapter 2 wave combat |
| `music_ch3_wave.ogg` | 2.5 min | Yes | Chapter 3 wave combat |
| `music_ch4_wave.ogg` | 2.5 min | Yes | Chapter 4 wave combat |
| `music_boss.ogg` | 2 min | Yes | Boss wave (all chapters) |
| `music_draft.ogg` | 1.5 min | Yes | Draft/upgrade phase (calm) |
| `music_victory.ogg` | 20 sec | No | Victory stinger |
| `music_defeat.ogg` | 15 sec | No | Defeat stinger |

### SFX — Tower & Projectiles
| File | Notes |
|------|-------|
| `sfx_proj_bolt.wav` | Default tower shot |
| `sfx_proj_axe.wav` | Throwing axes whoosh |
| `sfx_proj_arrow.wav` | Arrow fire twang |
| `sfx_proj_fireball_launch.wav` | Fire whoosh |
| `sfx_proj_fireball_impact.wav` | Fire burst on hit |
| `sfx_proj_cannon.wav` | Heavy boom |
| `sfx_proj_chain_launch.wav` | Electric crackle start |
| `sfx_proj_chain_jump.wav` | Short electric snap per jump |
| `sfx_proj_needle.wav` | Sharp high-pitched zip |
| `sfx_proj_spear.wav` | Heavy whoosh |
| `sfx_proj_chaos.wav` | Dark distorted whoosh |
| `sfx_mine_place.wav` | Click/thud placement |
| `sfx_mine_trigger.wav` | Explosion |
| `sfx_zone_fire_loop.wav` | Looping fire crackle (Immolation aura) |
| `sfx_zone_blizzard_loop.wav` | Looping cold hiss |

### SFX — Enemies
| File | Notes |
|------|-------|
| `sfx_enemy_hit_light.wav` | Runner/flyer hit |
| `sfx_enemy_hit_heavy.wav` | Brute/elite hit |
| `sfx_enemy_death_small.wav` | Grunt/runner death |
| `sfx_enemy_death_large.wav` | Brute death |
| `sfx_enemy_death_flyer.wav` | Flyer death (distinct) |
| `sfx_boss_spawn.wav` | Boss entrance roar |
| `sfx_boss_phase.wav` | Boss phase change (brief silence then hit) |
| `sfx_boss_death.wav` | Boss death explosion |

### SFX — Tower
| File | Notes |
|------|-------|
| `sfx_tower_hit.wav` | Tower takes damage |
| `sfx_tower_low_hp_loop.wav` | Looping warning pulse at HP < 30% |
| `sfx_tower_heal.wav` | Regen tick |

### SFX — Draft & Synergies
| File | Notes |
|------|-------|
| `sfx_draft_open.wav` | Cards slide in |
| `sfx_card_select.wav` | Card picked |
| `sfx_card_hover.wav` | Subtle hover sound (optional) |
| `sfx_level_up.wav` | XP bar fills, level-up event |
| `sfx_synergy_unlock.wav` | Synergy threshold hit — satisfying chime/sting |
| `sfx_wave_start.wav` | Horn/bell at wave start |
| `sfx_wave_clear.wav` | Short clean chime |

### SFX — Meta UI
| File | Notes |
|------|-------|
| `sfx_upgrade_confirm.wav` | Tower star upgrade confirmed |
| `sfx_rank_up.wav` | Spell rank-up confirmed |
| `sfx_ui_button.wav` | Generic button tap |
| `sfx_ui_back.wav` | Back/cancel navigation |
| `sfx_unlock_tower.wav` | New tower unlocked |

---

## 10. Free Asset Sources

| Source | What to Grab |
|--------|-------------|
| [kenney.nl](https://kenney.nl) | UI kits, tower defense sprite packs, input prompts |
| [opengameart.org](https://opengameart.org) | Enemy sprites, tilesets, explosion sheets |
| [game-icons.net](https://game-icons.net) | Spell icons — massive free library, CC license |
| [itch.io free assets](https://itch.io/game-assets/free) | Pixel art packs, isometric tiles, SFX packs |
| [freesound.org](https://freesound.org) | SFX (filter by CC0 license) |
| [incompetech.com](https://incompetech.com) | Royalty-free music by Kevin MacLeod |
| [Google Fonts](https://fonts.google.com) | All fonts (OFL license, free for commercial use) |
| [Quaternius](https://quaternius.com) | Free low-poly 3D model packs for Blender rendering |
| [Sketchfab free](https://sketchfab.com/features/free-3d-models) | Free 3D models if going the render-to-sprite route |
