--
--  Copyright (C) 2019  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2019  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

package SK.Locks
is

   type Lock_State_Type is (Free, Locked);

   type Spin_Lock_Type is private;

   Free_Lock : constant Spin_Lock_Type;

   --  Spin until Mutex is acquired.
   procedure Acquire (Lock : in out Spin_Lock_Type)
   with
      Post => State (Lock) = Locked;

   --  Release previously acquired Mutex.
   procedure Release (Lock : in out Spin_Lock_Type)
   with
      Pre  => State (Lock) = Locked,
      Post => State (Lock) = Free;

   function State (Lock : Spin_Lock_Type) return Lock_State_Type with Ghost;

private

   for Lock_State_Type use
     (Free   => 0,
      Locked => 1);
   for Lock_State_Type'Size use 32;

   --  Spin lock is implemented as record with a field holding the lock value
   --  since such data types are guaranteed to be passed by reference.
   type Spin_Lock_Type is record
      State : Lock_State_Type;
   end record;

   function State (Lock : Spin_Lock_Type) return Lock_State_Type
   is (Lock.State);

   Free_Lock : constant Spin_Lock_Type := (State => Free);

end SK.Locks;
