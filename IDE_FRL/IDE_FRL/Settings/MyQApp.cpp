#include "MyQApp.h"
#include "SettringJson.h"
#include <memory>
#include <QFile>
#include <QApplication>
#include <QtDebug>
using namespace std;

static auto settings = QSettings();

MyQApp::MyQApp(int &argc, char **argv, int f):QApplication(argc, argv, f)
{

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
        if(result->status() != SettringJson::NoError){
            result = make_unique<SettringJson>(default_global_settings_path());
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
    if(copy){
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
            InterpretatorsSettings::create_setting(default_int_settings_path());
            result = make_unique<InterpretatorsSettings>(default_int_settings_path(), true);
        }
        return result;
    }();
    return *settings.get();
}

void MyQApp::restart()
{
    QString program = qApp->arguments()[0];
    QStringList arguments = qApp->arguments().mid(1); // remove the 1st argument - the program name
    qApp->quit();
    QProcess::startDetached(program, arguments);
}
