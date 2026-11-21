//+------------------------------------------------------------------+
//|                                              AbsJsonStatus.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_STATUS_MQH__
#define __ABS_JSON_STATUS_MQH__

#property strict

#include "AbsJsonTypes.mqh"

/**
 * @file AbsJsonStatus.mqh
 * @brief Operation status and error information of the AbsJson library.
 *
 * The library does not use exceptions. Every failure is recorded in a
 * CAbsJsonStatus object (error code, message and, for parser errors, the
 * line / column / character position) that the caller can query.
 */

/**
 * @class CAbsJsonStatus
 * @brief Value type that stores the outcome of the last operation.
 *
 * The object owns no dynamic memory and can be copied freely with CopyFrom().
 *
 * @code
 * CAbsJson json;
 * if(!json.Parse(text))
 *    Print(json.GetStatus().FullMessage());
 * @endcode
 */
class CAbsJsonStatus
  {
private:
   /// Current error code; ABS_JSON_ERROR_NONE means success.
   ENUM_ABS_JSON_ERROR m_code;

   /// Human readable error message (empty on success).
   string            m_message;

   /// 1-based line of the error (meaningful for parser errors).
   int               m_line;

   /// 1-based column of the error (meaningful for parser errors).
   int               m_column;

   /// 0-based character offset of the error from the start of the text.
   int               m_position;

   /**
    * @brief Chooses the final message of an error.
    * @param code           Error code.
    * @param customMessage  Optional custom message.
    * @return customMessage when it is not empty, otherwise the default text of @p code.
    */
   string            BuildMessage(
      ENUM_ABS_JSON_ERROR code,
      const string customMessage)
     {
      if(customMessage!="")
         return customMessage;

      return AbsJsonErrorToString(code);
     }

public:

   /** @brief Creates a status in the "success" state. */
                     CAbsJsonStatus()
     {
      Clear();
     }

   /** @brief Destructor. The class owns no dynamic memory. */
   virtual          ~CAbsJsonStatus()
     {
     }

   /** @brief Resets to success: code NONE, empty message, line 1, column 1, position 0. */
   void              Clear()
     {
      m_code=ABS_JSON_ERROR_NONE;
      m_message="";
      m_line=1;
      m_column=1;
      m_position=0;
     }

   /** @return true when the last operation succeeded (no error code is set). */
   bool              Success() const
     {
      return (m_code==ABS_JSON_ERROR_NONE);
     }

   /** @return true when an error code is set. */
   bool              Failed() const
     {
      return (m_code!=ABS_JSON_ERROR_NONE);
     }

   /** @return The current error code (ABS_JSON_ERROR_NONE on success). */
   ENUM_ABS_JSON_ERROR Code() const
     {
      return m_code;
     }

   /** @return The error message; an empty string on success. */
   string            Message() const
     {
      return m_message;
     }

   /** @return 1-based line of the error. Only meaningful after a parser error. */
   int               Line() const
     {
      return m_line;
     }

   /** @return 1-based column of the error. Only meaningful after a parser error. */
   int               Column() const
     {
      return m_column;
     }

   /** @return 0-based character offset of the error. Only meaningful after a parser error. */
   int               Position() const
     {
      return m_position;
     }

   /**
    * @brief Message plus error location.
    * @return "" on success, otherwise "<message> (Line=L, Column=C, Position=P)".
    */
   string            FullMessage() const
     {
      if(Success())
         return "";

      return StringFormat(
                "%s (Line=%d, Column=%d, Position=%d)",
                m_message,
                m_line,
                m_column,
                m_position);
     }

   /**
    * @brief Stores an error location without changing the error code.
    * @param line      1-based line.
    * @param column    1-based column.
    * @param position  0-based character offset.
    */
   void              At(
      const int line,
      const int column,
      const int position)
     {
      m_line=line;
      m_column=column;
      m_position=position;
     }

   /**
    * @brief Records an error using the default message of the code.
    * @param code  Error code. The location fields are left unchanged.
    */
   void              Error(
      ENUM_ABS_JSON_ERROR code)
     {
      m_code=code;
      m_message=BuildMessage(code,"");
     }

   /**
    * @brief Records an error with a custom message.
    * @param code     Error code.
    * @param message  Custom message; when empty the default text of @p code is used.
    */
   void              Error(
      ENUM_ABS_JSON_ERROR code,
      const string message)
     {
      m_code=code;
      m_message=BuildMessage(code,message);
     }

   /**
    * @brief Records an error together with its location in the JSON text.
    * @param code      Error code.
    * @param message   Custom message; when empty the default text of @p code is used.
    * @param line      1-based line.
    * @param column    1-based column.
    * @param position  0-based character offset.
    */
   void              Error(
      ENUM_ABS_JSON_ERROR code,
      const string message,
      const int line,
      const int column,
      const int position)
     {
      m_code=code;
      m_message=BuildMessage(code,message);
      m_line=line;
      m_column=column;
      m_position=position;
     }

   /**
    * @brief Copies every field from another status object.
    * @param source  Status to copy from (not modified).
    */
   void              CopyFrom(
      const CAbsJsonStatus &source)
     {
      m_code=source.m_code;
      m_message=source.m_message;
      m_line=source.m_line;
      m_column=source.m_column;
      m_position=source.m_position;
     }

   /**
    * @brief Copies this status into another object.
    * @param target  Receives the copy (modified).
    */
   void              Clone(
      CAbsJsonStatus &target) const
     {
      target.CopyFrom(this);
     }

   /**
    * @brief Text for logging and debugging.
    * @return "Success" on success, otherwise FullMessage().
    */
   string            ToString() const
     {
      if(Success())
         return "Success";

      return FullMessage();
     }
  };

#endif // __ABS_JSON_STATUS_MQH__
//+------------------------------------------------------------------+
