//+------------------------------------------------------------------+
//|                                               AbsJsonClone.mqh  |
//|                             Copyright 2026, Amir Bagheri Studio. |
//|                                        https://mql5.ab-studio.ir |
//+------------------------------------------------------------------+
// SPDX-License-Identifier: MIT
#property copyright "Copyright 2026, Amir Bagheri Studio."
#property link      "https://mql5.ab-studio.ir"
#property version   "1.00" // Library release 1.0.0 (MQL5 requires the "major.minor" form here)

#ifndef __ABS_JSON_CLONE_MQH__
#define __ABS_JSON_CLONE_MQH__

#property strict

/**
 * @file AbsJsonClone.mqh
 * @brief Declaration of the central deep-copy engine.
 *
 * Only the declarations live here, so that the value / property / object / array
 * classes can call the engine without circular includes. The implementation is in
 * AbsJsonCloneImpl.mqh, which AbsJson.mqh includes after all classes are known.
 */

class CAbsJsonValue;
class CAbsJsonProperty;
class CAbsJsonObject;
class CAbsJsonArray;

/**
 * @class CAbsJsonClone
 * @brief Static deep-copy functions for every JSON class.
 *
 * Every function first clears the target, then copies the source completely.
 * The copy shares no memory with the source (strings are copied, containers are
 * re-created). Copying an object onto itself is not supported.
 * On failure the target is left empty (null / cleared).
 */
class CAbsJsonClone
  {
public:

   /**
    * @brief Deep copy of a value.
    * @param source        Value to copy (not modified).
    * @param[out] target   Receives the copy; cleared first.
    * @return true on success.
    */
   static bool       Value(
      const CAbsJsonValue &source,
      CAbsJsonValue &target);

   /**
    * @brief Deep copy of a property (name and value).
    * @param source        Property to copy (not modified).
    * @param[out] target   Receives the copy; cleared first.
    * @return true on success.
    */
   static bool       Property(
      const CAbsJsonProperty &source,
      CAbsJsonProperty &target);

   /**
    * @brief Deep copy of an object.
    * @param source        Object to copy (not modified).
    * @param[out] target   Receives the copy; cleared first.
    * @return true on success.
    */
   static bool       Object(
      const CAbsJsonObject &source,
      CAbsJsonObject &target);

   /**
    * @brief Deep copy of an array.
    * @param source        Array to copy (not modified).
    * @param[out] target   Receives the copy; cleared first.
    * @return true on success.
    */
   static bool       Array(
      const CAbsJsonArray &source,
      CAbsJsonArray &target);
  };

#endif // __ABS_JSON_CLONE_MQH__
//+------------------------------------------------------------------+
