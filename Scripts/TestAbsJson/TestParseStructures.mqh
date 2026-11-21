//+------------------------------------------------------------------+
//|                                          TestParseStructures.mqh |
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
void RunTestParseStructures()
  {
   RunTest(
      "Parse Simple Object",
      TestParseSimpleObject());

   RunTest(
      "Parse Object Multiple Properties",
      TestParseObjectMultipleProperties());

   RunTest(
      "Parse Simple Array",
      TestParseSimpleArray());

   RunTest(
      "Parse Nested Object",
      TestParseNestedObject());

   RunTest(
      "Parse Nested Array",
      TestParseNestedArray());

   RunTest(
      "Parse Object Array Mixed",
      TestParseObjectArrayMixed());

   RunTest(
      "Parse Mixed Array",
      TestParseMixedArray());

   RunTest(
      "Parse Array Mixed Types",
      TestParseArrayMixedTypes());

   RunTest(
      "Parse Deep Nested Object",
      TestParseDeepNestedObject());

   RunTest(
      "Parse Complex Document",
      TestParseComplexDocument());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a simple object with one property.
 *
 * Checks an object that holds one string value.
 *
 * @return
 * true when the test passes.
 */
bool TestParseSimpleObject()
  {

   string json="{\"name\":\"Amir\"}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         1,
         object.Count(),
         "Object property count is incorrect."))
      return false;


   CAbsJsonProperty *property=
      object.FindProperty("name");


   if(!AssertTrue(
         property!=NULL,
         "Property name was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         property.Value().GetString(),
         "Property value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an object with several properties.
 *
 * Checks different value kinds inside one object.
 *
 * @return
 * true when the test passes.
 */
bool TestParseObjectMultipleProperties()
  {

   string json="{\"name\":\"Amir\",\"age\":38,\"active\":true}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         3,
         object.Count(),
         "Object property count is incorrect."))
      return false;


   CAbsJsonProperty *name=
      object.FindProperty("name");


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
      object.FindProperty("age");


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
      object.FindProperty("active");


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
 * @brief Tests parsing a simple array.
 *
 * Checks an array of integer values.
 *
 * @return
 * true when the test passes.
 */
bool TestParseSimpleArray()
  {

   string json="[1,2,3]";

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
         3,
         array.Count(),
         "Array item count is incorrect."))
      return false;


   if(!AssertEqual(
         1,
         array.Item(0).GetInteger(),
         "First array item is incorrect."))
      return false;


   if(!AssertEqual(
         2,
         array.Item(1).GetInteger(),
         "Second array item is incorrect."))
      return false;


   if(!AssertEqual(
         3,
         array.Item(2).GetInteger(),
         "Third array item is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a nested object.
 *
 * Checks an object that contains another object.
 *
 * @return
 * true when the test passes.
 */
bool TestParseNestedObject()
  {

   string json="{\"user\":{\"name\":\"Amir\"}}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonProperty *user=
      object.FindProperty("user");


   if(!AssertTrue(
         user!=NULL,
         "User property was not found."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)user.Value().JsonType(),
         "User value type is not Object."))
      return false;


   CAbsJsonObject *userObject=
      user.Value().GetObject();

   if(!AssertTrue(
         userObject!=NULL,
         "Nested object is NULL."))
      return false;


   CAbsJsonProperty *name=
      userObject.FindProperty("name");


   if(!AssertTrue(
         name!=NULL,
         "Name property was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         name.Value().GetString(),
         "Nested name value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a nested array.
 *
 * Checks an array that contains other arrays.
 *
 * @return
 * true when the test passes.
 */
bool TestParseNestedArray()
  {

   string json="[[1,2],[3,4]]";

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
         2,
         array.Count(),
         "Root array count is incorrect."))
      return false;


   CAbsJsonArray *first=
      array.Item(0).GetArray();


   if(!AssertTrue(
         first!=NULL,
         "First nested array is NULL."))
      return false;


   if(!AssertEqual(
         1,
         first.Item(0).GetInteger(),
         "First nested array first value is incorrect."))
      return false;


   if(!AssertEqual(
         2,
         first.Item(1).GetInteger(),
         "First nested array second value is incorrect."))
      return false;



   CAbsJsonArray *second=
      array.Item(1).GetArray();


   if(!AssertTrue(
         second!=NULL,
         "Second nested array is NULL."))
      return false;


   if(!AssertEqual(
         3,
         second.Item(0).GetInteger(),
         "Second nested array first value is incorrect."))
      return false;


   if(!AssertEqual(
         4,
         second.Item(1).GetInteger(),
         "Second nested array second value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an object that contains an array and an object.
 *
 * Checks a combined structure of objects, arrays and nested objects.
 *
 * @return
 * true when the test passes.
 */
bool TestParseObjectArrayMixed()
  {

   string json=
      "{\"users\":[{\"name\":\"Amir\"},{\"name\":\"Ali\"}]}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonProperty *users=
      object.FindProperty("users");


   if(!AssertTrue(
         users!=NULL,
         "Users property was not found."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_ARRAY,
         (int)users.Value().JsonType(),
         "Users value type is not Array."))
      return false;


   CAbsJsonArray *array=
      users.Value().GetArray();


   if(!AssertTrue(
         array!=NULL,
         "Users array is NULL."))
      return false;


   if(!AssertEqual(
         2,
         array.Count(),
         "Users array count is incorrect."))
      return false;


   CAbsJsonValue *value1=
      array.Item(0);


   if(!AssertTrue(
         value1!=NULL,
         "First array item is NULL."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)value1.JsonType(),
         "First item is not Object."))
      return false;


   CAbsJsonObject *user1=
      value1.GetObject();


   if(!AssertTrue(
         user1!=NULL,
         "First object is NULL."))
      return false;


   CAbsJsonProperty *name1=
      user1.FindProperty("name");


   if(!AssertTrue(
         name1!=NULL,
         "First name property was not found."))
      return false;


   if(!AssertEqual(
         "Amir",
         name1.Value().GetString(),
         "First name value is incorrect."))
      return false;


   CAbsJsonValue *value2=
      array.Item(1);


   if(!AssertTrue(
         value2!=NULL,
         "Second array item is NULL."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)value2.JsonType(),
         "Second item is not Object."))
      return false;


   CAbsJsonObject *user2=
      value2.GetObject();


   if(!AssertTrue(
         user2!=NULL,
         "Second object is NULL."))
      return false;


   CAbsJsonProperty *name2=
      user2.FindProperty("name");


   if(!AssertTrue(
         name2!=NULL,
         "Second name property was not found."))
      return false;


   if(!AssertEqual(
         "Ali",
         name2.Value().GetString(),
         "Second name value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an array with mixed data types.
 *
 * Checks an array that mixes strings, numbers, booleans, null, objects and nested arrays.
 *
 * @return
 * true when the test passes.
 */
bool TestParseMixedArray()
  {

   string json=
      "[1,\"Amir\",true,null]";

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
         4,
         array.Count(),
         "Array count is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)array.Item(0).JsonType(),
         "First item type is incorrect."))
      return false;


   if(!AssertEqual(
         1,
         array.Item(0).GetInteger(),
         "First item value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)array.Item(1).JsonType(),
         "Second item type is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         array.Item(1).GetString(),
         "Second item value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_BOOLEAN,
         (int)array.Item(2).JsonType(),
         "Third item type is incorrect."))
      return false;


   if(!AssertTrue(
         array.Item(2).GetBoolean(),
         "Third item value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)array.Item(3).JsonType(),
         "Fourth item type is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an array that holds every JSON type.
 *
 * Checks the type and the value of each element.
 *
 * @return
 * true when the test passes.
 */
bool TestParseArrayMixedTypes()
  {

   string json=
      "[null,true,123,5000000000,12.5,\"Amir\",{\"id\":1},[1,2]]";

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
         8,
         array.Count(),
         "Array count is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)array.Item(0).JsonType(),
         "Item 0 type is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_BOOLEAN,
         (int)array.Item(1).JsonType(),
         "Item 1 type is incorrect."))
      return false;


   if(!AssertTrue(
         array.Item(1).GetBoolean(),
         "Item 1 value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)array.Item(2).JsonType(),
         "Item 2 type is incorrect."))
      return false;


   if(!AssertEqual(
         123,
         array.Item(2).GetInteger(),
         "Item 2 value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)array.Item(3).JsonType(),
         "Item 3 type is incorrect."))
      return false;


   if(!AssertEqual(
         "5000000000",
         IntegerToString((long)array.Item(3).GetLong()),
         "Item 3 value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_DOUBLE,
         (int)array.Item(4).JsonType(),
         "Item 4 type is incorrect."))
      return false;


   if(!AssertEqual(
         12.5,
         array.Item(4).GetDouble(),
         "Item 4 value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)array.Item(5).JsonType(),
         "Item 5 type is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         array.Item(5).GetString(),
         "Item 5 value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)array.Item(6).JsonType(),
         "Item 6 type is incorrect."))
      return false;


   CAbsJsonObject *object=
      array.Item(6).GetObject();


   if(!AssertTrue(
         object!=NULL,
         "Item 6 object is NULL."))
      return false;


   CAbsJsonProperty *id=
      object.FindProperty("id");


   if(!AssertTrue(
         id!=NULL,
         "Object property was not found."))
      return false;


   if(!AssertEqual(
         1,
         id.Value().GetInteger(),
         "Object property value is incorrect."))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_ARRAY,
         (int)array.Item(7).JsonType(),
         "Item 7 type is incorrect."))
      return false;


   CAbsJsonArray *subArray=
      array.Item(7).GetArray();


   if(!AssertTrue(
         subArray!=NULL,
         "Nested array is NULL."))
      return false;


   if(!AssertEqual(
         2,
         subArray.Count(),
         "Nested array count is incorrect."))
      return false;


   if(!AssertEqual(
         1,
         subArray.Item(0).GetInteger(),
         "Nested array first value is incorrect."))
      return false;


   if(!AssertEqual(
         2,
         subArray.Item(1).GetInteger(),
         "Nested array second value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing an object with several nesting levels.
 *
 * Parses a document of four nested objects and checks the innermost value.
 *
 * @return
 * true when the test passes.
 */
bool TestParseDeepNestedObject()
  {

   string json=
      "{\"a\":{\"b\":{\"c\":{\"value\":100}}}}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   CAbsJsonProperty *a=
      object.FindProperty("a");


   if(!AssertTrue(
         a!=NULL,
         "Property 'a' was not found."))
      return false;


   CAbsJsonObject *objA=
      a.Value().GetObject();


   if(!AssertTrue(
         objA!=NULL,
         "Object 'a' is NULL."))
      return false;


   CAbsJsonProperty *b=
      objA.FindProperty("b");


   if(!AssertTrue(
         b!=NULL,
         "Property 'b' was not found."))
      return false;


   CAbsJsonObject *objB=
      b.Value().GetObject();


   if(!AssertTrue(
         objB!=NULL,
         "Object 'b' is NULL."))
      return false;


   CAbsJsonProperty *c=
      objB.FindProperty("c");


   if(!AssertTrue(
         c!=NULL,
         "Property 'c' was not found."))
      return false;


   CAbsJsonObject *objC=
      c.Value().GetObject();


   if(!AssertTrue(
         objC!=NULL,
         "Object 'c' is NULL."))
      return false;


   CAbsJsonProperty *value=
      objC.FindProperty("value");


   if(!AssertTrue(
         value!=NULL,
         "Property 'value' was not found."))
      return false;


   if(!AssertEqual(
         100,
         value.Value().GetInteger(),
         "Value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a complex JSON document.
 *
 * Checks a combined structure of objects, arrays, nested objects and different value types.
 *
 * @return
 * true when the test passes.
 */
bool TestParseComplexDocument()
  {

   string json=
      "{"
      "\"id\":1,"
      "\"name\":\"Amir\","
      "\"active\":true,"
      "\"score\":12.5,"
      "\"profile\":{"
      "\"age\":38,"
      "\"city\":\"Tehran\""
      "},"
      "\"items\":[10,20,30]"
      "}";

   CAbsJsonParser parser;

   CAbsJsonObject object;


   if(!parser.Parse(json,object))
     {

      CAbsJsonStatus status;

      parser.GetStatus(status);

      Print(
         "Parser Error : ",
         status.FullMessage());

      return false;

     }


   if(!AssertEqual(
         1,
         object.FindProperty("id").Value().GetInteger(),
         "Id is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         object.FindProperty("name").Value().GetString(),
         "Name is incorrect."))
      return false;


   if(!AssertTrue(
         object.FindProperty("active").Value().GetBoolean(),
         "Active value is incorrect."))
      return false;


   if(!AssertEqual(
         12.5,
         object.FindProperty("score").Value().GetDouble(),
         "Score is incorrect."))
      return false;


   CAbsJsonObject *profile=
      object.FindProperty("profile").Value().GetObject();


   if(!AssertTrue(
         profile!=NULL,
         "Profile object is NULL."))
      return false;


   if(!AssertEqual(
         38,
         profile.FindProperty("age").Value().GetInteger(),
         "Age is incorrect."))
      return false;


   if(!AssertEqual(
         "Tehran",
         profile.FindProperty("city").Value().GetString(),
         "City is incorrect."))
      return false;


   CAbsJsonArray *items=
      object.FindProperty("items").Value().GetArray();


   if(!AssertTrue(
         items!=NULL,
         "Items array is NULL."))
      return false;


   if(!AssertEqual(
         3,
         items.Count(),
         "Items count is incorrect."))
      return false;


   if(!AssertEqual(
         10,
         items.Item(0).GetInteger(),
         "Item 0 is incorrect."))
      return false;


   if(!AssertEqual(
         20,
         items.Item(1).GetInteger(),
         "Item 1 is incorrect."))
      return false;


   if(!AssertEqual(
         30,
         items.Item(2).GetInteger(),
         "Item 2 is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
