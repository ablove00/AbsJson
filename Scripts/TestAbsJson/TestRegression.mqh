//+------------------------------------------------------------------+
//|                                               TestRegression.mqh |
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
 * @file TestRegression.mqh
 * @brief Tests for behavior that was fixed or added during the code audit:
 *        escaping, double round trip, nested ToString, error positions,
 *        depth limit, duplicate-key error code, number / escape utilities,
 *        UTF-8 file I/O and repeated parse / write cycles.
 */

/** @brief Builds @p count nested arrays, e.g. "[[[]]]". */
string RegBuildNestedArrays(const int count)
  {
   string text="";

   for(int i=0;i<count;i++)
      text+="[";

   for(int i=0;i<count;i++)
      text+="]";

   return text;
  }

/** @brief Control characters must be written as \u00XX and survive a round trip. */
bool TestRegControlCharacters()
  {
   CAbsJsonValue value;
   CAbsJsonWriter writer;
   CAbsJsonParser parser;
   CAbsJsonValue result;

   string text="A"+ShortToString(1)+"B"+ShortToString(31)+"C";

   value.SetString(text);

   string json=writer.Write(value);

   if(!AssertEqual("\"A\\u0001B\\u001FC\"",json,"Control characters were not escaped as \\u00XX."))
      return false;

   if(!AssertTrue(parser.Parse(json,result),"Escaped control characters were not parsed."))
      return false;

   return AssertEqual(text,result.GetString(),"Control character round trip is incorrect.");
  }

/** @brief Doubles must be written so that they parse back to the identical value. */
bool TestRegDoubleRoundTrip()
  {
   double values[]={0.1+0.2,1.5e-10,1e20,-123.456,3.14,0.0,1.0/3.0};

   for(int i=0;i<ArraySize(values);i++)
     {
      string text=CAbsJsonNumber::DoubleToJson(values[i]);

      double back;

      if(!AssertTrue(CAbsJsonNumber::ParseDouble(text,back),"DoubleToJson produced invalid JSON number: "+text))
         return false;

      if(!AssertTrue(back==values[i],"Double did not round trip: "+text))
         return false;
     }

   if(!AssertEqual("0",CAbsJsonNumber::DoubleToJson(0.0),"Zero text is incorrect."))
      return false;

   if(!AssertEqual("3.14",CAbsJsonNumber::DoubleToJson(3.14),"3.14 text is incorrect."))
      return false;

   double nan=MathSqrt(-1.0);

   return AssertEqual("null",CAbsJsonNumber::DoubleToJson(nan),"NaN must be written as null.");
  }

/** @brief Object/Array ToString() must handle nesting and escaping. */
bool TestRegNestedToString()
  {
   CAbsJsonParser parser;
   CAbsJsonObject object;

   string source="{\"a\":{\"b\":[1,\"x\\\"y\"]},\"c\":null}";

   if(!AssertTrue(parser.Parse(source,object),"Source was not parsed."))
      return false;

   if(!AssertEqual(source,object.ToString(),"Object.ToString() output is incorrect."))
      return false;

   CAbsJsonProperty property("na\"me");

   property.SetInteger(5);

   return AssertEqual("\"na\\\"me\":5",property.ToString(),"Property.ToString() must escape the name.");
  }

/** @brief CAbsJsonObject::GetArray(name,...) must return a deep copy. */
bool TestRegObjectGetArray()
  {
   CAbsJsonParser parser;
   CAbsJsonObject object;

   if(!parser.Parse("{\"list\":[1,2,3],\"n\":1}",object))
      return false;

   CAbsJsonArray copy;

   if(!AssertTrue(object.GetArray("list",copy),"GetArray returned false."))
      return false;

   if(!AssertEqual(3,copy.Count(),"Copied array count is incorrect."))
      return false;

   if(!AssertFalse(object.GetArray("n",copy),"GetArray must fail for a non-array property."))
      return false;

   return AssertFalse(object.GetArray("missing",copy),"GetArray must fail for a missing property.");
  }

/** @brief Nesting deeper than AbsJsonConst::MAX_DEPTH must be rejected, normal depth accepted. */
bool TestRegDepthLimit()
  {
   CAbsJsonParser parser;
   CAbsJsonValue value;

   if(!AssertTrue(parser.Parse(RegBuildNestedArrays(100),value),"Depth 100 must be accepted."))
      return false;

   if(parser.Parse(RegBuildNestedArrays(AbsJsonConst::MAX_DEPTH+50),value))
     {
      Print("Excessive depth was accepted.");
      return false;
     }

   CAbsJsonStatus status;

   parser.GetStatus(status);

   return AssertEqual((int)ABS_JSON_ERROR_DEPTH_EXCEEDED,(int)status.Code(),"Depth error code is incorrect.");
  }

