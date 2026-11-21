//+------------------------------------------------------------------+
//|                                                    TestValue.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#include "TestBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RunTestValue()
  {

   RunTest(
      "Value Setters",
      TestValueSetters());


   RunTest(
      "Getters",
      TestGetters());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the setters of CAbsJsonValue.
 *
 * Checks the setters for Null, String, Integer, Long, Double, Boolean, Object and Array and verifies that the stored value matches the assigned one.
 *
 * @return
 * true when the test passes.
 */
bool TestValueSetters()
  {

   CAbsJsonValue value;


   value.SetNull();

   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)value.JsonType(),
         "SetNull failed."))
      return false;


   value.SetString(
      "Amir");

   if(!AssertEqual(
         (int)ABS_JSON_STRING,
         (int)value.JsonType(),
         "SetString type failed."))
      return false;


   if(!AssertEqual(
         "Amir",
         value.GetString(),
         "SetString value failed."))
      return false;


   value.SetInteger(
      -123);

   if(!AssertEqual(
         (int)ABS_JSON_INTEGER,
         (int)value.JsonType(),
         "SetInteger type failed."))
      return false;


   if(!AssertEqual(
         -123,
         value.GetInteger(),
         "SetInteger value failed."))
      return false;


   long longValue=
      922337203685477000LL;


   value.SetLong(
      longValue);

   if(!AssertEqual(
         (int)ABS_JSON_LONG,
         (int)value.JsonType(),
         "SetLong type failed."))
      return false;


   if(!AssertEqual(
         longValue,
         value.GetLong(),
         "SetLong value failed."))
      return false;


   value.SetDouble(
      -123.456);

   if(!AssertEqual(
         (int)ABS_JSON_DOUBLE,
         (int)value.JsonType(),
         "SetDouble type failed."))
      return false;


   if(!AssertEqual(
         -123.456,
         value.GetDouble(),
         "SetDouble value failed."))
      return false;


   value.SetBoolean(
      true);

   if(!AssertEqual(
         (int)ABS_JSON_BOOLEAN,
         (int)value.JsonType(),
         "SetBoolean type failed."))
      return false;


   if(!AssertTrue(
         value.GetBoolean(),
         "SetBoolean true value failed."))
      return false;


   value.SetBoolean(
      false);

   if(!AssertFalse(
         value.GetBoolean(),
         "SetBoolean false value failed."))
      return false;


   CAbsJsonObject *object=
      new CAbsJsonObject();


   value.SetObject(
      object);

   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)value.JsonType(),
         "SetObject type failed."))
      return false;


   if(!AssertTrue(
         value.GetObject()!=NULL,
         "SetObject value failed."))
      return false;


   CAbsJsonArray *array=
      new CAbsJsonArray();


   value.SetArray(
      array);

   if(!AssertEqual(
         (int)ABS_JSON_ARRAY,
         (int)value.JsonType(),
         "SetArray type failed."))
      return false;


   if(!AssertTrue(
         value.GetArray()!=NULL,
         "SetArray value failed."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the getters of CAbsJsonValue.
 *
 * Checks the getters for String, Integer, Long, Double, Boolean, Object and Array values.
 *
 * @return
 * true when the test passes.
 */
bool TestGetters()
  {

   CAbsJsonValue value;


   value.SetString(
      "Amir");

   if(!AssertEqual(
         "Amir",
         value.GetString(),
         "GetString failed."))
      return false;


   value.SetInteger(
      123);

   if(!AssertEqual(
         123,
         value.GetInteger(),
         "GetInteger failed."))
      return false;


   long longValue=
      922337203685477000LL;


   value.SetLong(
      longValue);

   if(!AssertEqual(
         longValue,
         value.GetLong(),
         "GetLong failed."))
      return false;


   value.SetDouble(
      123.456);

   if(!AssertEqual(
         123.456,
         value.GetDouble(),
         "GetDouble failed."))
      return false;


   value.SetBoolean(
      true);

   if(!AssertTrue(
         value.GetBoolean(),
         "GetBoolean true failed."))
      return false;


   value.SetBoolean(
      false);

   if(!AssertFalse(
         value.GetBoolean(),
         "GetBoolean false failed."))
      return false;


   CAbsJsonObject *object=
      new CAbsJsonObject();


   value.SetObject(
      object);


   if(!AssertTrue(
         value.GetObject()!=NULL,
         "GetObject failed."))
      return false;


   CAbsJsonArray *array=
      new CAbsJsonArray();


   value.SetArray(
      array);


   if(!AssertTrue(
         value.GetArray()!=NULL,
         "GetArray failed."))
      return false;


   value.SetNull();


   if(!AssertEqual(
         (int)ABS_JSON_NULL,
         (int)value.JsonType(),
         "Getters after SetNull failed."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
