//+------------------------------------------------------------------+
//|                                                AbsJsonBase.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_BASE_MQH__
#define __ABS_JSON_BASE_MQH__

#property strict

#include <Object.mqh>
#include "AbsJsonStatus.mqh"

/**
 * @file AbsJsonBase.mqh
 * @brief Common base class of the AbsJson classes.
 *
 * CAbsJsonBase provides the "last operation status" infrastructure that the
 * value, node, parser and property classes share. It knows nothing about the
 * JSON structure itself.
 */

/**
 * @class CAbsJsonBase
 * @brief Base class that holds a CAbsJsonStatus (composition, not inheritance).
 *
 * Derives from CObject so that instances can be stored in the MQL5 standard
 * library containers (CArrayObj). The class allocates no dynamic memory.
 */
class CAbsJsonBase: public CObject
  {
protected:

   /// Status of the last operation performed on this object.
   CAbsJsonStatus    m_status;

public:

   /** @brief Creates the object with a cleared (successful) status. */
                     CAbsJsonBase()
     {
      m_status.Clear();
     }

   /** @brief Virtual destructor. Nothing to release. */
   virtual          ~CAbsJsonBase()
     {
     }

   /**
    * @brief Copies the current status into @p target.
    *
    * MQL5 cannot return a reference to a member, so the status is copied.
    * Prefer Status() when only a read is needed.
    *
    * @param[out] target  Receives the status.
    */
   void              GetStatus(
      CAbsJsonStatus &target) const
     {
      target.CopyFrom(m_status);
     }

   /**
    * @brief Read-only access to the current status.
    * @return Pointer to the internal status; valid for the lifetime of this object.
    */
   const CAbsJsonStatus *Status() const
     {
      return &m_status;
     }

   /** @return true when the last operation recorded an error. */
   bool              HasError() const
     {
      return m_status.Failed();
     }

   /** @brief Resets the status to success. */
   void              ClearStatus()
     {
      m_status.Clear();
     }

protected:

   /**
    * @brief Records an error with the default message of @p code.
    * @param code  Error code.
    * @return Always false, so callers can write `return SetError(...)`.
    */
   bool              SetError(
      ENUM_ABS_JSON_ERROR code)
     {
      m_status.Error(code);

      return false;
     }

   /**
    * @brief Records an error with a custom message.
    * @param code     Error code.
    * @param message  Custom message (empty = default message).
    * @return Always false.
    */
   bool              SetError(
      ENUM_ABS_JSON_ERROR code,
      const string message)
     {
      m_status.Error(code,message);

      return false;
     }

   /**
    * @brief Records an error together with its location in the JSON text.
    * @param code      Error code.
    * @param message   Message (empty = default message).
    * @param line      1-based line.
    * @param column    1-based column.
    * @param position  0-based character offset.
    * @return Always false.
    */
   bool              SetError(
      ENUM_ABS_JSON_ERROR code,
      const string message,
      const int line,
      const int column,
      const int position)
     {
      m_status.Error(code,message,line,column,position);

      return false;
     }

   /**
    * @brief Stores an error location without changing the error code.
    * @param line      1-based line.
    * @param column    1-based column.
    * @param position  0-based character offset.
    */
   void              SetErrorPosition(
      const int line,
      const int column,
      const int position)
     {
      m_status.At(line,column,position);
     }
  };

#endif // __ABS_JSON_BASE_MQH__
//+------------------------------------------------------------------+
