--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

separate (Regex.Regular_Expressions) procedure Compile (Output : in out Regular_Expression) is
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
         package Input_Symbol_Sets is new Utilities.Sorted_Sets (Element_Type => Input_Symbol_Access,
            "<" => Compare_Input_Symbols, "=" => Input_Symbol_Equals);
         use Input_Symbol_Sets;

         Input_Symbols : Sorted_Set := Empty_Set;
      begin
         --  Find all input symbols for this state and determine if it is an accepting state:
         for Syntax_Node of Unmarked_State.Syntax_Tree_Nodes loop
            if Syntax_Node.Node_Type = Single_Character then
               Input_Symbols.Add (new Input_Symbol'(Symbol_Type => Single_Character, Char => Syntax_Node.Char));
            elsif Syntax_Node.Node_Type = Any_Character then
               Input_Symbols.Add (new Input_Symbol'(Symbol_Type => Any_Character));
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
                  if Symbol.Symbol_Type = Single_Character then
                     if Syntax_Node.Node_Type = Single_Character and then Syntax_Node.Char = Symbol.Char then
                        Target_State_Set.Add (Syntax_Node.Followpos);
                     end if;
                  elsif Symbol.Symbol_Type = Any_Character then
                     if Syntax_Node.Node_Type = Any_Character then
                        Target_State_Set.Add (Syntax_Node.Followpos);
                     end if;
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

               Unmarked_State.Transitions.Append (Create_Transition_On_Symbol (Clone (Symbol), Target_State));
            end;
         end loop;
      end;
   end loop;
end Compile;

