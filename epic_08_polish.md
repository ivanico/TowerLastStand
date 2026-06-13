# Epic 08 — Polish, Performance & Export

> Prerequisite: Epics 01–07 complete and tested. The game must be fully playable with art and audio before this epic.
> Goal: Damage numbers, synergy banner animations, targeting indicator, performance optimizations, and a shippable Android APK.
> Completed epic delivers: a game ready for internal testing on a real Android device.

---

## Task 08-01 — Floating Damage Numbers

**File**: `res://scenes/ui/DamageNumber.tscn`
**Ref**: `mechanics.md` Section 10

- [ ] Create `DamageNumber.tscn` with root `Label`.
  - Font: monospaced pixel font, size 28.
  - Outline modulate: black, 1px.
  - `z_index = 100` (always on top).
  - No collision.
- [ ] Create `DamageNumber.gd`:
  - `func spawn(value: float, dtype: int, is_crit: bool, pos: Vector2)`:
    - Set `text = str(int(value))`.
    - Set `modulate = CombatUtils.get_damage_color(dtype)`.
    - If `is_crit`: scale to 1.4×, text prefix "★".
    - Set `global_position = pos + Vector2(randf_range(-20, 20), 0)`.  (slight horizontal scatter)
    - Create a Tween:
      - Move `global_position` up by 60px over 0.8 seconds.
      - Fade `modulate.a` from 1.0 to 0.0 over 0.8 seconds (start fade at 0.4s).
      - On complete: `queue_free()`.
- [ ] Implement object pooling for damage numbers: add to `ObjectPool` preload with count 40.
- [ ] In `EnemyBase.take_damage(amount, damage_type)`:
  - After computing final damage: get a `DamageNumber` from pool, call `spawn(final_damage, damage_type, is_crit, global_position + Vector2(0, -40))`.
  - Add to `VFXContainer` in GameWorld.
  - **Crit detection**: mark as crit if `final_damage > base_damage * 1.5` (synergy-boosted hits).
- [ ] Cap damage numbers: if more than 10 visible at once, skip spawning new ones until the oldest disappears.

---

## Task 08-02 — Synergy Banner Polish

**File**: `res://scenes/ui/SynergyBanner.tscn`, `SynergyBanner.gd`

The banner is already functional from Epic 03. Polish it here:

- [ ] Add slide-down from top animation using Tween:
  - Initial position: `Vector2(540, -80)` (off-screen top).
  - Tween to `Vector2(540, 80)` over 0.3 seconds (ease out).
  - Hold for 2.0 seconds.
  - Tween back to `Vector2(540, -80)` over 0.2 seconds (ease in).
- [ ] Add a brief screen flash on synergy unlock:
  - Instance a full-screen `ColorRect` (white, alpha=0.3) in `CanvasLayer`. Tween alpha 0.3 → 0 over 0.25 seconds. Then queue_free.
  - Only show the flash on ×5 synergies (not ×3).
- [ ] Ensure banner queues correctly: if a second synergy fires while the first banner is still showing, queue it and show after the first completes. Use an `Array` queue in `SynergyBanner.gd`.

---

## Task 08-03 — Enemy HP Bar Polish

**File**: `res://scenes/enemies/EnemyBase.tscn`

- [ ] Replace plain `ProgressBar` with a custom HP bar:
  - Root: `Node2D` positioned `-50` pixels above the enemy sprite center.
  - Background: `ColorRect` 60×8, color = `Color(0.2, 0.2, 0.2)`.
  - Fill: `ColorRect` same height, width driven by `(hp / base_hp) * 60.0`.
  - Fill color: green when > 50%, yellow when 25–50%, red when < 25%.
- [ ] In `take_damage()`: tween fill width smoothly over 0.15 seconds.
- [ ] Boss HP bar: 900×30px, anchored top-center of screen (in HUD, not above sprite). Tween on every hit.

---

## Task 08-04 — Targeting Indicator

**File**: `res://scenes/tower/TowerBase.gd`

- [ ] Add a faint targeting line from tower to current target enemy.
  - Use `Line2D` as a child of `TowerBase`. Width=2, color=`Color(1,1,1,0.15)`.
  - In `_physics_process(delta)`: if there is an active target, set `Line2D.points = [Vector2.ZERO, to_local(target.global_position)]`. Otherwise set `points = []`.
- [ ] This is intentionally subtle — just a faint hint of targeting direction.

---

## Task 08-05 — Screen Shake on Boss Hit

**File**: `res://scenes/main/GameWorld.gd`

- [ ] Add a `Camera2D` node as a child of GameWorld (centered, zoom=1.0).
- [ ] Implement `screen_shake(duration: float, magnitude: float)`:
  - Tween `Camera2D.offset` between random small vectors for `duration` seconds.
  - Tween magnitude back to zero at the end.
- [ ] Trigger mild shake (0.2s, 4px) on `EventBus.tower_damaged`.
- [ ] Trigger strong shake (0.4s, 12px) on `EventBus.boss_spawned` and each boss phase transition.

---

## Task 08-06 — Pause Menu

**File**: `res://scenes/ui/PauseMenu.tscn`

- [ ] Create `PauseMenu.tscn` with root `CanvasLayer`, layer=50.
- [ ] Add children:
  - `DimBG` (ColorRect) — full screen semi-transparent.
  - `Panel` (VBoxContainer, centered):
    - `TitleLabel` (Label) — "Paused".
    - `ResumeButton` (Button) — "Resume".
    - `RestartButton` (Button) — "Restart Run".
    - `MapButton` (Button) — "Return to Map".
    - `MusicSlider` (HSlider) — Music Volume.
    - `SFXSlider` (HSlider) — SFX Volume.
  - Hidden by default (`visible = false`).
