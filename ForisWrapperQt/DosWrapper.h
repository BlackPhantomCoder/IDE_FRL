#ifndef DOSWRAPPER_H
#define DOSWRAPPER_H


#include <QtCore>
#include <functional>

//данные
struct dos_data{
    //флаг относительности пути
    bool relative = false;
    //флаг для отладки
    bool debug = false;
    //флаг для --help
    bool help = false;
    //путь к досу
    std::string dos_exe_path;
    //путь к папки синхронизации
    std::string sinchro_path;
    //путь к форису
    std::string foris_path;
    //std::vector<std::pair<QChar, std::string>> disks;
    //транслируемый путь
    std::string disk_path;
    //путь к файлу синхронизации общий
    std::string sinc_file;
    //путь к файлу синхронизации (печать)
    std::string sinc_print_file;
    //путь к файлу синхронизации (чтение)
    std::string sinc_read_file;
    //режим процессора для DosBOX (см DosBOX config)
    std::string dos_cpu_cycles = "max";

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

private:
    void t_create_conf();

private:
    dos_data t_data;
    QProcess* t_process;
    QFileSystemWatcher* t_watcher;
};


#endif // DOSWRAPPER_H
