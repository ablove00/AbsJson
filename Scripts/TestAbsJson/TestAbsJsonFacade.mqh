//+------------------------------------------------------------------+
//|                                            TestAbsJsonFacade.mqh |
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
void RunTestAbsJsonFacade()
  {
   RunTest(
      "Facade Clone",
      TestFacadeClone());

   RunTest(
      "Facade Clone Independence",
      TestFacadeCloneIndependence());

   RunTest(
      "Facade Validate String",
      TestFacadeValidateString());

   RunTest(
      "Facade Validate",
      TestFacadeValidate());

   RunTest(
      "JSON Facade Parse",
      TestJsonFacadeParse());

   RunTest(
      "JSON Facade Root",
      TestJsonFacadeRoot());

   RunTest(
      "JSON Facade Minify",
      TestJsonFacadeMinify());

   RunTest(
      "JSON Facade Pretty Print",
      TestJsonFacadePrettyPrint());

   RunTest(
      "JSON Facade Clear",
      TestJsonFacadeClear());

   RunTest(
      "JSON Facade Status",
      TestJsonFacadeStatus());

   RunTest(
      "JSON Facade Round Trip",
      TestJsonFacadeRoundTrip());

   RunTest(
      "JSON Facade File IO",
      TestJsonFacadeFileIO());

   RunTest(
      "JSON Facade Pretty File IO",
      TestJsonFacadePrettyFileIO());

   RunTest(
      "JSON Facade Unicode File IO",
      TestJsonFacadeUnicodeFileIO());
  }
//+------------------------------------------------------------------+
bool TestFacadeClone()
  {
   CAbsJson source;

   if(!source.Parse(
         "{\"name\":\"Amir\",\"age\":38,\"items\":[1,2,3]}"))
      return false;


   CAbsJson target;

   if(!source.Clone(target))
      return false;


   if(!AssertEqual(
         source.ToString(),
         target.ToString(),
         "Cloned JSON is not equal to source."))
      return false;


   return true;
  }
//+------------------------------------------------------------------+
bool TestFacadeCloneIndependence()
  {
   CAbsJson source;

   if(!source.Parse(
         "{\"name\":\"Amir\",\"age\":38}"))
      return false;


   CAbsJson target;

   if(!source.Clone(target))
      return false;


   CAbsJsonObject *object=
      target.Root().GetObject();

   if(object==NULL)
      return false;


   CAbsJsonProperty *property=
      object.FindProperty("name");

   if(property==NULL)
      return false;


   property.SetString("Changed");


   CAbsJsonObject *sourceObject=
      source.Root().GetObject();

   if(sourceObject==NULL)
      return false;


   if(!AssertEqual(
         "Amir",
         sourceObject.FindProperty("name").Value().GetString(),
         "Source was modified after cloning."))
      return false;


   return true;
  }
//+------------------------------------------------------------------+
bool TestFacadeValidateString()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\"}"))
      return false;


   string before=
      json.ToString();


   if(!json.Validate(
         "{\"id\":123,\"active\":true}"))
      return false;


   if(!AssertEqual(
         before,
         json.ToString(),
         "Validate changed Root."))
      return false;


   if(json.Validate(
         "{\"id\":}"))
      return false;


   if(!AssertEqual(
         before,
         json.ToString(),
         "Invalid Validate changed Root."))
      return false;


   return true;
  }
