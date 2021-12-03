#include <QCoreApplication>

#include <QtCore>

#include "DosWrapper.h"

#include <iostream>
#include <cctype>
#include <sstream>
using namespace std;


void exists_file_info_or_exit(const QString& file, const QString& name){
    if(!is_exist_file(file)){
        cout << name.toStdString() << ": " << file.toStdString() << " not exist" << endl;
        exit(0);
    }
}

void exists_dir_info_or_exit(const QString& dir, const QString& name){
    if(!is_exist_file(dir)){
        cout << name.toStdString() << ": " << dir.toStdString() << " not exist" << endl;
        exit(0);
    }
}
void clear_spaces(std::string& str){
    size_t prev_it = 0;
    while(true){
        if(auto it = str.find( ' ', prev_it); it != str.npos){
            prev_it = it;
            str.erase(it);
        }
        else break;
    }
}

QSet<QString> commands = {"--relp", "--dosexe", "--forisp", "--disklet", "--diskp", "--sincp", "--doscpucycles"};

std::string get_or_exe(QStringList::iterator it, QStringList::iterator end){
    if(!commands.contains(*it)){
        cout << (*it).toStdString() << " is not a command" <<endl;
        cout << "allowed commands are:" << endl;
        for(const auto& command: commands){
            cout << command.toStdString() << endl;
        }
        exit(0);
    }
    if(it + 1 == end) {
        cout << (*it).toStdString() << " not enougth params" <<endl;
        cout << "for " << it->toStdString() << " required 1 param" <<endl;
        exit(0);
    }
    return (it + 1)->toStdString();
}

dos_data parse_or_exit(QStringList commands){
    dos_data d{};
    auto it = commands.begin();
    while(it != end(commands)){
        const auto& l = *it;
        if(l == "--relp"){
            d.relative = true;
            ++it;
            continue;
        }
        auto r = get_or_exe(it, end(commands));
        //?
        clear_spaces(r);
        it += 2;
        if(l == "--dosexe"){
            d.dos_exe_path = r;
            continue;
        }
        if(l == "--forisp"){
            d.foris_path = r;
            continue;
        }
        if(l == "--disklet"){
            d.disk_letter = r;
            continue;
        }
        if(l == "--diskp"){
            d.disk_path = r;
            continue;
        }
        if(l == "--sincp"){
            d.sinchro_path = r;
            continue;
        }
        if(l == "--doscpucycles"){
            d.dos_cpu_cycles = r;
            continue;
        }
    }
    return d;
}

//"--relp, --dosexe, --forisp, --disklet, --diskp, --sincp"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    auto lst = QStringList{};
    for(auto i = 1; i < argc; ++i){
        lst.push_back(argv[i]);
    }
    auto d = parse_or_exit(lst);

//    auto argv2 = QString("0 D:/SomePrograms/DosEngine/DOSBox/DOSBox.exe C:/Users/Dima/source/repos/IDE_FRL/ForisWrapper/for_dos D:/SomePrograms/DosEngine/foris D C:/Users/Dima/source/repos/IDE_FRL/ForisWrapper/for_dos/data").split(" ");

//    d.dos_exe_path = string(argv2[1].toStdString());
//    d.sinchro_path = string(argv2[2].toStdString());
//    d.foris_path =   string(argv2[3].toStdString());
//    d.disk_letter =  string(argv2[4].toStdString());
//    d.disk_path =    string(argv2[5].toStdString());

//    d.dos_exe_path = string(argv[1]);
//    d.sinchro_path = string(argv[2]);
//    d.foris_path =   string(argv[3]);
//    d.disk_letter =  string(argv[4]);
//    d.disk_path =    string(argv[5]);
    if(d.relative){
        auto path = (QCoreApplication::applicationDirPath() + "/").toStdString();
        d.disk_path = path + d.disk_path;
        d.sinchro_path = path + d.sinchro_path;
        d.foris_path = path + d.foris_path;
        d.dos_exe_path = path + d.dos_exe_path;
    }

    d.in_name = d.sinchro_path + "/sinchro/OUT.LSP";
    d.out_name = d.sinchro_path + "/sinchro/IN.LSP";

    d.in_acc_name = d.sinchro_path + "/sinchro/OACC.LSP";
    d.out_acc_name = d.sinchro_path + "/sinchro/INACC.LSP";


    exists_file_info_or_exit(d.dos_exe_path.c_str(), "dos file");
    exists_dir_info_or_exit(d.sinchro_path.c_str(), "sinchro path");
    exists_dir_info_or_exit(d.foris_path.c_str(), "foris path");
    exists_dir_info_or_exit(d.disk_path.c_str(), "disk path");

    if(!(d.disk_letter.size() == 1 && isalpha(d.disk_letter[0]))){
        cout << d.disk_letter << "(" << d.disk_letter.size() <<")" << " disk letter erorr" << endl;
        cout << "must be a-z or A-Z except c and C" << endl;
        exit(0);
    }
    if(d.disk_letter[0] == 'C'  || d.disk_letter[0] == 'c'){
        cout << "disk letter C not allowed"<< endl;
        cout << "must be a-z or A-Z except c and C" << endl;
        exit(0);
    }

    exists_file_info_or_exit((d.sinchro_path + "/template.conf").c_str(), "template conf");
    exists_file_info_or_exit((d.sinchro_path + "/driver.lsp").c_str(), "driver file");

    int cpu = -1;
//    {
//        auto s = istringstream(d.dos_cpu_cycles);
//        s >> cpu;
//        if(!(s && cpu > 0 && cpu <= 100)) cpu = -1;
//        else{
//            d.dos_cpu_cycles = "fixed " + d.dos_cpu_cycles;
//        }
//    }

    if(cpu == -1 && !(d.dos_cpu_cycles == "max" || d.dos_cpu_cycles == "auto")){
        cout << "dos cpu argument error: " << d.dos_cpu_cycles << endl;
        cout << "available: " /*number (1-100) or*/ "max or auto" << d.dos_cpu_cycles << endl;
        exit(0);
    }

    // Task parented to the application so that it
    // will be deleted by the application.
    auto task = DosWrapper(d);

    // This will cause the application to exit when
    // the task signals finished.
    QObject::connect(&task, &DosWrapper::finished, &a, &QCoreApplication::quit);

    // This will run the task from the application event loop.
    QTimer::singleShot(0, &task, &DosWrapper::run);

    try{
        auto result = a.exec();
        cout <<endl;
        cout << "----stopped----" <<endl;
        return result;
    }
    catch(std::exception& e){
        cout << "internal error " <<endl;
        cout << e.what() <<endl;
    }
    catch(const char* e){
        cout << "internal error " <<endl;
        cout << e <<endl;
    }
    catch(std::string& e){
        cout << "internal error " <<endl;
        cout << e <<endl;
    }
}
