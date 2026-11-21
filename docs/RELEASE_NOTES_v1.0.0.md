# AbsJson 1.0.0 — Initial Stable Release

Released 2026-09-21 · tag `v1.0.0` · MIT License · <https://mql5.ab-studio.ir>

AbsJson is a JSON library for MQL5 (MetaTrader 5): a parser, a writer, an object model (objects, arrays, typed values),
deep copy, error reporting with line / column / position, and UTF-8 file I/O. Use it with a single include:

```cpp
#include <AbsJson/AbsJson.mqh>
```

## Highlights

- RFC 8259 grammar; strict rejection of malformed input (trailing commas, leading zeros, control characters in strings, extra data, duplicate property names, nesting deeper than 256 levels).
- Typed values: null, string, integer, long, double, boolean, object, array.
- Hash-indexed objects (from 16 properties) for fast lookup.
- Round-trip-exact doubles; correct escaping of all control characters.
- Compact and pretty output; deep copy; validation; file save / load (UTF-8, common folder).
- 95 unit tests in `Scripts/TestAbsJson`.

## Requirements

MetaTrader 5, MetaEditor 5, MQL5 compiler. Tested with **MetaTrader 5 Build 6257** (the verified environment, not a stated minimum).

## Testing status

All 95 tests passed (0 failed) in a MetaTrader 5 Build 6257 run reported by the maintainer.

## Installation

Copy `Include/AbsJson` into `MQL5/Include/`. See `README.md` for details. Persian documentation: `README.fa.md`.

Full list of changes: see `CHANGELOG.md`.
