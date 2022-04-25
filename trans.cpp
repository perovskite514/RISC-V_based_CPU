#include <bits/stdc++.h>
using namespace std;

int main(){

    string s;
    ifstream reading_file;
    string filename = "fib10.mem";
    reading_file.open(filename, ios::in);
    while(getline(reading_file, s)){
        string a = s.substr(27, 8) + s.substr(18, 8) + s.substr(9, 8) + s.substr(0, 8);
        cout << a << endl;
    }
    reading_file.close();
}