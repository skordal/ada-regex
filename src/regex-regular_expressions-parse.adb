--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

separate (Regex.Regular_Expressions) procedure Parse (Input : in String; Output : in out Regular_Expression) is
   use Utilities.String_Buffers;
   Buffer : String_Buffer := Create (Input);

   --  Parse tree generation:
   function Parse_Alternation return Syntax_Tree_Node_Access;
   function Parse_Expression return Syntax_Tree_Node_Access;
   function Parse_Expression_Prime return Syntax_Tree_Node_Access;
   function Parse_Simple_Expression return Syntax_Tree_Node_Access;
   function Parse_Single_Expression return Syntax_Tree_Node_Access;
   function Parse_Element return Syntax_Tree_Node_Access;

   function Parse_Alternation return Syntax_Tree_Node_Access is
      Left, Right : Syntax_Tree_Node_Access;
   begin
      Left := Parse_Expression;
      if not Buffer.At_End and then Buffer.Peek = '|' then
         Buffer.Discard_Next;
         Right := Parse_Alternation;
         if Right = null then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": expected expression after '|' operator";
         else
            declare
               Retval : constant Syntax_Tree_Node_Access := Create_Node (Alternation,
                  Output.Get_Next_Node_Id, Left, Right);
            begin
               return Retval;
            end;
         end if;
      else
         return Left;
      end if;
   end Parse_Alternation;

   function Parse_Expression return Syntax_Tree_Node_Access is
      Left, Right : Syntax_Tree_Node_Access;
   begin
      Left := Parse_Simple_Expression;
      Right := Parse_Expression_Prime;

      if Right = null then
         return Left;
      else
         declare
            Retval : constant Syntax_Tree_Node_Access := Create_Node (Concatenation,
               Output.Get_Next_Node_Id, Left, Right);
         begin
            return Retval;
         end;
      end if;
   end Parse_Expression;

   function Parse_Expression_Prime return Syntax_Tree_Node_Access is
      Left, Right : Syntax_Tree_Node_Access;
   begin
      Left := Parse_Simple_Expression;
      if Left = null then
         return null;
      else
         Right := Parse_Expression_Prime;
         if Right = null then
            return Left;
         else
            declare
               Retval : constant Syntax_Tree_Node_Access := Create_Node (Concatenation,
                  Output.Get_Next_Node_Id, Left, Right);
            begin
               return Retval;
            end;
         end if;
      end if;
   end Parse_Expression_Prime;

   function Parse_Simple_Expression return Syntax_Tree_Node_Access is
      Left : constant Syntax_Tree_Node_Access := Parse_Single_Expression;
   begin
      if not Buffer.At_End and then (Buffer.Peek = '*') then
         declare
            Retval : constant Syntax_Tree_Node_Access := Create_Node (Kleene_Star,
               Output.Get_Next_Node_Id, Left);
         begin
            Buffer.Discard_Next;
            return Retval;
         end;
      else
         return Left;
      end if;
   end Parse_Simple_Expression;

   function Parse_Single_Expression return Syntax_Tree_Node_Access is
   begin
      if not Buffer.At_End and then Buffer.Peek = '(' then
         Buffer.Discard_Next;
         declare
            Retval : constant Syntax_Tree_Node_Access := Parse_Alternation;
         begin
            if Buffer.At_End or else Buffer.Get_Next /= ')' then
               raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
                  & ": expected ')' after expression";
            else
               return Retval;
            end if;
         end;
      else
         return Parse_Element;
      end if;
   end Parse_Single_Expression;

   function Parse_Element return Syntax_Tree_Node_Access is
      Escaped : Boolean := False;
   begin
      if Buffer.At_End or else (
            Buffer.Peek = '(' or
            Buffer.Peek = ')' or
            Buffer.Peek = '|' or
            Buffer.Peek = '*' or
            Buffer.Peek = '+')
      then
         return null;
      end if;

      --  Check for escaped character:
      if Buffer.Peek = '\' then
         Buffer.Discard_Next;

         if Buffer.At_End then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": expected character after '\'";
         elsif Buffer.Peek /= '(' and
               Buffer.Peek /= ')' and
               Buffer.Peek /= '[' and
               Buffer.Peek /= ']' and
               Buffer.Peek /= '*' and
               Buffer.Peek /= '.' and
               Buffer.Peek /= '|' and
               Buffer.Peek /= '\' and
               Buffer.Peek /= '+'
         then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": invalid escaped character " & Character'Image (Buffer.Peek);
         else
            Escaped := True;
         end if;
      end if;

      declare
         Char   : constant Character := Buffer.Get_Next;
         Retval : constant Syntax_Tree_Node_Access := Create_Node (
            (if not Escaped and Char = '.' then Any_Character else Single_Character),
            Output.Get_Next_Node_Id);
      begin
         if Retval.Node_Type = Single_Character then
            Retval.Char := Char;
         end if;

         return Retval;
      end;
   end Parse_Element;

begin
   Output.Syntax_Tree := Parse_Alternation;
   if not Buffer.At_End then
      raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
         & ": invalid trailing characters after regular expression";
   end if;

   --  Add the acceptance node:
   declare
      Acceptance_Node : constant Syntax_Tree_Node_Access := Create_Node (Acceptance,
         Output.Get_Next_Node_Id);
      Toplevel_Node   : constant Syntax_Tree_Node_Access := Create_Node (Concatenation,
         Output.Get_Next_Node_Id, Output.Syntax_Tree, Acceptance_Node);
   begin
      Output.Syntax_Tree := Toplevel_Node;
   end;

   --  Create the followpos() set for each node in the tree:
   Calculate_Followpos (Output.Syntax_Tree);
end Parse;

