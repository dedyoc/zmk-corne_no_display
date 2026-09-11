# Keymap Reference

Generated reference for `config/corne.keymap`. Update when the keymap changes.

## Hardware

- **Shield:** `corne_left` / `corne_right` (foostan Corne, no display)
- **Board:** nice!nano v2 (nRF52840)
- **Matrix transform:** `&default_transform` (6-column / 42-key).
  `&five_column_transform` is present but commented out.

## Key positions (0-41)

`hold-trigger-key-positions` and combos index by these numbers.

```
  0   1   2   3   4   5  │   6   7   8   9  10  11
 12  13  14  15  16  17  │  18  19  20  21  22  23
 24  25  26  27  28  29  │  30  31  32  33  34  35
         36  37  38      │  39  40  41
```

Shape per layer: **12 / 12 / 12 / 6 = 42 bindings**.

Left half = 0-5, 12-17, 24-29, 36-38.
Right half = 6-11, 18-23, 30-35, 39-41.

## Layers

Layer numbers are what `&lt` / `&mo` reference. Order in the file *is* the index.

| # | Node             | display-name | Reached by                      |
|---|------------------|--------------|---------------------------------|
| 0 | `default_layer`  | QWERTY       | base                            |
| 1 | `lower_layer`    | NUMBER       | `&lt 1 TAB` (left thumb, pos 37)  |
| 2 | `raise_layer`    | SYMBOL       | `&lt 2 ENTER` (right thumb, pos 39) |
| 3 | `fn_layer`       | Fn           | `&lt 3 BSPC` (right thumb, pos 40)  |
| 4 | `mouse_layer`    | MOUSE        | `&lt 4 SPACE` (left thumb, pos 38)  |
| 5 | `sprint_layer`   | FAST         | `&mo 5` (mouse layer pos 4)         |
| 6 | `precision_layer`| SLOW         | `&mo 6` (mouse layer pos 3)         |

Layers 5 and 6 are **signal layers**: every position is `&trans` and they carry
no bindings at all. Their only purpose is to activate the layer-scoped
`input-processors` overrides on `&mmv_input_listener` / `&msc_input_listener`
at the top of `corne.keymap`, which rescale pointer output while held. Because
they are fully transparent, the mouse layer stays completely usable underneath
— move, scroll, click and the sticky mods all keep working. Adding a real
binding to either layer would shadow the mouse-layer key at that position.

## Cursor speed

Movement is `&mmv`, whose stock ramp is 600 units/s reached over 300ms with
`acceleration-exponent = 1` (linear). The two speed keys scale that output
rather than replacing it, so they multiply whatever the ramp has reached:

| Hold (on mouse layer) | Cursor | Scroll |
|-----------------------|--------|--------|
| nothing               | 1x     | 1x     |
| pos 4 (`R` slot)      | 4x     | 3x     |
| pos 3 (`E` slot)      | 1/4    | 1/3    |

Both stock scalers (`zip_xy_scaler`, `zip_scroll_scaler`) set
`track-remainders`, which is what makes the dividing case work: without it the
small per-tick deltas would floor to zero and the cursor would stutter or stop.

Sprint is declared before precision in the listener node, so holding both at
once resolves to sprint — first matching override wins.

To retune, change the `<multiplier divisor>` cells on the relevant override.

## Thumb cluster (layer 0)

| pos | binding        |
|-----|----------------|
| 36  | `&kp ESC`      |
| 37  | `&lt 1 TAB`    |
| 38  | `&lt 4 SPACE`  |
| 39  | `&lt 2 ENTER`  |
| 40  | `&lt 3 BSPC`   |
| 41  | `&kp DEL`      |

## Home-row mods

"Timerless" hold-taps in urob's style (since 2026-09-09), guarded by
`hold-trigger-key-positions` so only opposite-hand keys can trigger the hold.

