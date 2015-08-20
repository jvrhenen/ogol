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

void visGraph() {
	nodes = [ box(text("A"), id("A"), size(50), fillColor("lightgreen")),
	     	  box(text("B"), id("B"), size(60), fillColor("orange")),
	     	  ellipse( text("C"), id("C"), size(70), fillColor("lightblue")),
	     	  ellipse(text("D"), id("D"), size(200, 40), fillColor("violet")),
	          box(text("E"), id("E"), size(50), fillColor("silver")),
		  box(text("F"), id("F"), size(50), fillColor("coral"))
	     	];
	edges = [ edge("A", "B"), edge("B", "C"), edge("B", "D"), edge("A", "C"),
	          edge("C", "E"), edge("C", "F"), edge("D", "E"), edge("D", "F"),
	          edge("A", "F")
	    	]; 
	render(graph(nodes, edges, hint("spring"), gap(100)));
}

bool runProgram() {
	Program pg = parse(#start[Program], |project://SSPMSE/input/test.ogol|).top;
	pg = desugar(pg);
	
	analyseProgram(pg);
	
	
	canvas = eval(pg);
	
	compileCanvas(canvas, |project://SSPMSE/input/ogol.js|);
	
	return true;
}