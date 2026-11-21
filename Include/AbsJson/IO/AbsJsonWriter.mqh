//+------------------------------------------------------------------+
//|                                              AbsJsonWriter.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_WRITER_MQH__
#define __ABS_JSON_WRITER_MQH__

#property strict

#include "../Objects/AbsJsonObject.mqh"
#include "../Objects/AbsJsonArray.mqh"
#include "../Utils/AbsJsonEscape.mqh"
#include "../Utils/AbsJsonNumber.mqh"

/**
 * @file AbsJsonWriter.mqh
 * @brief Serializes JSON values to text (RFC 8259).
 *
 * This is the only serializer of the library. The ToString() methods of
 * CAbsJsonValue, CAbsJsonObject and CAbsJsonArray are implemented at the end of this
 * file on top of CAbsJsonWriter, so every path produces identical output.
 */

/**
 * @class CAbsJsonWriter
 * @brief Converts a CAbsJsonValue, CAbsJsonObject or CAbsJsonArray to JSON text.
 *
 * Output rules:
 *  - Property order is the insertion order.
 *  - Strings and property names are escaped with CAbsJsonEscape::Escape()
 *    (including all control characters). Non-ASCII characters are written as they are.
 *  - Doubles are written with CAbsJsonNumber::DoubleToJson() (round-trip exact;
 *    NaN / infinity become null).
 *  - Empty objects and arrays are written as `{}` and `[]`.
 *  - Compact mode has no whitespace. Pretty mode uses "\r\n" line breaks, the configured
 *    number of spaces per level, and `": "` after property names.
 *
 * The writer keeps only its two settings, so one instance can be reused.
 */
