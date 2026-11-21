//+------------------------------------------------------------------+
//|                                                   TestHelper.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#ifndef __TEST_HELPER_MQH__
#define __TEST_HELPER_MQH__

#property strict

/**
 * @file
 * @brief Helper functions of the AbsJson tests.
 *
 * Contains the Assert helper functions used by the unit tests.
 */

/**
 * @brief Checks that a condition is true.
 *
 * @param condition
 * Condition to check.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertTrue(
   const bool condition,
   const string message)
  {

   if(condition)
      return true;

   Print("AssertTrue Failed : ",message);

   return false;

  }


/**
 * @brief Checks that a condition is false.
 *
 * @param condition
 * Condition to check.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertFalse(
   const bool condition,
   const string message)
  {

   if(!condition)
      return true;

   Print("AssertFalse Failed : ",message);

   return false;

  }

/**
 * @brief Compares two floating point numbers (absolute tolerance 1e-7).
 *
 * @param expected
 * Expected value.
 *
 * @param actual
 * Actual value.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertEqual(
   const double expected,
   const double actual,
   const string message)
{
   const double epsilon = 0.0000001;

   if(MathAbs(expected - actual) > epsilon)
   {
      Print(
         "AssertEqual Failed : ",
         message,
         " Expected=",
         DoubleToString(expected,8),
         " Actual=",
         DoubleToString(actual,8));

      return false;
   }

   return true;
}

/**
 * @brief Compares two 32-bit integers.
 *
 * @param expected
 * Expected value.
 *
 * @param actual
 * Actual value.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertEqual(
   const int expected,
   const int actual,
   const string message)
  {

   if(expected==actual)
      return true;

   Print(message);

   Print("Expected : ",expected);

   Print("Actual   : ",actual);

   return false;

  }

/**
 * @brief Compares two 64-bit integers.
 *
 * @param expected
 * Expected value.
 *
 * @param actual
 * Actual value.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertEqual(
   const long expected,
   const long actual,
   const string message)
  {

   if(expected!=actual)
     {

      Print(
         "[ASSERT FAILED] ",
         message,
         " Expected=",
         IntegerToString(expected),
         " Actual=",
         IntegerToString(actual));

      return false;

     }


   return true;

  }

/**
 * @brief Compares two strings.
 *
 * @param expected
 * Expected value.
 *
 * @param actual
 * Actual value.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertEqual(
   const string expected,
   const string actual,
   const string message)
  {

   if(expected==actual)
      return true;

   Print(message);

   Print("Expected : ",expected);

   Print("Actual   : ",actual);

   return false;

  }



/**
 * @brief Checks that a pointer is NULL.
 *
 * @param pointer
 * Pointer to check.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertNull(
   const void *pointer,
   const string message)
  {

   if(pointer==NULL)
      return true;

   Print("AssertNull Failed : ",message);

   return false;

  }


/**
 * @brief Checks that a pointer is not NULL.
 *
 * @param pointer
 * Pointer to check.
 *
 * @param message
 * Message printed when the check fails.
 *
 * @return
 * true when the check passes, false otherwise.
 */
bool AssertNotNull(
   const void *pointer,
   const string message)
  {

   if(pointer!=NULL)
      return true;

   Print("AssertNotNull Failed : ",message);

   return false;

  }

#endif // __TEST_HELPER_MQH__
//+------------------------------------------------------------------+
