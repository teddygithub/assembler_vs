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
	int countInst = 0;
	vector<string>  fourInst;
	for (auto i = instructionList.begin(); i != instructionList.end(); i++) {	
		int PE=0;
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
					string total = temp.substr(2, temp.size() - 2);
					string sep = "|";
					string stringIteration = Assembler::splitString(total,sep)[0];
					string stringLength = Assembler::splitString(total, sep)[1];
					int intII;
					if (Assembler::splitString(total, sep).size() > 2) {
						string stringII = Assembler::splitString(total, sep)[2];
						intII = atoi(stringII.substr(3, stringII.size() - 3).c_str());
					} else{
						intII = 0;
					}
					int intIteration = atoi(stringIteration.substr(10, stringIteration.size() - 10).c_str());
					int intLength = atoi(stringLength.substr(7, stringLength.size() - 7).c_str());				

					if (intLength != 1) {
						for (int it = 0; it != intIteration; it++) {
							for (int m = 1; m <= intLength; m++) {
								string temp = *(j + m);
								Assembler ass = Assembler(PE, intIteration, intLength,intII);
								countInst++;
#ifdef HEX_OUTPUT
								if (countInst % 4 == 0) {
									fourInst.push_back(ass.transformAssembles(temp));
									int i = 4;
									while (i--){
										fout << fourInst[i].substr(0, 8) << endl;
										fout << fourInst[i].substr(8, 8) << endl;
									}
									fourInst.clear();
								}
								else
									fourInst.push_back(ass.transformAssembles(temp));
#else	
								fout << ass.transformAssembles(temp) << endl;
#endif
							}
						}
					}
					else {
						string temp = *(j + 1);
						Assembler ass = Assembler(PE, intIteration, intLength,intII);
						countInst++;
#ifdef HEX_OUTPUT
						if (countInst % 4 == 0) {
							fourInst.push_back(ass.transformAssembles(temp));
							int i = 4;
							while (i--) {
								fout << fourInst[i].substr(0, 8) << endl;
								fout << fourInst[i].substr(8, 8) << endl;
							}
							fourInst.clear();
					}
						else
							fourInst.push_back(ass.transformAssembles(temp));
#else	
						fout << ass.transformAssembles(temp) << endl;
#endif
					}
					
				}
				else if (temp[0] == '%' && temp[1] == 't') {
					Assembler ass = Assembler(PE, 0, 1,0);
					countInst++;
#ifdef HEX_OUTPUT
					if (countInst % 4 == 0) {
						fourInst.push_back(ass.transformAssembles(temp));
						int i = 4;
						while (i--) {
							fout << fourInst[i].substr(0, 8) << endl;
							fout << fourInst[i].substr(8, 8) << endl;
						}
						fourInst.clear();
					}
					else
						fourInst.push_back(ass.transformAssembles(temp));
#else	
					fout << ass.transformAssembles(temp) << endl;
#endif
				}
				else {
					StringList tempList = *i;
					string temp = tempList[0];
					PE = atoi(temp.substr(3, 2).c_str());
				}
			}
		}
#ifndef HEX_OUTPUT
		fout << endl;
#endif
	}
	fout.close();
}