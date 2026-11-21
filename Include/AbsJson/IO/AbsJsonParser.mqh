//+------------------------------------------------------------------+
//|                                              AbsJsonParser.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_PARSER_MQH__
#define __ABS_JSON_PARSER_MQH__

#property strict

#include "../Core/AbsJsonBase.mqh"
#include "../Core/AbsJsonValue.mqh"
#include "../Objects/AbsJsonObject.mqh"
#include "../Objects/AbsJsonArray.mqh"
#include "../Utils/AbsJsonNumber.mqh"

/**
 * @file AbsJsonParser.mqh
 * @brief Recursive-descent JSON parser (RFC 8259).
 */

/**
 * @class CAbsJsonParser
 * @brief Parses JSON text into CAbsJsonValue / CAbsJsonObject / CAbsJsonArray.
 *
 * **Accepted:** the complete RFC 8259 grammar - objects, arrays, strings with all escapes
 * (including \uXXXX), numbers, true / false / null - with insignificant whitespace
 * (space, tab, CR, LF). A leading U+FEFF byte-order mark is skipped.
 *
 * **Rejected (error is recorded, no exception):**
 *  - empty / whitespace-only text (ABS_JSON_ERROR_EMPTY_DOCUMENT);
 *  - any extra characters after the top-level value;
 *  - trailing commas, comments, single-quoted strings, unquoted names;
 *  - raw control characters (< U+0020) inside strings;
 *  - numbers with a leading '+', leading zeros, ".5", "5.", NaN, Infinity;
 *  - integers outside the signed 64-bit range (ABS_JSON_ERROR_INVALID_NUMBER);
 *  - doubles that overflow (no finite double);
 *  - duplicate property names in one object (ABS_JSON_ERROR_DUPLICATE_PROPERTY);
 *  - nesting deeper than AbsJsonConst::MAX_DEPTH (ABS_JSON_ERROR_DEPTH_EXCEEDED).
 *
 * **Number mapping:** an integer that fits in int becomes ABS_JSON_INTEGER, a larger one
 * that fits in long becomes ABS_JSON_LONG, everything with a fraction or exponent becomes
 * ABS_JSON_DOUBLE. "-0" becomes the integer 0.
 *
 * **Strings:** stored as MQL5 UTF-16 strings. \uXXXX escapes are converted one UTF-16 code unit at
 * a time, so surrogate pairs ("\uD83D\uDE00") form the right character; an unpaired surrogate is
 * kept as is (RFC 8259 allows it syntactically). \u0000 cannot be stored in an MQL5 string and is dropped.
 *
 * **Errors** carry a code, a message and the line / column / character position at which the
 * problem was detected (see CAbsJsonStatus). The status is reset at the start of every Parse().
 */
