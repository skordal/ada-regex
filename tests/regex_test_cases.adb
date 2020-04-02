--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Assertions;
use  AUnit.Assertions;

with Regular_Expressions;
use Regular_Expressions;

package body Regex_Test_Cases is

   procedure Test_Single_Character (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a");
   begin
      Assert (not Test_Expr.Matches (""), "regex matches the empty string");
      Assert (not Test_Expr.Matches ("b"), "regex matches incorrect input string 'b'");
      Assert (Test_Expr.Matches ("a"), "regex does not match the correct input string 'a'");
   end Test_Single_Character;

   procedure Test_Kleene_Closure   (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a*");
   begin
      Assert (Test_Expr.Matches (""), "regex does not match the empty string");
      Assert (Test_Expr.Matches ("a"), "regex does not match the correct input string 'a'");
      Assert (Test_Expr.Matches ("aaaaaaaaaa"), "regex does not match the correct input string 'aaaaaaaaaa'");
      Assert (not Test_Expr.Matches ("g"), "regex matches incorrect input string 'g'");
      Assert (not Test_Expr.Matches ("bbsa"), "regex matches incorrect input string 'bbsa'");
   end Test_Kleene_Closure;

   procedure Test_Concatenation    (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("ab");
   begin
      Assert (not Test_Expr.Matches (""), "regex matches the empty string");
      Assert (not Test_Expr.Matches ("a"), "regex matches incorrect input string 'a'");
      Assert (not Test_Expr.Matches ("b"), "regex matches incorrect input string 'b'");
      Assert (not Test_Expr.Matches ("abc"), "regex matches incorrect input string 'abc'");
      Assert (Test_Expr.Matches ("ab"), "regex does not match correct input string 'ab'");
   end Test_Concatenation;

   procedure Test_Alternation      (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a|b");
   begin
      Assert (not Test_Expr.Matches (""), "regex matches the empty string");
      Assert (not Test_Expr.Matches ("ab"), "regex matches incorrect input string 'ab'");
      Assert (Test_Expr.Matches ("a"), "regex does not match correct input string 'a'");
      Assert (Test_Expr.Matches ("b"), "regex does not match correct input string 'b'");
   end Test_Alternation;

   procedure Test_Dragon_Example   (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      --  Pattern borrowed from the chapter on regular expression parsing in the "Dragon Book":
      Test_Expr : constant Regular_Expression := Create ("(a|b)*abb");
   begin
      Assert (not Test_Expr.Matches (""), "regex matches the empty string");
      Assert (Test_Expr.Matches ("abbaaabb"), "regex does not match correct input string 'abbaaabb'");
      Assert (Test_Expr.Matches ("aabb"), "regex does not match correct input string 'aabb'");
      Assert (Test_Expr.Matches ("bbbbabb"), "regex does not match correct input string 'bbbbabb'");
   end Test_Dragon_Example;

end Regex_Test_Cases;

