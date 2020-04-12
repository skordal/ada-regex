--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Assertions;
use  AUnit.Assertions;

with Regex.Regular_Expressions;
use Regex.Regular_Expressions;

package body Regex_Test_Cases is

   procedure Test_Single_Character (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "b");
      Matches (Test_Expr, "a");
   end Test_Single_Character;

   procedure Test_Kleene_Closure (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a*");
   begin
      Matches_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "a");
      Matches (Test_Expr, "aaaaaaaaaaa");
      Does_Not_Match (Test_Expr, "g");
      Does_Not_Match (Test_Expr, "bbsa");
   end Test_Kleene_Closure;

   procedure Test_Concatenation (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("ab");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "a");
      Does_Not_Match (Test_Expr, "b");
      Does_Not_Match (Test_Expr, "abc");
      Matches (Test_Expr, "ab");
   end Test_Concatenation;

   procedure Test_Alternation_Single (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a|b");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "ab");
      Matches (Test_Expr, "a");
      Matches (Test_Expr, "b");
   end Test_Alternation_Single;

   procedure Test_Alternation_Multiple (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a|b|c|d");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "a");
      Matches (Test_Expr, "b");
      Matches (Test_Expr, "c");
      Matches (Test_Expr, "d");
      Does_Not_Match (Test_Expr, "e");
   end Test_Alternation_Multiple;

   procedure Test_Dragon_Example (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      --  Pattern borrowed from the chapter on regular expression parsing in the "Dragon Book":
      Test_Expr : constant Regular_Expression := Create ("(a|b)*abb");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "abbaaabb");
      Matches (Test_Expr, "aabb");
      Matches (Test_Expr, "bbbbabb");
   end Test_Dragon_Example;

   procedure Test_Any_Char_Single (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Expr : constant Regular_Expression := Create ("a.c");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "ac");
      Matches (Test_Expr, "abc");
   end Test_Any_Char_Single;

   procedure Test_Any_Char_Optional (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Expr : constant Regular_Expression := Create (".*");
   begin
      Matches_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "abc");
   end Test_Any_Char_Optional;

   procedure Test_Any_Alternate (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Expr : constant Regular_Expression := Create ("(a|.|b)bc");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "abc");
      Matches (Test_Expr, "bbc");
      Matches (Test_Expr, "fbc");
      Does_Not_Match (Test_Expr, "bc");
   end Test_Any_Alternate;

   procedure Test_Escape_Seqs (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Expr : constant Regular_Expression := Create ("\.|\[|\]|\(|\)|\*|\+|\\|\|");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, ".");
      Matches (Test_Expr, "[");
      Matches (Test_Expr, "]");
      Matches (Test_Expr, "(");
      Matches (Test_Expr, ")");
      Matches (Test_Expr, "*");
      Matches (Test_Expr, "+");
      Matches (Test_Expr, "\");
      Matches (Test_Expr, "|");
   end Test_Escape_Seqs;

   procedure Test_Single_Range (T : in out Test_Fixture) is
      pragma Unreferenced (T);
   begin
      null;
   end Test_Single_Range;

   procedure Test_Multiple_Ranges (T : in out Test_Fixture) is
      pragma Unreferenced (T);
   begin
      null;
   end Test_Multiple_Ranges;

   procedure Test_Ranges_And_Chars (T : in out Test_Fixture) is
      pragma Unreferenced (T);
   begin
      null;
   end Test_Ranges_And_Chars;

   ------ Test utility functions -----

   procedure Matches_Empty_Strings (Regex : in Regular_Expression) is
   begin
      Assert (Regex.Matches (""), "regex does not match the empty string");
   end Matches_Empty_Strings;

   procedure Does_Not_Match_Empty_Strings (Regex : in Regular_Expression) is
   begin
      Assert (not Regex.Matches (""), "regex matches the empty string");
   end Does_Not_Match_Empty_Strings;

   procedure Matches (Regex : in Regular_Expression; Matching : in String) is
   begin
      Assert (Regex.Matches (Matching), "regex does not match correct input string '"
         & Matching & "'");
      null;
   end Matches;

   procedure Does_Not_Match (Regex : in Regular_Expression; Not_Matching : in String) is
   begin
      Assert (not Regex.Matches (Not_Matching), "regex matches incorrect input string '"
         & Not_Matching & "'");
   end Does_Not_Match;

end Regex_Test_Cases;

