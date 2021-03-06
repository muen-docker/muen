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

with DOM.Core;

with Cmd_Stream.Utils;

package Cmd_Stream.Roots.Subjects
is

   --  Generate command stream to create subjects of given system policy.
   procedure Create_Subjects
     (Policy     : in out Muxml.XML_Data_Type;
      Stream_Doc : in out Utils.Stream_Document_Type;
      Phys_Mem   :        DOM.Core.Node_List;
      Phys_Devs  :        DOM.Core.Node_List);

end Cmd_Stream.Roots.Subjects;
