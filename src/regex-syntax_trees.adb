--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020-2021 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Ada.Unchecked_Deallocation;

package body Regex.Syntax_Trees is

   function "<" (Left, Right : in Syntax_Tree_Node_Access) return Boolean is
   begin
      return Left.Id < Right.Id;
   end "<";

   function Create_Node (Node_Type : in Syntax_Tree_Node_Type; Id : in Natural;
      Left_Child, Right_Child : in Syntax_Tree_Node_Access := null; Char : in Character := Character'Val (0))
      return Syntax_Tree_Node_Access
   is
      Retval : constant Syntax_Tree_Node_Access := new Syntax_Tree_Node (Node_Type => Node_Type);
   begin
      Retval.Id := Id;
      Retval.Left_Child := Left_Child;
      Retval.Right_Child := Right_Child;

      if Node_Type = Single_Character then
         Retval.Char := Char;
      end if;

      return Retval;
   end Create_Node;

   function Clone_Tree (Root : in Syntax_Tree_Node_Access; Next_Id : in out Natural)
      return Syntax_Tree_Node_Access
   is
      Retval : constant Syntax_Tree_Node_Access := Create_Node (Root.Node_Type, Next_Id);
   begin
      Next_Id := Next_Id + 1;

      case Retval.Node_Type is
         when Single_Character =>
            Retval.Char := Root.Char;
         when Acceptance =>
            Retval.Acceptance_Id := Root.Acceptance_Id;
         when others =>
            null;
      end case;

      if Root.Left_Child /= null then
         Retval.Left_Child := Clone_Tree (Root.Left_Child, Next_Id);
      end if;

      if Root.Right_Child /= null then
         Retval.Right_Child := Clone_Tree (Root.Right_Child, Next_Id);
      end if;

      return Retval;
   end Clone_Tree;

   function Clone_Tree (Root : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Access is
      Next_Id : Natural := 1;
   begin
      return Clone_Tree (Root, Next_Id);
   end Clone_Tree;

   function Get_Acceptance_Node (Root : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Access is
      Retval : Syntax_Tree_Node_Access := null;
   begin
      if Root.Node_Type = Acceptance then
         return Root;
      else
         if Root.Right_Child /= null then
            Retval := Get_Acceptance_Node (Root.Right_Child);
            if Retval /= null then
               return Retval;
            end if;
         end if;

         if Root.Left_Child /= null then
            Retval := Get_Acceptance_Node (Root.Left_Child);
            if Retval /= null then
               return Retval;
            end if;
         end if;

         return null;
      end if;
   end Get_Acceptance_Node;

   procedure Free_Recursively (Root_Node : in out Syntax_Tree_Node_Access) is
      procedure Free is new Ada.Unchecked_Deallocation (Syntax_Tree_Node, Syntax_Tree_Node_Access);
   begin
      if Root_Node.Left_Child /= null then
         Free_Recursively (Root_Node.Left_Child);
      end if;

      if Root_Node.Right_Child /= null then
         Free_Recursively (Root_Node.Right_Child);
      end if;

      Free (Syntax_Tree_Node_Access (Root_Node));
   end Free_Recursively;

   function Nullable (Node : in Syntax_Tree_Node_Access) return Boolean is
   begin
      pragma Assert (Node /= null);

      case Node.Node_Type is
         when Kleene_Star | Empty_Node =>
            return True;
         when Single_Character | Any_Character | Acceptance =>
            return False;
         when Alternation =>
            return Nullable (Node.Left_Child) or Nullable (Node.Right_Child);
         when Concatenation =>
            return Nullable (Node.Left_Child) and Nullable (Node.Right_Child);
      end case;
   end Nullable;

   function Firstpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set is
      use Syntax_Tree_Node_Sets;
      Retval : Sorted_Set := Empty_Set;
   begin
      pragma Assert (Node /= null);

      case Node.Node_Type is
         when Empty_Node =>
            null; --  Returns Empty_Set
         when Kleene_Star =>
            Retval := Firstpos (Node.Left_Child);
         when Concatenation =>
            if Nullable (Node.Left_Child) then
               Retval := Firstpos (Node.Left_Child) & Firstpos (Node.Right_Child);
            else
               Retval := Firstpos (Node.Left_Child);
            end if;
         when Alternation =>
            Retval := Firstpos (Node.Left_Child) & Firstpos (Node.Right_Child);
         when Single_Character | Any_Character | Acceptance =>
            Retval := To_Set (Node);
      end case;

      return Retval;
   end Firstpos;

   function Lastpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set is
      use Syntax_Tree_Node_Sets;
      Retval : Sorted_Set := Empty_Set;
   begin
      pragma Assert (Node /= null);

      case Node.Node_Type is
         when Empty_Node =>
            null; --  Returns Empty_Set
         when Kleene_Star =>
            Retval := Lastpos (Node.Left_Child);
         when Single_Character | Any_Character | Acceptance =>
            Retval := To_Set (Node);
         when Concatenation =>
            if Nullable (Node.Right_Child) then
               Retval := Lastpos (Node.Right_Child) & Lastpos (Node.Left_Child);
            else
               Retval := Lastpos (Node.Right_Child);
            end if;
         when Alternation =>
            Retval := Lastpos (Node.Left_Child) & Lastpos (Node.Right_Child);
      end case;

      return Retval;
   end Lastpos;

   procedure Calculate_Followpos (Tree : in Syntax_Tree_Node_Access) is
      use Syntax_Tree_Node_Sets;
   begin
      pragma Assert (Tree /= null);
      if Tree.Node_Type = Concatenation then
         for Node of Lastpos (Tree.Left_Child) loop
            Node.Followpos := Node.Followpos & Firstpos (Tree.Right_Child);
         end loop;
      elsif Tree.Node_Type = Kleene_Star then
         for Node of Lastpos (Tree) loop
            Node.Followpos := Node.Followpos & Firstpos (Tree);
         end loop;
      end if;

      --  Continue down the tree:
      if Tree.Left_Child /= null then
         Calculate_Followpos (Tree.Left_Child);
      end if;
      if Tree.Right_Child /= null then
         Calculate_Followpos (Tree.Right_Child);
      end if;
   end Calculate_Followpos;

end Regex.Syntax_Trees;

