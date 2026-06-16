# Tower's Last Stand — Meshy 3D Model Prompting Guide

## Art Style Goal

Target reference: **Archero Chapter 11** enemies and characters.
That means VERY cartoonish — exaggerated proportions, oversized heads, chunky bodies,
bright candy-like colors, zero realism. Every model in this game should look like it
belongs in the same world, whether it's a shadow tower or a fire goblin.

---

## How to Use an Image Reference in Meshy

Meshy lets you upload a reference image alongside your text prompt to lock in style.

**Do this every single time:**
1. Screenshot an Archero Chapter 11 enemy or character (any one — you just need the style).
2. In Meshy → **Text to 3D** → click the image upload slot.
3. Upload the Archero screenshot as the **style reference**.
4. Paste your prompt in the text field.
5. Generate.

The image reference anchors the cartoon level so the output does not drift toward
realistic or semi-realistic. Without it, Meshy tends to add more detail than you want.

---

## Hard Rules (Never Break These)

Before anything else — these two rules apply to every single model, no exceptions:

**1. Always LOW POLY.**
Meshy will try to add surface detail, realistic skin pores, fine fabric weave, stone
texture noise — reject all of that. If the output looks too detailed or too realistic,
regenerate and add `extremely low polygon count, flat color surfaces, no surface noise,
no fine texture detail` to the prompt. The model should look like it was built from
big smooth geometric blocks, not sculpted.

**2. Towers are fortresses, not spires.**
A single tall skinny tower looks like a stick from top-down and gives nothing to look
at. Every "tower" in this game should be a **compact fortified structure** — a small
castle, a chunky fortress compound, a squat battlement with a main body and some
surrounding detail. Wide enough to have a real footprint. Think chibi castle, not
chess rook.

**3. Cartoon inverted silhouette — narrow base, wide top.**
Classic cartoon exaggeration: the structure is **narrower at the bottom and wider
at the top**, like a cartoon mushroom or a top-heavy chibi character. The base/stem
is thin and the top mass flares out wider. This makes the model look fun, bouncy,
and clearly cartoon — not like a real building. Apply this to the overall fortress
shape AND to any towers or turrets sticking up from it.

---

## The Master Style Block

**Copy this exactly at the start of EVERY prompt. Never change it. Never shorten it.**

```
Highly stylized cartoon 3D mobile game asset, Archero art style,
extremely exaggerated chibi proportions, oversized round head, short chunky body,
extremely low polygon count, low-poly with smooth rounded surfaces,
flat color surfaces with no surface noise or fine texture detail,
cel shading, flat vibrant candy colors with soft inner gradients,
bold dark outlines, bright saturated palette, clean readable silhouette,
no realistic textures, no photorealism, no dark gritty realism,
soft warm ambient lighting, subtle colored rim light matching the theme,
no harsh shadows, bright cheery lighting overall
```

> **Why the lighting is in the block:** Archero uses a bright top-lit look with a soft
> colored rim — no moody shadows, no dramatic contrast. If you leave lighting out of
> the prompt, Meshy defaults to a neutral studio light that can make things look
> more realistic than wanted.

---

## Tower Prompt Template

```
[MASTER STYLE BLOCK], [THEME] cartoon defensive fortress, compact fortified
structure, narrow at the base and wider at the top like a cartoon mushroom shape,
top-heavy inverted silhouette, main central body flaring outward toward the top
with surrounding battlements, [THEME COLOR] color palette, [THEME-SPECIFIC VISUAL DETAILS],
no characters, no people, architectural game prop, viewed from slight top-down angle
```

### Chapter Towers

#### Chapter 1 — Iron / Stone (Starting Fortress)

```
[MASTER STYLE BLOCK], sturdy cartoon stone defensive fortress,
compact fortified structure, narrow at the base and wider at the top
like a cartoon mushroom shape, top-heavy inverted silhouette,
chunky main keep flaring outward at the top with short surrounding battlement walls,
warm grey and brown color palette, simple rounded medieval stone blocks,
small cute arrow slit windows, slight mossy patches, iron band trim on the gates,
looks reliable and starter-tier, no characters, no people, architectural game prop,
viewed from slight top-down angle
```

