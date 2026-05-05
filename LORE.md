# Halendor — World Canon

This document is the source of truth for the in-game world. It is original
work — names, geography, factions, and creature designs are not derived from
any existing IP. Heroes-V-style structure is used as a *genre* template
(six factions, hero-led armies, town screens, week-of cycles), but every
proper name and lore beat in this file is original to the project.

The canon is also written so it can be lifted, sentence-by-sentence, into
prompts for image-generation tools. Each major entity has a "**Visual
prompt**" block that any AI image model can consume directly.

---

## 1. The world

**Halendor** is a continent split by the *Rift of Vesh* — a kilometre-deep
canyon cut by a falling star a thousand years before the campaign starts.
The star's fragments still pulse with raw cosmic light at the bottom of the
rift; from it leak the magical currents that all six civilisations harness
in their own way.

The age the campaign opens in is **the Long Dawn**: a generation of
prosperity after the Demon Wars. Borders are settled, harvests are heavy,
and the watchtowers have been quiet for nineteen years. The Long Dawn ends
in the prologue cinematic.

### Geography

- **Sunmarch** — the southern grass plains of the Dawn faction. White-walled
  fortresses, wheat fields, slow rivers, walled trade towns. Warm temperate.
- **The Cinderwastes** — a broken volcanic zone south of the rift, taken by
  Hell when it broke through nineteen years ago. Ash skies, basalt
  fortresses, lava rivers.
- **The Long Barrows** — a wind-bitten steppe in the central north covered
  in ten thousand burial mounds from a forgotten empire. Home of the
  Necropolis faction.
- **The Verdwall** — an immense old-growth forest along the eastern coast
  that the Sylvan elves have shaped for two thousand years.
- **Spire Reach** — a chain of towering stone mesas in the deep west where
  the Academy mages built their floating cities.
- **The Underveil** — vast cavern systems below Spire Reach, claimed by the
  Tenebra dark-elves and their drake allies.

### Calendar

The game tracks days, weeks (seven days), and months (four weeks). Every
week of the year carries a name that buffs a creature type for the week
("Week of the Griffin", "Week of the Lich"). This is identical to Heroes V
mechanically; only the week names are original.

---

## 2. The six factions

Each faction has: a name, a **brief lore sketch**, a **roster of seven
upgradeable creatures** (tier 1 → tier 7, each tier getting a base unit and
a stronger upgraded form), a **starting hero archetype**, and a
**visual-style guide** to keep generated art coherent across PRs.

### 2.1 Рассвет — *Dawn* (Light / Order)

**Lore.** A confederation of human kingdoms ruled from the white-stone
capital **Auralis** by a council of paladins. They worship **Solar**, the
distant star at the bottom of the Rift. Their magic is *radiance*: healing,
purification, blinding light. Their armies are disciplined infantry and
heavy cavalry stiffened by warrior-priests and griffins from the high
peaks.

**Visual style.**

> Polished silver plate armour with gold-trim filigree, royal blue cloth
> tabards bearing a stylised gold sun emblem, white capes. Cathedral
> architecture in white stone with stained-glass windows and gold spires.
> Warm sunrise lighting, cinematic composition, painterly digital art.

**Creatures (7 tiers, base / upgrade names):**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Pikeman | Halberdier |
| 2 | Crossbowman | Sharpshooter |
| 3 | Squire | Sentinel |
| 4 | Griffin | Royal Griffin |
| 5 | Monk | Zealot |
| 6 | Cavalier | Champion |
| 7 | Angel | Archangel |

**Starting hero of the campaign.**

- **Sir Artan Light-of-the-Hold** (Сэр Артан Свет в Холде). 25 years old,
  lord-elect of the small border keep **Watchstead** on the southern edge
  of the Cinderwastes. The campaign opens with Hell breaking the truce of
  the Long Dawn and burning Watchstead to the ground while Artan is in
  Auralis swearing his oath of office. The first mission is his march back
  to retake the keep.
