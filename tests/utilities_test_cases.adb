--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Text_IO;

with AUnit.Assertions;
use AUnit.Assertions;

with Utilities.Sorted_Sets;

package body Utilities_Test_Cases is

   package Integer_Sets is new Utilities.Sorted_Sets (Element_Type => Integer);

   procedure Test_Empty_Set (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Set : Integer_Sets.Sorted_Set := Integer_Sets.Empty_Set;
   begin
      Assert (Test_Set.Length = 0, "Length of an empty set is not 0!");
   end Test_Empty_Set;

   procedure Test_Basic_Ops (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Set : Integer_Sets.Sorted_Set := Integer_Sets.Empty_Set;
   begin
      for I in 1 .. 1000 loop
         Test_Set.Add (I);
      end loop;
      Assert (Test_Set.Length = 1000, "Test_Set length is not 1000!");

      declare
         Expected_Value : Natural := 1;
      begin
         for Value of Test_Set loop
            Assert (Value = Expected_Value, "Values in array does not match expected values");
            Expected_Value := Expected_Value + 1;
         end loop;
      end;
   end Test_Basic_Ops;

   procedure Test_Assignment (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      use type Integer_Sets.Sorted_Set;

      Test_Set : Integer_Sets.Sorted_Set := Integer_Sets.Empty_Set;
      Test_Set_2 : Integer_Sets.Sorted_Set := Integer_Sets.Empty_Set;
   begin
      for I in 0 .. 10 loop
         Test_Set.Add (I);
      end loop;

      Assert (Test_Set_2.Length = 0, "Test_Set_2.Length is not 0!");

      Test_Set_2 := Test_Set;
      Assert (Test_Set_2.Length = Test_Set.Length, "Set lengths do not match");
      Assert (Test_Set_2 = Test_Set, "Set contents do not match according to = operator");
      declare
         Expected_Value : Natural := 0;
      begin
         for Value of Test_Set_2 loop
            Assert (Value = Expected_Value, "Values in copied set does not match expected values");
            Expected_Value := Expected_Value + 1;
         end loop;
      end;
   end Test_Assignment;

   procedure Test_Ordering (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      Test_Set : Integer_Sets.Sorted_Set := Integer_Sets.Empty_Set;
   begin
      for I in reverse 1 .. 1000 loop
         Test_Set.Add (I);
      end loop;
      Assert (Test_Set.Length = 1000, "Test_Set length is not 1000!");

      declare
         Expected_Value : Natural := 1;
      begin
         for Value of Test_Set loop
            Assert (Value = Expected_Value, "Values in array does not match expected values");
            Expected_Value := Expected_Value + 1;
         end loop;
      end;
   end Test_Ordering;

end Utilities_Test_Cases;

