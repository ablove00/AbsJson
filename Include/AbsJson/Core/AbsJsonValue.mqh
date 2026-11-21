//+------------------------------------------------------------------+
//|                                               AbsJsonValue.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_VALUE_MQH__
#define __ABS_JSON_VALUE_MQH__

#property strict

#include "AbsJsonBase.mqh"
#include "../Internal/AbsJsonClone.mqh"

class CAbsJsonObject;
class CAbsJsonArray;

/**
 * @file AbsJsonValue.mqh
 * @brief The variant type that holds any JSON value.
 */

/**
 * @class CAbsJsonValue
 * @brief Holds one JSON value: null, string, integer, long, double, boolean, object or array.
 *
 * Only the field that matches JsonType() is meaningful. The getters never fail:
 * asking for a different type than the stored one returns the default of that
 * field (0, 0.0, false or ""). Check JsonType() / IsXxx() first when the type is not known.
 *
 * **Ownership:** a value that holds an object or an array owns it and deletes it
 * in Clear() and in the destructor.
 *
 * **Copying:** the copy constructor and the assignment operator perform a deep copy
 * (same as CopyFrom()), so `CAbsJsonValue b=a;` and `b=a;` are safe: no pointer is shared.
 * Self-assignment is a no-op.
 *
 * @note Serialization (ToString()) is implemented in AbsJsonWriter.mqh, so include
 *       AbsJson.mqh (which includes everything in the right order).
 */
