[English](README.md) | [فارسی](README.fa.md)

# AbsJson

یک کتابخانهٔ JSON برای **MQL5** (متاتریدر ۵): تجزیه (Parse)، ساخت، پرس‌وجو، ویرایش و نوشتن اسناد JSON، همراه با مدل شیءگرا، گزارش خطا با شمارهٔ خط و ستون، کپی عمیق و ورودی/خروجی فایل با UTF-8.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/MetaTrader-5-informational)

**نسخهٔ 1.0.0** · انتشار ۲۰۲۶-۰۹-۲۱ (2026-09-21) · تگ Git: `v1.0.0` · وب‌سایت رسمی: <https://mql5.ab-studio.ir>

- **یک include کافی است:** `#include <AbsJson/AbsJson.mqh>`
- **بدون وابستگی** به‌جز کتابخانهٔ استاندارد MQL5 (`CObject` و `CArrayObj`).
- **بدون استثنا (Exception):** همهٔ خطاها از طریق یک شیء وضعیت (`CAbsJsonStatus`) گزارش می‌شوند.
- **تست‌شده:** ۹۵ تست واحد در `Scripts/TestAbsJson`؛ همگی در اجرایی با MetaTrader 5 Build 6257 موفق بوده‌اند (بخش [تست](#tests) را ببینید).
- **دارای مجوز MIT.**

---

## فهرست مطالب

1. [ویژگی‌ها](#features)
2. [پیش‌نیازها](#requirements)
3. [نصب](#installation)
4. [شروع سریع](#quick-start)
5. [نمونه‌های استفاده](#usage-examples)
6. [مرور API](#api-overview)
7. [رفتار کتابخانه و تطابق با JSON](#behavior)
8. [قواعد مالکیت حافظه](#ownership)
9. [مدیریت خطا](#errors)
10. [محدودیت‌ها](#limitations)
11. [ساختار پروژه](#structure)
12. [تست](#tests)
13. [مشارکت](#contributing)
14. [تاریخچهٔ تغییرات](#changelog)
15. [مجوز](#license)
16. [وب‌سایت رسمی](#website)

---

<a id="features"></a>

## ویژگی‌ها

- **تجزیه‌گر (Parser)** مطابق گرامر RFC 8259: شیء، آرایه، رشته (با همهٔ escapeها از جمله `\uXXXX`)، عدد، `true`، `false` و `null`.
- **نویسنده (Writer)** با خروجی فشرده (`Minify`) و تورفته (`PrettyPrint`).
- **مدل مقدار تایپ‌دار:** `null`، رشته، عدد صحیح (۳۲ بیتی)، long (۶۴ بیتی)، double، منطقی، شیء و آرایه.
- **ویرایش شیء و آرایه:** `Set`، `Add`، `Insert`، `Remove`، گیرنده‌های (getter) تایپ‌دار، `FindProperty` و `Contains`.
- **اشیاء دارای ایندکس هش:** اشیایی که ۱۶ ویژگی یا بیشتر دارند برای جست‌وجوی سریع از ایندکس هش استفاده می‌کنند.
- **خطای دقیق:** کد خطا، پیام، شمارهٔ خط، شمارهٔ ستون و موقعیت کاراکتر.
- **کپی عمیق** مقدار، شیء، آرایه و کل سند (`CopyFrom` / `Clone`، سازندهٔ کپی و عملگر `=` در `CAbsJsonValue`).
- **اعتبارسنجی** متن JSON بدون تغییر سند فعلی.
- **ورودی/خروجی فایل** در پوشهٔ مشترک (Common) ترمینال: ذخیره با UTF-8 بدون BOM؛ بارگذاری UTF-8 (با یا بدون BOM) و UTF-16 LE (با BOM).
- **اعداد double با بازگشت دقیق** (`%.15g` و در صورت نیاز `%.17g`)؛ مقدار NaN و بی‌نهایت به صورت `null` نوشته می‌شود.
- **محدودیت عمق تو در تو** (۲۵۶ سطح) برای جلوگیری از سرریز پشته.
- **ابزارهای کمکی:** `CAbsJsonNumber` (اعتبارسنجی سخت‌گیرانهٔ عدد و تشخیص نوع) و `CAbsJsonEscape` (escape / unescape).
- **رابط سریال‌سازی:** `CAbsJsonSerializable` برای کلاس‌های خودتان.

<a id="requirements"></a>

## پیش‌نیازها

| پیش‌نیاز | جزئیات |
|---|---|
| پلتفرم | MetaTrader 5 |
| ویرایشگر | MetaEditor 5 |
| کامپایلر | کامپایلر MQL5 (کد از `#property strict` استفاده می‌کند) |
| آزمایش‌شده با | **MetaTrader 5 Build 6257** |

Build 6257 محیطی است که کتابخانه و مجموعهٔ تست آن در آن راستی‌آزمایی شده‌اند. این عدد **حداقل بیلد پشتیبانی‌شده نیست**: بیلدهای دیگر آزمایش نشده‌اند و حداقل بیلد پشتیبانی‌شده‌ای تعیین نشده است. اگر از بیلد دیگری استفاده می‌کنید، لطفاً نتیجه را گزارش دهید (به [CONTRIBUTING.md](CONTRIBUTING.md) نگاه کنید).

<a id="installation"></a>

## نصب

۱. پوشهٔ داده‌های متاتریدر ۵ را باز کنید (**File → Open Data Folder**).
۲. پوشهٔ `Include/AbsJson` را در `MQL5/Include/` کپی کنید، به‌طوری که فایل
   `MQL5/Include/AbsJson/AbsJson.mqh` وجود داشته باشد.
۳. (اختیاری) پوشهٔ `Scripts/TestAbsJson` را برای دریافت مجموعهٔ تست در `MQL5/Scripts/` کپی کنید.
۴. در کد خود بنویسید:

```cpp
#include <AbsJson/AbsJson.mqh>
```

فقط `AbsJson.mqh` را include کنید. این فایل همهٔ بخش‌های کتابخانه را به ترتیب لازم وارد می‌کند؛ برخی اعضا (مثلاً متدهای `ToString()` و موتور کپی عمیق) در یک فایل اعلان و در فایل دیگری پیاده‌سازی شده‌اند، بنابراین include کردن هدرهای جداگانه پشتیبانی نمی‌شود.

<a id="quick-start"></a>

## شروع سریع

```cpp
#include <AbsJson/AbsJson.mqh>

void OnStart()
  {
   CAbsJson json;

   if(!json.Parse("{\"name\":\"Amir\",\"items\":[1,2,3]}"))
     {
      Print("Parse error: ",json.GetStatus().FullMessage());
      return;
     }

   CAbsJsonObject *root=json.Root().GetObject();

   Print("name = ",root.GetString("name"));   // Amir
   Print(json.Minify());                      // {"name":"Amir","items":[1,2,3]}
   Print(json.PrettyPrint());                 // indented output
  }
```

<a id="usage-examples"></a>

## نمونه‌های استفاده

### تجزیه و خواندن مقادیر

```cpp
CAbsJson json;

if(json.Parse("{\"user\":{\"name\":\"Amir\",\"age\":38},\"tags\":[\"a\",\"b\"]}"))
  {
   CAbsJsonObject *root=json.Root().GetObject();

   CAbsJsonProperty *user=root.FindProperty("user");

   if(user!=NULL && user.IsObject())
     {
      CAbsJsonObject *userObject=user.Value().GetObject();

      Print(userObject.GetString("name"));    // Amir
      Print(userObject.GetInteger("age"));    // 38
     }

   CAbsJsonProperty *tags=root.FindProperty("tags");

   if(tags!=NULL && tags.IsArray())
     {
      CAbsJsonArray *array=tags.Value().GetArray();

      for(int i=0;i<array.Count();i++)
         Print(array.GetString(i));
     }
  }
```

گیرنده‌های تایپ‌دار هیچ‌وقت شکست نمی‌خورند: اگر ویژگی یا اندیس وجود نداشته باشد یا نوع دیگری داشته باشد، مقدار `""`، `0`، `0.0` یا `false` برمی‌گردانند. برای تشخیص این حالت‌ها از `Contains()` / `FindProperty()` / `JsonType()` استفاده کنید.

### ساخت سند

```cpp
CAbsJson json;

CAbsJsonObject *root=new CAbsJsonObject();

root.Set("symbol","EURUSD");
root.Set("lots",0.1);
root.Set("active",true);

CAbsJsonArray *levels=new CAbsJsonArray();

levels.Add(1.0850);
levels.Add(1.0900);
levels.AddNull();

root.SetArray("levels",levels);   // root takes ownership of 'levels'

json.Root().SetObject(root);      // the document takes ownership of 'root'

Print(json.PrettyPrint(2));
```

### قالب‌های خروجی

```cpp
string compact=json.Minify();                      // same as json.ToString()
string pretty =json.PrettyPrint();                 // 4 spaces per level (line breaks are "\r\n")
string pretty2=json.PrettyPrint(2);                // 2 spaces per level
string byEnum =json.ToString(ABS_JSON_PRETTY,2);   // enumeration-based variant
```

### اعتبارسنجی بدون تغییر سند

```cpp
CAbsJson json;

if(!json.Validate("{\"a\":}"))
   Print(json.GetStatus().FullMessage());
// Unexpected token. (Line=1, Column=6, Position=5)
```

### ذخیره و بارگذاری فایل

فایل‌ها در پوشهٔ **مشترک** ترمینال ذخیره می‌شوند (`FILE_COMMON`، یعنی `Terminal\Common\Files`).

```cpp
CAbsJson json;

json.Parse("{\"a\":1}");

if(!json.SaveFile("settings.json",true))      // true = pretty
   Print(json.GetStatus().FullMessage());

CAbsJson loaded;

if(!loaded.LoadFile("settings.json"))
   Print(loaded.GetStatus().FullMessage());
```

### کپی

```cpp
CAbsJson copy;
json.Clone(copy);                  // independent deep copy of the document

CAbsJsonValue a;
a.CopyFrom(*json.Root());          // deep copy of a value
CAbsJsonValue b(a);                 // copy constructor: deep copy
b=a;                               // assignment: deep copy
```

### پیاده‌سازی `CAbsJsonSerializable`

```cpp
#include <AbsJson/AbsJsonSerializable.mqh>

class CPerson : public CAbsJsonSerializable
  {
public:
   string Name;
   int    Age;

   virtual bool Serialize(CAbsJson &json) const
     {
      json.Clear();

      CAbsJsonObject *object=new CAbsJsonObject();

      if(object==NULL)
         return false;

      if(!object.Set("Name",Name) || !object.Set("Age",Age))
        {
         delete object;
         return false;
        }

      json.Root().SetObject(object);
      return true;
     }

   virtual bool Deserialize(const CAbsJson &json)
     {
      const CAbsJsonValue *root=json.Root();

      if(root.JsonType()!=ABS_JSON_OBJECT)
         return false;

      const CAbsJsonObject *object=root.GetObject();

      if(object==NULL || !object.HasProperty("Name") || !object.HasProperty("Age"))
         return false;

      Name=object.GetString("Name");
      Age=object.GetInteger("Age");
      return true;
     }
  };
```

خود کتابخانه این متدها را فراخوانی نمی‌کند؛ این رابط فقط یک قرارداد مشترک برای کلاس‌های شما تعریف می‌کند.

### ابزارهای عدد و escape

```cpp
CAbsJsonNumber::Validate("-0.5e+3");        // true  (strict RFC 8259 grammar)
CAbsJsonNumber::Validate("007");            // false
CAbsJsonNumber::IsLong("9223372036854775807");   // true

ENUM_ABS_JSON_NUMBER_TYPE type;
CAbsJsonNumber::GetNumberType("2147483648",type); // true, type == ABS_JSON_NUMBER_LONG

string escaped=CAbsJsonEscape::Escape("a\"b");    // a\"b
string raw    =CAbsJsonEscape::Unescape(escaped);
```

<a id="api-overview"></a>

## مرور API

نام همهٔ کلاس‌ها با `CAbsJson` شروع می‌شود. توضیحات به سبک Doxygen در هدرها همهٔ پارامترها، مقادیر بازگشتی و شرایط شکست را شرح می‌دهند.

### `CAbsJson` — نمای (Facade) سند (`AbsJson.mqh`)

| عضو | توضیح |
|---|---|
| `Parse(text)` | متن را در `Root()` تجزیه می‌کند. در صورت شکست، ریشه خالی و وضعیت تنظیم می‌شود. |
| `Root()` | مقدار ریشهٔ سند (`CAbsJsonValue`، هرگز `NULL` نیست). |
| `IsValid()` | پس از `Parse` / `LoadFile` موفق `true` است. |
| `GetStatus()` | وضعیت آخرین `Parse`، `Validate(text)`، `SaveFile` یا `LoadFile`. |
| `Validate(text)` / `Validate()` | بررسی متن بدون تغییر `Root()` / برگرداندن `IsValid()`. |
| `ToString()` / `Minify()` | JSON فشرده. |
| `ToString(format, indent)` | خروجی فشرده یا تورفته با `ENUM_ABS_JSON_FORMAT`. |
| `PrettyPrint(indent=4)` | JSON تورفته. |
| `Clone(target)` | کپی عمیق و مستقل از سند. |
| `Clear()` | سند را خالی می‌کند. |
| `SaveFile(name, pretty=false)` / `LoadFile(name)` | ورودی/خروجی فایل با UTF-8 در پوشهٔ مشترک. |

### `CAbsJsonValue` — یک مقدار JSON

`JsonType()`، `IsNull/IsString/IsInteger/IsLong/IsDouble/IsBoolean/IsObject/IsArray()`، `SetNull/SetString/SetInteger/SetLong/SetDouble/SetBoolean/SetObject/SetArray()`، `GetString/GetInteger/GetLong/GetDouble/GetBoolean/GetObject/GetArray()`، `CopyFrom()`، `Clone()`، `ToString()`، `SetValue(type, text)`، `Clear()`.

### `CAbsJsonObject` — شیء JSON (به ترتیب درج، نام‌های یکتا)

| عضو | توضیح |
|---|---|
| `Set(name, value)` | ویژگی را می‌سازد یا بازنویسی می‌کند (`string`، `int`، `long`، `double`، `bool`). |
| `SetObject(name, obj)` / `SetArray(name, arr)` | شیء / آرایه را ذخیره می‌کند؛ مالکیت منتقل می‌شود. |
| `GetString/GetInteger/GetLong/GetDouble/GetBoolean(name)` | گیرنده‌های تایپ‌دار با مقدار پیش‌فرض. |
| `GetObject(name, target)` / `GetArray(name, target)` | کپی عمیق یک فرزند در `target`. |
| `FindProperty(name)`، `Contains(name)`، `HasProperty(name)`، `IndexOf(name)` | جست‌وجو. |
| `GetProperty(index)`، `Count()`، `IsEmpty()` | پیمایش. |
| `Remove(name)` / `Remove(index)` | حذف یک ویژگی. |
| `AddProperty(p)` / `SetProperty(p)` | درج سطح پایین (قواعد مالکیت را ببینید). |
| `CopyFrom()`، `Clone()`، `ToString(pretty=false)`، `Clear()` | کپی، خروجی، بازنشانی. |

### `CAbsJsonArray` — آرایهٔ JSON

`Add(string/int/long/double/bool)`، `AddNull()`، `AddObject()`، `AddArray()`، `Insert(index, value)`، `Item(index)`، `GetString/GetInteger/GetLong/GetDouble/GetBoolean(index)`، `GetObject(index, target)`، `GetArray(index, target)`، `Remove(index)`، `Count()`، `IsEmpty()`، `CopyFrom()`، `Clone()`، `ToString(pretty=false)`، `Clear()`.

### `CAbsJsonProperty`

یک عضو نام/مقدار از شیء: `Name()`، `SetName()` (اگر نام در شیء مالک تکراری باشد `false` برمی‌گرداند)، `Value()` و همان توابع `Is…` / `Set…` / `Get…` که در `CAbsJsonValue` وجود دارند.

### `CAbsJsonParser` و `CAbsJsonWriter`

به‌صورت داخلی توسط Facade استفاده می‌شوند و مستقیماً هم در دسترس‌اند:

```cpp
CAbsJsonParser parser;
CAbsJsonValue value;

if(!parser.Parse(text,value))
  {
   CAbsJsonStatus status;
   parser.GetStatus(status);
   Print(status.FullMessage());
  }

CAbsJsonWriter writer;
writer.SetFormat(ABS_JSON_PRETTY);
writer.SetIndentSize(2);
string json=writer.Write(value);
```

`parser.Parse(text, CAbsJsonObject&)` و `parser.Parse(text, CAbsJsonArray&)` علاوه بر تجزیه، الزام می‌کنند که مقدار سطح بالا شیء / آرایه باشد.

### ابزارهای کمکی

- `CAbsJsonNumber`: `Validate`، `IsInteger`، `IsLong`، `IsDouble`، `IsNumber`، `FitsInLong`، `GetNumberType`، `ParseInteger`، `ParseLong`، `ParseDouble`، `IntegerToJson`، `LongToJson`، `DoubleToJson`.
- `CAbsJsonEscape`: `Escape`، `Unescape`، `EscapeUnicode`، `NeedEscape`، `UnicodeEscape`، `HexToUShort`، `UShortToHex`.
- `AbsJsonTypeToString(type)` و `AbsJsonErrorToString(code)`.
- ثابت‌ها در فضای نام `AbsJsonConst`: `DEFAULT_INDENT` (برابر ۴) و `MAX_DEPTH` (برابر ۲۵۶).

### انواع مقدار

| `ENUM_ABS_JSON_TYPE` | زمان ذخیره‌شدن |
|---|---|
| `ABS_JSON_NULL` | `null` |
| `ABS_JSON_STRING` | رشته |
| `ABS_JSON_INTEGER` | عدد صحیحی که در `int` ۳۲ بیتی جا شود |
| `ABS_JSON_LONG` | عدد صحیحی که به `long` ۶۴ بیتی نیاز دارد |
| `ABS_JSON_DOUBLE` | عددی با بخش اعشاری و/یا توان |
| `ABS_JSON_BOOLEAN` | `true` / `false` |
| `ABS_JSON_OBJECT` / `ABS_JSON_ARRAY` | ظرف‌ها |

<a id="behavior"></a>

## رفتار کتابخانه و تطابق با JSON

تجزیه‌گر گرامر RFC 8259 را هدف گرفته است. مجموعهٔ تست اسناد معتبر و نامعتبر را پوشش می‌دهد، اما یک آزمون رسمی تطابق نیست؛ بنابراین ادعای انطباق کامل نمی‌شود.

**پذیرفته می‌شود:** شیء، آرایه، رشته با همهٔ escapeها، عدد (`-`، بخش اعشاری، توان)، `true`/`false`/`null`، فاصله‌های خالی (space، tab، CR، LF)، هر مقدار در سطح بالا و BOM ابتدایی U+FEFF (نادیده گرفته می‌شود).

**با خطا رد می‌شود:**

- متن خالی یا فقط فاصلهٔ خالی؛
- کاراکترهای اضافی بعد از مقدار سطح بالا؛
- ویرگول انتهایی، توضیح (comment)، رشتهٔ تک‌نقل‌قولی، نام بدون نقل‌قول؛
- کاراکترهای کنترلی خام (کوچک‌تر از U+0020) داخل رشته؛
- عدد با `+` ابتدایی، صفر ابتدایی، `.5`، `5.`، `NaN`، `Infinity`؛
- عدد صحیح خارج از بازهٔ ۶۴ بیتی علامت‌دار و double سرریز شده؛
- **نام ویژگی تکراری** در یک شیء (انتخاب آگاهانهٔ کتابخانه؛ RFC 8259 فقط می‌گوید نام‌ها *باید* یکتا باشند)؛
- تو در تویی عمیق‌تر از ۲۵۶ سطح.

**رفتارهای ویژهٔ کتابخانه:**

- اعداد صحیح به `ABS_JSON_INTEGER` / `ABS_JSON_LONG` نگاشت می‌شوند؛ هر عددی با بخش اعشاری یا توان `ABS_JSON_DOUBLE` می‌شود. مقدار `-0` به عدد صحیح `0` تبدیل می‌شود.
- double بدون بخش اعشاری بدون ممیز نوشته می‌شود (`5.0` ← `5`) و در خواندن مجدد از نوع صحیح خواهد بود.
- NaN و ±بی‌نهایت در JSON قابل نمایش نیستند و به صورت `null` نوشته می‌شوند.
- رشته‌ها در MQL5 از نوع UTF-16 هستند. جفت جانشین (surrogate pair) که با دو `\uXXXX` نوشته شده باشد کاراکتر درست را می‌سازد؛ جانشین تنها حفظ می‌شود. `\u0000` در رشتهٔ MQL5 قابل ذخیره نیست و حذف می‌شود.
- نویسنده `"`، `\` و همهٔ کاراکترهای کنترلی کوچک‌تر از U+0020 را escape می‌کند؛ سایر کاراکترها (از جمله غیر ASCII) بدون تغییر نوشته می‌شوند. کاراکتر `/` escape نمی‌شود.
- خروجی تورفته از شکست خط `\r\n` و الگوی `": "` بعد از نام‌ها استفاده می‌کند.

<a id="ownership"></a>

## قواعد مالکیت حافظه

MQL5 زباله‌روب (Garbage Collector) ندارد، پس مالکیت صریح است:

- سند، مقدار، ویژگی، شیء یا آرایه **مالک همه چیزِ زیر خود است** و هنگام پاک‌سازی یا نابودی آن را آزاد می‌کند.
- `SetObject`، `SetArray`، `AddObject` و `AddArray` **مالکیت** اشاره‌گری را که می‌دهید می‌گیرند. شیئی که با `new` در heap ساخته شده باشد بدهید؛ نه شیء روی پشته و نه شیئی که جای دیگری مالک دارد. بعد از آن `delete` نکنید.
- `AddProperty` / `AddItem` / `Insert` فقط وقتی `true` برگردانند مالکیت را می‌گیرند؛ در صورت `false` هنوز اشاره‌گر مال شماست.
- اشاره‌گرهای برگشتی از `Root()`، `FindProperty()`، `GetProperty()`، `Item()`، `GetObject()` و `GetArray()` در مالکیت کتابخانه می‌مانند. با حذف عنصر، پاک‌سازی یا نابودی ظرف، و پس از `Parse()` / `Clear()` روی سند نامعتبر می‌شوند.
- `GetObject(name, target)` / `GetArray(name, target)` در `CAbsJsonObject` / `CAbsJsonArray` در `target` کپی می‌کنند؛ مالک `target` شما هستید.
- برای کپی از `CopyFrom`، `Clone`، سازندهٔ کپی یا `=` (در `CAbsJsonValue`) استفاده کنید؛ همگی عمیق‌اند.

<a id="errors"></a>

## مدیریت خطا

هیچ استثنایی پرتاب نمی‌شود. پس از `Parse`، `Validate(text)`، `SaveFile` یا `LoadFile` وضعیت را بخوانید:

```cpp
if(!json.Parse(text))
  {
   const CAbsJsonStatus *status=json.GetStatus();

   Print(status.Code());         // ENUM_ABS_JSON_ERROR
   Print(status.Message());
   Print(status.Line()," ",status.Column()," ",status.Position());
   Print(status.FullMessage());  // "<message> (Line=L, Column=C, Position=P)"
  }
```

کدهایی که کتابخانه واقعاً تولید می‌کند:

| کد | زمان بروز |
|---|---|
| `ABS_JSON_ERROR_EMPTY_DOCUMENT` | متن خالی یا فقط فاصلهٔ خالی است. |
| `ABS_JSON_ERROR_UNEXPECTED_END` | متن وسط یک ساختار تمام می‌شود. |
| `ABS_JSON_ERROR_UNEXPECTED_TOKEN` | کاراکتر نمی‌تواند شروع یک مقدار باشد. |
| `ABS_JSON_ERROR_INVALID_JSON` | کاراکتر اضافی بعد از مقدار سطح بالا. |
| `ABS_JSON_ERROR_INVALID_CHARACTER` | کاراکتر کنترلی خام در رشته. |
| `ABS_JSON_ERROR_INVALID_ESCAPE_SEQUENCE` | escape ناشناختهٔ بک‌اسلش. |
| `ABS_JSON_ERROR_INVALID_UNICODE` | `\uXXXX` نادرست. |
| `ABS_JSON_ERROR_INVALID_NUMBER` | عدد نادرست، سرریز عدد صحیح یا double خارج از بازه. |
| `ABS_JSON_ERROR_INVALID_BOOLEAN` / `ABS_JSON_ERROR_INVALID_NULL` | لیترال نادرست. |
| `ABS_JSON_ERROR_EXPECT_OBJECT` / `ABS_JSON_ERROR_EXPECT_ARRAY` | `{` / `[` وجود ندارد یا نوع سطح بالا برای overloadهای تایپ‌دار `Parse` اشتباه است. |
| `ABS_JSON_ERROR_EXPECT_STRING` | نام ویژگی رشته نیست. |
| `ABS_JSON_ERROR_EXPECT_COLON` / `ABS_JSON_ERROR_EXPECT_COMMA` | `:` / `,` (یا کروشهٔ بستن) وجود ندارد. |
| `ABS_JSON_ERROR_DUPLICATE_PROPERTY` | یک نام دو بار در یک شیء آمده است. |
| `ABS_JSON_ERROR_DEPTH_EXCEEDED` | تو در تویی عمیق‌تر از ۲۵۶ سطح. |
| `ABS_JSON_ERROR_OUT_OF_MEMORY` | تخصیص حافظه یا کپی داخلی شکست خورد. |
| `ABS_JSON_ERROR_IO` | فایل باز، خوانده یا نوشته نشد. |

در enum کدهای `UNKNOWN`، `INVALID_STRING`، `INVALID_ESCAPE`، `NOT_IMPLEMENTED`، `EXPECT_PROPERTY`، `EXPECT_VALUE`، `PROPERTY_NOT_FOUND`، `INDEX_OUT_OF_RANGE` و `TYPE_MISMATCH` هم تعریف شده‌اند، اما کتابخانه فعلاً آن‌ها را تولید نمی‌کند.

<a id="limitations"></a>

## محدودیت‌ها

- کل سند در حافظه نگه‌داری می‌شود؛ تجزیه‌گر یا نویسندهٔ جریانی (streaming) وجود ندارد.
- JSON Pointer / JSON Path، اعتبارسنجی با Schema، توضیح (comment) و JSON5 پشتیبانی نمی‌شود.
- اعداد صحیح خارج از بازهٔ ۶۴ بیتی علامت‌دار رد می‌شوند (پشتیبانی از اعداد بزرگ وجود ندارد).
- گیرنده‌های تایپ‌دار به‌جای گزارش ناسازگاری نوع، مقدار پیش‌فرض برمی‌گردانند.
- حذف یک ویژگی از شیء از مرتبهٔ O(n) است.
- قالب خروجی تورفته ثابت است (فقط اندازهٔ تورفتگی قابل تنظیم است).
- کپی عمیق و نابودی به‌صورت بازگشتی انجام می‌شوند؛ محدودیت ۲۵۶ سطح برای تجزیه است، نه برای ساختارهایی که خودتان دستی می‌سازید.
- API فایل فقط در پوشهٔ مشترک ترمینال کار می‌کند.

<a id="structure"></a>

## ساختار پروژه

```
Include/AbsJson/
├── AbsJson.mqh                 # entry point + CAbsJson facade
├── AbsJsonSerializable.mqh     # CAbsJsonSerializable interface
├── Core/
│   ├── AbsJsonTypes.mqh        # enums, constants, helper functions
│   ├── AbsJsonStatus.mqh       # CAbsJsonStatus (error / location)
│   ├── AbsJsonBase.mqh         # CAbsJsonBase (status holder)
│   ├── AbsJsonNode.mqh         # CAbsJsonNode (child storage and ownership)
│   ├── AbsJsonValue.mqh        # CAbsJsonValue
│   └── AbsJsonProperty.mqh     # CAbsJsonProperty
├── Objects/
│   ├── AbsJsonObject.mqh       # CAbsJsonObject (with hash index)
│   └── AbsJsonArray.mqh        # CAbsJsonArray
├── Internal/
│   ├── AbsJsonClone.mqh        # CAbsJsonClone declarations
│   └── AbsJsonCloneImpl.mqh    # deep-copy implementation
├── IO/
│   ├── AbsJsonParser.mqh       # CAbsJsonParser
│   └── AbsJsonWriter.mqh       # CAbsJsonWriter + ToString() implementations
└── Utils/
    ├── AbsJsonEscape.mqh       # CAbsJsonEscape
    └── AbsJsonNumber.mqh       # CAbsJsonNumber

Scripts/TestAbsJson/
├── TestAbsJson.mq5             # test runner (OnStart) + usage examples
├── TestBase.mqh, TestHelper.mqh
└── Test*.mqh                   # test groups (parse, write, round trip, clone, value, clear,
                                #   facade, regression, extended)
```

<a id="tests"></a>

## تست

### وضعیت راستی‌آزمایی‌شده

| مورد | وضعیت |
|---|---|
| مجموعهٔ تست | `Scripts/TestAbsJson/TestAbsJson.mq5` — ۹۵ تست ثبت‌شده |
| نتیجه | **۹۵ موفق، ۰ ناموفق** |
| محیط | MetaTrader 5 Build 6257 |
| گزارش‌دهنده | نگه‌دارندهٔ پروژه، از اجرای کامل مجموعه در متاتریدر ۵ |

مجموعهٔ کامل تست دوباره توسط نگه‌دارندهٔ پروژه اجرا شده است؛ لاگ کامل تب Experts نشان می‌دهد هر ۹۵ تست موفق بوده‌اند (`Passed : 95` و `Failed : 0`) و پس از آن خروجی نمونه‌های استفادهٔ اجراکنندهٔ تست نسخهٔ 1.0.0 آمده است. خود لاگ شمارهٔ بیلد ترمینال را ثبت نمی‌کند، بنابراین شمارهٔ بیلد بالا همان است که نگه‌دارنده اعلام کرده است. محیط تهیهٔ مستندات MetaTrader 5 / MetaEditor ندارد؛ پس این نتایج را نگه‌دارنده گزارش کرده و ابزار مستندسازی آن‌ها را اجرا نکرده است. بازبینی ایستای فایل‌های تست نشان داد تعداد تست‌های ثبت‌شده (۹۵) با مجموع گزارش‌شده برابر است.

### تست‌ها چه چیزی را پوشش می‌دهند

| حوزه | فایل‌های تست | تعداد |
|---|---|---|
| مبانی تجزیه: شیء / آرایهٔ خالی، رشته، integer، long، double، منطقی، null، ورودی خالی، مقادیر ریشه، فاصلهٔ خالی | `TestParseBasic.mqh` | 12 |
| ساختارهای تجزیه: شیء، آرایه، تو در تو، انواع مختلط، تو در تویی عمیق، اسناد پیچیده | `TestParseStructures.mqh` | 10 |
| اعداد: منفی، نمایش علمی، سرریز، اعداد نامعتبر، اعداد مرزی و خاص | `TestParseNumbers.mqh` | 7 |
| رشته‌ها: escape، یونیکد، `\uXXXX`، escapeهای پشت‌سرهم، رد کاراکتر کنترلی | `TestParseStrings.mqh` | 5 |
| JSON نامعتبر: ویرگول انتهایی، چند مقدار ریشه، ریشهٔ نامعتبر، ویژگی تکراری | `TestParseInvalid.mqh` | 4 |
| سریال‌سازی: شیء خالی / ساده / تو در تو، آرایه، pretty print، کاراکترهای ویژه، یونیکد | `TestWrite.mqh` | 7 |
| رفت‌وبرگشت (Round trip): ساده، تو در تو، آرایه، پیچیده، رشتهٔ دارای escape، یونیکد | `TestRoundTrip.mqh` | 6 |
| کپی عمیق: شیء، آرایه، مقدار، استقلال | `TestClone.mqh` | 4 |
| setter / getter مقدار | `TestValue.mqh` | 2 |
| پاک‌سازی شیء و آرایه | `TestClear.mqh` | 2 |
| Facade: parse، root، minify، pretty print، clear، status، clone، validate، round trip، ورودی/خروجی فایل (ساده، pretty، یونیکد) | `TestAbsJsonFacade.mqh` | 14 |
| رگرسیون: کاراکترهای کنترلی، round trip عدد double، `ToString` تو در تو، `GetArray`، محدودیت عمق، موقعیت خطا، کد خطای تکرار، BOM، ابزارهای عدد / escape، surrogate pair، ویرایش ظرف، چرخه‌های تکراری، فایل UTF-8 | `TestRegression.mqh` | 14 |
| توسعه‌یافته: ایندکس هش اشیای بزرگ، parse / clone بزرگ، تغییر نام، انتساب مقدار، نوع عدد، قالب خروجی، قالب‌بندی double | `TestExtended.mqh` | 8 |

مدیریت خطا: تست‌های ورودی نامعتبر (ویرگول انتهایی، چند مقدار ریشه، ورودی خالی یا ناقص مانند `{` یا `]`، اعداد نامعتبر و سرریز شده، کاراکتر کنترلی در رشته، ویژگی تکراری) بررسی می‌کنند که تجزیه‌گر ورودی را **رد کند**. *کد* خطا فقط در تست‌های رگرسیون (محدودیت عمق، ویژگی تکراری) و *موقعیت* خطا فقط برای یک حالت (شمارهٔ خط یک توکن نابجا) بررسی می‌شود؛ تست‌های Facade وضعیت پس از شکست و خطاهای فایل را بررسی می‌کنند. حالت‌هایی مانند نبودن دونقطه، نبودن ویرگول، رشتهٔ بسته‌نشده، escape ناشناخته، `\uXXXX` نادرست یا لیترال نادرست (`tru`، `nul`) تست اختصاصی ندارند و هیچ تستی تک‌تک کدهای خطا را بررسی نمی‌کند. افزودن تست‌های اختصاصی برای آن‌ها مشارکتی مطلوب خواهد بود.

### اجرای تست‌ها

۱. `Include/AbsJson` و `Scripts/TestAbsJson` را در پوشهٔ `MQL5` خود کپی کنید.
۲. فایل `MQL5/Scripts/TestAbsJson/TestAbsJson.mq5` را در MetaEditor 5 باز و کامپایل کنید (F7).
۳. در متاتریدر ۵ اسکریپت `TestAbsJson` را روی یک چارت اجرا کنید.
۴. نتیجه را در تب **Experts** ببینید. خروجی با این خطوط تمام می‌شود:

```
Passed : 95
Failed : 0
```

تست‌های ورودی/خروجی فایل چند فایل موقت `.json` در پوشهٔ مشترک ترمینال (`Terminal\Common\Files`) می‌سازند؛ بیشتر آن‌ها توسط تست‌ها حذف می‌شوند و فایل‌های باقی‌مانده با نام `AbsJson_*.json` را می‌توان دستی پاک کرد. پس از خلاصهٔ نتایج، اجراکننده چند نمونهٔ استفاده چاپ می‌کند؛ یکی از آن‌ها عمداً JSON نامعتبر را تجزیه می‌کند و `Expected parse error : …` چاپ می‌کند.

<a id="contributing"></a>

## مشارکت

مشارکت‌ها خوش‌آمدند. لطفاً ابتدا [CONTRIBUTING.md](CONTRIBUTING.md) را بخوانید. مشارکت‌ها تحت مجوز MIT پروژه پذیرفته می‌شوند.

<a id="changelog"></a>

## تاریخچهٔ تغییرات

[CHANGELOG.md](CHANGELOG.md) را ببینید. انتشار فعلی: **1.0.0 (2026-09-21)**.

<a id="license"></a>

## مجوز

AbsJson تحت [مجوز MIT](LICENSE) منتشر شده است. Copyright (c) 2026 Amir Bagheri Studio.

<a id="website"></a>

## وب‌سایت رسمی

<https://mql5.ab-studio.ir>

---

Copyright (c) 2026 Amir Bagheri Studio — MIT License — <https://mql5.ab-studio.ir>
