---
name: slop-design
description: Design Roblox HUDs and menus with the Studs, Raised or BlockyStuds theme, using measured layouts, outlined typography, matching icon colors and responsive scaling.
---

# Slop design
Use the existing theme unless the user requests another one. The tables below are measured examples of each theme, not a requirement to reuse the same menu contents, dimensions or colors everywhere.

### Reference and scope
- When recreating an image, preserve its layout, relative sizes, spacing and color identities. Apply the selected theme's borders, typography and surface treatment to that layout.
- Measure HUD groups against the reference image's full viewport. Convert a measured height to 1080p with `referencePixels * 1080 / referenceViewportHeight`. Keep normalized screen positions and edge anchors. For "a little smaller", use 0.9 of the measured sizes unless the user gives a factor. Scale text and spacing by that same factor.
- Account for the current viewport and `autoScaler` before judging size from a Studio screenshot. Do not repeatedly resize the design to compensate for a smaller preview viewport.
- Use the requested content. Do not invent currencies, passes, rewards or extra cards to fill space or make a grid even. A short final row is fine. Reduce excess space when content is removed instead of enlarging controls to fill it.
- After changing a hierarchy, update the client paths and connections that use it. Check text fit and the final scroll row as well as script compilation. Respect the project's restrictions on playtesting, and state which behavior remains untested.

## Shared resources
These apply to every theme.

### Icons
Take every icon from `resources/icons/freeIconsPack.luau`. It maps icon names to uploaded image ids:

```luau
["Calendar 1st"] = "rbxassetid://122704819305510",
["Rebirth 2nd"] = "rbxassetid://106171001948279",
```

- Search the file by name and copy the id into `ImageLabel.Image`. Do not search the Creator Store and do not upload new icons if the pack has a match.
- Most icons come in `1st` and `2nd` variants. Pick whichever fits. If one window already uses a variant, keep the rest of the window consistent with it. 1st is a 3d style, 2nd is a flatter style.
- Icons are 256px outlined images. Use `ScaleType = Fit` and `BackgroundTransparency = 1`.
- Never change an icon's `ImageColor3`. Leave it at (255, 255, 255) so the icon shows its own colors. If an icon's color doesn't fit, pick a different icon or variant instead of tinting it.
- If the pack has nothing that fits, say so and ask for an asset id. Do not substitute a text character.

### Roblox characters
For Robux, Premium, Roblox Plus and Verified, use the private-use glyphs in `resources/icons/robloxCharacters.luau`. Never use an image for these.

| Index | Glyph | Codepoint |
|---|---|---|
| 1 | Roblox Plus | `utf8.char(0xE003)` |
| 2 | Robux | `utf8.char(0xE002)` |
| 3 | Premium | `utf8.char(0xE001)` |
| 4 | Verified | `utf8.char(0xE000)` |

Put the glyph and the number in the same `TextLabel`, for example `utf8.char(0xE002) .. "9"`. Do not split them into two labels.

### Scaling
Every theme scales with the `autoScaler` module from the `scaleable-ui` skill (`resources/scripts/autoScaler.luau`). Follow that skill for setup.

- Design every window at 1080p. All pixel values in this skill are 1080p pixels.
- Every frame directly under a `ScreenGui` gets an Offset `Size` and no `UIAspectRatioConstraint`. Its `Position` can stay in Scale with an `AnchorPoint`.
- Put a `UIScale` tagged `UIScale` directly under that frame, with number attributes `MinScale` and `MaxScale`. `MaxScale` is 1. Each theme lists a starting `MinScale`. Lower it if the window doesn't fit on a phone.
- Children of the outer frame keep the Scale positions and sizes listed in each theme. They follow the outer frame.
- `UIScale` scales strokes, corners, tile sizes and text too. That's why stroke thickness and `TextSize` can be fixed pixel values.

### Text size
- Never use `TextScaled`. Set `TextScaled = false` and a fixed `TextSize` from the theme's table.
- Keep each label's box from the theme's tables. The box only places and aligns the text now.
- If new text doesn't fit its box, shorten the text or lower that label's `TextSize`. Do not turn `TextScaled` back on.
- Labels that hold more than one line set `TextWrapped = true`.

### HUD
HUD elements sit on the game screen all the time: menu buttons, currency counters, timers. They have no background. Theme styling for panels, cards and windows does not apply to them.

- The icon and its text float directly over the game. Nothing is drawn behind them.
- No colored tile, card, block, gradient, pattern, `UIStroke` border or rounded square behind an icon.
- No menu frame or panel around a group of HUD buttons.
- A button is an `ImageButton` with the icon as its `Image` and `BackgroundTransparency = 1`. Its label sits under or over the icon and follows the theme's text style: font, weight, color and text stroke.
- A layout frame that only groups or positions buttons is fine if it is invisible: `BackgroundTransparency = 1`, no stroke, no gradient, no image.
- Badges such as a notification count can still have their own small shape, since they mark state rather than frame the button.
- Small action controls such as a currency "+" may also have their own shape. In Raised, build them as green raised buttons with a centered text "+" and the same `Body`/`Face` press behavior as menu buttons. This does not add a background behind the currency row or main HUD icon.
- HUD frames still follow the Scaling rules. The outer frame has an Offset size and a tagged `UIScale`.

Don't build a HUD like this: a row of menu buttons where each icon sits on its own colored, patterned, outlined square. Drop the squares and keep the icons and labels.

### Color identity
- Choose each menu's accent from its main icon's dominant color or the supplied reference. Carry that accent through its header, related cards and highlighted text. Menus with different icon colors need different headers. Never clone the orange Raised header, pink Studs header or orange BlockyStuds topbar across every menu.
- Match a card's background to its own icon when it represents a distinct currency, reward or item. Shared action colors still apply, such as green purchase buttons and red close buttons.
- The palette tables are starting colors, not a closed list. Add a missing hue in the same style rather than replacing the reference color with an unrelated listed color. Raised surfaces need a lighter top, saturated bottom and darker lip of the same hue.
- When changing a menu's color, include its header. Keep the close button red unless requested otherwise, with a readable outlined "X".

### ScrollingFrames
Every `ScrollingFrame` in every theme sets `AutomaticCanvasSize` to the scrolling axis, usually `Y`, and leaves `CanvasSize` at {0, 0}, {0, 0}. Never hard-code a canvas size.

