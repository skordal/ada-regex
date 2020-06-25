--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Strings.Unbounded;
with Regex.State_Machines; use Regex.State_Machines;

package body Regex.Matchers is

   function Matches (Input : in Regular_Expression; Query : in String; Match_Id : out Natural) return Boolean is
      Current_State : State_Machine_State_Access := Input.Get_Start_State;
   begin
      for Symbol of Query loop
         declare
            Transition_Found : Boolean := False;
         begin
            Find_Transition : for Transition of Current_State.Transitions loop
               case Transition.Transition_On.Symbol_Type is
                  when Single_Character =>
                     if Transition.Transition_On.Char = Symbol then
                        Current_State := Transition.Target_State;
                        Transition_Found := True;
                     end if;
                  when Any_Character =>
                     Current_State := Transition.Target_State;
                     Transition_Found := True;
               end case;

               exit Find_Transition when Transition_Found;
            end loop Find_Transition;

            if not Transition_Found then
               return False;
            end if;
         end;
      end loop;

      if Current_State.Accepting then
         Match_Id := Current_State.Acceptance_id;
      end if;

      return Current_State.Accepting;
   end Matches;

   function Matches (Input : in Regular_Expression; Query : in String) return Boolean is
      Id : Natural;
   begin
      return Matches (Input, Query, Id);
   end Matches;


   function Get_Match (Input : in Regular_Expression; Query : in String; Complete_Match : out Boolean) return String
   is
      package Unbounded renames Ada.Strings.Unbounded;
      use type Unbounded.Unbounded_String;

      Current_State : State_Machine_State_Access := Input.Get_Start_State;
      Match         : Unbounded.Unbounded_String := Unbounded.Null_Unbounded_String;
   begin
      for Symbol of Query loop
         declare
            Transition_Found : Boolean := False;
         begin
            Find_Transition : for Transition of Current_State.Transitions loop
               case Transition.Transition_On.Symbol_Type is
                  when Single_Character =>
                     if Transition.Transition_On.Char = Symbol then
                        Match := Match & Symbol;
                        Current_State := Transition.Target_State;
                        Transition_Found := True;
                     end if;
                  when Any_Character =>
                     Match := Match & Symbol;
                     Transition_Found := True;
               end case;

               exit Find_Transition when Transition_Found;
            end loop Find_Transition;

            exit when not Transition_Found;
         end;
      end loop;

      Complete_Match := Current_State.Accepting;
      return Unbounded.To_String (Match);
   end Get_Match;

end Regex.Matchers;