- **Visual prompt** (Grok 2:3 Tall) — *already generated, see
  `assets/ai_generated/heroes/sir_artan_portrait.png`*:
  > Portrait of a young human knight, 25 years old, hero of the Dawn
  > faction in a high-fantasy world. Strong jaw, short dark hair, blue
  > eyes, determined gaze. Polished silver plate armour with gold trim,
  > royal blue cloth tabard with a gold sun emblem on the chest, white
  > cape with gold edge. Holding a longsword vertically in front of him,
  > hilt at chest height, blade pointing up. Behind him a soft golden
  > sunrise glow with god rays. Painterly fantasy art style, similar to
  > Heroes of Might and Magic V hero portraits or Diablo IV character
  > art. Professional digital painting, dramatic rim lighting, intricate
  > armour details, bust shot.

---

### 2.2 Геенна — *Gehenna* (Hell / Demons)

**Lore.** Demons broke through the Rift twenty years ago when a star
fragment cracked open. They built basalt fortresses on the Cinderwastes
and pushed back at every chance. Their society is a strict hierarchy of
masters and slaves bound by blood pacts. Magic is fire, fear and
contracts.

**Visual style.**

> Black basalt and red-iron architecture with rivers of lava. Demons in
> jagged spiked armour, charred horns, crimson and obsidian skin tones,
> glowing eyes. Cinder ash falling like snow. Dim red sky, rim-lit
> figures, painterly fantasy art.

**Creatures.**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Imp | Familiar |
| 2 | Cinder Hound | Cerberus |
| 3 | Ash Demon | Horned Demon |
| 4 | Pit Lord | Pit Fiend |
| 5 | Scorched Mage | Efreet |
| 6 | Nightmare | Hellsteed |
| 7 | Devil | Arch-Devil |

**Antagonist of the first campaign:** **Lord Vexhal the Cinder-Crowned** —
the demon prince who personally led the raid on Watchstead. Bald, charred
red skin, single curving horn, wears a half-cape of tanned demon-hide and
wields a flaming greatsword.

---

### 2.3 Курган — *Kurgan* (Necropolis / Undead)

**Lore.** The Long Barrows hold the dead of the Sundered Empire, an ancient
human kingdom that ruled before the Demon Wars. A century ago a council
of necromancers, the **Pale Synod**, learned to bind the empire's
mummified kings into service. Now Kurgan is a feudal nation of liches
ruling armies of the dead.

**Visual style.**

> Crumbling stone barrows, lich-towers of black obsidian and bone, ghostly
> green flame in iron braziers, full moons. Skeletons in tattered armour,
> liches in elaborate robes with bone crowns. Cold blue and sickly green
> palette, painterly digital art.

**Creatures.**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Skeleton | Skeleton Warrior |
| 2 | Walking Dead | Ghoul |
| 3 | Wight | Wraith |
| 4 | Vampire | Vampire Lord |
| 5 | Lich | Arch Lich |
| 6 | Bone Dragon | Spectral Dragon |
| 7 | Death Knight | Black Paladin |

---

### 2.4 Чащоба — *Chashchoba* (Sylvan / Forest)

**Lore.** Elves of the **Verdwall** have shaped the eastern forest for two
millennia. They live in cities woven from living trees, ride giant stags,
and trade peace for blood every century. Their magic is the green: growth,
binding, and the wrath of the wild.

**Visual style.**

> Tree-cities woven from living oaks and silvergrass, vine bridges,
> moss-covered stone paths. Elves in green and brown leather with silver
> filigree, longbows of pale wood. Dappled forest sunlight, painterly
> digital art, soft greens and warm golds.

**Creatures.**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Pixie | Sprite |
| 2 | Wood Elf Archer | Master Elf |
| 3 | Druid | Greater Druid |
| 4 | Stag Rider | Royal Stag Rider |
| 5 | Treant | Ancient Treant |
| 6 | Unicorn | War Unicorn |
| 7 | Green Dragon | Emerald Dragon |

