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

private with System;

private with Libmucontrol_Component.Memory;

package Mucontrol.Status.Instance
with
   Abstract_State => (State with External => Async_Readers),
   Initializes    => State
is

   --  Initialize subject status.
   procedure Initialize
   with
      Global  => (Output => State),
      Depends => (State => null);

   --  Get current subject state.
   function Get return State_Type
   with
      Global => (Input => State);

   --  Get current diagnostics value.
   function Get_Diagnostics return Diagnostics_Type
   with
      Global => (Input => State);

   --  Get current watchdog value.
   function Get_Watchdog return Interfaces.Unsigned_64
   with
      Global => (Input => State);

   --  Set subject state to given value.
   procedure Set (New_State : State_Type)
   with
      Global  => (In_Out => State),
      Depends => (State  =>+ New_State);

   --  Set error in subject status.
   procedure Error
   with
      Global  => (In_Out => State),
      Depends => (State  => State);

   --  Set diagnostic to given value.
   procedure Set_Diagnostics (Value : Diagnostics_Type)
   with
      Global  => (In_Out => State),
      Depends => (State  =>+ Value);

   --  Set watchdog value.
   procedure Set_Watchdog (Value : Interfaces.Unsigned_64)
   with
      Global  => (In_Out => State),
      Depends => (State  =>+ Value);

private

   package Cspec renames Libmucontrol_Component.Memory;

   pragma Warnings
     (GNATprove, Off,
      "indirect writes to * through a potential alias are ignored",
      Reason => "All objects with address clause are mapped to external "
      & "interfaces. Non-overlap is checked during system build.");
   pragma Warnings
     (GNATprove, Off,
      "writing * is assumed to have no effects on other non-volatile objects",
      Reason => "All objects with address clause are mapped to external "
      & "interfaces. Non-overlap is checked during system build.");
   --D @Interface
   --D The status page is written by a subject that includes the initialization
   --D and reset functionality and read by the control subject. It is used to
   --D report the current state of the initialization/reset process. Subjects
   --D may use unreserved state numbers to indicate custom runtime information.
   --D As an example: a subject may set state to \verb!16#1000#! after some
   --D information has been written to a shared memory region to indicate
   --D availability of said information.
   --D
   --D An error is designated by the most significant bit of State. If it is
   --D set, then an error condition is present. By or\-ing
   --D \verb!STATE_ERROR!, the current state value is preserved, which can be
   --D helpful for debugging purposes since it directly designates the failure
   --D state.
   --D
   --D The watchdog field is used to report liveliness of the subject by writing
   --D a new timestamp value within the WD interval specified on the command
   --D page.
   --D The diagnostics field can be used to report additional debug information,
   --D e.g. when transitioning to an error state.
   Status_Page : Status_Interface_Type
   with
      Import,
      Async_Readers,
      Part_Of => State,
      Size    => Cspec.Status_Size * 8,
      Address => System'To_Address (Cspec.Status_Address);
   pragma Warnings
     (GNATprove, On,
      "writing * is assumed to have no effects on other non-volatile objects");
   pragma Warnings
     (GNATprove, On,
      "indirect writes to * through a potential alias are ignored");

end Mucontrol.Status.Instance;
