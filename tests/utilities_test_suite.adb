--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with AUnit.Test_Caller;
with Regex.Utilities_Test_Cases;

package body Utilities_Test_Suite is

   function Test_Suite return AUnit.Test_Suites.Access_Test_Suite is
      package Utilities_Test_Caller is new AUnit.Test_Caller (Regex.Utilities_Test_Cases.Test_Fixture);
      Retval : constant AUnit.Test_Suites.Access_Test_Suite := new AUnit.Test_Suites.Test_Suite;
   begin
      Retval.Add_Test (Utilities_Test_Caller.Create ("empty-set",
         Regex.Utilities_Test_Cases.Test_Empty_Set'Access));
      Retval.Add_Test (Utilities_Test_Caller.Create ("basic-ops",
         Regex.Utilities_Test_Cases.Test_Basic_Ops'Access));
      Retval.Add_Test (Utilities_Test_Caller.Create ("assignment",
         Regex.Utilities_Test_Cases.Test_Assignment'Access));
      Retval.Add_Test (Utilities_Test_Caller.Create ("ordering",
         Regex.Utilities_Test_Cases.Test_Ordering'Access));
      return Retval;
   end Test_Suite;

end Utilities_Test_Suite;