---

### 2.5 Шпиль — *Shpil* (Academy / Mages)

**Lore.** The mage-cities of Spire Reach float above the western mesas on
chains of bound air-elementals. Their society is a meritocracy of
arcanists; titles and lands are won by demonstration of new spells. They
build constructs, ride djinn, and study the rift fragments directly.

**Visual style.**

> Floating crystalline cities on stone mesas, golden domes and turquoise
> roofs, elaborate clockwork, glowing runes etched into stone, towering
> stone golems and djinn. Bright sunlit palette, painterly digital art,
> ornate Persianate motifs (Heroes-V Academy aesthetic).

**Creatures.**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Gremlin | Master Gremlin |
| 2 | Stone Gargoyle | Obsidian Gargoyle |
| 3 | Iron Golem | Steel Golem |
| 4 | Mage | Arch-Mage |
| 5 | Djinn | Djinn Sultan |
| 6 | Rakshasa | Rakshasa Raja |
| 7 | Titan | Storm Titan |

---

### 2.6 Тенебра — *Tenebra* (Dungeon / Dark Elves)

**Lore.** Beneath Spire Reach the dark-elves rule the **Underveil**. They
broke from the surface elves a millennium ago over a question of blood
sacrifice. Their cities are carved from glowing black stone and lit by
phosphor moss and bound shadow-flame. Their magic is shadow, pain, and
binding.

**Visual style.**

> Vast cavern cities of black volcanic stone lit by purple phosphor and
> blue-flame braziers. Dark-elves with grey skin, white or red hair,
> intricate black armour with violet inlay, twin curved blades. Cool
> palette of black-violet-cyan, painterly digital art.

**Creatures.**

| Tier | Base | Upgrade |
|---|---|---|
| 1 | Troglodyte | Infernal Troglodyte |
| 2 | Harpy | Harpy Hag |
| 3 | Beholder | Evil Eye |
| 4 | Medusa | Medusa Queen |
| 5 | Minotaur | Minotaur King |
| 6 | Manticore | Scorpicore |
| 7 | Black Dragon | Red Dragon |

---

## 3. Campaign — *The Long Dawn Ends*

The launch campaign is **five missions** about Sir Artan reclaiming his
keep, then the south, then standing at the gates of Auralis when Lord
Vexhal marches on the capital.

| # | Title | Setup | Win condition |
|---|---|---|---|
| 1 | **The Burning of Watchstead** | Artan returns from his oath in Auralis to find Watchstead in ruins. He musters survivors from the southern villages. | Retake Watchstead castle from the demon garrison. |
| 2 | **The Bone Road** | Demons retreat north along the Bone Road (an old Kurgan trade route). Artan must catch their warlord. | Defeat the demon warlord on the road *and* secure two relic mines for resources. |
| 3 | **Allies of the Wild** | Artan learns the Verdwall elves are willing to march, but their queen demands a ritual debt repaid. | Complete a fetch quest for the elves and return with Sylvan reinforcements. |
| 4 | **The Pale Synod** | Kurgan necromancers offer help against Hell — at the price of a dark relic. Moral choice: take the deal or fight on alone. | Either accept the deal (gain undead unit hire) or refuse and survive a Synod assassination attempt. |
| 5 | **The Walls of Auralis** | Vexhal's full host marches on the capital. Artan defends the city. | Hold Auralis for fifteen turns, then defeat Vexhal in a final battle. |

The **first mission** is the vertical-slice scope of this project. The map
is small (40×40 tiles), one castle to retake, two resource piles, three
neutral monster stacks, one griffin lair to recruit, and Lord Vexhal's
warlord as a final boss. Sir Artan starts at level 1 with the army from
PR #1's `GameState.player_army`.

---

## 4. Asset prompt index

