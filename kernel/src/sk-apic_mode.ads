--
--  Copyright (C) 2013-2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013-2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with X86_64;

package SK.Apic_Mode
is

   --  Enable local APIC.
   procedure Enable
   with
      Global  => (In_Out => X86_64.State),
      Depends => (X86_64.State =>+ null);

   --  Write given low/high doubleword value to the ICR register of the local
   --  APIC.
   procedure Write_ICR (Low, High : SK.Word32)
   with
      Global  => (In_Out => X86_64.State),
      Depends => (X86_64.State =>+ (Low, High));

   --  Signal interrupt servicing completion.
   procedure EOI
   with
      Global  => (In_Out => X86_64.State),
      Depends => (X86_64.State =>+ null);

   --  Return local APIC ID.
   function Get_ID return SK.Byte
   with
      Global  => (Input => X86_64.State);

end SK.Apic_Mode;
