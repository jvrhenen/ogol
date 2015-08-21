module ogol::Test

import ogol::Syntax;
import ogol::Eval;
import ogol::Canvas2JS;
import ogol::Desugar;
import ogol::Semantic;

import IO;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;


bool canParse(c1, str expr) {
	try
		return /amb(_) !:= parse(c1, expr);
	catch: return false;
}

bool visParseTree() {
	pt = parse(#start[Program], |project://SSPMSE/input/trees.ogol|);
	renderParsetree(pt);
	
	return true;
}

// Parameter: find all reachable nodes from given node.
void runSemantic(str n) {
	Program pg = parse(#start[Program], |project://SSPMSE/input/test.ogol|).top;
	pg = desugar(pg);
	analyseProgram(pg, n);
}

void runProgram() {
	Program pg = parse(#start[Program], |project://SSPMSE/input/trees.ogol|).top;
	pg = desugar(pg);
	
	canvas = eval(pg);
	compileCanvas(canvas, |project://SSPMSE/input/ogol.js|);
}