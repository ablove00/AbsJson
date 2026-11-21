//+------------------------------------------------------------------+
//|                                                TestRoundTrip.mqh |
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
void RunTestRoundTrip()
  {
   RunTest(
      "Round Trip Simple",
      TestRoundTripSimple());

   RunTest(
      "Round Trip Nested",
      TestRoundTripNested());

   RunTest(
      "Round Trip Array",
      TestRoundTripArray());


   RunTest(
      "Round Trip Complex",
      TestRoundTripComplex());

   RunTest(
      "Round Trip Escaped String",
      TestRoundTripEscapedString());

   RunTest(
      "Round Trip Unicode",
      TestRoundTripUnicode());
  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for a simple object.
 *
 * Parses a simple JSON object, writes it and parses the output again.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripSimple()
  {

   string json=
      "{\"name\":\"Amir\",\"age\":38,\"active\":true}";


   CAbsJsonParser parser;


   CAbsJsonObject object;


   if(!parser.Parse(
         json,
         object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print("Parser Error : ", status.FullMessage());

      return false;

     }


   CAbsJsonWriter writer;


   string output=
      writer.Write(object);


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      Print(
         "Round Trip Parse Error : ",
         output);

      return false;

     }


   CAbsJsonProperty *name=
      result.FindProperty(
         "name");


   if(!AssertTrue(
         name!=NULL,
         "Name property was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         name.Value().GetString(),
         "Name value is incorrect."))
      return false;


   CAbsJsonProperty *age=
      result.FindProperty(
         "age");


   if(!AssertTrue(
         age!=NULL,
         "Age property was not found."))
      return false;


   if(!AssertEqual(
         38,
         age.Value().GetInteger(),
         "Age value is incorrect."))
      return false;


   CAbsJsonProperty *active=
      result.FindProperty(
         "active");


   if(!AssertTrue(
         active!=NULL,
         "Active property was not found."))
      return false;


   if(!AssertTrue(
         active.Value().GetBoolean(),
         "Active value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for a nested object.
 *
 * Parses a nested object, writes it again and parses the output.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripNested()
  {

   string json=
      "{\"user\":{\"name\":\"Amir\",\"age\":38},\"settings\":{\"enabled\":true}}";


   CAbsJsonParser parser;


   CAbsJsonObject object;


   if(!parser.Parse(
         json,
         object))
     {

      Print(
         "Parser Error during first Parse.");

      return false;

     }


   CAbsJsonWriter writer;


   string output=
      writer.Write(object);


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      Print(
         "Round Trip Parse Error : ",
         output);

      return false;

     }


   CAbsJsonProperty *user=
      result.FindProperty(
         "user");


   if(!AssertTrue(
         user!=NULL,
         "User property was not found."))
      return false;


   CAbsJsonObject *userObject=
      user.Value().GetObject();


   if(!AssertTrue(
         userObject!=NULL,
         "User object is NULL."))
      return false;


   CAbsJsonProperty *name=
      userObject.FindProperty(
         "name");


   if(!AssertTrue(
         name!=NULL,
         "Nested name property was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         name.Value().GetString(),
         "Nested name value is incorrect."))
      return false;


   CAbsJsonProperty *age=
      userObject.FindProperty(
         "age");


   if(!AssertTrue(
         age!=NULL,
         "Nested age property was not found."))
      return false;


   if(!AssertEqual(
         38,
         age.Value().GetInteger(),
         "Nested age value is incorrect."))
      return false;


   CAbsJsonProperty *settings=
      result.FindProperty(
         "settings");


   if(!AssertTrue(
         settings!=NULL,
         "Settings property was not found."))
      return false;


   CAbsJsonObject *settingsObject=
      settings.Value().GetObject();


   if(!AssertTrue(
         settingsObject!=NULL,
         "Settings object is NULL."))
      return false;


   CAbsJsonProperty *enabled=
      settingsObject.FindProperty(
         "enabled");


   if(!AssertTrue(
         enabled!=NULL,
         "Enabled property was not found."))
      return false;


   if(!AssertTrue(
         enabled.Value().GetBoolean(),
         "Enabled value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for an array.
 *
 * Parses a JSON array, writes it again, parses the output and compares the structures.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripArray()
  {

   string json=
      "{\"items\":[10,\"Amir\",true,12.5,null]}";


   CAbsJsonParser parser;


   CAbsJsonObject object;


   if(!parser.Parse(
         json,
         object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonWriter writer;


   string output=
      writer.Write(object);


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Round Trip Parse Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonProperty *items=
      result.FindProperty(
         "items");


   if(!AssertTrue(
         items!=NULL,
         "Items property was not found."))
      return false;


   CAbsJsonArray *array=
      items.Value().GetArray();


   if(!AssertTrue(
         array!=NULL,
         "Items array is NULL."))
      return false;


   if(!AssertEqual(
         5,
         array.Count(),
         "Array count is incorrect."))
      return false;


   if(!AssertEqual(
         10,
         array.Item(0).GetInteger(),
         "Array integer value is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         array.Item(1).GetString(),
         "Array string value is incorrect."))
      return false;


   if(!AssertTrue(
         array.Item(2).GetBoolean(),
         "Array boolean value is incorrect."))
      return false;


   if(!AssertEqual(
         12.5,
         array.Item(3).GetDouble(),
         "Array double value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)array.Item(4).JsonType(),
         "Array null value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for a complex JSON document.
 *
 * Parses a document with nested objects and arrays, writes it again and parses the output to verify the final structure.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripComplex()
  {

   string json=
      "{\"id\":123,\"name\":\"Amir\",\"active\":true,\"profile\":{\"city\":\"Tehran\",\"age\":38},\"scores\":[10,12.5,20],\"orders\":[{\"symbol\":\"XAUUSD\",\"volume\":1},{\"symbol\":\"EURUSD\",\"volume\":2}]}";


   CAbsJsonParser parser;


   CAbsJsonObject object;


   if(!parser.Parse(
         json,
         object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonWriter writer;


   string output=
      writer.Write(object);


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Round Trip Parse Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonProperty *id=
      result.FindProperty(
         "id");


   if(!AssertTrue(
         id!=NULL,
         "Id property was not found."))
      return false;


   if(!AssertEqual(
         123,
         id.Value().GetInteger(),
         "Id value is incorrect."))
      return false;


   CAbsJsonProperty *name=
      result.FindProperty(
         "name");


   if(!AssertTrue(
         name!=NULL,
         "Name property was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         name.Value().GetString(),
         "Name value is incorrect."))
      return false;


   CAbsJsonProperty *active=
      result.FindProperty(
         "active");


   if(!AssertTrue(
         active!=NULL,
         "Active property was not found."))
      return false;


   if(!AssertTrue(
         active.Value().GetBoolean(),
         "Active value is incorrect."))
      return false;


   CAbsJsonProperty *profile=
      result.FindProperty(
         "profile");


   if(!AssertTrue(
         profile!=NULL,
         "Profile property was not found."))
      return false;


   CAbsJsonObject *profileObject=
      profile.Value().GetObject();


   if(!AssertTrue(
         profileObject!=NULL,
         "Profile object is NULL."))
      return false;


   CAbsJsonProperty *city=
      profileObject.FindProperty(
         "city");


   if(!AssertTrue(
         city!=NULL,
         "City property was not found."))
      return false;


   if(!AssertEqual(
         "Tehran",
         city.Value().GetString(),
         "City value is incorrect."))
      return false;


   CAbsJsonProperty *age=
      profileObject.FindProperty(
         "age");


   if(!AssertTrue(
         age!=NULL,
         "Age property was not found."))
      return false;


   if(!AssertEqual(
         38,
         age.Value().GetInteger(),
         "Age value is incorrect."))
      return false;


   CAbsJsonProperty *scores=
      result.FindProperty(
         "scores");


   if(!AssertTrue(
         scores!=NULL,
         "Scores property was not found."))
      return false;


   CAbsJsonArray *scoresArray=
      scores.Value().GetArray();


   if(!AssertTrue(
         scoresArray!=NULL,
         "Scores array is NULL."))
      return false;


   if(!AssertEqual(
         3,
         scoresArray.Count(),
         "Scores count is incorrect."))
      return false;


   if(!AssertEqual(
         10,
         scoresArray.Item(0).GetInteger(),
         "Score 0 is incorrect."))
      return false;


   if(!AssertEqual(
         12.5,
         scoresArray.Item(1).GetDouble(),
         "Score 1 is incorrect."))
      return false;


   if(!AssertEqual(
         20,
         scoresArray.Item(2).GetInteger(),
         "Score 2 is incorrect."))
      return false;


   CAbsJsonProperty *orders=
      result.FindProperty(
         "orders");


   if(!AssertTrue(
         orders!=NULL,
         "Orders property was not found."))
      return false;


   CAbsJsonArray *ordersArray=
      orders.Value().GetArray();


   if(!AssertTrue(
         ordersArray!=NULL,
         "Orders array is NULL."))
      return false;


   if(!AssertEqual(
         2,
         ordersArray.Count(),
         "Orders count is incorrect."))
      return false;


   CAbsJsonObject *order0=
      ordersArray.Item(0).GetObject();


   if(!AssertTrue(
         order0!=NULL,
         "Order 0 object is NULL."))
      return false;


   CAbsJsonProperty *symbol0=
      order0.FindProperty(
         "symbol");


   if(!AssertTrue(
         symbol0!=NULL,
         "Order 0 symbol was not found."))
      return false;


   if(!AssertEqual(
         "XAUUSD",
         symbol0.Value().GetString(),
         "Order 0 symbol is incorrect."))
      return false;


   CAbsJsonProperty *volume0=
      order0.FindProperty(
         "volume");


   if(!AssertTrue(
         volume0!=NULL,
         "Order 0 volume was not found."))
      return false;


   if(!AssertEqual(
         1,
         volume0.Value().GetInteger(),
         "Order 0 volume is incorrect."))
      return false;


   CAbsJsonObject *order1=
      ordersArray.Item(1).GetObject();


   if(!AssertTrue(
         order1!=NULL,
         "Order 1 object is NULL."))
      return false;


   CAbsJsonProperty *symbol1=
      order1.FindProperty(
         "symbol");


   if(!AssertTrue(
         symbol1!=NULL,
         "Order 1 symbol was not found."))
      return false;


   if(!AssertEqual(
         "EURUSD",
         symbol1.Value().GetString(),
         "Order 1 symbol is incorrect."))
      return false;


   CAbsJsonProperty *volume1=
      order1.FindProperty(
         "volume");


   if(!AssertTrue(
         volume1!=NULL,
         "Order 1 volume was not found."))
      return false;


   if(!AssertEqual(
         2,
         volume1.Value().GetInteger(),
         "Order 1 volume is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for strings with escapes.
 *
 * Parses a string with escapes, writes it again and compares the final value with the initial one.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripEscapedString()
  {

   CAbsJsonParser parser;

   CAbsJsonWriter writer;

   CAbsJsonValue source;

   CAbsJsonValue result;


   string json=
      "\"Hello\\nWorld\\t\\\"JSON\\\"\\\\Test\\/Done\"";


   if(!parser.Parse(
         json,
         source))
      return false;


   string written=
      writer.Write(
         source);


   if(!parser.Parse(
         written,
         result))
      return false;


   if(!AssertEqual(
         source.GetString(),
         result.GetString(),
         "Round trip escaped string is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for Unicode strings.
 *
 * Parses a string with Unicode escapes, writes it again and compares the final value with the initial one.
 *
 * @return
 * true when the test passes.
 */
bool TestRoundTripUnicode()
  {

   CAbsJsonParser parser;

   CAbsJsonWriter writer;

   CAbsJsonValue source;

   CAbsJsonValue result;


   string json=
      "\"\\u0041\\u0042\\u0043\\u0031\\u0032\\u0033\"";


   if(!parser.Parse(
         json,
         source))
      return false;


   string written=
      writer.Write(
         source);


   if(!parser.Parse(
         written,
         result))
      return false;


   if(!AssertEqual(
         source.GetString(),
         result.GetString(),
         "Round trip Unicode string is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
