[English](README.md) | [فارسی](README.fa.md)

# AbsJson

A JSON library for **MQL5** (MetaTrader 5): parse, build, query, modify and write JSON documents, with an object model, error reporting with line/column positions, deep copy, and UTF-8 file I/O.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/MetaTrader-5-informational)

**Version 1.0.0** · Released 2026-09-21 · Git tag `v1.0.0` · Official website: <https://mql5.ab-studio.ir>

- **Single include:** `#include <AbsJson/AbsJson.mqh>`
- **No dependencies** besides the MQL5 Standard Library (`CObject`, `CArrayObj`).
- **No exceptions:** every failure is reported through a status object (`CAbsJsonStatus`).
- **Tested:** 95 unit tests in `Scripts/TestAbsJson`; all passed in a MetaTrader 5 Build 6257 run (see [Testing](#testing)).
- **MIT licensed.**

---

## Table of contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Quick start](#quick-start)
5. [Usage examples](#usage-examples)
6. [API overview](#api-overview)
7. [Behavior and JSON compliance](#behavior-and-json-compliance)
8. [Memory ownership rules](#memory-ownership-rules)
9. [Error handling](#error-handling)
10. [Limitations](#limitations)
11. [Project structure](#project-structure)
12. [Testing](#testing)
13. [Contributing](#contributing)
14. [Changelog](#changelog)
15. [License](#license)
16. [Official website](#official-website)

---

## Features

- **Parser** for the RFC 8259 grammar: objects, arrays, strings (all escapes including `\uXXXX`), numbers, `true`, `false`, `null`.
- **Writer** with compact (`Minify`) and indented (`PrettyPrint`) output.
- **Typed value model:** `null`, string, integer (32-bit), long (64-bit), double, boolean, object, array.
- **Object and array manipulation:** `Set`, `Add`, `Insert`, `Remove`, typed getters, `FindProperty`, `Contains`.
- **Hash-indexed objects:** objects with 16 or more properties use a hash index for fast lookup.
- **Precise errors:** error code, message, line, column and character position.
- **Deep copy** of values, objects, arrays and whole documents (`CopyFrom` / `Clone`, copy constructor and `=` on `CAbsJsonValue`).
- **Validation** of JSON text without touching the current document.
- **File I/O** in the common terminal folder: UTF-8 without BOM on save; UTF-8 (with or without BOM) and UTF-16 LE (with BOM) on load.
- **Round-trip-exact doubles** (`%.15g`, falling back to `%.17g`); NaN and infinity are written as `null`.
- **Nesting limit** (256 levels) to protect against stack exhaustion.
- **Utilities:** `CAbsJsonNumber` (strict number validation, type detection) and `CAbsJsonEscape` (escape / unescape).
- **Serialization interface:** `CAbsJsonSerializable` for your own classes.

## Requirements

| Requirement | Details |
|---|---|
| Platform | MetaTrader 5 |
| Editor | MetaEditor 5 |
| Compiler | MQL5 compiler (the sources use `#property strict`) |
| Tested with | **MetaTrader 5 Build 6257** |

Build 6257 is the environment in which the library and its test suite were verified. It is **not** a stated minimum: other builds have not been tested, and no minimum supported build has been established. If you use a different build, please report your result (see [CONTRIBUTING.md](CONTRIBUTING.md)).

## Installation

1. Open the MetaTrader 5 data folder (**File → Open Data Folder**).
2. Copy the folder `Include/AbsJson` into `MQL5/Include/`, so that the file
   `MQL5/Include/AbsJson/AbsJson.mqh` exists.
3. (Optional) Copy `Scripts/TestAbsJson` into `MQL5/Scripts/` to get the test suite.
4. In your code:

```cpp
#include <AbsJson/AbsJson.mqh>
```

Include `AbsJson.mqh` only. It pulls in every part of the library in the required order; some members (for example the `ToString()` methods and the deep-copy engine) are declared in one file and implemented in another, so including individual headers is not supported.

## Quick start

```cpp
#include <AbsJson/AbsJson.mqh>

void OnStart()
  {
   CAbsJson json;

   if(!json.Parse("{\"name\":\"Amir\",\"items\":[1,2,3]}"))
     {
      Print("Parse error: ",json.GetStatus().FullMessage());
      return;
     }

   CAbsJsonObject *root=json.Root().GetObject();

   Print("name = ",root.GetString("name"));   // Amir
   Print(json.Minify());                      // {"name":"Amir","items":[1,2,3]}
   Print(json.PrettyPrint());                 // indented output
  }
```

## Usage examples

### Parse and read values

```cpp
CAbsJson json;

if(json.Parse("{\"user\":{\"name\":\"Amir\",\"age\":38},\"tags\":[\"a\",\"b\"]}"))
  {
   CAbsJsonObject *root=json.Root().GetObject();

   CAbsJsonProperty *user=root.FindProperty("user");

   if(user!=NULL && user.IsObject())
     {
      CAbsJsonObject *userObject=user.Value().GetObject();

      Print(userObject.GetString("name"));    // Amir
      Print(userObject.GetInteger("age"));    // 38
     }

   CAbsJsonProperty *tags=root.FindProperty("tags");

   if(tags!=NULL && tags.IsArray())
     {
      CAbsJsonArray *array=tags.Value().GetArray();

      for(int i=0;i<array.Count();i++)
         Print(array.GetString(i));
     }
  }
```

Typed getters never fail: they return `""`, `0`, `0.0` or `false` when the property or index does not exist or has another type. Use `Contains()` / `FindProperty()` / `JsonType()` when you need to tell these cases apart.

### Build a document

```cpp
CAbsJson json;

CAbsJsonObject *root=new CAbsJsonObject();

root.Set("symbol","EURUSD");
root.Set("lots",0.1);
root.Set("active",true);

CAbsJsonArray *levels=new CAbsJsonArray();

levels.Add(1.0850);
levels.Add(1.0900);
levels.AddNull();

root.SetArray("levels",levels);   // root takes ownership of 'levels'

json.Root().SetObject(root);      // the document takes ownership of 'root'

Print(json.PrettyPrint(2));
```

### Output formats

```cpp
string compact=json.Minify();                      // same as json.ToString()
string pretty =json.PrettyPrint();                 // 4 spaces per level (line breaks are "\r\n")
string pretty2=json.PrettyPrint(2);                // 2 spaces per level
string byEnum =json.ToString(ABS_JSON_PRETTY,2);   // enumeration-based variant
```

### Validate without changing the document

```cpp
CAbsJson json;

if(!json.Validate("{\"a\":}"))
   Print(json.GetStatus().FullMessage());
// Unexpected token. (Line=1, Column=6, Position=5)
```

### Save and load files

Files are stored in the terminal's **common** folder (`FILE_COMMON`, i.e. `Terminal\Common\Files`).

```cpp
CAbsJson json;

json.Parse("{\"a\":1}");

if(!json.SaveFile("settings.json",true))      // true = pretty
   Print(json.GetStatus().FullMessage());

CAbsJson loaded;

if(!loaded.LoadFile("settings.json"))
   Print(loaded.GetStatus().FullMessage());
```

### Copy

```cpp
CAbsJson copy;
json.Clone(copy);                  // independent deep copy of the document

CAbsJsonValue a;
a.CopyFrom(*json.Root());          // deep copy of a value
CAbsJsonValue b(a);                 // copy constructor: deep copy
b=a;                               // assignment: deep copy
```

### Implement `CAbsJsonSerializable`

```cpp
#include <AbsJson/AbsJsonSerializable.mqh>

class CPerson : public CAbsJsonSerializable
  {
public:
   string Name;
   int    Age;

   virtual bool Serialize(CAbsJson &json) const
     {
      json.Clear();

      CAbsJsonObject *object=new CAbsJsonObject();

      if(object==NULL)
         return false;

      if(!object.Set("Name",Name) || !object.Set("Age",Age))
        {
         delete object;
         return false;
        }

      json.Root().SetObject(object);
      return true;
     }

   virtual bool Deserialize(const CAbsJson &json)
     {
      const CAbsJsonValue *root=json.Root();

      if(root.JsonType()!=ABS_JSON_OBJECT)
         return false;

      const CAbsJsonObject *object=root.GetObject();

      if(object==NULL || !object.HasProperty("Name") || !object.HasProperty("Age"))
         return false;

      Name=object.GetString("Name");
      Age=object.GetInteger("Age");
      return true;
     }
  };
```

The library does not call these methods itself; the interface only defines a common contract for your classes.

### Number and escape utilities

```cpp
CAbsJsonNumber::Validate("-0.5e+3");        // true  (strict RFC 8259 grammar)
CAbsJsonNumber::Validate("007");            // false
CAbsJsonNumber::IsLong("9223372036854775807");   // true

ENUM_ABS_JSON_NUMBER_TYPE type;
CAbsJsonNumber::GetNumberType("2147483648",type); // true, type == ABS_JSON_NUMBER_LONG

string escaped=CAbsJsonEscape::Escape("a\"b");    // a\"b
string raw    =CAbsJsonEscape::Unescape(escaped);
```

## API overview

All classes are prefixed with `CAbsJson`. Doxygen-style comments in the headers describe every parameter, return value and failure condition.

### `CAbsJson` — document facade (`AbsJson.mqh`)

| Member | Description |
|---|---|
| `Parse(text)` | Parses text into `Root()`. On failure the root is emptied and the status is set. |
| `Root()` | Root `CAbsJsonValue` of the document (never `NULL`). |
| `IsValid()` | `true` after a successful `Parse` / `LoadFile`. |
| `GetStatus()` | Status of the last `Parse`, `Validate(text)`, `SaveFile` or `LoadFile`. |
| `Validate(text)` / `Validate()` | Checks text without touching `Root()` / returns `IsValid()`. |
| `ToString()` / `Minify()` | Compact JSON. |
| `ToString(format, indent)` | Compact or pretty output chosen with `ENUM_ABS_JSON_FORMAT`. |
| `PrettyPrint(indent=4)` | Indented JSON. |
| `Clone(target)` | Independent deep copy of the document. |
| `Clear()` | Empties the document. |
| `SaveFile(name, pretty=false)` / `LoadFile(name)` | UTF-8 file I/O in the common folder. |

### `CAbsJsonValue` — one JSON value

`JsonType()`, `IsNull/IsString/IsInteger/IsLong/IsDouble/IsBoolean/IsObject/IsArray()`, `SetNull/SetString/SetInteger/SetLong/SetDouble/SetBoolean/SetObject/SetArray()`, `GetString/GetInteger/GetLong/GetDouble/GetBoolean/GetObject/GetArray()`, `CopyFrom()`, `Clone()`, `ToString()`, `SetValue(type, text)`, `Clear()`.

### `CAbsJsonObject` — JSON object (insertion-ordered, unique names)

| Member | Description |
|---|---|
| `Set(name, value)` | Creates or overwrites a property (`string`, `int`, `long`, `double`, `bool`). |
| `SetObject(name, obj)` / `SetArray(name, arr)` | Stores an object / array; ownership is transferred. |
| `GetString/GetInteger/GetLong/GetDouble/GetBoolean(name)` | Typed getters with defaults. |
| `GetObject(name, target)` / `GetArray(name, target)` | Deep copy of a child into `target`. |
| `FindProperty(name)`, `Contains(name)`, `HasProperty(name)`, `IndexOf(name)` | Lookup. |
| `GetProperty(index)`, `Count()`, `IsEmpty()` | Enumeration. |
| `Remove(name)` / `Remove(index)` | Removes a property. |
| `AddProperty(p)` / `SetProperty(p)` | Low-level insertion (see ownership rules). |
| `CopyFrom()`, `Clone()`, `ToString(pretty=false)`, `Clear()` | Copy, output, reset. |

### `CAbsJsonArray` — JSON array

`Add(string/int/long/double/bool)`, `AddNull()`, `AddObject()`, `AddArray()`, `Insert(index, value)`, `Item(index)`, `GetString/GetInteger/GetLong/GetDouble/GetBoolean(index)`, `GetObject(index, target)`, `GetArray(index, target)`, `Remove(index)`, `Count()`, `IsEmpty()`, `CopyFrom()`, `Clone()`, `ToString(pretty=false)`, `Clear()`.

### `CAbsJsonProperty`

A name/value member of an object: `Name()`, `SetName()` (returns `false` if the name already exists in the owning object), `Value()`, plus the same `Is…` / `Set…` / `Get…` helpers as `CAbsJsonValue`.

### `CAbsJsonParser` and `CAbsJsonWriter`

Used internally by the facade and available directly:

```cpp
CAbsJsonParser parser;
CAbsJsonValue value;

if(!parser.Parse(text,value))
  {
   CAbsJsonStatus status;
   parser.GetStatus(status);
   Print(status.FullMessage());
  }

CAbsJsonWriter writer;
writer.SetFormat(ABS_JSON_PRETTY);
writer.SetIndentSize(2);
string json=writer.Write(value);
```

`parser.Parse(text, CAbsJsonObject&)` and `parser.Parse(text, CAbsJsonArray&)` additionally require the top-level value to be an object / array.

### Helpers

- `CAbsJsonNumber`: `Validate`, `IsInteger`, `IsLong`, `IsDouble`, `IsNumber`, `FitsInLong`, `GetNumberType`, `ParseInteger`, `ParseLong`, `ParseDouble`, `IntegerToJson`, `LongToJson`, `DoubleToJson`.
- `CAbsJsonEscape`: `Escape`, `Unescape`, `EscapeUnicode`, `NeedEscape`, `UnicodeEscape`, `HexToUShort`, `UShortToHex`.
- `AbsJsonTypeToString(type)`, `AbsJsonErrorToString(code)`.
- Constants in namespace `AbsJsonConst`: `DEFAULT_INDENT` (4), `MAX_DEPTH` (256).

### Value types

| `ENUM_ABS_JSON_TYPE` | Stored when |
|---|---|
| `ABS_JSON_NULL` | `null` |
| `ABS_JSON_STRING` | string |
| `ABS_JSON_INTEGER` | integer that fits in a 32-bit `int` |
| `ABS_JSON_LONG` | integer that needs a 64-bit `long` |
| `ABS_JSON_DOUBLE` | number with a fraction and/or an exponent |
| `ABS_JSON_BOOLEAN` | `true` / `false` |
| `ABS_JSON_OBJECT` / `ABS_JSON_ARRAY` | containers |

## Behavior and JSON compliance

The parser targets the RFC 8259 grammar. The test suite covers valid and invalid documents; it does not constitute a formal conformance test, so no full-compliance claim is made.

**Accepted:** objects, arrays, strings with all escapes, numbers (`-`, fraction, exponent), `true`/`false`/`null`, whitespace (space, tab, CR, LF), any value at the top level, and a leading U+FEFF byte-order mark (skipped).

**Rejected with an error:**

- empty or whitespace-only text;
- extra characters after the top-level value;
- trailing commas, comments, single-quoted strings, unquoted names;
- raw control characters (below U+0020) inside strings;
- numbers with a leading `+`, leading zeros, `.5`, `5.`, `NaN`, `Infinity`;
- integers outside the signed 64-bit range, and doubles that overflow;
- **duplicate property names** in one object (a deliberate library choice; RFC 8259 only says names *should* be unique);
- nesting deeper than 256 levels.

**Library-specific behavior:**

- Integers map to `ABS_JSON_INTEGER` / `ABS_JSON_LONG`; anything with a fraction or exponent becomes `ABS_JSON_DOUBLE`. `-0` becomes the integer `0`.
- A double with no fractional part is written without a decimal point (`5.0` → `5`) and therefore reads back as an integer type.
- NaN and ±infinity cannot be represented in JSON and are written as `null`.
- Strings are MQL5 UTF-16 strings. A surrogate pair written as two `\uXXXX` escapes forms the correct character; an unpaired surrogate is kept. `\u0000` cannot be stored in an MQL5 string and is dropped.
- The writer escapes `"`, `\` and all control characters below U+0020; other characters (including non-ASCII) are written unchanged. `/` is not escaped.
- Pretty output uses `\r\n` line breaks and `": "` after names.

## Memory ownership rules

MQL5 has no garbage collection, so ownership is explicit:

- A document, value, property, object or array **owns everything below it** and deletes it when cleared or destroyed.
- `SetObject`, `SetArray`, `AddObject`, `AddArray` **take ownership** of the pointer you pass. Pass a heap object created with `new`; never a stack object, and never one owned elsewhere. Do not `delete` it afterwards.
- `AddProperty` / `AddItem` / `Insert` take ownership only when they return `true`; on `false` you still own the pointer.
- Pointers returned by `Root()`, `FindProperty()`, `GetProperty()`, `Item()`, `GetObject()`, `GetArray()` stay owned by the library. They become invalid when the element is removed or the container is cleared or destroyed, and after `Parse()` / `Clear()` on the document.
- `GetObject(name, target)` / `GetArray(name, target)` on `CAbsJsonObject` / `CAbsJsonArray` copy into `target`; you own `target`.
- Use `CopyFrom`, `Clone`, the copy constructor or `=` (on `CAbsJsonValue`) for copies; they are deep.

## Error handling

No exceptions are thrown. After `Parse`, `Validate(text)`, `SaveFile` or `LoadFile`, read the status:

```cpp
if(!json.Parse(text))
  {
   const CAbsJsonStatus *status=json.GetStatus();

   Print(status.Code());         // ENUM_ABS_JSON_ERROR
   Print(status.Message());
   Print(status.Line()," ",status.Column()," ",status.Position());
   Print(status.FullMessage());  // "<message> (Line=L, Column=C, Position=P)"
  }
```

Codes raised by the library:

| Code | Raised when |
|---|---|
| `ABS_JSON_ERROR_EMPTY_DOCUMENT` | Text is empty or only whitespace. |
| `ABS_JSON_ERROR_UNEXPECTED_END` | Text ends inside a construct. |
| `ABS_JSON_ERROR_UNEXPECTED_TOKEN` | A character cannot start a value. |
| `ABS_JSON_ERROR_INVALID_JSON` | Extra characters after the top-level value. |
| `ABS_JSON_ERROR_INVALID_CHARACTER` | Raw control character in a string. |
| `ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE` | Unknown backslash escape. |
| `ABS_JSON_ERROR_INVALID_UNICODE` | Malformed `\uXXXX`. |
| `ABS_JSON_ERROR_INVALID_NUMBER` | Malformed number, integer overflow, or double out of range. |
| `ABS_JSON_ERROR_INVALID_BOOLEAN` / `ABS_JSON_ERROR_INVALID_NULL` | Malformed literal. |
| `ABS_JSON_ERROR_EXPECT_OBJECT` / `ABS_JSON_ERROR_EXPECT_ARRAY` | Missing `{` / `[`, or wrong top-level type for the typed `Parse` overloads. |
| `ABS_JSON_ERROR_EXPECT_STRING` | Property name is not a string. |
| `ABS_JSON_ERROR_EXPECT_COLON` / `ABS_JSON_ERROR_EXPECT_COMMA` | Missing `:` / `,` (or closing bracket). |
| `ABS_JSON_ERROR_DUPLICATE_PROPERTY` | Same name twice in one object. |
| `ABS_JSON_ERROR_DEPTH_EXCEEDED` | Nesting deeper than 256 levels. |
| `ABS_JSON_ERROR_OUT_OF_MEMORY` | An allocation or internal copy failed. |
| `ABS_JSON_ERROR_IO` | A file could not be opened, read or written. |

The enumeration also defines `UNKNOWN`, `INVALID_STRING`, `INVALID_ESCAPE`, `NOT_IMPLEMENTED`, `EXPECT_PROPERTY`, `EXPECT_VALUE`, `PROPERTY_NOT_FOUND`, `INDEX_OUT_OF_RANGE` and `TYPE_MISMATCH`; the library does not currently raise them.

## Limitations

- The whole document is kept in memory; there is no streaming parser or writer.
- No JSON Pointer / JSON Path, schema validation, comments or JSON5.
- Integers outside the signed 64-bit range are rejected (no big-number support).
- Typed getters return defaults instead of reporting a type mismatch.
- Removing a property from an object is O(n).
- Pretty output has a fixed layout (no options other than indent size).
- Deep copy and destruction are recursive; the 256-level limit applies to parsing, not to structures you build by hand.
- The file API works in the common terminal folder only.

## Project structure

```
Include/AbsJson/
├── AbsJson.mqh                 # entry point + CAbsJson facade
├── AbsJsonSerializable.mqh     # CAbsJsonSerializable interface
├── Core/
│   ├── AbsJsonTypes.mqh        # enums, constants, helper functions
│   ├── AbsJsonStatus.mqh       # CAbsJsonStatus (error / location)
│   ├── AbsJsonBase.mqh         # CAbsJsonBase (status holder)
│   ├── AbsJsonNode.mqh         # CAbsJsonNode (child storage and ownership)
│   ├── AbsJsonValue.mqh        # CAbsJsonValue
│   └── AbsJsonProperty.mqh     # CAbsJsonProperty
├── Objects/
│   ├── AbsJsonObject.mqh       # CAbsJsonObject (with hash index)
│   └── AbsJsonArray.mqh        # CAbsJsonArray
├── Internal/
│   ├── AbsJsonClone.mqh        # CAbsJsonClone declarations
│   └── AbsJsonCloneImpl.mqh    # deep-copy implementation
├── IO/
│   ├── AbsJsonParser.mqh       # CAbsJsonParser
│   └── AbsJsonWriter.mqh       # CAbsJsonWriter + ToString() implementations
└── Utils/
    ├── AbsJsonEscape.mqh       # CAbsJsonEscape
    └── AbsJsonNumber.mqh       # CAbsJsonNumber

Scripts/TestAbsJson/
├── TestAbsJson.mq5             # test runner (OnStart) + usage examples
├── TestBase.mqh, TestHelper.mqh
└── Test*.mqh                   # test groups (parse, write, round trip, clone, value, clear,
                                #   facade, regression, extended)
```

## Testing

### Verified status

| Item | Status |
|---|---|
| Test suite | `Scripts/TestAbsJson/TestAbsJson.mq5` — 95 registered tests |
| Result | **95 passed, 0 failed** |
| Environment | MetaTrader 5 Build 6257 |
| Reported by | the maintainer, from running the complete suite in MetaTrader 5 |

The complete suite was run again by the maintainer; the full Experts-tab log shows all 95 tests passing (`Passed : 95`, `Failed : 0`), followed by the usage-example output of the 1.0.0 test runner. The log does not itself record the terminal build, so the build number above is the one stated by the maintainer. The documentation environment has no MetaTrader 5 / MetaEditor, so these results were reported by the maintainer and not executed by the documentation tooling. A static review of the test files confirmed that the number of registered tests (95) matches the reported total.

### What the tests cover

| Area | Test files | Tests |
|---|---|---|
| Parsing basics: empty object / array, string, integer, long, double, booleans, null, empty input, root values, whitespace | `TestParseBasic.mqh` | 12 |
| Parsing structures: objects, arrays, nesting, mixed types, deep nesting, complex documents | `TestParseStructures.mqh` | 10 |
| Parsing numbers: negative, scientific notation, overflow, invalid numbers, boundary and special numbers | `TestParseNumbers.mqh` | 7 |
| Parsing strings: escapes, Unicode, `\uXXXX`, consecutive escapes, control-character rejection | `TestParseStrings.mqh` | 5 |
| Invalid JSON: trailing commas, multiple root values, invalid root, duplicate properties | `TestParseInvalid.mqh` | 4 |
| Serialization: empty / simple / nested objects, arrays, pretty print, special characters, Unicode | `TestWrite.mqh` | 7 |
| Round trips: simple, nested, array, complex, escaped strings, Unicode | `TestRoundTrip.mqh` | 6 |
| Deep copy: object, array, value, independence | `TestClone.mqh` | 4 |
| Value setters / getters | `TestValue.mqh` | 2 |
| Clearing objects and arrays | `TestClear.mqh` | 2 |
| Facade: parse, root, minify, pretty print, clear, status, clone, validate, round trip, file I/O (plain, pretty, Unicode) | `TestAbsJsonFacade.mqh` | 14 |
| Regression: control characters, double round trip, nested `ToString`, `GetArray`, depth limit, error position, duplicate error code, BOM, number / escape utilities, surrogate pairs, container editing, repeated cycles, UTF-8 file | `TestRegression.mqh` | 14 |
| Extended: large-object hash index, large parse / clone, rename, value assignment, number type, output format, double formatting | `TestExtended.mqh` | 8 |

Error handling: the invalid-input tests (trailing commas, multiple root values, empty / structurally incomplete input such as `{` or `]`, invalid and overflowing numbers, control characters in strings, duplicate properties) check that the parser **rejects** the input. Error *codes* are asserted only in the regression tests (depth limit, duplicate property); error *positions* only for one case (line number of a misplaced token); the facade tests check the status after a failure and for file errors. Cases such as a missing colon, a missing comma, an unterminated string, an unknown escape, a malformed `\uXXXX` or a malformed literal (`tru`, `nul`) have no dedicated tests, and no test asserts every individual error code. Dedicated tests for these would be a welcome contribution.

### Running the tests

1. Copy `Include/AbsJson` and `Scripts/TestAbsJson` into your `MQL5` folder.
2. Open `MQL5/Scripts/TestAbsJson/TestAbsJson.mq5` in MetaEditor 5 and compile (F7).
3. In MetaTrader 5, run the script `TestAbsJson` on any chart.
4. Read the results on the **Experts** tab. The run ends with:

```
Passed : 95
Failed : 0
```

The file-I/O tests create temporary `.json` files in the terminal's common folder (`Terminal\Common\Files`); most are deleted by the tests, so leftovers named `AbsJson_*.json` can be removed manually. After the summary the runner prints a few usage examples; one of them parses invalid JSON on purpose and prints `Expected parse error : …`.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first. Contributions are accepted under the project's MIT License.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Current release: **1.0.0 (2026-09-21)**.

## License

AbsJson is released under the [MIT License](LICENSE). Copyright (c) 2026 Amir Bagheri Studio.

## Official website

<https://mql5.ab-studio.ir>

---

Copyright (c) 2026 Amir Bagheri Studio — MIT License — <https://mql5.ab-studio.ir>
