---
name: scaleable-ui
description: Make Roblox UI scale between phone and PC screens with the autoScaler module and tagged UIScales.
disable-model-invocation: false
---

# Scaleable UI
This skill makes UI keep the same proportions on every screen size. You design each window once, in pixels, for a 1080p screen. The `autoScaler` module then shrinks or grows it to fit smaller and larger screens.

The module lives in `resources/scripts/autoScaler.luau`.

## How the module works
- It only runs on the client. On the server it does nothing and returns `nil`.
- It watches every instance tagged `UIScale` through `CollectionService`, including ones added or removed later.
- It reads the camera's `ViewportSize.Y` and maps it onto each tagged `UIScale`:

| Screen height | `UIScale.Scale` |
|---|---|
| 393 px or less (phone) | `MinScale` |
| 1080 px or more (PC) | `MaxScale` |
| In between | Linear between the two |

- It updates again whenever the viewport size changes, so resizing the window or rotating a phone works without extra code.

## Setup

### 1. Add the module
Copy `autoScaler.luau` into the game as a `ModuleScript`, for example `ReplicatedStorage.Modules.AutoScaler`. Copy it as-is.

### 2. Require it once on the client
Require it from a client script that runs once, such as a `LocalScript` in `StarterPlayer.StarterPlayerScripts`:

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Modules.AutoScaler)
```

The module returns `nil`. Requiring it is all the setup it needs. Do not require it from `execute_luau` while building UI in Studio.

### 3. Size outer-most frames with Offset
Every frame directly under a `ScreenGui` uses Offset for its `Size`, measured as it should look on a 1080p screen.

| Do | Don't |
|---|---|
| `Size = UDim2.fromOffset(500, 300)` | `Size = UDim2.fromScale(0.5, 1)` |

- `Position` can still use Scale with an `AnchorPoint`, for example `AnchorPoint` (0.5, 0.5) and `Position` {0.5, 0}, {0.5, 0} to center it.
- Everything inside the outer frame can use Scale, Offset or both. All of it scales with the outer frame.
- Do not put a `UIAspectRatioConstraint` on an outer frame that has an Offset size. The size already fixes its shape.

### 4. Add a tagged UIScale
Put a `UIScale` directly under each outer-most frame:

| Property | Value |
|---|---|
| Name | `UIScale` |
| Tag | `UIScale` |
| Attribute `MinScale` (number) | Size on a phone. Defaults to 0.75 if missing. |
| Attribute `MaxScale` (number) | Size on a 1080p screen. Defaults to 1 if missing. |

Without the `UIScale` tag, the module ignores it.

### 5. Tune MinScale and MaxScale
- `MaxScale` is how the frame looks on a 1080p screen. Leave it at 1 if you sized the frame for 1080p.
- `MinScale` is how it looks on a phone. Lower it until the frame fits a phone screen with room around it. A big window usually needs 0.5 to 0.6. A small HUD element can stay near 0.75 so it stays readable.
- Set both as attributes on the `UIScale`, not in code.

## Hierarchy
```
ScreenGui
└─ Main                     (Size in Offset, e.g. {0, 500}, {0, 300})
   ├─ UIScale               (tag UIScale, MinScale, MaxScale)
   └─ ...                   (children in Scale or Offset)
```

## Notes
- `UIScale` also scales `UIStroke.Thickness`, `UICorner` radii and text, so pixel strokes keep their proportions on every screen.
- Because text scales too, use a fixed `TextSize` measured at 1080p instead of `TextScaled`. Text then stays the same size relative to the window, and labels of the same kind match.
- A frame nested inside another scaled frame does not need its own `UIScale`. Two tagged scales on the same branch multiply.
- Check the result with the Studio device emulator on a phone preset and on a 1080p preset.

## Checklist
- [ ] `AutoScaler` is required once, from a client script.
- [ ] Every frame directly under a `ScreenGui` has an Offset `Size` measured at 1080p.
- [ ] Each of those frames has a `UIScale` child tagged `UIScale`, with `MinScale` and `MaxScale` attributes.
- [ ] No `UIAspectRatioConstraint` on an outer frame sized in Offset.
