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

with System.Machine_Code;

with Skp;

with SK.CPU_Global;

package body SK.MP
with
   Refined_State => (Barrier => (Sense, CPU_Sense, Barrier_Count))
is

   type Sense_Array is array (Skp.CPU_Range) of Boolean;

   Sense         : Boolean     := False;
   CPU_Sense     : Sense_Array := Sense_Array'(others => True);
   Barrier_Count : SK.Byte     := 0
      with Atomic, Async_Readers, Async_Writers;

   -------------------------------------------------------------------------

   procedure Get_And_Increment_Barrier (Count : out SK.Byte)
   with
      SPARK_Mode => Off,
      Global     => (In_Out => Barrier_Count),
      Depends    => ((Barrier_Count, Count) => Barrier_Count)
   is
   begin
      Count := 1;

      System.Machine_Code.Asm
        (Template => "lock xaddb %0, %1",
         Inputs   => (SK.Byte'Asm_Input ("a", Count),
                      SK.Byte'Asm_Input ("m", Barrier_Count)),
         Outputs  => (SK.Byte'Asm_Output ("=a", Count),
                      SK.Byte'Asm_Output ("=m", Barrier_Count)),
         Volatile => True);
   end Get_And_Increment_Barrier;

   -------------------------------------------------------------------------

   procedure Wait_For_All
   with
      SPARK_Mode      => Off,
      Refined_Global  => (In_Out => (Barrier_Count, CPU_Sense, Sense)),
      Refined_Depends => ((Barrier_Count, Sense) =>+ Barrier_Count,
                          CPU_Sense              =>+ Sense)
   is
      Count : SK.Byte;
   begin
      CPU_Sense (CPU_Global.CPU_ID) := not Sense;
      Get_And_Increment_Barrier (Count => Count);

      if Count = SK.Byte (Skp.CPU_Range'Last) then
         Barrier_Count := 0;
         Sense         := CPU_Sense (CPU_Global.CPU_ID);
      else
         while Sense /= CPU_Sense (CPU_Global.CPU_ID) loop
            System.Machine_Code.Asm (Template => "pause",
                                     Volatile => True);
         end loop;
      end if;
   end Wait_For_All;

end SK.MP;
