//+------------------------------------------------------------------+
//|                                             TestParseInvalid.mqh |
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
void RunTestParseInvalid()
  {
   RunTest(
      "Invalid Trailing Comma",
      TestInvalidTrailingComma());

   RunTest(
      "Invalid Multiple Root Values",
      TestInvalidMultipleRootValues());

   RunTest(
      "Invalid Root",
      TestInvalidRoot());

   RunTest(
      "Parse Duplicate Property",
      TestParseDuplicateProperty());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests detection of trailing commas in objects and arrays.
 *
 * A trailing comma in an object or an array must be rejected as invalid JSON.
 *
 * @return
 * true when the test passes.
 */
bool TestInvalidTrailingComma()
  {

   CAbsJsonParser parser;

   CAbsJsonObject object;


   string invalidObject=
      "{\"name\":\"Amir\",}";


   if(parser.Parse(
         invalidObject,
         object))
     {

      Print(
         "Parser accepted trailing comma in object.");

      return false;

     }


   CAbsJsonArray array;


   string invalidArray=
      "[1,2,]";


   if(parser.Parse(
         invalidArray,
         array))
     {

      Print(
         "Parser accepted trailing comma in array.");

      return false;

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests that several values at the root are rejected.
 *
 * The parser must accept exactly one complete JSON value and reject extra values after it.
 *
 * @return
 * true when the test passes.
 */
bool TestInvalidMultipleRootValues()
  {

   string invalidValues[]=
     {
      "123 456",
      "true false",
      "\"first\" \"second\"",
      "{} {}",
      "[] []",
      "{\"a\":1} {\"b\":2}",
      "[1] [2]"
     };


   int total=
      ArraySize(invalidValues);


   for(int i=0;i<total;i++)
     {

      CAbsJsonParser parser;

      CAbsJsonValue value;


      if(parser.Parse(
            invalidValues[i],
            value))
        {
         Print(
            "Parser accepted multiple root values : ",
            invalidValues[i]);

         return false;
        }

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests that an invalid root is rejected.
 *
 * Inputs without a valid JSON value must be rejected.
 *
 * @return
 * true when the test passes.
 */
bool TestInvalidRoot()
  {

   string invalidRoots[]=
     {
      "",
      " ",
      "\t",
      "\r\n",
      ":",
      ",",
      "{",
      "}",
      "[",
      "]"
     };


   int total=
      ArraySize(invalidRoots);


   for(int i=0;i<total;i++)
     {

      CAbsJsonParser parser;

      CAbsJsonValue value;


      if(parser.Parse(
            invalidRoots[i],
            value))
        {
         Print(
            "Parser accepted invalid root : [",
            invalidRoots[i],
            "]");

         return false;
        }

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests that duplicate properties are rejected.
 *
 * The parser must reject a document that contains the same property name twice in one object.
 *
 * @return
 * true when the test passes.
 */
bool TestParseDuplicateProperty()
  {

   string invalidObjects[]=
     {
      "{\"id\":1,\"id\":2}",
      "{\"name\":\"Amir\",\"name\":\"Ali\"}",
      "{\"value\":10,\"value\":20,\"value\":30}",
      "{\"user\":{\"id\":1},\"user\":{\"id\":2}}"
     };


   int total=
      ArraySize(invalidObjects);


   for(int i=0;i<total;i++)
     {

      CAbsJsonParser parser;

      CAbsJsonValue value;


      if(parser.Parse(
            invalidObjects[i],
            value))
        {

         Print(
            "Parser accepted duplicate property : ",
            invalidObjects[i]);

         return false;

        }

     }


   return true;

  }
//+------------------------------------------------------------------+
