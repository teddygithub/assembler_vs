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
			for (auto j = i->begin(); j != i->end(); j++) {
				string temp = *j;
				if (temp[0] == '/' && temp[2] == 's') {
					string stringStart = temp;
					int intStart = atoi(stringStart.substr(8, stringStart.size() - 8).c_str());
					for (int it = 0; it != intStart; it++) {
						fout << "0000000000000000000000000000000000000000000000000000000000000000" << endl;
					}
				}
				else if(temp[0] == '/' && temp[2] =='i'){
					string stringIteration = temp;
					string stringLength = *(j + 1);
					int intIteration = atoi(stringIteration.substr(12, stringIteration.size() - 12).c_str());
					int intLength = atoi(stringLength.substr(9, stringLength.size() - 9).c_str());
					if (intLength != 1) {
						for (int it = 0; it != intIteration; it++) {
							for (int m = 1; m <= intLength; m++) {
								string temp = *(j + 1 + m);
								Assembler ass = Assembler(i - instructionList.begin(), intIteration, intLength);
								fout << ass.transformAssembles(temp) << endl;
							}
						}
					}
					else {
						string temp = *(j + 2);
						Assembler ass = Assembler(i - instructionList.begin(), intIteration, intLength);
						fout << ass.transformAssembles(temp) << endl;
					}
					
				}
				else {
					continue;
				}
			}
		}
	}
	fout.close();
}