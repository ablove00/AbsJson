//+------------------------------------------------------------------+
//|                                                 TestExtended.mqh |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)
#property strict

#include "TestBase.mqh"

/**
 * @file TestExtended.mqh
 * @brief Tests for the hash index of CAbsJsonObject, owner-aware SetName(),
 *        deep copy / assignment of CAbsJsonValue, the number-type and
 *        output-format enumerations, and the exact behavior of the double formatter.
 */

/** @brief Large objects: lookups, overwrite, removal and re-adding must stay correct with the hash index. */
bool TestExtLargeObjectIndex()
  {
   CAbsJsonObject object;

   const int total=5000;

   for(int i=0;i<total;i++)
      if(!object.Set("key"+IntegerToString(i),i))
         return false;

   if(!AssertEqual(total,object.Count(),"Large object count is incorrect."))
      return false;

   for(int i=0;i<total;i+=137)
      if(!AssertEqual(i,object.GetInteger("key"+IntegerToString(i)),"Large object lookup is incorrect."))
         return false;

   if(!AssertFalse(object.Contains("key5000"),"Missing key was found."))
      return false;

   // Overwrite must not add a property.
   object.Set("key42",-42);

   if(!AssertEqual(total,object.Count(),"Overwrite changed the count."))
      return false;

   if(!AssertEqual(-42,object.GetInteger("key42"),"Overwritten value is incorrect."))
      return false;

   // Duplicate through AddProperty must be rejected.
   CAbsJsonProperty *duplicate=new CAbsJsonProperty("key7");

   bool added=object.AddProperty(duplicate);

   if(!added)
      delete duplicate;

   if(!AssertFalse(added,"Duplicate property was accepted in a large object."))
      return false;

   // Remove from the middle: all other lookups must still work (indices shift).
   if(!AssertTrue(object.Remove("key100"),"Remove failed."))
      return false;

   if(!AssertFalse(object.Contains("key100"),"Removed key is still found."))
      return false;

   if(!AssertEqual(101,object.GetInteger("key101"),"Key after the removed one is wrong."))
      return false;

   if(!AssertEqual(4999,object.GetInteger("key4999"),"Last key is wrong after removal."))
      return false;

   // Re-adding a removed name must work.
   object.Set("key100",1000);

   if(!AssertEqual(1000,object.GetInteger("key100"),"Re-added key is wrong."))
      return false;

   // Shrink below the threshold, then grow again.
   for(int i=total-1;i>=10;i--)
      if(i!=100)
         object.Remove("key"+IntegerToString(i));

   if(!AssertTrue(object.Contains("key5") && object.Contains("key100"),"Remaining keys are not found."))
      return false;

   for(int i=0;i<200;i++)
      object.Set("n"+IntegerToString(i),i);

   if(!AssertEqual(199,object.GetInteger("n199"),"Lookup after re-growth is wrong."))
      return false;

   object.Clear();

   if(!AssertEqual(0,object.Count(),"Clear did not empty the object."))
      return false;

   object.Set("again",1);

   return AssertEqual(1,object.GetInteger("again"),"Object is not reusable after Clear.");
  }

/** @brief Parsing a large object must detect duplicates and keep every property. */
bool TestExtLargeParse()
  {
   string json="{";

   for(int i=0;i<3000;i++)
     {
      if(i>0)
         json+=",";

      json+="\"k"+IntegerToString(i)+"\":"+IntegerToString(i);
     }

   string valid=json+"}";

   CAbsJson doc;

   if(!AssertTrue(doc.Parse(valid),"Large document was rejected."))
      return false;

   CAbsJsonObject *root=doc.Root().GetObject();

   if(!AssertEqual(3000,root.Count(),"Parsed property count is wrong."))
      return false;

   if(!AssertEqual(2999,root.GetInteger("k2999"),"Parsed lookup is wrong."))
      return false;

   if(!AssertEqual(valid,doc.Minify(),"Large document did not round trip."))
      return false;

   // Duplicate of an early key near the end.
   CAbsJson bad;

   if(!AssertFalse(bad.Parse(json+",\"k5\":0}"),"Duplicate in a large object was accepted."))
      return false;

   return AssertEqual((int)ABS_JSON_ERROR_DUPLICATE_PROPERTY,(int)bad.GetStatus().Code(),"Duplicate error code is wrong.");
  }

