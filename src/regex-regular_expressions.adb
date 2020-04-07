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

