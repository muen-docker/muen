--
--  Copyright (C) 2021  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2021  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Musinfo.Instance;

package ITS.MSRs
is

   --  Write access to read-only MSR.
   procedure Write_To_Read_Only_Register
   with
      Pre => Musinfo.Instance.Is_Valid;

   --  Write access to disallowed MSR.
   procedure Write_To_Disallowed_Register
   with
      Pre => Musinfo.Instance.Is_Valid;

   --  Read access to disallowed MSR.
   procedure Read_From_Disallowed_Register
   with
      Pre => Musinfo.Instance.Is_Valid;

end ITS.MSRs;
