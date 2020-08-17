--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Characters.Latin_1;

with AUnit.Assertions; use AUnit.Assertions;

with Regex.Matchers;            use Regex.Matchers;
with Regex.Regular_Expressions; use Regex.Regular_Expressions;
with Regex.Syntax_Trees;        use Regex.Syntax_Trees;

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
      Test_Expr : constant Regular_Expression := Create ("\.|\[|\]|\(|\)|\*|\+|\\|\||\?|\-");
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
      Matches (Test_Expr, "?");
      Matches (Test_Expr, "-");
   end Test_Escape_Seqs;

   procedure Test_Single_Range (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("[a-c]d");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "a");
      Does_Not_Match (Test_Expr, "b");
      Does_Not_Match (Test_Expr, "c");
      Does_Not_Match (Test_Expr, "abc");
      Does_Not_Match (Test_Expr, "abcd");
      Matches (Test_Expr, "ad");
      Matches (Test_Expr, "bd");
      Matches (Test_Expr, "cd");
   end Test_Single_Range;

   procedure Test_Multiple_Ranges (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("[a-cA-C0-1]");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "_");
      Does_Not_Match (Test_Expr, "aC1");
      Does_Not_Match (Test_Expr, "d");
      Does_Not_Match (Test_Expr, "00");
      Matches (Test_Expr, "a");
      Matches (Test_Expr, "b");
      Matches (Test_Expr, "c");
      Matches (Test_Expr, "A");
      Matches (Test_Expr, "B");
      Matches (Test_Expr, "C");
      Matches (Test_Expr, "0");
      Matches (Test_Expr, "1");
   end Test_Multiple_Ranges;

   procedure Test_Ranges_And_Chars (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("[a-cfA-C_]");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "f_");
      Matches (Test_Expr, "a");
      Matches (Test_Expr, "b");
      Matches (Test_Expr, "c");
      Matches (Test_Expr, "A");
      Matches (Test_Expr, "B");
      Matches (Test_Expr, "C");
      Matches (Test_Expr, "_");
      Matches (Test_Expr, "f");
   end Test_Ranges_And_Chars;

   procedure Test_Plus_Operator (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("ab+");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "a");
      Matches (Test_Expr, "ab");
      Matches (Test_Expr, "abb");
      Matches (Test_Expr, "abbb");
   end Test_Plus_Operator;

   procedure Test_Hexadecimal (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("0(x|X)[0-9a-fA-F]+");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "0");
      Does_Not_Match (Test_Expr, "00");
      Does_Not_Match (Test_Expr, "0x");
      Does_Not_Match (Test_Expr, "0X");
      Matches (Test_Expr, "0x0");
      Matches (Test_Expr, "0xabcd1234");
      Matches (Test_Expr, "0xdeadbeef");
   end Test_Hexadecimal;

   procedure Test_Question_Operator (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("a?b");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "ab");
      Matches (Test_Expr, "b");
      Does_Not_Match (Test_Expr, "aab");
      Does_Not_Match (Test_Expr, "abb");
      Does_Not_Match (Test_Expr, "aa");
      Does_Not_Match (Test_Expr, "bb");
   end Test_Question_Operator;

   procedure Test_Partial_Matching (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("abc");
   begin
      declare
         Complete : Boolean;
         Partial_Match : constant String := Get_Match (Test_Expr, "abff", Complete);
      begin
         Assert (not Complete, "partial match is reported as complete match");
         Assert (Partial_Match = "ab", "partial match is incorrect");
      end;

      declare
         Complete : Boolean;
         Full_Match : constant String := Get_Match (Test_Expr, "abcdef", Complete);
      begin
         Assert (Complete, "full match is reported as incomplete match");
         Assert (Full_Match = "abc", "full match is incorrect");
      end;

      declare
         Complete : Boolean;
         No_Match : constant String := Get_Match (Test_Expr, "bbdd", Complete);
      begin
         Assert (not Complete, "no match is reported as complete match");
         Assert (No_Match'Length = 0, "incorrect partial match for string that should not match");
      end;
   end Test_Partial_Matching;

   procedure Test_Newlines (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Test_Expr : constant Regular_Expression := Create ("aab\n|bc\r|df\r\n");
   begin
      Does_Not_Match_Empty_Strings (Test_Expr);
      Does_Not_Match (Test_Expr, "aab");
      Does_Not_Match (Test_Expr, "bc");
      Does_Not_Match (Test_Expr, "df");

      Does_Not_Match (Test_Expr, "aab" & Ada.Characters.Latin_1.CR);
      Matches (Test_Expr, "aab" & Ada.Characters.Latin_1.LF);

      Does_Not_Match (Test_Expr, "bc" & Ada.Characters.Latin_1.LF);
      Matches (Test_Expr, "bc" & Ada.Characters.Latin_1.CR);

      Does_Not_Match (Test_Expr, "df" & Ada.Characters.Latin_1.LF);
      Does_Not_Match (Test_Expr, "df" & Ada.Characters.Latin_1.CR);
      Matches (Test_Expr, "df" & Ada.Characters.Latin_1.CR & Ada.Characters.Latin_1.LF);
   end Test_Newlines;

   procedure Test_Syntax_Tree_Compile (T : in out Test_Fixture) is
      pragma Unreferenced (T);
      Original_Expression : constant Regular_Expression := Create ("abc|ef");
      Test_Tree : Syntax_Tree_Node_Access := Clone_Tree (Original_Expression.Get_Syntax_Tree);
      Test_Expr : constant Regular_Expression := Create (Test_Tree);
   begin
      Free_Recursively (Test_Tree);

      Does_Not_Match_Empty_Strings (Test_Expr);
      Matches (Test_Expr, "abc");
      Matches (Test_Expr, "ef");
   end Test_Syntax_Tree_Compile;

   procedure Test_Multiple_Accept (T : in out Test_Fixture) is
      pragma Unreferenced (T);

      First_Expression  : constant Regular_Expression := Create ("abc");
      Second_Expression : constant Regular_Expression := Create ("def");
   begin

      Get_Acceptance_Node (First_Expression.Get_Syntax_Tree).Acceptance_Id := 1;
      Get_Acceptance_Node (Second_Expression.Get_Syntax_Tree).Acceptance_Id := 2;

      declare
         Id_Counter : Natural := 1;
         Combined_Tree : Syntax_Tree_Node_Access := Create_Node (
            Node_Type => Alternation,
            Id        => 0,
            Left_Child => Clone_Tree (First_Expression.Get_Syntax_Tree, Id_Counter),
            Right_Child => Clone_Tree (Second_Expression.Get_Syntax_Tree, Id_Counter));
         Test_Expr : constant Regular_Expression := Create (Combined_Tree);
      begin
         Free_Recursively (Combined_Tree);

         Does_Not_Match_Empty_Strings (Test_Expr);
         Matches (Test_Expr, "abc", 1);
         Matches (Test_Expr, "def", 2);
      end;

   end Test_Multiple_Accept;

   ------ Test utility functions -----

   procedure Matches_Empty_Strings (Regex : in Regular_Expression) is
   begin
      Assert (Matches (Regex, ""), "regex does not match the empty string");
   end Matches_Empty_Strings;

   procedure Does_Not_Match_Empty_Strings (Regex : in Regular_Expression) is
   begin
      Assert (not Matches (Regex, ""), "regex matches the empty string");
   end Does_Not_Match_Empty_Strings;

   procedure Matches (Regex : in Regular_Expression; Matching : in String) is
   begin
      Assert (Matches (Regex, Matching), "regex does not match correct input string '"
         & Matching & "'");
   end Matches;

   procedure Matches (Regex : in Regular_Expression; Matching : in String; Expected_Id : in Natural) is
      Match_Id : Natural;
   begin
      Assert (Matches (Regex, Matching, Match_Id), "regex does not match correct input string '"
         & Matching & "'");
      Assert (Match_Id = Expected_Id, "expected match ID ( " & Natural'Image (Expected_Id)
         & ") does not match actual match ID (" & Natural'Image (Match_Id) & ")");
   end Matches;

   procedure Does_Not_Match (Regex : in Regular_Expression; Not_Matching : in String) is
   begin
      Assert (not Matches (Regex, Not_Matching), "regex matches incorrect input string '"
         & Not_Matching & "'");
   end Does_Not_Match;

end Regex_Test_Cases;

