# Contributing to AbsJson

Thank you for your interest in improving AbsJson. This guide explains how to report problems, propose features and
submit changes. AbsJson is an MQL5 library, so there is no external build system: a change is validated by compiling in
MetaEditor 5 and running the test script in MetaTrader 5.

- Project website: <https://mql5.ab-studio.ir>
- Current version: 1.0.0 (see [CHANGELOG.md](CHANGELOG.md))
- License: [MIT](LICENSE)

## Contribution workflow

1. **Discuss first** for anything larger than a small fix: open an issue describing the problem or the proposed API.
2. **Fork** the repository and create a topic branch from `main` (for example `fix/escape-control-chars`).
3. **Set up** the development environment (see below), make your change, and add or update tests.
4. **Verify**: compile with 0 errors and run `TestAbsJson` (all tests must pass).
5. **Update the documentation**: Doxygen comments, `README.md` **and** `README.fa.md` when public behavior changes, and an entry under `[Unreleased]` in `CHANGELOG.md`.
6. **Open a pull request** against `main`, fill in the pull request template, and include the final `Passed` / `Failed` lines of your test run.
7. Respond to review comments. Reviewers check correctness, memory ownership, API consistency and tests first.

Keep pull requests focused: one logical change per pull request.

## Development setup

1. Copy `Include/AbsJson` to `<MQL5 data folder>/Include/AbsJson`.
2. Copy `Scripts/TestAbsJson` to `<MQL5 data folder>/Scripts/TestAbsJson`.
   (A symbolic link / junction from your clone to these folders avoids copying after every change.)
3. Open `TestAbsJson.mq5` in MetaEditor 5, compile with F7, run the script in MetaTrader 5 and read the **Experts** tab.

## Reporting bugs

Open an issue using the *Bug report* template and include:

- the JSON input (or a minimal piece of MQL5 code) that reproduces the problem;
- the expected and the actual result, including `GetStatus().FullMessage()` when a parse fails;
- your MetaTrader 5 build number and operating system;
- whether `TestAbsJson` passes on your machine.

Security-relevant problems (for example memory corruption reachable from crafted JSON) should not be posted in a public issue. Use GitHub's private vulnerability reporting if it is enabled for the repository;
otherwise contact the maintainers through the official website <https://mql5.ab-studio.ir>.

## Requesting features

Open an issue using the *Feature request* template. Describe the use case first, then the proposed API. Please check the
*Limitations* section of the README: streaming, JSON Path / Pointer and schema validation are known gaps, not bugs.

## Pull request guidelines

Before opening a pull request, make sure that:

- [ ] the project compiles without errors and without new warnings;
- [ ] `TestAbsJson` reports `Failed : 0` and you have pasted the summary lines in the description;
- [ ] new behavior and bug fixes have tests (success **and** failure paths);
- [ ] every new or changed public class, method, parameter and return value is documented;
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]` (Added / Changed / Fixed / Removed);
- [ ] `README.md` and `README.fa.md` are updated together when the public API or behavior changes;
- [ ] no non-English text remains in source comments or documentation, except intentional Unicode test data;
- [ ] you did not add compiled files (`*.ex5`) or unrelated formatting changes.

## MQL5 coding conventions

- **Language:** valid MQL5 with `#property strict`. Do not use C++ / Java-only constructs.
- **Entry point:** users include only `AbsJson.mqh`. Add new headers there, in dependency order.
- **Naming:** classes `CAbsJson…`, members `m_…`, include guards `__ABS_JSON_…_MQH__`, files `AbsJson….mqh`.
- **File format:** UTF-8 with BOM and CRLF line endings, as saved by MetaEditor (see `.gitattributes`).
- **File header:** keep the standard banner (copyright, official website link, `// SPDX-License-Identifier: MIT`, `#property` lines). `#property version` stays `"1.00"` (the MQL5 "major.minor" form of release 1.0.0); the library release number is tracked in `CHANGELOG.md`.
- **Errors:** no exceptions. Record failures in the status object (`SetError` in classes derived from `CAbsJsonBase`) and return `false`. Prefer an existing error code; append new codes at the **end** of `ENUM_ABS_JSON_ERROR` so existing numeric values stay stable.
- **Memory:** every `new` has exactly one owner. Document ownership transfer, free everything you allocated on every failure path, and never return pointers to temporaries.
- **Const correctness:** use `const` for parameters and methods that do not modify state, as far as MQL5 supports it.
- **No unproven claims:** do not state RFC compliance or performance results that tests or measurements do not support.

## Documentation standards

- Doxygen-style `/** … */` comments for every class, method, parameter, return value and member variable (`@brief`, `@param`, `@return`). State failure conditions, limits and ownership explicitly.
- Documentation language is English. The Persian README (`README.fa.md`) mirrors the English one: same structure, same facts, same code; only the explanatory text is translated.
- Code snippets in documentation must use the real API and should be compilable; keep identifiers, class names, method names and file names untranslated.
- Use Semantic Versioning and the Keep a Changelog format for `CHANGELOG.md`; do not record changes that did not happen.

## Testing requirements

Tests live in `Scripts/TestAbsJson`.

- Add `bool TestXxx()` returning `true` on success, using the helpers in `TestHelper.mqh` (`AssertEqual`, `AssertTrue`, `AssertFalse`, `AssertNull`, `AssertNotNull`).
- Register it with `RunTest("Name",TestXxx());` in the `RunTest…()` function of its group file, or add a new `Test….mqh` group and call its runner from `TestAbsJson.mq5`.
- Cover failure paths as well as success paths: invalid input, boundary values, empty containers, error codes.
- Tests that use files must use names starting with `AbsJson`, work in the common folder (`FILE_COMMON`) and delete their files.
- Tests must not depend on execution order or on leftovers from earlier runs.
- Update the test counts in `README.md` / `README.fa.md` when you add tests, and report only results you actually obtained.

Dedicated tests for malformed-structure errors (missing colon / comma, unterminated string, unknown escape, malformed `\uXXXX`, malformed literals) and for individual error codes are especially welcome.

## Compatibility considerations

- The library is verified with **MetaTrader 5 Build 6257**. No minimum build is established; avoid language features that are new or unusual unless necessary, and mention the build you tested with.
- Do not break the public API in a minor or patch release (Semantic Versioning). A breaking change needs a clear justification, updated tests and docs, and a **major** version bump.
- Keep the observable behavior documented in the README (duplicate keys rejected, number mapping, escaping, error codes). Changing it is a user-visible change and belongs in the changelog.
- Files written by `SaveFile()` are UTF-8 without BOM; `LoadFile()` must continue to read UTF-8 (with / without BOM) and UTF-16 LE with BOM.

## Commit messages

Use short, imperative subjects ("Fix escaping of control characters") and explain *why* in the body when it is not obvious.
Reference the issue number in the pull request description.

## License

AbsJson is licensed under the [MIT License](LICENSE). By submitting a contribution you confirm that you have the right to
submit it, and you agree that it will be licensed under the same MIT License. Copyright (c) 2026 Amir Bagheri Studio.
