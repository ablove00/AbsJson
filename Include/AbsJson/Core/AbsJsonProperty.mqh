//+------------------------------------------------------------------+
//|                                            AbsJsonProperty.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_PROPERTY_MQH__
#define __ABS_JSON_PROPERTY_MQH__

#property strict

#include "AbsJsonValue.mqh"
#include "../Internal/AbsJsonClone.mqh"
#include "../Utils/AbsJsonEscape.mqh"

/**
 * @file AbsJsonProperty.mqh
 * @brief One name/value member of a JSON object.
 */

class CAbsJsonNode;

/**
 * @class CAbsJsonProperty
 * @brief A member of a JSON object: a name and a CAbsJsonValue.
 *
 * The property contains its value by composition (no separate allocation) and
 * therefore owns it, including any object / array the value owns.
 * Most getters / setters simply forward to the contained value.
 *
 * A property that is stored in an object knows its owner, so SetName() can refuse a name that
 * would duplicate another property and can keep the object's lookup index correct.
 * Copying a property with the assignment operator copies name and value (deep), never the owner.
 */
class CAbsJsonProperty : public CAbsJsonBase
  {
private:

   /// Property name (the JSON key).
   string            m_name;

   /// Property value (owned).
   CAbsJsonValue     m_value;

   /// Node that stores this property, or NULL for a free-standing property (not owned by this class).
   CAbsJsonNode      *m_owner;

public:

   /** @brief Creates an unnamed property whose value is null. */
                     CAbsJsonProperty()
     {
      m_name="";
      m_owner=NULL;
     }

   /**
    * @brief Creates a property with a name and a null value.
    * @param name  Property name.
    */
                     CAbsJsonProperty(
      const string name)
     {
      m_name=name;
      m_owner=NULL;
     }

   /**
    * @brief Copies name and value (deep copy) from another property; the owner is not copied.
    * @param source  Property to copy.
    */
   void              operator=(
      const CAbsJsonProperty &source)
     {
      if(GetPointer(source)==GetPointer(this))
         return;

      CopyFrom(source);
     }

   /** @brief Destructor. The contained value releases its content. */
   virtual          ~CAbsJsonProperty()
     {
     }

   /**
    * @brief Clears the name, resets the value to null and clears the status.
    * @warning Do not call this on a property that is stored in an object; remove it from the object instead.
    */
   void              Clear()
     {
      m_name="";
      m_value.Clear();
      ClearStatus();
     }

   /**
    * @brief Sets the name.
    *
    * When the property is stored in an object, the rename is refused if another property of that
    * object already has the new name (an object never contains duplicate names).
    * Implemented in AbsJsonNode.mqh.
    *
    * @param name  New name.
    * @return true when the name was changed (or already equal); false when the rename was refused.
    */
   bool              SetName(
      const string name);

   /**
    * @brief Internal: sets the node that stores this property. Called by CAbsJsonNode only.
    * @param owner  Owning node, or NULL.
    */
   void              SetOwner(
      CAbsJsonNode *owner)
     {
      m_owner=owner;
     }

   /** @return The node that stores this property, or NULL. */
   CAbsJsonNode      *Owner() const
     {
      return m_owner;
     }

   /** @return The property name. */
   string            Name() const
     {
      return m_name;
     }

   /**
    * @brief Case-sensitive name comparison.
    * @param name  Name to compare with.
    * @return true when the names are identical.
    */
   bool              IsName(
      const string name) const
     {
      return (m_name==name);
     }

   /** @return Pointer to the contained value (owned by the property, never NULL). */
   CAbsJsonValue     *Value()
     {
      return &m_value;
     }

   /** @return Read-only pointer to the contained value (never NULL). */
   const CAbsJsonValue *Value() const
     {
      return &m_value;
     }

   /**
    * @brief Replaces the value with a deep copy of @p value.
    * @param value  Value to copy.
    */
   void              SetValue(
      const CAbsJsonValue &value)
     {
      m_value.CopyFrom(value);
     }

   /** @brief Sets the value to null. */
   void              SetNull()
     {
      m_value.SetNull();
     }

   /** @brief Sets the value to a string. @param value The string. */
   void              SetString(
      const string value)
     {
      m_value.SetString(value);
     }

   /** @brief Sets the value to a 32-bit integer. @param value The integer. */
   void              SetInteger(
      const int value)
     {
      m_value.SetInteger(value);
     }

   /** @brief Sets the value to a 64-bit integer. @param value The integer. */
   void              SetLong(
      const long value)
     {
      m_value.SetLong(value);
     }

   /** @brief Sets the value to a double. @param value The number. */
   void              SetDouble(
      const double value)
     {
      m_value.SetDouble(value);
     }

   /** @brief Sets the value to a boolean. @param value true or false. */
   void              SetBoolean(
      const bool value)
     {
      m_value.SetBoolean(value);
     }

   /**
    * @brief Sets the value to an object; ownership of the pointer is transferred.
    * @param value  Heap-allocated object (NULL = null value).
    */
   void              SetObject(
      CAbsJsonObject *value)
     {
      m_value.SetObject(value);
     }

   /**
    * @brief Sets the value to an array; ownership of the pointer is transferred.
    * @param value  Heap-allocated array (NULL = null value).
    */
   void              SetArray(
      CAbsJsonArray *value)
     {
      m_value.SetArray(value);
     }

   /** @return The string payload ("" when the value is not a string). */
   string            GetString() const
     {
      return m_value.GetString();
     }

   /** @return The int payload (0 when the value is not an integer). */
   int               GetInteger() const
     {
      return m_value.GetInteger();
     }

   /** @return The long payload (0 when the value is not a long). */
   long              GetLong() const
     {
      return m_value.GetLong();
     }

   /** @return The double payload (0.0 when the value is not a double). */
   double            GetDouble() const
     {
      return m_value.GetDouble();
     }

   /** @return The boolean payload (false when the value is not a boolean). */
   bool              GetBoolean() const
     {
      return m_value.GetBoolean();
     }

   /** @return The JSON type of the value. */
   ENUM_ABS_JSON_TYPE JsonType() const
     {
      return m_value.JsonType();
     }

   /** @return true when the value is null. */
   bool              IsNull() const
     {
      return m_value.IsNull();
     }

   /** @return true when the value is a string. */
   bool              IsString() const
     {
      return m_value.IsString();
     }

   /** @return true when the value is a 32-bit integer. */
   bool              IsInteger() const
     {
      return m_value.IsInteger();
     }

   /** @return true when the value is a 64-bit integer. */
   bool              IsLong() const
     {
      return m_value.IsLong();
     }

   /** @return true when the value is a double. */
   bool              IsDouble() const
     {
      return m_value.IsDouble();
     }

   /** @return true when the value is a boolean. */
   bool              IsBoolean() const
     {
      return m_value.IsBoolean();
     }

   /** @return true when the value is an object. */
   bool              IsObject() const
     {
      return m_value.IsObject();
     }

   /** @return true when the value is an array. */
   bool              IsArray() const
     {
      return m_value.IsArray();
     }

   /**
    * @brief Replaces name and value with a deep copy of @p source.
    * @param source  Property to copy. Copying a property onto itself is not supported.
    * @return true on success.
    */
   bool              CopyFrom(
      const CAbsJsonProperty &source)
     {
      return CAbsJsonClone::Property(source,*this);
     }

   /**
    * @brief Stores a deep copy of this property into @p target.
    * @param[out] target  Receives the copy.
    * @return true on success.
    */
   bool              Clone(
      CAbsJsonProperty &target) const
     {
      return CAbsJsonClone::Property(*this,target);
     }

   /**
    * @brief Serializes the property as `"name":value` (compact, name escaped).
    * @return JSON text of the member (not a complete JSON document).
    */
   string            ToString() const
     {
      return "\"" +
             CAbsJsonEscape::Escape(m_name) +
             "\":" +
             m_value.ToString();
     }
  };

#endif // __ABS_JSON_PROPERTY_MQH__
//+------------------------------------------------------------------+
