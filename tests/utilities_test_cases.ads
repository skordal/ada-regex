--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Fixtures;

package Utilities_Test_Cases is

   type Test_Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Empty_Set  (T : in out Test_Fixture);
   procedure Test_Basic_Ops  (T : in out Test_Fixture);
   procedure Test_Assignment (T : in out Test_Fixture);
   procedure Test_Ordering   (T : in out Test_Fixture);

end Utilities_Test_Cases;

