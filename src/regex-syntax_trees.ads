--  Ada regular expression library
--  (c) Kristian Klomsten Skordal 2020 <kristian.skordal@wafflemail.net>
--  Report bugs and issues on <https://github.com/skordal/ada-regex>

with Regex.Utilities.Sorted_Sets;

package Regex.Syntax_Trees is

   type Syntax_Tree_Node;
   type Syntax_Tree_Node_Access is access all Syntax_Tree_Node;

   function "<" (Left, Right : in Syntax_Tree_Node_Access) return Boolean;
   package Syntax_Tree_Node_Sets is new Utilities.Sorted_Sets (
      Element_Type => Syntax_Tree_Node_Access);

   type Syntax_Tree_Node_Type is (
      Acceptance,
      Single_Character,
      Alternation,
      Concatenation,
      Kleene_Star);
   type Syntax_Tree_Node (Node_Type : Syntax_Tree_Node_Type) is record
      Left_Child, Right_Child : Syntax_Tree_Node_Access;
      Id : Natural := 0;
      Followpos : Syntax_Tree_Node_Sets.Sorted_Set;
      case Node_Type is
         when Single_Character =>
            Char : Character;
         when others =>
            null;
      end case;
   end record;

   --  Allocates and initializes a syntax tree node:
   function Create_Node (Node_Type               : in Syntax_Tree_Node_Type;
                         Id                      : in Natural;
                         Left_Child, Right_Child : in Syntax_Tree_Node_Access := null;
                         Char                    : in Character := Character'Val (0))
   return Syntax_Tree_Node_Access;

   --  Frees a syntax tree recursively:
   procedure Free_Recursively (Root_Node : in out Syntax_Tree_Node_Access);

   --  Computes the nullable() function for the specified node:
   function Nullable (Node : in Syntax_Tree_Node_Access) return Boolean;

   --  Computes the firstpos() function for the specified node:
   function Firstpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set;

   --  Computes the lastpos() function for the specified node:
   function Lastpos (Node : in Syntax_Tree_Node_Access) return Syntax_Tree_Node_Sets.Sorted_Set;

   --  Calculates the followpos() function for all nodes in the specified tree:
   procedure Calculate_Followpos (Tree : in Syntax_Tree_Node_Access);

end Regex.Syntax_Trees;
