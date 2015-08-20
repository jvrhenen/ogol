module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;

import IO;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import String;
import util::Math;

alias FunEnv = map[FunId id, FunDef def];

alias VarEnv = map[VarId id, Value val];

data Value 	= boolean(bool b)
  			| number(real i)
  			;

/*
         +y
         |
         |
         |
-x ------+------- +x
         |
         |
         |
        -y

NB: home = (0, 0)
*/


alias Turtle = tuple[int dir, bool pendown, Point position];

alias State = tuple[Turtle turtle, Canvas canvas];

// Top-level eval function
Canvas eval(p:(Program)`<Command * cmds>`) {
	funenv = collectFunDefs(p);
	varEnv = ();
	state = <<0, false, <0,0>>, []>;
	
	for(c <- cmds) {
		state = eval(c, funenv, varEnv, state);
	}
	return state.canvas;
}

FunEnv collectFunDefs(Program p) = (f.id: f | /FunDef f:= p);

// Commands
default State eval(Command cmd, FunEnv fenv, VarEnv venv, State state)
{
	throw "Cannot eval: <cmd>";
}

State eval((Block)`[<Command* cmds>]`, FunEnv fenv, VarEnv venv, State state) {
	for(Command c <- cmds) {
		state = eval(c, fenv, venv, state);
	}
	return state;
}

State eval((Command)`ifelse <Expr e> <Block b1> <Block b2>`, FunEnv fenv, VarEnv venv, State state) {	
	if(eval(e, venv) == boolean(true)) {
		state = eval(b1, fenv, venv, state);
	} else {
		state = eval(b2, fenv, venv, state);
	}
	return state;
}

State eval((Command)`while <Expr e> <Block b>`, FunEnv fenv, VarEnv venv, State state) {
	while(eval(e, venv) == boolean(true)) {
		state = eval(b, fenv, venv, state);
	}
	return state;
}

State eval((Command)`repeat <Expr e> <Block b>`, FunEnv fenv, VarEnv venv, State state) {
	int steps = toInt(eval(e, venv).i);
	for(int n <- [0 .. steps]) {
		state = eval(b, fenv, venv, state);
	}
	return state;
}


//States
State eval((Command)`home;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.position = <0,0>;
	return state;
}

State eval((Command)`pendown;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.pendown = true;
	return state;
}

State eval((Command)`penup;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.pendown = false;
	return state;
}

State eval((Command)`right <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	state.turtle.dir = toInt(eval(e, venv).i + state.turtle.dir) % 360;
	return state;
}

