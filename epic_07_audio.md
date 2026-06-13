# Epic 07 — Audio

> Prerequisite: Epic 06 complete and tested.
> Goal: Every combat event, UI action, and scene transition has the correct sound effect. Music plays and crossfades between states. AudioManager handles all playback.
> Completed epic delivers: the game sounds like a finished product with no silent events.

---

## Task 07-01 — Import All Audio Files

**Ref**: `assets.md` Section 9

- [ ] Place all `.ogg` and `.wav` files in `res://assets/audio/` with exact filenames from `assets.md`.
- [ ] Import settings for **music** (`.ogg`): Loop = true (except stingers: `music_victory.ogg`, `music_defeat.ogg`). Compress = Vorbis.
- [ ] Import settings for **SFX** (`.wav`): Loop = false. Compress = IMA ADPCM (for mobile performance).
- [ ] Verify all files import without errors in Godot's FileSystem panel.

---

## Task 07-02 — AudioManager Full Implementation

**File**: `res://autoloads/AudioManager.gd`
**Ref**: `components.md` Section 3

Replace the Epic 01 stub:

- [ ] Add vars:
  ```gdscript
  var _sfx_pool: Array[AudioStreamPlayer]   # 12 pooled SFX players
  var _music_player_a: AudioStreamPlayer    # crossfade player A
  var _music_player_b: AudioStreamPlayer    # crossfade player B
  var _active_music_player: AudioStreamPlayer
  var _music_volume_db: float = 0.0
  var _sfx_volume_db: float = 0.0
  var _current_track: AudioStream = null
  var _preloaded_sfx: Dictionary            # { filename: AudioStream }
  ```
- [ ] In `_ready()`:
  - Create `_music_player_a` and `_music_player_b` as child `AudioStreamPlayer` nodes. Assign bus "Music".
  - Create 12 `AudioStreamPlayer` nodes for SFX pool. Assign bus "SFX". Add to `_sfx_pool`.
  - Set `_active_music_player = _music_player_a`.
  - Preload all SFX listed in `assets.md` Section 9 into `_preloaded_sfx`.
  - Connect `EventBus` signals to audio handlers (see Task 07-03).
- [ ] Implement `play_sfx(filename: String, pitch_scale: float = 1.0)`:
  - Get an idle player from `_sfx_pool` (one where `!is_playing()`). If all busy: skip playback.
  - Set `player.stream = _preloaded_sfx.get(filename)`. Set `player.pitch_scale = pitch_scale`.
  - Set `player.volume_db = _sfx_volume_db`. Call `player.play()`.
- [ ] Implement `play_music(stream: AudioStream, crossfade_time: float = 1.0)`:
  - If `stream == _current_track`: return (already playing).
  - Set `_current_track = stream`.
  - Set the *inactive* player's stream to `stream`. Set volume to `-80.0 db`. Call `play()`.
  - Tween: fade active player volume to `-80.0 db`, fade inactive player to `_music_volume_db`, over `crossfade_time` seconds.
  - On tween complete: swap `_active_music_player`. Stop the now-inactive player.
- [ ] Implement `stop_music(fade_time: float = 1.0)`: Tween active player volume to `-80.0 db`, then stop.
- [ ] Implement `set_music_volume(linear: float)`: `_music_volume_db = linear_to_db(linear)`. Update active player.
- [ ] Implement `set_sfx_volume(linear: float)`: `_sfx_volume_db = linear_to_db(linear)`. Values persist to MetaManager (add `music_volume: float` and `sfx_volume: float` to `SaveData`).

---

## Task 07-03 — Wire Combat SFX via EventBus

**File**: `res://autoloads/AudioManager.gd`

Connect EventBus signals in `_ready()` and implement handlers:

- [ ] `EventBus.wave_started` → `play_sfx("sfx_wave_start.wav")`.
- [ ] `EventBus.wave_cleared` → `play_sfx("sfx_wave_clear.wav")`.
- [ ] `EventBus.level_up` → `play_sfx("sfx_level_up.wav")`.
- [ ] `EventBus.synergy_threshold_reached` → `play_sfx("sfx_synergy_unlock.wav")`.
- [ ] `EventBus.boss_spawned` → `play_sfx("sfx_boss_spawn.wav")`. Also crossfade to `music_boss.ogg`.
- [ ] `EventBus.boss_died` → `play_sfx("sfx_boss_death.wav")`.
- [ ] `EventBus.tower_damaged` → `play_sfx("sfx_tower_hit.wav")`. If `GameState.tower_hp < GameState.tower_max_hp * 0.3` and low-HP loop not already playing: start `sfx_tower_low_hp_loop.wav` looping on a dedicated player (not from pool). Stop it when HP goes above 30% or tower dies.
- [ ] `EventBus.tower_healed` → `play_sfx("sfx_tower_heal.wav")`.
- [ ] `EventBus.tower_died` → stop all music immediately. Play `sfx_boss_spawn.wav` (dramatic hit). AudioManager does not trigger scene change — that stays in GameWorld.
- [ ] `EventBus.draft_opened` → `play_sfx("sfx_draft_open.wav")`. Crossfade music to `music_draft.ogg`.
- [ ] `EventBus.draft_closed` → crossfade back to the wave music track for the current chapter.
- [ ] `EventBus.card_selected` → `play_sfx("sfx_card_select.wav")`.

---

## Task 07-04 — Wire Projectile SFX in TowerBase

**File**: `res://scenes/tower/TowerBase.gd`

- [ ] In `_fire_projectile(spell)`: call `AudioManager.play_sfx()` with the correct SFX based on `spell.damage_type`:
  - NORMAL → `sfx_proj_bolt.wav`.
  - PIERCING → `sfx_proj_arrow.wav`.
  - MAGIC → `sfx_proj_fireball_launch.wav`.
  - SIEGE → `sfx_proj_cannon.wav`.
  - CHAOS → `sfx_proj_chaos.wav`.
