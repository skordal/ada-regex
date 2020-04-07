--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Regex.Utilities.Sorted_Sets;
with Regex.Utilities.String_Buffers;

package body Regex.Regular_Expressions is

   function Create (Input : in String) return Regular_Expression is
   begin
      return Retval : Regular_Expression do
         Compile (Input, Retval);
      end return;
   end Create;

   function Matches (This : in Regular_Expression; Query : in String) return Boolean is
      Current_State : State_Machine_State_Access := This.Start_State;
   begin
      for Symbol of Query loop
         declare
            Transition_Found : Boolean := False;
         begin
            Find_Transition : for Transition of Current_State.Transitions loop
               if Transition.Input_Symbol = Symbol then
                  Current_State := Transition.Target_State;
                  Transition_Found := True;
                  exit Find_Transition;
               end if;
            end loop Find_Transition;

            if not Transition_Found then
               return False;
            end if;
         end;
      end loop;

      return Current_State.Accepting;
   end Matches;

   procedure Print_Syntax_Tree (This : in Regular_Expression) is
      use Ada.Text_IO;

      --  Helper functions:
      procedure Print_Set (Set : in Syntax_Tree_Node_Sets.Sorted_Set);
      procedure Print_Node_Recursively (Node : in Syntax_Tree_Node_Access; Indentation : Natural);

      procedure Print_Set (Set : in Syntax_Tree_Node_Sets.Sorted_Set) is
      begin
         Put ("{ ");
         for Element of Set loop
            Put (Natural'Image (Element.Id) & ", ");
         end loop;
         Put ("}");
      end Print_Set;

      procedure Print_Node_Recursively (Node : in Syntax_Tree_Node_Access; Indentation : Natural) is
      begin
         for I in 0 .. Indentation loop
            Put (' ');
         end loop;
         Put ("node " & Natural'Image (Node.Id) & ": ");

         case Node.Node_Type is
            when Acceptance =>
               Put_Line ("accept");
            when Single_Character =>
               Put ("character " & Character'Image (Node.Char)
                  & ", nullable = " & Boolean'Image (Nullable (Node))
                  & ", firstpos = ");
               Print_Set (Firstpos (Node));
               Put (", lastpos = ");
               Print_Set (Lastpos (Node));
               Put (", followpos = ");
               Print_Set (Node.Followpos);
               New_Line;
            when Alternation =>
               Put ("alternation '|', nullable = " & Boolean'Image (Nullable (Node))
                  & ", firstpos = ");
               Print_Set (Firstpos (Node));
               Put (", lastpos = ");
               Print_Set (Lastpos (Node));
               Put (", followpos = ");
               Print_Set (Node.Followpos);
               New_Line;
               Print_Node_Recursively (Node.Left_Child, Indentation + 3);
               Print_Node_Recursively (Node.Right_Child, Indentation + 3);
            when Concatenation =>
               Put ("concatenation, nullable = " & Boolean'Image (Nullable (Node))
                  & ", firstpos = ");
               Print_Set (Firstpos (Node));
               Put (", lastpos = ");
               Print_Set (Lastpos (Node));
               Put (", followpos = ");
               Print_Set (Node.Followpos);
               New_Line;
               Print_Node_Recursively (Node.Left_Child, Indentation + 3);
               Print_Node_Recursively (Node.Right_Child, Indentation + 3);
            when Kleene_Star =>
               Put ("kleene star '*', nullable = " & Boolean'Image (Nullable (Node))
                  & ", firstpos = ");
               Print_Set (Firstpos (Node));
               Put (", lastpos = ");
               Print_Set (Lastpos (Node));
               Put (", followpos = ");
               Print_Set (Node.Followpos);
               New_Line;
               Print_Node_Recursively (Node.Left_Child, Indentation + 3);
         end case;
      end Print_Node_Recursively;
   begin
      Put_Line ("Parse tree:");
      if This.Syntax_Tree = null then
         Put_Line ("   null");
      else
         Print_Node_Recursively (This.Syntax_Tree, 3);
      end if;
   end Print_Syntax_Tree;

   procedure Print_State_Machine (This : in Regular_Expression) is
   begin
      for State of This.State_Machine_States loop
         Print_State (State.all);
      end loop;
   end Print_State_Machine;

   procedure Print_State (This : in State_Machine_State) is
      use Ada.Text_IO;
   begin
      Put ("State machine node for {");
      for Node of This.Syntax_Tree_Nodes loop
         Put (Natural'Image (Node.Id) & ", ");
      end loop;
      Put_Line ("} (accepting = " & Boolean'Image (This.Accepting) & ")");

      for Transition of This.Transitions loop
         Put ("   transition to on " & Character'Image (Transition.Input_Symbol) & " to {");
         for Node of Transition.Target_State.Syntax_Tree_Nodes loop
            Put (Natural'Image (Node.Id) & ", ");
         end loop;
         Put_Line ("}");
      end loop;

   end Print_State;

   procedure Finalize (This : in out Regular_Expression) is
      procedure Free_State is new Ada.Unchecked_Deallocation (State_Machine_State, State_Machine_State_Access);
   begin
      if This.Syntax_Tree /= null then
         Free_Recursively (This.Syntax_Tree);
      end if;

      for State of This.State_Machine_States loop
         Free_State (State);
      end loop;
   end Finalize;

   function Get_Next_Node_Id (This : in out Regular_Expression) return Natural is
      Retval : constant Natural := This.Syntax_Tree_Node_Count;
   begin
      This.Syntax_Tree_Node_Count := This.Syntax_Tree_Node_Count + 1;
      return Retval;
   end Get_Next_Node_Id;

   procedure Compile (Input : in String; Output : in out Regular_Expression) is separate;

end Regex.Regular_Expressions;

