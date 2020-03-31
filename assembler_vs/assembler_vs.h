#include<fstream>
StringList getInputAssemble() {
	ifstream fin("test.txt");//pea1add_huibian_out.txt   pea0add_huibian.txt
	//ifstream fin("test_Counts.txt");
	//ifstream fin("pea1add_huibian_out.txt");//pea1add_huibian_out.txt   pea0add_huibian.txt
	//ifstream fin("pea0add_huibian.txt");//pea1add_huibian_out.txt   pea0add_huibian.txt
	StringList result;
	string temp;
	while (getline(fin,temp))
	{
		result.push_back(temp);
	}
	fin.close();
	return result;
}