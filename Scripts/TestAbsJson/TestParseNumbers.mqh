//+------------------------------------------------------------------+
//|                                             TestParseNumbers.mqh |
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
void RunTestParseNumbers()
  {
   RunTest(
      "Parse Negative Integer",
      TestParseNegativeInteger());

   RunTest(
      "Parse Negative Double",
      TestParseNegativeDouble());

   RunTest(
      "Parse Scientific Number",
      TestParseScientificNumber());

   RunTest(
      "Parse Overflow Integer",
      TestParseOverflowInteger());

   RunTest(
      "Parse Invalid Number",
      TestParseInvalidNumber());

   RunTest(
      "Parse Boundary Numbers",
      TestParseBoundaryNumbers());

   RunTest(
      "Parse Special Numbers",
      TestParseSpecialNumbers());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a negative integer.
 *
 * Checks the value type and the value of a negative integer.
 *
 * @return
 * true when the test passes.
 */
bool TestParseNegativeInteger()
  {

   string json=
      "-12345";

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
         "Parsed type is incorrect."))
      return false;


   if(!AssertEqual(
         -12345,
         value.GetInteger(),
         "Parsed negative integer is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a negative decimal number.
 *
 * Checks the value type and the value of a negative fraction.
 *
 * @return
 * true when the test passes.
 */
bool TestParseNegativeDouble()
  {

   string json=
      "-123.456";

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
         "Parsed type is incorrect."))
      return false;


   if(!AssertEqual(
         -123.456,
         value.GetDouble(),
         "Parsed negative double is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing numbers in scientific notation.
 *
 * Checks numbers with a zero or negative exponent and different exponent spellings.
 *
 * @return
 * true when the test passes.
 */
bool TestParseScientificNumber()
  {

   string json=
      "1.25e3";

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
         "Parsed type is incorrect."))
      return false;


   if(!AssertEqual(
         1250.0,
         value.GetDouble(),
         "Scientific number value is incorrect."))
      return false;



// Second case: negative value and negative exponent


   json=
      "-2.5E-2";


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
         "Parsed type is incorrect."))
      return false;


   if(!AssertEqual(
         -0.025,
         value.GetDouble(),
         "Negative scientific number value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests detection of integer overflow.
 *
 * Integers outside the signed 64-bit range must be rejected.
 *
 * @return
 * true when the test passes.
 */
bool TestParseOverflowInteger()
  {

   string json=
      "999999999999999999999999999999999999";

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(parser.Parse(json,value))
     {

      Print(
         "Parser accepted overflow integer.");

      return false;

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests detection of invalid numbers.
 *
 * Malformed numbers are parsed and must be rejected.
 *
 * @return
 * true when the test passes.
 */
bool TestParseInvalidNumber()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   string invalidNumbers[]=
     {
      "1..2",
      "--10",
      "1e",
      "1e+",
      ".5",
      "+10",
      "01",
      "1.",
      "-1.",
      "-.5",
      "0.",
      "00",
      "-",
      "+",
      "",
      " ",
      "1e-",
      "1E+",
      "1e--2",
      "1e++2",
      "1e+-2"
      "1e-+2",
      "1e2.3",
      "1e2e3",
      "1.2.3",
      "00.1",
      "-01",
      "01.5",
      "00.5",
      "1a",
      "1_0",
      "NaN",
      "Infinity",
      "-Infinity"
     };


   int total=
      ArraySize(invalidNumbers);


   for(int i=0;i<total;i++)
     {

      if(parser.Parse(
            invalidNumbers[i],
            value))
        {

         Print(
            "Parser accepted invalid number : ",
            invalidNumbers[i]);

         return false;

        }

     }


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the Integer and Long boundary values.
 *
 * Checks the largest and smallest int and long values and the first values outside the int range.
 *
 * @return
 * true when the test passes.
 */
bool TestParseBoundaryNumbers()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;



// Max Integer


   if(!parser.Parse(
         "2147483647",
         value))
     {

      Print("Parse Error : Max Integer");

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)value.JsonType(),
         "Max Integer type is incorrect."))
      return false;


   if(!AssertEqual(
         2147483647,
         value.GetInteger(),
         "Max Integer value is incorrect."))
      return false;




// Min Integer


   if(!parser.Parse(
         "-2147483648",
         value))
     {

      Print("Parse Error : Min Integer");

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)value.JsonType(),
         "Min Integer type is incorrect."))
      return false;


   if(!AssertEqual(
         (int)-2147483648,
         value.GetInteger(),
         "Min Integer value is incorrect."))
      return false;




// Outside the Integer range


   if(!parser.Parse(
         "2147483648",
         value))
     {

      Print("Parse Error : Long Positive");

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)value.JsonType(),
         "Long positive type is incorrect."))
      return false;




// Max Long


   if(!parser.Parse(
         "9223372036854775807",
         value))
     {

      Print("Parse Error : Max Long");

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)value.JsonType(),
         "Max Long type is incorrect."))
      return false;




// Min Long


   if(!parser.Parse(
         "-9223372036854775808",
         value))
     {

      Print("Parse Error : Min Long");

      return false;

     }


   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)value.JsonType(),
         "Min Long type is incorrect."))
      return false;



   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests special and boundary numbers that are valid JSON.
 *
 * Checks numbers with zero, a minus sign, a zero fraction and different exponent forms.
 *
 * @return
 * true when the test passes.
 */
bool TestParseSpecialNumbers()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   string validNumbers[]=
     {
      "0",
      "-0",
      "0.0",
      "-0.0",
      "1.0",
      "-1.0",
      "10.0",
      "-10.0",
      "1e0",
      "1E0",
      "1e+0",
      "1E+0",
      "1e-0",
      "1E-0",
      "1.0e0",
      "-1.0e0",
      "0.5",
      "-0.5",
      "10e2",
      "10E2",
      "1.25e2",
      "1.25e-2"
     };


   int total=
      ArraySize(validNumbers);


   for(int i=0;i<total;i++)
     {

      if(!parser.Parse(
            validNumbers[i],
            value))
        {

         Print(
            "Parser rejected valid special number : ",
            validNumbers[i]);

         return false;

        }

     }


   return true;

  }
//+------------------------------------------------------------------+
