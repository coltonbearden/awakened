# Awakened — Brand Kit (v1, SPEC v2.20 / D-29)

**Concept:** Redline. **Tagline:** Set in ink. Runs at redline. **Axis:** restrained / contemporary print-modern /
typographic-structured. **Primary hue:** crimson. **Frame:** editorial print. **Status:** the ratified identity — every
value below is final and is the source of truth for every asset in this directory and every palette under
`plugins/aura/palettes/`. HEX is canonical; RGB and HSL are derived.

Lineage: curated from an internal tournament of thirty-five brand-kit concepts and their scored evaluation. No single
concept was adopted; the components below were chosen across the set and the mark is new. Original work, no upstream
repository lineage (`SOURCES.md`). Generative-image prompts are deliberately absent: every asset here is a
deterministic vector.

## 1. Concept

### 1.1 Name and philosophy

**Redline.** Two meanings, one word: the editor's red pen that strikes every unnecessary line, and the last zone on a
tachometer where the engine gives everything. Every component in this marketplace was redlined (edited down) so it can
be redlined (pushed to the limit). The awakening is not an explosion; it is a system becoming legible. Restraint is
total until the needle sweeps.

### 1.2 Visual theme

Contemporary print-modernism in dark ink: typography does the work; hairline rules structure every surface; crimson
appears as marks in the margin — an underline, a caret, the segment past the last tick. Zero decoration. Light appears
only where something changed state.

### 1.3 Voice

| Attribute | We say | We never say |
|---|---|---|
| Exact | "322 matrix rows: 96 shortlist, 211 reject, 15 merge, 0 defer. The log is in `eval/`." | "Massively slimmed down!" |
| Blunt | "No daemons. No telemetry. No exceptions." | "We take your privacy very seriously." |
| Dry | "Markdown and JSON. Nothing runs until you invoke it." | "Powered by cutting-edge AI infrastructure." |
| Unhurried | "Read the source first. We'll wait." | "Get started in seconds!!!" |
| Technically warm | "If it breaks, open an issue — we read all of them." | "Contact our support team for assistance." |

Receipts, not adjectives: a number comes with the file it came from. Deletion is stated as deletion. Anime energy
lives in names and geometry only — never in imagery (`SPEC.md` §7).

### 1.4 First-encounter story

Ten repositories went in. Nine plugins came out. Nothing extra survived.

## 2. Colour System

### 2.1 Dark mode (primary)

| Role | Hex | RGB | HSL |
|---|---|---|---|
| Background | `#100E0C` | 16, 14, 12 | 30°, 14%, 5% |
| Surface (elevated) | `#1B1815` | 27, 24, 21 | 30°, 12%, 9% |
| Border | `#2A2620` | 42, 38, 32 | 36°, 14%, 15% |
| Text | `#F4F0E8` | 244, 240, 232 | 40°, 35%, 93% |
| Text (muted) | `#A79F91` | 167, 159, 145 | 38°, 11%, 61% |
| Primary (crimson) | `#FF544E` | 255, 84, 78 | 2°, 100%, 65% |
| On-primary | `#100E0C` | 16, 14, 12 | 30°, 14%, 5% |
| Secondary (graphite) | `#8C857A` | 140, 133, 122 | 37°, 7%, 51% |
| Accent (non-photo blue) | `#93C6F2` | 147, 198, 242 | 208°, 79%, 76% |
| Success | `#4CC38A` | 76, 195, 138 | 151°, 50%, 53% |
| Warning | `#E8B644` | 232, 182, 68 | 42°, 78%, 59% |
| Error | `#FF8577` | 255, 133, 119 | 6°, 100%, 73% |
| Info | `#619DE0` | 97, 157, 224 | 212°, 67%, 63% |

Primary and Error share the red family on purpose — red is this brand's ink. They are separated by value and
temperature, and the rule in §2.3 keeps colour from ever being the sole carrier.

### 2.2 Light mode — "proof paper" (complete)

