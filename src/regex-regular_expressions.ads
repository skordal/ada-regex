--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Finalization;
private with Ada.Containers.Vectors;
private with Regex.Utilities.Sorted_Sets;

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

   --  Parse tree node:
   type Syntax_Tree_Node;
   type Syntax_Tree_Node_Access is access all Syntax_Tree_Node;

   function "<" (Left, Right : in Syntax_Tree_Node_Access) return Boolean;
   package Syntax_Tree_Node_Sets is new Utilities.Sorted_Sets (
      Element_Type => Syntax_Tree_Node_Access);

   type Syntax_Tree_Node_Type is (
      Acceptance,
      Single_Character,
      Alternation,
      Concatenation,
      Kleene_Star);
   type Syntax_Tree_Node (Node_Type : Syntax_Tree_Node_Type) is record
      Left_Child, Right_Child : Syntax_Tree_Node_Access;
      Id : Natural := 0;
      Followpos : Syntax_Tree_Node_Sets.Sorted_Set;
      case Node_Type is
         when Single_Character =>
            Char : Character;
         when others =>
            null;
      end case;
   end record;

   --  Allocates and initializes a syntax tree node:
   function Create_Node (Node_Type : in Syntax_Tree_Node_Type; Id : in Natural;
      Left_Child, Right_Child : in Syntax_Tree_Node_Access := null; Char : in Character := Character'Val (0))
   return Syntax_Tree_Node_Access;

   --  Frees a syntax tree recursively:
   procedure Free_Recursively (Root_Node : in out Syntax_Tree_Node_Access);

   --  Computes the nullable() function for the specified node:
   function Nullable (Node : in Syntax_Tree_Node_Access) return Boolean;

   --  Computes the firstpos() function for the specified node:
   function Firstpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set;

   --  Computes the lastpos() function for the specified node:
   function Lastpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set;

   --  Calculates the followpos() function for all nodes in the specified tree:
   procedure Calculate_Followpos (Tree : in Syntax_Tree_Node_Access);

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

