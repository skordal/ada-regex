--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Unchecked_Deallocation;

package body Regex.State_Machines is
   use Regex.Syntax_Trees;

   function Clone (Object : in Input_Symbol_Access) return Input_Symbol_Access is
      New_Object : constant Input_Symbol_Access := new Input_Symbol (Symbol_Type => Object.Symbol_Type);
   begin
      New_Object.all := Object.all;
      return New_Object;
   end Clone;

   function "<" (Left, Right : in Input_Symbol_Access) return Boolean is
   begin
      case Left.Symbol_Type is
         when Single_Character =>
            if Right.Symbol_Type = Single_Character then
               return Left.Char < Right.Char;
            else
               return True;
            end if;
         when Any_Character =>
            return False;
      end case;
   end "<";

   function Create_Transition_On_Symbol (Input_Symbol : in Input_Symbol_Access;
                                         Target_State : in State_Machine_State_Access)
      return State_Machine_Transition is
   begin
      return Retval : State_Machine_Transition do
         Retval.Transition_On := Input_Symbol;
         Retval.Target_State := Target_State;
      end return;
   end Create_Transition_On_Symbol;

   procedure Adjust (This : in out State_Machine_Transition) is
      pragma Assert (This.Transition_On /= null);

      New_Input_Symbol : constant Input_Symbol_Access := new Input_Symbol (
         Symbol_Type => This.Transition_On.Symbol_Type);
   begin
      New_Input_Symbol.all := This.Transition_On.all;
      This.Transition_On := New_Input_Symbol;
   end Adjust;

   procedure Finalize (This : in out State_Machine_Transition) is
      procedure Free is new Ada.Unchecked_Deallocation (Input_Symbol, Input_Symbol_Access);
   begin
      Free (This.Transition_On);
   end Finalize;

   function Create_State (Syntax_Tree_Nodes : in Syntax_Tree_Node_Sets.Sorted_Set) return State_Machine_State_Access is
      Retval : constant State_Machine_State_Access := new State_Machine_State'(
         Syntax_Tree_Nodes => Syntax_Tree_Nodes,
         Transitions => State_Machine_Transition_Vectors.Empty_Vector,
         others => False);
   begin
      return Retval;
   end Create_State;

end Regex.State_Machines;

