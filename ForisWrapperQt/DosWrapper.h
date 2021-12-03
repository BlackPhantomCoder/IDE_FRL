#ifndef DOSWRAPPER_H
#define DOSWRAPPER_H


#include <QtCore>
#include <functional>

struct dos_data{
    bool relative = false;

    std::string dos_exe_path;
    std::string sinchro_path;
    std::string foris_path;
    std::string disk_letter;
    std::string disk_path;
    std::string in_name;
    std::string out_name;
    std::string in_acc_name;
    std::string out_acc_name;

    std::string dos_cpu_cycles = "max";

};

bool is_exist_file(const QString& path);
bool is_exist_dir(const QString& path);

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
