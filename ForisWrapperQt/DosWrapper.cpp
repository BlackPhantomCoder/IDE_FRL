#include "DosWrapper.h"

#include <iostream>
#include <string>
#include <algorithm>
#include <set>
#include <io.h>
#include <fcntl.h>
#include <vector>
#include <string_view>
#include <fstream>
#include <sstream>

#include <thread>
#include <chrono>

using namespace std;


bool is_exist_file(const QString& path){
    return QFile::exists(path);
}

bool is_exist_dir(const QString& path){
    auto f = QDir(path);
    return f.exists();
}

void file_del(const string_view& filename) {
    auto file = QFile(filename.data());
    if(file.exists()){
        if(!file.remove()){
            int tryes = 0;
            while(tryes != 100){
                if(file.remove()) return;
                ++tryes;
                std::this_thread::sleep_for(std::chrono::milliseconds(50));
            }
            throw "internal error: delete file error";
        }
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

DosWrapper::DosWrapper(dos_data data, QObject *parent)
    :
       QObject(parent),
       t_data{data}
{
    t_create_conf();
}

DosWrapper::~DosWrapper()
{
   finish();
}

void DosWrapper::run()
{
    // Do processing here
    t_process = new QProcess(this);
    connect(t_process, static_cast<void(QProcess::*)(int)>(&QProcess::finished), this, &DosWrapper::finished);
    //connect(t_process, &QProcess::errorOccurred, this, &DosWrapper::finished);

    file_del(t_data.in_acc_name);
    file_del(t_data.out_acc_name);
    file_del(t_data.out_name);
    file_del(t_data.in_name);

    t_watcher = new QFileSystemWatcher(this);
    bool beingWatched = t_watcher->addPath(QString::fromStdString(t_data.sinchro_path + "/sinchro"));
    if (!beingWatched ) {
        qDebug() << "internal error: watcher error";
        emit finished();
        return;
    }
    connect(t_watcher, &QFileSystemWatcher::directoryChanged, this, &DosWrapper::dir_changed);

    QStringList commands;

    auto str = QString()
            +  t_data.dos_exe_path.c_str()
            + " -conf "
            +  t_data.sinchro_path.c_str()
            + "/sinchro/conf.conf -noconsole"
            + "\n";

    auto env = QProcessEnvironment::systemEnvironment();
    env.insert("SDL_VIDEODRIVER", "dummy"); // Add an environment variable
    t_process->setProcessEnvironment(env);
    t_process->setNativeArguments(str);
    t_process->start(t_data.dos_exe_path.c_str());

    if( !t_process->waitForStarted(3000)) {
        delete t_watcher;
        t_watcher = nullptr;
        emit finished();
    }
    cout << "ForisWrapper 0.19 (c)" << endl;
}

void DosWrapper::finish()
{
    if(t_process && (t_process->state() == QProcess::Running)){
        t_process->terminate();
        t_process->waitForFinished(1000);
        if(t_process->state() == QProcess::Running)t_process->kill();
        t_process->waitForFinished(100);
    }
}

void DosWrapper::dir_changed(const QString &path)
{
    if(path != (t_data.sinchro_path+"/sinchro").c_str()) return;

    {
        auto file = QFile(t_data.in_acc_name.c_str());
        if(file.exists()){
             step(state::output);
             return;
        }
    }
    {
        auto file = QFile(t_data.out_acc_name.c_str());
        if(file.exists()){
             step(state::input);
             return;
        }
    }
}

void DosWrapper::step(DosWrapper::state s)
{
    if(!cin || !cout) {
        emit finished();
        return;
    }
    if (s == state::input) {
        while(true){
            if(!cin) break;
            cout << "> " << std::flush;
            string s;
            getline(cin, s);
            if (empty(s)){
                QCoreApplication::processEvents();
                if(!cin) {
                    emit finished();
                    return;
                }
                continue;
            }
            send(s + "\n\n", t_data.out_name, t_data.out_acc_name);
            break;
        }
        if(!cin || !cout) {
            emit finished();
        }
    }
    else {
        cout << get(t_data.in_name, t_data.in_acc_name) << std::flush;
    }
}

void DosWrapper::t_create_conf()
{
    QFile::remove((t_data.sinchro_path + "/sinchro/conf.conf").c_str());
    if(!is_exist_dir((t_data.sinchro_path + "/sinchro").c_str())){
        auto d = QDir(t_data.sinchro_path.c_str());
        if(!d.mkdir("sinchro")){
            cout << t_data.sinchro_path << "/sinchro creating error" <<endl;
            emit finished();
            return;
        }
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    QFile::copy((t_data.sinchro_path + "/template.conf").c_str(),(t_data.sinchro_path + "/sinchro/conf.conf").c_str());
    auto conf = ofstream(t_data.sinchro_path + "/sinchro/conf.conf", std::ios::app);

    conf << "cycles=" << t_data.dos_cpu_cycles << endl;
    conf << endl;
    conf << "[autoexec]" << endl;
    conf << endl;
    conf << "MOUNT " << t_data.disk_letter << ": " << t_data.disk_path << endl;
    conf << t_data.disk_letter << ":" << endl;
    conf << "MOUNT F: " << t_data.sinchro_path << endl;
    conf << "MOUNT S: " << t_data.sinchro_path +"/sinchro" << endl;
    conf << "MOUNT X: " << t_data.foris_path << endl;
    conf << "x:\\fsmem - > nul" << endl;
    conf << "x:\\foris f:\\driver.lsp +Q" << endl;
    conf << "x:\\fsfree" << endl;
    conf << "exit" << endl;
}
