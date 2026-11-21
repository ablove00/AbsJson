//+------------------------------------------------------------------+
//|                                        AbsJsonSerializable.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_SERIALIZABLE_MQH__
#define __ABS_JSON_SERIALIZABLE_MQH__

#property strict

#include "AbsJson.mqh"

/**
 * @file AbsJsonSerializable.mqh
 * @brief Interface for classes that can write themselves to, and read themselves from, a JSON document.
 */

/**
 * @class CAbsJsonSerializable
 * @brief Abstract interface (pure virtual methods) for JSON serialization of user classes.
 *
 * A derived class implements Serialize() to store its fields in a CAbsJson document and
 * Deserialize() to read them back. The library does not call these methods itself;
 * they define a common contract for user code.
 *
 * Example:
 * @code
 * class CPerson : public CAbsJsonSerializable
 *   {
 * public:
 *    string Name;
 *    int    Age;
 *
 *    virtual bool Serialize(CAbsJson &json) const
 *      {
 *       json.Clear();
 *
 *       CAbsJsonObject *object=new CAbsJsonObject();
 *
 *       if(object==NULL)
 *          return false;
 *
 *       if(!object.Set("Name",Name) || !object.Set("Age",Age))
 *         {
 *          delete object;
 *          return false;
 *         }
 *
 *       json.Root().SetObject(object);   // the root now owns the object
 *
 *       return true;
 *      }
 *
 *    virtual bool Deserialize(const CAbsJson &json)
 *      {
 *       const CAbsJsonValue *root=json.Root();
 *
 *       if(root.JsonType()!=ABS_JSON_OBJECT)
 *          return false;
 *
 *       const CAbsJsonObject *object=root.GetObject();
 *
 *       if(object==NULL || !object.HasProperty("Name") || !object.HasProperty("Age"))
 *          return false;
 *
 *       Name=object.GetString("Name");
 *       Age=object.GetInteger("Age");
 *
 *       return true;
 *      }
 *   };
 * @endcode
 */
class CAbsJsonSerializable
  {
public:

   /** @brief Creates the interface object. */
                     CAbsJsonSerializable()
     {
     }

   /** @brief Virtual destructor. */
   virtual          ~CAbsJsonSerializable()
     {
     }

   /**
    * @brief Writes the state of the object into a JSON document.
    * @param[out] json  Document that receives the data. Implementations normally call
    *                   json.Clear() first and then build the root.
    * @return true on success.
    */
   virtual bool      Serialize(
      CAbsJson &json) const = 0;

   /**
    * @brief Reads the state of the object from a JSON document.
    * @param json  Document to read (not modified).
    * @return true on success; false when the document does not have the expected structure.
    */
   virtual bool      Deserialize(
      const CAbsJson &json) = 0;
  };

#endif // __ABS_JSON_SERIALIZABLE_MQH__
//+------------------------------------------------------------------+