- [ ] Create `PauseMenu.gd`:
  - `_ready()`: set slider values from `AudioManager` current volumes. Connect buttons and sliders.
  - On `ResumeButton.pressed`: hide menu, unpause tree.
  - On `RestartButton.pressed`: unpause, `MetaManager.spend_energy()` — NO deduct on restart (energy was already spent on run start). Reload scene.
  - On `MapButton.pressed`: unpause. `get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")`.
  - On `MusicSlider.value_changed(v)`: call `AudioManager.set_music_volume(v)`.
  - On `SFXSlider.value_changed(v)`: call `AudioManager.set_sfx_volume(v)`.
- [ ] In `GameWorld.gd`: handle Android back button / Escape key to toggle pause.
  - `_input(event)`: if `event.is_action_pressed("ui_cancel")`: toggle pause.
- [ ] In `GameWorld._ready()`: add PauseMenu instance to scene tree.

---

## Task 08-07 — Performance Pass

**Ref**: `project.md` Tech Stack, `mechanics.md` Section 3

Target: 60 fps stable on mid-range Android (Snapdragon 660 equivalent).

- [ ] **Enemy separation steering**: limit `_apply_separation()` to check only the 10 nearest enemies, not all active enemies. Use `WaveManager._active_enemies` with a distance pre-filter (skip any enemy > 80px away before the inner check).
- [ ] **Projectile physics**: ensure `ProjectileBase` uses `_physics_process` (not `_process`) for movement so it respects physics step. Verify pool correctly disables `CollisionShape2D.disabled = true` on release.
- [ ] **Object pool audit**: run the game for 5 waves. Check Godot profiler for orphan nodes. Confirm every `get()` is matched with a `release()`. Check for any remaining `queue_free()` calls on pooled nodes in the codebase (should be zero for projectiles and enemies).
- [ ] **Particle budget**: cap `GPUParticles2D` emission across all active VFX to 200 particles total. Add a global counter in a `VFXManager` singleton (lightweight — just an int that VFX nodes increment/decrement). If over budget: skip spawning low-priority effects (hit sparks) but always show death and level-up VFX.
- [ ] **Draw call reduction**: merge all small UI textures (tag icons, star icons, spell icons) into a single texture atlas using Godot's `ImportAtlas` tool. Verify fewer draw calls in the Remote Profiler during draft screen.
- [ ] **Wave fallback**: confirm the 30-second fallback timer from Epic 04 is working (prevents stalled waves on extreme builds).
- [ ] **Memory**: run the project through 3 full runs without restarting. Check Remote > Memory for any growing arrays or leaked scenes.

---

## Task 08-08 — Input Tuning for Mobile

**File**: Various scripts

- [ ] All `Button` nodes: set `minimum_size = Vector2(80, 80)` or larger for finger-friendly tap targets.
- [ ] Draft cards: set `PanelContainer.minimum_size = Vector2(260, 360)`. Ensure finger tap anywhere on the card (not just the button) triggers selection — use `_gui_input()` or a full-card Button.
- [ ] Disable any mouse-specific hover states (no tooltip on hover — mobile has no hover).
- [ ] Test on a 1080×1920 device (or emulator): confirm no UI elements are clipped off screen edges.
- [ ] Check for any `Input.is_action_pressed()` calls that should be `just_pressed()` for single-frame actions.

---

## Task 08-09 — Android Export Setup

**Ref**: `project.md` Tech Stack

- [ ] Install Android build template via Godot's Export menu (Editor > Export Template Manager).
- [ ] In Project > Export > Android: configure preset:
  - Package name: `com.yourname.towerslaststand`.
  - App name: `Tower's Last Stand`.
  - Min SDK: 24 (Android 7.0).
  - Target SDK: 34.
  - Orientation: Portrait.
  - Graphics API: OpenGL ES 3.0 (matches Compatibility renderer).
  - Internet permission: OFF (no network required for v1).
  - Vibrate permission: ON (optional — for haptic feedback stub).
- [ ] Configure signing:
  - Generate a debug keystore via `keytool` for testing builds.
  - Document the command used (store in a `BUILD_NOTES.md` at project root).
- [ ] Set app icon: use a 512×512 PNG placeholder (solid color with game initials for now — real icon in a hotfix after Epic 08).
- [ ] Export a debug APK. Install on a real device or Android emulator.

---

## Task 08-10 — Final Integration Test (Device)

Run ALL of the following on a real Android device or Godot's Android emulator:

- [ ] Full run from WorldMap → wave 1 → wave 20 → boss → VictoryScreen → WorldMap. No crashes.
- [ ] Defeat run: play until tower dies → DefeatScreen → retry → back to WorldMap. No crashes.
- [ ] Draft picks: pick 5+ cards in one run. Synergy banner fires. No visual glitches.
- [ ] Pause menu: open and close mid-wave. Enemies resume correctly. Volume sliders work.
- [ ] Tower Garage: upgrade Ironclad to Star 2. Return to game. Confirm higher HP.
- [ ] Spell Codex: rank up one spell. Start run. Confirm ranked-up spell shows improved stats in draft.
- [ ] Confirm save/load: kill the app mid-run (not mid-wave). Reopen. Should return to WorldMap with previous tower star and materials intact (runs don't save mid-wave by design — that's expected).
- [ ] Performance: maintain 60 fps during wave 10 with 12+ enemies and multiple spells firing. Check with Godot's in-editor profiler OR Android Studio GPU profiler.
- [ ] No logcat crashes on Android. Run `adb logcat | grep -i godot` while playing to check.
- [ ] Touch targets: all buttons responsive on first tap with normal adult finger.
- [ ] Fix any remaining issues. Tag the git commit as `v0.1-internal`.