class CAbsJsonParser : public CAbsJsonBase
  {
private:

   /// Text being parsed.
   string            m_text;

   /// Length of m_text in characters.
   int               m_length;

   /// Current 0-based character offset.
   int               m_position;

   /// Current 1-based line.
   int               m_line;

   /// Current 1-based column.
   int               m_column;

   /// Current container nesting depth.
   int               m_depth;

public:

   /** @brief Creates a parser in the reset state. */
                     CAbsJsonParser()
     {
      Reset();
     }

   /** @brief Destructor. */
   virtual          ~CAbsJsonParser()
     {
     }

private:

   /** @brief Resets text, position, depth and status. */
   void              Reset()
     {
      m_text="";
      m_length=0;
      m_position=0;
      m_line=1;
      m_column=1;
      m_depth=0;

      ClearStatus();
     }

   /**
    * @brief Resets the parser and loads new text.
    * @param json  Text to parse.
    */
   void              SetText(
      const string json)
     {
      Reset();

      m_text=json;
      m_length=StringLen(json);
     }

   /**
    * @brief Records an error at the current position.
    * @param code     Error code.
    * @param message  Message (empty = default message of @p code).
    * @return Always false.
    */
   bool              Fail(
      const ENUM_ABS_JSON_ERROR code,
      const string message="")
     {
      return SetError(code,message,m_line,m_column,m_position);
     }

   /** @return true when the whole text has been consumed. */
   bool              IsEnd() const
     {
      return (m_position>=m_length);
     }

   /** @return The current character, or 0 at the end of the text. */
   ushort            Current() const
     {
      if(IsEnd())
         return 0;

      return (ushort)StringGetCharacter(m_text,m_position);
     }

   /** @brief Moves one character forward and updates line / column. */
   void              Advance()
     {
      if(IsEnd())
         return;

      ushort ch=(ushort)StringGetCharacter(m_text,m_position);

      m_position++;

      if(ch=='\n')
        {
         m_line++;
         m_column=1;
        }
      else
         m_column++;
     }

   /** @brief Skips space, tab, CR and LF. */
   void              SkipWhiteSpace()
     {
      while(!IsEnd())
        {
         ushort ch=Current();

         if(ch==' ' || ch=='\t' || ch=='\r' || ch=='\n')
           {
            Advance();
            continue;
           }

         break;
        }
     }

   /**
    * @brief Consumes the current character when it equals @p expected.
    * @param expected  Expected character.
    * @return true when it matched and was consumed.
    */
   bool              Match(
      const ushort expected)
     {
      if(IsEnd())
         return false;

      if(Current()!=expected)
         return false;

      Advance();

      return true;
     }

   /**
    * @brief Enters a container; fails when the nesting limit is exceeded.
    * @return true when allowed. Every successful call must be paired with LeaveContainer().
    */
   bool              EnterContainer()
     {
      if(m_depth>=AbsJsonConst::MAX_DEPTH)
         return Fail(ABS_JSON_ERROR_DEPTH_EXCEEDED);

      m_depth++;

      return true;
     }

   /** @brief Leaves a container entered with EnterContainer(). */
   void              LeaveContainer()
     {
      m_depth--;
     }

public:

   /**
    * @brief Parses JSON text into a value.
    *
    * @param json            JSON text.
    * @param[out] value      Receives the parsed value. It is cleared first and is left null on failure.
    * @return true on success; false on failure (see GetStatus() / Status()).
    */
   bool              Parse(
      const string json,
      CAbsJsonValue &value)
     {
      value.Clear();

      SetText(json);

      // Tolerate a byte-order mark (RFC 8259 section 8.1 allows ignoring it).
      if(!IsEnd() && Current()==0xFEFF)
         Advance();

      SkipWhiteSpace();

      if(IsEnd())
         return Fail(ABS_JSON_ERROR_EMPTY_DOCUMENT);

      if(!ParseValue(value))
        {
         value.Clear();
         return false;
        }

      SkipWhiteSpace();

      if(!IsEnd())
        {
         value.Clear();
         return Fail(ABS_JSON_ERROR_INVALID_JSON,"Unexpected characters after JSON value.");
        }

      return true;
     }

   /**
    * @brief Parses JSON text whose top-level value must be an object.
    *
    * @param json            JSON text.
    * @param[out] object     Receives a deep copy of the parsed object (replaced on success; untouched on failure).
    * @return true on success; false on failure, including ABS_JSON_ERROR_EXPECT_OBJECT when the
    *         top-level value is not an object.
    */
   bool              Parse(
      const string json,
      CAbsJsonObject &object)
     {
      CAbsJsonValue value;

      if(!Parse(json,value))
         return false;

      if(value.JsonType()!=ABS_JSON_OBJECT)
         return Fail(ABS_JSON_ERROR_EXPECT_OBJECT);

      if(!object.CopyFrom(*value.GetObject()))
         return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY,"Copying the parsed object failed.");

      return true;
     }

   /**
    * @brief Parses JSON text whose top-level value must be an array.
    *
    * @param json           JSON text.
    * @param[out] array     Receives a deep copy of the parsed array (replaced on success; untouched on failure).
    * @return true on success; false on failure, including ABS_JSON_ERROR_EXPECT_ARRAY when the
    *         top-level value is not an array.
    */
   bool              Parse(
      const string json,
      CAbsJsonArray &array)
     {
      CAbsJsonValue value;

      if(!Parse(json,value))
         return false;

      if(value.JsonType()!=ABS_JSON_ARRAY)
         return Fail(ABS_JSON_ERROR_EXPECT_ARRAY);

      if(!array.CopyFrom(*value.GetArray()))
         return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY,"Copying the parsed array failed.");

      return true;
     }