- `hml` (left, positions 13-16): `LGUI A`, `LALT S`, `LSHFT D`, `LCTRL F`
- `hmr` (right, positions 19-22): `RCTRL J`, `RSHFT K`, `RALT L`, `RGUI '`

Both carry the same properties:

| Property | Value | Why |
|---|---|---|
| `flavor` | `balanced` | |
| `tapping-term-ms` | 280 | Long on purpose — only applies after a pause. |
| `require-prior-idle-ms` | 150 | The load-bearing one: a key pressed within 150ms of another resolves instantly as a tap, so fast typing never sees a modifier or a delay. |
| `quick-tap-ms` | 175 | Repeat-tap the same key without a hold. |
| `hold-trigger-on-release` | set | Defers the positional check to release, which is what allows same-hand mod combos. |

Tuning levers: same-hand false mods -> raise `tapping-term-ms`; cross-hand false
mods -> raise `require-prior-idle-ms`; missed mods when typing fast -> lower
`require-prior-idle-ms`.

Each list covers the *opposite* half only, thumbs included — so a home-row mod
cannot be triggered by a key on its own hand, including that hand's thumb keys.
`Ctrl+Backspace` works because Backspace is a right thumb and `LCTRL` is left
`F`; the same-hand equivalent does not.

## Symbol layer (layer 2)

Not a stock arrangement — worth having written down:

```
  `   ~   #   &   |   │   ^   {   }   ;   -   -
  !   _   :   =   "   │   @   (   )   [   ]   -
  %   ?   *   +   \   │   /   -   <   >   $   -
```

Dashes are `&trans` (no effect on this layer). Note `-` and `_` sit on opposite
halves, as do `=` and `+`.

## Behaviors

| Name  | Type          | Notes                                                |
|-------|---------------|------------------------------------------------------|
| `td0` | tap-dance     | tap = `&caps_word`, double-tap = `&kp CAPS`          |
| `hml` | hold-tap      | left home-row mods, `balanced`, timerless (see above) |
| `hmr` | hold-tap      | right home-row mods, `balanced`, timerless           |
| `osm` | sticky-key    | 1000ms release, `lazy` + `ignore-modifiers` + `quick-release` |

## Macros

Terminal-friendly clipboard bindings on the left edge column of layer 0:

| Name    | Position | Sends            |
|---------|----------|------------------|
| `paste` | 0        | `Shift+Insert`   |
| `copy`  | 12       | `Ctrl+Insert`    |
| `cut`   | 24       | `Shift+Delete`   |

The `combos` node exists but is **empty** (bracket combos were removed in
commit `6b33dbb`).

## Notable bindings

- Position 11 (top-right) is `&trans` — free. It held `&soft_off` until
  2026-09-09, but that behavior needs `CONFIG_ZMK_PM_SOFT_OFF=y` (which was
  never set, so it silently did nothing) and the corner is easy to mis-hit
  next to Backspace. `CONFIG_ZMK_SLEEP` is a *different* feature: automatic
  deep sleep on idle, which is enabled and working.
- Position 23 (right pinky, home row outer) is also `&trans` and free. On a
  stock Corne this is `'`, which here moved inward to pos 22 as `&hmr RGUI '`.
- `&bootloader` on layer 3 pos 30 only. Layer 4's copy at pos 29 was removed in
  `634dcfe`: layer 4 is held with the space thumb, so space+`B` fired it
  mid-typing. Layer 3's is cross-hand from its layer key and is kept.
- `&sys_reset` on layer 3 pos 16.
- Bluetooth profile select on layer 1 row 2; `&bt BT_CLR_ALL` at pos 13.
- RGB controls on layer 1 row 3.
- Mouse move/scroll and `&mkp` buttons on layer 4; needs `CONFIG_ZMK_POINTING=y`.
- Cursor speed keys on layer 4 pos 3/4 (`&mo 6` / `&mo 5`) — see "Cursor speed".
