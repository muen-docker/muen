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

with Musinfo.Utils;

with Mucontrol.Status;

with Init.Addrspace;
with Init.Status;
with Init.Utils;

package body Init.Memory
is

   use type Musinfo.Resource_Kind;
   use type Musinfo.Memory_Kind;

   --  Initialize content of given memory region.
   procedure Init_Region_Content
     (Region  :     Musinfo.Memregion_Type;
      Success : out Boolean)
   with
      Pre => Musinfo.Instance.Is_Valid and
       Region.Flags.Writable;

   --  Returns True if the given resource should be processed.
   function Should_Process (Resource : Musinfo.Resource_Type) return Boolean
   is (Resource.Kind = Musinfo.Res_Memory
       and then not Utils.Is_Stack (Region => Resource.Mem_Data)
       and then not Utils.Is_Status (Region => Resource.Mem_Data))
   with
      Post =>
        (if Should_Process'Result then Resource.Kind = Musinfo.Res_Memory);

   -------------------------------------------------------------------------

   procedure Check_Hashes (Success : out Boolean)
   is
      use type Musinfo.Hash_Type;

      Iter    : Musinfo.Utils.Resource_Iterator_Type
        := Musinfo.Instance.Create_Resource_Iterator;
      Element : Musinfo.Resource_Type;
   begin
      Process_Memregions :
      while Musinfo.Instance.Has_Element (Iter => Iter) loop
         Status.Set_Diagnostics
           (Value => Mucontrol.Status.Diagnostics_Type
              (Musinfo.Utils.Index (Iter => Iter)));
         Element := Musinfo.Instance.Element (Iter => Iter);
         if Should_Process (Resource => Element)
           and then Element.Mem_Data.Kind /= Musinfo.Subject_Channel
           and then Element.Mem_Data.Hash /= Musinfo.No_Hash
         then
            Success := Addrspace.Calculate_Hash
              (Source => Element.Mem_Data) = Element.Mem_Data.Hash;
            if not Success then
               return;
            end if;
         end if;
         Musinfo.Utils.Next (Iter => Iter);
         pragma Loop_Invariant
           (Musinfo.Instance.Belongs_To (Iter => Iter));
      end loop Process_Memregions;

      Success := True;
   end Check_Hashes;

   -------------------------------------------------------------------------

   procedure Clear_Writable
   is
      Iter    : Musinfo.Utils.Resource_Iterator_Type
        := Musinfo.Instance.Create_Resource_Iterator;
      Element : Musinfo.Resource_Type;
   begin
      Process_Memregions :
      while Musinfo.Instance.Has_Element (Iter => Iter) loop
         --D @Item List => subject-lifecycle-operation-init-steps, Priority => 25
         --D For every writable memory region except for the stack, the status
         --D interface, mapped subject states and timed event regions, erase
         --D their content by filling the entire region with zeros.
         --D The Sinfo index of the region currently being processed is set as
         --D diagnostics value.
         Status.Set_Diagnostics
           (Value => Mucontrol.Status.Diagnostics_Type
              (Musinfo.Utils.Index (Iter => Iter)));
         Element := Musinfo.Instance.Element (Iter => Iter);
         if Should_Process (Resource => Element)
           and then Element.Mem_Data.Flags.Writable
           and then Element.Mem_Data.Kind /= Musinfo.Subject_State
           and then Element.Mem_Data.Kind /= Musinfo.Subject_Timed_Event
         then
            Addrspace.Memset (Region  => Element.Mem_Data,
                              Pattern => 0);
         end if;
         Musinfo.Utils.Next (Iter => Iter);
         pragma Loop_Invariant
           (Musinfo.Instance.Belongs_To (Iter => Iter));
      end loop Process_Memregions;
   end Clear_Writable;

   -------------------------------------------------------------------------

   procedure Get_Base_Addresses
     (Text_Base  : out Interfaces.Unsigned_64;
      Stack_Base : out Interfaces.Unsigned_64;
      Stack_Size : out Interfaces.Unsigned_64;
      Success    : out Boolean)
   is
      Iter    : Musinfo.Utils.Resource_Iterator_Type
        := Musinfo.Instance.Create_Resource_Iterator;
      Element : Musinfo.Resource_Type;
      Stack_Found, Text_Found : Boolean;
   begin
      Stack_Found := False;
      Text_Found  := False;
      Text_Base   := 0;
      Stack_Base  := 0;
      Stack_Size  := 0;

      Process_Memregions :
      while Musinfo.Instance.Has_Element (Iter => Iter)
        and not (Stack_Found and Text_Found)
      loop
         Element := Musinfo.Instance.Element (Iter => Iter);
         if Element.Kind = Musinfo.Res_Memory then
            if Utils.Is_Stack (Region => Element.Mem_Data) then
               Stack_Base  := Element.Mem_Data.Address;
               Stack_Size  := Element.Mem_Data.Size;
               Stack_Found := True;
            elsif Utils.Is_Text_Region (Resource => Element) then
               Text_Base  := Element.Mem_Data.Address;
               Text_Found := True;
            end if;
         end if;
         Musinfo.Utils.Next (Iter => Iter);
         pragma Loop_Invariant
           (Musinfo.Instance.Belongs_To (Iter => Iter));
      end loop Process_Memregions;
      Success := Stack_Found and Text_Found;
   end Get_Base_Addresses;

   -------------------------------------------------------------------------

   procedure Init_Region_Content
     (Region  :     Musinfo.Memregion_Type;
      Success : out Boolean)
   is
      use type Interfaces.Unsigned_64;
      use type Musinfo.Hash_Type;
      use type Musinfo.Memregion_Type;
   begin
      Success := False;
      case Region.Content is
         when Musinfo.Content_File => null;
         when Musinfo.Content_Fill =>
            Addrspace.Memset
              (Region  => Region,
               Pattern => Region.Pattern);
         when Musinfo.Content_Uninitialized =>
            if Region.Hash /= Musinfo.No_Hash then
               declare
                  Src_Region : constant Musinfo.Memregion_Type
                    := Musinfo.Instance.Memory_By_Hash
                      (Hash    => Region.Hash,
                       Content => Musinfo.Content_File);
               begin
                  if Src_Region = Musinfo.Null_Memregion
                    or else Src_Region.Size /= Region.Size
                  then
                     return;
                  end if;
                  Addrspace.Memcopy (Source      => Src_Region,
                                     Destination => Region);
               end;
            end if;
      end case;
      Success := True;
   end Init_Region_Content;

   -------------------------------------------------------------------------

   procedure Setup_Writable (Success : out Boolean)
   is
      Iter    : Musinfo.Utils.Resource_Iterator_Type
        := Musinfo.Instance.Create_Resource_Iterator;
      Element : Musinfo.Resource_Type;
   begin
      Process_Memregions :
      while Musinfo.Instance.Has_Element (Iter => Iter) loop
         Status.Set_Diagnostics
           (Value => Mucontrol.Status.Diagnostics_Type
              (Musinfo.Utils.Index (Iter => Iter)));
         Element := Musinfo.Instance.Element (Iter => Iter);
         if Should_Process (Resource => Element)
           and then Element.Mem_Data.Flags.Writable
           and then Element.Mem_Data.Kind /= Musinfo.Subject_State
           and then Element.Mem_Data.Kind /= Musinfo.Subject_Timed_Event
         then
            Init_Region_Content (Region  => Element.Mem_Data,
                                 Success => Success);
            if not Success then
               return;
            end if;
         end if;
         Musinfo.Utils.Next (Iter => Iter);
         pragma Loop_Invariant
           (Musinfo.Instance.Belongs_To (Iter => Iter));
      end loop Process_Memregions;

      Success := True;
   end Setup_Writable;

end Init.Memory;