#### Chapter 2 — Ice Fortress

```
[MASTER STYLE BLOCK], frozen ice cartoon defensive fortress,
compact fortified structure, narrow at the base and wider at the top
like a cartoon mushroom shape, top-heavy inverted silhouette,
chunky main ice keep flaring outward at the top with short crystal surrounding walls,
pale blue and white color palette, glowing icy blue crystal formations growing
out of the walls and battlements, sharp angular ice shards on the rooftops,
soft inner blue glow, snowflake motifs on the walls, icicle trim dripping from edges,
cool blue rim light, no characters, no people, architectural game prop,
viewed from slight top-down angle
```

#### Chapter 3 — Fire Fortress

```
[MASTER STYLE BLOCK], volcanic fire cartoon defensive fortress,
compact fortified structure, narrow at the base and wider at the top
like a cartoon mushroom shape, top-heavy inverted silhouette,
chunky main keep flaring outward at the top with short surrounding lava walls,
deep red-black stone with glowing orange and yellow magma cracks running
across all walls, small cartoon flame puffs on the rooftop and battlements,
ember glow from window slits, lava pooling at the narrow base,
warm orange-red rim light, hot and ominous but cute and rounded,
no characters, no people, architectural game prop, viewed from slight top-down angle
```

#### Chapter 4 — Shadow Fortress (Chibi Sauron)

```
[MASTER STYLE BLOCK], chibi cartoon dark evil fortress inspired by Sauron's stronghold,
HIGHLY cartoonized and cute — not scary, compact fortified structure,
narrow at the base and wider at the top like a cartoon mushroom shape,
top-heavy inverted silhouette, main rounded dark keep flaring outward at the top
with short surrounding shadow walls, single giant oversized glowing orange cartoon eye
on the front of the main keep, black stone with dark purple magical glow and gold trim
accents on walls and gates, small swirling shadow wisps floating around the battlements,
cute evil aesthetic, purple-black rim light,
looks like a funny chibi villain fortress not a scary one,
no characters, no people, architectural game prop, viewed from slight top-down angle
```

---

## The 5 Evolution Stages

Every tower and every enemy has 5 evolutions — from the most bare-bones version
to the most elaborate and visually impressive. Think star upgrades: Evolution 1 is
what you start with, Evolution 5 is the max-level form.

Append the evolution block at the **very end** of the full prompt. Everything else
stays the same — only the evolution block changes between the 5 versions.

```
[MASTER STYLE BLOCK] + [ASSET DESCRIPTION] + [EVOLUTION BLOCK]
```

---

### Evolution 1 — Base Form

> Plain. No decoration, no glow, no effects. Just the recognizable shape in flat color.
> Looks like it just spawned with zero upgrades.

```
evolution stage 1 out of 5, base starter form, plain and completely undecorated,
basic shape with flat color only, zero glow effects, no ornaments, no particles,
no magical elements, no extra structures, looks unupgraded and default tier
```

---

### Evolution 2 — Awakening Form

> A little personality starting to show. Small trim, a faint hint of the theme color.
> Still simple but not completely plain.

```
evolution stage 2 out of 5, slightly upgraded form, small simple decorative trim added,
faint subtle hint of theme color and glow starting to emerge on edges,
one minor ornament or accent detail, slightly more polished than base form,
still fairly simple overall
```

---

### Evolution 3 — Empowered Form

> Clear visual identity established. Glows are visible, theme elements are prominent.
> This is the mid-tier look — recognizably upgraded but not yet over the top.

```
evolution stage 3 out of 5, empowered mid-tier form, theme fully visible and clear,
moderate glow effects on key structural areas, clear decorative elements and ornaments,
one or two signature theme details prominent, balanced between simple and complex,
noticeably upgraded but not overwhelming
```

---

### Evolution 4 — Exalted Form

> Strong and impressive. Intense glows, elaborate decorations, silhouette is richer
> with added structural elements. Clearly a high-power version.

```
evolution stage 4 out of 5, exalted high-tier form, intense glowing effects
on multiple areas of the structure, elaborate ornate decorations and intricate trim,
additional architectural or magical elements growing from the form,
more complex and layered silhouette, powerful and impressive, nearly max tier
```

