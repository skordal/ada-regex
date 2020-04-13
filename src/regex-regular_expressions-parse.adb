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
   function Parse_Bracket return Syntax_Tree_Node_Access;
   function Parse_Range return Syntax_Tree_Node_Access;

   --  Utility functions:
   function Is_Escapable (C : in Character) return Boolean;

   --  Character range functions:
   type Character_Range_Array is array (Positive range <>) of Character;
   function Range_Contents (Range_Start, Range_End : in Character) return Character_Range_Array;

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

      --  Check for a character range:
      if Buffer.Peek = '[' then
         return Parse_Bracket;
      end if;

      --  Check for escaped character:
      if Buffer.Peek = '\' then
         Buffer.Discard_Next;

         if Buffer.At_End then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": expected character after '\'";
         elsif not Is_Escapable (Buffer.Peek) then
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

   function Parse_Bracket return Syntax_Tree_Node_Access is
      Retval : Syntax_Tree_Node_Access := null;
   begin
      if Buffer.At_End or else Buffer.Peek /= '[' then
         raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
            & ": expected opening bracket '['";
      end if;

      --  Discard the opening '['
      Buffer.Discard_Next;

      declare
         First_Range : constant Syntax_Tree_Node_Access := Parse_Range;
      begin
         Retval := First_Range;
         if First_Range = null then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": expected character range or single character";
         end if;

         loop
            declare
               Left  : constant Syntax_Tree_Node_Access := Retval;
               Right : constant Syntax_Tree_Node_Access := Parse_Range;
            begin
               exit when Right = null;
               Retval := Create_Node (Node_Type   => Alternation,
                                      Id          => Output.Get_Next_Node_Id,
                                      Left_Child  => Left,
                                      Right_Child => Right);
            end;
         end loop;
      end;

      --  Expect a closing ']':
      if Buffer.At_End or else Buffer.Get_Next /= ']' then
         raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
            & ": expected end bracket ']'";
      end if;

      return Retval;
   end Parse_Bracket;

   function Parse_Range return Syntax_Tree_Node_Access is
      Range_Start, Range_End : Character;
   begin
      if Buffer.At_End or else Buffer.Peek = ']' then
         return null;
      end if;

      Range_Start := Buffer.Get_Next;
      if Buffer.At_End or else Buffer.Peek = ']' then
         return Create_Node (Node_Type => Single_Character,
                             Id        => Output.Get_Next_Node_Id,
                             Char      => Range_Start);
      elsif Buffer.Peek = '-' then
         Buffer.Discard_Next;
         if Buffer.At_End then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": expected character after '-' in range";
         elsif Buffer.Peek = '\' then
            raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
               & ": character range cannot contain escaped characters";
         else
            Range_End := Buffer.Get_Next;
         end if;

         --  "Unwrap" the range: create nodes for each character:
         declare
            Retval : Syntax_Tree_Node_Access := null;
         begin
            for C of Range_Contents (Range_Start, Range_End) loop
               if Retval = null then
                  Retval := Create_Node (Node_Type => Single_Character,
                                         Id        => Output.Get_Next_Node_Id,
                                         Char      => C);
               else
                  Retval := Create_Node (Node_Type   => Alternation,
                                         Id          => Output.Get_Next_Node_Id,
                                         Left_Child  => Retval,
                                         Right_Child => Create_Node (
                                            Node_Type => Single_Character,
                                            Id        => Output.Get_Next_Node_Id,
                                            Char      => C));
               end if;
            end loop;
            return Retval;
         end;
      else --  Single character
         if Range_Start = '\' then
            Buffer.Discard_Next;
            if Buffer.At_End then
               raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
                  & ": expected escaped character";
            elsif not Is_Escapable (Buffer.Peek) then
               raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
                  & ": invalid escape sequence";
            end if;

            return Create_Node (Node_Type => Single_Character,
                                Id        => Output.Get_Next_Node_Id,
                                Char      => Buffer.Get_Next);
         else
            return Create_Node (Node_Type => Single_Character,
                                Id        => Output.Get_Next_Node_Id,
                                Char      => Range_Start);
         end if;
      end if;
   end Parse_Range;

   function Is_Escapable (C : in Character) return Boolean is
   begin
      return C = '(' or
             C = ')' or
             C = '[' or
             C = ']' or
             C = '*' or
             C = '.' or
             C = '|' or
             C = '\' or
             C = '+';
   end Is_Escapable;

   function Range_Contents (Range_Start, Range_End : in Character) return Character_Range_Array is
      Start_Value : constant Integer := Character'Pos (Range_Start);
      End_Value   : constant Integer := Character'Pos (Range_End);
   begin
      if Start_Value > End_Value then
         raise Syntax_Error with "at index " & Natural'Image (Buffer.Get_Index)
            & ": invalid character range";
      end if;

      return Retval : Character_Range_Array (1 .. End_Value - Start_Value + 1) do
         for I in 1 .. End_Value - Start_Value + 1 loop
            Retval (I) := Character'Val (Start_Value + I - 1);
         end loop;
      end return;
   end Range_Contents;

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

