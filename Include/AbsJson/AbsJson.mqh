//+------------------------------------------------------------------+
//|                                                    AbsJson.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

// Include guard: the file can be included several times safely.
#ifndef __ABS_JSON_MQH__
#define __ABS_JSON_MQH__

#property strict

//====================================================
// Core
//====================================================
#include "Core/AbsJsonTypes.mqh"
#include "Core/AbsJsonStatus.mqh"
#include "Core/AbsJsonBase.mqh"
#include "Core/AbsJsonNode.mqh"
#include "Core/AbsJsonValue.mqh"
#include "Core/AbsJsonProperty.mqh"

//====================================================
// Objects
//====================================================
#include "Objects/AbsJsonObject.mqh"
#include "Objects/AbsJsonArray.mqh"

//====================================================
// Internals
//====================================================
#include "Internal/AbsJsonCloneImpl.mqh"

//====================================================
// Utils
//====================================================
#include "Utils/AbsJsonEscape.mqh"
#include "Utils/AbsJsonNumber.mqh"

//====================================================
// IO
//====================================================
#include "IO/AbsJsonWriter.mqh"
#include "IO/AbsJsonParser.mqh"

/**
 * @file AbsJson.mqh
 * @brief Entry point of the AbsJson library: include this file only.
 *
 * It includes every part of the library in the correct order and defines the
 * CAbsJson facade. Parts that are declared in one file and implemented in another
 * (CAbsJsonClone, the ToString() methods) are only complete when this file is included.
 */

/**
 * @class CAbsJson
 * @brief Facade: a JSON document with parse, write, clone, validate and file operations.
 *
 * Typical use:
 * @code
 * #include <AbsJson/AbsJson.mqh>
 *
 * CAbsJson json;
 *
 * if(!json.Parse("{\"name\":\"Amir\",\"items\":[1,2,3]}"))
 *   {
 *    Print(json.GetStatus().FullMessage());
 *    return;
 *   }
 *
 * CAbsJsonObject *root=json.Root().GetObject();
 * Print(root.GetString("name"));       // Amir
 * Print(json.PrettyPrint(2));
 * @endcode
 *
 * The document owns its Root value and everything below it. Pointers obtained from
 * Root() become invalid after Clear(), Parse() or destruction.
 * Do not copy a CAbsJson with the assignment operator; use Clone().
 */
