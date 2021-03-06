--
--  Copyright (C) 2013  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013  Adrian-Ken Rueegsegger <ken@codelabs.ch>
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

with System;

with SK.Hypercall;

with Example_Component.Channels;

package body Foo.Sender
with
   Refined_State => (State => Response)
is

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
   --D Example response channel. Used to illustrate a service component.
   Response : Foo.Message_Type
     with
       Volatile,
       Async_Readers,
       Address => System'To_Address
         (Example_Component.Channels.Example_Response_Address);
   pragma Warnings
     (GNATprove, On,
      "writing * is assumed to have no effects on other non-volatile objects");
   pragma Warnings
     (GNATprove, On,
      "indirect writes to * through a potential alias are ignored");

   -------------------------------------------------------------------------

   procedure Send (Res : Foo.Message_Type)
   with
      Refined_Global  => (Output => Response, In_Out => X86_64.State),
      Refined_Depends => (Response => Res, X86_64.State =>+ null)
   is
   begin
      Response := Res;

      SK.Hypercall.Trigger_Event
        (Number => Example_Component.Channels.Example_Response_Event);
   end Send;

begin
   Response := Foo.Null_Message;
end Foo.Sender;
