--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Suites;

package Regex_Test_Suite is

   --  Creates the Regex library test suite:
   function Test_Suite return AUnit.Test_Suites.Access_Test_Suite;

end Regex_Test_Suite;

