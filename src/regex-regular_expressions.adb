--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Unchecked_Deallocation;
with Regex.Utilities.Sorted_Sets;
with Regex.Utilities.String_Buffers;

package body Regex.Regular_Expressions is

   function Create (Input : in String) return Regular_Expression is
   begin
      return Retval : Regular_Expression do
         Parse (Input, Retval);
         Compile (Retval);
      end return;
   end Create;

   function Get_Syntax_Tree (This : in Regular_Expression)
      return Regex.Syntax_Trees.Syntax_Tree_Node_Access is
   begin
      return This.Syntax_Tree;
   end Get_Syntax_Tree;

   function Get_State_Machine (This : in Regular_Expression)
      return Regex.State_Machines.State_Machine_State_Vectors.Vector is
   begin
      return This.State_Machine_States;
   end Get_State_Machine;

   function Get_Start_State (This : in Regular_Expression)
      return Regex.State_Machines.State_Machine_State_Access is
   begin
      return This.Start_State;
   end Get_Start_State;

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

   --  Separate units:
   procedure Parse (Input : in String; Output : in out Regular_Expression) is separate;
   procedure Compile (Output : in out Regular_Expression) is separate;

end Regex.Regular_Expressions;

