//+------------------------------------------------------------------+
//|                                                  TestAbsJson.mq5 |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#include "TestParseBasic.mqh"
#include "TestParseStructures.mqh"
#include "TestParseStrings.mqh"
#include "TestParseNumbers.mqh"
#include "TestParseInvalid.mqh"
#include "TestWrite.mqh"
#include "TestRoundTrip.mqh"
#include "TestClone.mqh"
#include "TestValue.mqh"
#include "TestClear.mqh"
#include "TestAbsJsonFacade.mqh"
#include "TestRegression.mqh"
#include "TestExtended.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {

   Print("==================================================");
   Print("AbsJson Unit Test");
   Print("==================================================");


//--------------------------------------------------
// Parser
//--------------------------------------------------

   RunTestParseBasic();

   RunTestParseStructures();

   RunTestParseStrings();

   RunTestParseNumbers();

   RunTestParseInvalid();

   RunTestWrite();

   RunTestRoundTrip();

   RunTestClone();

   RunTestValue();

   RunTestClear();
   
   RunTestAbsJsonFacade();

   RunTestRegression();

   RunTestExtended();

//--------------------------------------------------
// Summary
//--------------------------------------------------

   Print("--------------------------------------------------");

   Print("Passed : ",gPassed);

   Print("Failed : ",gFailed);

   Print("==================================================");

   // Usage examples (printed output only, not counted as tests).
   Print("--- Usage examples ---");
   ExampleParseAndRead();
   ExampleParseError();
   ExampleMinifyAndPrettyPrint();
  }
//+------------------------------------------------------------------+
/** @brief Example: parse a document and read two properties. */
void ExampleParseAndRead()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":\"Amir\",\"age\":38}"))
     {
      CAbsJsonStatus status;

      status=json.GetStatus();

      Print(
         "Parse Error : ",
         status.FullMessage());
     }
   else
     {
      Print(
         "Name = ",
         json.Root().GetObject().FindProperty("name").Value().GetString());

      Print(
         "Age = ",
         json.Root().GetObject().FindProperty("age").Value().GetInteger());
     }
  }
//+------------------------------------------------------------------+
/** @brief Example: parse invalid JSON on purpose and print the error with its location. */
void ExampleParseError()
  {
   CAbsJson json;

   if(!json.Parse(
         "{\"name\":}"))
     {
      CAbsJsonStatus status;

      status=json.GetStatus();

      // Expected: this input is invalid on purpose.
      Print(
         "Expected parse error : ",
         status.FullMessage());
     }
  }
//+------------------------------------------------------------------+
/** @brief Example: write a parsed document in compact and in indented form. */
void ExampleMinifyAndPrettyPrint()
  {
   CAbsJson json;

   json.Parse(
      "{\"name\":\"Amir\",\"items\":[1,2,3]}");

   Print(
      "Minify = ",
      json.Minify());

   Print(
      "PrettyPrint = ",
      json.PrettyPrint());
  }
//+------------------------------------------------------------------+
