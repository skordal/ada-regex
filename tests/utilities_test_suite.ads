--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Suites;

package Utilities_Test_Suite is

   --  Creates the test suite for the Regex utility packages:
   function Test_Suite return AUnit.Test_Suites.Access_Test_Suite;

end Utilities_Test_Suite;

