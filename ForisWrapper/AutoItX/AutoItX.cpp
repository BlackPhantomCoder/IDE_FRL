#include <Windows.h>
#include "AutoItX3_DLL.h"
#include <iostream>
#include <string>
#include <algorithm>
#include <set>
#include <io.h>
#include <fcntl.h>
#include <vector>
#include <string_view>
#include <fstream>
using namespace std;

void check_wait(const string_view& str) {
    auto in = ifstream(str.data());
    while (!in) {
        Sleep(100);
        in = ifstream(str.data()); 
    };
}

#include <filesystem>
namespace fs = std::filesystem;
void file_del(const string_view& filename) {
    for(;;) {
        try
        {
            fs::remove(filename.data());
        }
        catch (...)
        {
            Sleep(50);
            continue;
        }
        break;
    }
}

void write(string_view filename, string_view str) {
    auto out = ofstream(filename.data());
    out << str.data();
}

string read(string_view filename) {
    string result;
    auto in = ifstream(filename.data());
    auto ch = in.get();
    while (in) {
        result += ch;
        ch = in.get();
    }
    return result;
}

string get(string_view in_name, string_view in_acc_name) {
    auto result = read(in_name);
    file_del(in_acc_name);
    return result;
}

void send(string_view str, string_view out_name, string_view out_acc_name) {
    write(out_name, str);
    file_del(out_acc_name);
}

enum class state {input, output};
state sync(string_view out_acc_name, string_view in_acc_name) {
    for (;;) {
        auto in = ifstream(out_acc_name);
        if (in)  return state::input;
        auto out = ifstream(in_acc_name);
        if (out)  return state::output;
        Sleep(50);
    }
}

void create_conf(
    const string& sinchro_path,
    string_view foris_path,
    string_view disk_letter,
    string_view disk_path
) {
    fs::remove(sinchro_path + "/conf.conf");
    fs::copy(sinchro_path + "/template.conf", sinchro_path + "/conf.conf");
    auto conf = ofstream(sinchro_path + "/conf.conf", std::ios::app);
    conf << endl;
    conf << "MOUNT " << disk_letter << ": " << disk_path << endl;
    conf << disk_letter << ":" << endl;
    conf << "MOUNT F: " << sinchro_path << endl;
    conf << "MOUNT X: " << foris_path << endl;
    conf << "x:\\fsmem - > nul" << endl;
    conf << "x:\\foris f:\driver.lsp" << endl;
    conf << "x:\\fsfree" << endl;
    conf << "exit" << endl;
}

int main(int argc, char* argv[])
{
    if (argc < 6) return 1;

    //auto argv2 = vector<string>{
    //    "D:/SomePrograms/DosEngine/DOSBox/DOSBox.exe",
    //    "C:/Users/Dima/source/repos/TryDos2/Debug/sinchro",
    //    "D:/SomePrograms/DosEngine/foris",
    //    "D",
    //    "C:/Users/Dima/source/repos/TryDos2/Debug/sinchro/data"
    //};

    auto console = GetConsoleWindow(); 


    auto dos_exe_path = string(argv[1]);
    auto sinchro_path = string(argv[2]);
    auto foris_path =   string(argv[3]);
    auto disk_letter =  string(argv[4]);
    auto disk_path =    string(argv[5]);

    const auto in_name = sinchro_path + "\\out.lsp";
    const auto out_name = sinchro_path + "\\in.lsp";

    const auto in_acc_name = sinchro_path + "\\oacc.lsp";
    const auto out_acc_name = sinchro_path + "\\inacc.lsp";

   
    file_del(in_acc_name);
    create_conf(sinchro_path, foris_path, disk_letter, disk_path);
    //

    auto s = wstring(begin(dos_exe_path), end(dos_exe_path)) + L" -conf " + wstring(begin(sinchro_path), end(sinchro_path))  + L"/conf.conf -noconsole";

    AU3_Run(s.c_str(), NULL, SW_HIDE);
    Sleep(2300);
    auto hdos = FindWindow(L"SDL_app", nullptr);
    AU3_WinActiveByHandle(hdos);
    AU3_Send(L"{enter}");
    Sleep(1000);
    //ShowWindow(hdos, SW_HIDE);
    
    if (hdos != NULL) {
        while (cin) {
            auto state = sync(out_acc_name, in_acc_name);
            if (state == state::input) {
                cout << "> ";
                string s;
                getline(cin, s);
                if (empty(s)) continue;
                send(s + "\n\n", out_name, out_acc_name);
            }
            else {
                cout << get(in_name, in_acc_name);
            }
            Sleep(51);
        }
        if (IsWindow(hdos)) {
            SendMessage(hdos, WM_CLOSE, NULL, NULL);
        }
    }
    else {
        cout << "DOSBox don't found" << endl;
        cin.get();
    }
    return 0;
}