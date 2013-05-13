with SK;

with Skp.IO_Ports;

package body IO_Port_Tests
is

   use Ahven;
   use Skp;

   -------------------------------------------------------------------------

   procedure Initialize (T : in out Testcase)
   is
   begin
      T.Set_Name (Name => "I/O port tests");
      T.Add_Test_Routine
        (Routine => IO_Bitmap_Handling'Access,
         Name    => "I/O bitmap handling");
   end Initialize;

   -------------------------------------------------------------------------

   procedure IO_Bitmap_Handling
   is
      use type SK.Word16;
      use type IO_Ports.IO_Bitmap_Stream;

      B        : IO_Ports.IO_Bitmap_Type            := IO_Ports.Null_IO_Bitmap;
      Null_Ref : constant IO_Ports.IO_Bitmap_Stream := (others => 16#ff#);
      S_Ref    : IO_Ports.IO_Bitmap_Stream          := (2583   => 16#fe#,
                                                        others => 16#ff#);
   begin
      Assert (Condition => IO_Ports.To_Stream (B => B) = Null_Ref,
              Message   => "Null bitmap allows access");

      IO_Ports.Allow_Ports (B          => B,
                            Start_Port => 16#50b0#,
                            End_Port   => 16#50b0#);
      Assert (Condition => IO_Ports.To_Stream (B => B) = S_Ref,
              Message   => "Error allowing single port");

      IO_Ports.Allow_Ports (B          => B,
                            Start_Port => 16#03d4#,
                            End_Port   => 16#03d5#);
      S_Ref (123) := 16#cf#;
      Assert (Condition => IO_Ports.To_Stream (B => B) = S_Ref,
              Message   => "Error allowing ports");
   end IO_Bitmap_Handling;

end IO_Port_Tests;
