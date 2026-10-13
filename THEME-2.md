# THEME-2.md — Site Design System
Follow this file for all styling decisions. Do not deviate without asking.

## Visual Identity
Minimalist "Tech Wireframe" aesthetic.
A bright, architectural interface that feels like a high-fidelity product skeleton,
technical drawing, or precision UI blueprint. The site should look clean, intentional,
and engineered, with visible structure and measured spacing.

Not cyberpunk, not neon, not futuristic glow. Think monochrome industrial design,
Swiss editorial grids, CAD overlays, and refined SaaS/product architecture.

## Color Palette (CSS variables)
:root {
  --bg-primary:   #f9f9f7;   /* warm near-white page background */
  --bg-surface:   #ffffff;   /* cards, panels, form fields */
  --bg-muted:     #f2f2ef;   /* subtle section bands, secondary surfaces */
  --bg-elevated:  #ffffff;   /* dialogs, popovers, sticky bars */

  --fg-primary:   #050505;   /* pitch-black primary typography */
  --fg-secondary: #3a3a36;   /* body copy and secondary labels */
  --fg-dim:       #777771;   /* captions, metadata, inactive states */
  --fg-faint:     #aaa9a2;   /* disabled text and construction marks */

  --line:         #e8e8e3;   /* default hairline borders */
  --line-strong:  #d5d5cd;   /* emphasized dividers, selected card borders */
  --line-dark:    #0a0a0a;   /* primary button borders, key schematic strokes */

  --accent:       #000000;   /* primary action, links, selected states */
  --accent-soft:  #f0f0eb;   /* hover fill, selected row background */

  --success:      #2f6f4e;   /* restrained semantic success only */
  --warning:      #8a6418;   /* restrained semantic warning only */
  --alert:        #b3261e;   /* errors/destructive only */

  --shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.04);
  --shadow-md:    0 8px 24px rgba(0, 0, 0, 0.06);

  --pattern-line: rgba(0, 0, 0, 0.075);
  --pattern-dot:  rgba(0, 0, 0, 0.12);
}

## Color Usage Rule
The theme is monochrome first. Black, white, and high-key grayscale should carry at
least 95% of the visual system. Semantic colors are allowed only when the UI needs to
communicate state: success, warning, error, destructive, or validation feedback.

Do not add decorative brand colors. If an element needs emphasis, use contrast,
border weight, typographic hierarchy, spacing, or a wireframe pattern before adding
color.

## Typography
- Font: clean geometric sans-serif everywhere — Inter, Satoshi, Avenir Next, Manrope,
  or Neue Haas Grotesk
- Body: 15-16px base, line-height 1.55-1.7
- Main headings: sentence case, heavy weight 700-850, tight but not cramped
- Section labels: all caps, 11-12px, weight 600-700, letter-spacing 0.08em
- Metadata/captions: 12-13px, regular or medium weight, muted gray
- Numeric/data readouts: tabular-nums, medium weight, aligned to grid
- Do not use decorative display fonts, serif fonts, handwriting, or monospace as the
  default face. Monospace is allowed only for small code-like labels or measurements.

## Wireframe Graphic Language
- Use abstract geometric placeholders instead of photography or colorful illustrations.
- Preferred motifs: fine diagonal hatching, micro-dot grids, concentric circles,
  orthographic outlines, axis lines, crop marks, bounding boxes, measurement ticks,
  blueprint callout labels, and simple rectangular/spherical primitives.
- Graphic blocks should look like precise placeholders, not unfinished gray boxes.
- Keep patterns low contrast. They should add technical texture without competing
  with content.
- Use black or gray linework only. Avoid gradients, neon strokes, colorful blobs,
  3D glass effects, or stock illustration styles.

## Layout — Modular Grid System
- Build pages from clear grid-aligned modules with visible structure.
- Use cards and panels with 1px borders, restrained radius, and consistent internal
  spacing.
- Page sections may be full-width bands or constrained grid rows; avoid floating
  decorative sections.
