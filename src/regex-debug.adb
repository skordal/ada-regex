--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Text_IO;

package body Regex.Debug is

   procedure Print_Syntax_Tree (Root : in Regex.Syntax_Trees.Syntax_Tree_Node_Access) is
      use Ada.Text_IO;
      use Regex.Syntax_Trees;

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
            when Any_Character =>
               Put ("any character, nullable = " & Boolean'Image (Nullable (Node))
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
      if Root = null then
         Put_Line ("   null");
      else
         Print_Node_Recursively (Root, 3);
      end if;
   end Print_Syntax_Tree;

   procedure Print_State_Machine (States : in Regex.State_Machines.State_Machine_State_Vectors.Vector) is
   begin
      for State of States loop
         Print_State (State.all);
      end loop;
   end Print_State_Machine;

   procedure Print_State (State : in Regex.State_Machines.State_Machine_State) is
      use Ada.Text_IO;
      use Regex.State_Machines;
   begin
      Put ("State machine node for {");
      for Node of State.Syntax_Tree_Nodes loop
         Put (Natural'Image (Node.Id) & ", ");
      end loop;
      Put_Line ("} (accepting = " & Boolean'Image (State.Accepting) & ")");

      for Transition of State.Transitions loop
         case Transition.Transition_On.Symbol_Type is
            when Single_Character =>
               Put ("   transition on " & Character'Image (Transition.Transition_On.Char) & " to {");
               for Node of Transition.Target_State.Syntax_Tree_Nodes loop
                  Put (Natural'Image (Node.Id) & ", ");
               end loop;
               Put_Line ("}");
            when Any_Character =>
               Put ("   transition on any character to {");
               for Node of Transition.Target_State.Syntax_Tree_Nodes loop
                  Put (Natural'Image (Node.Id) & ", ");
               end loop;
               Put_Line ("}");
         end case;
      end loop;
   end Print_State;

end Regex.Debug;

