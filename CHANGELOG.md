# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Only changes that are verifiable in this repository are recorded here. No earlier version history or release date
exists for the pre-release baseline described at the end of this file.

## [Unreleased]

_Nothing yet._

## [1.0.0] - 2026-09-21

**AbsJson 1.0.0 — Initial Stable Release** (Git tag `v1.0.0`). First stable, public release under the MIT License.

Verified status: the test suite (`Scripts/TestAbsJson/TestAbsJson.mq5`, 95 tests) passed completely
(95 passed, 0 failed) in a MetaTrader 5 Build 6257 run reported by the maintainer. The changes below are listed relative to the
pre-release baseline.

### Added

- Hash index in `CAbsJsonObject` (used from 16 properties on) for O(1) average lookup, duplicate detection and `Set()`.
- `CAbsJsonProperty::SetName()` now returns `bool` and refuses a name that already exists in the owning object; the owning object keeps its index consistent after a rename.
- Parser: nesting limit (`AbsJsonConst::MAX_DEPTH`, 256) with the new error code `ABS_JSON_ERROR_DEPTH_EXCEEDED`.
- Parser: errors now carry line, column and character position.
- Parser: a leading U+FEFF byte-order mark is skipped.
- New error code `ABS_JSON_ERROR_IO`, used for file open / read / write failures.
- `CAbsJsonNumber::GetNumberType()` (returns `ENUM_ABS_JSON_NUMBER_TYPE`), `CAbsJsonNumber::FitsInLong()`.
- `CAbsJsonWriter::SetFormat()` and `CAbsJson::ToString(ENUM_ABS_JSON_FORMAT, indentSize)` (use `ENUM_ABS_JSON_FORMAT`).
- Deep-copy semantics for `CAbsJsonValue` (copy constructor and `operator=`) and `CAbsJsonProperty::operator=`.
- `CAbsJsonObject::GetArray(name, array)` is now implemented.
- 22 new tests: `TestRegression.mqh` (14) and `TestExtended.mqh` (8), covering escaping, double round trip, nested `ToString`, depth limit, error positions, duplicate-key error code, BOM, number / escape utilities, surrogate pairs, container editing, repeated cycles, UTF-8 file round trip, large-object index, rename, value assignment, number type, output format and double formatting.
- Documentation and project files: `README.md` (English), `README.fa.md` (Persian), `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE` (MIT), GitHub issue / pull-request templates, `.gitignore`, `.gitattributes`, `docs/RELEASE_CHECKLIST.md`, `docs/RELEASE_NOTES_v1.0.0.md`.
- Source headers carry an `SPDX-License-Identifier: MIT` line and a release-version note (`#property version "1.00"` is the MQL5 "major.minor" form of 1.0.0).

### Changed

- All source and test documentation translated from Persian to English and rewritten as Doxygen-style comments (parameters, return values, failure conditions, ownership). Three Persian/CJK strings remain intentionally as Unicode test data.
- `ToString()` of `CAbsJsonValue`, `CAbsJsonObject` and `CAbsJsonArray` is implemented in `AbsJsonWriter.mqh` on top of `CAbsJsonWriter`, so every serialization path produces identical output. As a consequence, include `AbsJson.mqh` rather than individual headers.
- Doubles are written with `%.15g`, falling back to `%.17g`, so they parse back to the identical value (previously limited to 8 decimals). NaN and ±infinity are written as `null`.
- `SaveFile()` writes UTF-8 without BOM (previously UTF-16). `LoadFile()` reads UTF-8 with or without BOM and UTF-16 LE with BOM, so files written by the previous behavior still load.
- `CAbsJsonNumber::IsInteger()`, `IsDouble()`, `IsNumber()` use the strict RFC 8259 grammar (for example `007` and `1e` are no longer accepted); `ParseInteger()` / `ParseLong()` check the range.
- Parser: values are parsed directly into the property instead of being deep-copied once per nesting level; long string runs are copied in blocks.
- Parser: duplicate property names are reported as `ABS_JSON_ERROR_DUPLICATE_PROPERTY` (previously `ABS_JSON_ERROR_OUT_OF_MEMORY`).
- `CAbsJsonNode` lists no longer delete elements themselves; the node deletes each child exactly once.
- Failed `Add` / `Insert` / allocation paths free what they allocated; documented ownership rules for every pointer-taking method.
- The writer's pretty output keeps its previous layout; empty containers are written as `{}` / `[]`.
- Facade `Parse()` parses directly into `Root()` (no intermediate deep copy).
- Test runner: leftover ad-hoc functions renamed to `ExampleParseAndRead`, `ExampleParseError`, `ExampleMinifyAndPrettyPrint`; a stray `BeginTest` call was removed.
- The low-level parser methods (`ParseValue`, `ParseString`, `ParseNumber`, `ParseBoolean`, `ParseNull`) are private; use `Parse()`.

### Fixed

- `CAbsJsonValue::ToString()` returned an empty string for objects and arrays and did not escape strings; `CAbsJsonProperty::ToString()` did not escape the name.
- The writer did not escape control characters below U+0020, which produced invalid JSON.
- `CAbsJsonClone::Value` leaked an allocated object and could dereference `NULL` on some failure paths.
- `SetObject()` / `SetArray()` on a value that already held the same pointer caused a use-after-free.
- `CAbsJsonObject::SetProperty()` with a property that is already stored in the object deleted the stored property.
- `CAbsJsonObject::GetArray(name, array)` always returned `false`.
- `AbsJsonConst::MAX_DEPTH` existed but was never enforced.
- Assigning a `CAbsJsonValue` with `=` copied raw pointers (double delete); now a deep copy.

### Removed

- `ENUM_ABS_JSON_TOKEN` (never used).
- The `TestAbsJson.ex5` binary that was shipped in the source tree (build it from `TestAbsJson.mq5`).

## Pre-release baseline

The project as received for the audit: the `Include/AbsJson` library (header version `1.00`) with a test script folder `Scripts/TestAbsJson` and a compiled `TestAbsJson.ex5`. Source comments were largely in Persian. No dated release history is available.
