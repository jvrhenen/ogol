module ogol::Syntax

/*

Ogol syntax summary

Program: Command...

Command:
 * Control flow: 
  if Expr Block
  ifelse Expr Block Block
  while Expr Block
  repeat Expr Block
 * Drawing (mind the closing semicolons)
  forward Expr; fd Expr; back Expr; bk Expr; home;
  right Expr; rt Expr; left Expr; lt Expr; 
  pendown; pd; penup; pu;
 * Procedures
  definition: to Name [Var...] Command... end
  call: Name Expr... ;
 
Block: [Command...]
 
Expressions
 * Variables :x, :y, :angle, etc.
 * Number: 1, 2, -3, 0.7, -.1, etc.
 * Boolean: true, false
 * Arithmetic: +, *, /, -
 * Comparison: >, <, >=, <=, =, !=
 * Logical: &&, ||

Reserved keywords
 if, ifelse, while, repeat, forward, back, right, left, pendown, 
 penup, to, true, false, end

Bonus:
 - add literal for colors
 - support setpencolor

*/

keyword Reserved = "if" | "ifelse" | "while" | "repeat" | "forward" | "back" | "right" | "left" | "pendown" | "penup" | "to" | "true" | "false" | "end";

start syntax Program = Command*; 

syntax Block = Command*;

syntax Command = "if" Expr Block
			   | "ifelse" Expr Block Block
			   | "while" Expr Block
			   | "repeat" Expr Block
			   | Forward
			   | Back
			   | Home
			   | Right 
			   | Left
			   | Pendown
			   | Penup
			   | FunDef
			   | FunCall
			   ;
				
syntax Expr = VarId
			| Number
			| Boolean
			| Logical
			;

syntax FunDef 	= "to" FunId VarId* Block "end";
syntax FunCall 	= VarId Expr* ";" ;

syntax Forward 	= "forward" Expr ";" | "fd" Expr ";";
syntax Back		= "back" Expr ";" | "bk" Expr ";";
syntax Home		= "home" ";";
syntax Right 	= "right" Expr ";" | "rt" Expr ";";
syntax Left		= "left" Expr ";" | "lt" Expr ";";
syntax Pendown 	= "pendown" ";" | "pd" ";";
syntax Penup 	= "penup" ";" | "pu" ";";

syntax Logical = Logical "&&" Logical
			   | Logical "||" Logical
			   | "(" Expr ")"
			   ;			   

lexical Boolean = "true" | "false";
lexical Number 	
  = [\-]?[0-9]+ "." [0-9]+
  ;
  
lexical VarId
  = ":" [a-zA-Z][a-zA-Z0-9]* \Reserved  !>> [a-zA-Z0-9];
  
lexical FunId
  = [a-zA-Z][a-zA-Z0-9]* \Reserved !>> [a-zA-Z0-9];


layout Standard 
  = WhitespaceOrComment* !>> [\ \t\n\r] !>> "--";
  
lexical WhitespaceOrComment 
  = whitespace: Whitespace
  | comment: Comment
  ; 

lexical Whitespace
  = [\ \t\n\r]
  ;

lexical Comment
  = @category="Comment" "--" ![\n\r]* $
  ;  
  