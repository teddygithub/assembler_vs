#include "pch.h"
#include "Assembler.h"


Assembler::Assembler()
{
}


Assembler::~Assembler()
{
}

StringList Assembler::splitString(string& s, string& seperator)
{
	vector<string> result;
	typedef string::size_type string_size;
	string_size i = 0;

	while (i != s.size()) {
		//找到字符串中首个不等于分隔符的字母；
		int flag = 0;
		while (i != s.size() && flag == 0) {
			flag = 1;
			for (string_size x = 0; x < seperator.size(); ++x)
				if (s[i] == seperator[x]) {
					++i;
					flag = 0;
					break;
				}
		}

		//找到又一个分隔符，将两个分隔符之间的字符串取出；
		flag = 0;
		string_size j = i;
		while (j != s.size() && flag == 0) {
			for (string_size x = 0; x < seperator.size(); ++x)
				if (s[j] == seperator[x]) {
					flag = 1;
					break;
				}
			if (flag == 0)
				++j;
		}
		if (i != j) {
			result.push_back(s.substr(i, j - i));
			i = j;
		}
	}
	return result;
}

void Assembler::groupInstructions(InstructionList & instructionList, StringList & inputs){
	StringList tempList;
	int PE_Number = 0;
	//compensate when first umempty pe is not 0
	int firstID = atoi(inputs[0].substr(3,2).c_str());
	if (firstID != 0) {
		for (int i = 0; i != firstID; i++) {
			instructionList.push_back(tempList);
		}
		PE_Number = firstID;
	}
	for (auto i = inputs.begin(); i != inputs.end(); i++){
		string temp = *i;
		if (temp[0] == 'P') {
			string sub_temp = temp.substr(3, 2);
			int number = atoi(sub_temp.c_str());
			if (number != firstID) {
				if (number == PE_Number ) {
					instructionList.push_back(tempList);
					tempList.clear();
				}
				else {
					instructionList.push_back(tempList);
					tempList.clear();
					int distance = number-PE_Number;
					for (int i = 0; i != distance; i++) {
						instructionList.push_back(tempList);
					}
					PE_Number = number;
				}
			}			
			PE_Number++;
		}
		else {
			tempList.push_back(temp);
		}
	}
	instructionList.push_back(tempList);
	//compensate when last umempty pe is not 63
	if (PE_Number != 64) {
		tempList.clear();
		for (int i = 0; i != 64 - PE_Number; i++) {
			instructionList.push_back(tempList);
		}
	}
}

void Assembler::clearComments(StringList &sL)
{
	for (int i=0;i<sL.size();i++ ){
		if (sL[i] == "") {
			sL.erase(i+sL.begin());
			i--;
		}
		else if (sL[i][0] == '/' && (sL[i][2] != 's' && sL[i][2]!= 'i')) {
			sL.erase(i + sL.begin());
			i--;
		}
	}
}

void Assembler::transformOpcode(string &opcode)
{
	if (opcode == "%load") {
		opcode = "01111";
	}
	else if (opcode == "%store") {
		opcode = "10000";
	}
	else if (opcode == "%add") {
		opcode = "00010";
	}
	else if (opcode == "%uadd") {
		opcode = "00100";
	}
	else if (opcode == "%sub") {
		opcode = "00011";
	}
	else if (opcode == "%usub") {
		opcode = "00101";
	}
	else if (opcode == "%mul") {
		opcode = "10000";
	}
	else if (opcode == "%umul") {
		opcode = "10010";
	}
	else if (opcode == "%mac") {
		opcode = "10001";
	}
	else if (opcode == "%umac") {
		opcode = "10011";
	}
	else if (opcode == "%and") {
		opcode = "00110";
	}
	else if (opcode == "%or") {
		opcode = "00111";
	}
	else if (opcode == "%xor") {
		opcode = "01000";
	}
	else if (opcode == "%abs") {
		opcode = "01001";
	}
	else if (opcode == "%sel") {
		opcode = "01010";
	}
	else if (opcode == "%sll") {
		opcode = "01011";
	}
	else if (opcode == "%srl") {
		opcode = "01100";
	}
	else if (opcode == "%arl") {
		opcode = "01101";
	}
	else if (opcode == "%all") {
		opcode = "01110";
	}
	else if (opcode == "%clz") {
		opcode = "01111";
	}	
	else if (opcode == "%nop"){
		opcode = "00000";
	}
	else {
		opcode = "unknwon";
	}
}

void Assembler::transformInOut(string &temp)
{
	if (temp[0] == 'x') {
		temp = "0000_0000";
	}
	else if (temp[0] == 's' && temp[1] == 'm') {
		string step;
		for (int i = 2; i < temp.size(); i++) {
			step.append(&temp[i]);
		}
		int Number = atof(step.c_str());
		
		temp = "0011";
	}
	else {
		temp = "0000";

	}
}

string Assembler::transformAssembles(string &temp)
{
	if (temp[0] == 'P'&&temp[1] == 'E') {
		return temp;
	}
	if (temp[0] == '/') {
		return temp;
	}
	string sperator = " ";
	StringList opcode2Operand = splitString(temp, sperator);
	string opcode = opcode2Operand.at(0); 
	string operand = opcode2Operand.at(1);
	sperator = ",";
	StringList operands = splitString(operand, sperator);
	string input1 = operands.at(0);
	string input2 = operands.at(1);
	string input3 = operands.at(2);
	string output = operands.at(3);

	transformInOut(input1);
	transformInOut(input2);
	transformInOut(input3);
	transformInOut(output);
	transformOpcode(opcode);

	string transformed = input1 + "_" + input2 + "_" + input3 + "_" + output + "_" + opcode;
	return transformed;
}


