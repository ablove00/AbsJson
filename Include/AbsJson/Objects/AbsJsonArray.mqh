//+------------------------------------------------------------------+
//|                                               AbsJsonArray.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_ARRAY_MQH__
#define __ABS_JSON_ARRAY_MQH__

#property strict

#include "../Core/AbsJsonNode.mqh"
#include "AbsJsonObject.mqh"
#include "../Internal/AbsJsonClone.mqh"

/**
 * @file AbsJsonArray.mqh
 * @brief JSON array: an ordered list of values.
 */

/**
 * @class CAbsJsonArray
 * @brief A JSON array. Elements are CAbsJsonValue objects owned by the array.
 *
 * Typed getters (GetString(index) ...) return a default (""/0/0.0/false) when the index is
 * out of range or the element has another type. Use Item(index) and JsonType() to tell these
 * cases apart. Pointers returned by Item() stay owned by the array and become invalid when
 * the element is removed or the array is cleared or destroyed.
 */
class CAbsJsonArray : public CAbsJsonNode
  {
private:

   /**
    * @brief Appends an already allocated element; frees it when it cannot be stored.
    * @param item  Heap-allocated value (ownership is always taken).
    * @return true when appended.
    */
   bool              Append(
      CAbsJsonValue *item)
     {
      if(item==NULL)
         return false;

      if(!AddItem(item))
        {
         delete item;
         return false;
        }

      return true;
     }

public:

   /** @brief Creates an empty array. */
                     CAbsJsonArray()
     {
     }

   /** @brief Destructor. Deletes all elements. */
   virtual          ~CAbsJsonArray()
     {
      Clear();
     }

   /** @return ABS_JSON_ARRAY. */
   virtual ENUM_ABS_JSON_TYPE NodeType() const
     {
      return ABS_JSON_ARRAY;
     }

   /** @return Always true. */
   virtual bool      IsArray() const
     {
      return true;
     }

   /** @return Number of elements. */
   virtual int       Count() const
     {
      return m_items.Total();
     }

   /**
    * @brief Removes the element at @p index.
    * @param index  Zero-based index.
    * @return true when removed, false when @p index is out of range.
    */
   virtual bool      Remove(
      const int index)
     {
      return RemoveItem(index);
     }

   /**
    * @brief Appends a string.
    * @param value  The value to append.
    * @return true on success.
    */
   bool              Add(
      const string value)
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      item.SetString(value);

      return Append(item);
     }

   /**
    * @brief Appends a 32-bit integer.
    * @param value  The value to append.
    * @return true on success.
    */
   bool              Add(
      const int value)
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      item.SetInteger(value);

      return Append(item);
     }

   /**
    * @brief Appends a 64-bit integer.
    * @param value  The value to append.
    * @return true on success.
    */
   bool              Add(
      const long value)
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      item.SetLong(value);

      return Append(item);
     }

   /**
    * @brief Appends a double.
    * @param value  The value to append.
    * @return true on success.
    */
   bool              Add(
      const double value)
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      item.SetDouble(value);

      return Append(item);
     }

   /**
    * @brief Appends a boolean.
    * @param value  The value to append.
    * @return true on success.
    */
   bool              Add(
      const bool value)
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      item.SetBoolean(value);

      return Append(item);
     }

   /**
    * @brief Appends a null element.
    * @return true on success.
    */
   bool              AddNull()
     {
      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
         return false;

      return Append(item);
     }

   /**
    * @brief Appends an object; ownership of @p object is transferred.
    * @param object  Heap-allocated object. NULL is rejected.
    * @return true on success; false when @p object is NULL or the element could not be stored
    *         (@p object is then deleted).
    */
   bool              AddObject(
      CAbsJsonObject *object)
     {
      if(object==NULL)
         return false;

      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
        {
         delete object;
         return false;
        }

      item.SetObject(object);

      return Append(item);
     }

   /**
    * @brief Appends an array; ownership of @p array is transferred.
    * @param array  Heap-allocated array. NULL is rejected.
    * @return true on success; false when @p array is NULL or the element could not be stored
    *         (@p array is then deleted).
    */
   bool              AddArray(
      CAbsJsonArray *array)
     {
      if(array==NULL)
         return false;

      CAbsJsonValue *item=new CAbsJsonValue();

      if(item==NULL)
        {
         delete array;
         return false;
        }

      item.SetArray(array);

      return Append(item);
     }

   /**
    * @brief Inserts an element at a position; later elements move up by one.
    * @param index  Insert position, 0..Count() (Count() appends).
    * @param value  Heap-allocated value. Must not be NULL.
    * @return true on success (the array takes ownership); false when @p value is NULL,
    *         @p index is out of range, or inserting failed (the caller keeps ownership).
    */
   bool              Insert(
      const int index,
      CAbsJsonValue *value)
     {
      if(value==NULL)
         return false;

      if(index<0 || index>m_items.Total())
         return false;

      return m_items.Insert(value,index);
     }

   /**
    * @brief Element at @p index.
    * @param index  Zero-based index.
    * @return The element (owned by the array) or NULL when @p index is out of range.
    */
   CAbsJsonValue     *Item(
      const int index)
     {
      if(index<0 || index>=m_items.Total())
         return NULL;

      return (CAbsJsonValue*)m_items.At(index);
     }

   /**
    * @brief Element at @p index (usable on a const array).
    * @param index  Zero-based index.
    * @return The element (owned by the array) or NULL when @p index is out of range.
    * @note The returned pointer is not const-qualified; do not modify the element through
    *       a const array.
    */
   CAbsJsonValue     *Item(
      const int index) const
     {
      if(index<0 || index>=m_items.Total())
         return NULL;

      return (CAbsJsonValue*)m_items.At(index);
     }

   /**
    * @brief String value of an element.
    * @param index  Zero-based index.
    * @return The value, or "" when @p index is out of range or the element has another type.
    */
   string            GetString(
      const int index) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL)
         return "";

      return value.GetString();
     }

   /**
    * @brief 32-bit integer value of an element.
    * @param index  Zero-based index.
    * @return The value, or 0 when @p index is out of range or the element has another type.
    */
   int               GetInteger(
      const int index) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL)
         return 0;

      return value.GetInteger();
     }

   /**
    * @brief 64-bit integer value of an element.
    * @param index  Zero-based index.
    * @return The value, or 0 when @p index is out of range or the element has another type.
    */
   long              GetLong(
      const int index) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL)
         return 0;

      return value.GetLong();
     }

   /**
    * @brief Double value of an element.
    * @param index  Zero-based index.
    * @return The value, or 0.0 when @p index is out of range or the element has another type.
    */
   double            GetDouble(
      const int index) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL)
         return 0.0;

      return value.GetDouble();
     }

   /**
    * @brief Boolean value of an element.
    * @param index  Zero-based index.
    * @return The value, or false when @p index is out of range or the element has another type.
    */
   bool              GetBoolean(
      const int index) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL)
         return false;

      return value.GetBoolean();
     }

   /**
    * @brief Copies an element that is an object into @p object (deep copy).
    * @param index          Zero-based index.
    * @param[out] object    Receives the copy.
    * @return true on success; false when @p index is out of range, the element is not an
    *         object, or the copy failed.
    */
   bool              GetObject(
      const int index,
      CAbsJsonObject &object) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL || value.JsonType()!=ABS_JSON_OBJECT)
         return false;

      CAbsJsonObject *source=value.GetObject();

      if(source==NULL)
         return false;

      return object.CopyFrom(*source);
     }

   /**
    * @brief Copies an element that is an array into @p array (deep copy).
    * @param index         Zero-based index.
    * @param[out] array    Receives the copy.
    * @return true on success; false when @p index is out of range, the element is not an
    *         array, or the copy failed.
    */
   bool              GetArray(
      const int index,
      CAbsJsonArray &array) const
     {
      CAbsJsonValue *value=Item(index);

      if(value==NULL || !value.IsArray())
         return false;

      CAbsJsonArray *source=value.GetArray();

      if(source==NULL)
         return false;

      return source.Clone(array);
     }

   /**
    * @brief Replaces the content with a deep copy of another array.
    * @param source  Array to copy (not modified).
    * @return true on success.
    */
   bool              CopyFrom(
      const CAbsJsonArray &source)
     {
      return CAbsJsonClone::Array(source,*this);
     }

   /**
    * @brief Stores a deep copy of this array into @p target.
    * @param[out] target  Receives the copy.
    * @return true on success.
    */
   bool              Clone(
      CAbsJsonArray &target) const
     {
      return CAbsJsonClone::Array(*this,target);
     }

   /**
    * @brief Serializes the array to JSON text. Implemented in AbsJsonWriter.mqh.
    * @param pretty  true for indented output (4 spaces), false for compact output.
    * @return JSON text.
    */
   string            ToString(
      const bool pretty=false) const;
  };

#endif // __ABS_JSON_ARRAY_MQH__
//+------------------------------------------------------------------+
