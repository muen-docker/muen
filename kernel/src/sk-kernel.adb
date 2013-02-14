with System.Machine_Code;

with SK.Console;
with SK.Version;
with SK.Debug;
with SK.Interrupts;
with SK.System_State;
with SK.VMX;
with SK.CPU;

package body SK.Kernel
is

   -------------------------------------------------------------------------

   procedure Main
   is
      Success : Boolean;
   begin
      pragma Debug
        (SK.Console.Put_Line
           (Item => "Booting Separation Kernel ("
            & SK.Version.Version_String & ") ..."));

      --  Setup IDT.

      Interrupts.Init;
      Interrupts.Load;

      Success := System_State.Is_Valid;
      if Success then
         VMX.Enable;
      else
         pragma Debug
           (SK.Console.Put_Line
              (Item => "System initialisation error"));
         null;
      end if;

      pragma Debug
        (SK.Console.Put_Line
           (Item => "Terminating"));
   end Main;

end SK.Kernel;
