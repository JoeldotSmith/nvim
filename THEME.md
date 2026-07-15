# THEME.md — Site Design System
Follow this file for all styling decisions. Do not deviate without asking.

## Visual Identity
Tron Legacy "Encom Boardroom" HUD aesthetic — reference: robscanlon.com/encom-boardroom
Wireframe instrument-panel interface floating on true black. Thin glowing hairlines,
dense data-panel labeling, monochrome-led palette (cyan primary, green secondary).
Not "neon cyberpunk" — restrained, technical, schematic. Think avionics HUD, not
nightclub signage.

## Color Palette (CSS variables)
:root {
  --bg-primary:   #000000;   /* true black — HUD elements float on void, no bg texture */
  --bg-surface:   #000a0d;   /* barely-there cyan tint, panel interiors */
  --bg-elevated:  #001114;   /* modals, active/focused panels */

  --fg-primary:   #b8fbff;   /* dim glowing cyan-white, primary text */
  --fg-dim:       #2a5a60;   /* muted cyan, inactive labels, timestamps */

  --accent:       #00e5ff;   /* PRIMARY — borders, links, headers, most glow */
  --accent-bright:#7dffff;   /* hover/active state */

  --highlight:    #39ff88;   /* SECONDARY — status/active/success, "system online" states */
  --highlight-dim:#1a5c38;   /* muted green, used for inactive-but-positive states */

  --alert:        #ff4444;   /* errors/destructive ONLY — used sparingly */

  --line:         rgba(0, 229, 255, 0.35);           /* hairline panel borders, 1px */
  --line-highlight: rgba(57, 255, 136, 0.35);         /* hairline borders on active/highlighted panels */
  --glow-sm:      0 0 4px rgba(0, 229, 255, 0.6);
  --glow-lg:      0 0 20px rgba(0, 229, 255, 0.4);
  --glow-highlight: 0 0 8px rgba(57, 255, 136, 0.6);
}

## Color Usage Rule
Cyan carries the interface (structure, text, default state — roughly 80% of accent use).
Green is reserved for meaning: active/online/success/"this is the important one right now"
(roughly 20%). Never let green become decorative — if it's glowing green, it should signal
something (current section, live status, positive metric). Red only for errors.

## Typography
- Font: monospace everywhere — JetBrains Mono, Fira Code, or IBM Plex Mono
- Body: 14px base, line-height 1.6
- Headings/labels: uppercase, letter-spacing 0.05–0.1em, weight 400–500 (thin/light —
  Encom's type is delicate, not bold)
- Numeric/data readouts: tabular-nums, slightly larger tracking

## Terminal / HUD Chrome
- Section headers use the label convention: `LABEL .EXT *STATUS*`
  e.g. `ABOUT .TXT *END. PROGRAM*`, `PROJECTS .SYS *ACTIVE*`, `CONTACT .SYS *STANDBY*`
- `*STATUS*` tag uses --highlight (green) when live/active, --fg-dim when idle
- Nav styled as terminal title bar: `user@yoursite:~$` prompt, decorative (non-functional)
  three-dot cluster top-left
- Blinking cursor (▊) in cyan after typed hero text; respect `prefers-reduced-motion`
- Any real data (GitHub stats, uptime, visitor count, local time) rendered as small
  HUD readout panels — bordered rectangles with a dim cyan label + bright value
- Wireframe/outline icons only, no filled icons

## Layout — Data Panel System
- Build sections as discrete rectangular panels with 1px --line borders, not implicit
  whitespace-separated blocks
- Panels can nest a thin grid/ruler pattern in the background at very low opacity
  (~5-8%) to reinforce the "instrument panel" feel — optional, use sparingly
- Corners: sharp or max 1-2px radius — no soft corners anywhere
- Active/focused panel switches border color from --line to --line-highlight (green)
  and increases glow — this is how you signal "you are here" or "this is selected"

## Component Defaults
- Buttons: 1px solid --accent border, transparent bg, text in --accent. On hover:
  --glow-lg + text shifts to --accent-bright. NEVER solid-filled.
- Primary/CTA buttons may use --highlight (green) border + glow instead of cyan,
  to visually mark them as "the important action"
- Cards/panels: --bg-surface, 1px --line border, sharp corners
- Focus states: outline in --accent + --glow-sm, never color-only
- Code blocks: --bg-elevated, cyan default syntax, green for strings/success output

## Never Do This
- No gradients — glow via box-shadow only
- No filled/solid-background buttons — outline + glow only
- No rounded-full/pill shapes, no soft corners generally
- No magenta, yellow, or purple accents — palette is cyan + green + black, red for errors only
- No drop shadows for depth — border + glow instead
- No sans-serif fonts anywhere
- No emoji — use ASCII/unicode (▊ $ > # ~ |) instead
- Don't let green outnumber cyan — if more than ~20% of visible accent color is green,
  it's lost its meaning as a status signal and just become "second neon color"

## Accessibility Note
Both --accent (#00e5ff) and --highlight (#39ff88) need contrast checks against
--bg-primary (#000000) — thin/light font weights at small sizes are especially
vulnerable to failing WCAG AA. If a weight/size combo fails, increase weight
before brightening color further (keeps the delicate HUD look intact).
