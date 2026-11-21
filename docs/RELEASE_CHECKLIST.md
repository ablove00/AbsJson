# Release checklist — AbsJson 1.0.0

Internal notes for the maintainer.

## Decisions (final)

| Item | Decision |
|---|---|
| License | MIT — `LICENSE`, copyright (c) 2026 Amir Bagheri Studio (the holder named in every source header) |
| Version | 1.0.0 (Semantic Versioning). `#property version` stays `"1.00"` because MQL5 only accepts the "major.minor" form |
| Git tag | `v1.0.0` |
| Release title | AbsJson 1.0.0 — Initial Stable Release |
| Release date | 2026-09-21 (as specified by the maintainer) |
| Tested environment | MetaTrader 5 Build 6257 (verified environment, **not** a stated minimum) |
| Official website | https://mql5.ab-studio.ir |

## Verification status

- Maintainer-reported: 95 tests passed, 0 failed, MetaTrader 5 Build 6257 (build number as stated by the maintainer).
- A further complete run was reported with its full log (timestamp 2026-11-21 11:36, symbol/timeframe GBPAUD_o,H1): all 95 tests `[PASS]`, `Passed : 95`, `Failed : 0`, followed by the usage examples (including the intentional `Expected parse error : …` line). The log does not record the terminal build.
- Not executed by the documentation tooling (no MetaTrader 5 / MetaEditor there). Static check: 95 tests are registered in `Scripts/TestAbsJson`.
- README code snippets were written from the implemented API and the calls the tests exercise; they were not compiled as separate programs.

## Before tagging

- [ ] Confirm the release date: it is 2026-09-21 in all documents, while the test log above is dated 2026-11-21. If the tag is created on a later day, decide whether the documents should keep that date or be updated.
- [ ] If the last run was not made from the final release files (clean clone), repeat it and confirm `Passed : 95` / `Failed : 0`.
- [ ] Compile the README snippets in a scratch script (optional but recommended).
- [ ] Create the tag: `git tag -a v1.0.0 -m "AbsJson 1.0.0 — Initial Stable Release"` and push it.
- [ ] Create the GitHub release from the tag, title *AbsJson 1.0.0 — Initial Stable Release*, body from `docs/RELEASE_NOTES_v1.0.0.md`.
- [ ] Attach a zip containing `Include/AbsJson` (and optionally `Scripts/TestAbsJson`). Do not attach `.ex5` files.

## Suggested GitHub repository metadata

- **Description:** `JSON library for MQL5 (MetaTrader 5): parser, writer, object model, deep copy and UTF-8 file I/O.`
- **Website:** `https://mql5.ab-studio.ir`
- **Topics:** `mql5`, `metatrader5`, `mt5`, `json`, `json-parser`, `json-serializer`, `library`, `algorithmic-trading`
- **Features:** Issues on; Discussions optional; Wiki off unless used.
- **License:** GitHub detects MIT from `LICENSE` automatically.
- **Branch protection (optional):** require a pull request and a reported test run before merging to `main`.

## Ideas after 1.0.0

- Dedicated tests for malformed-structure errors and for each error code.
- An `Examples/` script folder built from the README snippets.
- A benchmark section, only after measuring.