private:

   /**
    * @brief Parses a string literal starting at the opening quote.
    * @param[out] text  Receives the unescaped content.
    * @return true on success.
    */
   bool              ParseString(
      string &text)
     {
      text="";

      if(!Match('"'))
         return Fail(ABS_JSON_ERROR_UNEXPECTED_TOKEN,"Expected '\"'.");

      int runStart=m_position;

      while(m_position<m_length)
        {
         ushort ch=(ushort)StringGetCharacter(m_text,m_position);

         // Ordinary character: part of the current run (a string cannot contain a line break).
         if(ch!='"' && ch!='\\' && ch>=32)
           {
            m_position++;
            m_column++;
            continue;
           }

         // Flush the run collected so far.
         if(m_position>runStart)
            text+=StringSubstr(m_text,runStart,m_position-runStart);

         if(ch=='"')
           {
            Advance();
            return true;
           }

         if(ch<32)
            return Fail(ABS_JSON_ERROR_INVALID_CHARACTER,"Control character in string.");

         // Backslash escape.
         Advance();

         if(IsEnd())
            return Fail(ABS_JSON_ERROR_UNEXPECTED_END,"Unexpected end after escape sequence.");

         ch=Current();

         switch(ch)
           {
            case '"':
               text+="\"";
               break;
            case '\\':
               text+="\\";
               break;
            case '/':
               text+="/";
               break;
            case 'b':
               text+=CharToString(8);
               break;
            case 'f':
               text+=CharToString(12);
               break;
            case 'n':
               text+="\n";
               break;
            case 'r':
               text+="\r";
               break;
            case 't':
               text+="\t";
               break;
            case 'u':
              {
               Advance();

               if(!ParseUnicodeEscape(text))
                  return false;

               runStart=m_position;
               continue;
              }
            default:
               return Fail(ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE,"Invalid escape sequence.");
           }

         Advance();

         runStart=m_position;
        }

      return Fail(ABS_JSON_ERROR_UNEXPECTED_END,"Unexpected end while reading string.");
     }

   /**
    * @brief Parses the literal true or false.
    * @param[out] value  Receives the boolean.
    * @return true on success.
    */
   bool              ParseBoolean(
      bool &value)
     {
      if(m_position+4<=m_length && StringSubstr(m_text,m_position,4)=="true")
        {
         value=true;
         m_position+=4;
         m_column+=4;
         return true;
        }

      if(m_position+5<=m_length && StringSubstr(m_text,m_position,5)=="false")
        {
         value=false;
         m_position+=5;
         m_column+=5;
         return true;
        }

      return Fail(ABS_JSON_ERROR_INVALID_BOOLEAN,"Invalid boolean value.");
     }

   /**
    * @brief Parses the literal null.
    * @return true on success.
    */
   bool              ParseNull()
     {
      if(m_position+4>m_length)
         return Fail(ABS_JSON_ERROR_UNEXPECTED_END,"Unexpected end while reading null.");

      if(StringSubstr(m_text,m_position,4)!="null")
         return Fail(ABS_JSON_ERROR_INVALID_NULL,"Invalid null value.");

      m_position+=4;
      m_column+=4;

      return true;
     }

   /**
    * @brief Parses a number token.
    *
    * Grammar: `[-] (0 | [1-9][0-9]*) [. digits] [(e|E) [+|-] digits]`.
    *
    * @param[out] value  Receives an integer, long or double value.
    * @return true on success.
    */
   bool              ParseNumber(
      CAbsJsonValue &value)
     {
      int startPosition=m_position;
      bool hasDecimal=false;
      bool hasExponent=false;

      if(Current()=='-')
         Advance();

      if(IsEnd())
         return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Invalid number.");

      ushort ch=Current();

      if(ch=='0')
        {
         Advance();

         // A leading zero must not be followed by another digit.
         if(!IsEnd())
           {
            ch=Current();

            if(ch>='0' && ch<='9')
               return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Leading zero is not allowed.");
           }
        }
      else
         if(ch>='1' && ch<='9')
           {
            Advance();

            while(!IsEnd())
              {
               ch=Current();

               if(ch<'0' || ch>'9')
                  break;

               Advance();
              }
           }
         else
            return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Invalid number.");

      // Fraction.
      if(!IsEnd() && Current()=='.')
        {
         hasDecimal=true;

         Advance();

         bool decimalDigit=false;

         while(!IsEnd())
           {
            ch=Current();

            if(ch<'0' || ch>'9')
               break;

            decimalDigit=true;

            Advance();
           }

         if(!decimalDigit)
            return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Digit expected after decimal point.");
        }

      // Exponent.
      if(!IsEnd())
        {
         ch=Current();

         if(ch=='e' || ch=='E')
           {
            hasExponent=true;

            Advance();

            if(!IsEnd())
              {
               ch=Current();

               if(ch=='+' || ch=='-')
                  Advance();
              }

            bool exponentDigit=false;

            while(!IsEnd())
              {
               ch=Current();

               if(ch<'0' || ch>'9')
                  break;

               exponentDigit=true;

               Advance();
              }

            if(!exponentDigit)
               return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Invalid exponent.");
           }
        }

      string numberText=StringSubstr(m_text,startPosition,m_position-startPosition);

      if(hasDecimal || hasExponent)
        {
         double valueDouble=StringToDouble(numberText);

         if(!MathIsValidNumber(valueDouble))
            return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Number is out of the double range.");

         value.SetDouble(valueDouble);

         return true;
        }

      if(!CAbsJsonNumber::FitsInLong(numberText))
         return Fail(ABS_JSON_ERROR_INVALID_NUMBER,"Integer overflow.");

      long valueLong=StringToInteger(numberText);

      if(valueLong>=-2147483648L && valueLong<=2147483647L)
        {
         value.SetInteger((int)valueLong);
         return true;
        }

      value.SetLong(valueLong);

      return true;
     }

   /**
    * @brief Parses any JSON value at the current position (leading whitespace allowed).
    * @param[out] value  Receives the value.
    * @return true on success.
    */
   bool              ParseValue(
      CAbsJsonValue &value)
     {
      SkipWhiteSpace();

      if(IsEnd())
         return Fail(ABS_JSON_ERROR_UNEXPECTED_END,"Unexpected end of document.");

      ushort ch=Current();

      if(ch=='{')
        {
         CAbsJsonObject *object=new CAbsJsonObject();

         if(object==NULL)
            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);

         if(!ParseObject(*object))
           {
            delete object;
            return false;
           }

         value.SetObject(object);

         return true;
        }

      if(ch=='[')
        {
         CAbsJsonArray *array=new CAbsJsonArray();

         if(array==NULL)
            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);

         if(!ParseArray(*array))
           {
            delete array;
            return false;
           }

         value.SetArray(array);

         return true;
        }

      if(ch=='"')
        {
         string text;

         if(!ParseString(text))
            return false;

         value.SetString(text);

         return true;
        }

      if(ch=='t' || ch=='f')
        {
         bool b;

         if(!ParseBoolean(b))
            return false;

         value.SetBoolean(b);

         return true;
        }

      if(ch=='n')
        {
         if(!ParseNull())
            return false;

         value.SetNull();

         return true;
        }

      // A '+' is routed to ParseNumber so that it is reported as an invalid number.
      if(ch=='-' || ch=='+' || (ch>='0' && ch<='9'))
         return ParseNumber(value);

      return Fail(ABS_JSON_ERROR_UNEXPECTED_TOKEN,"Unexpected token.");
     }

   /**
    * @brief Parses an array starting at '['.
    * @param array  Receives the elements (must be empty).
    * @return true on success.
    */
   bool              ParseArray(
      CAbsJsonArray &array)
     {
      if(!EnterContainer())
         return false;

      bool ok=ParseArrayBody(array);

      LeaveContainer();

      return ok;
     }

   /**
    * @brief Body of ParseArray() (kept separate so that the depth is always restored).
    * @param array  Receives the elements.
    * @return true on success.
    */
   bool              ParseArrayBody(
      CAbsJsonArray &array)
     {
      if(!Match('['))
         return Fail(ABS_JSON_ERROR_EXPECT_ARRAY,"'[' expected.");

      SkipWhiteSpace();

      if(Match(']'))
         return true;

      while(true)
        {
         SkipWhiteSpace();

         CAbsJsonValue *value=new CAbsJsonValue();

         if(value==NULL)
            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);

         if(!ParseValue(*value))
           {
            delete value;
            return false;
           }

         if(!array.AddItem(value))
           {
            delete value;
            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);
           }

         SkipWhiteSpace();

         if(Match(']'))
            return true;

         if(Match(','))
           {
            SkipWhiteSpace();
            continue;
           }

         return Fail(ABS_JSON_ERROR_EXPECT_COMMA,"',' or ']' expected.");
        }

      return false;
     }

   /**
    * @brief Parses an object starting at '{'.
    * @param object  Receives the properties (must be empty).
    * @return true on success.
    */
   bool              ParseObject(
      CAbsJsonObject &object)
     {
      if(!EnterContainer())
         return false;

      bool ok=ParseObjectBody(object);

      LeaveContainer();

      return ok;
     }

   /**
    * @brief Body of ParseObject() (kept separate so that the depth is always restored).
    * @param object  Receives the properties.
    * @return true on success.
    */
   bool              ParseObjectBody(
      CAbsJsonObject &object)
     {
      if(!Match('{'))
         return Fail(ABS_JSON_ERROR_EXPECT_OBJECT,"'{' expected.");

      SkipWhiteSpace();

      if(Match('}'))
         return true;

      while(true)
        {
         SkipWhiteSpace();

         if(Current()!='"')
            return Fail(ABS_JSON_ERROR_EXPECT_STRING,"Property name must be string.");

         // Remember where the name starts, for a precise duplicate-name error.
         int keyLine=m_line;
         int keyColumn=m_column;
         int keyPosition=m_position;

         string name;

         if(!ParseString(name))
            return false;

         SkipWhiteSpace();

         if(!Match(':'))
            return Fail(ABS_JSON_ERROR_EXPECT_COLON,"':' expected.");

         SkipWhiteSpace();

         CAbsJsonProperty *property=new CAbsJsonProperty(name);

         if(property==NULL)
            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);

         // Parse straight into the property's own value (no intermediate deep copy).
         if(!ParseValue(*property.Value()))
           {
            delete property;
            return false;
           }

         if(!object.AddProperty(property))
           {
            delete property;

            if(object.Contains(name))
               return SetError(
                         ABS_JSON_ERROR_DUPLICATE_PROPERTY,
                         "Duplicate property name: "+name,
                         keyLine,
                         keyColumn,
                         keyPosition);

            return Fail(ABS_JSON_ERROR_OUT_OF_MEMORY);
           }

         SkipWhiteSpace();

         if(Match('}'))
            return true;

         if(Match(','))
           {
            SkipWhiteSpace();
            continue;
           }

         return Fail(ABS_JSON_ERROR_EXPECT_COMMA,"',' or '}' expected.");
        }

      return false;
     }

   /**
    * @brief Reads the four hex digits of a \uXXXX escape (the parser is positioned just after the 'u').
    * @param text  Receives the decoded UTF-16 code unit.
    * @return true on success.
    */
   bool              ParseUnicodeEscape(
      string &text)
     {
      int code=0;

      for(int i=0;i<4;i++)
        {
         if(IsEnd())
            return Fail(ABS_JSON_ERROR_UNEXPECTED_END);

         ushort ch=Current();

         int digit=-1;

         if(ch>='0' && ch<='9')
            digit=ch-'0';
         else
            if(ch>='a' && ch<='f')
               digit=10+(ch-'a');
            else
               if(ch>='A' && ch<='F')
                  digit=10+(ch-'A');

         if(digit<0)
            return Fail(ABS_JSON_ERROR_INVALID_UNICODE,"Invalid unicode escape.");

         code=(code<<4)+digit;

         Advance();
        }

      // U+0000 cannot be stored in an MQL5 string; it is dropped.
      if(code!=0)
         text+=ShortToString((ushort)code);

      return true;
     }
  };

#endif // __ABS_JSON_PARSER_MQH__
//+------------------------------------------------------------------+
