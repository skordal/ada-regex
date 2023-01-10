--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020-2021 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Regex_Test_Cases;
with AUnit.Test_Caller;

package body Regex_Test_Suite is

   package Regex_Test_Caller is new AUnit.Test_Caller (Regex_Test_Cases.Test_Fixture);

   function Test_Suite return AUnit.Test_Suites.Access_Test_Suite is
      Retval : constant AUnit.Test_Suites.Access_Test_Suite := new AUnit.Test_Suites.Test_Suite;
   begin
      Retval.Add_Test (Regex_Test_Caller.Create ("single-character",
         Regex_Test_Cases.Test_Single_Character'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("kleene-closure",
         Regex_Test_Cases.Test_Kleene_Closure'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("concatenation",
         Regex_Test_Cases.Test_Concatenation'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("alternation-single",
         Regex_Test_Cases.Test_Alternation_Single'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("alternation-multiple",
         Regex_Test_Cases.Test_Alternation_Multiple'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("dragon-book",
         Regex_Test_Cases.Test_Dragon_Example'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("any-character-single",
         Regex_Test_Cases.Test_Any_Char_Single'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("any-character-optional",
         Regex_Test_Cases.Test_Any_Char_Optional'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("any-alternate",
         Regex_Test_Cases.Test_Any_Alternate'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("escaped-char",
         Regex_Test_Cases.Test_Escape_Seqs'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("quotes",
         Regex_Test_Cases.Test_Quotes'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("single-quotes",
         Regex_Test_Cases.Test_Single_Quotes'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("single-range",
         Regex_Test_Cases.Test_Single_Range'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("multiple-ranges",
         Regex_Test_Cases.Test_Multiple_Ranges'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("ranges-and-chars",
         Regex_Test_Cases.Test_Ranges_And_Chars'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("plus-operator",
         Regex_Test_Cases.Test_Plus_Operator'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("hexadecimal",
         Regex_Test_Cases.Test_Hexadecimal'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("question-mark",
         Regex_Test_Cases.Test_Question_Operator'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("partial-match",
         Regex_Test_Cases.Test_Partial_Matching'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("newlines",
         Regex_Test_Cases.Test_Newlines'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("end-of-line-operator",
         Regex_Test_Cases.Test_End_Of_Line_Operator'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("syntax-tree-compile",
         Regex_Test_Cases.Test_Syntax_Tree_Compile'Access));
      Retval.Add_Test (Regex_Test_Caller.Create ("multiple-accept",
         Regex_Test_Cases.Test_Multiple_Accept'Access));

      return Retval;
   end Test_Suite;

end Regex_Test_Suite;

