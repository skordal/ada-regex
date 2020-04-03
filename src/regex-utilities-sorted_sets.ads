--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Iterator_Interfaces;

private with Ada.Finalization;
private with Ada.Unchecked_Deallocation;

--  Simple ordered set designed for use with few items. Inserting identical
--  elements will not cause exceptions to be raised, they will instead be
--  merged with existing items.
generic
   type Element_Type is private;
   with function "=" (Left, Right : in Element_Type) return Boolean is <>;
   with function "<" (Left, Right : in Element_Type) return Boolean is <>;
package Regex.Utilities.Sorted_Sets is

   --  Sorted set object.
   type Sorted_Set is tagged private with
      Constant_Indexing => Constant_Reference,
      Default_Iterator => Iterate,
      Iterator_Element => Element_Type;

   --  Converts a single value of the Element_Type to a sorted set:
   function To_Set (Item : in Element_Type) return Sorted_Set;

   --  Creates a set with the specified capacity:
   function Create_Set (Capacity : in Natural) return Sorted_Set;

   --  Creates an empty set:
   function Empty_Set return Sorted_Set is (Create_Set (0));

   --  Gets the number of items in the set:
   function Length (This : in Sorted_Set) return Natural with Inline;

   --  Adds an item to the set:
   procedure Add (This : in out Sorted_Set; Item : in Element_Type);

   --  Adds all items of another set to a set:
   procedure Add (This : in out Sorted_Set; Items : in Sorted_Set);

   --  Checks if an element exists in the set:
   function Element_Exists (This : in Sorted_Set; Item : in Element_Type) return Boolean;

   --  Appends an item to a set, returning the new set:
   function "&" (Left : in Sorted_Set; Right : in Element_Type) return Sorted_Set;

   --  Merges two sorted sets:
   function "&" (Left, Right : in Sorted_Set) return Sorted_Set;

   --  Compares two sorted sets for equality by comparing each element in the sets:
   function "=" (Left, Right : in Sorted_Set) return Boolean;

   --  Create iterators for sorted sets:
   type Cursor is private;
   function Has_Element (Position : in Cursor) return Boolean;
   package Set_Iterators is new Ada.Iterator_Interfaces (Cursor, Has_Element);

   --  Returns an iterator that can be used to iterate throught the items in a set:
   function Iterate (This : in Sorted_Set) return Set_Iterators.Forward_Iterator'Class;

   --  Returns the value of an element:
   function Element_Value (This : in Sorted_Set; Position : in Cursor) return Element_Type;

   --  Indexing:
   type Constant_Reference_Type (Item : not null access constant Element_Type) is private
      with Implicit_Dereference => Item;
   function Constant_Reference (This : in Sorted_Set; Position : in Cursor)
      return Constant_Reference_Type;

private

   Default_Capacity : constant Natural := 5;

   type Item_Array is array (Positive range <>) of aliased Element_Type;
   type Item_Array_Access is access Item_Array;

   procedure Free_Item_Array is new Ada.Unchecked_Deallocation (
      Item_Array, Item_Array_Access);

   type Sorted_Set is new Ada.Finalization.Controlled with record
      Items      : Item_Array_Access := null;
      Capacity   : Natural := 0;
      Item_Count : Natural := 0;
   end record;

   overriding procedure Adjust   (This : in out Sorted_Set);
   overriding procedure Finalize (This : in out Sorted_Set);

   procedure Enlarge_Item_Array (This : in out Sorted_Set);

   type Cursor is record
      Items            : Item_Array_Access;
      Index, End_Index : Natural;
   end record;

   type Set_Iterator is new Set_Iterators.Forward_Iterator with record
      Items : Item_Array_Access;
      Item_Count : Natural;
   end record;

   overriding function First (This : in Set_Iterator) return Cursor;
   overriding function Next (This : in Set_Iterator; Position : in Cursor) return Cursor;

   type Constant_Reference_Type (Item : not null access constant Element_Type) is null record;

end Regex.Utilities.Sorted_Sets;

