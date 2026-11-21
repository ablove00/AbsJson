//+------------------------------------------------------------------+
//|                                                AbsJsonNode.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_NODE_MQH__
#define __ABS_JSON_NODE_MQH__

#property strict

#include <Arrays\ArrayObj.mqh>
#include "AbsJsonProperty.mqh"

/**
 * @file AbsJsonNode.mqh
 * @brief Common base of the two JSON containers: object and array.
 */

/**
 * @class CAbsJsonNode
 * @brief Base class that stores and owns the children of a JSON object or array.
 *
 * - A CAbsJsonObject uses the property list (m_properties).
 * - A CAbsJsonArray uses the item list (m_items).
 *
 * **Ownership:** the node owns every child it stores and deletes it in Clear(),
 * in the destructor and when a child is removed. The two CArrayObj lists are put
 * in "no free mode" so that the node itself is the only place that deletes a child
 * (each child is deleted exactly once, never by the list as well).
 * A successful AddProperty() / AddItem() transfers ownership of the pointer to the node.
 * When they return false the caller keeps ownership and must delete the pointer.
 */
class CAbsJsonNode : public CAbsJsonBase
  {
protected:

   /// Child properties. Only used by CAbsJsonObject.
   CArrayObj         m_properties;

   /// Child values. Only used by CAbsJsonArray.
   CArrayObj         m_items;

public:

   /** @brief Creates an empty node. The lists never delete elements themselves (see class notes). */
                     CAbsJsonNode()
     {
      m_properties.FreeMode(false);
      m_items.FreeMode(false);
     }

   /** @brief Destructor. Deletes every child. */
   virtual          ~CAbsJsonNode()
     {
      Clear();
     }

   /**
    * @brief Deletes all children and resets the status.
    *
    * Children are deleted in reverse order.
    */
   virtual void      Clear()
     {
      int count=m_properties.Total();

      for(int i=count-1;i>=0;i--)
        {
         CAbsJsonProperty *property=(CAbsJsonProperty*)m_properties.At(i);

         if(property!=NULL)
            delete property;
        }

      m_properties.Clear();

      count=m_items.Total();

      for(int i=count-1;i>=0;i--)
        {
         CObject *item=m_items.At(i);

         if(item!=NULL)
            delete item;
        }

      m_items.Clear();

      ClearStatus();
     }

   /**
    * @brief Number of children.
    * @return Always 0 in this base class; CAbsJsonObject / CAbsJsonArray override it.
    */
   virtual int       Count() const
     {
      return 0;
     }

   /** @return true when the node has no children. */
   bool              IsEmpty() const
     {
      return (Count()==0);
     }

   /**
    * @brief Removes the child at @p index.
    * @param index  Zero-based index.
    * @return false in the base class (overridden by the derived classes).
    */
   virtual bool      Remove(
      const int index)
     {
      return false;
     }

   /** @brief Deletes every child (same as Clear()). */
   void              RemoveAll()
     {
      Clear();
     }

   /**
    * @brief Appends a property (object use).
    *
    * @param property  Heap-allocated property. Must not be NULL.
    * @return true on success (the node now owns @p property);
    *         false when @p property is NULL or the list could not grow
    *         (the caller keeps ownership).
    */
   virtual bool      AddProperty(
      CAbsJsonProperty *property)
     {
      if(property==NULL)
         return false;

      if(!m_properties.Add(property))
         return false;

      property.SetOwner(GetPointer(this));

      return true;
     }

   /**
    * @brief Asks whether a stored property may be renamed (called by CAbsJsonProperty::SetName()).
    * @param property  The property that wants a new name.
    * @param name      The new name.
    * @return true when allowed. The base class allows everything; CAbsJsonObject refuses duplicates.
    */
   virtual bool      CanRename(
      const CAbsJsonProperty *property,
      const string name)
     {
      return true;
     }

   /** @brief Called after a stored property was renamed, so derived classes can refresh their lookup data. */
   virtual void      Renamed()
     {
     }

   /**
    * @brief Returns the property at @p index (object use).
    * @param index  Zero-based index.
    * @return The property (still owned by the node) or NULL when out of range.
    */
   CAbsJsonProperty  *GetProperty(
      const int index) const
     {
      if(index<0 || index>=m_properties.Total())
         return NULL;

      return (CAbsJsonProperty*)m_properties.At(index);
     }

   /**
    * @brief Appends an item (array use).
    *
    * @param item  Heap-allocated item (a CAbsJsonValue). Must not be NULL.
    * @return true on success (the node now owns @p item);
    *         false when @p item is NULL or the list could not grow
    *         (the caller keeps ownership).
    */
   virtual bool      AddItem(
      CObject *item)
     {
      if(item==NULL)
         return false;

      return m_items.Add(item);
     }

   /**
    * @brief Returns the item at @p index (array use).
    * @param index  Zero-based index.
    * @return The item (still owned by the node) or NULL when out of range.
    */
   CObject           *GetItem(
      const int index) const
     {
      if(index<0 || index>=m_items.Total())
         return NULL;

      return m_items.At(index);
     }

   /**
    * @brief Deletes the property at @p index (object use).
    * @param index  Zero-based index.
    * @return true when removed, false when @p index is out of range.
    */
   virtual bool      RemoveProperty(
      const int index)
     {
      if(index<0 || index>=m_properties.Total())
         return false;

      CAbsJsonProperty *property=(CAbsJsonProperty*)m_properties.At(index);

      if(property!=NULL)
         delete property;

      return m_properties.Delete(index);
     }

   /**
    * @brief Deletes the item at @p index (array use).
    * @param index  Zero-based index.
    * @return true when removed, false when @p index is out of range.
    */
   virtual bool      RemoveItem(
      const int index)
     {
      if(index<0 || index>=m_items.Total())
         return false;

      CObject *item=m_items.At(index);

      if(item!=NULL)
         delete item;

      return m_items.Delete(index);
     }

   /** @return Number of properties (object use). */
   int               PropertyCount() const
     {
      return m_properties.Total();
     }

   /** @return Number of items (array use). */
   int               ItemCount() const
     {
      return m_items.Total();
     }

   /** @brief Resets the status to success (same as ClearStatus()). */
   void              ResetError()
     {
      ClearStatus();
     }

   /**
    * @brief Copies the content of another node into this one.
    * @param source  Source node.
    * @return true. The base class only clears this node; derived classes override it
    *         and perform the real deep copy.
    */
   virtual bool      CopyFrom(
      const CAbsJsonNode &source)
     {
      Clear();

      return true;
     }

   /**
    * @brief Copies this node into @p target.
    * @param[out] target  Receives the copy.
    * @return true. The base class only clears @p target; derived classes override it.
    */
   virtual bool      Clone(
      CAbsJsonNode &target) const
     {
      target.Clear();

      return true;
     }

   /**
    * @brief JSON type of the node.
    * @return ABS_JSON_NULL in the base class; ABS_JSON_OBJECT / ABS_JSON_ARRAY in the derived classes.
    */
   virtual ENUM_ABS_JSON_TYPE NodeType() const
     {
      return ABS_JSON_NULL;
     }

   /**
    * @brief Serializes the node to JSON text.
    * @param pretty  true for indented output.
    * @return "" in the base class; CAbsJsonObject / CAbsJsonArray override it.
    */
   virtual string    ToString(
      const bool pretty=false) const
     {
      return "";
     }

   /** @return true when the node is a JSON object. */
   virtual bool      IsObject() const
     {
      return false;
     }

   /** @return true when the node is a JSON array. */
   virtual bool      IsArray() const
     {
      return false;
     }
  };

//+------------------------------------------------------------------+
//| CAbsJsonProperty::SetName() (declared in AbsJsonProperty.mqh)    |
//+------------------------------------------------------------------+
bool CAbsJsonProperty::SetName(
   const string name)
  {
   if(m_name==name)
      return true;

   if(m_owner!=NULL && !m_owner.CanRename(GetPointer(this),name))
      return false;

   m_name=name;

   if(m_owner!=NULL)
      m_owner.Renamed();

   return true;
  }

#endif // __ABS_JSON_NODE_MQH__
//+------------------------------------------------------------------+