//+------------------------------------------------------------------+
bool TestFacadeValidate()
  {
   CAbsJson json;

   if(json.Validate())
      return false;


   if(!json.Parse(
         "{\"name\":\"Amir\"}"))
      return false;


   if(!json.Validate())
      return false;


   json.Clear();


   if(json.Validate())
      return false;


   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests Parse() of the CAbsJson facade.
 *
 * Checks that CAbsJson parses a JSON text with the internal parser and stores the result in Root.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeParse()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"age\":38}"))
      return false;

   if(!AssertEqual(
         "Amir",
         json.Root().GetObject().FindProperty("name").Value().GetString(),
         "Parsed name is incorrect."))
      return false;

   if(!AssertEqual(
         38,
         json.Root().GetObject().FindProperty("age").Value().GetInteger(),
         "Parsed age is incorrect."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests access to Root in the facade.
 *
 * Checks that the document root is exposed correctly and that its type and values are accessible.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeRoot()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"active\":true}"))
      return false;

   if(!AssertTrue(
         json.Root().IsObject(),
         "Root is not an Object."))
      return false;

   CAbsJsonObject *object=
      json.Root().GetObject();

   if(object==NULL)
      return false;

   if(!AssertEqual(
         "Amir",
         object.FindProperty("name").Value().GetString(),
         "Root name is incorrect."))
      return false;

   if(!AssertTrue(
         object.FindProperty("active").Value().GetBoolean(),
         "Root boolean value is incorrect."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests Minify() of the facade.
 *
 * Checks that Minify() produces compact JSON through CAbsJsonWriter.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeMinify()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"items\":[1,2,3]}"))
      return false;

   string result=
      json.Minify();

   if(!AssertEqual(
         "{\"name\":\"Amir\",\"items\":[1,2,3]}",
         result,
         "Minify output is incorrect."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests PrettyPrint() of the facade.
 *
 * Checks that PrettyPrint() formats the JSON through CAbsJsonWriter.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadePrettyPrint()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"items\":[1,2]}"))
      return false;

   string result=
      json.PrettyPrint(2);

   string expected=
      "{\r\n"
      "  \"name\": \"Amir\",\r\n"
      "  \"items\": [\r\n"
      "    1,\r\n"
      "    2\r\n"
      "  ]\r\n"
      "}";

   if(!AssertEqual(
         expected,
         result,
         "PrettyPrint output is incorrect."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests clearing the root of the facade.
 *
 * Checks that Clear() removes the current document and returns the root to the invalid state.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeClear()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"age\":38}"))
      return false;

   if(!AssertTrue(
         json.Validate(),
         "JSON should be valid before Clear."))
      return false;

   json.Clear();

   if(!AssertFalse(
         json.Validate(),
         "JSON should be invalid after Clear."))
      return false;

   if(!AssertTrue(
         json.Root().IsNull(),
         "Root should be Null after Clear."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the status of the facade.
 *
 * Checks that the success or error status of the parser is available through GetStatus() of the facade.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeStatus()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\"}"))
      return false;

   CAbsJsonStatus status=
      json.GetStatus();

   if(!AssertTrue(
         status.Success(),
         "Status should be OK after successful Parse."))
      return false;

   if(json.Parse(
         "{\"name\":}"))
      return false;

   status=
      json.GetStatus();

   if(!AssertFalse(
         status.Success(),
         "Status should indicate an error after invalid Parse."))
      return false;

   if(!AssertTrue(
         status.FullMessage()!="",
         "Error message should not be empty."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test through the facade.
 *
 * Parses a JSON text, writes it with the facade and parses the output again.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeRoundTrip()
  {
   CAbsJson source;

   string json=
      "{\"name\":\"Amir\",\"age\":38,\"active\":true,\"items\":[1,2,3]}";

   if(!source.Parse(json))
      return false;

   string written=
      source.Minify();

   CAbsJson target;

   if(!target.Parse(written))
      return false;

   if(!AssertEqual(
         source.Minify(),
         target.Minify(),
         "Round Trip JSON is not equal."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests saving and loading a JSON file.
 *
 * Saves a document to a file, loads it again and compares the result.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeFileIO()
  {
   string filename=
      "AbsJson_Facade_Test.json";


   CAbsJson source;

   if(!source.Parse(
         "{\"name\":\"Amir\",\"age\":38,\"items\":[1,2,3]}"))
      return false;


   if(!source.SaveFile(
         filename))
      return false;


   CAbsJson target;

   if(!target.LoadFile(
         filename))
      return false;


   if(!AssertEqual(
         source.Minify(),
         target.Minify(),
         "Loaded JSON is different from saved JSON."))
      return false;


   FileDelete(
      filename,
      FILE_COMMON);


   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests saving a JSON file with pretty printing.
 *
 * Saves the document pretty-printed and checks that the file can be loaded again.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadePrettyFileIO()
  {
   string filename=
      "AbsJson_Facade_Pretty_Test.json";


   CAbsJson source;

   if(!source.Parse(
         "{\"name\":\"Amir\",\"items\":[1,2,3]}"))
      return false;


   if(!source.SaveFile(
         filename,
         true))
      return false;


   CAbsJson target;

   if(!target.LoadFile(
         filename))
      return false;


   if(!AssertEqual(
         source.Minify(),
         target.Minify(),
         "Pretty file round trip failed."))
      return false;


   FileDelete(
      filename,
      FILE_COMMON);


   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests saving and loading JSON with Unicode.
 *
 * Checks that a document with Unicode characters survives saving and loading unchanged.
 *
 * @return
 * true when the test passes.
 */
bool TestJsonFacadeUnicodeFileIO()
  {
   string filename=
      "AbsJson_Facade_Unicode_Test.json";


   CAbsJson source;

   string json=
      "{\"name\":\"امیر\",\"city\":\"تهران\",\"message\":\"سلام دنیا\"}";


   if(!source.Parse(json))
      return false;


   if(!source.SaveFile(filename))
      return false;


   CAbsJson target;

   if(!target.LoadFile(filename))
     {
      FileDelete(
         filename,
         FILE_COMMON);

      return false;
     }


   if(!AssertEqual(
         source.Minify(),
         target.Minify(),
         "Unicode file round trip failed."))
     {
      FileDelete(
         filename,
         FILE_COMMON);

      return false;
     }


   FileDelete(
      filename,
      FILE_COMMON);


   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Round-trip test for saving and loading a JSON file.
 *
 * Creates a document, saves it to a file, reloads it and checks the final structure.
 *
 * @return
 * true when the test passes.
 */
bool TestSaveLoadRoundTrip()
  {
   string filename="AbsJson_TestSaveLoadRoundTrip.json";

   CAbsJson source;

   if(!source.Parse(
         "{\"name\":\"Amir\",\"age\":38,\"active\":true}"))
      return false;

   if(!source.SaveFile(filename))
      return false;

   CAbsJson loaded;

   if(!loaded.LoadFile(filename))
      return false;

   if(!AssertTrue(
         loaded.IsValid(),
         "Loaded JSON should be valid."))
      return false;

   if(!AssertEqual(
         "Amir",
         loaded.Root().GetObject().GetString("name"),
         "Loaded name is incorrect."))
      return false;

   if(!AssertEqual(
         38,
         loaded.Root().GetObject().GetInteger("age"),
         "Loaded age is incorrect."))
      return false;

   if(!AssertTrue(
         loaded.Root().GetObject().GetBoolean("active"),
         "Loaded active value is incorrect."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests loading an invalid file.
 *
 * Creates a file with invalid JSON and checks that LoadFile() reports it as invalid.
 *
 * @return
 * true when the test passes.
 */
bool TestLoadInvalidFile()
  {
   string filename="AbsJson_TestLoadInvalidFile.json";

   int handle=
      FileOpen(
         filename,
         FILE_WRITE |
         FILE_TXT   |
         FILE_COMMON);

   if(handle==INVALID_HANDLE)
      return false;

   FileWriteString(
      handle,
      "{\"name\":}");

   FileClose(handle);

   CAbsJson json;

   if(json.LoadFile(filename))
      return false;

   CAbsJsonStatus status =
      json.GetStatus();

   if(!AssertFalse(
         status.Success(),
         "Status should indicate an error after invalid file load."))
      return false;

   if(!AssertTrue(
         status.FullMessage()!="",
         "Invalid file error message should not be empty."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests loading an empty file.
 *
 * Creates a completely empty file and checks that LoadFile() rejects it and records an error status.
 *
 * @return
 * true when the test passes.
 */
bool TestLoadEmptyFile()
  {
   string filename="AbsJson_TestLoadEmptyFile.json";

   int handle=
      FileOpen(
         filename,
         FILE_WRITE |
         FILE_TXT   |
         FILE_COMMON);

   if(handle==INVALID_HANDLE)
      return false;

   FileClose(handle);

   CAbsJson json;

   if(json.LoadFile(filename))
      return false;

   CAbsJsonStatus status =
      json.GetStatus();

   if(!AssertFalse(
         status.Success(),
         "Status should indicate an error after empty file load."))
      return false;

   if(!AssertTrue(
         status.FullMessage()!="",
         "Empty file error message should not be empty."))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