- [ ] Add slight pitch randomization per shot: `pitch_scale = randf_range(0.9, 1.1)` to prevent repetitive sound.
- [ ] For chain spells: play `sfx_proj_chain_launch.wav` on fire. In `ProjectileBase` chain jump logic: play `sfx_proj_chain_jump.wav` on each jump.

---

## Task 07-05 — Wire Enemy Hit & Death SFX in EnemyBase

**File**: `res://scenes/enemies/EnemyBase.gd`

- [ ] In `take_damage()`: call `AudioManager.play_sfx()` based on `armor_type`:
  - LIGHT or UNARMORED → `sfx_enemy_hit_light.wav`.
  - MEDIUM, HEAVY → `sfx_enemy_hit_heavy.wav`.
  - Add pitch variance: `randf_range(0.85, 1.15)`.
- [ ] In `die()`: call `AudioManager.play_sfx()` based on `enemy_type`:
  - GRUNT, RUNNER → `sfx_enemy_death_small.wav`.
  - BRUTE → `sfx_enemy_death_large.wav`.
  - FLYER → `sfx_enemy_death_flyer.wav`.
- [ ] Boss SFX are handled by `EnemyBoss.gd` directly — no base class handling needed.

---

## Task 07-06 — Music State Machine

**File**: `res://autoloads/AudioManager.gd`

- [ ] Preload all chapter music and draft music in `_ready()` (or lazy-load on first play).
- [ ] Implement `play_chapter_music(chapter_id: int)`:
  - Map chapter ID to track: `{ 1: music_ch1_wave, 2: music_ch2_wave, ... }`.
  - Call `play_music(track)`.
- [ ] Wire to `EventBus.wave_started`:
  - If not boss wave: call `play_chapter_music(1)` (hardcoded Chapter 1 for now; extend in Epic 05 when chapter config is wired).
- [ ] Wire to `EventBus.phase_changed`:
  - `DRAFT` → crossfade to `music_draft.ogg`.
  - `WAVE` → crossfade back to chapter music.
  - `BOSS` → crossfade to `music_boss.ogg` (already done in task 07-03 via boss_spawned).
- [ ] Wire to `EventBus.run_ended`:
  - If `victory`: play `music_victory.ogg` (no loop, one-shot).
  - If defeat: play `music_defeat.ogg` (no loop, one-shot).

---

## Task 07-07 — UI & Meta SFX

**File**: `res://scenes/main/WorldMap.gd`, `TowerGarage.gd`, `SpellCodex.gd`

- [ ] Every Button's `pressed` signal: call `AudioManager.play_sfx("sfx_ui_button.wav")`.
- [ ] Back buttons: `play_sfx("sfx_ui_back.wav")`.
- [ ] `MetaManager.upgrade_tower_star()` success: `play_sfx("sfx_upgrade_confirm.wav")`.
- [ ] `MetaManager.upgrade_spell_rank()` success: `play_sfx("sfx_rank_up.wav")`.
- [ ] Tower unlock (future — stub the call for now): `play_sfx("sfx_unlock_tower.wav")`.
- [ ] WorldMap music: play `music_main_menu.ogg` in `WorldMap._ready()`.

---

## Task 07-08 — Audio Bus Setup in Godot

- [ ] In Project > Audio > Buses: create two additional buses named exactly `"Music"` and `"SFX"` as children of `Master`.
- [ ] Set `Master` bus volume to 0 db.
- [ ] Set `Music` and `SFX` bus volumes to 0 db by default.
- [ ] Add `AudioEffectLimiter` to `Master` bus to prevent clipping.
- [ ] Add `AudioEffectCompressor` to `SFX` bus (gentle compression: threshold=-12, ratio=3:1) to prevent SFX from peaking.
- [ ] Do NOT add reverb or delay effects — mobile performance impact is too high.

---

## Task 07-09 — Volume Settings (Future Settings Screen Stub)

**File**: `res://autoloads/AudioManager.gd`

- [ ] Store `music_volume_linear` and `sfx_volume_linear` (0.0–1.0) in `SaveData` (add fields if not already present).
- [ ] On `_ready()`, load saved volumes and apply via `set_music_volume()` and `set_sfx_volume()`.
- [ ] Expose `set_music_volume(v)` and `set_sfx_volume(v)` as public methods for a future Settings screen.
- [ ] Default both to 0.8 if no save exists.

---

## Task 07-10 — Integration Test

- [ ] Run the project. Verify:
  - Wave start plays horn SFX.
  - Tower fires a different SFX for each damage type (Normal bolt vs Siege cannon vs Magic fireball).
  - Enemies play hit sounds on damage (lighter sound for Runners, heavier for Brutes).
  - Enemies play distinct death sounds by type.
  - Boss entrance plays a loud stab SFX and music crossfades to boss track.
  - Draft opening crossfades to calm draft music. Card pick plays click SFX. Combat music resumes on close.
  - Level-up chime plays correctly.
  - Synergy unlock plays a distinct satisfying chime.
  - Tower low-HP loop starts when tower drops below 30% and stops when healed above 30%.
  - UI buttons all play a click sound.
  - Garage upgrades play upgrade confirm SFX.
  - Victory screen plays victory stinger (no loop). Defeat screen plays defeat stinger.
- [ ] Confirm no audio players accumulate — SFX pool of 12 never overflows (check with rapid enemy kills).
- [ ] Adjust volume levels so SFX are never louder than music.
- [ ] Fix all audio issues before moving to Epic 08.
