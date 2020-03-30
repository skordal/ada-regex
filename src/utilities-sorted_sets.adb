--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Text_IO;
with Ada.Containers.Generic_Array_Sort;

package body Utilities.Sorted_Sets is

   function To_Set (Item : in Element_Type) return Sorted_Set is
      Retval : Sorted_Set := Empty_Set;
   begin
      Retval.Add (Item);
      return Retval;
   end To_Set;

   function Create_Set (Capacity : in Natural) return Sorted_Set is
   begin
      return Retval : Sorted_Set do
         Retval.Capacity := Capacity;
         Retval.Item_Count := 0;
         Retval.Items := new Item_Array (1 .. Capacity);
      end return;
   end Create_Set;

   function Length (This : in Sorted_Set) return Natural is
   begin
      return This.Item_Count;
   end Length;

   procedure Add (This : in out Sorted_Set; Item : in Element_Type) is
      procedure Sort_Array is new Ada.Containers.Generic_Array_Sort (
         Index_Type => Positive, Element_Type => Element_Type, Array_Type => Item_Array);
   begin
      --  Check if the element exists in the set:
      if This.Element_Exists (Item) then
         return;
      end if;

      if This.Item_Count = 0 or else This.Item_Count >= This.Capacity then
         This.Enlarge_Item_Array;
      end if;

      This.Item_Count := This.Item_Count + 1;
      This.Items (This.Item_Count) := Item;

      Sort_Array (This.Items (1 .. This.Item_Count));
   end Add;

   procedure Add (This : in out Sorted_Set; Items : in Sorted_Set) is
   begin
      for Item of Items loop
         This.Add (Item);
      end loop;
   end Add;

   function Element_Exists (This : in Sorted_Set; Item : in Element_Type) return Boolean is
   begin
      for I of This loop
         if I = Item then
            return True;
         end if;
      end loop;

      return False;
   end Element_Exists;

   function "&" (Left : in Sorted_Set; Right : in Element_Type) return Sorted_Set is
      Retval : Sorted_Set := Left;
   begin
      Retval.Add (Right);
      return Retval;
   end "&";

   function "&" (Left, Right : in Sorted_Set) return Sorted_Set is
      Result_Set : Sorted_Set := Create_Set (Natural'Max (Left.Capacity, Right.Capacity));
   begin
      for I of Left loop
         Result_Set.Add (I);
      end loop;

      for I of Right loop
         Result_Set.Add (I);
      end loop;

      return Result_Set;
   end "&";

   function "=" (Left, Right : in Sorted_Set) return Boolean is
   begin
      if Left.Length /= Right.Length then
         return False;
      end if;

      for I in 1 .. Left.Item_Count loop
         if Left.Items (I) /= Right.Items (I) then
            return False;
         end if;
      end loop;

      return True;
   end "=";

   function Has_Element (Position : in Cursor) return Boolean is
   begin
      return Position.Index > 0 and Position.Index <= Position.End_Index;
   end Has_Element;

   function Iterate (This : in Sorted_Set) return Set_Iterators.Forward_Iterator'Class is
   begin
      return Retval : Set_Iterator do
         Retval.Items := This.Items;
         Retval.Item_Count := This.Item_Count;
      end return;
   end Iterate;

   function Element_Value (This : in Sorted_Set; Position : in Cursor) return Element_Type is
   begin
      return This.Items (Position.Index);
   end Element_Value;

   function Constant_Reference (This : aliased in Sorted_Set; Position : in Cursor) return Constant_Reference_Type is
      Retval : Constant_Reference_Type (Item => This.Items (Position.Index)'Access);
   begin
      return Retval;
   end Constant_Reference;

   procedure Adjust (This : in out Sorted_Set) is
      New_Array : Item_Array_Access;
   begin
      if This.Items /= null then
         New_Array := new Item_Array (This.Items'Range);
         for I in This.Items'Range loop
            New_Array (I) := This.Items (I);
         end loop;
         This.Items := New_Array;
      end if;
   end Adjust;

   procedure Finalize (This : in out Sorted_Set) is
   begin
      if This.Items /= null then
         Free_Item_Array (This.Items);
      end if;
   end Finalize;

   procedure Enlarge_Item_Array (This : in out Sorted_Set) is
      New_Capacity : Natural;
      New_Array : Item_Array_Access;
   begin
      if This.Capacity = 0 then
         This.Items := new Item_Array (1 .. Default_Capacity);
         This.Capacity := Default_Capacity;
      else
         --  Enlarge the item array by ~10 %, minimum Default_Capacity elements:
         New_Capacity := Natural (Float (This.Capacity) * 1.1);
         if New_Capacity < This.Capacity + Default_Capacity then
            New_Capacity := This.Capacity + Default_Capacity;
         end if;

         New_Array := new Item_Array (1 .. New_Capacity);
         for I in This.Items'Range loop
            New_Array (I) := This.Items (I);
         end loop;

         Free_Item_Array (This.Items);

         This.Capacity := New_Capacity;
         This.Items := New_Array;
      end if;
   end Enlarge_Item_Array;

   function First (This : in Set_Iterator) return Cursor is
   begin
      return Retval : Cursor do
         Retval.Items := This.Items;
         Retval.Index := 1;
         Retval.End_Index := This.Item_Count;
      end return;
   end First;

   function Next (This : in Set_Iterator; Position : in Cursor) return Cursor is
      Retval : Cursor := Position;
   begin
      Retval.Items := This.Items;
      Retval.Index := Retval.Index + 1;
      Retval.End_Index := This.Item_Count;
      return Retval;
   end Next;

end Utilities.Sorted_Sets;

