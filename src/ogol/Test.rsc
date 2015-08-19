module ogol::Test
import ogol::Syntax;
import ogol::Eval;
import ogol::Canvas2JS;
import ogol::Desugar;

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

bool runProgram() {
	pt = parse(#start[Program], |project://SSPMSE/input/trees.ogol|);
	canvas = eval(desugar(pt.top));
	
	compileCanvas(canvas, |project://SSPMSE/input/ogol.js|);
	
	return true;
}