| Role | Hex | RGB | HSL |
|---|---|---|---|
| Background | `#F8F4EC` | 248, 244, 236 | 40°, 46%, 95% |
| Surface (elevated) | `#FFFDF8` | 255, 253, 248 | 43°, 100%, 99% |
| Border | `#DFD6C6` | 223, 214, 198 | 38°, 28%, 83% |
| Text | `#171310` | 23, 19, 16 | 26°, 18%, 8% |
| Text (muted) | `#5A5344` | 90, 83, 68 | 41°, 14%, 31% |
| Primary (crimson) | `#C21F2C` | 194, 31, 44 | 355°, 72%, 44% |
| On-primary | `#FFFFFF` | 255, 255, 255 | 0°, 0%, 100% |
| Secondary | `#4A443C` | 74, 68, 60 | 34°, 10%, 26% |
| Accent | `#2F6FA8` | 47, 111, 168 | 208°, 56%, 42% |
| Success | `#1E7A4C` | 30, 122, 76 | 150°, 61%, 30% |
| Warning | `#7C5A00` | 124, 90, 0 | 44°, 100%, 24% |
| Error | `#C0365B` | 192, 54, 91 | 344°, 56%, 48% |
| Info | `#2059A8` | 32, 89, 168 | 215°, 68%, 39% |

### 2.3 Usage rules

- **Crimson is a mark, not a paint.** Underlines, the active rule, the single main action, the segment past the
  threshold. It never fills an area larger than a button and never sits behind text.
- **Light has a job.** Nothing glows that isn't working: emphasis appears only where state changed (a crossing, a
  focus, a diff). Secondary graphite carries structure — rules, table borders, inactive states. Accent is the
  non-photo blue of print production: annotations, footnote links, diff context only.
- **Marketing is typography.** Compositions are background + text + one crimson mark. No photography, no
  illustration, no gradient fields.
- **Terminal.** Success / Warning / Error / Info map to pass / flaky / fail / notice. Primary is the cursor and a
  statusline's redline segment. Every semantic state carries a glyph (`✓ ! ✕ i`); colour is never the sole signal
  (WCAG 1.4.1). Error is prefixed `✕`; brand crimson never appears inline inside diagnostic output.

### 2.4 Contrast (WCAG 2.1 relative luminance; text ≥ 4.5:1, UI components ≥ 3:1)

| Pairing | Dark: vs bg / vs surface | Light: vs bg / vs surface | Result |
|---|---|---|---|
| Text | 16.95 / 15.55 | 16.84 / 18.17 | PASS |
| Text (muted) | 7.35 / 6.74 | 6.95 / 7.50 | PASS |
| Primary as text or link | 6.08 / 5.58 | 5.43 / 5.86 | PASS |
| On-primary label on Primary fill | 6.08 | 5.96 | PASS |
| Secondary (UI component) | 5.28 / 4.84 | 8.77 / 9.46 | PASS |
| Accent (UI component) | 10.64 / 9.76 | 4.83 / 5.22 | PASS |
| Success | 8.70 / 7.98 | 4.85 / 5.24 | PASS |
| Warning | 10.28 / 9.43 | 5.77 / 6.22 | PASS |
| Error | 8.14 / 7.47 | 4.88 / 5.27 | PASS |
| Info | 6.79 / 6.23 | 6.26 / 6.76 | PASS |

Minimum pair in the system: 4.83:1 (light accent as a UI component; 3:1 required). Minimum text pair: 5.43:1.

### 2.5 CSS custom properties

```css
:root,
:root[data-theme="dark"] {
  --awakened-bg: #100E0C;
  --awakened-surface: #1B1815;
  --awakened-border: #2A2620;
  --awakened-text: #F4F0E8;
  --awakened-text-muted: #A79F91;
  --awakened-primary: #FF544E;
  --awakened-on-primary: #100E0C;
  --awakened-secondary: #8C857A;
  --awakened-accent: #93C6F2;
  --awakened-success: #4CC38A;
  --awakened-warning: #E8B644;
  --awakened-error: #FF8577;
  --awakened-info: #619DE0;
}

:root[data-theme="light"] {
  --awakened-bg: #F8F4EC;
  --awakened-surface: #FFFDF8;
  --awakened-border: #DFD6C6;
  --awakened-text: #171310;
  --awakened-text-muted: #5A5344;
  --awakened-primary: #C21F2C;
  --awakened-on-primary: #FFFFFF;
  --awakened-secondary: #4A443C;
  --awakened-accent: #2F6FA8;
  --awakened-success: #1E7A4C;
  --awakened-warning: #7C5A00;
  --awakened-error: #C0365B;
  --awakened-info: #2059A8;
}
```

### 2.6 The brand terminal palette — `getsuga-tensho`