class CAbsJson
  {
private:

   /// Root value of the document (null for an empty document).
   CAbsJsonValue     m_root;

   /// true when m_root holds a successfully parsed (or cloned valid) document.
   bool              m_valid;

   /// Status of the last parse / validate / file operation.
   CAbsJsonStatus    m_status;

   /**
    * @brief Records an I/O error.
    * @param message  Error message.
    * @return Always false.
    */
   bool              IoError(
      const string message)
     {
      m_status.Error(ABS_JSON_ERROR_IO,message);

      return false;
     }

public:

   /** @brief Creates an empty document (Root is null, IsValid() is false). */
                     CAbsJson()
     {
      m_valid=false;
     }

   /** @brief Destructor. Releases the document. */
                    ~CAbsJson()
     {
      Clear();
     }

   /**
    * @brief Root value of the document.
    * @return Pointer to the root (never NULL). It is owned by the document.
    */
   CAbsJsonValue     *Root()
     {
      return &m_root;
     }

   /**
    * @brief Root value of the document, read-only.
    * @return Pointer to the root (never NULL). It is owned by the document.
    */
   const CAbsJsonValue *Root() const
     {
      return &m_root;
     }

   /**
    * @brief Empties the document.
    *
    * The root becomes null and IsValid() becomes false. The last status is left unchanged.
    */
   void              Clear()
     {
      m_root.Clear();

      m_valid=false;
     }

   /**
    * @brief Tells whether the document holds a successfully parsed document.
    * @return true after a successful Parse() / LoadFile() (or a Clone() of a valid document).
    * @note Building the root by hand through Root() does not set this flag.
    */
   bool              IsValid() const
     {
      return m_valid;
     }

   /**
    * @brief Status of the last Parse(), Validate(text), SaveFile() or LoadFile() call.
    * @return Pointer to the internal status; valid for the lifetime of the document.
    */
   const CAbsJsonStatus *GetStatus() const
     {
      return &m_status;
     }

   /**
    * @brief Parses JSON text and stores the result in Root.
    *
    * On success the document becomes valid and the status is cleared. On failure the root is
    * emptied, the document is invalid and the status describes the error
    * (code, message, line, column, position).
    *
    * @param text  JSON text (UTF-16 MQL5 string).
    * @return true on success.
    */
   bool              Parse(
      const string text)
     {
      CAbsJsonParser parser;

      m_root.Clear();

      m_valid=false;

      bool ok=parser.Parse(text,m_root);

      parser.GetStatus(m_status);

      if(!ok)
        {
         m_root.Clear();
         return false;
        }

      m_valid=true;

      return true;
     }

   /**
    * @brief Serializes the document as compact JSON (same as Minify()).
    * @return JSON text. A null root gives "null".
    */
   string            ToString()
     {
      CAbsJsonWriter writer;

      writer.SetPretty(false);

      return writer.Write(m_root);
     }

   /**
    * @brief Serializes the document in the given output mode.
    * @param format      ABS_JSON_MINIFY (compact) or ABS_JSON_PRETTY (indented).
    * @param indentSize  Spaces per level for ABS_JSON_PRETTY. Values <= 0 are ignored.
    * @return JSON text.
    */
   string            ToString(
      const ENUM_ABS_JSON_FORMAT format,
      const int indentSize=4)
     {
      CAbsJsonWriter writer;

      writer.SetFormat(format);

      writer.SetIndentSize(indentSize);

      return writer.Write(m_root);
     }

   /**
    * @brief Serializes the document without any insignificant whitespace.
    * @return Compact JSON text.
    */
   string            Minify()
     {
      CAbsJsonWriter writer;

      writer.SetPretty(false);

      return writer.Write(m_root);
     }

   /**
    * @brief Serializes the document with indentation and line breaks ("\r\n").
    * @param indentSize  Spaces per level. Values <= 0 are ignored (the default 4 is used).
    * @return Pretty-printed JSON text.
    */
   string            PrettyPrint(
      const int indentSize=4)
     {
      CAbsJsonWriter writer;

      writer.SetPretty(true);

      writer.SetIndentSize(indentSize);

      return writer.Write(m_root);
     }

   /**
    * @brief Makes @p target an independent deep copy of this document.
    * @param[out] target  Receives the copy (its previous content is discarded).
    *                     Cloning a document into itself is not supported.
    * @return true on success; false when copying failed (@p target is then empty and invalid).
    */
   bool              Clone(
      CAbsJson &target) const
     {
      target.Clear();

      if(!CAbsJsonClone::Value(m_root,target.m_root))
        {
         target.m_valid=false;
         return false;
        }

      target.m_status.Clear();

      target.m_valid=m_valid;

      return true;
     }

   /**
    * @brief Checks JSON text without touching Root.
    *
    * The status of this document is updated with the result of the check.
    *
    * @param text  JSON text.
    * @return true when the text is valid JSON.
    */
   bool              Validate(
      const string text)
     {
      CAbsJsonParser parser;

      CAbsJsonValue value;

      bool ok=parser.Parse(text,value);

      parser.GetStatus(m_status);

      return ok;
     }

   /**
    * @brief Tells whether the current document is valid (same as IsValid()).
    * @return true when valid.
    */
   bool              Validate() const
     {
      return m_valid;
     }

   /**
    * @brief Writes the document to a file in the common terminal folder (FILE_COMMON).
    *
    * The file is written as UTF-8 without a byte-order mark, which is what other JSON tools expect.
    *
    * @param filename  File name or relative path (must not be empty).
    * @param pretty    true for indented output.
    * @return true on success; false on failure (status code ABS_JSON_ERROR_IO).
    */
   bool              SaveFile(
      const string filename,
      const bool pretty=false)
     {
      if(filename=="")
         return IoError("Filename is empty.");

      CAbsJsonWriter writer;

      writer.SetPretty(pretty);

      string json=writer.Write(m_root);

      uchar bytes[];

      int count=StringToCharArray(json,bytes,0,WHOLE_ARRAY,CP_UTF8);

      // StringToCharArray() counts the terminating zero; do not write it.
      if(count>0)
         ArrayResize(bytes,count-1);

      ResetLastError();

      int handle=FileOpen(filename,FILE_WRITE|FILE_BIN|FILE_COMMON);

      if(handle==INVALID_HANDLE)
         return IoError("Cannot open file for writing.");

      uint written=0;

      if(ArraySize(bytes)>0)
         written=FileWriteArray(handle,bytes);

      FileClose(handle);

      if(written!=(uint)ArraySize(bytes))
         return IoError("Cannot write the file.");

      m_status.Clear();

      return true;
     }

   /**
    * @brief Reads a JSON file from the common terminal folder (FILE_COMMON) and parses it.
    *
    * UTF-8 (with or without BOM) is read directly. A file with a UTF-16 LE byte-order mark
    * (as written by earlier versions of this library) is read as UTF-16.
    *
    * @param filename  File name or relative path (must not be empty).
    * @return true when the file was read and parsed successfully. Open / read problems set
    *         ABS_JSON_ERROR_IO; JSON problems set the usual parser error.
    */
   bool              LoadFile(
      const string filename)
     {
      if(filename=="")
         return IoError("Filename is empty.");

      ResetLastError();

      int handle=FileOpen(filename,FILE_READ|FILE_BIN|FILE_COMMON);

      if(handle==INVALID_HANDLE)
         return IoError("Cannot open file for reading.");

      int size=(int)FileSize(handle);

      uchar bytes[];

      if(size>0)
        {
         if(FileReadArray(handle,bytes,0,size)!=(uint)size)
           {
            FileClose(handle);
            return IoError("Cannot read the file.");
           }
        }

      FileClose(handle);

      string json="";

      if(size>=2 && bytes[0]==0xFF && bytes[1]==0xFE)
        {
         // UTF-16 LE with BOM: combine byte pairs into UTF-16 code units.
         int units=(size-2)/2;

         ushort chars[];

         ArrayResize(chars,units);

         for(int i=0;i<units;i++)
            chars[i]=(ushort)(bytes[2+2*i] | (bytes[3+2*i]<<8));

         json=ShortArrayToString(chars,0,units);
        }
      else
        {
         int start=0;

         // Skip a UTF-8 byte-order mark.
         if(size>=3 && bytes[0]==0xEF && bytes[1]==0xBB && bytes[2]==0xBF)
            start=3;

         if(size>start)
            json=CharArrayToString(bytes,start,size-start,CP_UTF8);
        }

      return Parse(json);
     }
  };

#endif // __ABS_JSON_MQH__
//+------------------------------------------------------------------+
