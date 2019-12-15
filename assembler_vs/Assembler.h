#pragma once
#include <string>
#include <vector>
#include <sstream>
//#define HEX_OUTPUT
using namespace std;
typedef vector<string> StringList;
typedef vector<StringList> InstructionList;

class Assembler
{
public:
	Assembler(int id,int iteration, int length,int II);
	~Assembler();
	static StringList splitString(string &s, string &split);
	static void groupInstructions(InstructionList &iL, StringList & sL);
	static void clearComments(StringList&);
	static void transformOpcode(string &);
	void transformIn(string &);
	void transformIn4(string &);
	void transformIndex(string &);
	void tranformOut(string &);
	void transformOperands(StringList &);
	int  groupPELocation(int PE_ID);
	string transformAssembles(string &);
	static bool ifHEX;
private:	
	int PE_ID;
	int locaton;
	int intIteration;
	int intLength;
	int intII;
	string opcode;
	string in1;
	string in2;
	string in3;
	string in4 ;
	string out1;
	string ConfigExtend ;
	string Func ;
	string Imm ;
	string out2 ;
	string out3 ;
	string iteration;
	string AddrMem;
	string DirectAddrMem;
	string InMem ;
	string Offset;
	string Task_PackageNum;
	string Package_Index;
	string Index_PE ;
	string Iteration_PEA ;
	string Iteration_PE ;
	string Initial_Idle ;
	string Iteration_Line ;
	string Count;
	int type;
};

