#include <QCoreApplication>

#include <QtCore>

#include "DosWrapper.h"

#include <iostream>
#include <cctype>
using namespace std;


void exists_file_info_or_exit(const QString& file, const QString& name){
    if(!is_exist_file(file)){
        cout << name.toStdString() << " not exist" << endl;
        exit(0);
    }
}

void exists_dir_info_or_exit(const QString& dir, const QString& name){
    if(!is_exist_file(dir)){
        cout << name.toStdString() << " not exist" << endl;
        exit(0);
    }
}

QSet<QString> commands = {"--relp", "--dosexe", "--forisp", "--disklet", "--diskp", "--sincp"};

std::string get_or_exe(QStringList::iterator it, QStringList::iterator end){
    if(!commands.contains(*it)){
        cout << (*it).toStdString() << " is not a command" <<endl;
        exit(0);
    }
    if(it + 1 == end) {
        cout << (*it).toStdString() << " not enoth params" <<endl;
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
        exit(0);
    }
    if(d.disk_letter[0] == 'C'  || d.disk_letter[0] == 'c'){
        cout << "letter C not allowed"<< endl;
        exit(0);
    }

    exists_file_info_or_exit((d.sinchro_path + "/template.conf").c_str(), "template conf");
    exists_file_info_or_exit((d.sinchro_path + "/driver.lsp").c_str(), "driver file");

    // Task parented to the application so that it
    // will be deleted by the application.
    auto task = DosWrapper(d);

    // This will cause the application to exit when
    // the task signals finished.
    QObject::connect(&task, &DosWrapper::finished, &a, &QCoreApplication::quit);

    // This will run the task from the application event loop.
    QTimer::singleShot(0, &task, &DosWrapper::run);

    return a.exec();
}
