#ifndef MYQAPP_H
#define MYQAPP_H

#include <QtCore>
#include <QtWidgets>
#include "InterpretatorsSettings.h"

//Класс приложения с полезными функциями
class MyQApp : public QApplication
{
public:
    MyQApp(int &argc, char **argv, int = ApplicationFlags);
    ~MyQApp();

    static QString now_global_settings_path();
    static bool set_new_global_settings_path(const QString& path, bool copy);
    static QString default_global_settings_path();

    static QSettings& global_settings();

    static QString now_int_settings_path();
    static bool set_new_int_settings_path(const QString& path, bool copy);
    static QString default_int_settings_path();


    static InterpretatorsSettings& interpretator_settings();

    static void restart();

    static bool is_first_start();

};



struct AtGroupper{
    AtGroupper(QSettings& s, const QString& name) : s(s){
        s.beginGroup(name);
    }
    ~AtGroupper(){
        s.endGroup();
    }
    QSettings& s;
};

#define MY_UNIQ_ID_IMPL(lineno) _a_local_var_##lineno
#define MY_UNIQ_ID(lineno) MY_UNIQ_ID_IMPL(lineno)


#define AT_GROUP(s, g) AtGroupper MY_UNIQ_ID(__LINE__)(s, g);


class restart_later : public QObject{
    Q_OBJECT
public:
    restart_later() : QObject(nullptr){};
    ~restart_later(){
        MyQApp::restart();
    }

};

#endif // MYQAPP_H
