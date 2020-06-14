--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Regex.Regular_Expressions; use Regex.Regular_Expressions;

package Regex.Matchers is

   --  Checks of a string matches a regular expression:
   function Matches (Input : in Regular_Expression; Query : in String) return Boolean;

   --  Gets the first part of a string that matches a regular expression:
   function Get_Match (Input : in Regular_Expression; Query : in String; Complete_Match : out Boolean)
      return String;

end Regex.Matchers;

