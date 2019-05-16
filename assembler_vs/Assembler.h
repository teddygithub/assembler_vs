#pragma once
#include <string>
#include <vector>
using namespace std;
typedef vector<string> StringList;
typedef vector<StringList> InstructionList;

class Assembler
{
public:
	Assembler();
	~Assembler();
	static StringList splitString(string &s, string &split);
	static void groupInstructions(InstructionList &iL, StringList & sL);
	static void clearComments(StringList&);
	static void transformOpcode(string &);
	static void transformInOut(string &);
	static string transformAssembles(string &);
};

