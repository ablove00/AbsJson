//+------------------------------------------------------------------+
//|                                             TestParseStrings.mqh |
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
void RunTestParseStrings()
  {
   RunTest(
      "Parse Escape Characters",
      TestParseEscapeCharacters());

   RunTest(
      "Parse Unicode",
      TestParseUnicode());

   RunTest(
      "Parse Unicode Escape",
      TestParseUnicodeEscape());

   RunTest(
      "Parse Multiple Unicode Escapes",
      TestParseMultipleUnicodeEscapes());

   RunTest(
      "Parse Invalid Control Character",
      TestParseInvalidControlCharacter());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing escape characters.
 *
 * Parses a string with escapes and checks the decoded characters.
 *
 * @return
 * true when the test passes.
 */
bool TestParseEscapeCharacters()
  {

   string json=
      "{\"text\":\"Line1\\nLine2\\t\\\"Quoted\\\"\\\\Folder\\/File\"}";

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


   string expected=
      "Line1\nLine2\t\"Quoted\"\\Folder/File";


   if(!AssertEqual(
         expected,
         object.FindProperty("text").Value().GetString(),
         "Escape characters were parsed incorrectly."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a Unicode escape.
 *
 * Checks that a \uXXXX escape is converted to the matching Unicode character.
 *
 * @return
 * true when the test passes.
 */
bool TestParseUnicode()
  {

   string json=
      "{\"text\":\"\\u0041\\u0042\\u0043\"}";

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
         "ABC",
         object.FindProperty("text").Value().GetString(),
         "Unicode value was parsed incorrectly."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing a single Unicode escape.
 *
 * Checks that one \uXXXX escape is decoded to the matching character.
 *
 * @return
 * true when the test passes.
 */
bool TestParseUnicodeEscape()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(
         "\"\\u0041\"",
         value))
      return false;


   if(!AssertEqual(
         "A",
         value.GetString(),
         "Unicode escape value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests parsing consecutive Unicode escapes.
 *
 * Checks that several escapes in a row are decoded in the correct order.
 *
 * @return
 * true when the test passes.
 */
bool TestParseMultipleUnicodeEscapes()
  {

   CAbsJsonParser parser;

   CAbsJsonValue value;


   if(!parser.Parse(
         "\"\\u0041\\u0042\\u0043\"",
         value))
      return false;


   if(!AssertEqual(
         "ABC",
         value.GetString(),
         "Multiple Unicode escape value is incorrect."))
      return false;


   if(!parser.Parse(
         "\"\\u0031\\u0032\\u0033\"",
         value))
      return false;


   if(!AssertEqual(
         "123",
         value.GetString(),
         "Multiple numeric Unicode escape value is incorrect."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests that control characters in a JSON string are rejected.
 *
 * According to RFC 8259 the characters U+0000 to U+001F must not appear unescaped inside a JSON string, so such strings are checked and must be rejected.
 *
 * @return
 * true when the test passes.
 */
bool TestParseInvalidControlCharacter()
  {

   string invalidStrings[]=
     {
      "\"\x01\"",
      "\"\x02\"",
      "\"\x07\"",
      "\"\x0B\"",
      "\"\x0C\"",
      "\"\x1B\"",
      "\"\x1F\""
     };


   int total=
      ArraySize(invalidStrings);


   for(int i=0;i<total;i++)
     {

      CAbsJsonParser parser;

      CAbsJsonValue value;


      if(parser.Parse(
            invalidStrings[i],
            value))
        {

         Print(
            "Parser accepted invalid control character at index : ",
            i);

         return false;

        }

     }


   return true;

  }
//+------------------------------------------------------------------+