- Recommended max content width: 1120-1280px.
- Grid rhythm: 8px spacing scale; common gaps are 16px, 24px, 32px, and 48px.
- Cards: 6-8px radius, never pill-shaped. Large surfaces may use 10-12px only if the
  rest of the design is very restrained.
- Dividers and borders are part of the design language. Use them intentionally to
  show structure, grouping, and hierarchy.
- Empty areas should feel measured, not vague. Whitespace should align to the grid.

## Terminal / Blueprint Chrome
- Optional labels may use blueprint-style conventions:
  `SECTION / 01`, `MODULE / HERO`, `SPEC / ACTIVE`, `INDEX / 04`
- Small structural labels should sit above or inside panel edges, like drawing
  annotations.
- Use thin rules, corner brackets, crosshair marks, or measurement ticks to frame
  important modules.
- Avoid fake terminal prompts, glowing cursors, or cyber HUD treatment. This theme is
  architectural wireframe, not command-line sci-fi.

## Component Defaults
- Buttons: 1px solid --line-dark, white or transparent background, black text.
  On hover, use --accent-soft background or invert to black background with white text.
- Primary buttons: black background, white text, 1px black border. Keep the shape
  rectangular with modest radius.
- Secondary buttons: white/transparent background, black border, black text.
- Icon buttons: square or softly rounded rectangles with 1px border; no circular
  floating action buttons unless the product pattern requires it.
- Cards/panels: --bg-surface, 1px --line border, 6-8px radius, optional --shadow-sm.
- Feature cards: include one abstract wireframe placeholder or schematic header area
  instead of an image.
- Inputs/selects: white background, 1px --line-strong border, 6px radius, clear focus
  ring in black or dark gray.
- Focus states: visible 2px outline or offset ring. Never rely on color alone.
- Tables/lists: thin row dividers, compact metadata, strong alignment, tabular nums
  for counts, prices, metrics, or timestamps.
- Code blocks: very light gray background, 1px border, dark text, no neon syntax theme.

## Abstract Placeholder Recipes
Use these patterns for hero art, thumbnails, empty states, and feature visuals:

- Diagonal hatch panel: white panel with 1px border and repeating 45-degree gray lines.
- Dot matrix panel: soft gray surface with tiny evenly spaced black dots at low opacity.
- Concentric system diagram: nested circles, a central node, and two or three radial
  measurement lines.
- Wireframe object: simple outlined cuboid, device frame, dashboard chart, product
  module, or architectural elevation.
- Blueprint card: rectangular bounding box with corner ticks, small all-caps labels,
  and one simple central geometric form.

Patterns should be implemented with CSS backgrounds, SVGs, canvas, or lightweight
inline markup. Keep them crisp and scalable.

## Interaction & Motion
- Motion should be subtle and functional: 120-180ms transitions for hover, focus,
  opening, and selection.
- Use tiny translations, border darkening, or background shifts. Avoid bouncy,
  elastic, parallax-heavy, or theatrical animation.
- Skeleton/loading states should use wireframe placeholders or low-contrast shimmer.
- Respect `prefers-reduced-motion`.

## Never Do This
- No neon, glow, bloom, cyberpunk lighting, or saturated accent palettes.
- No dark mode unless explicitly requested.
- No colorful gradients, gradient orbs, bokeh blobs, or decorative glassmorphism.
- No photography as the main visual language unless the content specifically requires
  real product/place/person imagery.
- No rounded-full pills as a default shape.
- No thick drop shadows or material-design elevation stacks.
- No emoji as interface decoration.
- No playful cartoon illustrations.
- No excessive beige/tan styling. The background may be warm near-white, but the theme
  should read grayscale and technical.
- No dense black fills except for primary CTAs, selected states, or deliberate graphic
  contrast.

## Accessibility Note
Primary content should use --fg-primary or --fg-secondary on --bg-primary/--bg-surface.
Muted labels using --fg-dim must stay large enough and high enough contrast to remain
readable. Border-only controls need visible text labels or accessible names, and focus
states must be clearly visible against white and light-gray surfaces.
