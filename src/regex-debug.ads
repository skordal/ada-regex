--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Regex.State_Machines;
with Regex.Syntax_Trees;

package Regex.Debug is

   --  Prints the parse tree for the regular expression:
   procedure Print_Syntax_Tree (Root : in Regex.Syntax_Trees.Syntax_Tree_Node_Access);

   --  Prints the state machine for the regular expression:
   procedure Print_State_Machine (States : in Regex.State_Machines.State_Machine_State_Vectors.Vector);

private

   --  Prints the contents of a state machine state:
   procedure Print_State (State : in Regex.State_Machines.State_Machine_State);

end Regex.Debug;