/** @brief Parser errors must carry line / column / position. */
bool TestRegErrorPosition()
  {
   CAbsJsonParser parser;
   CAbsJsonValue value;

   if(parser.Parse("{\n  \"a\": }",value))
      return false;

   CAbsJsonStatus status;

   parser.GetStatus(status);

   if(!AssertEqual(2,status.Line(),"Error line is incorrect."))
      return false;

   if(!AssertTrue(status.Column()>1,"Error column was not recorded."))
      return false;

   return AssertTrue(status.Position()>0,"Error position was not recorded.");
  }

/** @brief Duplicate property names must produce ABS_JSON_ERROR_DUPLICATE_PROPERTY. */
bool TestRegDuplicateErrorCode()
  {
   CAbsJsonParser parser;
   CAbsJsonValue value;

   if(parser.Parse("{\"a\":1,\"a\":2}",value))
      return false;

   CAbsJsonStatus status;

   parser.GetStatus(status);

   return AssertEqual((int)ABS_JSON_ERROR_DUPLICATE_PROPERTY,(int)status.Code(),"Duplicate error code is incorrect.");
  }

/** @brief A leading byte-order mark is tolerated. */
bool TestRegByteOrderMark()
  {
   CAbsJsonParser parser;
   CAbsJsonValue value;

   string text=ShortToString(0xFEFF)+"{\"a\":1}";

   return AssertTrue(parser.Parse(text,value),"Text with a BOM was rejected.");
  }

/** @brief CAbsJsonNumber validation and range helpers. */
bool TestRegNumberUtils()
  {
   if(!AssertTrue(CAbsJsonNumber::Validate("-0.5e+3"),"Valid number rejected."))
      return false;

   string invalid[]={"","-","+1","007",".5","5.","1e","1e+","0x10","NaN","1.2.3"};

   for(int i=0;i<ArraySize(invalid);i++)
      if(!AssertFalse(CAbsJsonNumber::Validate(invalid[i]),"Invalid number accepted: "+invalid[i]))
         return false;

   if(!AssertTrue(CAbsJsonNumber::IsInteger("-12"),"IsInteger failed."))
      return false;

   if(!AssertFalse(CAbsJsonNumber::IsInteger("1.0"),"IsInteger accepted a double."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::IsDouble("1e3"),"IsDouble failed."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::IsLong("9223372036854775807"),"Max long rejected."))
      return false;

   if(!AssertFalse(CAbsJsonNumber::IsLong("9223372036854775808"),"Long overflow accepted."))
      return false;

   if(!AssertTrue(CAbsJsonNumber::IsLong("-9223372036854775808"),"Min long rejected."))
      return false;

   int i32;

   if(!AssertFalse(CAbsJsonNumber::ParseInteger("2147483648",i32),"ParseInteger accepted a value outside int."))
      return false;

   return AssertTrue(CAbsJsonNumber::ParseInteger("-2147483648",i32) && i32==-2147483647-1,"ParseInteger min int failed.");
  }

/** @brief CAbsJsonEscape helpers. */
bool TestRegEscapeUtils()
  {
   string raw="q\"b\\s/"+ShortToString(9)+ShortToString(10)+ShortToString(2);

   string escaped=CAbsJsonEscape::Escape(raw);

   if(!AssertEqual("q\\\"b\\\\s/\\t\\n\\u0002",escaped,"Escape output is incorrect."))
      return false;

   if(!AssertEqual(raw,CAbsJsonEscape::Unescape(escaped),"Unescape did not restore the text."))
      return false;

   if(!AssertEqual("plain",CAbsJsonEscape::Escape("plain"),"Plain text must be unchanged."))
      return false;

   if(!AssertEqual("\\u00E9",CAbsJsonEscape::EscapeUnicode(ShortToString(0xE9)),"EscapeUnicode is incorrect."))
      return false;

   // Malformed \u escape is kept, not silently dropped.
   return AssertEqual("\\uZZZZ",CAbsJsonEscape::Unescape("\\uZZZZ"),"Malformed unicode escape handling is incorrect.");
  }

