--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Assertions;
use  AUnit.Assertions;

with Regular_Expressions;
use Regular_Expressions;

package body Regex_Test_Cases is

   procedure Test_Simple_Expression (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : Regular_Expression := Create ("abc");
   begin
      Assert (not Test_Expr.Matches (""), "Regex should not match the empty string");
      Assert (not Test_Expr.Matches ("abcd"), "Test string """"abcd"""" matches regex but should not");
      Assert (Test_Expr.Matches ("abc"), "Test string """"abc"""" should match regex but does not");
   end Test_Simple_Expression;

   procedure Test_Simple_Expression_With_Star (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : Regular_Expression := Create ("(a|b)*abb");
   begin
      Assert (not Test_Expr.Matches (""), "Regex should not match the empty string");
      Assert (Test_Expr.Matches ("abbaaabb"), "Regex should match """"abbaaabb"""" but does not");
      Assert (Test_Expr.Matches ("aabb"), "Regex should match """"aabb"""" but does not");
      Assert (Test_Expr.Matches ("bbbbabb"), "Regex should match """"bbbbabb"""" but does not");
   end Test_Simple_Expression_With_Star;

end Regex_Test_Cases;

