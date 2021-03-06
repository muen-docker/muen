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

with Mucontrol.Status.Instance;

package body Init.Status
is

   -------------------------------------------------------------------------

   procedure Error
     (Diagnostic : Mucontrol.Status.Diagnostics_Type
      := Mucontrol.Status.DIAG_OK)
   is
      use type Mucontrol.Status.Diagnostics_Type;
   begin
      if Diagnostic /= Mucontrol.Status.DIAG_OK then
         Mucontrol.Status.Instance.Set_Diagnostics (Value => Diagnostic);
      end if;
      Mucontrol.Status.Instance.Error;
   end Error;

   -------------------------------------------------------------------------

   procedure Initialize renames Mucontrol.Status.Instance.Initialize;

   -------------------------------------------------------------------------

   procedure Set
     (New_State : Mucontrol.Status.State_Type)
      renames Mucontrol.Status.Instance.Set;

   -------------------------------------------------------------------------

   procedure Set_Diagnostics (Value : Mucontrol.Status.Diagnostics_Type)
      renames Mucontrol.Status.Instance.Set_Diagnostics;

end Init.Status;