/** @brief Deep clone of a large object must produce a working index. */
bool TestExtLargeClone()
  {
   CAbsJsonObject source;

   for(int i=0;i<500;i++)
      source.Set("p"+IntegerToString(i),"v"+IntegerToString(i));

   CAbsJsonObject copy;

   if(!AssertTrue(source.Clone(copy),"Clone failed."))
      return false;

   source.Remove("p10");

   if(!AssertTrue(copy.Contains("p10"),"Clone is not independent."))
      return false;

   return AssertEqual("v499",copy.GetString("p499"),"Cloned lookup is wrong.");
  }

/** @brief SetName() must refuse duplicates inside an object and keep lookups correct. */
bool TestExtRenameProperty()
  {
   // Free-standing property: always allowed.
   CAbsJsonProperty standalone("a");

   if(!AssertTrue(standalone.SetName("b"),"Rename of a free property failed."))
      return false;

   // Small object (linear search) and large object (hash index).
   int sizes[]={3,300};

   for(int s=0;s<ArraySize(sizes);s++)
     {
      CAbsJsonObject object;

      for(int i=0;i<sizes[s];i++)
         object.Set("p"+IntegerToString(i),i);

      CAbsJsonProperty *first=object.FindProperty("p0");

      if(!AssertTrue(first!=NULL,"Property not found."))
         return false;

      if(!AssertFalse(first.SetName("p1"),"Rename to an existing name was accepted."))
         return false;

      if(!AssertEqual("p0",first.Name(),"Name changed although the rename was refused."))
         return false;

      if(!AssertEqual(sizes[s],object.Count(),"Count changed."))
         return false;

      if(!AssertTrue(first.SetName("p0"),"Rename to the same name must succeed."))
         return false;

      if(!AssertTrue(first.SetName("renamed"),"Rename to a free name failed."))
         return false;

      if(!AssertTrue(object.Contains("renamed"),"New name is not found."))
         return false;

      if(!AssertFalse(object.Contains("p0"),"Old name is still found."))
         return false;

      if(!AssertEqual(0,object.GetInteger("renamed"),"Renamed property lost its value."))
         return false;

      if(!AssertEqual(1,object.GetInteger("p1"),"Other property is wrong after rename."))
         return false;
     }

   return true;
  }

/** @brief Assignment and copy construction of CAbsJsonValue must be deep (no double delete). */
bool TestExtValueAssignment()
  {
   CAbsJsonParser parser;
   CAbsJsonValue a;

   if(!parser.Parse("{\"list\":[1,2],\"o\":{\"x\":1}}",a))
      return false;

   CAbsJsonValue b;

   b=a;

   // Modify the copy; the source must not change.
   b.GetObject().Set("extra",true);

   if(!AssertEqual("{\"list\":[1,2],\"o\":{\"x\":1}}",a.ToString(),"Source changed after assigning and modifying the copy."))
      return false;

   if(!AssertTrue(b.GetObject().Contains("extra"),"Copy was not modified."))
      return false;

   CAbsJsonValue c(a);

   if(!AssertEqual(a.ToString(),c.ToString(),"Copy constructor result is wrong."))
      return false;

   // Self-assignment keeps the data.
   a=a;

   if(!AssertEqual("{\"list\":[1,2],\"o\":{\"x\":1}}",a.ToString(),"Self-assignment destroyed the value."))
      return false;

   // Assigning a scalar over a container releases the container safely.
   CAbsJsonValue scalar;

   scalar.SetInteger(7);

   b=scalar;

   if(!AssertEqual("7",b.ToString(),"Assigning a scalar failed."))
      return false;

   // Property assignment copies name and value, not the owner.
   CAbsJsonObject object;

   object.Set("n",5);

   CAbsJsonProperty p;

   p=*object.FindProperty("n");

   if(!AssertTrue(p.Owner()==NULL,"Assigned property must not have an owner."))
      return false;

   return AssertEqual("\"n\":5",p.ToString(),"Assigned property content is wrong.");
  }