Shipped verbatim as `plugins/aura/palettes/getsuga-tensho.json` (Windows Terminal scheme shape). Contrast is
against the background `#100E0C`.

| Slot | Hex | vs bg | Slot | Hex | vs bg |
|---|---|---|---|---|---|
| black | `#262019` | 1.20 | brightBlack | `#6B6355` | 3.25 |
| red | `#FF544E` | 6.08 | brightRed | `#FF8B84` | 8.51 |
| green | `#4CC38A` | 8.70 | brightGreen | `#8FDDB6` | 12.10 |
| yellow | `#E8B644` | 10.28 | brightYellow | `#F3D289` | 13.20 |
| blue | `#619DE0` | 6.79 | brightBlue | `#9CC5F0` | 10.69 |
| purple | `#C583B9` | 6.72 | brightPurple | `#DFB1D6` | 10.45 |
| cyan | `#63BFB7` | 8.87 | brightCyan | `#9CDCD6` | 12.50 |
| white | `#E9E2D4` | 14.95 | brightWhite | `#F8F4EC` | 17.56 |

Foreground `#F4F0E8` (16.95), background `#100E0C`, cursor `#FF544E`, selection `#33241E`. Slots `black` and
`brightBlack` are background-tier by ANSI convention (dim panels, comments) and are held to 3:1, not 4.5:1.

### 2.7 The six `aura` palettes — one discipline, six transformations

Base form is the ink; the preset is the transformation. Every palette keeps the same rules: a near-black (or, for
`gear-fifth`, proof-paper) field, a paper foreground, semantic slots that stay legible, and one signal hue that moves.
Every text slot measures ≥ 4.5:1 against its background and `brightBlack` ≥ 3:1; the tables below are computed from
the shipped files and are regenerated with them.

**`getsuga-tensho`** — the brand ink — crimson on warm black. Background `#100E0C`, foreground `#F4F0E8` (16.95:1), cursor `#FF544E` (6.08:1), selection `#33241E`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#262019` | 1.20:1 | `#6B6355` | 3.25:1 |
| red | `#FF544E` | 6.08:1 | `#FF8B84` | 8.51:1 |
| green | `#4CC38A` | 8.70:1 | `#8FDDB6` | 12.10:1 |
| yellow | `#E8B644` | 10.28:1 | `#F3D289` | 13.20:1 |
| blue | `#619DE0` | 6.79:1 | `#9CC5F0` | 10.69:1 |
| purple | `#C583B9` | 6.72:1 | `#DFB1D6` | 10.45:1 |
| cyan | `#63BFB7` | 8.87:1 | `#9CDCD6` | 12.50:1 |
| white | `#E9E2D4` | 14.95:1 | `#F8F4EC` | 17.56:1 |

**`final-flash`** — gold energy on amber-black. Background `#0E0B05`, foreground `#FFF4DE` (18.01:1), cursor `#FFC531` (12.43:1), selection `#33280E`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#2A2110` | 1.24:1 | `#7A6A4A` | 3.73:1 |
| red | `#FF6E62` | 7.17:1 | `#FF9A90` | 9.62:1 |
| green | `#5BCB8E` | 9.71:1 | `#96E1B8` | 12.87:1 |
| yellow | `#FFC531` | 12.43:1 | `#FFE08A` | 15.23:1 |
| blue | `#6FA8E8` | 7.90:1 | `#A3CCF3` | 11.69:1 |
| purple | `#CC8FBE` | 7.71:1 | `#E2B8D8` | 11.30:1 |
| cyan | `#67C4B8` | 9.51:1 | `#A0DFD6` | 13.12:1 |
| white | `#EDE3CF` | 15.43:1 | `#FFF9EE` | 18.75:1 |

**`six-eyes`** — cyan and limitless blue on blue-black. Background `#05080C`, foreground `#E8F2F7` (17.65:1), cursor `#35E1FF` (12.77:1), selection `#143544`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#131C24` | 1.17:1 | `#5A7089` | 3.93:1 |
| red | `#FF5C5C` | 6.63:1 | `#FF9090` | 9.22:1 |
| green | `#3DDC97` | 11.35:1 | `#86EDC2` | 14.24:1 |
| yellow | `#FFC145` | 12.39:1 | `#FFD98A` | 14.85:1 |
| blue | `#57A6FF` | 7.93:1 | `#93C7FF` | 11.33:1 |
| purple | `#B48CFF` | 7.77:1 | `#D2BAFF` | 11.67:1 |
| cyan | `#35E1FF` | 12.77:1 | `#8DEFFF` | 15.22:1 |
| white | `#D7E5EC` | 15.58:1 | `#F4FAFD` | 19.05:1 |