State eval((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	int newDir = toInt(state.turtle.dir - eval(e, venv).i);
	if(newDir < 0) {
		newDir = 360 + newDir;
	}
	
	state.turtle.dir = newDir;
	return state;
}

State eval((Command)`forward <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	turtle = state.turtle;
	canvas = state.canvas;
	
	int steps = toInt(eval(e, venv).i);
	startPoint = turtle.position;
	int dir = turtle.dir;
	
	int deltaX = toInt(sin( (dir * ( PI()/ 180.0) )) * steps);
	int deltaY = toInt(cos( (dir * ( PI()/ 180.0) )) * steps);

	endPoint = <startPoint.x+deltaX, startPoint.y-deltaY>;
	
	if(turtle.pendown) { //canvas
		state.canvas = state.canvas + line(startPoint, endPoint);
	}
	
	state.turtle.position = endPoint;
	return state;
}

State eval((Command)`back <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	turtle = state.turtle;
	canvas = state.canvas;
	
	int steps = toInt(eval(e, venv).i);
	startPoint = turtle.position;
	int dir = turtle.dir;
	
	int deltaX = toInt(sin( (dir * ( PI()/ 180.0) )) * steps);
	int deltaY = toInt(cos( (dir * ( PI()/ 180.0) )) * steps);

	endPoint = <startPoint.x-deltaX, startPoint.y+deltaY>;
	
	if(turtle.pendown) { //canvas
		state.canvas = state.canvas + line(startPoint, endPoint);
	}
	
	state.turtle.position = endPoint;
	
	return state;
}

State eval((Command)`to <FunId f> <VarId* vars> <Command* cmds> end`, FunEnv fenv, VarEnv venv, State state) {	
	return state;
}

State eval((Command)`<FunId f> <Expr* es>;`, FunEnv fenv, VarEnv venv, State state) {
	funDef = fenv[f];
	
	vars = [v | VarId v <- funDef.vars];
	exprs = [e | Expr e <- es];
	
	for(int i <- [0 .. size(vars)] ) {
		Expr e = exprs[i];
		venv = venv + (vars[i]: eval(e, venv) );
	}
		
	for(Command c <- funDef.cmds) {
		state = eval(c, fenv, venv, state);
	}
	return state;
}

/*State eval((Command)`setpencolor <Color c>;`, FunEnv fenv, VarEnv venv, State state) {
	return state;
}*/

// Booleans
Value eval((Expr)`true`, VarEnv env) = boolean(true);
Value eval((Expr)`false`, VarEnv env) = boolean(false);

// Numbers
Value eval((Expr)`<Number n>`, VarEnv env) = number(toReal(unparse(n)));

// Variables
Value eval((Expr)`<VarId x>`, VarEnv env) = env[x];

// Arithmetic
Value eval((Expr)`<Expr lhs> * <Expr rhs>`, VarEnv env) // *
	= number(x * y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);
		
Value eval((Expr)`<Expr lhs> / <Expr rhs>`, VarEnv env) // /
	= number(x / y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> + <Expr rhs>`, VarEnv env) // +
	= number(x + y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);
		
Value eval((Expr)`<Expr lhs> - <Expr rhs>`, VarEnv env) // -
	= number(x - y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);		

// Comparison
Value eval((Expr)`<Expr lhs> \> <Expr rhs>`, VarEnv env) // >
	= boolean(x > y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);
		
Value eval((Expr)`<Expr lhs> \< <Expr rhs>`, VarEnv env) // <
	= boolean(x < y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);	
		
Value eval((Expr)`<Expr lhs> \<= <Expr rhs>`, VarEnv env) // <=
	= boolean(x <= y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);				

Value eval((Expr)`<Expr lhs> \>= <Expr rhs>`, VarEnv env) // >=
	= boolean(x >= y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);	
		
Value eval((Expr)`<Expr lhs> = <Expr rhs>`, VarEnv env) // =
	= boolean(x == y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);
		
Value eval((Expr)`<Expr lhs> != <Expr rhs>`, VarEnv env) // !=
	= boolean(x != y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);

// Logical
Value eval((Expr)`<Expr lhs> && <Expr rhs>`, VarEnv env)
	= boolean(x && y)
	when
		boolean(x) := eval(lhs, env),
		boolean(y) := eval(rhs, env);
		
Value eval((Expr)`<Expr lhs> || <Expr rhs>`, VarEnv env)
	= boolean(x || y)
	when
		boolean(x) := eval(lhs, env),
		boolean(y) := eval(rhs, env);		
		
// Default
default Value eval(Expr e, VarEnv _) {
	throw "Cannot eval: <e>";
}		
		
// TESTS

// Boolean
test bool testTrue() = eval((Expr)`true`, ()) ==  boolean(true);
test bool testFalse() = eval((Expr)`false`, ()) ==  boolean(false);

// Numbers
test bool testNumber() = eval((Expr)`-1.23`, ()) == number(-1.23);

// Variables
test bool testVar() = eval((Expr)`:x`, ((VarId)`:x` : number(1.0))) == number(1.0);

// Arthmetic						
test bool testMult() = eval((Expr)`:x * 2`, ((VarId)`:x` : number(2.0))) == number(4.0);
test bool testDiv() = eval((Expr)`:x / 2`, ((VarId)`:x` : number(2.0))) == number(1.0);
test bool testAdd() = eval((Expr)`:x + 2`, ((VarId)`:x` : number(2.0))) == number(4.0);
test bool testSub() = eval((Expr)`:x - 1`, ((VarId)`:x` : number(2.0))) == number(1.0); 

// Comparison
test bool testGe() = eval((Expr)`:x \> 5`, ((VarId)`:x` : number(6.0))) == boolean(true); // >
test bool testLe() = eval((Expr)`:x \< 5`, ((VarId)`:x` : number(4.0))) == boolean(true); // <
test bool testGt1() = eval((Expr)`:x \>= 5`, ((VarId)`:x` : number(5.0))) == boolean(true); // >=
test bool testGt2() = eval((Expr)`:x \>= 5`, ((VarId)`:x` : number(6.0))) == boolean(true); // >=
test bool testLt1() = eval((Expr)`:x \<= 5`, ((VarId)`:x` : number(5.0))) == boolean(true); // <=
test bool testLt2() = eval((Expr)`:x \<= 5`, ((VarId)`:x` : number(4.0))) == boolean(true); // <=
test bool testEq() = eval((Expr)`:x = 5`, ((VarId)`:x` : number(5.))) == boolean(true); // =
test bool testNq() = eval((Expr)`:x != 5`, ((VarId)`:x` : number(4.0))) == boolean(true); // !=
	
// Logical
test bool testAnd() = eval((Expr)`:x && true`, ((VarId)`:x`: boolean(true))) == boolean(true); // &&
test bool testOr() = eval((Expr)`:x || true`, ((VarId)`:x`: boolean(true))) == boolean(true); // ||