Because the canvas grows to fit its children, children inside it must not take their height from the canvas:
- Stack them with a `UIListLayout` or `UIGridLayout` instead of placing each one by `Position`.
- Give each child a width in scale and get its height from a `UIAspectRatioConstraint` (`AspectType = ScaleWithParentSize`, `DominantAxis = Width`), `AutomaticSize = Y`, or a fixed Offset for heading and spacer rows.
- Never give a child a Y scale size inside a ScrollingFrame that has an automatic canvas.
- For width-driven aspect-ratio rows, use full-width direct children, `Size` {1, 0}, {0, 0}, and move side margins to `UIPadding`. Narrow aspect-ratio children caused automatic canvas height to be undercounted in the tested layout.
- Use Offset gaps and full-width spacer rows for top and bottom space. Scale-based vertical padding and gaps were omitted or undercounted in that layout. These offsets are 1080p pixels and scale with the outer `UIScale`.
- Check that the last row, its strokes and the bottom margin are reachable at maximum scroll. `AutomaticCanvasSize` alone does not prove the list fits. Keep `CanvasSize` zero and correct the layout rather than hard-coding a larger canvas.

### Textures
Pattern textures live in `resources/textures/surfaceTypes.luau`. Each image holds a 2x2 block of the tile.

| Name | Id |
|---|---|
| Universal | `rbxassetid://117748142355030` |
| Stud | `rbxassetid://12055407192` |
| Weld | `rbxassetid://95865038110339` |

## Studs
This UI style is heavily inspired by Jxnt, credits to them.

Bright, chunky game UI. Saturated gradient panels sit on a dark see-through body, every colored surface has a faint tile pattern, borders are thick white and black, and text is heavy with an outline.

### Units
- `Main` is sized in Offset at 1080p. Children use Scale positions and sizes, except the fixed-height rows and gaps described in the shared scrolling rules.
- The pixel values are `Main.Size`, `UICorner.CornerRadius`, `UIStroke.Thickness`, the pattern `TileSize` and `TextSize`. `UIScale` scales all of them.
- Positions and sizes below are fractions of the parent unless stated otherwise.

### ScreenGui
| Property | Value |
|---|---|
| `IgnoreGuiInset` | `true` |
| `ResetOnSpawn` | `false` |
| `ZIndexBehavior` | `Sibling` |
| `ScreenInsets` | `DeviceSafeInsets` |

### Window frame
`Main` is an invisible `Frame` that only sizes the window.

| Property | Value |
|---|---|
| `AnchorPoint` | (0.5, 0.5) |
| `Position` | {0.5, 0}, {0.5, 0} |
| `Size` | {0, 788}, {0, 432} |
| `BackgroundTransparency` | 1 |
| `UIScale` | tag `UIScale`, `MinScale` 0.75, `MaxScale` 1 |

`Main` matches the width of the body panel, so anything centered in the content uses X = 0.5. The header and the window icon hang outside `Main`.

### Layers (ZIndex)
| ZIndex | Used for |
|---|---|
| 1 | Body panel |
| 2 | Header |
| 3 | Cards, bars, buttons, their patterns |
| 4 | Pattern on top of a bar fill, close button |
| 5 | All text |
| 6 | Window icon |
| 7 | Price badges |

### Body panel
| Property | Value |
|---|---|
| `AnchorPoint` | (0.5, 1) |
| `Position` | {0.5, 0}, {1, 0} |
| `Size` | {1, 0}, {0.8372, 0} |
| `BackgroundColor3` | (12, 10, 18) |
| `BackgroundTransparency` | 0.4 |
| `UICorner` | 12 px |

The top 16.3% of `Main` stays empty for the header. The body has the border pair described below but no pattern.

### Border pair
Every bordered element gets exactly two `UIStroke`s. That covers the body, header, close button, cards, bars and buttons. Never fake a border with an inner `Frame`.

| Name | Color | Thickness | Transparency | `BorderStrokePosition` | ZIndex |
|---|---|---|---|---|---|
| `InnerStroke` | (255, 255, 255) | 2 | 0.15 | Inner | 2 |
| `OuterStroke` | (20, 18, 24) | 2.5 | 0 | Outer | 1 |

Both use `ApplyStrokeMode = Border` and `LineJoinMode = Round`.

Change only the inner stroke's transparency, and only by surface:
- Body, header, buttons: 0.15.
- Cards and bars: 0.2.
- Close button: 0.1.

### Text
- Font: Montserrat, Heavy weight (`rbxasset://fonts/families/Montserrat.json`, `Enum.FontWeight.Heavy`).
- `TextScaled = false` with a fixed `TextSize` from the table at the end of this section.
- `TextColor3` (255, 255, 255) unless the element below says otherwise.
- Text `BackgroundTransparency = 1`, ZIndex 5.
- Every label gets one `UIStroke` with `ApplyStrokeMode = Contextual` and `LineJoinMode = Round`:

| Text | Stroke color | Thickness |
|---|---|---|
| Window title | (35, 30, 40) | 2.5 |
| Everything else | (35, 30, 40) | 2 |
| Small badges (price) | (20, 18, 24) | 1.5 |

- Text on a button or card sits in a child `Label` with `AnchorPoint` (0.5, 0.5) and `Position` {0.5, 0}, {0.5, 0}. Use a `TextButton` with an empty `Text` as the button itself.

| Container | Label size |
|---|---|
| Card | {0.88, 0}, {0.45, 0} |
| Button | {0.88, 0}, {0.68, 0} |
| Close button | {0.6, 0}, {0.6, 0} |
| Bar | {1, 0}, {0.7, 0} |

| Text | `TextSize` |
|---|---|
| Window title | 64 |
| Subtitle (`RebirthCount`) | 46 |
| Card label ("x512 Power") | 53 |
| Arrow between cards | 100 |
| Bar text | 42 |
| Primary button label | 38 |
| Premium button label | 34 |
| Close "X" | 41 |
| Price badge | 30 |

### Gradients
Colored surfaces use `BackgroundColor3` (255, 255, 255) and a `UIGradient` with `Rotation = 90` and no transparency. The first color is the top.