Promtps that have been used to generate art are recorded here for
reproducibility and so a different artist can pick up where Grok left off.

### Generated

| Asset | File | Prompt | Tool / ratio |
|---|---|---|---|
| Sir Artan portrait | `assets/ai_generated/heroes/sir_artan_portrait.png` | Section 2.1 above | Grok 2:3 Tall (720×1280) |
| Pikeman sprite | `assets/ai_generated/units/pikeman.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Crossbowman sprite | `assets/ai_generated/units/crossbowman.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Squire sprite | `assets/ai_generated/units/squire.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Griffin sprite | `assets/ai_generated/units/griffin.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Monk sprite | `assets/ai_generated/units/monk.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Cavalier sprite | `assets/ai_generated/units/cavalier.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Angel sprite | `assets/ai_generated/units/angel.png` | Section 2.1 + unit prefix | Grok 1:1 Square |
| Gold icon | `assets/ai_generated/icons/gold.png` | Resource-icon prefix + sun-stamped coin pile | Grok 1:1 Square |
| Wood icon | `assets/ai_generated/icons/wood.png` | Resource-icon prefix + chopped logs | Grok 1:1 Square |
| Ore icon | `assets/ai_generated/icons/ore.png` | Resource-icon prefix + iron ore chunks | Grok 1:1 Square |
| Crystal icon | `assets/ai_generated/icons/crystal.png` | Resource-icon prefix + glowing blue crystals | Grok 1:1 Square |
| Mercury icon | `assets/ai_generated/icons/mercury.png` | Resource-icon prefix + mercury chalice | Grok 1:1 Square |
| Sulfur icon | `assets/ai_generated/icons/sulfur.png` | Resource-icon prefix + sulfur crystals | Grok 1:1 Square |
| Gems icon | `assets/ai_generated/icons/gems.png` | Resource-icon prefix + multi-coloured cut stones | Grok 1:1 Square |
| Main menu backdrop | `assets/ai_generated/backdrops/main_menu.jpg` | Halendor castle at sunrise | Grok 16:9 Widescreen (1280×720) |
| Battlefield backdrop | `assets/ai_generated/backdrops/battlefield_grass.jpg` | Empty grassy meadow, isometric | Grok 16:9 Widescreen (1280×720) |

### To generate (queue)

| Asset | Prompt source | Target file | Grok ratio |
|---|---|---|---|
| Sir Artan world sprite | "Артан на карте" prompt block | `assets/ai_generated/heroes/sir_artan_world.png` | 1:1 Square |
| Spell icon: Bless | Section 4 spell-icon prefix | `assets/ai_generated/icons/spell_bless.png` | 1:1 Square |
| Spell icon: Haste | Section 4 spell-icon prefix | `assets/ai_generated/icons/spell_haste.png` | 1:1 Square |
| Spell icon: Slow | Section 4 spell-icon prefix | `assets/ai_generated/icons/spell_slow.png` | 1:1 Square |
| Spell icon: Fire Bolt | Section 4 spell-icon prefix | `assets/ai_generated/icons/spell_fire_bolt.png` | 1:1 Square |
| Lord Vexhal portrait | Section 2.2 antagonist | `assets/ai_generated/heroes/lord_vexhal_portrait.png` | 2:3 Tall |

Backgrounds in unit images are removed automatically by passing the raw
JPG/PNG through `rembg` (a one-shot Python script). Resource icons keep
their dark gradient background which blends well with the dark HUD bar.
Portraits and backdrops keep their painted backgrounds.

### Unit-prompt prefix

> Single character standing facing 3/4 forward, full body visible, idle
> combat stance, painterly digital art in Heroes of Might and Magic V
> style, dramatic lighting, plain neutral grey-blue background, intricate
> armour details, professional fantasy game art.

### Resource-icon prefix

> Single fantasy game resource icon, top-down 3/4 view, painterly style,
> dramatic lighting on dark transparent-style neutral background,
> professional game UI art, centered composition.
