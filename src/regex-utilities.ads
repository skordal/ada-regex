--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020-2023 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

package Regex.Utilities is

   --  Escapes regex operators in an input string:
   function Escape (Input : in String) return String;

end Regex.Utilities;

