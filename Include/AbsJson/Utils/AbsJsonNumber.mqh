//+------------------------------------------------------------------+
//|                                              AbsJsonNumber.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_NUMBER_MQH__
#define __ABS_JSON_NUMBER_MQH__

#property strict

#include "../Core/AbsJsonTypes.mqh"

/**
 * @file AbsJsonNumber.mqh
 * @brief Validation and formatting of JSON numbers (RFC 8259, section 6).
 */

/**
 * @class CAbsJsonNumber
 * @brief Static helpers for JSON number text.
 *
 * JSON number grammar: `[-] int [frac] [exp]` where `int` is `0` or a digit 1-9 followed by
 * digits, `frac` is `.` followed by at least one digit, and `exp` is `e|E [+|-] digits`.
 * A leading `+`, leading zeros ("007"), ".5", "5." and hex / NaN / Infinity are not valid JSON.
 */
class CAbsJsonNumber
  {
public:

   /** @brief Creates the helper (all members are static). */
                     CAbsJsonNumber()
     {
     }

   /** @brief Destructor. */
                    ~CAbsJsonNumber()
     {
     }

   /**
    * @brief Tests whether the text is a valid JSON integer (no fraction, no exponent).
    * @param text  Candidate text.
    * @return true for text such as "0", "-12", "345"; false for "", "-", "007", "1.0", "1e3".
    */
   static bool       IsInteger(
      const string text)
     {
      if(!Validate(text))
         return false;

      return !HasFractionOrExponent(text);
     }

   /**
    * @brief Tests whether the text is a valid JSON integer that fits in a signed 64-bit long.
    * @param text  Candidate text.
    * @return true when IsInteger() is true and the value is within [-2^63, 2^63-1].
    */
   static bool       IsLong(
      const string text)
     {
      if(!IsInteger(text))
         return false;

      return FitsInLong(text);
     }

   /**
    * @brief Tests whether the text is a valid JSON number written with a fraction and/or exponent.
    * @param text  Candidate text.
    * @return true for "1.5", "-0.25", "1e3", "2E-4"; false for integers and invalid text.
    */
   static bool       IsDouble(
      const string text)
     {
      if(!Validate(text))
         return false;

      return HasFractionOrExponent(text);
     }

   /**
    * @brief Tests whether the text is any valid JSON number (same as Validate()).
    * @param text  Candidate text.
    * @return true when valid.
    */
   static bool       IsNumber(
      const string text)
     {
      return Validate(text);
     }

   /**
    * @brief Classifies a JSON number text the way the parser stores it.
    *
    * @param text          Candidate text.
    * @param[out] type     ABS_JSON_NUMBER_INTEGER (fits in int), ABS_JSON_NUMBER_LONG (fits in long
    *                      but not in int) or ABS_JSON_NUMBER_DOUBLE (has a fraction and/or exponent).
    *                      Unchanged on failure.
    * @return true on success; false when the text is not a valid JSON number or is an integer
    *         outside the 64-bit range.
    */
   static bool       GetNumberType(
      const string text,
      ENUM_ABS_JSON_NUMBER_TYPE &type)
     {
      if(!Validate(text))
         return false;

      if(HasFractionOrExponent(text))
        {
         type=ABS_JSON_NUMBER_DOUBLE;
         return true;
        }

      if(!FitsInLong(text))
         return false;

      long value=StringToInteger(text);

      if(value>=-2147483648L && value<=2147483647L)
         type=ABS_JSON_NUMBER_INTEGER;
      else
         type=ABS_JSON_NUMBER_LONG;

      return true;
     }

   /**
    * @brief Checks that a valid integer text lies in the signed 64-bit range.
    *
    * Compares as text, so it is exact for all inputs. Leading zeros are tolerated.
    *
    * @param text  Optional '-' followed by decimal digits. Other input gives undefined results.
    * @return true when the value is within [-9223372036854775808, 9223372036854775807].
    */
   static bool       FitsInLong(
      const string text)
     {
      int length=StringLen(text);

      if(length<=0)
         return false;

      int start=0;
      bool negative=false;

      if(StringGetCharacter(text,0)=='-')
        {
         negative=true;
         start=1;
        }

      if(start>=length)
         return false;

      while(start<length && StringGetCharacter(text,start)=='0')
         start++;

      // Only zeros.
      if(start>=length)
         return true;

      int digits=length-start;

      if(digits<19)
         return true;

      if(digits>19)
         return false;

      string limit=negative ? "9223372036854775808" : "9223372036854775807";

      for(int i=0;i<19;i++)
        {
         ushort ch=StringGetCharacter(text,start+i);
         ushort lim=StringGetCharacter(limit,i);

         if(ch>lim)
            return false;

         if(ch<lim)
            return true;
        }

      return true;
     }

   /**
    * @brief Parses a valid JSON integer into an int.
    * @param text           Integer text.
    * @param[out] result    Receives the value on success (unchanged on failure).
    * @return true on success; false when the text is not a JSON integer or does not fit in an int.
    */
   static bool       ParseInteger(
      const string text,
      int &result)
     {
      long value;

      if(!ParseLong(text,value))
         return false;

      if(value<-2147483648L || value>2147483647L)
         return false;

      result=(int)value;

      return true;
     }

   /**
    * @brief Parses a valid JSON integer into a long.
    * @param text           Integer text.
    * @param[out] result    Receives the value on success (unchanged on failure).
    * @return true on success; false when the text is not a JSON integer or does not fit in a long.
    */
   static bool       ParseLong(
      const string text,
      long &result)
     {
      if(!IsLong(text))
         return false;

      result=StringToInteger(text);

      return true;
     }

   /**
    * @brief Parses any valid JSON number into a double.
    * @param text           Number text.
    * @param[out] result    Receives the value on success (unchanged on failure).
    * @return true on success; false when the text is not a valid JSON number.
    */
   static bool       ParseDouble(
      const string text,
      double &result)
     {
      if(!Validate(text))
         return false;

      result=StringToDouble(text);

      return true;
     }

   /**
    * @brief Formats an int as JSON number text.
    * @param value  The value.
    * @return Decimal text.
    */
   static string     IntegerToJson(
      const int value)
     {
      return IntegerToString(value);
     }

   /**
    * @brief Formats a long as JSON number text.
    * @param value  The value.
    * @return Decimal text.
    */
   static string     LongToJson(
      const long value)
     {
      return IntegerToString(value);
     }

   /**
    * @brief Formats a double as JSON number text that parses back to the identical double.
    *
    * Uses the shortest of 15 or 17 significant digits that round-trips (`%.15g`, falling back to
    * `%.17g`; the behavior of StringFormat's `%g` is verified by the regression tests). Very large or very small magnitudes use exponent notation ("1e+20", "1.5e-10"),
    * which is valid JSON. A whole-number double such as 5.0 is written as "5", so it reads
    * back as an integer type. Zero and negative zero give "0".
    * NaN and +/-infinity cannot be expressed in JSON and give "null".
    *
    * @param value  The value.
    * @return JSON text.
    */
   static string     DoubleToJson(
      const double value)
     {
      if(!MathIsValidNumber(value))
         return "null";

      if(value==0.0)
         return "0";

      string result=StringFormat("%.15g",value);

      if(StringToDouble(result)!=value)
         result=StringFormat("%.17g",value);

      return result;
     }

   /**
    * @brief Strict RFC 8259 validation of a complete number text.
    *
    * @param text  Candidate text, which must contain nothing but the number (no spaces).
    * @return true when the whole text matches the JSON number grammar.
    */
   static bool       Validate(
      const string text)
     {
      int length=StringLen(text);

      if(length==0)
         return false;

      int index=0;

      // Optional minus sign.
      if(StringGetCharacter(text,index)=='-')
        {
         index++;

         if(index>=length)
            return false;
        }

      // Integer part: "0" or [1-9][0-9]*  (no leading zeros).
      if(StringGetCharacter(text,index)=='0')
        {
         index++;

         if(index<length)
           {
            ushort next=StringGetCharacter(text,index);

            if(next>='0' && next<='9')
               return false;
           }
        }
      else
        {
         bool digit=false;

         while(index<length)
           {
            ushort ch=StringGetCharacter(text,index);

            if(ch>='0' && ch<='9')
              {
               digit=true;
               index++;
              }
            else
               break;
           }

         if(!digit)
            return false;
        }

      // Optional fraction: "." followed by at least one digit.
      if(index<length && StringGetCharacter(text,index)=='.')
        {
         index++;

         int start=index;

         while(index<length)
           {
            ushort ch=StringGetCharacter(text,index);

            if(ch>='0' && ch<='9')
               index++;
            else
               break;
           }

         if(start==index)
            return false;
        }

      // Optional exponent: e|E [+|-] digits.
      if(index<length)
        {
         ushort ch=StringGetCharacter(text,index);

         if(ch=='e' || ch=='E')
           {
            index++;

            if(index>=length)
               return false;

            ch=StringGetCharacter(text,index);

            if(ch=='+' || ch=='-')
              {
               index++;

               if(index>=length)
                  return false;
              }

            int start=index;

            while(index<length)
              {
               ch=StringGetCharacter(text,index);

               if(ch>='0' && ch<='9')
                  index++;
               else
                  break;
              }

            if(start==index)
               return false;
           }
        }

      return (index==length);
     }

private:

   /**
    * @brief Tells whether valid number text contains a '.', 'e' or 'E'.
    * @param text  Valid JSON number text.
    * @return true for non-integer notation.
    */
   static bool       HasFractionOrExponent(
      const string text)
     {
      int length=StringLen(text);

      for(int i=0;i<length;i++)
        {
         ushort ch=StringGetCharacter(text,i);

         if(ch=='.' || ch=='e' || ch=='E')
            return true;
        }

      return false;
     }
  };

#endif // __ABS_JSON_NUMBER_MQH__
//+------------------------------------------------------------------+
