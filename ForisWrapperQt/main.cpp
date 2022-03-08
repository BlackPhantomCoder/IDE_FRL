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

//структура для флагов
struct command{
    //имя флага
    QString name;
    //количество параметров
    unsigned params_count;
    //функция, вызываемая при нахождении флага
    function<void(dos_data&, const QStringList&)> init_fnc;
    //описание флага (выводится при --help)
    QString desctiption = "нет описания";
};

bool operator==(const command& lh, const command& rh){
    return lh.name == rh.name;
}

bool operator<(const command& lh, const command& rh){
    return lh.name < rh.name;
}

//команды
set<command> commands = {
    {"--relp", 0,
        [](dos_data& d, const QStringList& params) {
             d.relative = true;
        },
        "добавляет вначале к следующим командам, в которых есть путь, путь приложения"
    },
    {"--absp", 0,
        [](dos_data& d, const QStringList& params) {
             d.relative = false;
        },
        "отменяет --relp"
    },
    {"--dosexe", 1,
        [](dos_data& d, const QStringList& params) {
            d.dos_exe_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") + params[0].toStdString();
        },
        "задаёт путь к DosBOX"
    },
    {"--forisp", 1,
        [](dos_data& d, const QStringList& params) {
            d.foris_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
        },
        "задаёт путь к данным FORIS"
    },
    {"--diskmt", 1,
        [](dos_data& d, const QStringList& params) {
            d.disk_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
        },
        "задаёт диск, который будет добавлен в ретрансляцию путей в FORIS (под именем D)"
    },
    {"--sincp", 1,
        [](dos_data& d, const QStringList& params) {
            d.sinchro_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") +params[0].toStdString();
        },
        "задаёт путь к папке синхронизации с драйвером и конфигурацией"
    },
    {"--doscpucycles", 1,
        [](dos_data& d, const QStringList& params) {
             d.dos_cpu_cycles =((d.relative) ? (QCoreApplication::applicationDirPath() + "/").toStdString(): "") + params[0].toStdString();
        },
        "настройка использования процессора досом (доступные варианты число (500-10000) или max или auto) подробнее см в конфигурации DosBOX"
    },
    {"--debug", 0,
        [](dos_data& d, const QStringList& params) {
            d.debug = true;
        },
        "влючает подробный вывод действий"
    },
    {"--help", 0,
        [](dos_data& d, const QStringList& params) {
            d.help = true;
        },
        "просмотр доступных команд с выводом их описания"
    }
};

QStringList::iterator apply_or_exe(dos_data& d, QStringList::iterator it, QStringList::iterator end){
    auto i = find_if(begin(commands), std::end(commands), [it](const auto& cmd){return cmd.name == *it;});
    if(i == std::end(commands)){
        cout << (*it).toStdString() << " не команда" <<endl;
        cout << "доступные команды:" << endl;
        for(const auto& command: commands){
            cout << command.name.toStdString() << endl;
        }
        cout << "подробнее --help" << endl;
        exit(0);
    }
    if(distance(it + 1, end) < i->params_count) {
        cout << (*it).toStdString() << " недостаточно параметров" <<endl;
        cout << "для " << it->toStdString() << " требуется "<< i->params_count<< " параметров" <<endl;
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

//    auto lst = QString(
//                "--relp --dosexe data/DOSBox/DOSBox.exe --sincp data/for_dos "
//                "--forisp data/foris --absp --diskmt D:/repos/IDE_FRL/run/examples/project_example_1 --doscpucycles max --debug"
//    ).split(" ");

    auto lst = QStringList{};
    for(auto i = 1; i < argc; ++i){
        lst.push_back(argv[i]);
    }
    auto d = parse_or_exit(lst);

    if(d.help){
        cout << "доступные команды:" << endl;
        for(const auto& command: commands){
            cout << "команда: " << command.name.toStdString() << endl;
            cout << "описание: " << command.desctiption.toStdString() << endl;
        }
        return 0;
    }


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
        cout << "--doscpucycles error: " << d.dos_cpu_cycles << endl;
        cout << "доступны: *number (500-10000) или max или auto" << d.dos_cpu_cycles << endl;
        exit(0);
    }

    if(d.debug){
        cout << "relative:" << d.relative << endl;
        cout << "dos_exe_path:" << d.dos_exe_path << endl;
        cout << "sinchro_path:" << d.sinchro_path << endl;
        cout << "foris_path:" << d.foris_path << endl;
        cout << "disk_path:" << d.disk_path << endl;
        cout << "sinc_file:" << d.sinc_file << endl;
        cout << "sinc_print_file:" << d.sinc_print_file << endl;
        cout << "sinc_read_file:" << d.sinc_read_file << endl;
        cout << "dos_cpu_cycles:" << d.dos_cpu_cycles << endl;
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
        cout << "внутренняя ошибка" <<endl;
        cout << e.what() <<endl;
    }
    catch(const char* e){
        cout << "внутренняя ошибка" <<endl;
        cout << e <<endl;
    }
    catch(std::string& e){
        cout << "внутренняя ошибка" <<endl;
        cout << e <<endl;
    }
}