| Surface | Top | Bottom |
|---|---|---|
| Header (pink) | (240, 70, 115) | (236, 24, 72) |
| Close button (pink) | (255, 66, 138) | (238, 25, 72), `Rotation = 41` |
| Card (blue) | (56, 182, 248) | (40, 160, 240) |
| Bar fill (pink) | (242, 70, 110) | (236, 50, 92) |
| Primary button (red) | (242, 62, 104) | (218, 48, 88) |
| Premium button (yellow) | (240, 228, 60) | (241, 189, 38) |

Flat colors:
- Bar track: (241, 244, 247), no gradient.
- Robux price text: (88, 255, 76).
- Decorative glyphs such as the arrow: (225, 232, 242).

### Pattern overlay
The header, cards and bars each get a `Pattern` `ImageLabel` child:

| Property | Value |
|---|---|
| `Image` | `Universal` from `surfaceTypes.luau` (`rbxassetid://117748142355030`) |
| `Size` | {1, 0}, {1, 0} |
| `BackgroundTransparency` | 1 |
| `ImageColor3` | (255, 255, 255) |
| `ImageTransparency` | 0.87 |
| `ScaleType` | Tile |
| `TileSize` | {0, 50}, {0, 50} |

- Every pattern in the project uses the same 50 × 50 px tile. Do not use Scale for `TileSize`, because the tiles then grow and shrink with each element.
- Give the pattern a `UICorner` matching its parent if the corners show through.
- On a bar, put the pattern above the fill (ZIndex 4) so it covers both the fill and the track.

### Corner radii
| Element | `CornerRadius` |
|---|---|
| Body | 12 px |
| Card | 8 px |
| Bar track | 6 px |
| Header, close button, bar fill | 4 px |
| Buttons | 3 px |

### Header
| Property | Value |
|---|---|
| `AnchorPoint` | (0.5, 0) |
| `Position` | {0.5, 0}, {0, 0} |
| `Size` | {1.06, 0}, {0.205, 0} |
| ZIndex | 2 |

The header is 6% wider than the body, so it sticks out 3% on each side. It overlaps the top of the body by about 4% of `Main` height.

- **Title.** Sibling of the header inside `Main`. `AnchorPoint` (0.5, 0.5), `Position` {0.5, 0}, {0.107, 0}, `Size` {0.663, 0}, {0.149, 0}.
- **Window icon.** An `ImageLabel` from the icon pack, sibling of the header. `AnchorPoint` (0.5, 0.5), `Position` {0, 0}, {0.102, 0}, so it is centered on the left edge of `Main`. `Size` {0.1429, 0}, {0.2605, 0}, `Rotation` -6, ZIndex 6.
- **Close button.** A `TextButton` inside the header. `AnchorPoint` (1, 0.5), `Position` {0.974, 0}, {0.5, 0}, `Size` {0.0885, 0}, {0.773, 0}, ZIndex 4. Its label is an "X".

### Body content
Positions are fractions of `Main`.

| Element | AnchorPoint | Position | Size |
|---|---|---|---|
| Subtitle (`RebirthCount`) | (0.5, 0.5) | {0.5, 0}, {0.281, 0} | {0.510, 0}, {0.107, 0} |
| Left card | (0, 0.5) | {0.0383, 0}, {0.472, 0} | {0.3929, 0}, {0.2744, 0} |
| Right card | (1, 0.5) | {0.9617, 0}, {0.472, 0} | {0.3929, 0}, {0.2744, 0} |
| Arrow between cards | (0.5, 0.5) | {0.5, 0}, {0.470, 0} | {0.1378, 0}, {0.2977, 0} |
| Progress bar | (0.5, 0.5) | {0.5, 0}, {0.712, 0} | {0.6939, 0}, {0.1395, 0} |
| Primary button | (1, 0.5) | {0.4834, 0}, {0.884, 0} | {0.2117, 0}, {0.1302, 0} |
| Premium button | (0, 0.5) | {0.5166, 0}, {0.884, 0} | {0.2832, 0}, {0.1395, 0} |

Rules behind the table:
- Mirrored pairs sit the same distance from each side. Cards are 3.83% in from the edges. Buttons sit 1.66% either side of X = 0.5, a 3.3% gap in total.
- Anchor each element to the edge or center it is aligned to. Left-aligned items use X 0, right-aligned X 1, centered X 0.5. Vertically, rows use Y 0.5.
- Buttons in a row share a center line. The premium button is about 7% taller than the primary one.

### Progress bar
- The track has `ClipsDescendants = true`.
- `Fill` is a child `Frame` with `AnchorPoint` (0, 0), `Position` {0, 0}, {0, 0}, `Size` {progress, 0}, {1, 0}, ZIndex 3. Set the X scale from code.
- The bar text ("Level 1 / 25") is a child of the track, centered, ZIndex 5.

### Price badge
A Robux price sits on the top-right corner of the premium button. It is a child of the button:

| Property | Value |
|---|---|
| `Text` | `utf8.char(0xE002) .. price` |
| `AnchorPoint` | (0.5, 0.5) |
| `Position` | {0.93, 0}, {0.008, 0} |
| `Size` | {0.246, 0}, {0.5, 0} |
| `Rotation` | 15 |
| `TextColor3` | (88, 255, 76) |
| ZIndex | 7 |
| Stroke | (20, 18, 24), thickness 1.5 |

### Hierarchy
```
ScreenGui
└─ Main                     (UIScale)
   ├─ Body                  (UICorner, InnerStroke, OuterStroke)
   ├─ Header                (UICorner, UIGradient, Pattern, InnerStroke, OuterStroke)
   │  └─ Close              (UICorner, UIGradient, Label, InnerStroke, OuterStroke)
   ├─ Title                 (UIStroke)
   ├─ Icon
   ├─ Subtitle              (UIStroke)
   ├─ Current / Next        (UICorner, UIGradient, Pattern, Label, InnerStroke, OuterStroke)
   ├─ Arrow                 (UIStroke)
   ├─ LevelBar              (UICorner, Fill, Pattern, LevelText, InnerStroke, OuterStroke)
   ├─ Rebirth               (UICorner, UIGradient, Label, InnerStroke, OuterStroke)
   └─ SkipRebirth           (UICorner, UIGradient, Label, Price, InnerStroke, OuterStroke)
```

Name strokes `InnerStroke` and `OuterStroke`. Name text children `Label` and patterns `Pattern`.

