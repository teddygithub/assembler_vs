#include "pch.h"
#include "Assembler.h"
Assembler::Assembler(int id, int ii, int ll, int II)
{
	in1 = "XXXXXXXX";
	in2 = "XXXXXXXX";
	in3 = "XXXXXXXX";
	in4 = "XXXXXX";
	out1 = "XXXXXXX";
	ConfigExtend = "0";
	Func = "";
	Imm = "X";
	out2 = "XXXXXXX";
	out3 = "X";
	iteration = "XXXXXXXXXX";
	AddrMem = "XXXXXXXX";
	DirectAddrMem = "XXXXXXXX";
	InMem = "XXXXXXXX";
	Offset = "XXXX";
	Offsetex = "XXX";
	IItype = "X";
	increaseFlag = "XX";
	Task_PackageNum = "XXXXX";
	Package_Index = "XXXXX";
	Index_PE = "XXXXXXXX";
	Iteration_PEA = "XXXXXXX";
	Iteration_PE = "XXXXXXX";
	Iteration_PE_ex = "X";
	Initial_Idle = "XXXXXX";
	Initial_Idle_ex = "XX";
	Iteration_Line = "XX";
	Count = "XXXXXX";
	Addr_loop = "X";
	type = 0;
	PE_ID = id;
	locaton = groupPELocation(PE_ID);
	intIteration = ii;
	intLength = ll;
	intII = II;
}

Assembler::~Assembler()
{
}

string D2B(int &n) {    //modified for GR 8-15
	string result;
	switch (n)
	{
	case 0:result = "00000"; break;
	case 1:result = "00001"; break;
	case 2:result = "00010"; break;
	case 3:result = "00011"; break;
	case 4:result = "00100"; break;
	case 5:result = "00101"; break;
	case 6:result = "00110"; break;
	case 7:result = "00111"; break;
	case 8:result = "01000"; break;
	case 9:result = "01001"; break;
	case 10:result = "01010"; break;
	case 11:result = "01011"; break;
	case 12:result = "01100"; break;
	case 13:result = "01101"; break;
	case 14:result = "01110"; break;
	case 15:result = "01111"; break;
	case 16:result = "10000"; break;
	case 17:result = "10001"; break;
	case 18:result = "10010"; break;
	case 19:result = "10011"; break;
	default:result = "00000"; break;
	}
	return result;
}

int charToDigit(char c)
{
	if (c == 'A')
		return 10;
	else if (c == 'B')
		return 11;
	else if (c == 'C')
		return 12;
	else if (c == 'D')
		return 13;
	else if (c == 'E')
		return 14;
	else if (c == 'F')
		return 15;
	else
		return c - '0';
}

long long int B2D(string pre)
{
	int length = pre.size();
	int result = 0;
	for (int i = 0; i < length; i++)
	{
		result += ((charToDigit(pre[i]))*pow(2, length - 1 - i));
	}
	return result;
}

string D2H(long long int pre) {
	ostringstream oss;
	if (pre == 0)
		return "0";
	while (pre != 0) {
		int mod = pre % 16;
		if (mod == 10)
			oss << "a";
		else if (mod == 11)
			oss << "b";
		else if (mod == 12)
			oss << "c";
		else if (mod == 13)
			oss << "d";
		else if (mod == 14)
			oss << "e";
		else if (mod == 15)
			oss << "f";
		else
			oss << pre % 16;
		pre /= 16;
	}
	string res = oss.str();
	oss.str("");//清空原数据流
	for (int i = 0; i < res.length(); i++) {
		oss << res[res.length() - i - 1];
	}
	return oss.str();
}

