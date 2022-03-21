#include "DosWrapper.h"

#include "StaticData.h"
#include <string>
#include <algorithm>
#include <set>
#include <io.h>
#include <fcntl.h>
#include <vector>
#include <string_view>
#include <fstream>
#include <sstream>

#include <chrono>
using namespace std;
using StaticData::qout;


bool is_exist_file(const QString& path){
    return QFile::exists(path);
}

bool is_exist_dir(const QString& path){
    auto f = QDir(path);
    return f.exists();
}

void file_del(const QString& filename) {
    auto file = QFile(filename);
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

void write(const QString& filename, const QString& str) {
    auto result = QString();
    auto file = QFile(filename);
    file.open(QFile::WriteOnly);

    {
        QTextStream out(&file);
        out << str;
    }

    file.close();
//    auto out = ofstream(filename.toStdString());
//    out << str.toStdString();
}

QString read(const QString& filename) {
//    auto result = QString();
//    auto file = QFile(filename);
//    file.open(QFile::ReadOnly);
//    auto data = file.readAll();
//    result = QString::fromLocal8Bit(data);
//    result.remove(result.size() - 1, 1);
//    file.close();
//    return result;
    string result;
    auto in = ifstream(filename.toStdString());
    auto ch = in.get();
    while (in) {
        result += ch;
        ch = in.get();
    }
    return QString::fromLocal8Bit(result.c_str());
}


QString get(const QString& in_name, const QString& in_acc_name) {
    auto result = read(in_name);
    file_del(in_acc_name);
    return result;
}


void send(const QString& str, const QString& out_name, const QString& out_acc_name) {
    write(out_name, str);
    file_del(out_acc_name);
}

DosWrapper::DosWrapper(dos_data data, QObject *parent)
    :
       QObject(parent),
       t_data{data}
{
    t_create_conf();
    connect(&t_io, &ConsoleReader::received_line, &t_reader, &LineReader::append_line);
    connect(&t_io, &ConsoleReader::finished, this, &DosWrapper::finish);
}

DosWrapper::~DosWrapper()
{
   finish();
}

void DosWrapper::run()
{
    // Do processing here
    t_process = new QProcess(this);
    connect(t_process, static_cast<void(QProcess::*)(int)>(&QProcess::finished), this, &DosWrapper::finish);
    //connect(t_process, &QProcess::errorOccurred, this, &DosWrapper::finished);

    file_del(t_data.sinc_file);
    file_del(t_data.sinc_print_file);
    file_del(t_data.sinc_read_file);

    t_watcher = new QFileSystemWatcher(this);
    bool beingWatched = t_watcher->addPath(t_data.sinchro_path + "/sinchro");
    if (!beingWatched ) {
        qDebug() << "internal error: watcher error";
        emit finished();
        return;
    }
    connect(t_watcher, &QFileSystemWatcher::directoryChanged, this, &DosWrapper::dir_changed);

    QStringList commands;

    auto str = QString()
            +  t_data.dos_exe_path
            + " -conf "
            +  t_data.sinchro_path
            + "/sinchro/conf.conf -noconsole"
            + "\n";

    auto env = QProcessEnvironment::systemEnvironment();
    if(!t_data.display_dos)
        env.insert("SDL_VIDEODRIVER", "dummy"); // Add an environment variable
    t_process->setProcessEnvironment(env);
    t_process->setNativeArguments(str);
    t_process->start(t_data.dos_exe_path);

    if( !t_process->waitForStarted(3000)) {
        delete t_watcher;
        t_watcher = nullptr;
        emit finished();
    }
    (*qout) << StaticData::program_name << " " << StaticData::version_number << " (c)" << endl;
    if(t_data.mulisp)
        (*qout) << "muLisp mode" << endl;
}

void DosWrapper::finish()
{
    if(!t_io.is_finished()){
        t_io.finish();
    }
    if(t_process && (t_process->state() == QProcess::Running)){
        t_process->terminate();
        t_process->waitForFinished(1000);
        if(t_process->state() == QProcess::Running)t_process->kill();
        t_process->waitForFinished(100);
    }
    emit finished();
}

void DosWrapper::dir_changed(const QString &path)
{
    if(path != (t_data.sinchro_path+"/sinchro")) return;

    {
        auto file = QFile(t_data.sinc_print_file);
        if(file.exists()){
             step(state::output);
             return;
        }
    }
    {
        auto file = QFile(t_data.sinc_read_file);
        if(file.exists()){
             step(state::input);
             return;
        }
    }
}

void DosWrapper::step(DosWrapper::state s)
{
    if (s == state::input) {
        send_to_dos();
    }
    else {
        (*qout) << get(t_data.sinc_file, t_data.sinc_print_file);
        (*qout) << flush;
    }
}

void DosWrapper::send_to_dos()
{
    if(t_reader.is_empty()){
        connect(&t_reader, &LineReader::appended, this, &DosWrapper::send_to_dos);
    }
    else{
        send(t_reader.read_line() + "\n", t_data.sinc_file, t_data.sinc_read_file);
        disconnect(&t_reader, &LineReader::appended, this, &DosWrapper::send_to_dos);
    }
}

void DosWrapper::t_create_conf()
{
    QFile::remove((t_data.sinchro_path + "/sinchro/conf.conf"));
    if(!is_exist_dir((t_data.sinchro_path + "/sinchro"))){
        auto d = QDir(t_data.sinchro_path);
        if(!d.mkdir("sinchro")){
            (*qout) << t_data.sinchro_path << "/sinchro creating error" << endl;
            emit finished();
            return;
        }
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    QFile::copy((t_data.sinchro_path + "/template.conf"),(t_data.sinchro_path + "/sinchro/conf.conf"));

    {
        auto config = ofstream((t_data.sinchro_path + "/c.lsp").toStdString());
        config << ("(**add_translate_disk** '|" +t_data.disk_path +"| 'D:)").toStdString() << endl;

        config << "(**top-level**)" <<endl;
    }


    auto conf = ofstream((t_data.sinchro_path + "/sinchro/conf.conf").toStdString(), std::ios::app);

    conf << "cycles=" << t_data.dos_cpu_cycles.toStdString() << endl;
    conf << endl;
    conf << "[autoexec]" << endl;
    conf << endl;


    conf << "MOUNT D: " << t_data.disk_path.toStdString() << endl;
    conf << "MOUNT F: " << t_data.sinchro_path.toStdString() << endl;
    conf << "MOUNT S: " << t_data.sinchro_path.toStdString() << "\\sinchro" << endl;
    conf << "MOUNT X: " << t_data.wrap_path.toStdString() << endl;

    if(t_data.mulisp)
        conf << "X:\\" << t_data.wrap_name.toStdString() <<  " F:driver.lsp +Q" << endl;
    else{
        conf << "X:\\fsmem - > nul" << endl;
        conf << "X:\\" << t_data.wrap_name.toStdString() << " F:driver.lsp +Q" << endl;
        conf << "x:\\fsfree" << endl;
    }
    if(t_data.dos_exit)
        conf << "exit" << endl;
}
