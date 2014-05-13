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

with Ada.Directories;

with Muxml;

with Mutools.XML_Utils;

with Test_Utils;

package body XML_Utils_Tests
is

   use Ahven;

   -------------------------------------------------------------------------

   procedure Add_Memory
   is
      Filename : constant String := "obj/memory.xml";
      Policy   : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Policy,
                   Kind => Muxml.Format_Src,
                   File => "data/test_policy.xml");
      Mutools.XML_Utils.Add_Memory_Region
        (Policy      => Policy,
         Name        => "test",
         Address     => "16#9000_1000#",
         Size        => "16#3000#",
         Caching     => "UC",
         Alignment   => "16#1000#",
         Memory_Type => "");
      Mutools.XML_Utils.Add_Memory_Region
        (Policy      => Policy,
         Name        => "noaddress",
         Address     => "",
         Size        => "16#8000#",
         Caching     => "WC",
         Alignment   => "16#0020_0000#",
         Memory_Type => "");

      Muxml.Write (Data => Policy,
                   Kind => Muxml.Format_Src,
                   File => Filename);

      Assert (Condition => Test_Utils.Equal_Files
              (Filename1 => Filename,
               Filename2 => "data/memory.xml"),
              Message   => "Policy mismatch");

      Ada.Directories.Delete_File (Name => Filename);
   end Add_Memory;

   -------------------------------------------------------------------------

   procedure Add_Memory_With_File
   is
      Filename : constant String := "obj/memory_with_file.xml";
      Policy   : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Policy,
                   Kind => Muxml.Format_Src,
                   File => "data/test_policy.xml");
      Mutools.XML_Utils.Add_Memory_Region
        (Policy      => Policy,
         Name        => "test",
         Address     => "16#2000#",
         Size        => "16#4000#",
         Caching     => "WB",
         Alignment   => "16#1000#",
         Memory_Type => "",
         File_Name   => "testfile",
         File_Offset => "16#1000#");

      Muxml.Write (Data => Policy,
                   Kind => Muxml.Format_Src,
                   File => Filename);

      Assert (Condition => Test_Utils.Equal_Files
              (Filename1 => Filename,
               Filename2 => "data/memory_with_file.xml"),
              Message   => "Policy mismatch");

      Ada.Directories.Delete_File (Name => Filename);
   end Add_Memory_With_File;

   -------------------------------------------------------------------------

   procedure Initialize (T : in out Testcase)
   is
   begin
      T.Set_Name (Name => "XML utility tests");
      T.Add_Test_Routine
        (Routine => Add_Memory'Access,
         Name    => "Add memory region");
      T.Add_Test_Routine
        (Routine => Add_Memory_With_File'Access,
         Name    => "Add memory region with file content");
   end Initialize;

end XML_Utils_Tests;