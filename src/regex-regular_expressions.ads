--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Finalization;
private with Ada.Containers.Vectors;
private with Regex.Syntax_Trees;

package Regex.Regular_Expressions is

   --  Regex engine exceptions:
   Syntax_Error : exception;

   --  Regular expression object:
   type Regular_Expression is new Ada.Finalization.Limited_Controlled with private;

   --  Creates a regular expression object from a regular expression string:
   function Create (Input : in String) return Regular_Expression;

   --  Checks of a string matches a regular expression:
   function Matches (This : in Regular_Expression; Query : in String) return Boolean;

   --  Prints the parse tree for the regular expression:
   procedure Print_Syntax_Tree (This : in Regular_Expression);

   --  Prints the state machine for the regular expression:
   procedure Print_State_Machine (This : in Regular_Expression);

private
   use Regex.Syntax_Trees;

   --  State machine forward declarations:
   type State_Machine_State;
   type State_Machine_State_Access is access all State_Machine_State;

   --  State machine transition object:
   type State_Machine_Transition is record
      Input_Symbol : Character;
      Target_State : State_Machine_State_Access;
   end record;
   package State_Machine_Transition_Vectors is new Ada.Containers.Vectors (
      Element_type => State_Machine_Transition, Index_Type => Positive);

   --  State machine state object:
   type State_Machine_State is record
      Syntax_Tree_Nodes : Syntax_Tree_Node_Sets.Sorted_Set;  --  Syntax tree nodes represented by this state
      Transitions       : State_Machine_Transition_Vectors.Vector; --  Outgoing transitions from this state
      Marked, Accepting : Boolean := False;
   end record;
   package State_Machine_State_Vectors is new Ada.Containers.Vectors (
      Element_Type => State_Machine_State_Access, Index_Type => Positive);

   --  Creates a new, empty state machine state for a specific set of syntax tree nodes,:
   function Create_State (Syntax_Tree_Nodes : in Syntax_Tree_Node_Sets.Sorted_Set)
      return State_Machine_State_Access;

   --  Prints the contents of a state machine state:
   procedure Print_State (This : in State_Machine_State);

   --  Complete regular expression object type:
   type Regular_Expression is new Ada.Finalization.Limited_Controlled with record
      Syntax_Tree : Syntax_Tree_Node_Access := null; --  Syntax tree kept around for debugging
      Syntax_Tree_Node_Count : Natural := 1;         --  Counter used to number nodes and keep count

      State_Machine_States : State_Machine_State_Vectors.Vector := State_Machine_State_Vectors.Empty_Vector;
      Start_State          : State_Machine_State_Access;
   end record;

   --  Frees a regular expression object:
   overriding procedure Finalize (This : in out Regular_Expression);

   --  Gets the next node ID:
   function Get_Next_Node_Id (This : in out Regular_Expression) return Natural with Inline;

   --  Compiles a regular expression into a state machine:
   procedure Compile (Input : in String; Output : in out Regular_Expression);

end Regex.Regular_Expressions;

