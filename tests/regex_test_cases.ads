--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Fixtures;
private with Regex.Regular_Expressions;

package Regex_Test_Cases is

   type Test_Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Single_Character     (T : in out Test_Fixture);
   procedure Test_Kleene_Closure       (T : in out Test_Fixture);
   procedure Test_Concatenation        (T : in out Test_Fixture);
   procedure Test_Alternation_Single   (T : in out Test_Fixture);
   procedure Test_Alternation_Multiple (T : in out Test_Fixture);
   procedure Test_Dragon_Example       (T : in out Test_Fixture);
   procedure Test_Any_Char_Single      (T : in out Test_Fixture);
   procedure Test_Any_Char_Optional    (T : in out Test_Fixture);
   procedure Test_Any_Alternate        (T : in out Test_Fixture);
   procedure Test_Escape_Seqs          (T : in out Test_Fixture);
   procedure Test_Single_Range         (T : in out Test_Fixture);
   procedure Test_Multiple_Ranges      (T : in out Test_Fixture);
   procedure Test_Ranges_And_Chars     (T : in out Test_Fixture);
   procedure Test_Plus_Operator        (T : in out Test_Fixture);
   procedure Test_Hexadecimal          (T : in out Test_Fixture);
   procedure Test_Question_Operator    (T : in out Test_Fixture);
   procedure Test_Partial_Matching     (T : in out Test_Fixture);
   procedure Test_Newlines             (T : in out Test_Fixture);

private
   use Regex.Regular_Expressions;

   procedure Matches_Empty_Strings        (Regex : in Regular_Expression) with Inline;
   procedure Does_Not_Match_Empty_Strings (Regex : in Regular_Expression) with Inline;

   procedure Matches        (Regex : in Regular_Expression;     Matching : in String) with Inline;
   procedure Does_Not_Match (Regex : in Regular_Expression; Not_Matching : in String) with Inline;

end Regex_Test_Cases;

