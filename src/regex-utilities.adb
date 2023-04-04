--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2023 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Regex.Utilities is

   function Escape (Input : in String) return String is
      Retval : Unbounded_String := Null_Unbounded_String;
   begin
      for C of Input loop
         if C not in '(' | ')' | '[' | ']' | '*' | '.' | '|' | '\' | '+' | '?' | '-' | '$' then
            Retval := Retval & C;
         else
            Retval := Retval & '\' & C;
         end if;
      end loop;

      return To_String (Retval);
   end Escape;

end Regex.Utilities;

