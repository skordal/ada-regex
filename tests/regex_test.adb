--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Run;
with AUnit.Reporter.Text;

with Regex_Test_Suite;
with Utilities_Test_Suite;

procedure Regex_Test is
   procedure Regex_Test_Runner is new AUnit.Run.Test_Runner (Regex_Test_Suite.Test_Suite);
   procedure Utilities_Test_Runner is new AUnit.Run.Test_Runner (Utilities_Test_Suite.Test_Suite);
   Test_Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Regex_Test_Runner (Test_Reporter);
   Utilities_Test_Runner (Test_Reporter);
end Regex_Test;