### Checklist
- [ ] Every colored surface has a gradient, a pattern, and both strokes.
- [ ] Every text label is Montserrat Heavy and white, with a dark contextual stroke and a fixed `TextSize`.
- [ ] `Main` is sized in Offset and has a tagged `UIScale`. Children use Scale except the documented scrolling rows and gaps.
- [ ] Icons come from `freeIconsPack.luau`, Robux and similar glyphs from `robloxCharacters.luau`.
- [ ] Every pattern uses `TileSize` {0, 50}, {0, 50}.
- [ ] Header and card accents follow their icons and the reference, rather than repeating the example palette everywhere.

## Raised
This UI style is heavily inspired by Duckable, credits to them.

Square, chunky game UI with no studs and no pattern. Every panel looks like a block pressed out of the screen: a gradient face sits on a darker lip along the bottom edge. Black outlines are thick, the white inner border fades out toward the bottom, and text is heavy with a black outline.

### Units
- `Main` is sized in Offset at 1080p. Children use Scale positions and sizes, except the fixed-height rows and gaps described under Scrolling content.
- Pixel values include `Main.Size`, `UIStroke.Thickness`, `TextSize`, list and grid gaps, and fixed-height heading or spacer rows. `UIScale` scales all of them.
- Positions and sizes below are fractions of the parent unless stated otherwise.
- No `UICorner` anywhere. Every corner is square.

### ScreenGui
| Property | Value |
|---|---|
| `IgnoreGuiInset` | `true` |
| `ResetOnSpawn` | `false` |
| `ZIndexBehavior` | `Sibling` |
| `ScreenInsets` | `DeviceSafeInsets` |

### Window frame
`Main` is the window body itself.

| Property | Value |
|---|---|
| `AnchorPoint` | (0.5, 0.5) |
| `Position` | {0.5, 0}, {0.5, 0} |
| `Size` | {0, 1010}, {0, 666} |
| `BackgroundColor3` | (0, 0, 0) |
| `BackgroundTransparency` | 0.35 |
| `UIScale` | tag `UIScale`, `MinScale` 0.5, `MaxScale` 1 |
| `OuterStroke` | see below, thickness 3 |

### Raised block
Header, close button, cards and buttons all use the same build:

```
Block                (Frame or TextButton, BackgroundColor3 = lip color, OuterStroke)
└─ Face              (Frame, white background, UIGradient, InnerStroke)
```

- `Face` has `Position` {0, 0}, {0, 0} and `Size` {1, 0}, {faceHeight, 0}, so the block's own background shows underneath as the lip.
- Put icons and text on the block, not the face, unless they must be clipped to the face.

Buttons add one level so they can be pressed:

```
Button               (TextButton, Text = "", AutoButtonColor = false, BackgroundTransparency = 1)
└─ Body              (Frame, BackgroundColor3 = lip color, OuterStroke)
   └─ Face           (Frame, white background, UIGradient, InnerStroke, Label)
```

- `Button` is an invisible hit box. It never moves or resizes, so hover doesn't flicker while the body animates.
- `Body` has `AnchorPoint` (0, 1), `Position` {0, 0}, {1, 0} and `Size` {1, 0}, {1, 0}. It is pinned to the bottom edge, so it grows and shrinks from the top.
- `Face` has `Position` {0, 0}, {0, 0} and `Size` {1, 0}, {faceHeight, 0}, the same as on other blocks.
- The button's text goes inside `Face`, so it rides along with the face.

| Block | Lip | `Face` height |
|---|---|---|
| Header | 13 px of 107 | 0.8785 |
| Close button | 13 px of 108 | 0.8796 |
| Card | 9 px of 195 | 0.9538 |
| Buy button | 8 px of 65 | 0.877 |

### Strokes
`OuterStroke` goes on the block:

| Property | Value |
|---|---|
| `Color` | (2, 4, 7) |
| `Thickness` | 3, or 2 on buy buttons |
| `BorderStrokePosition` | Outer |
| `ApplyStrokeMode` | Border |
| `LineJoinMode` | Miter |

`InnerStroke` goes on the face:

| Property | Value |
|---|---|
| `Color` | (255, 255, 255) |
| `Thickness` | 3 |
| `BorderStrokePosition` | Inner |
| `ApplyStrokeMode` | Border |
| `LineJoinMode` | Miter |

The inner stroke has a `UIGradient` child with `Rotation = 90` and `Transparency` going from 0.12 at the top to 0.72 at the bottom. That makes the top edge bright and the bottom edge a faint line above the lip. Do not set `Transparency` on the stroke itself.

### Text
- Font is Montserrat (`rbxasset://fonts/families/Montserrat.json`).
- Titles, the multiplier and other headline numbers use `Enum.FontWeight.Heavy`. There is no `Black` weight in the enum.
- Everything else uses `Enum.FontWeight.ExtraBold`.
- `TextScaled = false` with the fixed `TextSize` below.
- `TextColor3` (241, 244, 246) unless the element below says otherwise. `BackgroundTransparency = 1`.
- Every label gets one `UIStroke` with color (2, 4, 7), `ApplyStrokeMode = Contextual` and `LineJoinMode = Round`.

| Text | Weight | `TextSize` | Stroke |
|---|---|---|---|
| Window title | ExtraBold | 70 | 3 |
| Close "X" | ExtraBold | 88 | 3 |
| Card title | Heavy | 56 | 4 |
| Feature title ("Server Luck") | Heavy | 44 | 2.5 |
| Multiplier ("1x > 2x") | Heavy | 100 | 5 |
| Section heading ("Passes") | ExtraBold | 40 | 2.5 |
| Price | ExtraBold | 46 | 2.5 |
| Description | ExtraBold | 30 | 2 |

Card titles get a `UIGradient` child with `Rotation = 90` that colors the text fill.

| Card | Top | Bottom |
|---|---|---|
| Purple | (241, 125, 245) | (160, 84, 244) |
| Orange | (241, 213, 6) | (241, 150, 6) |
| Green | flat (0, 244, 8) | |

Text gradients are plain: two keypoints, top color at 0 and bottom color at 1, blending smoothly. Text is flat, not a raised block, so it never gets the glossy look. No hard stops, no light top half with a dark band under the middle, and no extra keypoints that fake a shine. This applies to every gradient on text, including counters and other HUD numbers.

