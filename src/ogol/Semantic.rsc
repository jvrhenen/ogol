module ogol::Semantic

import ogol::Syntax;

import IO;
import String;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import analysis::graphs::Graph;

alias Definitions = lrel[str funcName, str scopeName];
alias Uses = rel[str funcName, loc src, str scopeName];

void analyseProgram(Program p) {
	callGraph(p);
}

void callGraph(p:(Program)`<Command * cmds>`) {
	Definitions defs = funcInCommands("global", cmds, [  ] );
	
	Uses uses = funcUsedInCommands("global", cmds, defs);
	
	render(graph(functionFigures(defs), functionCalls(uses), hint("layered"), gap(100)));
	
	notUsedCalls(defs, uses);
}

Figures functionFigures(Definitions defs) {
	nodes = [];
	for(<str funcName, str scopeName> <- defs) {
		nodes = nodes + [  box(text("<funcName>"), id("<funcName>"), size(50), fillColor("lightgreen")) ];
	}
	
	return nodes;
}

Edges functionCalls(Uses uses) {
	edges = [];
	for(<str funcName, loc src, str scopeName> <- uses) {
		str from = last(split("/", scopeName));
		if(from != "global") {
			edges = edges + edge(from, "<funcName>", toArrow(triangle(20)) );
		}
	}
	return edges;
}



void notUsedCalls(Definitions defs, Uses uses) {
	calls = {};
	for(<str funcName, loc src, str scopeName> <- uses) {
		str from = last(split("/", scopeName));
		if(from != "global") {
			calls = calls + <from, "<funcName>">;
		}
	}
	
	// Get all functions
	allFuncs = [];
	for(<str funcName, str scopeName> <- defs) {
		allFuncs = allFuncs + "<funcName>";
	}
	
	// Get all called functions
	allCalledFuncs = [];
	for(<str funcName, loc src, str scopeName> <- uses) {
		allCalledFuncs = allCalledFuncs + "<funcName>";
	}
	println(allFuncs - allCalledFuncs);
}

// Semantic

Definitions funcInCommands(str scopeName, Command* cmds, Definitions defs) 
	= ( defs | funcInCommand(scopeName, cmd, it) | cmd <- cmds );
	
Definitions funcInCommand(str scopeName, (Command)`to <FunId fid> <VarId* vars> <Command* cmds> end`, Definitions defs) {
	defs = <"<fid>", scopeName> + defs;
	return funcInCommands("<scopeName>/<fid>", cmds, defs);
}		

default Definitions funcInCommand(str scopeName, Command cmd, Definitions defs) {
	return defs;
}

Uses funcUsedInCommands(str scopeName, Command* cmds, Definitions defs) 
	= { *funcUsedInCommand(scopeName, cmd, defs) | cmd <- cmds };

Uses funcUsedInCommand(str scopeName, (Command)`to <FunId fid> <VarId* vars> <Command* cmds> end`, Definitions defs) {
	return funcUsedInCommands("<scopeName>/<fid>", cmds, defs);	
}

Uses funcUsedInCommand(str scopeName, (Command)`<FunId fid> <Expr* exps>;`, Definitions defs) {
	return {}+<"<fid>", fid@\loc, scopeName>;
}

Uses funcUsedInCommand(str scopeName, (Command)`ifelse <Expr e> <Block b1> <Block b2>`, Definitions defs) {
	return funcUsedInCommands(scopeName, b1.cmds, defs) + funcUsedInCommands(scopeName, b2.cmds, defs); 
}

Uses funcUsedInCommand(str scopeName, (Command)`while <Expr e> <Block b1>`, Definitions defs) {
	return funcUsedInCommands(scopeName, b1.cmds, defs); 
}

Uses funcUsedInCommand(str scopeName, (Command)`repeat <Expr e> <Block b>`, Definitions defs) {
	return funcUsedInCommands(scopeName, b.cmds, defs);
}


default Uses funcUsedInCommand(str scopeName, Command cmd, Definitions defs) {
	return {};
}