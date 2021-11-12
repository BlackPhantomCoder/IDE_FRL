#include "GlobalSettings.h"
#include "SettringJson.h"
#include <memory>
#include <QFile>
#include <QApplication>
using namespace std;

QSettings &global_settings()
{
    static auto settings = SettringJson(QApplication::applicationDirPath() + "/main_settings.json");
    return settings;
}

InterpretatorsSettings &interpretator_settings()
{
    static auto settings = [](){
        auto result = make_unique<InterpretatorsSettings>(QApplication::applicationDirPath() + "/interpretator.json", true);
        if(!result->is_loaded()){
            InterpretatorsSettings::create_setting(QApplication::applicationDirPath() + "/interpretator.json");
            result = make_unique<InterpretatorsSettings>(QApplication::applicationDirPath() + "/interpretator.json", true);
        }
        return result;
    }();
    return *settings.get();
}