Color part of a label with RichText instead of splitting it. The multiplier is `1x &gt; <font color="#E1F529">2x</font>`.

### Colors
Faces use a `UIGradient` with `Rotation = 90`. The first color is the top.

| Block | Top | Bottom | Lip |
|---|---|---|---|
| Orange surface | (249, 165, 13) | (242, 7, 10) | (137, 7, 10) |
| Close button (red) | (240, 120, 122) | (205, 54, 56) | (142, 32, 34) |
| Green card | (225, 245, 90) | (50, 199, 37) | (1, 60, 5) |
| Purple card | (233, 104, 245) | (65, 60, 244) | (67, 24, 115) |
| Orange card | (241, 213, 6) | (241, 96, 4) | (189, 68, 4) |
| Red card | (245, 72, 64) | (205, 22, 22) | (128, 10, 10) |
| Blue surface | (88, 204, 255) | (28, 100, 240) | (14, 46, 128) |
| Buy button (green) | (206, 244, 8) | (20, 223, 8) | (2, 146, 8) |

Buy buttons are always green, whatever card they sit on.

Headers use the row matching their icon, including its lip. For example, a purple icon gets the purple palette, a blue icon gets blue and a red icon gets red. Orange is one option.

HUD cash amounts and matching floating gain text use the green card gradient, (225, 245, 90) to (50, 199, 37). Blue gem amounts use (90, 236, 255) to (20, 104, 255). Keep both as smooth two-keypoint text gradients. Standalone HUD Robux prices use flat green (0, 244, 8), including both the glyph and number. Prices inside green buy buttons stay white.

### Header
Fractions of `Main`.

| Element | AnchorPoint | Position | Size |
|---|---|---|---|
| Header | (0, 0) | {0, 0}, {0, 0} | {1, 0}, {0.1607, 0} |
| Close button | (1, 0) | {0.997, 0}, {0, 0} | {0.1069, 0}, {0.1622, 0} |
| Content | (0, 0) | {0, 0}, {0.1652, 0} | {1, 0}, {0.8348, 0} |

The header spans the full window width. The close button is a separate square block on top of the header's right end, about the same height as the header.

Inside the header, as fractions of the header:

| Element | Position | Size |
|---|---|---|
| Icon | {0.0129, 0}, {0.0374, 0} | {0.0871, 0}, {0.8224, 0} |
| Title | {0.1158, 0}, {0.1402, 0} | {0.3168, 0}, {0.6542, 0} |

The title is left-aligned. The close button's "X" sits inside its `Face`, centered at {0.5, 0}, {0.526, 0} with size {0.9, 0}, {0.932, 0}.

### Scrolling content
Everything below the header lives in a `ScrollingFrame` named `Content`. It follows the shared ScrollingFrame rule.

| Property | Value |
|---|---|
| `Position` | {0, 0}, {0.1652, 0} |
| `Size` | {1, 0}, {0.8348, 0} |
| `BackgroundTransparency` | 1 |
| `ScrollingDirection` | Y |
| `ScrollBarThickness` | 6 |
| `ScrollBarImageColor3` | (0, 0, 0) |
| `ScrollBarImageTransparency` | 0.45 |
| `AutomaticCanvasSize` | Y |
| `CanvasSize` | {0, 0}, {0, 0} |

Children stack with a `UIListLayout`:

| Property | Value |
|---|---|
| `FillDirection` | Vertical |
| `HorizontalAlignment` | Center |
| `SortOrder` | LayoutOrder |
| `Padding` | {0, 19} |

Add a `UIPadding` with left and right padding {0.0357, 0}, and zero top and bottom padding. Use the full-width children below so the automatic canvas counts aspect-ratio heights correctly. The section heading's frame spans the content width; its text can still be a compact label inside it.

| LayoutOrder | Element | Size | Height comes from |
|---|---|---|---|
| 0 | Invisible top spacer | {1, 0}, {0, 6} | Offset height |
| 1 | Feature card | {1, 0}, {0, 0} | `UIAspectRatioConstraint` 4.81 |
| 2 | Section heading row | {1, 0}, {0, 62} | Offset height |
| 3 | `Passes` grid | {1, 0}, {0, 0} | `AutomaticSize = Y` |
| 4 | Invisible bottom spacer | {1, 0}, {0, 6} | Offset height |

The 6 px spacers plus the adjacent 19 px layout gaps give 25 px top and bottom margins. All spacer backgrounds are transparent. Additional sections go before the bottom spacer in layout order.

Each `UIAspectRatioConstraint` here uses `AspectType = ScaleWithParentSize` and `DominantAxis = Width`.

The `Passes` grid is a transparent `Frame` with a `UIGridLayout`:

| Property | Value |
|---|---|
| `CellSize` | {0.4866, 0}, {1, 0} |
| `CellPadding` | {0.0268, 0}, {0, 15} |
| `SortOrder` | LayoutOrder |

Parent a `UIAspectRatioConstraint` to the `UIGridLayout` itself with `AspectRatio` 2.328, `AspectType` ScaleWithParentSize and `DominantAxis` Width. That sizes every cell to 2.328:1 from the cell width. Without it, or with the default FitWithinMaxSize, the cells collapse to 1 × 1.

Keep grid row gaps in Offset. A Y scale on `CellPadding` measures against the grid's own automatic height, which depends on the padding.

### Feature card
A full-width card for the main offer. Fractions of the card:

| Element | Position | Size |
|---|---|---|
| Icon | {0.0117, 0}, {0.0513, 0} | {0.1876, 0}, {0.9026, 0} |
| Title | {0.2132, 0}, {0.0308, 0} | {0.2559, 0}, {0.2667, 0} |
| Multiplier | {0.306, 0}, {0.318, 0} | {0.3625, 0}, {0.5128, 0} |
| Buy button | {0.7431, 0}, {0.5077, 0} | {0.2281, 0}, {0.3333, 0} |

- The title is left-aligned and green (0, 244, 8).
- By default, the card holds its icon, title, multiplier and buy button. Add decorative icon rain only when requested. Put it behind the content inside a dedicated `CanvasGroup` within `Face`, and clip it there. Do not rely on `ClipsDescendants` alone for rotated images. Stop its animation while the window is hidden. Keep the text and purchase control unobstructed.

