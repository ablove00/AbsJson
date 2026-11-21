//+------------------------------------------------------------------+
//|                                              AbsJsonEscape.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_ESCAPE_MQH__
#define __ABS_JSON_ESCAPE_MQH__

#property strict

/**
 * @file AbsJsonEscape.mqh
 * @brief Escaping and unescaping of JSON string content (RFC 8259, section 7).
 */

/**
 * @class CAbsJsonEscape
 * @brief Static helpers that convert between raw text and JSON string content.
 *
 * All functions work on the string *content* only; the surrounding double quotes
 * are not added or removed. MQL5 strings are UTF-16, so a character outside the
 * Basic Multilingual Plane is stored as a surrogate pair and is escaped as two
 * consecutive \uXXXX sequences, which is exactly the JSON representation.
 *
 * @note A \u0000 escape cannot be represented in an MQL5 string (the zero character
 *       terminates it), so Unescape() drops it.
 */
class CAbsJsonEscape
  {
public:

   /** @brief Creates the helper (all members are static). */
                     CAbsJsonEscape()
     {
     }

   /** @brief Destructor. */
                    ~CAbsJsonEscape()
     {
     }

   /**
    * @brief Escapes text so that it can be placed between the quotes of a JSON string.
    *
    * Escaped: `"` `\` and every control character below U+0020
    * (as \b \f \n \r \t, or \u00XX for the others). All other characters, including
    * non-ASCII ones, are copied unchanged. The `/` character is not escaped.
    *
    * @param text  Raw text.
    * @return Escaped text.
    */
   static string     Escape(
      const string text)
     {
      int length=StringLen(text);

      // Fast path: copy whole runs of characters that need no escaping.
      string result="";
      int runStart=0;

      for(int i=0;i<length;i++)
        {
         ushort ch=StringGetCharacter(text,i);

         if(!NeedEscape(ch))
            continue;

         if(i>runStart)
            result+=StringSubstr(text,runStart,i-runStart);

         runStart=i+1;

         switch(ch)
           {
            case 34:
               result+="\\\"";
               break;
            case 92:
               result+="\\\\";
               break;
            case 8:
               result+="\\b";
               break;
            case 12:
               result+="\\f";
               break;
            case 10:
               result+="\\n";
               break;
            case 13:
               result+="\\r";
               break;
            case 9:
               result+="\\t";
               break;
            default:
               result+=UnicodeEscape(ch);
               break;
           }
        }

      if(runStart==0)
         return text;

      if(runStart<length)
         result+=StringSubstr(text,runStart,length-runStart);

      return result;
     }

   /**
    * @brief Tells whether a character must be escaped inside a JSON string.
    * @param ch  UTF-16 code unit.
    * @return true for `"`, `\` and every character below U+0020.
    */
   static bool       NeedEscape(
      const ushort ch)
     {
      return (ch==34 || ch==92 || ch<32);
     }

   /**
    * @brief Converts JSON escape sequences back to the characters they stand for.
    *
    * Supported: \" \\ \/ \b \f \n \r \t and \uXXXX (four hex digits).
    * Lenient on malformed input (this is a utility, the parser validates strictly):
    * an unknown escape yields the escaped character itself, a malformed \u escape is
    * copied unchanged, and a trailing lone backslash is kept.
    *
    * @param text  Escaped text (without the surrounding quotes).
    * @return Unescaped text.
    */
   static string     Unescape(
      const string text)
     {
      string result="";
      int length=StringLen(text);

      for(int i=0;i<length;i++)
        {
         ushort ch=StringGetCharacter(text,i);

         if(ch!='\\')
           {
            result+=ShortToString(ch);
            continue;
           }

         // Backslash as the last character.
         if(i+1>=length)
           {
            result+="\\";
            break;
           }

         i++;

         ushort next=StringGetCharacter(text,i);

         switch(next)
           {
            case '"':
               result+="\"";
               break;
            case '\\':
               result+="\\";
               break;
            case '/':
               result+="/";
               break;
            case 'b':
               result+=ShortToString(8);
               break;
            case 'f':
               result+=ShortToString(12);
               break;
            case 'n':
               result+=ShortToString(10);
               break;
            case 'r':
               result+=ShortToString(13);
               break;
            case 't':
               result+=ShortToString(9);
               break;
            case 'u':
              {
               if(i+4<length && IsHex4(text,i+1))
                 {
                  ushort unicode=HexToUShort(StringSubstr(text,i+1,4));

                  // \u0000 cannot live in an MQL5 string.
                  if(unicode!=0)
                     result+=ShortToString(unicode);

                  i+=4;
                 }
               else
                  result+="\\u";

               break;
              }
            default:
               result+=ShortToString(next);
               break;
           }
        }

      return result;
     }

   /**
    * @brief Converts hexadecimal text to a ushort.
    *
    * Characters that are not hex digits are ignored (they add 0). At most the low
    * 16 bits of the result are kept.
    *
    * @param hex  Hex digits, normally four (upper or lower case).
    * @return The value.
    */
   static ushort     HexToUShort(
      const string hex)
     {
      ushort value=0;
      int length=StringLen(hex);

      for(int i=0;i<length;i++)
        {
         ushort ch=StringGetCharacter(hex,i);

         value*=16;

         if(ch>='0' && ch<='9')
            value+=(ushort)(ch-'0');
         else
            if(ch>='A' && ch<='F')
               value+=(ushort)(ch-'A'+10);
            else
               if(ch>='a' && ch<='f')
                  value+=(ushort)(ch-'a'+10);
        }

      return value;
     }

   /**
    * @brief Formats a character as a JSON unicode escape.
    * @param ch  UTF-16 code unit.
    * @return "\\uXXXX" with four upper-case hex digits.
    */
   static string     UnicodeEscape(
      const ushort ch)
     {
      return "\\u"+UShortToHex(ch);
     }

   /**
    * @brief Formats a ushort as four upper-case hexadecimal digits.
    * @param value  The value.
    * @return Text such as "00E9".
    */
   static string     UShortToHex(
      const ushort value)
     {
      string chars="0123456789ABCDEF";
      string result="";
      ushort temp=value;

      for(int i=0;i<4;i++)
        {
         int digit=temp & 15;

         result=StringSubstr(chars,digit,1)+result;

         temp=temp >> 4;
        }

      return result;
     }

   /**
    * @brief Like Escape(), but also writes every non-ASCII character as \uXXXX.
    *
    * The result is pure ASCII and therefore independent of the file encoding.
    *
    * @param text  Raw text.
    * @return Escaped, ASCII-only text.
    */
   static string     EscapeUnicode(
      const string text)
     {
      string result="";
      int length=StringLen(text);

      for(int i=0;i<length;i++)
        {
         ushort ch=StringGetCharacter(text,i);

         if(ch>=128)
           {
            result+=UnicodeEscape(ch);
            continue;
           }

         if(NeedEscape(ch))
            result+=Escape(ShortToString(ch));
         else
            result+=ShortToString(ch);
        }

      return result;
     }

private:

   /**
    * @brief Checks that four hex digits start at @p start.
    * @param text   Text to inspect.
    * @param start  Index of the first of the four characters.
    * @return true when the four characters exist and are all hex digits.
    */
   static bool       IsHex4(
      const string text,
      const int start)
     {
      if(start+4>StringLen(text))
         return false;

      for(int i=start;i<start+4;i++)
        {
         ushort ch=StringGetCharacter(text,i);

         bool hex=((ch>='0' && ch<='9') ||
                   (ch>='a' && ch<='f') ||
                   (ch>='A' && ch<='F'));

         if(!hex)
            return false;
        }

      return true;
     }
  };

#endif // __ABS_JSON_ESCAPE_MQH__
//+------------------------------------------------------------------+
