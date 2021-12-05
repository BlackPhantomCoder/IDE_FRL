#include "MyQApp.h"
#include "SettringJson.h"
#include <memory>
#include <QFile>
#include <QApplication>
#include <QtDebug>
using namespace std;

bool restart_flag = false;
static auto settings = QSettings();

MyQApp::MyQApp(int &argc, char **argv, int f):QApplication(argc, argv, f)
{
}

MyQApp::~MyQApp()
{
    if(is_first_start())
        settings.setValue("first_start", false);
    if(restart_flag){
        QString program = qApp->arguments()[0];
        QStringList arguments = qApp->arguments().mid(1); // remove the 1st argument - the program name
        QProcess::startDetached(program, arguments);
    }
}

QString MyQApp::now_global_settings_path()
{
    return settings.value("path", default_global_settings_path()).toString();
}

bool MyQApp::set_new_global_settings_path(const QString &path, bool copy)
{
    if(copy){
        auto result = QFile::copy(now_global_settings_path(), path);
        if(!result) return false;
    }
    settings.setValue("path", path);
    return true;
}

QString MyQApp::default_global_settings_path()
{
    return   QApplication::applicationDirPath() + "/data/main_settings.json";
}

QSettings &MyQApp::global_settings()
{
    static auto settings = [](){
        auto result = make_unique<SettringJson>(now_global_settings_path());
        if(QFile::exists(now_global_settings_path()) && result->status() != SettringJson::NoError){
            if(!is_first_start())
                QMessageBox::warning(nullptr, tr("Внимание"),
                                                tr("Ошибка загрузки настроек приложения. Установлен путь по умолчанию."),
                                               QMessageBox::Ok);
            auto f = QFile(default_global_settings_path());
            f.open(QFile::WriteOnly);
            f.close();
            result = make_unique<SettringJson>(default_global_settings_path());
            set_new_global_settings_path(default_int_settings_path(), false);
        }
        return result;
    }();
    return *settings;
}

QString MyQApp::now_int_settings_path()
{
    return global_settings().value("intpath", default_int_settings_path()).toString();
}

bool MyQApp::set_new_int_settings_path(const QString &path, bool copy)
{
    if(now_int_settings_path() == path) return true;
    if(copy){
        if(QFile::exists(path)){
            if(!QFile::remove(path)) return false;
        }
        auto result = QFile::copy( now_int_settings_path(), path);
        if(!result) return false;
    }
    global_settings().setValue("intpath", path);
    return true;
}

QString MyQApp::default_int_settings_path()
{
    return QApplication::applicationDirPath() + "/data/interpretator.json";
}

InterpretatorsSettings &MyQApp::interpretator_settings()
{
    static auto settings = [](){
        auto result = make_unique<InterpretatorsSettings>(now_int_settings_path(), true);
        if(!result->is_loaded()){
            QMessageBox::warning(nullptr, tr("Внимание"),
                                            tr("Ошибка загрузки настроек интерпретатора. Установлен путь по умолчанию."),
                                           QMessageBox::Ok);
            InterpretatorsSettings::create_setting(default_int_settings_path());
            result = make_unique<InterpretatorsSettings>(default_int_settings_path(), true);
            set_new_int_settings_path(default_int_settings_path(), false);
        }
        return result;
    }();
    return *settings.get();
}

void MyQApp::restart()
{
//    QString program = qApp->arguments()[0];
//    QStringList arguments = qApp->arguments().mid(1); // remove the 1st argument - the program name
//    connect(qApp,&QCoreApplication::aboutToQuit, [program, arguments](){QProcess::startDetached(program, arguments);});
    restart_flag = true;
    qApp->quit();
}

bool MyQApp::is_first_start()
{
    return settings.value("first_start", true).toBool();
}
