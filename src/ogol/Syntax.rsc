module ogol::Syntax

import vis::ParseTree;

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

keyword Reserved = "if" | "ifelse" | "while" | "repeat" | "forward" | "fd" | "back" | "bk" | "home" | "right" | "rt" | "left" | "lt" | "pendown" | "pd" | "penup" | "pu" | "setpencolor" | "to" | "true" | "false" | "end";

start syntax Program = Command*; 

syntax Block = "[" Command* cmds "]";

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

syntax Expr 
   = Boolean
   | Number
   | VarId
   > left   div: Expr "/" Expr 
   > left   mul: Expr "*" Expr
   > left ( add: Expr "+" Expr 
   		  | sub: Expr "-" Expr
   		  )
   > left ( gt:  Expr "\>"  Expr
          | st:  Expr "\<"  Expr
          | gte: Expr "\>=" Expr
          | ste: Expr "\<=" Expr
          | eq:  Expr "="  Expr
          | neq: Expr "!=" Expr
          )    
   | left ( and: Expr "&&" Expr
          | or:  Expr "||" Expr
          )
   ;

syntax FunDef 	= "to" FunId id VarId* vars Command* cmds "end";
syntax FunCall 	= FunId Expr* ";" ;

syntax Forward 	= "forward" Expr ";" | "fd" Expr ";";
syntax Back		= "back" Expr ";" | "bk" Expr ";";
syntax Home		= "home" ";";
syntax Right 	= "right" Expr ";" | "rt" Expr ";";
syntax Left		= "left" Expr ";" | "lt" Expr ";";
syntax Pendown 	= "pendown" ";" | "pd" ";";
syntax Penup 	= "penup" ";" | "pu" ";";
syntax Pencolor = "setpencolor" Color ";";

syntax Logical = left Logical "&&" Logical
			   > left Logical "||" Logical
			   | Expr
			   ;
			   
syntax Arithmetic 	= left div: Expr l "/" Expr r 
					> left multi: Expr l "*" Expr r
					> left ( 
						add: Expr l "+" Expr r
         				| sub: Expr l "-" Expr r
         			);				   
         			
syntax Comparision 	= left
					(Comparision "\>" Comparision
					| Comparision "\<" Comparision
					| Comparision "\>=" Comparision
					| Comparision "\<=" Comparision
					| Comparision "=" Comparision
					| Comparision "!=" Comparision)
					| Expr
					;         			

lexical Boolean = "true" | "false";
lexical Number 	= "-"? [0-9]+ !>> [0-9]
   				| "-"? [0-9]* "." [0-9]+ !>> [0-9];
lexical Color = "#" [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f];
  
lexical VarId
  = ":" ([a-zA-Z][a-zA-Z0-9]*) \ Reserved !>> [a-zA-Z0-9];
  
lexical FunId
  = ([a-zA-Z][a-zA-Z0-9]*) \ Reserved !>> [a-zA-Z0-9];


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