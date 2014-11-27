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

with Skp.Kernel;
with Skp.Scheduling;

use type Skp.Scheduling.Major_Frame_Array;

package body SK.CPU_Global
with
   Refined_State => (State => Storage)
is

   --  Record used to store per-CPU global data.
   type Storage_Type is record
      Scheduling_Plan     : Skp.Scheduling.Major_Frame_Array;
      Current_Minor_Frame : Active_Minor_Frame_Type;
   end record;

   pragma $Build_Warnings (Off, "* bits of ""Storage"" unused");
   Storage : Storage_Type
   with
      Address => System'To_Address (Skp.Kernel.CPU_Store_Address + 8),
      Size    => 8 * (SK.Page_Size - 8);
   pragma $Build_Warnings (On,  "* bits of ""Storage"" unused");

   -------------------------------------------------------------------------

   function Get_Current_Minor_Frame return Active_Minor_Frame_Type
   with
      Refined_Global => (Input => Storage),
      Refined_Post   =>
         Get_Current_Minor_Frame'Result = Storage.Current_Minor_Frame
   is
   begin
      return Storage.Current_Minor_Frame;
   end Get_Current_Minor_Frame;

   -------------------------------------------------------------------------

   function Get_Major_Length
     (Major_Id : Skp.Scheduling.Major_Frame_Range)
      return Skp.Scheduling.Minor_Frame_Range
   with
      Refined_Global => (Input => Storage)
   is
   begin
      return Storage.Scheduling_Plan (Major_Id).Length;
   end Get_Major_Length;

   -------------------------------------------------------------------------

   function Get_Minor_Frame
     (Major_Id : Skp.Scheduling.Major_Frame_Range;
      Minor_Id : Skp.Scheduling.Minor_Frame_Range)
      return Skp.Scheduling.Minor_Frame_Type
   with
      Refined_Global => (Input => Storage)
   is
   begin
      return Storage.Scheduling_Plan (Major_Id).Minor_Frames (Minor_Id);
   end Get_Minor_Frame;

   -------------------------------------------------------------------------

   procedure Init
   with
      Refined_Global  => (Output => Storage),
      Refined_Depends => (Storage => null)
   is
   begin
      Storage := Storage_Type'
        (Scheduling_Plan     => Skp.Scheduling.Null_Major_Frames,
         Current_Minor_Frame => Active_Minor_Frame_Type'
           (Minor_Id   => Skp.Scheduling.Minor_Frame_Range'First,
            Subject_Id => Skp.Subject_Id_Type'First));
   end Init;

   -------------------------------------------------------------------------

   function Is_BSP return Boolean
   is
   begin
      --  Skp.CPU_Range is auto-generated by mugenspec and contains only a
      --  single element if the system is configured for one core. GNAT finds
      --  the use of 'First on such a trivial type suspicious and warns about
      --  it.
      pragma Warnings (Off);
      return CPU_ID = Skp.CPU_Range'First;
      pragma Warnings (On);
   end Is_BSP;

   -------------------------------------------------------------------------

   procedure Set_Current_Minor (Frame : Active_Minor_Frame_Type)
   with
      Refined_Global  => (In_Out => Storage),
      Refined_Depends => (Storage =>+ Frame),
      Refined_Post    => Storage.Current_Minor_Frame = Frame
   is
   begin
      Storage.Current_Minor_Frame := Frame;
   end Set_Current_Minor;

   -------------------------------------------------------------------------

   procedure Set_Scheduling_Plan (Data : Skp.Scheduling.Major_Frame_Array)
   with
      Refined_Global  => (In_Out => Storage),
      Refined_Depends => (Storage =>+ Data),
      Refined_Post    => Storage.Scheduling_Plan = Data
   is
   begin
      Storage.Scheduling_Plan := Data;
   end Set_Scheduling_Plan;

   -------------------------------------------------------------------------

   procedure Swap_Subject
     (Old_Id : Skp.Subject_Id_Type;
      New_Id : Skp.Subject_Id_Type)
     with
        Refined_Global  => (In_Out => Storage),
        Refined_Depends => (Storage =>+ (Old_Id, New_Id))
   is
   begin
      for I in Skp.Scheduling.Major_Frame_Range loop
         for J in Skp.Scheduling.Minor_Frame_Range loop
            if Storage.Scheduling_Plan (I).Minor_Frames
              (J).Subject_Id = Old_Id
            then
               Storage.Scheduling_Plan (I).Minor_Frames
                 (J).Subject_Id := New_Id;
            end if;
         end loop;
      end loop;

      if Storage.Current_Minor_Frame.Subject_Id = Old_Id then
         Storage.Current_Minor_Frame.Subject_Id := New_Id;
      end if;
   end Swap_Subject;

end SK.CPU_Global;