### Pass card
Fractions of the card:

| Element | Position | Size |
|---|---|---|
| Icon | {0.0396, 0}, {0.0205, 0} | {0.207, 0}, {0.482, 0} |
| Title | {0.2643, 0}, {0.1231, 0} | {0.7048, 0}, {0.2872, 0} |
| Description | {0.0485, 0}, {0.5333, 0} | {0.5683, 0}, {0.3179, 0} |
| Buy button | {0.6344, 0}, {0.5385, 0} | {0.3392, 0}, {0.3333, 0} |

The title and the description are left-aligned. The description has `TextWrapped = true` and fits two lines.

### Buy button
- The price label is a child of `Face` named `Price`, with `AnchorPoint` (0.5, 0.5), `Position` {0.52, 0}, {0.4737, 0} and `Size` {0.86, 0}, {0.807, 0}. It sits centered on the face, nudged right to balance the glyph.
- `Text` is `utf8.char(0xE002) .. price`, white.

### Button press
Every button in this theme is 3D. The face sits on the lip like a key. Pressing pushes the whole key down: the top edge drops, the lip collapses, and the face ends up resting on the bottom edge. This applies to buy buttons, the close button and any other button built as a raised block.

The motion has to be scripted. Put it in a client `LocalScript`, tag each button `RaisedButton` and wire every tagged button from that one script. The UI instances themselves only hold the rest state.

Tween the Y size of `Body` and `Face` together, with the same `TweenInfo`. `Body` is pinned to the bottom, so changing its height moves its top edge and its outline. `Face` gets the inverse scale, so its height in pixels never changes. It just rides up or down with the top edge, and the label inside it follows.

| State | `Body` Y size | `Face` Y size | Tween |
|---|---|---|---|
| Rest | 1 | faceHeight | 0.1 s, Quad, Out |
| Hover | 1.03 | faceHeight / 1.03 | 0.1 s, Quad, Out |
| Pressed | faceHeight | 1 | 0.05 s, Quad, Out |
| Released | back to Hover or Rest | same | 0.12 s, Back, Out |

| Button | faceHeight | Hover `Face` | Pressed `Body` |
|---|---|---|---|
| Buy button | 0.877 | 0.8515 | 0.877 |
| Close button | 0.8796 | 0.854 | 0.8796 |

- Pressed, the body is exactly as tall as the face, so the lip is gone and the face sits flush with the bottom edge.
- Hover raises the top edge by 3% of the button height, about 2 px on a buy button, and the lip grows by the same amount. It should be barely visible.
- Nothing ever shows above the face. Never move the face down inside a full-height body. That reveals a strip of lip color at the top and makes the button look upside down.
- On release, go back to Hover if the pointer is still over the button, otherwise to Rest.
- Drive press and release from `InputBegan` and `InputEnded` rather than `MouseButton1Down` and `MouseButton1Up`. Those miss the release when the pointer leaves the button while held.
- Touch has no hover. A tap goes Rest, Pressed, Rest.
- Only tween `Size` on `Body` and `Face`. Leave `Button` and every `Position` alone.

### HUD button press
Floating HUD icon buttons have no face or lip, so they use a scale bounce: bigger on hover, smaller on press. Small raised action controls such as "+" use `RaisedButton` and the 3D press instead.

- Give each HUD button its own `UIScale` named `PressScale`, with no tag. The tagged `UIScale` on the outer HUD frame belongs to `autoScaler`. Never tween that one. The two multiply, so the bounce works at any screen size.
- Tag the button `RaisedHudButton` and wire it from the same client `LocalScript` as the raised buttons.
- Set the button's `AnchorPoint` to (0.5, 0.5) so it grows and shrinks from its center.

| State | `PressScale.Scale` | Tween |
|---|---|---|
| Rest | 1 | 0.1 s, Quad, Out |
| Hover | 1.08 | 0.1 s, Quad, Out |
| Pressed | 0.92 | 0.05 s, Quad, Out |
| Released | back to Hover or Rest | 0.12 s, Back, Out |

The release, input-event and touch rules from Button press apply here too. Tween `PressScale.Scale`, never the button's `Size`.

### Notifications and value feedback
- A notification marks a real available action or unread state. Set its visibility from that condition when the UI loads and whenever the relevant value changes. Hide it when the action is no longer available.
- Raised badges use the same square face, dark lip and fading inner border as other blocks. At 1080p, start with a 3 px black outer stroke, 2.5 px white inner stroke and 2.5 px contextual text stroke. Keep the badge clear of neighboring labels and icons.
- When an attention shake is requested, rotate only the badge. A starting sequence is -18, 16, -12, 8, -4, 0 degrees, 0.06 s per step, once every 3 s while visible. Reset rotation when hidden.
- For animated currency gains, match the floating gain text to the counter's color gradient. Keep its travel clear of nearby prices and buttons. Use a separate untagged animation scale for counter pops so `autoScaler` retains control of the tagged scale.

### Hierarchy
```
ScreenGui
└─ Main                     (UIScale, OuterStroke)
   ├─ Header                (OuterStroke, Face, Icon, Title)
   ├─ Close                 (Body → Face → Label)
   └─ Content               (ScrollingFrame, UIListLayout, UIPadding)
      ├─ TopSpacer
      ├─ ServerLuck         (UIAspectRatioConstraint, OuterStroke, Face, Icon, Title, Multiplier, Buy)
      ├─ PassesTitle        (full-width heading row)
      ├─ Passes             (UIGridLayout with UIAspectRatioConstraint)
      │  └─ TripleRoll / VIP / ...   (OuterStroke, Face, Icon, Title, Description, Buy)
      └─ BottomSpacer
```

`Face` always holds `UIGradient` and `InnerStroke`. `Buy` and `Close` are buttons: an invisible `TextButton` holding `Body`, which holds `Face`, which holds the label. `Body` carries the `OuterStroke`.

