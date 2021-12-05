#include <QCoreApplication>

#include <QtCore>

#include "DosWrapper.h"

#include <iostream>
#include <cctype>
#include <sstream>
#include <vector>
#include <functional>
#include <set>
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

struct command{
    QString name;
    int params_count;
    function<void(dos_data&, const QStringList&)> init_fnc;
};

bool operator==(const command& lh, const command& rh){
    return lh.name == rh.name;
}

bool operator<(const command& lh, const command& rh){
    return lh.name < rh.name;
}

set<command> commands = {
    //добавляет к следующим командам с путём путь приложения
    {"--relp", 0, [](dos_data& d, const QStringList& params) {
         d.relative = true;
    }},
    //не добавляет к следующим командам с путём путь приложения
    {"--absp", 0, [](dos_data& d, const QStringList& params) {
         d.relative = false;
    }},
    //путь к досу
    {"--dosexe", 1, [](dos_data& d, const QStringList& params) {
         d.dos_exe_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") + params[0].toStdString();
    }},
    //путь к форису
    {"--forisp", 1, [](dos_data& d, const QStringList& params) {
         d.foris_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
    }},
    //монтирование диска с проектом (он будет добавлен в ретрансляцию путей)
    {"--diskmt", 1, [](dos_data& d, const QStringList& params) {
         d.disk_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
    }},
    //путь к папке синхронизации с драйвером и конфигурацией
    {"--sincp", 1, [](dos_data& d, const QStringList& params) {
         d.sinchro_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
    }},
    //настройка использования процессора досом
    {"--doscpucycles", 1, [](dos_data& d, const QStringList& params) {
         d.dos_cpu_cycles =((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") + params[0].toStdString();
    }}
};

QStringList::iterator apply_or_exe(dos_data& d, QStringList::iterator it, QStringList::iterator end){
    auto i = find_if(begin(commands), std::end(commands), [it](const auto& cmd){return cmd.name == *it;});
    if(i == std::end(commands)){
        cout << (*it).toStdString() << " is not a command" <<endl;
        cout << "allowed commands are:" << endl;
        for(const auto& command: commands){
            cout << command.name.toStdString() << endl;
        }
        exit(0);
    }
    if(distance(it + 1, end) < i->params_count) {
        cout << (*it).toStdString() << " not enougth params" <<endl;
        cout << "for " << it->toStdString() << " required "<< i->params_count<< " params" <<endl;
        exit(0);
    }
    auto result = QStringList{};
    if(i->params_count)
        copy((it + 1), it + 1 + i->params_count, back_inserter(result));
    i->init_fnc(d, result);
    return it + 1+ i->params_count;
}

dos_data parse_or_exit(QStringList commands){
    dos_data d{};
    auto it = commands.begin();
    while(it != end(commands)){
        if(it->isEmpty()) {++it; continue;}
        it = apply_or_exe(d, it, end(commands));
    }
    return d;
}


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
//    auto lst = QString(
//                " --relp"
//                " --dosexe data/DOSBox/DOSBox.exe"
//                " --sincp data/for_dos"
//                " --forisp data/foris"
//                " --diskmt data/for_dos/data"
//                " --doscpucycles 4500"
//               ).split(" ");

    auto lst = QStringList{};
    for(auto i = 1; i < argc; ++i){
        lst.push_back(argv[i]);
    }
    auto d = parse_or_exit(lst);


    d.sinc_file = d.sinchro_path + "/sinchro/SINC.LSP";
    d.sinc_print_file = d.sinchro_path + "/sinchro/SP.LSP";
    d.sinc_read_file = d.sinchro_path + "/sinchro/SR.LSP";


    exists_dir_info_or_exit(d.disk_path.c_str(), "disk path");
    exists_file_info_or_exit(d.dos_exe_path.c_str(), "dos file");
    exists_dir_info_or_exit(d.sinchro_path.c_str(), "sinchro path");
    exists_dir_info_or_exit(d.foris_path.c_str(), "foris path");
    exists_file_info_or_exit((d.sinchro_path + "/template.conf").c_str(), "template conf");
    exists_file_info_or_exit((d.sinchro_path + "/driver.lsp").c_str(), "driver file");

    int cpu = -1;
    {
        auto s = istringstream(d.dos_cpu_cycles);
        s >> cpu;
        if(!(s && cpu >= 500 && cpu <= 10000)) cpu = -1;
        else{
            d.dos_cpu_cycles = "fixed " + d.dos_cpu_cycles;
        }
    }

    if(cpu == -1 && !(d.dos_cpu_cycles == "max" || d.dos_cpu_cycles == "auto")){
        cout << "dos cpu argument error: " << d.dos_cpu_cycles << endl;
        cout << "available: *number (500-10000) or max or auto" << d.dos_cpu_cycles << endl;
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
