/*--------------------------------
	Tokens

		Types:
			-identifier 	=		i				
			-keyword 		=		k
			-symbol 		=		s
			-number 		=		n
			-string 		=		S

----------------------------------*/

QC.RawSymbols = {

	// MATH:

		["+"] = {"add", "addition" },
		["-"] = { "sub", "subtract" },
		["*"] = { "mul", "multiplier" },
		["/"] = { "div", "division" },
		["%"] = { "mod", "modulus" },
		["^"] = { "pow", "power" },
		["="] = { "ass", "assign" },
		["+="] = { "aadd", "increase" },
		["-="] = { "asub", "decrease" },
		["*="] = { "amul", "multiplier" },
		["/="] = { "adiv", "division" },
		["++"] = { "inc", "increment" },
		["--"] = { "dec", "decrement" },

	// COMPARISON:

		["=="] = { "eq", "equal" },
		["!="] = { "neq", "unequal" },
		["<"] = { "lth", "less" },
		["<="] = { "leq", "less or equal" },
		[">"] = { "gth", "greater" },
		[">="] = { "geq", "greater or equal" },

	// BITWISE:

		["&"] = { "band", "and" },
		["|"] = { "bor", "or" },
		["^^"] = { "bxor", "or" },
		[">>"] = { "bshr", ">>" },
		["<<"] = { "bshl", "<<" },
		["~"] = { "bng", "~" },

	// CONDITION:

		["!"] = { "not", "not" },
		["&&"] = { "and", "and" },
		["||"] = { "or", "or" },

	// SYMBOLS:
		
		["?"] = { "qsm", "?" },
		[":"] = { "col", "colon" },
		[";"] = { "sep", "semicolon" },
		[","] = { "com", "comma" },
		["$"] = { "dlt", "delta" },
		["#"] = { "len", "length" },
		["."] = { "prd", "period" },

	// BRACKETS:

		["("] = { "lpa", "left parenthesis" },
		[")"] = { "rpa", "right parenthesis" },
		["{"] = { "lcb", "left curly bracket" },
		["}"] = { "rcb", "right curly bracket" },
		["["] = { "lsb", "left square bracket" },
		["]"] = { "rsb", "right square bracket" },

	// MISC:

		["@"] = { "dir", "directive operator" },
		["..."] = { "varg", "varargs" },
}

/*--------------------------------
	Tokens
----------------------------------*/

QC.RawKeywords = {

	["server"] = { "sv", "serverside" },
	["client"] = { "cl", "clientside" },

	["event"] = { "ev", "event" },

	["if"] = { "if", "if statement" },
	["elseif"] = { "eif", "elseif statement" },
	["else"] = { "els", "else statement" },

	["while"] = { "whl", "while loop" },
	["for"] = { "for", "for statement" },
	["foreach"] = { "fea", "for statement" },
	["break"] = { "brk", "loop break" },
	["continue"] = { "cnt", "loop continue" },

	["in"] = { "in", "foreach in" },

	["switch"] = { "swh", "switch" },
	["case"] = { "cse", "case" },
	["default"] = { "def", "default" },

	["function"] = { "func", "function" },
	["return"] = { "ret", "return" },
	["void"] = { "void", "void" },

	["this"] = { "ths", "this" },

	["true"] = { "tre", "true" },
	["false"] = { "fls", "false" },

	["input"] = { "win", "wire input" },
	["output"] = { "wout", "wire output" },
	["networked"] = { "nw", "networked" },

}