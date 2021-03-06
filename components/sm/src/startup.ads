--
--  Copyright (C) 2020  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2020  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with X86_64;

with Musinfo.Instance;

package Startup
with
   Abstract_State => (State with External => Async_Writers)
is

   --  Initialize runtime environment of monitored subject.
   procedure Setup_Monitored_Subject (Success : out Boolean)
   with
      Global  => (Input  => (State, Musinfo.Instance.State),
                  In_Out => X86_64.State),
      Depends => (Success      => (State, Musinfo.Instance.State),
                  X86_64.State =>+ Musinfo.Instance.State),
      Pre     => Musinfo.Instance.Is_Valid;

end Startup;
