--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Fixtures;

package Regex_Test_Cases is

   type Test_Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Simple_Expression (T : in out Test_Fixture);
   procedure Test_Simple_Expression_With_Star (T : in out Test_Fixture);

end Regex_Test_Cases;

