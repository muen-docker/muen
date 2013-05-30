with System.Machine_Code;

with SK.CPU;
with SK.Console;
with SK.Console_VGA;
with SK.Hypercall;

with Skp;

with Interrupts;
with Handler;
with Sm_Kernel_Iface;

procedure Sm
is
   use type SK.Word64;

   package SKI renames Sm_Kernel_Iface;

   subtype Width_Type  is Natural range 1 .. 80;
   subtype Height_Type is Natural range 1 .. 25;

   package VGA is new SK.Console_VGA
     (Width_Type   => Width_Type,
      Height_Type  => Height_Type,
      Base_Address => System'To_Address (16#000b_8000#));

   package Text_IO is new SK.Console
     (Initialize      => VGA.Init,
      Output_New_Line => VGA.New_Line,
      Output_Char     => VGA.Put_Char);

   State : SK.Subject_State_Type;
   Id    : Skp.Subject_Id_Type;
begin
   Text_IO.Init;
   Text_IO.Put_Line ("SM subject running");
   Interrupts.Initialize;

   System.Machine_Code.Asm
     (Template => "sti",
      Volatile => True);
   SK.CPU.Hlt;

   loop
      Id    := Handler.Current_Subject;
      State := SKI.Get_Subject_State (Id => Id);

      if State.Exit_Reason = 30 then
         Text_IO.Put_String (Item => "Subject ");
         Text_IO.Put_Byte   (Item => SK.Byte (Id));
         Text_IO.Put_String (Item => ": I/O instruction on port ");
         Text_IO.Put_Word16
           (Item => SK.Word16 (State.Exit_Qualification / 2 ** 16));
         Text_IO.New_Line;
         State.RIP := State.RIP + State.Instruction_Len;
         SKI.Set_Subject_State (Id    => Id,
                                State => State);
         SK.Hypercall.Trigger_Event (Number => SK.Byte (Id));
      else
         Text_IO.New_Line;
         Text_IO.Put_String (Item => "Unhandled trap for subject ");
         Text_IO.Put_Byte   (Item => SK.Byte (Id));
         Text_IO.Put_String (Item => " EXIT (");
         Text_IO.Put_Word16 (Item => SK.Word16 (State.Exit_Reason));
         Text_IO.Put_String (Item => ":");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Exit_Qualification));
         Text_IO.Put_String (Item => ":");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Interrupt_Info));
         Text_IO.Put_Line   (Item => ")");

         Text_IO.Put_String ("EIP: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.RIP));
         Text_IO.Put_String (" CS : ");
         Text_IO.Put_Word16 (Item => SK.Word16 (State.CS));
         Text_IO.Put_String (" EFLAGS: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.RFLAGS));
         Text_IO.New_Line;
         Text_IO.Put_String ("ESP: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.RSP));
         Text_IO.Put_String (" SS : ");
         Text_IO.Put_Word16 (Item => SK.Word16 (State.SS));
         Text_IO.New_Line;

         Text_IO.Put_String (Item => "EAX: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RAX));
         Text_IO.Put_String (Item => " EBX: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RBX));
         Text_IO.Put_String (Item => " ECX: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RCX));
         Text_IO.Put_String (Item => " EDX: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RDX));
         Text_IO.New_Line;

         Text_IO.Put_String (Item => "ESI: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RSI));
         Text_IO.Put_String (Item => " EDI: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RDI));
         Text_IO.Put_String (Item => " EBP: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.Regs.RBP));
         Text_IO.New_Line;

         Text_IO.Put_String (Item => "CR0: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.CR0));
         Text_IO.Put_String (Item => " CR2: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.CR2));
         Text_IO.Put_String (Item => " CR3: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.CR3));
         Text_IO.Put_String (Item => " CR4: ");
         Text_IO.Put_Word32 (Item => SK.Word32 (State.CR4));
         Text_IO.New_Line;

         Text_IO.New_Line;
         Text_IO.Put_Line (Item => "Halting execution");

         loop
            SK.CPU.Hlt;
         end loop;
      end if;
   end loop;
end Sm;
