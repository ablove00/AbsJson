//+------------------------------------------------------------------+
//|                                           AbsJsonCloneImpl.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_CLONE_IMPL_MQH__
#define __ABS_JSON_CLONE_IMPL_MQH__

#property strict

#include "../Core/AbsJsonValue.mqh"
#include "../Core/AbsJsonProperty.mqh"
#include "../Objects/AbsJsonObject.mqh"
#include "../Objects/AbsJsonArray.mqh"
#include "AbsJsonClone.mqh"

/**
 * @file AbsJsonCloneImpl.mqh
 * @brief Implementation of CAbsJsonClone (see AbsJsonClone.mqh).
 *
 * Memory rule used by every function: a newly created child is deleted on
 * every failure path before the function returns, so a failed copy never leaks.
 */

bool CAbsJsonClone::Value(
   const CAbsJsonValue &source,
   CAbsJsonValue &target)
  {
   target.Clear();

   switch(source.JsonType())
     {
      case ABS_JSON_NULL:
         target.SetNull();
         return true;

      case ABS_JSON_STRING:
         target.SetString(source.GetString());
         return true;

      case ABS_JSON_INTEGER:
         target.SetInteger(source.GetInteger());
         return true;

      case ABS_JSON_LONG:
         target.SetLong(source.GetLong());
         return true;

      case ABS_JSON_DOUBLE:
         target.SetDouble(source.GetDouble());
         return true;

      case ABS_JSON_BOOLEAN:
         target.SetBoolean(source.GetBoolean());
         return true;

      case ABS_JSON_OBJECT:
        {
         // Validate the source before allocating anything (no leak on this path).
         if(source.GetObject()==NULL)
            return false;

         CAbsJsonObject *object=new CAbsJsonObject();

         if(object==NULL)
            return false;

         if(!Object(*source.GetObject(),*object))
           {
            delete object;
            return false;
           }

         target.SetObject(object);
         return true;
        }

      case ABS_JSON_ARRAY:
        {
         if(source.GetArray()==NULL)
            return false;

         CAbsJsonArray *array=new CAbsJsonArray();

         if(array==NULL)
            return false;

         if(!Array(*source.GetArray(),*array))
           {
            delete array;
            return false;
           }

         target.SetArray(array);
         return true;
        }
     }

   return false;
  }

bool CAbsJsonClone::Object(
   const CAbsJsonObject &source,
   CAbsJsonObject &target)
  {
   target.Clear();

   int total=source.Count();

   for(int i=0;i<total;i++)
     {
      CAbsJsonProperty *property=source.GetProperty(i);

      if(property==NULL)
         continue;

      CAbsJsonProperty *copy=new CAbsJsonProperty();

      if(copy==NULL)
        {
         target.Clear();
         return false;
        }

      if(!Property(*property,*copy))
        {
         delete copy;
         target.Clear();
         return false;
        }

      if(!target.AddProperty(copy))
        {
         delete copy;
         target.Clear();
         return false;
        }
     }

   return true;
  }

bool CAbsJsonClone::Array(
   const CAbsJsonArray &source,
   CAbsJsonArray &target)
  {
   target.Clear();

   int total=source.Count();

   for(int i=0;i<total;i++)
     {
      CAbsJsonValue *value=source.Item(i);

      if(value==NULL)
         continue;

      CAbsJsonValue *copy=new CAbsJsonValue();

      if(copy==NULL)
        {
         target.Clear();
         return false;
        }

      if(!Value(*value,*copy))
        {
         delete copy;
         target.Clear();
         return false;
        }

      if(!target.AddItem(copy))
        {
         delete copy;
         target.Clear();
         return false;
        }
     }

   return true;
  }

bool CAbsJsonClone::Property(
   const CAbsJsonProperty &source,
   CAbsJsonProperty &target)
  {
   target.Clear();

   target.SetName(source.Name());

   if(source.Value()==NULL)
      return false;

   return Value(*source.Value(),*target.Value());
  }

#endif // __ABS_JSON_CLONE_IMPL_MQH__
//+------------------------------------------------------------------+
