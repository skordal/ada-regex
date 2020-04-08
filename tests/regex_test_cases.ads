--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Fixtures;

package Regex_Test_Cases is

   type Test_Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Single_Character  (T : in out Test_Fixture);
   procedure Test_Kleene_Closure    (T : in out Test_Fixture);
   procedure Test_Concatenation     (T : in out Test_Fixture);
   procedure Test_Alternation       (T : in out Test_Fixture);
   procedure Test_Dragon_Example    (T : in out Test_Fixture);
   procedure Test_Any_Char_Single   (T : in out Test_Fixture);
   procedure Test_Any_Char_Optional (T : in out Test_Fixture);

end Regex_Test_Cases;