/** @brief CAbsJsonNumber::GetNumberType() uses ENUM_ABS_JSON_NUMBER_TYPE. */
bool TestExtNumberType()
  {
   ENUM_ABS_JSON_NUMBER_TYPE type=ABS_JSON_NUMBER_DOUBLE;

   if(!AssertTrue(CAbsJsonNumber::GetNumberType("5",type) && type==ABS_JSON_NUMBER_INTEGER,"5 must be an integer."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::GetNumberType("-2147483648",type) && type==ABS_JSON_NUMBER_INTEGER,"Min int must be an integer."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::GetNumberType("2147483648",type) && type==ABS_JSON_NUMBER_LONG,"2147483648 must be a long."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::GetNumberType("1.0",type) && type==ABS_JSON_NUMBER_DOUBLE,"1.0 must be a double."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::GetNumberType("2E3",type) && type==ABS_JSON_NUMBER_DOUBLE,"2E3 must be a double."))
      return false;

   type=ABS_JSON_NUMBER_INTEGER;

   if(!AssertFalse(CAbsJsonNumber::GetNumberType("9223372036854775808",type),"Overflow accepted."))
      return false;

   if(!AssertFalse(CAbsJsonNumber::GetNumberType("01",type),"Leading zero accepted."))
      return false;

   // Must agree with the parser.
   CAbsJsonParser parser;
   CAbsJsonValue value;

   parser.Parse("2147483648",value);

   return AssertTrue(value.JsonType()==ABS_JSON_LONG,"Parser and GetNumberType disagree.");
  }

/** @brief ENUM_ABS_JSON_FORMAT is honored by the writer and by the facade. */
bool TestExtOutputFormat()
  {
   CAbsJson json;

   if(!json.Parse("{\"a\":[1,2]}"))
      return false;

   if(!AssertEqual(json.Minify(),json.ToString(ABS_JSON_MINIFY),"MINIFY format output is wrong."))
      return false;

   if(!AssertEqual(json.PrettyPrint(2),json.ToString(ABS_JSON_PRETTY,2),"PRETTY format output is wrong."))
      return false;

   CAbsJsonWriter writer;

   writer.SetFormat(ABS_JSON_PRETTY);

   string pretty=writer.Write(*json.Root());

   if(!AssertTrue(StringFind(pretty,"\r\n")>=0,"Pretty output has no line breaks."))
      return false;

   writer.SetFormat(ABS_JSON_MINIFY);

   return AssertEqual("{\"a\":[1,2]}",writer.Write(*json.Root()),"Switching back to compact output failed.");
  }

/** @brief The double formatter must always emit valid JSON that parses back to the same double. */
bool TestExtDoubleFormatting()
  {
   double values[]={1e-300,1e300,123456789.123456789,DBL_MAX,DBL_MIN,-1e-7,1e15,1e16,123456789012345.0,0.5,-0.25,2.2250738585072014e-308};

   for(int i=0;i<ArraySize(values);i++)
     {
      string text=CAbsJsonNumber::DoubleToJson(values[i]);

      if(!AssertTrue(CAbsJsonNumber::Validate(text),"Not a valid JSON number: "+text))
         return false;

      double back;

      if(!AssertTrue(CAbsJsonNumber::ParseDouble(text,back) && back==values[i],"Round trip failed: "+text))
         return false;
     }

   if(!AssertEqual("0.5",CAbsJsonNumber::DoubleToJson(0.5),"0.5 text is wrong."))
      return false;

   if(!AssertEqual("-0.25",CAbsJsonNumber::DoubleToJson(-0.25),"-0.25 text is wrong."))
      return false;

   return AssertEqual("5",CAbsJsonNumber::DoubleToJson(5.0),"Whole double text is wrong.");
  }

/** @brief Runs the extended tests. */
void RunTestExtended()
  {
   RunTest("Extended Large Object Index",TestExtLargeObjectIndex());
   RunTest("Extended Large Parse",TestExtLargeParse());
   RunTest("Extended Large Clone",TestExtLargeClone());
   RunTest("Extended Rename Property",TestExtRenameProperty());
   RunTest("Extended Value Assignment",TestExtValueAssignment());
   RunTest("Extended Number Type",TestExtNumberType());
   RunTest("Extended Output Format",TestExtOutputFormat());
   RunTest("Extended Double Formatting",TestExtDoubleFormatting());
  }
//+------------------------------------------------------------------+
