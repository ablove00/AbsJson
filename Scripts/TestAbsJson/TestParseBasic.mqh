//+------------------------------------------------------------------+
//|                                               TestParseBasic.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#include "TestBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RunTestParseBasic()
  {

   RunTest(
      "Parse Empty Object",
      TestParseEmptyObject());

   RunTest(
      "Parse Empty Array",
      TestParseEmptyArray());

   RunTest(
      "Parse String",
      TestParseString());

   RunTest(
      "Parse Integer",
      TestParseInteger());

   RunTest(
      "Parse Long",
      TestParseLong());

   RunTest(
      "Parse Double",
      TestParseDouble());

   RunTest(
      "Parse Boolean True",
      TestParseBooleanTrue());

   RunTest(
      "Parse Boolean False",
      TestParseBooleanFalse());

   RunTest(
      "Parse Null",
      TestParseNull());

   RunTest(
      "Parse Empty String",
      TestParseEmptyString());

   RunTest(
      "Parse Root Values",
      TestParseRootValues());

   RunTest(
      "Parse Whitespace",
      TestParseWhitespace());

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an empty object.
 *
 * The parsed object must contain no properties.
 *
 * @return
 * true when the test passes.
 */
bool TestParseEmptyObject()
  {

   string json = "{}";

   CAbsJsonParser parser;

   CAbsJsonObject object;

   if(!parser.Parse(json, object))
     {
      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print("Parser Error : ", status.FullMessage());

      return false;
     }

   if(!AssertEqual(
         0,
         object.Count(),
         "Object must not contain any Property."))
     {
      return false;
     }

   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an empty array.
 *
 * The parsed array must contain no elements.
 *
 * @return
 * true when the test passes.
 */
bool TestParseEmptyArray()
  {

   string json = "[]";


   CAbsJsonParser parser;

   CAbsJsonArray array;

   if(!parser.Parse(json,array))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }

   if(!AssertEqual(
         0,
         array.Count(),
         "Array must not contain any item."))
     {
      return false;
     }


   return true;

  }

//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a String value.
 *
 * Checks the parsed type and the extracted string.
 *
 * @return
 * true when the test passes.
 */
bool TestParseString()
  {

   string json = "\"Amir\"";


   CAbsJsonParser parser;

   CAbsJsonValue value;

   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }

   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)value.JsonType(),
         "Parsed value type must be String."))
     {
      return false;
     }


   if(!AssertEqual(
         "Amir",
         value.GetString(),
         "Parsed string value is incorrect."))
     {
      return false;
     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an Integer value.
 *
 * Checks the parsed type and the integer value.
 *
 * @return
 * true when the test passes.
 */
bool TestParseInteger()
  {

   string json="123";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)value.JsonType(),
         "Parsed value type is not Integer."))
      return false;


   if(!AssertEqual(
         123,
         value.GetInteger(),
         "Parsed integer value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a Long value.
 *
 * Checks the parsed type and the 64-bit integer value.
 *
 * @return
 * true when the test passes.
 */
bool TestParseLong()
  {

   string json="5000000000";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)value.JsonType(),
         "Parsed value type is not Long."))
      return false;


   if(!AssertEqual(
         (long)5000000000,
         value.GetLong(),
         "Parsed long value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a Double value.
 *
 * Checks the parsed type and the floating point value.
 *
 * @return
 * true when the test passes.
 */
bool TestParseDouble()
  {

   string json="123.456";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_DOUBLE,
         (int)value.JsonType(),
         "Parsed value type is not Double."))
      return false;


   if(MathAbs(
         value.GetDouble()-123.456)>0.000001)
     {

      Print(
         "[ASSERT FAILED] Parsed double value is incorrect.");

      return false;

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing the boolean true.
 *
 * Checks the parsed type and that the value is true.
 *
 * @return
 * true when the test passes.
 */
bool TestParseBooleanTrue()
  {

   string json="true";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_BOOLEAN,
         (int)value.JsonType(),
         "Parsed value type is not Boolean."))
      return false;


   if(!AssertTrue(
         value.GetBoolean(),
         "Parsed boolean true value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing the boolean false.
 *
 * Checks the parsed type and that the value is false.
 *
 * @return
 * true when the test passes.
 */
bool TestParseBooleanFalse()
  {

   string json="false";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_BOOLEAN,
         (int)value.JsonType(),
         "Parsed value type is not Boolean."))
      return false;


   if(!AssertFalse(
         value.GetBoolean(),
         "Parsed boolean false value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a Null value.
 *
 * Checks that the parsed type is Null.
 *
 * @return
 * true when the test passes.
 */
bool TestParseNull()
  {

   string json="null";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(json,value))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)value.JsonType(),
         "Parsed value type is not Null."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an empty string.
 *
 * Empty inputs and inputs without a valid JSON value must be rejected.
 *
 * @return
 * true when the test passes.
 */
bool TestParseEmptyString()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(
         "\"\"",
         value))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)value.JsonType(),
         "Empty string type is incorrect."))
      return false;


   if(!AssertEqual(
         "",
         value.GetString(),
         "Empty string value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing different value kinds at the root.
 *
 * Checks that a JSON value can be parsed without being wrapped in an object or an array.
 *
 * @return
 * true when the test passes.
 */
bool TestParseRootValues()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(
         "\"Amir\"",
         value))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)value.JsonType(),
         "Root string type is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         value.GetString(),
         "Root string value is incorrect."))
      return false;


   if(!parser.Parse(
         "123",
         value))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)value.JsonType(),
         "Root integer type is incorrect."))
      return false;


   if(!AssertEqual(
         123,
         value.GetInteger(),
         "Root integer value is incorrect."))
      return false;


   if(!parser.Parse(
         "-12.5",
         value))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_DOUBLE,
         (int)value.JsonType(),
         "Root double type is incorrect."))
      return false;


   if(!AssertEqual(
         -12.5,
         value.GetDouble(),
         "Root double value is incorrect."))
      return false;


   if(!parser.Parse(
         "true",
         value))
      return false;


   if(!AssertTrue(
         value.GetBoolean(),
         "Root boolean true is incorrect."))
      return false;


   if(!parser.Parse(
         "false",
         value))
      return false;


   if(!AssertFalse(
         value.GetBoolean(),
         "Root boolean false is incorrect."))
      return false;


   if(!parser.Parse(
         "null",
         value))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)value.JsonType(),
         "Root null type is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests whitespace handling.
 *
 * Checks that space, tab, CR and LF are ignored correctly at different positions.
 *
 * @return
 * true when the test passes.
 */
bool TestParseWhitespace()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   string json=
      " \r\n\t { \r\n"
      "\t \"name\" \t : \t \"Amir\" , \r\n"
      "\t \"age\" \t : \t 38 \r\n"
      " } \r\n\t ";


   if(!parser.Parse(
         json,
         value))
      return false;


   CAbsJsonObject *object=
      value.GetObject();


   if(!AssertTrue(
         object!=NULL,
         "Whitespace object is NULL."))
      return false;


   if(!AssertEqual(
         2,
         object.Count(),
         "Whitespace object count is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         object.FindProperty(
            "name").Value().GetString(),
         "Whitespace name value is incorrect."))
      return false;


   if(!AssertEqual(
         38,
         object.FindProperty(
            "age").Value().GetInteger(),
         "Whitespace age value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
