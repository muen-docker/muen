--
--  Copyright (C) 2017  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2017  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

package Ahci.Delays
is

   --  Used to model time passing.
   Time_Passes : Interfaces.Unsigned_64 := 0
   with
      Ghost;

   --  Suspend execution of caller for at least Usec microseconds.
   procedure U_Delay (Usec : Natural)
   with
      Pre    => Musinfo.Instance.Is_Valid,
      Global => (Input  => (Musinfo.Instance.State,
                            Musinfo.Instance.Scheduling_Info),
                 In_Out => Time_Passes);

   --  Suspend execution of caller for at least Msec milliseconds.
   procedure M_Delay (Msec : Natural)
   with
      Pre     => Musinfo.Instance.Is_Valid,
       Global => (Input  => (Musinfo.Instance.State,
                             Musinfo.Instance.Scheduling_Info),
                  In_Out => Time_Passes);

end Ahci.Delays;
