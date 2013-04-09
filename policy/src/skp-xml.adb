with Ada.Exceptions;

with DOM.Core.Nodes;
with DOM.Core.Elements;
with DOM.Core.Documents;
with Input_Sources.File;
with Sax.Readers;
with Schema.Dom_Readers;
with Schema.Validators;

with Skp.Xml.Util;
with Skp.Xml.Grammar;
with Skp.Validators;

package body Skp.Xml
is

   use Ada.Strings.Unbounded;

   package DR renames Schema.Dom_Readers;
   package SV renames Schema.Validators;

   --  Convert given hex string to word64.
   function To_Word64 (Hex : String) return SK.Word64;

   --  Deserialize memory layout from XML data.
   function Deserialize_Mem_Layout
     (Node : DOM.Core.Node)
      return Memory_Layout_Type;

   --  Deserialize I/O ports from XML data.
   function Deserialize_Ports (Node : DOM.Core.Node) return IO_Ports_Type;

   -------------------------------------------------------------------------

   function Deserialize_Mem_Layout
     (Node : DOM.Core.Node)
      return Memory_Layout_Type
   is
      Mem_Layout : Memory_Layout_Type;

      --  Add memory region to memory layout.
      procedure Add_Mem_Region (Node : DOM.Core.Node);

      ----------------------------------------------------------------------

      procedure Add_Mem_Region (Node : DOM.Core.Node)
      is
         R      : Memory_Region_Type;
         PM     : SK.Word64;
         VM     : SK.Word64;
         VM_Str : constant String := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "virtual_address");
      begin
         PM := To_Word64
           (Hex => DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "physical_address"));

         if VM_Str'Length = 0 then
            VM := PM;
         else
            VM := To_Word64 (Hex => VM_Str);
         end if;

         R.Physical_Address := PM;
         R.Virtual_Address  := VM;
         R.Size             := Util.To_Memory_Size
           (Str => DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "size"));
         R.Alignment        := Util.To_Memory_Size
           (Str => DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "alignment"));
         R.Writable         := Boolean'Value
           (DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "writable"));

         R.Executable       := Boolean'Value
           (DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "executable"));

         Validators.Validate (Region => R);
         Mem_Layout.Append (New_Item => R);
      end Add_Mem_Region;
   begin
      Util.For_Each_Node (Node     => Node,
                          Tag_Name => "memory_region",
                          Process  => Add_Mem_Region'Access);

      return Mem_Layout;
   end Deserialize_Mem_Layout;

   -------------------------------------------------------------------------

   function Deserialize_Ports (Node : DOM.Core.Node) return IO_Ports_Type
   is
      Ports : IO_Ports_Type;

      --  Add I/O port range to I/O ports.
      procedure Add_Port_Range (Node : DOM.Core.Node);

      ----------------------------------------------------------------------

      procedure Add_Port_Range (Node : DOM.Core.Node)
      is
         P_Range        : IO_Port_Range;
         Start_Port_Str : constant String := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "start");
         End_Port_Str   : constant String := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "end");
      begin
         P_Range.Start_Port := SK.Word16 (To_Word64 (Hex => Start_Port_Str));

         if End_Port_Str'Length = 0 then
            P_Range.End_Port := P_Range.Start_Port;
         else
            P_Range.End_Port := SK.Word16 (To_Word64 (Hex => End_Port_Str));
         end if;

         Ports.Append (New_Item => P_Range);
      end Add_Port_Range;
   begin
      Util.For_Each_Node (Node     => Node,
                          Tag_Name => "io_port",
                          Process  => Add_Port_Range'Access);
      return Ports;
   end Deserialize_Ports;

   -------------------------------------------------------------------------

   procedure Finalize (Object : in out XML_Data_Type)
   is
   begin
      DOM.Core.Nodes.Free (N => Object.Doc);
   end Finalize;

   -------------------------------------------------------------------------

   procedure Parse
     (Data   : in out XML_Data_Type;
      File   :        String;
      Schema :        String)
   is
      Reader     : DR.Tree_Reader;
      File_Input : Input_Sources.File.File_Input;
   begin
      Reader.Set_Grammar (Grammar => Grammar.Get_Grammar (File => Schema));
      Reader.Set_Feature (Name  => Sax.Readers.Schema_Validation_Feature,
                          Value => True);

      begin
         Input_Sources.File.Open (Filename => File,
                                  Input    => File_Input);

         begin
            Reader.Parse (Input => File_Input);

         exception
            when others =>
               Input_Sources.File.Close (Input => File_Input);
               Reader.Free;
               raise;
         end;

         Input_Sources.File.Close (Input => File_Input);
         Data.Doc := Reader.Get_Tree;

      exception
         when SV.XML_Validation_Error =>
            raise Processing_Error with "XML validation error - "
              & Reader.Get_Error_Message;
         when E : others =>
            raise Processing_Error with "Error reading XML file '" & File
              & "' - " & Ada.Exceptions.Exception_Message (X => E);
      end;
   end Parse;

   -------------------------------------------------------------------------

   function To_Policy (Data : XML_Data_Type) return Policy_Type
   is

      package DCD renames DOM.Core.Documents;

      Root   : constant DOM.Core.Node := DCD.Get_Element (Doc => Data.Doc);
      Policy : Policy_Type;

      --  Add subject specification to policy.
      procedure Add_Subject (Node : DOM.Core.Node);

      ----------------------------------------------------------------------

      procedure Add_Subject (Node : DOM.Core.Node)
      is
         Name     : constant String  := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "name");
         Id_Str   : constant String  := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "id");
         Id       : constant Natural := Natural'Value (Id_Str);
         PML4_Str : constant String  := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "pml4_address");
         IOBM_Str : constant String  := DOM.Core.Elements.Get_Attribute
           (Elem => Node,
            Name => "io_bitmap_address");
         Ports    : IO_Ports_Type;
         State    : Initial_State_Type;
         Subj_Mem : Memory_Layout_Type;

         --  Add device ressources (memory and I/O ports) to subject.
         procedure Add_Device (Node : DOM.Core.Node);

         -------------------------------------------------------------------

         procedure Add_Device (Node : DOM.Core.Node)
         is
            Dev      : Device_Type;
            Dev_Name : constant Unbounded_String := To_Unbounded_String
              (DOM.Core.Elements.Get_Attribute
                 (Elem => Node,
                  Name => "name"));
         begin
            Dev := Policy.Hardware.Devices.Element (Key => Dev_Name);
            Subj_Mem.Splice (Before => Memregion_Package.No_Element,
                             Source => Dev.Memory_Layout);
            Ports.Splice (Before => Ports_Package.No_Element,
                          Source => Dev.IO_Ports);

         exception
            when others =>
               raise Processing_Error with "No hardware device with name '"
                 & To_String (Dev_Name) & "'";
         end Add_Device;
      begin
         Subj_Mem := Deserialize_Mem_Layout (Node => Node);

         Util.For_Each_Node (Node     => Node,
                             Tag_Name => "device",
                             Process  => Add_Device'Access);

         State.Stack_Address := To_Word64
           (Hex => Util.Get_Element_Attr_By_Tag_Name
              (Node      => Node,
               Tag_Name  => "initial_state",
               Attr_Name => "stack_address"));
         State.Entry_Point := To_Word64
           (Hex => Util.Get_Element_Attr_By_Tag_Name
              (Node      => Node,
               Tag_Name  => "initial_state",
               Attr_Name => "entry_point"));
         Policy.Subjects.Insert
           (New_Item =>
              (Id                => Id,
               Name              => To_Unbounded_String (Name),
               Pml4_Address      => To_Word64 (Hex => PML4_Str),
               IO_Bitmap_Address => To_Word64 (Hex => IOBM_Str),
               Init_State        => State,
               Memory_Layout     => Subj_Mem,
               IO_Ports          => Ports));

      exception
         when E : others =>
            Ada.Exceptions.Raise_Exception
              (E       => Ada.Exceptions.Exception_Identity (X => E),
               Message => "Subject " & Name & ": "
               & Ada.Exceptions.Exception_Message (X => E));
      end Add_Subject;
   begin
      Policy.Vmxon_Address := To_Word64
        (Hex => Util.Get_Element_Attr_By_Tag_Name
           (Node      => Root,
            Tag_Name  => "system",
            Attr_Name => "vmxon_address"));
      Policy.Vmcs_Start_Address := To_Word64
        (Hex => Util.Get_Element_Attr_By_Tag_Name
           (Node      => Root,
            Tag_Name  => "system",
            Attr_Name => "vmcs_start_address"));

      declare
         HW_Node : constant DOM.Core.Node
           := Xml.Util.Get_Element_By_Tag_Name
             (Node     => Root,
              Tag_Name => "hardware");

         --  Add device to hardware policy.
         procedure Add_Device (Node : DOM.Core.Node);

         -------------------------------------------------------------------

         procedure Add_Device (Node : DOM.Core.Node)
         is
            Name : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "name");
            Dev  : Device_Type;
         begin
            Dev.Name          := To_Unbounded_String (Name);
            Dev.Memory_Layout := Deserialize_Mem_Layout (Node => Node);
            Dev.IO_Ports      := Deserialize_Ports (Node => Node);

            Policy.Hardware.Devices.Insert
              (Key      => Dev.Name,
               New_Item => Dev);
         end Add_Device;
      begin
         Util.For_Each_Node (Node     => HW_Node,
                             Tag_Name => "device",
                             Process  => Add_Device'Access);
      end;

      declare
         Kernel_Node : constant DOM.Core.Node
           := Xml.Util.Get_Element_By_Tag_Name
             (Node     => Root,
              Tag_Name => "kernel");
      begin
         Policy.Kernel.Stack_Address := To_Word64
           (Hex => Util.Get_Element_Attr_By_Tag_Name
              (Node      => Root,
               Tag_Name  => "kernel",
               Attr_Name => "stack_address"));
         Policy.Kernel.Pml4_Address := To_Word64
           (Hex => Util.Get_Element_Attr_By_Tag_Name
              (Node      => Root,
               Tag_Name  => "kernel",
               Attr_Name => "pml4_address"));
         Policy.Kernel.Memory_Layout := Deserialize_Mem_Layout
           (Node => Kernel_Node);
      end;

      declare
         Bin_Node : constant DOM.Core.Node
           := Xml.Util.Get_Element_By_Tag_Name
             (Node     => Root,
              Tag_Name => "binaries");

         --  Add binary to policy.
         procedure Add_Binary (Node : DOM.Core.Node);

         -------------------------------------------------------------------

         procedure Add_Binary (Node : DOM.Core.Node)
         is
            Path : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "path");
            Addr : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "physical_address");
         begin
            Policy.Binaries.Append
              (New_Item => (Path             => To_Unbounded_String (Path),
                            Physical_Address => To_Word64 (Hex => Addr)));
         end Add_Binary;
      begin
         Util.For_Each_Node (Node     => Bin_Node,
                             Tag_Name => "binary",
                             Process  => Add_Binary'Access);
      end;

      Util.For_Each_Node (Node     => Root,
                          Tag_Name => "subject",
                          Process  => Add_Subject'Access);

      Validators.Validate (Policy => Policy);
      return Policy;
   end To_Policy;

   -------------------------------------------------------------------------

   function To_Word64 (Hex : String) return SK.Word64
   is
   begin
      return SK.Word64'Value ("16#" & Hex & "#");
   end To_Word64;

end Skp.Xml;