class CAbsJsonWriter
  {
private:

   /// true for indented output.
   bool              m_pretty;

   /// Spaces per indentation level (always > 0).
   int               m_indentSize;

public:

   /** @brief Creates a compact writer with a 4-space indent size. */
                     CAbsJsonWriter()
     {
      m_pretty=false;
      m_indentSize=AbsJsonConst::DEFAULT_INDENT;
     }

   /** @brief Destructor. */
                    ~CAbsJsonWriter()
     {
     }

   /**
    * @brief Enables or disables pretty printing.
    * @param value  true = indented output, false = compact output.
    */
   void              SetPretty(
      const bool value)
     {
      m_pretty=value;
     }

   /**
    * @brief Selects compact or pretty output with the format enumeration.
    * @param format  ABS_JSON_MINIFY or ABS_JSON_PRETTY.
    */
   void              SetFormat(
      const ENUM_ABS_JSON_FORMAT format)
     {
      m_pretty=(format==ABS_JSON_PRETTY);
     }

   /**
    * @brief Sets the number of spaces per indentation level.
    * @param value  Spaces per level. Values <= 0 are ignored.
    */
   void              SetIndentSize(
      const int value)
     {
      if(value>0)
         m_indentSize=value;
     }

   /**
    * @brief Serializes a value.
    * @param value  Value to write (not modified).
    * @return JSON text.
    */
   string            Write(
      const CAbsJsonValue &value)
     {
      return WriteValue(&value,0);
     }

   /**
    * @brief Serializes an object.
    * @param object  Object to write (not modified).
    * @return JSON text.
    */
   string            Write(
      const CAbsJsonObject &object)
     {
      return WriteObject(object,0);
     }

   /**
    * @brief Serializes an array.
    * @param array  Array to write (not modified).
    * @return JSON text.
    */
   string            Write(
      const CAbsJsonArray &array)
     {
      return WriteArray(array,0);
     }

private:

   /**
    * @brief Indentation text of a nesting level.
    * @param level  Nesting level (0 = top).
    * @return "" in compact mode, otherwise level*indentSize spaces.
    */
   string            Indent(
      const int level)
     {
      if(!m_pretty)
         return "";

      int count=level*m_indentSize;

      if(count<=0)
         return "";

      string result;

      StringInit(result,count,' ');

      return result;
     }

   /**
    * @brief Line break text.
    * @return "" in compact mode, otherwise "\r\n".
    */
   string            NewLine()
     {
      if(!m_pretty)
         return "";

      return "\r\n";
     }

   /**
    * @brief Serializes an object at a nesting level.
    * @param object  Object to write.
    * @param level   Nesting level, used for indentation.
    * @return JSON text.
    */
   string            WriteObject(
      const CAbsJsonObject &object,
      const int level)
     {
      string json="{";
      int total=object.Count();
      int written=0;

      for(int i=0;i<total;i++)
        {
         CAbsJsonProperty *property=object.GetProperty(i);

         if(property==NULL)
            continue;

         if(written>0)
            json+=",";

         json+=NewLine();
         json+=Indent(level+1);
         json+="\"";
         json+=CAbsJsonEscape::Escape(property.Name());
         json+="\":";

         if(m_pretty)
            json+=" ";

         json+=WriteValue(property.Value(),level+1);

         written++;
        }

      if(written>0)
        {
         json+=NewLine();
         json+=Indent(level);
        }

      json+="}";

      return json;
     }

   /**
    * @brief Serializes an array at a nesting level.
    * @param array  Array to write.
    * @param level  Nesting level, used for indentation.
    * @return JSON text.
    */
   string            WriteArray(
      const CAbsJsonArray &array,
      const int level)
     {
      string json="[";
      int total=array.Count();
      int written=0;

      for(int i=0;i<total;i++)
        {
         CAbsJsonValue *value=array.Item(i);

         if(value==NULL)
            continue;

         if(written>0)
            json+=",";

         json+=NewLine();
         json+=Indent(level+1);
         json+=WriteValue(value,level+1);

         written++;
        }

      if(written>0)
        {
         json+=NewLine();
         json+=Indent(level);
        }

      json+="]";

      return json;
     }

   /**
    * @brief Serializes any value at a nesting level.
    * @param value  Value to write; NULL is written as null.
    * @param level  Nesting level, used for indentation.
    * @return JSON text.
    */
   string            WriteValue(
      const CAbsJsonValue *value,
      const int level)
     {
      if(value==NULL)
         return "null";

      switch(value.JsonType())
        {
         case ABS_JSON_NULL:
            return "null";

         case ABS_JSON_STRING:
            return "\""+CAbsJsonEscape::Escape(value.GetString())+"\"";

         case ABS_JSON_INTEGER:
            return CAbsJsonNumber::IntegerToJson(value.GetInteger());

         case ABS_JSON_LONG:
            return CAbsJsonNumber::LongToJson(value.GetLong());

         case ABS_JSON_DOUBLE:
            return CAbsJsonNumber::DoubleToJson(value.GetDouble());

         case ABS_JSON_BOOLEAN:
            return value.GetBoolean() ? "true" : "false";

         case ABS_JSON_OBJECT:
           {
            const CAbsJsonObject *object=value.GetObject();

            if(object==NULL)
               return "null";

            return WriteObject(*object,level);
           }

         case ABS_JSON_ARRAY:
           {
            const CAbsJsonArray *array=value.GetArray();

            if(array==NULL)
               return "null";

            return WriteArray(*array,level);
           }
        }

      return "null";
     }
  };

//+------------------------------------------------------------------+
//| ToString() implementations (declared in the core classes)        |
//+------------------------------------------------------------------+

string CAbsJsonValue::ToString() const
  {
   CAbsJsonWriter writer;

   return writer.Write(*this);
  }

string CAbsJsonObject::ToString(
   const bool pretty) const
  {
   CAbsJsonWriter writer;

   writer.SetPretty(pretty);

   return writer.Write(*this);
  }

string CAbsJsonArray::ToString(
   const bool pretty) const
  {
   CAbsJsonWriter writer;

   writer.SetPretty(pretty);

   return writer.Write(*this);
  }

#endif // __ABS_JSON_WRITER_MQH__
//+------------------------------------------------------------------+
