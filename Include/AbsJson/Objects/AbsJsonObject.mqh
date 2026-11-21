//+------------------------------------------------------------------+
//|                                              AbsJsonObject.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_OBJECT_MQH__
#define __ABS_JSON_OBJECT_MQH__

#property strict

#include "../Core/AbsJsonNode.mqh"
#include "../Internal/AbsJsonClone.mqh"

/**
 * @file AbsJsonObject.mqh
 * @brief JSON object: an ordered set of uniquely named properties.
 */

/// Number of properties from which a CAbsJsonObject uses its hash index.
#define ABS_JSON_HASH_THRESHOLD 16

/**
 * @class CAbsJsonObject
 * @brief A JSON object. Keeps its properties in insertion order.
 *
 * **Duplicate names:** a name can appear only once. AddProperty() refuses a
 * duplicate, Set...() overwrites the existing property, and the parser reports
 * ABS_JSON_ERROR_DUPLICATE_PROPERTY. (RFC 8259 only says that names SHOULD be unique;
 * this library chooses to reject duplicates instead of silently keeping one of them.)
 *
 * **Lookup cost:** objects with fewer than 16 properties are searched linearly. From 16
 * properties on, the object maintains a hash index (open addressing, FNV-1a) so that
 * IndexOf(), FindProperty(), Contains() and the typed getters take O(1) on average.
 * Appending is O(1) on average; removing a property is O(n) (the following properties shift
 * and the index is rebuilt). Renaming a stored property through CAbsJsonProperty::SetName()
 * keeps the index correct and is refused when the new name already exists.
 *
 * **Typed getters** (GetString(name) ...) return a default (""/0/0.0/false)
 * when the property is missing or has another type. Use HasProperty() / FindProperty()
 * to tell these cases apart.
 *
 * **Ownership:** the object owns its properties and everything below them.
 * Pointers returned by FindProperty() / GetProperty() stay owned by the object and
 * become invalid when the property is removed or the object is cleared or destroyed.
 */
class CAbsJsonObject : public CAbsJsonNode
  {
private:

   /// Hash table slots: 0 = empty, otherwise (property index + 1). Size is a power of two, or 0 when unused.
   int               m_table[];

   /// Current number of slots of m_table (0 = no index, linear search).
   int               m_tableSize;

   /**
    * @brief FNV-1a hash of a name.
    * @param text  Property name.
    * @return 32-bit hash.
    */
   static uint       Hash(
      const string text)
     {
      uint hash=2166136261;
      int length=StringLen(text);

      for(int i=0;i<length;i++)
        {
         hash^=(uint)StringGetCharacter(text,i);
         hash*=16777619;
        }

      return hash;
     }

   /**
    * @brief Puts one property index into the hash table (the table must have a free slot).
    * @param name   Property name.
    * @param index  Index of the property in the property list.
    */
   void              TableInsert(
      const string name,
      const int index)
     {
      int mask=m_tableSize-1;
      int slot=(int)(Hash(name) & (uint)mask);

      while(m_table[slot]!=0)
         slot=(slot+1) & mask;

      m_table[slot]=index+1;
     }

   /** @brief Drops the hash index (back to linear search). */
   void              ResetTable()
     {
      ArrayFree(m_table);

      m_tableSize=0;
     }

   /**
    * @brief Rebuilds the hash index from the property list.
    *
    * The index is dropped when the object is small; otherwise the table is sized to at most
    * half full.
    */
   void              RebuildTable()
     {
      int total=m_properties.Total();

      if(total<ABS_JSON_HASH_THRESHOLD)
        {
         ResetTable();
         return;
        }

      int size=64;

      while(size<total*4)
         size*=2;

      ArrayResize(m_table,size);
      ArrayInitialize(m_table,0);

      m_tableSize=size;

      for(int i=0;i<total;i++)
        {
         CAbsJsonProperty *property=(CAbsJsonProperty*)m_properties.At(i);

         if(property!=NULL)
            TableInsert(property.Name(),i);
        }
     }

   /** @brief Registers the property that was just appended (the last one) in the index. */
   void              TableAddLast()
     {
      int total=m_properties.Total();

      if(total<ABS_JSON_HASH_THRESHOLD)
         return;

      // Build (or grow) the table when it does not exist yet or would become more than half full.
      if(m_tableSize==0 || total*2>m_tableSize)
        {
         RebuildTable();
         return;
        }

      CAbsJsonProperty *property=(CAbsJsonProperty*)m_properties.At(total-1);

      if(property!=NULL)
         TableInsert(property.Name(),total-1);
     }

   /**
    * @brief Returns the property with @p name, creating an empty (null) one when missing.
    * @param name  Property name.
    * @return The property (owned by the object) or NULL on allocation failure.
    */
   CAbsJsonProperty  *Acquire(
      const string name)
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property!=NULL)
         return property;

      property=new CAbsJsonProperty(name);

      if(property==NULL)
         return NULL;

      if(!AddProperty(property))
        {
         delete property;
         return NULL;
        }

      return property;
     }