### Checklist
- [ ] Every block has a lip, a gradient face, an `OuterStroke`, and an `InnerStroke` that fades toward the bottom.
- [ ] No `UICorner` and no pattern textures.
- [ ] Every text label is Montserrat Heavy or ExtraBold, with a black contextual stroke and a fixed `TextSize`.
- [ ] Every buy button is green and shows the Robux glyph and price in one label.
- [ ] Every raised button is an invisible `TextButton` holding `Body` and `Face`, tagged `RaisedButton`. A client script grows `Body` on hover and shrinks it to the face's height on press, with no lip color ever showing above the face.
- [ ] Decorative icon animation appears only when requested, clips inside the face and stays behind readable content.
- [ ] Every floating HUD icon button is tagged `RaisedHudButton` and has its own untagged `PressScale` that grows on hover and shrinks on press. Raised "+" controls use `RaisedButton` instead.
- [ ] `Content` uses `AutomaticCanvasSize = Y` and lays out its children with `UIListLayout` and `UIGridLayout`.
- [ ] `Main` is sized in Offset and has a tagged `UIScale`. Children use Scale except the documented list spacing and fixed-height rows.
- [ ] Icons come from `freeIconsPack.luau`, Robux and similar glyphs from `robloxCharacters.luau`.
- [ ] Each header and distinct reward card matches its icon's color. The example orange header has not spread to unrelated menus.
- [ ] HUD prices are green, text gradients have two smooth keypoints, and no HUD icon has a background tile.
- [ ] Notifications follow their availability condition, and value feedback does not cover adjacent prices.
- [ ] The final scroll row and its bottom margin are reachable. Direct aspect-ratio rows use full width with horizontal padding.

## BlockyStuds
This UI style is heavily inspired by derpmonster83's Dogs vs Cats TD, credits to them.

Flat, blocky menus on a dark gray body. A bright studded topbar carries the menu's color. Content sits on flat gradient cards with thin black outlines. Buttons mix two kinds:
- **Inside a frame:** 3D buttons with a dark lip, such as buy, equip and unequip.
- **Topbar and HUD:** 2D flat buttons that grow on hover and shrink on press, such as the close button, HUD icons and small badges on tiles.

### Units
- All pixel values below are 1080p pixels, measured from the reference screenshots.
- `Main` is sized in Offset with a tagged `UIScale`, `MinScale` 0.55, `MaxScale` 1.
- Build children in Scale by dividing each pixel value by its parent's pixel size. Fixed-height rows and gaps inside a `ScrollingFrame` follow the shared ScrollingFrame rules.
- No `UICorner` anywhere. Every corner is square.
- `ScreenGui`: `IgnoreGuiInset = true`, `ResetOnSpawn = false`, `ZIndexBehavior = Sibling`, `ScreenInsets = DeviceSafeInsets`.

### Dark shade
Every colored element has one dark shade of its own hue. Use it for that element's outline, its lip and the stroke on its text. Do not use black for these.

| Color | Fill | Dark shade |
|---|---|---|
| Red (close, unequip, sell) | (255, 92, 92) → (255, 69, 69) | (95, 14, 14) |
| Green (buy, equip) | (207, 255, 56) → (74, 255, 104) | (15, 84, 22) |
| Pink (gift badge) | (245, 137, 255) | (106, 33, 93) |

For a new hue, take the fill and multiply each channel by about 0.35.

Panels, cards, the topbar and plain text use black (0, 0, 0) outlines and strokes instead.

### Window
`Main` is an invisible frame holding the topbar and the body. The topbar sticks out past the body on both sides.

| Element | Size | Placement |
|---|---|---|
| Topbar row | full `Main` width, 64 tall | top of `Main` |
| Body | `Main` width minus 20, rest of the height | centered under the topbar, sharing its bottom outline |
| Side panel (optional) | 254 wide | 16 to the right of the body, top 4 below the body's top, bottom 6 above it |

The topbar sticks out 10 px past the body on each side. The reference inventory body is 653 × 441, the shop body 652 × 505.

Body:

| Property | Value |
|---|---|
| `BackgroundColor3` | (49, 50, 51) |
| `BackgroundTransparency` | 0.1 |
| Outline | `UIStroke`, black, 2, `BorderStrokePosition` Outer |
| Pattern | none |

A side panel is a second body: same color, same outline, no topbar. Use it for details of the selected item.

### Topbar
The topbar is 2D: flat, no lip, no inner white stroke.

| Property | Value |
|---|---|
| Height | 64, including the outline |
| Fill | the menu's color, as a `UIGradient` with `Rotation = 90`, lighter top to darker bottom |
| Outline | `UIStroke`, black, 2, Outer |
| Pattern | `Stud` from `surfaceTypes.luau` (`rbxassetid://12055407192`), `ScaleType` Tile, `TileSize` {0, 60}, {0, 60}, `ImageTransparency` 0.75 |

One stud tile image is 60 px, so the 60 px tall fill shows two rows of studs.

The topbar's color comes from the menu's icon, following the shared Color identity rules. Every menu gets its own topbar color. Reference fills:

| Menu | Top | Bottom |
|---|---|---|
| Inventory (orange) | (255, 171, 69) | (253, 133, 35) |
| Shop (magenta) | (255, 102, 252) | (215, 61, 255) |

Topbar contents, left to right:
- **Icon (optional):** fills the left 64 × 64 square, in its normal colors.
- **Title:** starts 72 px from the topbar's left edge, with or without an icon. Left-aligned, vertically centered.
- **Close button:** the right end of the topbar row, a 64 × 64 square. The topbar fill stops where it starts.

### Close button
2D, flat red square. It grows and shrinks with the 2D motion, never the 3D press.

| Property | Value |
|---|---|
| Size | 64 × 64 |
| Fill | red gradient (255, 92, 92) → (255, 69, 69) |
| Outline | `UIStroke`, (95, 14, 14), 2, Outer |
| Label | "X", white, `TextSize` 52, stroke (95, 14, 14) 4 |

### Content cards
Cards inside the body are flat, with no lip and no inner white stroke.

| Property | Value |
|---|---|
| Fill | `UIGradient`, `Rotation = 90`, lighter top to darker bottom |
| Outline | `UIStroke`, black, 1, Outer |
| Pattern | none |

| Card | Top | Bottom |
|---|---|---|
| Featured offer (gold) | (255, 239, 62) | (255, 149, 56) |
| Gamepass group (blue) | (57, 222, 255) | (65, 132, 255) |
| Luck (green) | (167, 255, 67) | (90, 210, 60) |

Match each card to what it sells, following Color identity. Don't scatter decorative icons over cards.

