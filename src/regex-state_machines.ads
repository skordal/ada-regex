--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Containers.Vectors;
with Ada.Finalization;
with Regex.Syntax_Trees;

package Regex.State_Machines is

   --  Input symbol type:
   type Input_Symbol_Type is (Single_Character, Any_Character, Character_Range);
   type Input_Symbol (Symbol_Type : Input_Symbol_Type) is record
      case Symbol_Type is
         when Single_Character =>
            Char : Character;
         when others =>
            null;
      end case;
   end record;
   type Input_Symbol_Access is access all Input_Symbol;

   --  State machine forward declarations:
   type State_Machine_State;
   type State_Machine_State_Access is access all State_Machine_State;

   --  State machine transition object:
   type State_Machine_Transition is new Ada.Finalization.Controlled with record
      Transition_On : Input_Symbol_Access;
      Target_State  : State_Machine_State_Access;
   end record;

   function Create_Transition_On_Character (Input_Char : in Character;
                                            Target_State : in State_Machine_State_Access)
      return State_Machine_Transition;

   overriding procedure Adjust   (This : in out State_Machine_Transition);
   overriding procedure Finalize (This : in out State_Machine_Transition);

   package State_Machine_Transition_Vectors is new Ada.Containers.Vectors (
      Element_type => State_Machine_Transition, Index_Type => Positive);

   --  State machine state object:
   type State_Machine_State is record
      --  Syntax tree nodes represented by this state:
      Syntax_Tree_Nodes : Regex.Syntax_Trees.Syntax_Tree_Node_Sets.Sorted_Set;
      --  Outgoing transitions from this state:
      Transitions       : State_Machine_Transition_Vectors.Vector;

      Marked, Accepting : Boolean := False;
   end record;
   package State_Machine_State_Vectors is new Ada.Containers.Vectors (
      Element_Type => State_Machine_State_Access, Index_Type => Positive);

   --  Creates a new, empty state machine state for a specific set of syntax tree nodes,:
   function Create_State (Syntax_Tree_Nodes : in Regex.Syntax_Trees.Syntax_Tree_Node_Sets.Sorted_Set)
      return State_Machine_State_Access;

end Regex.State_Machines;