**`domain-expansion`** — deep void, violet and barrier cyan. Background `#0A0714`, foreground `#EEE9FA` (16.78:1), cursor `#A07CFF` (6.48:1), selection `#2A2050`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#1B1530` | 1.14:1 | `#6E6299` | 3.67:1 |
| red | `#FF5C7C` | 6.72:1 | `#FF93A9` | 9.49:1 |
| green | `#43E5A0` | 12.30:1 | `#8CF1C6` | 14.73:1 |
| yellow | `#FFC24B` | 12.41:1 | `#FFDA93` | 14.91:1 |
| blue | `#6FA8FF` | 8.28:1 | `#A6C9FF` | 11.79:1 |
| purple | `#A07CFF` | 6.48:1 | `#C9B3FF` | 10.80:1 |
| cyan | `#5CD6E8` | 11.62:1 | `#9AE7F1` | 14.31:1 |
| white | `#DDD6EE` | 14.17:1 | `#F4F1FB` | 17.87:1 |

**`ultra-instinct`** — silver base, electric-blue accents, graphite. Background `#0B0C0F`, foreground `#E4E7EC` (15.78:1), cursor `#4D8DFF` (6.12:1), selection `#1E2A3D`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#1C1F26` | 1.19:1 | `#737A87` | 4.53:1 |
| red | `#FF6B6B` | 7.05:1 | `#FF9B9B` | 9.70:1 |
| green | `#5CC49A` | 9.14:1 | `#94DDBF` | 12.44:1 |
| yellow | `#E3B95A` | 10.57:1 | `#F0D394` | 13.46:1 |
| blue | `#4D8DFF` | 6.12:1 | `#8AB6FF` | 9.51:1 |
| purple | `#B39DDB` | 8.16:1 | `#D2C3EE` | 11.90:1 |
| cyan | `#7DD3E8` | 11.51:1 | `#AEE5F2` | 14.24:1 |
| white | `#C9CED6` | 12.37:1 | `#F5F7FA` | 18.22:1 |

**`gear-fifth`** — the light set — vivid ink on proof paper. Background `#F8F4EC`, foreground `#171310` (16.84:1), cursor `#C21F2C` (5.43:1), selection `#E6DCC8`.
| Slot | Normal | vs bg | Bright | vs bg |
|---|---|---|---|---|
| black | `#171310` | 16.84:1 | `#5A5344` | 6.95:1 |
| red | `#C21F2C` | 5.43:1 | `#A8172B` | 6.78:1 |
| green | `#14804A` | 4.54:1 | `#0F6B3E` | 6.00:1 |
| yellow | `#8A6100` | 5.05:1 | `#7C5A00` | 5.77:1 |
| blue | `#1F63C4` | 5.26:1 | `#1A54A8` | 6.65:1 |
| purple | `#8A3FB0` | 5.60:1 | `#73338F` | 7.37:1 |
| cyan | `#0D7570` | 5.04:1 | `#0B6B67` | 5.78:1 |
| white | `#DFD6C6` | 1.31:1 | `#FFFDF8` | 1.08:1 |

## 3. Typography

| Face | Role | License | Weights |
|---|---|---|---|
| Instrument Serif | Display, wordmark | SIL OFL 1.1 (Google Fonts) | 400, 400 italic |
| Public Sans | UI, body | SIL OFL 1.1 (Google Fonts) | 400, 600 |
| Space Mono | Code, terminal, the proof strip | SIL OFL 1.1 (Google Fonts) | 400, 700 |

```css
--font-display: "Instrument Serif", Georgia, "Times New Roman", serif;
--font-body: "Public Sans", "Segoe UI", Roboto, "Helvetica Neue", system-ui, sans-serif;
--font-mono: "Space Mono", ui-monospace, "SFMono-Regular", Menlo, Consolas, "Liberation Mono", monospace;
```

