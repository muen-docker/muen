--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Memhashes.Utils.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;
with System.Assertions;

package body Memhashes.Utils.Test_Data.Tests is


--  begin read only
   procedure Test_To_Stream (Gnattest_T : in out Test);
   procedure Test_To_Stream_bfcf93 (Gnattest_T : in out Test) renames Test_To_Stream;
--  id:2.2/bfcf937fb5200e20/To_Stream/1/0/
   procedure Test_To_Stream (Gnattest_T : in out Test) is
   --  memhashes-utils.ads:27:4:To_Stream
--  end read only

      pragma Unreferenced (Gnattest_T);

      use type Ada.Streams.Stream_Element_Array;

      Impl         : DOM.Core.DOM_Implementation;
      Mem, Content : DOM.Core.Node;
      Policy       : Muxml.XML_Data_Type;
   begin
      Policy.Doc := DOM.Core.Create_Document (Implementation => Impl);

      Mem := DOM.Core.Documents.Create_Element
        (Doc      => Policy.Doc,
         Tag_Name => "memory");
      DOM.Core.Elements.Set_Attribute
        (Elem  => Mem,
         Name  => "size",
         Value => "24");

      Content := DOM.Core.Documents.Create_Element
        (Doc      => Policy.Doc,
         Tag_Name => "fill");
      DOM.Core.Elements.Set_Attribute
        (Elem  => Content,
         Name  => "pattern",
         Value => "16#32#");
      Content := DOM.Core.Nodes.Append_Child
        (N         => Mem,
         New_Child => Content);

      Assert (Condition => To_Stream (Node => Mem) =
                Ada.Streams.Stream_Element_Array'
                  (1 .. 24 => 16#32#),
              Message   => "Fill content mismatch");

      Cmd_Line.Test_Data.Set_Input_Dir (Dir => "data");
      Muxml.Utils.Remove_Child (Node       => Mem,
                                Child_Name => "fill");
      Content := DOM.Core.Documents.Create_Element
        (Doc      => Policy.Doc,
         Tag_Name => "file");
      DOM.Core.Elements.Set_Attribute
        (Elem  => Content,
         Name  => "filename",
         Value => "testfile");
      DOM.Core.Elements.Set_Attribute
        (Elem  => Content,
         Name  => "offset",
         Value => "none");
      Content := DOM.Core.Nodes.Append_Child
        (N         => Mem,
         New_Child => Content);

      declare
         Ref1 : constant Ada.Streams.Stream_Element_Array (1 .. 24)
           := (1      => 16#3a#,
               2      => 16#ae#,
               3      => 16#f3#,
               4      => 16#fb#,
               others => 0);
         Ref2 : constant Ada.Streams.Stream_Element_Array (1 .. 24)
           := (1      => 16#f3#,
               2      => 16#fb#,
               others => 0);
      begin
         Assert (Condition => To_Stream (Node => Mem) = Ref1,
                 Message   => "File content mismatch (1)");

         DOM.Core.Elements.Set_Attribute
           (Elem  => Content,
            Name  => "offset",
            Value => "2");
         Assert (Condition => To_Stream (Node => Mem) = Ref2,
                 Message   => "File content mismatch (2)");
      end;
--  begin read only
   end Test_To_Stream;
--  end read only

end Memhashes.Utils.Test_Data.Tests;