--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Fixtures;

--  The Regex.Utilities package is a private subpackage of Regex, thus
--  this test package must also be a subpackage of Regex.
package Regex.Utilities_Test_Cases is

   type Test_Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Empty_Set  (T : in out Test_Fixture);
   procedure Test_Basic_Ops  (T : in out Test_Fixture);
   procedure Test_Assignment (T : in out Test_Fixture);
   procedure Test_Ordering   (T : in out Test_Fixture);

end Regex.Utilities_Test_Cases;

