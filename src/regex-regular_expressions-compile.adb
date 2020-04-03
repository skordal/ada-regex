--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

separate (Regex.Regular_Expressions) procedure Compile (Input : in String; Output : in out Regular_Expression) is
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
         Right := Parse_Expression;
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

      declare
         Retval : constant Syntax_Tree_Node_Access := Create_Node (Single_Character,
            Output.Get_Next_Node_Id, Char => Buffer.Get_Next);
      begin
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

   --  Create the state machine:
   declare
      Start_State : constant State_Machine_State_Access := Create_State (Firstpos (Output.Syntax_Tree));
      Unmarked_State : State_Machine_State_Access := null;
   begin
      Output.State_Machine_States.Append (Start_State);
      Output.Start_State := Start_State;

      loop
         Unmarked_State := null;

         Find_Unmarked_State_Loop : for State of Output.State_Machine_States loop
            if State.Marked = False then
               Unmarked_State := State;
               exit Find_Unmarked_State_Loop;
            end if;
         end loop Find_Unmarked_State_Loop;
         exit when Unmarked_State = null;

         --  Mark state:
         Unmarked_State.Marked := True;
         declare
            package Input_Symbol_Sets is new Utilities.Sorted_Sets (Element_Type => Character);
            use Input_Symbol_Sets;

            Input_Symbols : Sorted_Set := Empty_Set;
         begin
            --  Find all input symbols for this state and determine if it is an accepting state:
            for Syntax_Node of Unmarked_State.Syntax_Tree_Nodes loop
               if Syntax_Node.Node_Type = Single_Character then
                  Input_Symbols.Add (Syntax_Node.Char);
               elsif Syntax_Node.Node_Type = Acceptance then
                  Unmarked_State.Accepting := True;
               end if;
            end loop;

            --  Create transitions for each input symbol:
            for Symbol of Input_Symbols loop
               declare
                  use type Syntax_Tree_Node_Sets.Sorted_Set;
                  Target_State_Set : Syntax_Tree_Node_Sets.Sorted_Set := Syntax_Tree_Node_Sets.Empty_Set;
                  Target_State : State_Machine_State_Access := null;
               begin
                  for Syntax_Node of Unmarked_State.Syntax_Tree_Nodes loop
                     if Syntax_Node.Node_Type = Single_Character and then Syntax_Node.Char = Symbol then
                        Target_State_Set.Add (Syntax_Node.Followpos);
                     end if;
                  end loop;

                  --  Find or create the target node:
                  Find_Target_State_Loop : for State of Output.State_Machine_States loop
                     if State.Syntax_Tree_Nodes = Target_State_Set then
                        Target_State := State;
                        exit Find_Target_State_Loop;
                     end if;
                  end loop Find_Target_State_Loop;

                  if Target_State = null then
                     Target_State := Create_State (Target_State_Set);
                     Output.State_Machine_States.Append (Target_State);
                  end if;

                  Unmarked_State.Transitions.Append ((Symbol, Target_State));
               end;
            end loop;
         end;
      end loop;
   end;
end Compile;