StringList Assembler::splitString(string& s, string& seperator)
{
	vector<string> result;
	typedef string::size_type string_size;
	string_size i = 0;

	while (i != s.size()) {
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

void Assembler::groupInstructions(InstructionList & instructionList, StringList & inputs) {
	StringList tempList;
	int PE_Number = 0;
	//compensate when first umempty pe is not 0
	//int firstID = atoi(inputs[0].substr(3, 2).c_str());
	//if (firstID != 0) {
	//	for (int i = 0; i != firstID; i++) {
	//		instructionList.push_back(tempList);
	//	}
	//	PE_Number = firstID;
	//}
	int firstID = atoi(inputs[0].substr(3, 2).c_str());
	for (auto i = inputs.begin(); i != inputs.end(); i++) {
		string temp = *i;
		if (temp[0] == 'P') {
			if (PE_Number != 0) {
				instructionList.push_back(tempList);
				tempList.clear();
				PE_Number++;
			}
			tempList.push_back(temp);
			/*string sub_temp = temp.substr(3, 2);
			int number = atoi(sub_temp.c_str());
			if (number != firstID) {
				if (number == PE_Number) {
					instructionList.push_back(tempList);
					tempList.clear();
				}
				else {
					instructionList.push_back(tempList);
					tempList.clear();
					int distance = number - PE_Number;
					for (int i = 0; i != distance; i++) {
						instructionList.push_back(tempList);
					}
					PE_Number = number;
				}
			}
			PE_Number++;*/
		}
		else {
			tempList.push_back(temp);
			PE_Number++;
		}
	}
	instructionList.push_back(tempList);
	//compensate when last umempty pe is not 63
	/*if (PE_Number != 64) {
		tempList.clear();
		for (int i = 0; i != 64 - PE_Number; i++) {
			instructionList.push_back(tempList);
		}
	}*/
}

void Assembler::clearComments(StringList &sL)
{
	for (int i = 0; i < sL.size(); i++) {
		if (sL[i] == "") {
			sL.erase(i + sL.begin());
			i--;
		}
		else if (sL[i][0] == '/' && (sL[i][2] != 's' && sL[i][2] != 'i' && sL[i][2] != 'l')) {
			sL.erase(i + sL.begin());
			i--;
		}
		else {
			string *temp = &sL[i];
			for (int j = 0; j < temp->size(); j++) {
				if ((*temp)[j] == ' '&& j==0) {
					temp->erase(j,1);
					j--;
				}
			}
		}
	}
}

void Assembler::transformOpcode(string &opcode,int PE_ID)
{
	if (opcode == "%router") {
		opcode = "00001";
	}
	else if (opcode == "%loadA"&& PE_ID <= 7) {
		opcode = "00";
		Addr_loop = "0";
	}
	else if (opcode == "%loadB"&& PE_ID <= 7) {
		opcode = "00";
		Addr_loop = "1";
	}
	else if (opcode == "%loadA"&& PE_ID > 7) {
		opcode = "10";
		Addr_loop = "0";
	}
	else if (opcode == "%loadB"&& PE_ID > 7) {
		opcode = "10";
		Addr_loop = "1";
	}
	else if (opcode == "%storeA" && PE_ID<=7) {
		opcode = "01";
		Addr_loop = "0";
	}
	else if (opcode == "%storeB" && PE_ID <= 7) {
		opcode = "01";
		Addr_loop = "1";
	}
	else if (opcode == "%storeA" && PE_ID > 7) {
		opcode = "11";
		Addr_loop = "0";
	}
	else if (opcode == "%storeB" && PE_ID > 7) {
		opcode = "11";
		Addr_loop = "1";
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
	else if (opcode == "%mrl") {
		opcode = "10100";
	}
	else if (opcode == "%umrl") {
		opcode = "10101";
	}
	else if (opcode == "%equal") {
		opcode = "10110";
	}
	else if (opcode == "%div") {
		opcode = "10111";
	}
	else if (opcode == "%udiv") {
		opcode = "11000";
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
	else if (opcode == "%nop") {
		opcode = "00000";
	}
	else if (opcode == "%top") {
		opcode = "top";
	}
	else {
		opcode = "unkno";
	}
}

void Assembler::transformIndex(string &index) {
	//	return 0;//左上顶角
	//	return 1;//右上顶角
	//	return 2;//左下顶角
	//	return 3;//右上顶角
	//	return 4;//上边沿
	//	return 5;//下边沿
	//	return 6;//左边沿
	//	return 7;//右边沿
	//	return 8;//左上区
	//	return 9;//左下区
	//	return 10;//右上区
	//	return 11;//右下区
	if (index == "upup") {
		switch (this->locaton) {
		case 0:index = "0111"; break;
		case 1:index = "0111"; break;
		case 2:index = "0100"; break;
		case 3:index = "0100"; break;
		case 4:index = "0111"; break;
		case 5:index = "0100"; break;
		case 6:index = "0000"; break;
		case 7:index = "0000"; break;
		case 8:index = "0000"; break;
		case 9:index = "0000"; break;
		case 10:index = "0000"; break;
		case 11:index = "0000"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "left") {
		switch (this->locaton) {
		case 0:index = "0011"; break;
		case 1:index = "0000"; break;
		case 2:index = "0011"; break;
		case 3:index = "0000"; break;
		case 4:index = "0000"; break;
		case 5:index = "0000"; break;
		case 6:index = "0111"; break;
		case 7:index = "0100"; break;
		case 8:index = "0010"; break;
		case 9:index = "0010"; break;
		case 10:index = "0010"; break;
		case 11:index = "0010"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "down") {
		switch (this->locaton) {
		case 0:index = "0100"; break;
		case 1:index = "0100"; break;
		case 2:index = "0111"; break;
		case 3:index = "0111"; break;
		case 4:index = "0100"; break;
		case 5:index = "0111"; break;
		case 6:index = "0001"; break;
		case 7:index = "0001"; break;
		case 8:index = "0001"; break;
		case 9:index = "0001"; break;
		case 10:index = "0001"; break;
		case 11:index = "0001"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "righ") {
		switch (this->locaton) {
		case 0:index = "0000"; break;
		case 1:index = "0011"; break;
		case 2:index = "0000"; break;
		case 3:index = "0011"; break;
		case 4:index = "0001"; break;
		case 5:index = "0001"; break;
		case 6:index = "0100"; break;
		case 7:index = "0111"; break;
		case 8:index = "0011"; break;
		case 9:index = "0011"; break;
		case 10:index = "0011"; break;
		case 11:index = "0011"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "upte") {
		switch (this->locaton) {
		case 0:index = "SELF"; break;
		case 1:index = "SELF"; break;
		case 2:index = "0111"; break;
		case 3:index = "0111"; break;
		case 4:index = "SELF"; break;
		case 5:index = "0111"; break;
		case 6:index = "0010"; break;
		case 7:index = "0010"; break;
		case 8:index = "0100"; break;
		case 9:index = "0000"; break;
		case 10:index = "0100"; break;
		case 11:index = "0000"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "dote") {
		switch (this->locaton) {
		case 0:index = "0111"; break;
		case 1:index = "0111"; break;
		case 2:index = "SELF"; break;
		case 3:index = "SELF"; break;
		case 4:index = "0111"; break;
		case 5:index = "SELF"; break;
		case 6:index = "0011"; break;
		case 7:index = "0011"; break;
		case 8:index = "0000"; break;
		case 9:index = "0101"; break;
		case 10:index = "0000"; break;
		case 11:index = "0101"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "lete") {
		switch (this->locaton) {
		case 0:index = "SELF"; break;
		case 1:index = "0011"; break;
		case 2:index = "SELF"; break;
		case 3:index = "0011"; break;
		case 4:index = "0010"; break;
		case 5:index = "0010"; break;
		case 6:index = "SELF"; break;
		case 7:index = "0111"; break;
		case 8:index = "0110"; break;
		case 9:index = "0110"; break;
		case 10:index = "0000"; break;
		case 11:index = "0000"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "rite") {
		switch (this->locaton) {
		case 0:index = "0011"; break;
		case 1:index = "SELF"; break;
		case 2:index = "0011"; break;
		case 3:index = "SELF"; break;
		case 4:index = "0011"; break;
		case 5:index = "0011"; break;
		case 6:index = "0111"; break;
		case 7:index = "SELF"; break;
		case 8:index = "0000"; break;
		case 9:index = "0000"; break;
		case 10:index = "0111"; break;
		case 11:index = "0111"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "di2r") {
		switch (this->locaton) {
		case 0:index = "0001"; break;
		case 1:index = "0001"; break;
		case 2:index = "0001"; break;
		case 3:index = "0001"; break;
		case 4:index = "NONO"; break;
		case 5:index = "NONO"; break;
		case 6:index = "0101"; break;
		case 7:index = "0101"; break;
		case 8:index = "NONO"; break;
		case 9:index = "NONO"; break;
		case 10:index = "NONO"; break;
		case 11:index = "NONO"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "di2c") {
		switch (this->locaton) {
		case 0:index = "0101"; break;
		case 1:index = "0101"; break;
		case 2:index = "0101"; break;
		case 3:index = "0101"; break;
		case 4:index = "0101"; break;
		case 5:index = "0101"; break;
		case 6:index = "NONO"; break;
		case 7:index = "NONO"; break;
		case 8:index = "NONO"; break;
		case 9:index = "NONO"; break;
		case 10:index = "NONO"; break;
		case 11:index = "NONO"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "di3r") {
		switch (this->locaton) {
		case 0:index = "0010"; break;
		case 1:index = "0010"; break;
		case 2:index = "0010"; break;
		case 3:index = "0010"; break;
		case 4:index = "NONO"; break;
		case 5:index = "NONO"; break;
		case 6:index = "0110"; break;
		case 7:index = "0110"; break;
		case 8:index = "NONO"; break;
		case 9:index = "NONO"; break;
		case 10:index = "NONO"; break;
		case 11:index = "NONO"; break;
		default:index = "UNKOWN";	break;
		}
	}
	else if (index == "di3c") {
		switch (this->locaton) {
		case 0:index = "0110"; break;
		case 1:index = "0110"; break;
		case 2:index = "0110"; break;
		case 3:index = "0110"; break;
		case 4:index = "0110"; break;
		case 5:index = "0110"; break;
		case 6:index = "NONO"; break;
		case 7:index = "NONO"; break;
		case 8:index = "NONO"; break;
		case 9:index = "NONO"; break;
		case 10:index = "NONO"; break;
		case 11:index = "NONO"; break;
		default:index = "UNKOWN";	break;
		}
	}
}

string IntToBinaryString(int n,int length) {
	string binary="";
	if (n < 0) n = -n;
	while (n / 2 != 1 && n!=0) {		
		binary = n % 2 == 0 ? "0" + binary : "1" + binary;
		n = n / 2;
	}
	if (n != 0) {
		binary = n % 2 == 0 ? "0" + binary : "1" + binary;
		binary = "1" + binary;
	}
	int distance = length - binary.length();
	if (distance>0) {
		for (int i = 0; i != distance; i++) {
			binary = "0" + binary;
		}
	}
	return binary;
}

void Assembler::tranformOut(string &temp)
{
	string number = "";
	for (int i = 2; i < temp.size(); i++) {
		number = number + temp[i];
	}
	int Number = atof(number.c_str());
	if (temp[0] == 'L' && temp[1] == 'R') {
		temp = "00" + D2B(Number);
	}
	else if (temp[0] == 'G' && temp[1] == 'R')
	{
		temp = "01" + D2B(Number);
	}
}

void Assembler::transformIn(string &temp)
{
	if (temp[0] == 'P' && temp[1] == 'E') {
		string source = "010";
		string out1_or_out2 = temp.substr(2, 1);
		if (out1_or_out2 == "0") {
			source = "010";
		}
		else {
			source = "100";
		}
		string index;
		for (int i = 4; i < temp.size(); i++) {
			index = index + temp[i];
		}
		
		if (index == "self") {
			if (out1_or_out2 == "0") {
				temp = "01100000";
			}
			else if (out1_or_out2 == "1") {
				temp = "01101000";
			}
			else {
				_ASSERT("out1_or_out2 is wrong");
			}
		}
		else {
			transformIndex(index);
			if (temp[3] == 'E')
				temp = source + "1" + index; //取流水线寄存器输出modified
			else
				temp = source + "0" + index; //取out输出
		}
	}
	else if (temp[0] == 'L' && temp[1] == 'R') {
		string source = "000";
		string index = "";
		for (int i = 2; i < temp.size(); i++) {
			index = index + temp[i];
		}
		int Number = atof(index.c_str());
		temp = source + D2B(Number);
	}
	else if (temp[0] == 'G' && temp[1] == 'R') {
		string source = "001";
		string index = "";
		for (int i = 2; i < temp.size(); i++) {
			index = index + temp[i];
		}
		int Number = atof(index.c_str());
		temp = source + D2B(Number);
	}
	else if (temp[0] == 'I' && temp[1] == 'M') {		
		string index;
		Imm = "1";		
		for (int i = 2; i < temp.size(); i++) {
			index = index + temp[i];
		}
		int Number = atof(index.c_str());
		string binary = IntToBinaryString(Number, 8);
		temp = binary;
	}
	else if (temp[0] == 'S' && temp[1] == 'M') {
		string SM;
		for (int i = 2; i < temp.size(); i++) {
			SM = SM + temp[i];
		}
		int Number = atoi(SM.c_str());
		string binary = IntToBinaryString(Number, 13);
		temp = "100"+binary.substr(0,5);
		DirectAddrMem = binary.substr(5,8);
	}
}

void Assembler::transformIn4(string &temp)
{
	string out1_or_out2 = temp.substr(2, 1);
	string index;
	for (int i = 3; i < temp.size(); i++) {
		index = index + temp[i];
	}
	
	if (index == "self") {
		temp = "000000";
	}
	else {
		transformIndex(index);
		temp = "10"+index;

	}
}

void Assembler::transformOperands(StringList &operands)
{
	if (type == 0) { //ALU
		int size = 2;
		Imm = "0";
		in1 = operands.at(0);
		transformIn(in1);
		if (opcode == "00001") {//route
			transformIn(in1);
			//in1 = "00000000";
			in2 = operands.at(1);
			transformIn(in2);
			size = 2;
		}
		else {
			in2 = operands.at(1);
			transformIn(in2);
		}
		if (opcode == "00000") { //nop
			in1 = "00000000";
			in2 = "00000000";
		}
		if (opcode == "10011" || opcode == "10001") { //mac
			in3 = operands.at(2);
			transformIn(in3);
			size = 3;
		}
		else {
			in3 = "00000000";
		}
		if (opcode == "01010") { //sel
			in4 = operands.at(2);
			transformIn4(in4);
			size = 3;
		}
		else {
			in4 = "000000";
		}
		if (operands.size() > size) {
			out1 = operands.at(size);
			tranformOut(out1);
		}
		else {
			out1 = "1000000";
		}
		out2 = "1000000";
		out3 = "0";
		if (intLength == 1) {
			string iter_num = IntToBinaryString(intIteration, 5);
			string iter_II = IntToBinaryString(intII, 3);
			if (intII < 0) {
				intII = -intII;
				out3 = "1";
			}
			if (intII<=7)
				iteration = "00" + iter_num + iter_II;
			else
				iteration = "01" + iter_num + "000";    //modified for ii>7 load iteration from GR

		}
		else {
			iteration = "0000000000";
		}
			
		
	}
	else if (type == 1) { //LS
		if (intLength == 1) {
			string iter_num = IntToBinaryString(intIteration, 5);
			string iter_II = IntToBinaryString(intII, 3);
			if (intII < 0) {
				intII = -intII;
				IItype = "1";
			}
			else IItype = "0";
			if (intII <= 7)
				iteration = "00" + iter_num + iter_II;
			else
				iteration = "01" + iter_num + "000";    //modified for ii>7
		}
		else {
			iteration = "0000000000";
		}
		DirectAddrMem = "00000000";
		int size = 2;
		if (opcode == "00" |opcode == "10") { //Load
			AddrMem = operands.at(0);
			transformIn(AddrMem);
			int intOffset = atoi(operands.at(1).c_str());
			if (intOffset < 0) {
				intOffset = -intOffset;
				increaseFlag = "10";
			}
			else if (intOffset == 0)
				increaseFlag = "00";
			else increaseFlag = "01";
			if (intOffset >= 16) {
				intOffset = intOffset - 16;
				Offsetex = "100";
			}
			else Offsetex = "000";
			Offset = IntToBinaryString(intOffset, 4);
			InMem = "00000000";
		}
		else if (opcode == "01" | opcode =="11" ) { //Store		
			AddrMem = operands.at(0);
			transformIn(AddrMem);
			InMem = operands.at(1);
			int intOffset = atoi(operands.at(2).c_str());
			if (intOffset < 0) {
				intOffset = -intOffset;
				increaseFlag = "10";
			}
			else if (intOffset == 0)
				increaseFlag = "00";
			else increaseFlag = "01";
			if (intOffset >= 16) {
				intOffset = intOffset - 16;
				Offsetex = "100";
			}
			else Offsetex = "000";
			Offset = IntToBinaryString(intOffset, 4);
			transformIn(AddrMem);
			transformIn(InMem);
			size = 3;
		}
		if (operands.size() > size) {
			out1 = operands.at(size);
			tranformOut(out1);
		}
		else {
			out1 = "1000000";
		}
	}
	
}

int Assembler::groupPELocation(int PE_ID)
{
	if (PE_ID == 0) {
		return 0;//左上顶角
	}
	else if (PE_ID == 7) {
		return 1;//右上顶角
	}
	else if (PE_ID == 56) {
		return 2;//左下顶角
	}
	else if (PE_ID == 63) {
		return 3;//右下顶角
	}
	else if (PE_ID / 8 == 0) {
		return 4;//上边沿
	}
	else if (PE_ID / 8 == 7) {
		return 5;//下边沿
	}
	else if (PE_ID % 8 == 0) {
		return 6;//左边沿
	}
	else if (PE_ID % 8 == 7) {
		return 7;//右边沿
	}
	else if (1 <= PE_ID % 8 && PE_ID % 8 <= 3 && 1 <= PE_ID / 8 && PE_ID / 8 <= 3) {
		return 8;//左上区
	}
	else if (1 <= PE_ID % 8 && PE_ID % 8 <= 3 && 4 <= PE_ID / 8 && PE_ID / 8 <= 6) {
		return 9;//左下区
	}
	else if (4 <= PE_ID % 8 && PE_ID % 8 <= 6 && 1 <= PE_ID / 8 && PE_ID / 8 <= 3) {
		return 10;//右上区
	}
	else if (4 <= PE_ID % 8 && PE_ID % 8 <= 6 && 4 <= PE_ID / 8 && PE_ID / 8 <= 6) {
		return 11;//右下区
	}
}

string Assembler::transformAssembles(string &temp)
{
	int iteration_pe_temp;
	if (temp[0] == 'P'&&temp[1] == 'E') {
		return temp;
	}
	if (temp[0] == '/') {
		return temp;
	}
	string sperator = " ";
	StringList opcode2Operand = splitString(temp, sperator);
	opcode = opcode2Operand.at(0);
	string operand = opcode2Operand.at(1);
	sperator = ",";
	StringList operands = splitString(operand, sperator);
	transformOpcode(opcode,PE_ID);
	type = 0;
	if (opcode.length() == 2) {
		Func = "10";
		type = 1;
	}
	else if (opcode.length() == 3) {
		Func = "00";
		type = 2;
	}
	else {
		Func = "01";
	}
	transformOperands(operands);

	string transformed;
	if (type == 0) { // ALUF
#ifdef  HEX_OUTPUT
		//iteration = "1111111111";   //modified for load iteration from LR[8-11] or GR[16-19]
		transformed = ConfigExtend +Func + in1 +  in2 +  in3 +  in4 + 
			Imm +  out1 +  out2 +  out3 +  iteration +  opcode;
		string result("");
		for (int j = 0; j != 16; j++)
		{
			int dec = B2D(transformed.substr(4 * j, 4));
			string hex = D2H(dec);
			result = result + hex;
		}
		transformed = result;
#else
		//iteration = "1111111111";   //modified for load iteration from LR[8-11] or GR[16-19]
		transformed = ConfigExtend + "_" + Func + "_" + in1 + "_" + in2 + "_" + in3 + "_" + in4 + "_" +
			Imm + "_" + out1 + "_" + out2 + "_" + out3 + "_" + iteration + "_" + opcode;
#endif //  HEX_OUTPUT

		
	}
	else if (type == 1) { //LS
#ifdef HEX_OUTPUT
		transformed = ConfigExtend +  Func +  AddrMem + InMem
			+  DirectAddrMem + Offset +  Offsetex  + out1 + Addr_loop + "0000" + IItype + increaseFlag
			+  iteration + "000" +  opcode;
		string result("");
		for (int j = 0; j != 16; j++)
		{
			int dec = B2D(transformed.substr(4 * j, 4));
			string hex = D2H(dec);
			result = result + hex;
	    }
		transformed = result;
#else
		transformed = ConfigExtend + "_" + Func + "_" + AddrMem + "_" + InMem
			+ "_" + DirectAddrMem + "_" + Offset + "_" + Offsetex + "_" + out1 + "_" + Addr_loop + "0000" + "_" + IItype + "_" + increaseFlag
			+ "_" + iteration + "_" + "000" + "_" + opcode;
#endif // HEX_OUTPUT
	}
	else if (type == 2) { //top
		Index_PE = IntToBinaryString(PE_ID, 8);	
		Task_PackageNum = operands.at(0); //0开始计数
		Task_PackageNum = IntToBinaryString(atof(Task_PackageNum.c_str()), 5);
		Package_Index = operands.at(1); //0开始计数
		Package_Index = IntToBinaryString(atof(Package_Index.c_str()), 5);
		Iteration_PEA = operands.at(2); 
		Iteration_PEA = IntToBinaryString(atof(Iteration_PEA.c_str()), 7);
		Iteration_PE = operands.at(3);
		iteration_pe_temp = atof(Iteration_PE.c_str());
		if (iteration_pe_temp >= 128) {
			iteration_pe_temp = iteration_pe_temp - 128;
			Iteration_PE_ex = "1";
		}
		else Iteration_PE_ex = "0";
		Iteration_PE = IntToBinaryString(iteration_pe_temp, 7);
		Initial_Idle = operands.at(4);
		Initial_Idle = IntToBinaryString(atof(Initial_Idle.c_str()), 8);
		Initial_Idle_ex = Initial_Idle.substr(0, 2);
		Initial_Idle = Initial_Idle.substr(2,6);
		Iteration_Line = operands.at(5);
		Iteration_Line = IntToBinaryString(atof(Iteration_Line.c_str()), 2);
		Count = operands.at(6);
		int intCount = atof(Count.c_str());
		Count = IntToBinaryString(intCount, 6);
#ifdef  HEX_OUTPUT
		transformed = ConfigExtend +  Func +  Task_PackageNum +  "000" + Package_Index + "000" +
			Index_PE +  Iteration_PEA + Iteration_PE + 
			Initial_Idle +  Iteration_Line + Initial_Idle_ex + Iteration_PE_ex + "000000" + Count;
		string result("");
		for (int j = 0; j != 16; j++)
		{
			int dec = B2D(transformed.substr(4 * j, 4));
			string hex = D2H(dec);
			result = result + hex;
		}
		transformed = result;
#else
		transformed = ConfigExtend + "_" + Func + "_" + Task_PackageNum + "_" + "000" + "_" + Package_Index + "_" + "000" +
			"_" + Index_PE + "_" + Iteration_PEA + "_" + Iteration_PE + "_" +
			Initial_Idle + "_" + Iteration_Line + "_" +  Initial_Idle_ex + "_" + Iteration_PE_ex +"_000000" + "_" + Count;
#endif //  HEX_OUTPUT

		
	}
	return transformed;
}


