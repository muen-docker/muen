--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Solo5.Generator.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;
with System.Assertions;

--  begin read only
--  id:2.2/00/
--
--  This section can be used to add with clauses if necessary.
--
--  end read only

--  begin read only
--  end read only
package body Solo5.Generator.Test_Data.Tests is

--  begin read only
--  id:2.2/01/
--
--  This section can be used to add global variables and other elements.
--
--  end read only

--  begin read only
--  end read only

--  begin read only
   procedure Test_Write (Gnattest_T : in out Test);
   procedure Test_Write_23ab15 (Gnattest_T : in out Test) renames Test_Write;
--  id:2.2/23ab1562ae4604fa/Write/1/0/
   procedure Test_Write (Gnattest_T : in out Test) is
--  end read only

      pragma Unreferenced (Gnattest_T);

      Policy : Muxml.XML_Data_Type;

      Uni1_Bi : constant String := "obj/unikernel1_bi";
      Uni2_Bi : constant String := "obj/unikernel2_bi";
   begin
      Muxml.Parse (Data => Policy,
                   Kind => Muxml.Format_B,
                   File => "data/test_policy.xml");

      Write (Output_Dir => "obj",
             Policy     => Policy);

      Assert (Condition => Test_Utils.Equal_Files
              (Filename1 => "data/unikernel1_bi",
               Filename2 => Uni1_Bi),
              Message   => "Unikernel 1 boot info mismatch");
      Assert (Condition => Test_Utils.Equal_Files
              (Filename1 => "data/unikernel2_bi",
               Filename2 => Uni2_Bi),
              Message   => "Unikernel 2 boot info mismatch");

      Ada.Directories.Delete_File (Name => Uni1_Bi);
      Ada.Directories.Delete_File (Name => Uni2_Bi);

      --  Missing 'subject_binary' memory region.

      Muxml.Utils.Set_Attribute
        (Doc   => Policy.Doc,
         XPath => "/system/memory/memory[@type='subject_binary']",
         Name  => "type",
         Value => "subject");

      begin
         Write (Output_Dir => "obj",
                Policy     => Policy);
         Assert (Condition => False,
                 Message   => "Exception expected");

      exception
         when E : Missing_Binary =>
            Assert (Condition => Ada.Exceptions.Exception_Message (X => E)
                    = "Unable to determine unikernel binary end: No memory "
                    & "region with type 'subject_binary' present",
                    Message   => "Exception message mismatch");
      end;
--  begin read only
   end Test_Write;
--  end read only

--  begin read only
--  id:2.2/02/
--
--  This section can be used to add elaboration code for the global state.
--
begin
--  end read only
   null;
--  begin read only
--  end read only
end Solo5.Generator.Test_Data.Tests;
