--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

package body Regex.State_Machines is
   use Regex.Syntax_Trees;

   function Create_State (Syntax_Tree_Nodes : in Syntax_Tree_Node_Sets.Sorted_Set) return State_Machine_State_Access is
      Retval : constant State_Machine_State_Access := new State_Machine_State'(
         Syntax_Tree_Nodes => Syntax_Tree_Nodes,
         Transitions => State_Machine_Transition_Vectors.Empty_Vector,
         others => False);
   begin
      return Retval;
   end Create_State;

end Regex.State_Machines;

