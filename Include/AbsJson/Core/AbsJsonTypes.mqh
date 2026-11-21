//+------------------------------------------------------------------+
//|                                                 AbsJsonTypes.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_TYPES_MQH__
#define __ABS_JSON_TYPES_MQH__

#property strict

/**
 * @file AbsJsonTypes.mqh
 * @brief Public enumerations, constants and small helper functions of the AbsJson library.
 *
 * This file has no dependency on any other file of the project. It defines:
 *  - the JSON value type enumeration,
 *  - the error codes reported through CAbsJsonStatus,
 *  - formatting and number-type enumerations,
 *  - library-wide constants (namespace AbsJsonConst),
 *  - helpers that convert a type or an error code into readable text.
 *
 * The library targets the JSON grammar of RFC 8259. Library-specific
 * decisions (for example: duplicate object keys are rejected) are documented
 * where they are implemented.
 */

/**
 * @brief Type of the data stored in a JSON value (CAbsJsonValue).
 *
 * JSON itself has a single "number" type. The library distinguishes three
 * numeric storage types so that integers survive a parse/write round trip
 * without being converted to floating point.
 */
enum ENUM_ABS_JSON_TYPE
  {
   ABS_JSON_NULL = 0,       ///< JSON null (also the state of a cleared value).
   ABS_JSON_STRING,         ///< JSON string (stored as an MQL5 UTF-16 string).
   ABS_JSON_INTEGER,        ///< Integer that fits in a signed 32-bit int.
   ABS_JSON_LONG,           ///< Integer that needs a signed 64-bit long.
   ABS_JSON_DOUBLE,         ///< Number with a fraction and/or an exponent (64-bit double).
   ABS_JSON_BOOLEAN,        ///< JSON true / false.
   ABS_JSON_OBJECT,         ///< JSON object (CAbsJsonObject).
   ABS_JSON_ARRAY           ///< JSON array (CAbsJsonArray).
  };

/**
 * @brief Generic operation result.
 * @note Reserved for future use. The current API reports success through
 *       bool return values and CAbsJsonStatus.
 */
enum ENUM_ABS_JSON_RESULT
  {
   ABS_JSON_RESULT_OK = 0,          ///< Operation succeeded.
   ABS_JSON_RESULT_FAILED           ///< Operation failed.
  };

/**
 * @brief Error codes stored in CAbsJsonStatus.
 *
 * ABS_JSON_ERROR_NONE means "no error". Every other value describes a failure.
 * New codes are only ever appended at the end so existing numeric values stay stable.
 */
enum ENUM_ABS_JSON_ERROR
  {
   ABS_JSON_ERROR_NONE = 0,                  ///< No error.

   ABS_JSON_ERROR_UNKNOWN,                   ///< Unknown error.

   ABS_JSON_ERROR_OUT_OF_MEMORY,             ///< An object could not be allocated.

   ABS_JSON_ERROR_INVALID_JSON,              ///< The document is not valid JSON (generic structural error).

   ABS_JSON_ERROR_UNEXPECTED_END,            ///< The text ended before the construct was complete.

   ABS_JSON_ERROR_INVALID_CHARACTER,         ///< A character that is not allowed at this position (e.g. a raw control character in a string).

   ABS_JSON_ERROR_INVALID_STRING,            ///< Malformed string.

   ABS_JSON_ERROR_INVALID_ESCAPE,            ///< Malformed escape (reserved, see ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE).

   ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE,   ///< Unknown or malformed backslash escape inside a string.

   ABS_JSON_ERROR_UNEXPECTED_TOKEN,          ///< A token that cannot start a value or continue the current construct.

   ABS_JSON_ERROR_NOT_IMPLEMENTED,           ///< The requested feature is not implemented.

   ABS_JSON_ERROR_INVALID_UNICODE,           ///< Malformed \uXXXX escape.

   ABS_JSON_ERROR_INVALID_NUMBER,            ///< Malformed number, or an integer outside the 64-bit range.

   ABS_JSON_ERROR_INVALID_BOOLEAN,           ///< Malformed true / false literal.

   ABS_JSON_ERROR_INVALID_NULL,              ///< Malformed null literal.

   ABS_JSON_ERROR_EXPECT_OBJECT,             ///< A JSON object was expected (also reported when '{' is missing).

   ABS_JSON_ERROR_EXPECT_ARRAY,              ///< A JSON array was expected (also reported when '[' is missing).

   ABS_JSON_ERROR_EXPECT_PROPERTY,           ///< A property was expected.

   ABS_JSON_ERROR_EXPECT_COLON,              ///< ':' expected after a property name.

   ABS_JSON_ERROR_EXPECT_COMMA,              ///< ',' (or the closing bracket) expected.

   ABS_JSON_ERROR_EXPECT_STRING,             ///< A string was expected (property names must be strings).

   ABS_JSON_ERROR_EXPECT_VALUE,              ///< A value was expected.

   ABS_JSON_ERROR_DUPLICATE_PROPERTY,        ///< An object contains the same property name twice.

   ABS_JSON_ERROR_PROPERTY_NOT_FOUND,        ///< The requested property does not exist.

   ABS_JSON_ERROR_INDEX_OUT_OF_RANGE,        ///< An index is outside the valid range.

   ABS_JSON_ERROR_TYPE_MISMATCH,             ///< The value has a different JSON type than requested.

   ABS_JSON_ERROR_EMPTY_DOCUMENT,            ///< The JSON text is empty or contains only whitespace.

   ABS_JSON_ERROR_DEPTH_EXCEEDED,            ///< Nesting deeper than AbsJsonConst::MAX_DEPTH.

   ABS_JSON_ERROR_IO                         ///< A file could not be opened, read or written.
  };

