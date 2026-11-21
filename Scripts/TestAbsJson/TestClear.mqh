//+------------------------------------------------------------------+
//|                                                    TestClear.mqh |
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
void RunTestClear()
  {
   RunTest(
      "Clear Object",
      TestClearObject());


   RunTest(
      "Clear Array",
      TestClearArray());
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests Clear() on an object.
 *
 * Creates an object with several properties, calls Clear() and checks that all properties are removed.
 *
 * @return
 * true when the test passes.
 */
bool TestClearObject()
  {

   CAbsJsonObject object;


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!object.AddProperty(name))
     {
      delete name;
      return false;
     }


   CAbsJsonProperty *age=
      new CAbsJsonProperty();


   age.SetName(
      "age");


   age.Value().SetInteger(
      38);


   if(!object.AddProperty(age))
     {
      delete age;
      return false;
     }


   if(!AssertEqual(
         2,
         object.Count(),
         "Object setup failed."))
      return false;


   object.Clear();


   if(!AssertEqual(
         0,
         object.Count(),
         "Object was not cleared."))
      return false;


   if(!AssertTrue(
         object.FindProperty(
            "name")==NULL,
         "Name property still exists after Clear."))
      return false;


   if(!AssertTrue(
         object.FindProperty(
            "age")==NULL,
         "Age property still exists after Clear."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests Clear() on an array.
 *
 * Creates an array with several values, calls Clear() and checks that the array ends up completely empty.
 *
 * @return
 * true when the test passes.
 */
bool TestClearArray()
  {

   CAbsJsonArray array;


   CAbsJsonValue *integer=
      new CAbsJsonValue();


   integer.SetInteger(
      10);


   if(!array.AddItem(integer))
     {
      delete integer;
      return false;
     }


   CAbsJsonValue *text=
      new CAbsJsonValue();


   text.SetString(
      "Amir");


   if(!array.AddItem(text))
     {
      delete text;
      return false;
     }


   CAbsJsonValue *boolean=
      new CAbsJsonValue();


   boolean.SetBoolean(
      true);


   if(!array.AddItem(boolean))
     {
      delete boolean;
      return false;
     }


   if(!AssertEqual(
         3,
         array.Count(),
         "Array setup failed."))
      return false;


   array.Clear();


   if(!AssertEqual(
         0,
         array.Count(),
         "Array was not cleared."))
      return false;


   if(!AssertTrue(
         array.Item(0)==NULL,
         "Array item still exists after Clear."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
