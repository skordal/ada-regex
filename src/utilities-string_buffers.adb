--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

package body Utilities.String_Buffers is

   function Create (Input : in String) return String_Buffer is
   begin
      return Retval : String_Buffer do
         Retval.Buffer := Ada.Strings.Unbounded.To_Unbounded_String (Input);
         Retval.Index  := 1;
      end return;
   end Create;

   function Get_Next (This : in out String_Buffer) return Character is
      Retval : constant Character := Ada.Strings.Unbounded.Element (This.Buffer, This.Index);
   begin
      This.Index := This.Index + 1;
      return Retval;
   end Get_Next;

   function Peek (This : in out String_Buffer) return Character is
   begin
      return Ada.Strings.Unbounded.Element (This.Buffer, This.Index);
   end Peek;

   procedure Discard_Next (This : in out String_Buffer) is
      Discard_Me : constant Character := This.Get_Next;
   begin
      null;
   end Discard_Next;

   function At_End (This : in String_Buffer) return Boolean is
   begin
      return This.Index > Ada.Strings.Unbounded.Length (This.Buffer);
   end At_End;

   function Get_Index (This : in String_Buffer) return Natural is
   begin
      return This.Index;
   end Get_Index;

end Utilities.String_Buffers;