| Step | Usage | Face / weight | Size px / rem | Line-height | Tracking |
|---|---|---|---|---|---|
| 7 | H1 / masthead | Instrument Serif 400 | 48 / 3.0 | 1.05 | −0.01em |
| 6 | H2 | Instrument Serif 400 | 32 / 2.0 | 1.12 | 0 |
| 5 | Folio / overline / proof strip | Space Mono 400 | 11 / 0.6875 | 1.30 | +0.08em, uppercase |
| 4 | Body | Public Sans 400 | 16 / 1.0 | 1.65 | 0 |
| 3 | Caption | Public Sans 400 | 13 / 0.8125 | 1.50 | +0.01em |
| 2 | Code | Space Mono 400 | 14 / 0.875 | 1.60 | 0 |
| 1 | Terminal / statusline | Space Mono 400 | 13 / 0.8125 | 1.45 | 0 |

Rules: Instrument Serif is headline-only (32 px+) and never bolded — emphasis is its italic. Body emphasis is Public
Sans 600, never underline (underline belongs to crimson marks). Numerals in tables are Space Mono. No pixel fonts
anywhere: they fail at UI sizes and read as costume. No font file ships in this repository; every SVG here carries its
text as outlined paths.

## 4. Logo and Iconography

### 4.1 The Meter (primary logomark)

Constructed on a 24 × 24 unit grid (`logo-mark.svg` renders it at 20 px per unit):

1. **Threshold rule:** a 1.5-unit horizontal rule from x = 2 to x = 22, centred at y = 12.5 (y 11.75 … 13.25), in
   Text colour. It is drawn last and passes in front of the bars.
2. **Bars 1–4:** width 2.5 units, left edges at x = 3, 7, 11, 15; bottoms at y = 21; heights 2.5, 4, 5.5, 7. Muted
   colour (`#A79F91` dark / `#5A5344` light).
3. **Bar 5:** left edge x = 19, width 2.5, bottom y = 21, top y = 3. Below the rule (y 13.25 … 21) it is muted like
   its siblings; above the rule (y 3 … 11.75) it is Primary crimson.

Symbolism: a meter, a limit, and the one segment that went past it — awakening as a threshold crossed, drawn with a
draftsman's economy. The mark is product truth: `aura`'s `power-level` preset renders the context window as a rising
meter and `transformation` prints threshold states. Mark-to-wordmark ratio: mark height = 1.6 × cap height; gap =
0.75 × cap height.

**One colour (`logo-mark-mono.svg`):** identical geometry, everything in one ink; the crossing carries the story.
Weight replaces colour — no opacity is used anywhere in the mark.

### 4.2 Wordmark

`awakened`, all lowercase, Instrument Serif 400, tracking 0. One modification: a rule 0.03 em thick runs beneath the
full word, 0.09 em below the baseline; its final 0.16 em is Primary crimson and kicks upward at 45° — the
proofreader's rule becoming the needle. Lowercase because the word is also the repository slug and the command
argument.

### 4.3 Variants

| Variant | File | Spec |
|---|---|---|
| Mark, full colour | `logo-mark.svg` | ink via `currentColor`, muted `#A79F91`, crimson `#FF544E`; sits on any dark surface |
| Mark, one colour | `logo-mark-mono.svg` | `currentColor` throughout |
| App icon | `app-icon.svg` | 512 × 512, `#100E0C` plate, 1 px `#2A2620` keyline inset 20 px (a printed plate edge), mark in a 300 px area centred at (256, 262); safe zone the central 384 × 384 |
| Favicon | `favicon.svg` | 16 × 16 native: a 2 px rule at y 10 … 12 spanning x 1 … 15; three 3 px bars with 1 px gaps at x 3, 7, 11 (heights 2 and 3 below the rule); the third bar continues above the rule to y = 1 in crimson. Ticks and the two shortest bars are dropped — three bars, one rule, one crossing |
| Lockup on dark | `logo-lockup-dark.svg` | mark + wordmark on `#100E0C` |
| Lockup on light | `logo-lockup-light.svg` | mark + wordmark on `#F8F4EC`, crimson `#C21F2C` |
| README banner | `banner-dark.svg`, `banner-light.svg` | 1600 × 400: lockup, a hairline folio rule, the proof strip in Space Mono; the README embeds both in a theme-aware `<picture>` |
| Social preview | `social-preview.svg`, `social-preview.png` | 1280 × 640: centred lockup, the furnace line in Public Sans, the proof strip; the PNG is rendered from the SVG for GitHub's setting and is never edited by hand |

