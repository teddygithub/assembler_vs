#include<fstream>
StringList getInputAssemble() {
	ifstream fin("input.txt");
	StringList result;
	string temp;
	while (getline(fin,temp))
	{
		result.push_back(temp);
	}
	fin.close();
	return result;
}