--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

private with Ada.Strings.Unbounded;

package Utilities.String_Buffers is

   --  String buffer type:
   type String_Buffer is tagged limited private;

   --  Creates a string buffer:
   function Create (Input : in String) return String_Buffer;

   --  Gets the next character from a string buffer:
   function Get_Next (This : in out String_Buffer) return Character;

   --  Peeks at the next character in a string buffer:
   function Peek (This : in out String_Buffer) return Character;

   --  Discards the next character in a string buffer:
   procedure Discard_Next (This : in out String_Buffer);

   --  Checks whether the string buffer index is at the end:
   function At_End (This : in String_Buffer) return Boolean;

   --  Gets the current index in the string buffer:
   function Get_Index (This : in String_Buffer) return Natural;

private

   type String_Buffer is tagged limited record
      Buffer : Ada.Strings.Unbounded.Unbounded_String;
      Index  : Integer;
   end record;

end Utilities.String_Buffers;