### 4.4 Clearspace and minimum sizes

Clearspace = 0.75 × mark height on all sides (nine grid units). Minimum sizes: mark 16 px digital (the favicon
construction), 20 px for the full five-bar version, 7 mm print; lockup 120 px wide digital, 30 mm print.

### 4.5 UI iconography

20 × 20 grid, 1.25 px hairline stroke, squared caps, 1 px corner radius, no fills. Metaphor: the proofreader's bench —
a plugin is a stamped page, removal is a strikethrough, approval is a checked margin. Active state swaps the stroke to
crimson on exactly one sub-element, never the whole glyph.

## 5. UI and Motion Doctrine

For any future surface. No website exists (D-02); this section keeps one built later from inventing a second brand.

- **Surfaces:** flat ink. Page `#100E0C`, panels `#1B1815`. No gradients, no glass, no noise on product surfaces.
- **Borders:** 1 px `#2A2620` rules; columns separate with `border-left`, not boxes. Width scale 1 px (rules), 2 px (the
  crimson underline only).
- **Radius:** 0 / 1 / 2 px. Buttons 2 px, inputs 1 px, everything else square. Paper has corners.
- **Elevation:** none — print is flat. Layers differ by tint step plus a rule. The single exception, a modal:
  `0 0 0 1px #2A2620` over an `rgba(16, 14, 12, 0.6)` scrim.
- **Motion:** print doesn't animate; it turns pages. Durations 120 ms / 160 ms, nothing longer. Only `opacity` and
  the underline's `transform: scaleX()` animate; position never moves. `ease-out` for entrances, `linear` for the
  underline draw. `prefers-reduced-motion: reduce` removes the draw; fades remain. Never loop, never pulse, never
  shake an error.

Signature motifs, each with its value:

1. **Threshold rule** — one per page, at the moment of highest importance:
   `height: 1px; background: linear-gradient(90deg, #2A2620 0%, #FF544E 50%, #2A2620 100%);`
2. **Column rule** — `border-left: 1px solid #2A2620; padding-left: 24px;` on every secondary column.
3. **Kicked underline** — links and the active item: a 2 px crimson rule 6 px below the text with an 8 × 8 px 45°
   kick at its right end; draws left-to-right in 160 ms on hover.
4. **Folio header** — Space Mono overline (step 5) in `#8C857A`, a 1 px `#2A2620` rule 8 px beneath, then the H2.
5. **Proof caret** — list and changelog marker: a crimson `▸` (6 × 8 px) hung 12 px into the left margin.
6. **Open-circuit frame** — featured panel whose top edge carries a deliberate 24 px gap:
   `clip-path: polygon(0 0, calc(100% - 24px) 0, calc(100% - 24px) 1px, 100% 1px, 100% 100%, 0 100%);`
7. **Proof strip** — Space Mono 13 px, tracking +0.08 em, uppercase, muted: `9 PLUGINS · 0 DAEMONS · 0 TELEMETRY`.
   Every number in it is a receipt and is corrected the day it changes.

## 6. Asset Inventory and Regeneration

| File | Purpose | Notes |
|---|---|---|
| `BRAND.md` | This kit | Source of truth; palettes and assets follow it |
| `logo-mark.svg`, `logo-mark-mono.svg` | The Meter | 480 × 480, `currentColor` ink |
| `app-icon.svg` | 512 × 512 icon | Plate, keyline, mark |
| `favicon.svg` | 16 × 16 | Pixel-native construction; scales by integer multiples cleanly |
| `logo-lockup-dark.svg`, `logo-lockup-light.svg` | Mark + wordmark | Text outlined to paths |
| `banner-dark.svg`, `banner-light.svg` | README header | 1600 × 400; both embedded via `<picture>` |
| `social-preview.svg`, `social-preview.png` | GitHub social preview | 1280 × 640; PNG rendered from the SVG (8-bit RGB) |

Regeneration: the SVGs are hand-shaped markup — rectangles for the mark, `<path>` data for text produced by outlining
the OFL fonts with a font-tools library on a maintainer's machine. Nothing here depends on a font being installed;
no build step, script, or dependency enters the repository (HR-7). Change a value in this kit first, then the asset,
then the palette file that carries it; check C5 holds the palette shape, review holds the rest (D-29, ADR-029).
