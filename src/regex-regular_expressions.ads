--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

private with Ada.Finalization;
private with Regex.Syntax_Trees;
private with Regex.State_Machines;

package Regex.Regular_Expressions is

   --  Regex engine exceptions:
   Syntax_Error        : exception;
   Unsupported_Feature : exception;

   --  Regular expression object:
   type Regular_Expression is tagged limited private;

   --  Creates a regular expression object from a regular expression string:
   function Create (Input : in String) return Regular_Expression;

   --  Checks of a string matches a regular expression:
   function Matches (This : in Regular_Expression; Query : in String) return Boolean;

private
   use Regex.State_Machines;
   use Regex.Syntax_Trees;

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