/**
 * @brief Output mode of the writer.
 * Used by CAbsJsonWriter::SetFormat() and CAbsJson::ToString(ENUM_ABS_JSON_FORMAT, int).
 */
enum ENUM_ABS_JSON_FORMAT
  {
   ABS_JSON_MINIFY = 0,      ///< No insignificant whitespace.
   ABS_JSON_PRETTY           ///< Human readable output with indentation.
  };

/**
 * @brief Numeric storage type that a JSON number text maps to.
 * Returned by CAbsJsonNumber::GetNumberType().
 */
enum ENUM_ABS_JSON_NUMBER_TYPE
  {
   ABS_JSON_NUMBER_INTEGER = 0,     ///< int
   ABS_JSON_NUMBER_LONG,            ///< long
   ABS_JSON_NUMBER_DOUBLE           ///< double
  };

/**
 * @brief Library-wide constants.
 */
namespace AbsJsonConst
{
/// Default number of spaces per indentation level in pretty-printed output.
const int DEFAULT_INDENT = 4;

/// Maximum container nesting depth accepted by the parser (guards against stack exhaustion).
const int MAX_DEPTH = 256;

/// Text of the JSON literal true.
const string TRUE_TEXT = "true";

/// Text of the JSON literal false.
const string FALSE_TEXT = "false";

/// Text of the JSON literal null.
const string NULL_TEXT = "null";

/// The empty string.
const string EMPTY = "";
}

/**
 * @brief Converts a JSON value type to a readable name.
 *
 * @param type  The type to convert.
 * @return "Null", "String", "Integer", "Long", "Double", "Boolean", "Object" or "Array";
 *         "Unknown" for an out-of-range value.
 */
string AbsJsonTypeToString(const ENUM_ABS_JSON_TYPE type)
  {
   switch(type)
     {
      case ABS_JSON_NULL:
         return "Null";
      case ABS_JSON_STRING:
         return "String";
      case ABS_JSON_INTEGER:
         return "Integer";
      case ABS_JSON_LONG:
         return "Long";
      case ABS_JSON_DOUBLE:
         return "Double";
      case ABS_JSON_BOOLEAN:
         return "Boolean";
      case ABS_JSON_OBJECT:
         return "Object";
      case ABS_JSON_ARRAY:
         return "Array";
     }

   return "Unknown";
  }

/**
 * @brief Converts an error code to its default English message.
 *
 * @param error  The error code.
 * @return Default message text; "Unknown" for an out-of-range value.
 */
string AbsJsonErrorToString(const ENUM_ABS_JSON_ERROR error)
  {
   switch(error)
     {
      case ABS_JSON_ERROR_NONE:
         return "No error";

      case ABS_JSON_ERROR_UNKNOWN:
         return "Unknown error";

      case ABS_JSON_ERROR_OUT_OF_MEMORY:
         return "Out of memory";

      case ABS_JSON_ERROR_INVALID_JSON:
         return "Invalid JSON";

      case ABS_JSON_ERROR_UNEXPECTED_END:
         return "Unexpected end of document";

      case ABS_JSON_ERROR_INVALID_CHARACTER:
         return "Invalid character";

      case ABS_JSON_ERROR_INVALID_STRING:
         return "Invalid string";

      case ABS_JSON_ERROR_INVALID_ESCAPE:
         return "Invalid escape sequence";

      case ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE:
         return "Invalid escape sequence";

      case ABS_JSON_ERROR_UNEXPECTED_TOKEN:
         return "Unexpected token";

      case ABS_JSON_ERROR_NOT_IMPLEMENTED:
         return "Feature not implemented";

      case ABS_JSON_ERROR_INVALID_UNICODE:
         return "Invalid unicode sequence";

      case ABS_JSON_ERROR_INVALID_NUMBER:
         return "Invalid number";

      case ABS_JSON_ERROR_INVALID_BOOLEAN:
         return "Invalid boolean";

      case ABS_JSON_ERROR_INVALID_NULL:
         return "Invalid null";

      case ABS_JSON_ERROR_EXPECT_OBJECT:
         return "Object expected";

      case ABS_JSON_ERROR_EXPECT_ARRAY:
         return "Array expected";

      case ABS_JSON_ERROR_EXPECT_PROPERTY:
         return "Property expected";

      case ABS_JSON_ERROR_EXPECT_COLON:
         return "':' expected";

      case ABS_JSON_ERROR_EXPECT_COMMA:
         return "',' expected";

      case ABS_JSON_ERROR_EXPECT_STRING:
         return "String expected";

      case ABS_JSON_ERROR_EXPECT_VALUE:
         return "Value expected";

      case ABS_JSON_ERROR_DUPLICATE_PROPERTY:
         return "Duplicate property";

      case ABS_JSON_ERROR_PROPERTY_NOT_FOUND:
         return "Property not found";

      case ABS_JSON_ERROR_INDEX_OUT_OF_RANGE:
         return "Index out of range";

      case ABS_JSON_ERROR_TYPE_MISMATCH:
         return "Type mismatch";

      case ABS_JSON_ERROR_EMPTY_DOCUMENT:
         return "Empty document";

      case ABS_JSON_ERROR_DEPTH_EXCEEDED:
         return "Maximum nesting depth exceeded";

      case ABS_JSON_ERROR_IO:
         return "File I/O error";
     }

   return "Unknown";
  }

#endif // __ABS_JSON_TYPES_MQH__
//+------------------------------------------------------------------+
