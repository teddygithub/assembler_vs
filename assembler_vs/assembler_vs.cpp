// assembler_vs.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include "pch.h"
#include <iostream>
#include "assembler_vs.h"

int main(){
    std::cout << "Assembler for CGRA V0.1!\n"; 
	StringList inputs = getInputAssemble();
	Assembler::clearComments(inputs);
	InstructionList instructionList;
	Assembler::groupInstructions(instructionList,inputs);
	ofstream fout("output.txt");
	//for (int i = 0; i < inputs.size(); i++) {
	//	string temp = inputs.at(i);
	//	fout <<Assembler::transformAssembles(temp)<<endl;
	//}
	for (auto i = instructionList.begin(); i != instructionList.end(); i++) {	
		fout << "PE" << i - instructionList.begin() << endl;
		if (i->size() != 0) {
			StringList tempList = *i;
			string stringStart = tempList[0];
			string stringIteration = tempList[1];
			int intStart = atoi(stringStart.substr(8, stringStart.size() - 8).c_str());
			int intIteration = atoi(stringIteration.substr(12, stringIteration.size() - 12).c_str());
			for (int it = 0; it != intStart; it++) {
				fout << "0000_0000_0000_0000_0000_0000_0000_00000"<<endl;
			}
			for (int it = 0; it != intIteration; it++) {
				for (auto j = i->begin()+2; j != i->end(); j++) {
					string temp = *j;
					fout << Assembler::transformAssembles(temp) << endl;
				}
			}
			
		}
	}
	fout.close();
}