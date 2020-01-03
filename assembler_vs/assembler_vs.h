#include<fstream>
StringList getInputAssemble() {
	ifstream fin("ConfigPack_conven1_assemble.txt");
	StringList result;
	string temp;
	while (getline(fin,temp))
	{
		result.push_back(temp);
	}
	fin.close();
	return result;
}