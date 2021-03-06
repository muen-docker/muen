--
--  Copyright (C) 2014  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2014  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Interfaces;

with Bfd.Sections;

with DOM.Core;

package Elfcheck.Bfd_Utils
is

   --  Check that a section matches the properties defined by the memory region
   --  identified by name. An exception is raised if a property does not fit
   --  the requirements. If Mapped is False, the VMA is not validated.
   procedure Check_Section
     (Physical_Mem : DOM.Core.Node_List;
      Virtual_Mem  : DOM.Core.Node_List;
      Region_Name  : String;
      Section      : Bfd.Sections.Section;
      Mapped       : Boolean := True);

   --  Check that the given entry point address matches the expected kernel
   --  entry point. An exception is raised if they do not match.
   procedure Check_Entry_Point (Address : Interfaces.Unsigned_64);

private

   --  Validate that the section size is smaller than the size of the memory
   --  region identified by name.
   procedure Validate_Size
     (Section      : Bfd.Sections.Section;
      Section_Name : String;
      Region_Name  : String;
      Size         : Interfaces.Unsigned_64);

   --  Validate that the section VMA is equal to the virtualAddress of the
   --  memory region identified by name.
   procedure Validate_VMA
     (Section      : Bfd.Sections.Section;
      Section_Name : String;
      Region_Name  : String;
      Address      : Interfaces.Unsigned_64);

   --  Validate that the section LMA plus size lays within the physical memory
   --  region given by address and size.
   procedure Validate_LMA_In_Region
     (Section      : Bfd.Sections.Section;
      Section_Name : String;
      Region_Name  : String;
      Address      : Interfaces.Unsigned_64;
      Size         : Interfaces.Unsigned_64);

   --  Validate that the section flags match the permissions of the memory
   --  region identified by name.
   procedure Validate_Permission
     (Section      : Bfd.Sections.Section;
      Section_Name : String;
      Region_Name  : String;
      Read_Only    : Boolean);

end Elfcheck.Bfd_Utils;
