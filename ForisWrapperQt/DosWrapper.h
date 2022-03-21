#ifndef DOSWRAPPER_H
#define DOSWRAPPER_H


#include <QtCore>
#include <QThread>
#include <functional>
#include "ConsoleReader.h"
#include "LineReader.h"

//данные
struct dos_data{
    //флаг относительности пути
    bool relative = false;
    //флаг для отладки
    bool debug = false;
    //флаг для --help
    bool help = false;
    //путь к досу
    QString dos_exe_path;
    //путь к папки синхронизации
    QString sinchro_path;
    //путь к интерпретатору
    QString wrap_path;
    //имя файла интерпретатора
    QString wrap_name;
    //std::vector<std::pair<QChar, std::string>> disks;
    //транслируемый путь
    QString disk_path;
    //путь к файлу синхронизации общий
    QString sinc_file;
    //путь к файлу синхронизации (печать)
    QString sinc_print_file;
    //путь к файлу синхронизации (чтение)
    QString sinc_read_file;
    //режим процессора для DosBOX (см DosBOX config)
    QString dos_cpu_cycles = "max";
    //режим интерпретатора (foris/mulisp)
    bool mulisp = false;
    //режим отображения окна доса
    bool display_dos = false;
    //режим выхода из доса после окончания работы
    bool dos_exit = true;
};

bool is_exist_file(const QString& path);
bool is_exist_dir(const QString& path);

//класс, запускающий Foris в Dosbox и общающийся с ним через файлы синхронизации (через driver.lsp)
class DosWrapper : public QObject
{
    Q_OBJECT

    enum class state {input, output};
public:
    DosWrapper(dos_data data, QObject *parent = 0);
    ~DosWrapper();
signals:
    void finished();

public slots:
    void run();
    void finish();

private slots:
    void dir_changed(const QString& path);
    void step(state s);

    void send_to_dos();

private:
    void t_create_conf();

private:
    dos_data t_data;
    QProcess* t_process;
    QFileSystemWatcher* t_watcher;
    ConsoleReader t_io;
    LineReader t_reader;
};


#endif // DOSWRAPPER_H