---

### Evolution 5 — Ascended / Ultimate Form

> Maximum. Over-the-top cartoon extravagance. Multiple glow layers, floating elements
> orbiting the model, richest color palette, most elaborate silhouette. Should look
> like the legendary endgame version of itself.

```
evolution stage 5 out of 5, ultimate ascended max-level form, over-the-top cartoon
extravagance, multiple layers of intense glowing aura radiating from the structure,
small floating magical elements orbiting the model, richest most saturated version
of the theme color palette, most elaborate and complex silhouette with crown-like
or halo-like top elements, maximum decoration within the low-poly cartoon style,
looks legendary and final-form, awe-inspiring but still cute and cartoonish
```

---

### Full Example — Fire Fortress Evolution 3

```
Highly stylized cartoon 3D mobile game asset, Archero art style,
extremely exaggerated chibi proportions, oversized round head, short chunky body,
extremely low polygon count, low-poly with smooth rounded surfaces,
flat color surfaces with no surface noise or fine texture detail,
cel shading, flat vibrant candy colors with soft inner gradients,
bold dark outlines, bright saturated palette, clean readable silhouette,
no realistic textures, no photorealism, no dark gritty realism,
soft warm ambient lighting, subtle colored rim light matching the theme,
no harsh shadows, bright cheery lighting overall,
volcanic fire cartoon defensive fortress, compact fortified structure,
narrow at the base and wider at the top like a cartoon mushroom shape,
top-heavy inverted silhouette, chunky main keep flaring outward at the top
with short surrounding lava walls, deep red-black stone with glowing orange
and yellow magma cracks running across all walls, small cartoon flame puffs
on the rooftop and battlements, ember glow from window slits,
lava pooling at the narrow base, warm orange-red rim light,
hot and ominous but cute and rounded, no characters, no people,
architectural game prop, viewed from slight top-down angle,
evolution stage 3 out of 5, empowered mid-tier form, theme fully visible and clear,
moderate glow effects on key structural areas, clear decorative elements and ornaments,
one or two signature theme details prominent, balanced between simple and complex,
noticeably upgraded but not overwhelming
```

---

## Enemy Prompt Template

```
[MASTER STYLE BLOCK], [ENEMY TYPE] fantasy enemy creature for tower defense game,
[DESCRIPTION], [ARMOR AND COLOR DETAILS], T-pose or neutral idle stance,
full body visible from head to toe, no background, white or transparent background,
game-ready character asset
```

### Enemy Types

#### Grunt (basic soldier)

```
[MASTER STYLE BLOCK], grunt goblin soldier fantasy enemy creature for tower defense game,
small pudgy humanoid goblin, oversized round head, tiny body, simple dented leather
chest armor, small dull helmet tilted to one side, green-brown skin, holds a tiny club,
neutral idle stance, full body visible from head to toe, no background,
white background, game-ready character asset
```

#### Runner (fast scout)

```
[MASTER STYLE BLOCK], runner goblin scout fantasy enemy creature for tower defense game,
tiny lean goblin, oversized round head, big wide eyes, light cloth wrappings on arms,
no heavy armor, subtle yellow energy glow around feet suggesting speed,
bright lime green skin, exaggerated long legs relative to tiny torso,
neutral idle stance, full body visible from head to toe, no background,
white background, game-ready character asset
```

#### Brute (heavy tank)

```
[MASTER STYLE BLOCK], brute troll tank fantasy enemy creature for tower defense game,
massive hulking troll, extremely oversized wide body with tiny legs,
heavy grey iron plate armor with dents and scratches, huge round fists,
wide flat face with underbite, small squinting eyes, grey-green skin,
much larger than a normal enemy, neutral idle stance,
full body visible from head to toe, no background, white background,
game-ready character asset
```

#### Flyer (flying enemy)

```
[MASTER STYLE BLOCK], flyer imp flying fantasy enemy creature for tower defense game,
small winged imp, oversized round head, tiny round body, large expressive cartoon bat
wings proportionally huge compared to body, slightly off-ground hovering pose,
big bright purple-blue eyes, purple-blue skin, mischievous grin,
neutral hover idle stance, full body visible from head to toe, no background,
white background, game-ready character asset
```