/** @brief Surrogate pairs and escaped unicode must round trip. */
bool TestRegSurrogatePair()
  {
   CAbsJsonParser parser;
   CAbsJsonValue value;

   if(!parser.Parse("\"\\uD83D\\uDE00\"",value))
      return false;

   string text=value.GetString();

   if(!AssertEqual(2,StringLen(text),"Surrogate pair must give two UTF-16 units."))
      return false;

   CAbsJsonWriter writer;

   return AssertEqual(text,ShortToString(0xD83D)+ShortToString(0xDE00),"Surrogate pair content is incorrect.")
          && AssertEqual("\""+text+"\"",writer.Write(value),"Surrogate pair output is incorrect.");
  }

/** @brief Removing, inserting and overwriting must keep ownership consistent. */
bool TestRegContainerEditing()
  {
   CAbsJsonObject object;

   if(!AssertTrue(object.Set("a",1) && object.Set("b","x") && object.Set("a",2),"Set failed."))
      return false;

   if(!AssertEqual(2,object.Count(),"Set must overwrite an existing name."))
      return false;

   if(!AssertEqual(2,object.GetInteger("a"),"Overwritten value is incorrect."))
      return false;

   if(!AssertTrue(object.Remove("a"),"Remove failed."))
      return false;

   if(!AssertEqual(1,object.Count(),"Count after Remove is incorrect."))
      return false;

   CAbsJsonArray array;

   array.Add(1);
   array.Add("two");
   array.AddNull();

   CAbsJsonValue *inserted=new CAbsJsonValue();

   inserted.SetBoolean(true);

   if(!AssertTrue(array.Insert(1,inserted),"Insert failed."))
     {
      delete inserted;
      return false;
     }

   if(!AssertEqual("[1,true,\"two\",null]",array.ToString(),"Array after Insert is incorrect."))
      return false;

   if(!AssertTrue(array.Remove(0),"Array Remove failed."))
      return false;

   return AssertFalse(array.Remove(10),"Remove out of range must fail.");
  }

/** @brief Many parse / write / clone cycles must stay consistent (memory smoke test). */
bool TestRegRepeatedCycles()
  {
   string source="{\"a\":[1,2,{\"b\":\"c\"}],\"d\":{\"e\":null,\"f\":1.5}}";

   for(int i=0;i<300;i++)
     {
      CAbsJson json;
      CAbsJson copy;

      if(!json.Parse(source))
         return false;

      if(!json.Clone(copy))
         return false;

      if(copy.Minify()!=source)
        {
         Print("Cycle ",i," produced different output: ",copy.Minify());
         return false;
        }
     }

   return true;
  }

/** @brief Files are stored as UTF-8 and read back unchanged. */
bool TestRegUtf8File()
  {
   CAbsJson source;
   CAbsJson target;

   string name=ShortToString(0x0645)+ShortToString(0x4E16);

   if(!source.Parse("{\"k\":\"x\"}"))
      return false;

   source.Root().GetObject().Set("name",name);

   string filename="AbsJsonRegressionUtf8.json";

   if(!AssertTrue(source.SaveFile(filename),"SaveFile failed."))
      return false;

   bool loaded=target.LoadFile(filename);

   FileDelete(filename,FILE_COMMON);

   if(!AssertTrue(loaded,"LoadFile failed."))
      return false;

   return AssertEqual(name,target.Root().GetObject().GetString("name"),"UTF-8 file round trip is incorrect.");
  }

/** @brief Runs the regression tests. */
void RunTestRegression()
  {
   RunTest("Regression Control Characters",TestRegControlCharacters());
   RunTest("Regression Double Round Trip",TestRegDoubleRoundTrip());
   RunTest("Regression Nested ToString",TestRegNestedToString());
   RunTest("Regression Object GetArray",TestRegObjectGetArray());
   RunTest("Regression Depth Limit",TestRegDepthLimit());
   RunTest("Regression Error Position",TestRegErrorPosition());
   RunTest("Regression Duplicate Error Code",TestRegDuplicateErrorCode());
   RunTest("Regression Byte Order Mark",TestRegByteOrderMark());
   RunTest("Regression Number Utils",TestRegNumberUtils());
   RunTest("Regression Escape Utils",TestRegEscapeUtils());
   RunTest("Regression Surrogate Pair",TestRegSurrogatePair());
   RunTest("Regression Container Editing",TestRegContainerEditing());
   RunTest("Regression Repeated Cycles",TestRegRepeatedCycles());
   RunTest("Regression UTF-8 File",TestRegUtf8File());
  }
//+------------------------------------------------------------------+