### Text
- Font is Montserrat (`rbxasset://fonts/families/Montserrat.json`). Titles, buttons and numbers use `ExtraBold`. Section headings and detail lines use `Bold`.
- Text is white (255, 255, 255) with a `UIStroke` (`ApplyStrokeMode = Contextual`, `LineJoinMode = Round`).
- Text on a colored button uses that button's dark shade for its stroke. All other text uses black.

| Text | `TextSize` | Weight | Stroke |
|---|---|---|---|
| Window title | 32 | ExtraBold | black 3 |
| Close "X" | 52 | ExtraBold | dark shade 4 |
| Section heading ("Gamepasses!") | 22 | Bold | black 1.5 |
| Card title | 32 | ExtraBold | black 3 |
| Card subtitle | 22 | Bold | black 2 |
| Price on a buy button | 26 | ExtraBold | dark shade 2.5 |
| Action button ("UNEQUIP") | 30 | ExtraBold | dark shade 3 |
| Tile label ("VIP!") | 26 | ExtraBold | black 2.5 |
| Item count ("x3") | 24 | ExtraBold | black 2.5 |
| Item name | 26 | ExtraBold | black 2 |
| Item price ("$120") | 28 | ExtraBold | black 2.5 |
| Detail line ("Placement Limit: 3") | 20 | Bold | black 1.5 |

- Section headings are left-aligned with the cards' left edge and sit directly above their card.
- Text fill is flat white. Don't put gradients on text in this theme.

### 3D buttons
Buttons inside the body or a side panel are 3D. Build them like Raised buttons: an invisible `TextButton` holding `Body`, which holds `Face`, which holds the label. Press them with Raised's Button press motion, tagged `RaisedButton`.

Differences from Raised:
- The lip is 6 px of the button's dark shade.
- The outline is 2 px of the same dark shade, not black.
- No white inner stroke.

| Button | Size | faceHeight |
|---|---|---|
| Buy button on a card | 164 × 60 | 0.9 |
| Buy button under a tile | 143 × 60 | 0.9 |
| Side panel action | 230 × 75 | 0.92 |

- Buy buttons are always green and show `utf8.char(0xE002) .. price` in one label.
- A side panel action button spans the panel minus 12 px on each side and sits 12 px above the panel's bottom. Color it by what it does: red to unequip, sell or remove, green to equip or buy.

### 2D buttons
The close button, topbar buttons, HUD icons and small badges on tiles are 2D. They have no lip and don't use the 3D press. Use Raised's HUD button press motion: an untagged `UIScale` named `PressScale` on each button, tag `RaisedHudButton`, 1.08 on hover and 0.92 on press.

### Shop layout
The body holds a `ScrollingFrame` that follows the shared ScrollingFrame rules.

| Property | Value |
|---|---|
| Content margin | 9 px left of the cards, 9 px top |
| Card width | body width minus 32 (620 in the reference) |
| Scroll bar | `ScrollBarThickness` 12, `ScrollBarImageColor3` white, `ScrollBarImageTransparency` 0 |
| Gap between a card and the next heading | 14 |
| Gap between a heading and its card | 6 |

Featured offer card, 620 × 141:
- Title and subtitle left-aligned, 16 px from the left. The title's top sits about 45 px down, and the subtitle follows directly under it.
- The offer's icon, about 130 px, sits in the middle.
- The buy button, 164 × 60, sits 12 px from the right edge and 11 px from the bottom.

Gamepass group card: one blue card holding a row of tiles, each with a buy button under it.

| Part | Value |
|---|---|
| Columns | 4, 155 px apart |
| Tile | 124 × 123, black at `BackgroundTransparency` 0.5, no outline, 18 px below the card's top |
| Tile icon | fills the tile |
| Tile label | bottom of the tile, centered |
| Gift badge | 40 × 40 pink square in the tile's top-right corner, flush with both edges, outline (106, 33, 93) 2, gift icon in its normal colors |
| Buy button | 143 × 60, centered under its tile, 7 px below it |
| Bottom padding | 13 |

If there are fewer passes than columns, leave the row short. Don't add filler passes.

### Inventory layout
- Items sit in a grid in the body, 124 px apart, starting 14 px in from the body's top-left.
- An item is only its icon, about 100 px. No card, tile or background behind it.
- An equipped item gets a green check badge in the icon's top-right corner, about 37 px.
- The count ("x3") sits at the icon's bottom-right corner.
- The side panel shows the selected item, top to bottom: its icon (about 100 px, centered), price, name, detail lines, stats with a small icon, and the action button at the bottom.

### HUD
HUD elements follow the shared HUD rules: floating icons and labels with no background, 2D, using the motion from 2D buttons. Don't put studded tiles or colored squares behind HUD icons.

### Hierarchy
```
ScreenGui
└─ Main                     (UIScale)
   ├─ Topbar                (UIGradient, Stud pattern, UIStroke, Icon, Title)
   ├─ Close                 (UIGradient, UIStroke, Label, PressScale)
   ├─ Body                  (UIStroke)
   │  └─ Content            (ScrollingFrame, UIListLayout, UIPadding)
   │     ├─ StarterHeading
   │     ├─ StarterPack     (UIGradient, UIStroke, Icon, Title, Subtitle, Buy)
   │     ├─ PassesHeading
   │     └─ Passes          (UIGradient, UIStroke, tiles and Buy buttons)
   └─ SidePanel             (optional, UIStroke, details, Action)
```

`Buy` and `Action` are 3D: an invisible `TextButton` holding `Body`, which holds `Face`, which holds the label.

### Checklist
- [ ] The topbar is flat and studded, with a `Stud` tile at {0, 60}, {0, 60}, and its color matches the menu's icon.
- [ ] The topbar sticks out 10 px past the body on each side, with a 64 × 64 red close button at its right end.
- [ ] The body is dark gray (49, 50, 51) at 0.1 transparency with a 2 px black outline and no pattern.
- [ ] Cards are flat gradients with a 1 px black outline. Nothing has a white inner stroke or a `UICorner`.
- [ ] Buttons inside frames are 3D with a 6 px lip, a 2 px outline and a text stroke, all in the button's dark shade.
- [ ] The close button, topbar buttons, HUD icons and tile badges are 2D and use `PressScale`.
- [ ] Text is flat white Montserrat with a fixed `TextSize` and no gradient.
- [ ] Inventory items have no background tile.
