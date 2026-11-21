//+------------------------------------------------------------------+
//|                                                     TestBase.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#include <AbsJson/AbsJson.mqh>
#include "TestHelper.mqh"
//--------------------------------------------------
// Test counters
//--------------------------------------------------

int gPassed = 0;
int gFailed = 0;

/**
 * @brief Prints the header of a test.
 *
 * @param testName
 * Test name.
 */
void BeginTest(
   const string testName)
  {

   Print("--------------------------------------------------");
   Print("Running : ",testName);

  }

/**
 * @brief Records the result of a test.
 *
 * @param testName
 * Test name.
 *
 * @param result
 * Test result.
 */
void EndTest(
   const string testName,
   const bool result)
  {

   if(result)
     {
      gPassed++;
      Print("[PASS] ",testName);
     }
   else
     {
      gFailed++;
      Print("[FAIL] ",testName);
     }

  }

/**
 * @brief Runs one test and records its result.
 *
 * @param testName
 * Test name.
 *
 * @param result
 * Test result.
 */
void RunTest(
   const string testName,
   const bool result)
  {

   EndTest(
      testName,
      result);

  }
