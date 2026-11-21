//+------------------------------------------------------------------+
//|                                                    TestWrite.mqh |
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
void RunTestWrite()
  {
   RunTest(
      "Write Empty Object",
      TestWriteEmptyObject());

   RunTest(
      "Write Simple Object",
      TestWriteSimpleObject());

   RunTest(
      "Write Nested Object",
      TestWriteNestedObject());

   RunTest(
      "Write Array",
      TestWriteArray());

   RunTest(
      "Pretty Print",
      TestPrettyPrint());

   RunTest(
      "Write Special Characters",
      TestWriteSpecialCharacters());

   RunTest(
      "Write Unicode",
      TestWriteUnicode());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing an empty object.
 *
 * Checks the JSON output for an object without properties.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteEmptyObject()
  {

   CAbsJsonObject object;

   CAbsJsonWriter writer;

   string output=
      writer.Write(object);


   if(!AssertEqual(
         "{}",
         output,
         "Empty object output is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing a simple object.
 *
 * Checks writing string and integer properties.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteSimpleObject()
  {

   CAbsJsonObject object;


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!object.AddProperty(name))
     {

      delete name;

      return false;

     }



   CAbsJsonProperty *age=
      new CAbsJsonProperty();


   age.SetName(
      "age");


   age.Value().SetInteger(
      38);


   if(!object.AddProperty(age))
     {

      delete age;

      return false;

     }



   CAbsJsonWriter writer;


   string output=
      writer.Write(object);



   CAbsJsonParser parser;


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      Print(
         "Generated JSON invalid : ",
         output);

      return false;

     }



   CAbsJsonProperty *pName=
      result.FindProperty(
         "name");


   if(!AssertTrue(
         pName!=NULL,
         "Name property missing."))
      return false;


   if(!AssertEqual(
         "Amir",
         pName.Value().GetString(),
         "Name value incorrect."))
      return false;



   CAbsJsonProperty *pAge=
      result.FindProperty(
         "age");


   if(!AssertTrue(
         pAge!=NULL,
         "Age property missing."))
      return false;


   if(!AssertEqual(
         38,
         pAge.Value().GetInteger(),
         "Age value incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing a nested object.
 *
 * Checks writing an object that contains an inner object.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteNestedObject()
  {

   CAbsJsonObject object;


   CAbsJsonProperty *user=
      new CAbsJsonProperty();


   user.SetName(
      "user");


   CAbsJsonObject *userObject=
      new CAbsJsonObject();


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!userObject.AddProperty(name))
     {

      delete name;
      delete userObject;
      delete user;

      return false;

     }


   user.Value().SetObject(
      userObject);


   if(!object.AddProperty(user))
     {

      delete user;

      return false;

     }


   CAbsJsonWriter writer;


   string output=
      writer.Write(object);



   CAbsJsonParser parser;


   CAbsJsonObject result;


   if(!parser.Parse(
         output,
         result))
     {

      Print(
         "Generated JSON invalid : ",
         output);

      return false;

     }



   CAbsJsonProperty *pUser=
      result.FindProperty(
         "user");


   if(!AssertTrue(
         pUser!=NULL,
         "User property missing."))
      return false;



   CAbsJsonObject *userResult=
      pUser.Value().GetObject();


   if(!AssertTrue(
         userResult!=NULL,
         "Nested object is NULL."))
      return false;



   CAbsJsonProperty *pName=
      userResult.FindProperty(
         "name");


   if(!AssertTrue(
         pName!=NULL,
         "Nested name property missing."))
      return false;



   if(!AssertEqual(
         "Amir",
         pName.Value().GetString(),
         "Nested name value incorrect."))
      return false;



   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing an array.
 *
 * Checks writing an array with different value kinds.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteArray()
  {

   CAbsJsonArray array;


   CAbsJsonValue *item1=
      new CAbsJsonValue();


   item1.SetInteger(
      10);


   if(!array.AddItem(item1))
     {

      delete item1;

      return false;

     }



   CAbsJsonValue *item2=
      new CAbsJsonValue();


   item2.SetString(
      "Amir");


   if(!array.AddItem(item2))
     {

      delete item2;

      return false;

     }



   CAbsJsonValue *item3=
      new CAbsJsonValue();


   item3.SetBoolean(
      true);


   if(!array.AddItem(item3))
     {

      delete item3;

      return false;

     }



   CAbsJsonWriter writer;


   string output=
      writer.Write(array);



   CAbsJsonParser parser;


   CAbsJsonArray result;


   if(!parser.Parse(
         output,
         result))
     {

      Print(
         "Generated JSON invalid : ",
         output);

      return false;

     }



   if(!AssertEqual(
         3,
         result.Count(),
         "Array count is incorrect."))
      return false;



   if(!AssertEqual(
         10,
         result.Item(0).GetInteger(),
         "Array integer value incorrect."))
      return false;



   if(!AssertEqual(
         "Amir",
         result.Item(1).GetString(),
         "Array string value incorrect."))
      return false;



   if(!AssertTrue(
         result.Item(2).GetBoolean(),
         "Array boolean value incorrect."))
      return false;



   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests pretty printing and the indent size.
 *
 * Checks the indented output and a change of the indent size.
 *
 * @return
 * true when the test passes.
 */
bool TestPrettyPrint()
  {

   CAbsJsonObject object;


   CAbsJsonProperty *user=
      new CAbsJsonProperty();


   user.SetName(
      "user");


   CAbsJsonObject *userObject=
      new CAbsJsonObject();


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!userObject.AddProperty(name))
     {
      delete name;
      delete userObject;
      delete user;
      return false;
     }


   user.Value().SetObject(
      userObject);


   if(!object.AddProperty(user))
     {
      delete user;
      return false;
     }


   CAbsJsonWriter writer;


   writer.SetPretty(true);


   string output=
      writer.Write(object);


   string expected=
      "{\r\n"
      "    \"user\": {\r\n"
      "        \"name\": \"Amir\"\r\n"
      "    }\r\n"
      "}";


   if(!AssertEqual(
         expected,
         output,
         "Pretty Print output is incorrect."))
      return false;


   writer.SetIndentSize(2);


   output=
      writer.Write(object);


   expected=
      "{\r\n"
      "  \"user\": {\r\n"
      "    \"name\": \"Amir\"\r\n"
      "  }\r\n"
      "}";


   if(!AssertEqual(
         expected,
         output,
         "Custom indent output is incorrect."))
      return false;


   writer.SetPretty(false);


   output=
      writer.Write(object);


   expected=
      "{\"user\":{\"name\":\"Amir\"}}";


   if(!AssertEqual(
         expected,
         output,
         "Minified output after disabling Pretty Print is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing special JSON characters.
 *
 * Checks that quotes, backslashes and control characters inside a string are escaped correctly.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteSpecialCharacters()
  {

   CAbsJsonValue value;

   CAbsJsonWriter writer;

   CAbsJsonParser parser;

   CAbsJsonValue result;


   value.SetString(
      "Quote: \" Backslash: \\ Slash: / NewLine:\n Tab:\t Return:\r");


   string json=
      writer.Write(value);


   if(!AssertEqual(
         "\"Quote: \\\" Backslash: \\\\ Slash: / NewLine:\\n Tab:\\t Return:\\r\"",
         json,
         "Special characters JSON output is incorrect."))
      return false;


   if(!parser.Parse(
         json,
         result))
      return false;


   if(!AssertEqual(
         value.GetString(),
         result.GetString(),
         "Special characters round trip is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests writing Unicode characters.
 *
 * Converts a string with Unicode characters to JSON and parses the produced output again.
 *
 * @return
 * true when the test passes.
 */
bool TestWriteUnicode()
  {

   CAbsJsonValue value;

   CAbsJsonWriter writer;

   CAbsJsonParser parser;

   CAbsJsonValue result;


   value.SetString(
      "Hello سلام 世界");


   string json=
      writer.Write(value);


   if(!AssertEqual(
         "\"Hello سلام 世界\"",
         json,
         "Unicode JSON output is incorrect."))
      return false;


   if(!parser.Parse(
         json,
         result))
      return false;


   if(!AssertEqual(
         value.GetString(),
         result.GetString(),
         "Unicode round trip is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
