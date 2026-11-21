//+------------------------------------------------------------------+
//|                                                    TestClone.mqh |
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
void RunTestClone()
  {
   RunTest(
      "Clone Object",
      TestCloneObject());

   RunTest(
      "Clone Array",
      TestCloneArray());

   RunTest(
      "Clone Value",
      TestCloneValue());

   RunTest(
      "Clone Independence",
      TestCloneIndependence());
      
  
  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the deep copy of an object.
 *
 * Clones an object with simple values and a nested object, then checks the values and the independence of the copy from the source object.
 *
 * @return
 * true when the test passes.
 */
bool TestCloneObject()
  {

   CAbsJsonObject source;


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!source.AddProperty(name))
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


   if(!source.AddProperty(age))
     {
      delete age;
      return false;
     }


   CAbsJsonProperty *profile=
      new CAbsJsonProperty();


   profile.SetName(
      "profile");


   CAbsJsonObject *profileObject=
      new CAbsJsonObject();


   CAbsJsonProperty *city=
      new CAbsJsonProperty();


   city.SetName(
      "city");


   city.Value().SetString(
      "Tehran");


   if(!profileObject.AddProperty(city))
     {
      delete city;
      delete profileObject;
      delete profile;
      return false;
     }


   profile.Value().SetObject(
      profileObject);


   if(!source.AddProperty(profile))
     {
      delete profile;
      return false;
     }


   CAbsJsonObject target;

   CAbsJsonClone clone;


   if(!clone.Object(
         source,
         target))
      return false;


   CAbsJsonProperty *targetName=
      target.FindProperty(
         "name");


   if(!AssertTrue(
         targetName!=NULL,
         "Cloned name property is missing."))
      return false;


   if(!AssertEqual(
         "Amir",
         targetName.Value().GetString(),
         "Cloned name value is incorrect."))
      return false;


   CAbsJsonProperty *targetAge=
      target.FindProperty(
         "age");


   if(!AssertTrue(
         targetAge!=NULL,
         "Cloned age property is missing."))
      return false;


   if(!AssertEqual(
         38,
         targetAge.Value().GetInteger(),
         "Cloned age value is incorrect."))
      return false;


   CAbsJsonProperty *targetProfile=
      target.FindProperty(
         "profile");


   if(!AssertTrue(
         targetProfile!=NULL,
         "Cloned profile property is missing."))
      return false;


   CAbsJsonObject *targetProfileObject=
      targetProfile.Value().GetObject();


   if(!AssertTrue(
         targetProfileObject!=NULL,
         "Cloned profile object is NULL."))
      return false;


   CAbsJsonProperty *targetCity=
      targetProfileObject.FindProperty(
         "city");


   if(!AssertTrue(
         targetCity!=NULL,
         "Cloned city property is missing."))
      return false;


   if(!AssertEqual(
         "Tehran",
         targetCity.Value().GetString(),
         "Cloned city value is incorrect."))
      return false;


   targetName.Value().SetString(
      "Changed");


   if(!AssertEqual(
         "Amir",
         source.FindProperty(
            "name").Value().GetString(),
         "Source object was modified through clone."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the deep copy of an array.
 *
 * Clones an array with different values and a nested object, then checks the values and the independence of the copy from the source array.
 *
 * @return
 * true when the test passes.
 */
bool TestCloneArray()
  {

   CAbsJsonArray source;


   CAbsJsonValue *item0=
      new CAbsJsonValue();


   item0.SetInteger(
      10);


   if(!source.AddItem(item0))
     {
      delete item0;
      return false;
     }


   CAbsJsonValue *item1=
      new CAbsJsonValue();


   item1.SetString(
      "Amir");


   if(!source.AddItem(item1))
     {
      delete item1;
      return false;
     }


   CAbsJsonValue *item2=
      new CAbsJsonValue();


   item2.SetBoolean(
      true);


   if(!source.AddItem(item2))
     {
      delete item2;
      return false;
     }


   CAbsJsonValue *item3=
      new CAbsJsonValue();


   CAbsJsonObject *object=
      new CAbsJsonObject();


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!object.AddProperty(name))
     {
      delete name;
      delete object;
      delete item3;
      return false;
     }


   item3.SetObject(
      object);


   if(!source.AddItem(item3))
     {
      delete item3;
      return false;
     }


   CAbsJsonArray target;

   CAbsJsonClone clone;


   if(!clone.Array(
         source,
         target))
      return false;


   if(!AssertEqual(
         4,
         target.Count(),
         "Cloned array count is incorrect."))
      return false;


   if(!AssertEqual(
         10,
         target.Item(0).GetInteger(),
         "Cloned integer value is incorrect."))
      return false;


   if(!AssertEqual(
         "Amir",
         target.Item(1).GetString(),
         "Cloned string value is incorrect."))
      return false;


   if(!AssertTrue(
         target.Item(2).GetBoolean(),
         "Cloned boolean value is incorrect."))
      return false;


   CAbsJsonObject *targetObject=
      target.Item(3).GetObject();


   if(!AssertTrue(
         targetObject!=NULL,
         "Cloned object is NULL."))
      return false;


   CAbsJsonProperty *targetName=
      targetObject.FindProperty(
         "name");


   if(!AssertTrue(
         targetName!=NULL,
         "Cloned object name is missing."))
      return false;


   if(!AssertEqual(
         "Amir",
         targetName.Value().GetString(),
         "Cloned object name is incorrect."))
      return false;


   target.Item(1).SetString(
      "Changed");


   if(!AssertEqual(
         "Amir",
         source.Item(1).GetString(),
         "Source array was modified through clone."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests the deep copy of a value.
 *
 * Clones values of different types, then checks them and verifies that the source is unchanged.
 *
 * @return
 * true when the test passes.
 */
bool TestCloneValue()
  {

   CAbsJsonValue source;


   CAbsJsonObject *object=
      new CAbsJsonObject();


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!object.AddProperty(name))
     {
      delete name;
      delete object;
      return false;
     }


   CAbsJsonArray *array=
      new CAbsJsonArray();


   CAbsJsonValue *item=
      new CAbsJsonValue();


   item.SetDouble(
      12.5);


   if(!array.AddItem(item))
     {
      delete item;
      delete array;
      delete object;
      return false;
     }


   CAbsJsonProperty *data=
      new CAbsJsonProperty();


   data.SetName(
      "data");


   data.Value().SetArray(
      array);


   if(!object.AddProperty(data))
     {
      delete data;
      delete object;
      return false;
     }


   source.SetObject(
      object);


   CAbsJsonValue target;

   CAbsJsonClone clone;


   if(!clone.Value(
         source,
         target))
      return false;


   if(!AssertEqual(
         (int)ABS_JSON_OBJECT,
         (int)target.JsonType(),
         "Cloned value type is incorrect."))
      return false;


   CAbsJsonObject *targetObject=
      target.GetObject();


   if(!AssertTrue(
         targetObject!=NULL,
         "Cloned object is NULL."))
      return false;


   CAbsJsonProperty *targetName=
      targetObject.FindProperty(
         "name");


   if(!AssertTrue(
         targetName!=NULL,
         "Cloned name property is missing."))
      return false;


   if(!AssertEqual(
         "Amir",
         targetName.Value().GetString(),
         "Cloned name value is incorrect."))
      return false;


   CAbsJsonProperty *targetData=
      targetObject.FindProperty(
         "data");


   if(!AssertTrue(
         targetData!=NULL,
         "Cloned data property is missing."))
      return false;


   CAbsJsonArray *targetArray=
      targetData.Value().GetArray();


   if(!AssertTrue(
         targetArray!=NULL,
         "Cloned array is NULL."))
      return false;


   if(!AssertEqual(
         1,
         targetArray.Count(),
         "Cloned array count is incorrect."))
      return false;


   if(!AssertEqual(
         12.5,
         targetArray.Item(0).GetDouble(),
         "Cloned double value is incorrect."))
      return false;


   targetName.Value().SetString(
      "Changed");


   if(!AssertEqual(
         "Amir",
         source.GetObject().FindProperty(
            "name").Value().GetString(),
         "Source value was modified through clone."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
/**
 * @brief Tests that a clone is fully independent of its source.
 *
 * Builds a nested structure, deep-clones it, modifies the clone and verifies that the source did not change.
 *
 * @return
 * true when the test passes.
 */
bool TestCloneIndependence()
  {

   CAbsJsonObject source;


   CAbsJsonProperty *name=
      new CAbsJsonProperty();


   name.SetName(
      "name");


   name.Value().SetString(
      "Amir");


   if(!source.AddProperty(name))
     {
      delete name;
      return false;
     }


   CAbsJsonProperty *profile=
      new CAbsJsonProperty();


   profile.SetName(
      "profile");


   CAbsJsonObject *profileObject=
      new CAbsJsonObject();


   CAbsJsonProperty *city=
      new CAbsJsonProperty();


   city.SetName(
      "city");


   city.Value().SetString(
      "Tehran");


   if(!profileObject.AddProperty(city))
     {
      delete city;
      delete profileObject;
      delete profile;
      return false;
     }


   CAbsJsonArray *numbers=
      new CAbsJsonArray();


   CAbsJsonValue *number1=
      new CAbsJsonValue();


   number1.SetInteger(
      10);


   if(!numbers.AddItem(number1))
     {
      delete number1;
      delete numbers;
      delete profileObject;
      delete profile;
      return false;
     }


   CAbsJsonValue *number2=
      new CAbsJsonValue();


   number2.SetInteger(
      20);


   if(!numbers.AddItem(number2))
     {
      delete number2;
      delete numbers;
      delete profileObject;
      delete profile;
      return false;
     }


   CAbsJsonProperty *values=
      new CAbsJsonProperty();


   values.SetName(
      "values");


   values.Value().SetArray(
      numbers);


   if(!profileObject.AddProperty(values))
     {
      delete values;
      delete profileObject;
      delete profile;
      return false;
     }


   profile.Value().SetObject(
      profileObject);


   if(!source.AddProperty(profile))
     {
      delete profile;
      return false;
     }


   CAbsJsonObject clone;


   CAbsJsonClone cloner;


   if(!cloner.Object(
         source,
         clone))
      return false;


   CAbsJsonProperty *cloneName=
      clone.FindProperty(
         "name");


   if(!AssertTrue(
         cloneName!=NULL,
         "Clone name property is missing."))
      return false;


   CAbsJsonProperty *cloneProfile=
      clone.FindProperty(
         "profile");


   if(!AssertTrue(
         cloneProfile!=NULL,
         "Clone profile property is missing."))
      return false;


   CAbsJsonObject *cloneProfileObject=
      cloneProfile.Value().GetObject();


   if(!AssertTrue(
         cloneProfileObject!=NULL,
         "Clone profile object is NULL."))
      return false;


   CAbsJsonProperty *cloneCity=
      cloneProfileObject.FindProperty(
         "city");


   if(!AssertTrue(
         cloneCity!=NULL,
         "Clone city property is missing."))
      return false;


   CAbsJsonProperty *cloneValues=
      cloneProfileObject.FindProperty(
         "values");


   if(!AssertTrue(
         cloneValues!=NULL,
         "Clone values property is missing."))
      return false;


   CAbsJsonArray *cloneArray=
      cloneValues.Value().GetArray();


   if(!AssertTrue(
         cloneArray!=NULL,
         "Clone values array is NULL."))
      return false;


   if(!AssertEqual(
         "Amir",
         cloneName.Value().GetString(),
         "Clone name value is incorrect."))
      return false;


   if(!AssertEqual(
         "Tehran",
         cloneCity.Value().GetString(),
         "Clone city value is incorrect."))
      return false;


   if(!AssertEqual(
         10,
         cloneArray.Item(0).GetInteger(),
         "Clone array item 0 is incorrect."))
      return false;


   if(!AssertEqual(
         20,
         cloneArray.Item(1).GetInteger(),
         "Clone array item 1 is incorrect."))
      return false;


   cloneName.Value().SetString(
      "Changed");


   cloneCity.Value().SetString(
      "Mashhad");


   cloneArray.Item(0).SetInteger(
      999);


   if(!AssertEqual(
         "Amir",
         source.FindProperty(
            "name").Value().GetString(),
         "Source name changed through clone."))
      return false;


   CAbsJsonObject *sourceProfile=
      source.FindProperty(
         "profile").Value().GetObject();


   if(!AssertTrue(
         sourceProfile!=NULL,
         "Source profile object is NULL."))
      return false;


   if(!AssertEqual(
         "Tehran",
         sourceProfile.FindProperty(
            "city").Value().GetString(),
         "Source city changed through clone."))
      return false;


   CAbsJsonArray *sourceArray=
      sourceProfile.FindProperty(
         "values").Value().GetArray();


   if(!AssertTrue(
         sourceArray!=NULL,
         "Source values array is NULL."))
      return false;


   if(!AssertEqual(
         10,
         sourceArray.Item(0).GetInteger(),
         "Source array item changed through clone."))
      return false;


   return true;

  }
//+------------------------------------------------------------------+