#### Elite (armored champion)

```
[MASTER STYLE BLOCK], elite armored champion fantasy enemy creature for tower defense game,
humanoid knight enemy, oversized round helmet with a glowing visor slit,
ornate silver and gold plate armor with magical blue-white energy shield aura
glowing around the full body, imposing but still chibi proportions — big head
small body, short legs, neutral idle stance, full body visible from head to toe,
no background, white background, game-ready character asset
```

#### Boss — Chapter 1 (Plains Boss)

```
[MASTER STYLE BLOCK], massive goblin warlord boss fantasy enemy for tower defense game,
giant version of the grunt goblin but 3x the size, oversized round head with
a large crown or horned helmet, thick fur-trimmed armor, one giant club weapon,
green skin with war paint markings, much larger than all regular enemies,
intimidating but cute and cartoonish, neutral idle stance,
full body visible from head to toe, no background, white background,
game-ready character asset
```

#### Boss — Chapter 2 (Ice Boss)

```
[MASTER STYLE BLOCK], giant ice elemental boss fantasy enemy for tower defense game,
massive creature made of blue ice and snow, oversized round body, sharp crystal
spikes growing from shoulders, glowing pale blue eyes, icy crown on top,
cartoon snowflake patterns on its body, frost mist around feet,
cool blue glow overall, intimidating but cute and cartoonish, neutral idle stance,
full body visible from head to toe, no background, white background,
game-ready character asset
```

#### Boss — Chapter 3 (Fire Boss)

```
[MASTER STYLE BLOCK], giant fire demon boss fantasy enemy for tower defense game,
massive creature made of dark volcanic rock with glowing magma cracks,
oversized round head with a flaming mane, huge glowing orange eyes,
small cartoon flame puffs on shoulders and fists, lava dripping from body,
warm orange-red glow overall, intimidating but cute and cartoonish,
neutral idle stance, full body visible from head to toe, no background,
white background, game-ready character asset
```

#### Boss — Chapter 4 (Shadow Boss)

```
[MASTER STYLE BLOCK], giant shadow wraith boss fantasy enemy for tower defense game,
massive dark specter creature, oversized round head with a single huge glowing
orange eye in the center, tattered dark purple-black cloak or robe with gold trim,
shadowy wisps floating around the body, small cute ghost-like hands,
dark purple glow overall, looks like a mini chibi version of a dark lord,
intimidating but cartoonish and a bit goofy, neutral idle stance,
full body visible from head to toe, no background, white background,
game-ready character asset
```

---

## Quick Checklist Before Each Generate

- [ ] Image reference uploaded? (Archero Ch11 screenshot)
- [ ] Master Style Block pasted at the start? (includes low poly rule)
- [ ] Subject described clearly (what it IS and what CHAPTER/THEME)?
- [ ] Tower described as a fortress/compact structure, NOT a tall spire?
- [ ] Color palette mentioned?
- [ ] Evolution block appended at the end? (1 through 5)
- [ ] "No background / white background" included for enemies?
- [ ] "No characters / no people" included for towers?
- [ ] If result looks too detailed/realistic — regenerate and add: `extremely low polygon count, flat color surfaces, no surface noise, no fine texture detail`

---

## Common Meshy Settings

| Setting | Value |
|---------|-------|
| Mode | Text to 3D |
| Art Style | Cartoon (if Meshy has a style selector) |
| Topology | Low Poly |
| Texture Style | Cartoon / Stylized |
| Resolution | High (you will render to sprite anyway) |

---

## After You Get the Model

The pipeline for getting it into Godot:

1. Export from Meshy as `.glTF` or `.OBJ`.
2. Open in Blender.
3. Set orthographic camera at ~60° top-down (Archero angle).
4. Apply cel/flat shade material if Meshy texture needs cleanup.
5. Render frames at:
   - **Towers:** 160×160 px per frame
   - **Enemies:** 64–256 px per frame (see `assets.md` per enemy)
6. Pack into horizontal spritesheet PNG.
7. Drop into `res://assets/sprites/` using the filename from `assets.md`.
