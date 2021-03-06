--
--  Copyright (C) 2020  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2020  Adrian-Ken Rueegsegger <ken@codelabs.ch>
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright notice,
--      this list of conditions and the following disclaimer.
--
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
--  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
--  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
--  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--

with Interfaces;

package Mucontrol.Status
is

   type State_Type is new Interfaces.Unsigned_64
     with Size => 64;

   --  Waiting for initial command.
   STATE_INITIAL      : constant State_Type := 16#0000#;
   --  Synchronized with command.
   STATE_SYNCED       : constant State_Type := 16#0001#;
   --  Erasing writable memory regions.
   STATE_ERASING      : constant State_Type := 16#0002#;
   --  All writable memory regions have been erased.
   STATE_ERASED       : constant State_Type := 16#0003#;
   --  Preparing writable memory regions.
   STATE_PREPARING    : constant State_Type := 16#0004#;
   --  All writable memory regions have been prepared with their initial
   --  content.
   STATE_PREPARED     : constant State_Type := 16#0005#;
   --  Validating hashes of all memory regions.
   STATE_VALIDATING   : constant State_Type := 16#0006#;
   --  Hashes of all memory regions have been validated.
   STATE_VALIDATED    : constant State_Type := 16#0007#;
   --  Initializing remaining environment for subject execution.
   STATE_INITIALIZING : constant State_Type := 16#0008#;
   --  Subject is running.
   STATE_RUNNING      : constant State_Type := 16#0009#;
   --  Subject has finished its task and halted further execution.
   STATE_FINISHED     : constant State_Type := 16#000a#;
   --  Error occurred.
   STATE_ERROR        : constant State_Type := 16#8000_0000_0000_0000#;

   type Diagnostics_Type is new Interfaces.Unsigned_64
     with Size => 64;

   --  Processing successful, no error.
   DIAG_OK             : constant Diagnostics_Type := 16#0000#;
   --  Received unexpected command.
   DIAG_UNEXPECTED_CMD : constant Diagnostics_Type := 16#0001#;

   Padding_Start_Byte : constant := 8 + 8 + 8;
   Padding_Size       : constant := (Page_Size - Padding_Start_Byte) * 8;

   type Padding_Type is array
     (Padding_Start_Byte .. Page_Size - 1) of Interfaces.Unsigned_8
     with Size => Padding_Size;

   --D @Interface
   type Status_Interface_Type is record
      --D @Interface
      --D Current state reported by the subject.
      State       : State_Type with Atomic;
      --D @Interface
      --D Current watchdog timestamp reported by the subject.
      Watchdog    : Interfaces.Unsigned_64;
      --D @Interface
      --D Current diagnostics value reported by the subject. Its meaning depends
      --D on the current state.
      Diagnostics : Diagnostics_Type;
      --D @Interface
      --D Padding of the status interface to the full memory page so every bit
      --D of memory is captured by this type.
      Reserved    : Padding_Type;
   end record
     with
       Object_Size => Page_Size * 8,
       Size        => Page_Size * 8,
       Volatile;

   for Status_Interface_Type use record
      State       at  0 range 0 .. 63;
      Watchdog    at  8 range 0 .. 63;
      Diagnostics at 16 range 0 .. 63;
      Reserved    at Padding_Start_Byte range 0 .. Padding_Size - 1;
   end record;

end Mucontrol.Status;