class CAbsJsonValue : public CAbsJsonBase
  {
private:

   /// Type of the stored value.
   ENUM_ABS_JSON_TYPE m_type;

   /// Payload when m_type is ABS_JSON_STRING.
   string            m_string;

   /// Payload when m_type is ABS_JSON_INTEGER.
   int               m_integer;

   /// Payload when m_type is ABS_JSON_LONG.
   long              m_long;

   /// Payload when m_type is ABS_JSON_DOUBLE.
   double            m_double;

   /// Payload when m_type is ABS_JSON_BOOLEAN.
   bool              m_boolean;

   /// Owned object when m_type is ABS_JSON_OBJECT, otherwise NULL.
   CAbsJsonObject    *m_object;

   /// Owned array when m_type is ABS_JSON_ARRAY, otherwise NULL.
   CAbsJsonArray     *m_array;

public:

   /** @brief Creates a null value. */
                     CAbsJsonValue()
     {
      m_object=NULL;
      m_array=NULL;

      Clear();
     }

   /**
    * @brief Copy constructor: creates a deep copy of @p source.
    * @param source  Value to copy.
    */
                     CAbsJsonValue(
      const CAbsJsonValue &source)
     {
      m_object=NULL;
      m_array=NULL;

      Clear();

      CopyFrom(source);
     }

   /**
    * @brief Assignment: replaces this value with a deep copy of @p source.
    * @param source  Value to copy. Assigning a value to itself does nothing.
    */
   void              operator=(
      const CAbsJsonValue &source)
     {
      if(GetPointer(source)==GetPointer(this))
         return;

      CopyFrom(source);
     }

   /** @brief Destructor. Deletes the owned object / array, if any. */
   virtual          ~CAbsJsonValue()
     {
      Clear();
     }

   /**
    * @brief Resets the value to null.
    *
    * Deletes the owned object / array and clears every payload field and the status.
    */
   void              Clear()
     {
      if(m_object!=NULL)
        {
         delete m_object;
         m_object=NULL;
        }

      if(m_array!=NULL)
        {
         delete m_array;
         m_array=NULL;
        }

      m_type=ABS_JSON_NULL;
      m_string="";
      m_integer=0;
      m_long=0;
      m_double=0.0;
      m_boolean=false;

      ClearStatus();
     }

   /** @return The type of the stored value. */
   ENUM_ABS_JSON_TYPE JsonType() const
     {
      return m_type;
     }

   /** @return true when the value is null. */
   bool              IsNull() const
     {
      return (m_type==ABS_JSON_NULL);
     }

   /** @return true when the value is a string. */
   bool              IsString() const
     {
      return (m_type==ABS_JSON_STRING);
     }

   /** @return true when the value is a 32-bit integer. */
   bool              IsInteger() const
     {
      return (m_type==ABS_JSON_INTEGER);
     }

   /** @return true when the value is a 64-bit integer. */
   bool              IsLong() const
     {
      return (m_type==ABS_JSON_LONG);
     }

   /** @return true when the value is a double. */
   bool              IsDouble() const
     {
      return (m_type==ABS_JSON_DOUBLE);
     }

   /** @return true when the value is a boolean. */
   bool              IsBoolean() const
     {
      return (m_type==ABS_JSON_BOOLEAN);
     }

   /** @return true when the value is an object. */
   bool              IsObject() const
     {
      return (m_type==ABS_JSON_OBJECT);
     }

   /** @return true when the value is an array. */
   bool              IsArray() const
     {
      return (m_type==ABS_JSON_ARRAY);
     }

   /** @brief Makes the value null (same as Clear()). */
   void              SetNull()
     {
      Clear();
     }

   /**
    * @brief Makes the value a string.
    * @param value  The string. Any previous content is released first.
    */
   void              SetString(const string value)
     {
      Clear();

      m_type=ABS_JSON_STRING;
      m_string=value;
     }

   /**
    * @brief Makes the value a 32-bit integer.
    * @param value  The integer.
    */
   void              SetInteger(const int value)
     {
      Clear();

      m_type=ABS_JSON_INTEGER;
      m_integer=value;
     }

   /**
    * @brief Makes the value a 64-bit integer.
    * @param value  The integer.
    */
   void              SetLong(const long value)
     {
      Clear();

      m_type=ABS_JSON_LONG;
      m_long=value;
     }

   /**
    * @brief Makes the value a double.
    * @param value  The number. NaN and +/-infinity are accepted here but are written as null
    *               by the writer because JSON cannot represent them.
    */
   void              SetDouble(const double value)
     {
      Clear();

      m_type=ABS_JSON_DOUBLE;
      m_double=value;
     }

   /**
    * @brief Makes the value a boolean.
    * @param value  true or false.
    */
   void              SetBoolean(const bool value)
     {
      Clear();

      m_type=ABS_JSON_BOOLEAN;
      m_boolean=value;
     }

   /**
    * @brief Makes the value an object and takes ownership of it.
    *
    * @param value  Heap-allocated object (created with `new`). The value deletes it later.
    *               NULL turns this value into null. Passing the object that is already
    *               held is a no-op.
    * @warning The pointer must not be owned by anybody else and must not be a stack object.
    */
   void              SetObject(
      CAbsJsonObject *value)
     {
      if(value!=NULL && value==m_object)
         return;

      Clear();

      if(value==NULL)
         return;

      m_type=ABS_JSON_OBJECT;
      m_object=value;
     }

   /**
    * @brief Makes the value an array and takes ownership of it.
    *
    * @param value  Heap-allocated array (created with `new`). The value deletes it later.
    *               NULL turns this value into null. Passing the array that is already
    *               held is a no-op.
    * @warning The pointer must not be owned by anybody else and must not be a stack object.
    */
   void              SetArray(
      CAbsJsonArray *value)
     {
      if(value!=NULL && value==m_array)
         return;

      Clear();

      if(value==NULL)
         return;

      m_type=ABS_JSON_ARRAY;
      m_array=value;
     }

   /** @return The string payload ("" when the value is not a string). */
   string            GetString() const
     {
      return m_string;
     }

   /** @return The 32-bit integer payload (0 when the value is not an integer). */
   int               GetInteger() const
     {
      return m_integer;
     }

   /** @return The 64-bit integer payload (0 when the value is not a long). */
   long              GetLong() const
     {
      return m_long;
     }

   /** @return The double payload (0.0 when the value is not a double). */
   double            GetDouble() const
     {
      return m_double;
     }

   /** @return The boolean payload (false when the value is not a boolean). */
   bool              GetBoolean() const
     {
      return m_boolean;
     }

   /** @return The owned object (do not delete) or NULL when the value is not an object. */
   CAbsJsonObject    *GetObject()
     {
      return m_object;
     }

   /** @return The owned object, read-only, or NULL when the value is not an object. */
   const CAbsJsonObject *GetObject() const
     {
      return m_object;
     }

   /** @return The owned array (do not delete) or NULL when the value is not an array. */
   CAbsJsonArray     *GetArray()
     {
      return m_array;
     }

   /** @return The owned array, read-only, or NULL when the value is not an array. */
   const CAbsJsonArray *GetArray() const
     {
      return m_array;
     }

   /**
    * @brief Replaces this value with a deep copy of @p source.
    * @param source  Value to copy (not modified). Copying a value onto itself is not supported.
    * @return true on success; false when the copy failed (this value is then left null).
    */
   bool              CopyFrom(
      const CAbsJsonValue &source)
     {
      return CAbsJsonClone::Value(source,*this);
     }

   /**
    * @brief Stores a deep copy of this value into @p target.
    * @param[out] target  Receives the copy.
    * @return true on success.
    */
   bool              Clone(
      CAbsJsonValue &target) const
     {
      return CAbsJsonClone::Value(*this,target);
     }

   /**
    * @brief Serializes the value to compact JSON text.
    *
    * Strings are escaped, doubles use the shortest round-trip format, and objects /
    * arrays are written recursively. Implemented in AbsJsonWriter.mqh.
    *
    * @return JSON text.
    */
   string            ToString() const;

   /**
    * @brief Sets the value from a type and a text representation.
    *
    * No syntax checking is done for numbers: text that is not numeric becomes 0.
    * For ABS_JSON_BOOLEAN only the exact text "true" gives true. Objects and arrays
    * cannot be created from text here.
    *
    * @param jsonType  Wanted type.
    * @param text      Text representation of the value.
    * @return true for null, string, integer, long, double and boolean; false for
    *         ABS_JSON_OBJECT / ABS_JSON_ARRAY (the value is then null).
    */
   bool              SetValue(
      ENUM_ABS_JSON_TYPE jsonType,
      const string text)
     {
      Clear();

      switch(jsonType)
        {
         case ABS_JSON_NULL:
            SetNull();
            return true;

         case ABS_JSON_STRING:
            SetString(text);
            return true;

         case ABS_JSON_INTEGER:
            SetInteger((int)StringToInteger(text));
            return true;

         case ABS_JSON_LONG:
            SetLong(StringToInteger(text));
            return true;

         case ABS_JSON_DOUBLE:
            SetDouble(StringToDouble(text));
            return true;

         case ABS_JSON_BOOLEAN:
            SetBoolean(text=="true");
            return true;
        }

      return false;
     }
  };

#endif // __ABS_JSON_VALUE_MQH__
//+------------------------------------------------------------------+