public:

   /** @brief Creates an empty object. */
                     CAbsJsonObject()
     {
      m_tableSize=0;
     }

   /** @brief Deletes all properties, drops the hash index and resets the status. */
   virtual void      Clear()
     {
      CAbsJsonNode::Clear();

      ResetTable();
     }

   /** @brief Destructor. Deletes all properties. */
   virtual          ~CAbsJsonObject()
     {
      Clear();
     }

   /** @return ABS_JSON_OBJECT. */
   virtual ENUM_ABS_JSON_TYPE NodeType() const
     {
      return ABS_JSON_OBJECT;
     }

   /** @return Always true. */
   virtual bool      IsObject() const
     {
      return true;
     }

   /** @return Number of properties. */
   virtual int       Count() const
     {
      return m_properties.Total();
     }

   /**
    * @brief Finds a property by name.
    * @param name  Property name (case-sensitive).
    * @return The property (owned by the object) or NULL when it does not exist.
    */
   CAbsJsonProperty  *FindProperty(
      const string name) const
     {
      int index=IndexOf(name);

      if(index<0)
         return NULL;

      return (CAbsJsonProperty*)m_properties.At(index);
     }

   /**
    * @brief Tests whether a property exists.
    * @param name  Property name.
    * @return true when the property exists.
    */
   bool              Contains(
      const string name) const
     {
      return (IndexOf(name)>=0);
     }

   /**
    * @brief Position of a property.
    * @param name  Property name.
    * @return Zero-based index in insertion order, or -1 when not found.
    */
   int               IndexOf(
      const string name) const
     {
      if(m_tableSize>0)
        {
         int mask=m_tableSize-1;
         int slot=(int)(Hash(name) & (uint)mask);

         while(true)
           {
            int entry=m_table[slot];

            if(entry==0)
               return -1;

            CAbsJsonProperty *candidate=(CAbsJsonProperty*)m_properties.At(entry-1);

            if(candidate!=NULL && candidate.IsName(name))
               return entry-1;

            slot=(slot+1) & mask;
           }
        }

      int total=m_properties.Total();

      for(int i=0;i<total;i++)
        {
         CAbsJsonProperty *property=(CAbsJsonProperty*)m_properties.At(i);

         if(property==NULL)
            continue;

         if(property.IsName(name))
            return i;
        }

      return -1;
     }

   /**
    * @brief Removes the property with the given name.
    * @param name  Property name.
    * @return true when removed, false when it does not exist.
    */
   bool              Remove(
      const string name)
     {
      int index=IndexOf(name);

      if(index<0)
         return false;

      return RemoveProperty(index);
     }

   /**
    * @brief Removes the property at @p index.
    * @param index  Zero-based index.
    * @return true when removed, false when @p index is out of range.
    */
   virtual bool      Remove(
      const int index)
     {
      return RemoveProperty(index);
     }

   /**
    * @brief Inserts a property or replaces the content of the property with the same name.
    *
    * - Name not present: @p property is added to the object (the object takes ownership).
    * - Name present: its value is replaced by a deep copy of the value of @p property, and
    *   @p property itself is deleted.
    *
    * @param property  Heap-allocated property. Ownership is always taken (on failure it is deleted).
    *                  Passing a property that is already stored in this object is a no-op.
    * @return true on success; false when @p property is NULL or could not be stored.
    */
   bool              SetProperty(
      CAbsJsonProperty *property)
     {
      if(property==NULL)
         return false;

      int index=IndexOf(property.Name());

      if(index>=0)
        {
         CAbsJsonProperty *oldProperty=GetProperty(index);

         if(oldProperty==property)
            return true;

         bool copied=true;

         if(oldProperty!=NULL)
            copied=oldProperty.CopyFrom(property);

         delete property;

         return copied;
        }

      if(!AddProperty(property))
        {
         delete property;
         return false;
        }

      return true;
     }

   /**
    * @brief Sets (creates or overwrites) a property to a string.
    * @param name   Property name.
    * @param value  New value. An existing property of any type is overwritten.
    * @return true on success; false when the property could not be created.
    */
   bool              Set(
      const string name,
      const string value)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
         return false;

      property.SetString(value);

      return true;
     }

   /**
    * @brief Sets (creates or overwrites) a property to a 32-bit integer.
    * @param name   Property name.
    * @param value  New value. An existing property of any type is overwritten.
    * @return true on success; false when the property could not be created.
    */
   bool              Set(
      const string name,
      const int value)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
         return false;

      property.SetInteger(value);

      return true;
     }

   /**
    * @brief Sets (creates or overwrites) a property to a 64-bit integer.
    * @param name   Property name.
    * @param value  New value. An existing property of any type is overwritten.
    * @return true on success; false when the property could not be created.
    */
   bool              Set(
      const string name,
      const long value)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
         return false;

      property.SetLong(value);

      return true;
     }

   /**
    * @brief Sets (creates or overwrites) a property to a double.
    * @param name   Property name.
    * @param value  New value. An existing property of any type is overwritten.
    * @return true on success; false when the property could not be created.
    */
   bool              Set(
      const string name,
      const double value)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
         return false;

      property.SetDouble(value);

      return true;
     }

   /**
    * @brief Sets (creates or overwrites) a property to a boolean.
    * @param name   Property name.
    * @param value  New value. An existing property of any type is overwritten.
    * @return true on success; false when the property could not be created.
    */
   bool              Set(
      const string name,
      const bool value)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
         return false;

      property.SetBoolean(value);

      return true;
     }

   /**
    * @brief Sets a property to an object; ownership of @p object is transferred.
    * @param name    Property name.
    * @param object  Heap-allocated object (NULL stores null). An existing property is overwritten.
    * @return true on success; false when the property could not be created
    *         (@p object is then deleted).
    */
   bool              SetObject(
      const string name,
      CAbsJsonObject *object)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
        {
         if(object!=NULL)
            delete object;

         return false;
        }

      property.SetObject(object);

      return true;
     }

   /**
    * @brief Sets a property to an array; ownership of @p array is transferred.
    * @param name   Property name.
    * @param array  Heap-allocated array (NULL stores null). An existing property is overwritten.
    * @return true on success; false when the property could not be created
    *         (@p array is then deleted).
    */
   bool              SetArray(
      const string name,
      CAbsJsonArray *array)
     {
      CAbsJsonProperty *property=Acquire(name);

      if(property==NULL)
        {
         if(array!=NULL)
            delete array;

         return false;
        }

      property.SetArray(array);

      return true;
     }

   /**
    * @brief String value of a property.
    * @param name  Property name.
    * @return The string, or "" when missing or not a string.
    */
   string            GetString(
      const string name) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return "";

      return property.GetString();
     }

   /**
    * @brief 32-bit integer value of a property.
    * @param name  Property name.
    * @return The integer, or 0 when missing or not an integer.
    */
   int               GetInteger(
      const string name) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return 0;

      return property.GetInteger();
     }

   /**
    * @brief 64-bit integer value of a property.
    * @param name  Property name.
    * @return The long, or 0 when missing or not a long.
    */
   long              GetLong(
      const string name) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return 0;

      return property.GetLong();
     }

   /**
    * @brief Double value of a property.
    * @param name  Property name.
    * @return The double, or 0.0 when missing or not a double.
    */
   double            GetDouble(
      const string name) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return 0.0;

      return property.GetDouble();
     }

   /**
    * @brief Boolean value of a property.
    * @param name  Property name.
    * @return The boolean, or false when missing or not a boolean.
    */
   bool              GetBoolean(
      const string name) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return false;

      return property.GetBoolean();
     }

   /**
    * @brief Tests whether a property exists (same as Contains()).
    * @param name  Property name.
    * @return true when the property exists.
    */
   bool              HasProperty(
      const string name) const
     {
      return Contains(name);
     }

   /**
    * @brief Copies a child object into @p object (deep copy).
    * @param name           Property name.
    * @param[out] object    Receives the copy.
    * @return true on success; false when the property is missing, is not an object,
    *         or the copy failed. @p object is not modified when the property is missing
    *         or has another type.
    */
   bool              GetObject(
      const string name,
      CAbsJsonObject &object) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return false;

      CAbsJsonValue *value=property.Value();

      if(value==NULL || value.JsonType()!=ABS_JSON_OBJECT)
         return false;

      CAbsJsonObject *source=value.GetObject();

      if(source==NULL)
         return false;

      return object.CopyFrom(*source);
     }

   /**
    * @brief Copies a child array into @p array (deep copy).
    * @param name          Property name.
    * @param[out] array    Receives the copy.
    * @return true on success; false when the property is missing, is not an array,
    *         or the copy failed. @p array is not modified when the property is missing
    *         or has another type.
    */
   bool              GetArray(
      const string name,
      CAbsJsonArray &array) const
     {
      CAbsJsonProperty *property=FindProperty(name);

      if(property==NULL)
         return false;

      CAbsJsonValue *value=property.Value();

      if(value==NULL || value.JsonType()!=ABS_JSON_ARRAY)
         return false;

      CAbsJsonArray *source=value.GetArray();

      if(source==NULL)
         return false;

      return CAbsJsonClone::Array(*source,array);
     }

   /**
    * @brief Appends a property; duplicate names are rejected.
    * @param property  Heap-allocated property.
    * @return true on success (the object takes ownership); false when @p property is NULL,
    *         its name already exists, or storing failed (the caller keeps ownership).
    */
   virtual bool      AddProperty(
      CAbsJsonProperty *property)
     {
      if(property==NULL)
         return false;

      if(Contains(property.Name()))
         return false;

      if(!CAbsJsonNode::AddProperty(property))
         return false;

      TableAddLast();

      return true;
     }

   /**
    * @brief Deletes the property at @p index and keeps the hash index consistent.
    * @param index  Zero-based index.
    * @return true when removed, false when @p index is out of range.
    */
   virtual bool      RemoveProperty(
      const int index)
     {
      if(!CAbsJsonNode::RemoveProperty(index))
         return false;

      if(m_tableSize>0)
         RebuildTable();

      return true;
     }

   /**
    * @brief Allows a rename only when no other property already uses the new name.
    * @param property  The property to rename.
    * @param name      The new name.
    * @return true when the name is free (or already belongs to @p property).
    */
   virtual bool      CanRename(
      const CAbsJsonProperty *property,
      const string name)
     {
      int index=IndexOf(name);

      if(index<0)
         return true;

      CAbsJsonProperty *existing=GetProperty(index);

      return (existing==property);
     }

   /** @brief Refreshes the hash index after a property was renamed. */
   virtual void      Renamed()
     {
      if(m_tableSize>0)
         RebuildTable();
     }

   /**
    * @brief Replaces the content with a deep copy of another object.
    * @param source  Must be a CAbsJsonObject.
    * @return true on success; false when @p source is not an object or the copy failed.
    */
   virtual bool      CopyFrom(
      const CAbsJsonNode &source)
     {
      const CAbsJsonObject *object=dynamic_cast<const CAbsJsonObject*>(&source);

      if(object==NULL)
         return false;

      return CAbsJsonClone::Object(*object,*this);
     }

   /**
    * @brief Stores a deep copy of this object into @p target.
    * @param[out] target  Must be a CAbsJsonObject.
    * @return true on success; false when @p target is not an object or the copy failed.
    */
   virtual bool      Clone(
      CAbsJsonNode &target) const
     {
      CAbsJsonObject *object=dynamic_cast<CAbsJsonObject*>(&target);

      if(object==NULL)
         return false;

      return CAbsJsonClone::Object(*this,*object);
     }

   /**
    * @brief Serializes the object to JSON text. Implemented in AbsJsonWriter.mqh.
    * @param pretty  true for indented output (4 spaces), false for compact output.
    * @return JSON text.
    */
   virtual string    ToString(
      const bool pretty=false) const;
  };

#endif // __ABS_JSON_OBJECT_MQH__
//+------------------------------------------------------------------+
