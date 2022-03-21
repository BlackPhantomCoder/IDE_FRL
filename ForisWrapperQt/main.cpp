#include <QCoreApplication>

#include <QtCore>

#include "DosWrapper.h"

#include <iostream>
#include <cctype>
#include <sstream>
#include <vector>
#include <functional>
#include <set>
#include "StaticData.h"
using namespace std;
using StaticData::qout;


void exists_file_info_or_exit(const QString& file, const QString& name){
    if(!is_exist_file(file)){
        (*qout)  << name << ": " << file << " not exist" << endl;
        exit(0);
    }
}

void exists_dir_info_or_exit(const QString& dir, const QString& name){
    if(!is_exist_file(dir)){
        (*qout) << name << ": " << dir << " not exist" << endl;
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
            d.dos_exe_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") + params[0];
        },
        "задаёт путь к DosBOX"
    },
    {"--forisp", 1,
        [](dos_data& d, const QStringList& params) {
            d.wrap_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") +params[0];
            d.mulisp = false;
        },
        "задаёт путь к папке с FORIS"
    },
    {"--mulispp", 1,
        [](dos_data& d, const QStringList& params) {
            d.wrap_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") +params[0];
            d.mulisp = true;
        },
        "задаёт путь к папке с  MULISP"
    },
    {"--file", 1,
        [](dos_data& d, const QStringList& params) {
            d.wrap_name = params[0];
        },
        "задаёт имя файла FORIS/MULISP"
    },
    {"--diskmt", 1,
        [](dos_data& d, const QStringList& params) {
            d.disk_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") +params[0];
        },
        "задаёт диск, который будет добавлен в ретрансляцию путей в FORIS (под именем D)"
    },
    {"--sincp", 1,
        [](dos_data& d, const QStringList& params) {
            d.sinchro_path = ((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") +params[0];
        },
        "задаёт путь к папке синхронизации с драйвером и конфигурацией"
    },
    {"--doscpucycles", 1,
        [](dos_data& d, const QStringList& params) {
             d.dos_cpu_cycles =((d.relative) ? (QCoreApplication::applicationDirPath() + "/"): "") + params[0];
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
    },
    {"--display_dos", 0,
        [](dos_data& d, const QStringList& params) {
            d.display_dos = true;
        },
        "режим отображения окна доса"
    },
    {"--dos_noexit", 0,
        [](dos_data& d, const QStringList& params) {
            d.dos_exit = false;
        },
        "не выходить из доса после окончания работы"
    }
};

QStringList::iterator apply_or_exe(dos_data& d, QStringList::iterator it, QStringList::iterator end){
    auto i = find_if(begin(commands), std::end(commands), [it](const auto& cmd){return cmd.name == *it;});
    if(i == std::end(commands)){
        (*qout) << *it << QString()+" не команда" <<endl;
        (*qout) << QString()+"доступные команды:" << endl;
        for(const auto& command: commands){
            (*qout) << command.name<< endl;
        }
        (*qout) << QString()+"подробнее --help" << endl;
        exit(0);
    }
    if(distance(it + 1, end) < i->params_count) {
        (*qout) << *it << QString()+" недостаточно параметров" <<endl;
        (*qout) << QString()+"для " << *it << QString()+" требуется "<< i->params_count<< QString()+" параметров" <<endl;
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
//                "--relp --dosexe data/DOSBox/DOSBox.exe --sincp data/for_dos "
//                "--mulispp data/mulisp --file mulisp85 --absp --diskmt D:/repos/IDE_FRL/run/examples/project_example_1 "
//                "--doscpucycles max --debug --display_dos"
//    ).split(" ");



//    auto lst = QString(
//                "--relp --dosexe data/DOSBox/DOSBox.exe --sincp data/for_dos "
//                "--forisp data/foris --file foris --absp --diskmt D:/repos/IDE_FRL/run/examples/project_example_1"
//                " --doscpucycles max --debug --display_dos --dos_noexit"
//    ).split(" ");

    auto lst = QStringList{};
    for(auto i = 1; i < argc; ++i){
        lst.push_back(argv[i]);
    }
    auto d = parse_or_exit(lst);

    if(d.help){
        (*qout) << QString()+"доступные команды:" << endl;
        for(const auto& command: commands){
            (*qout) << QString()+"команда: " << command.name << endl;
            (*qout) << QString()+"описание: " << command.desctiption << endl;
        }
        return 0;
    }


    {

        auto extencion = "LSP";
        if(d.mulisp)
            extencion = "$SP";
        d.sinc_file = d.sinchro_path + "/sinchro/SINC." + extencion;
        d.sinc_print_file = d.sinchro_path + "/sinchro/SP." + extencion;
        d.sinc_read_file = d.sinchro_path + "/sinchro/SR."+ extencion;
    }



    exists_dir_info_or_exit(d.disk_path, "disk path");
    exists_file_info_or_exit(d.dos_exe_path, "dos file");
    exists_dir_info_or_exit(d.sinchro_path, "sinchro path");
    exists_dir_info_or_exit(d.wrap_path, "wrap path");
    exists_file_info_or_exit((d.sinchro_path + "/template.conf"), "template conf");
    exists_file_info_or_exit((d.sinchro_path + "/driver.lsp"), "driver file");

    int cpu = -1;
    {
        auto s = istringstream(d.dos_cpu_cycles.toStdString());
        s >> cpu;
        if(!(s && cpu >= 500 && cpu <= 10000)) cpu = -1;
        else{
            d.dos_cpu_cycles = "fixed " + d.dos_cpu_cycles;
        }
    }

    if(cpu == -1 && !(d.dos_cpu_cycles == "max" || d.dos_cpu_cycles == "auto")){
        (*qout) << "--doscpucycles error: " << d.dos_cpu_cycles << endl;
        (*qout) << QString()+"доступны: *number (500-10000) или max или auto" << d.dos_cpu_cycles << endl;
        exit(0);
    }

    if(d.debug){
        (*qout) << "relative:" << d.relative << endl;
        (*qout) << "dos_exe_path:" << d.dos_exe_path << endl;
        (*qout) << "sinchro_path:" << d.sinchro_path << endl;
        (*qout) << "wrap_path:" << d.wrap_path << endl;
        (*qout) << "wrap_name:" << d.wrap_name << endl;
        (*qout) << "disk_path:" << d.disk_path << endl;
        (*qout) << "sinc_file:" << d.sinc_file << endl;
        (*qout) << "sinc_print_file:" << d.sinc_print_file << endl;
        (*qout) << "sinc_read_file:" << d.sinc_read_file << endl;
        (*qout) << "dos_cpu_cycles:" << d.dos_cpu_cycles << endl;
        (*qout) << "mulisp:" << d.mulisp << endl;
        (*qout) << "display_dos:" << d.display_dos << endl;
        (*qout) << "dos_exit:" << d.dos_exit << endl;
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
        (*qout) <<endl;
        (*qout) << "----stopped----" <<endl;
        return result;
    }
    catch(std::exception& e){
        (*qout) << QString()+"внутренняя ошибка" <<endl;
        (*qout) << e.what() <<endl;
    }
    catch(const char* e){
        (*qout) << QString()+"внутренняя ошибка" <<endl;
        (*qout) << e <<endl;
    }
    catch(std::string& e){
        (*qout) << QString()+"внутренняя ошибка" <<endl;
        (*qout) << e.c_str() <<endl;
    }
}
