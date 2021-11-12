#include "InterpretatorsSettings.h"

#include <algorithm>
using namespace std;

bool InterpretatorsSettings::create_setting(const QString &path)
{
    SettringJson t_data;
    t_data.setPath(SettringJson::json_format, QSettings::UserScope, path);
    return t_data.status() == SettringJson::NoError;
}

InterpretatorsSettings::InterpretatorsSettings(const QString &path, bool destruct_saved, QObject *parent):
    QObject(parent),
    t_saved(true),
    t_autosave(destruct_saved),
    t_data(path)

{
    t_loaded = t_data.status() == QSettings::NoError;
    if(t_loaded){
        t_data.beginGroup("interpretators");

        auto groups = t_data.childGroups();
        for(const auto& name : t_data.childGroups()){
            t_data.beginGroup(name);
            auto intrepretator = InterpretatorData{};

            intrepretator.params = t_data.value("params", "").toString();
            intrepretator.path = t_data.value("path", "").toString();

            t_all.insert(name, intrepretator);
            t_data.endGroup();
        }

        t_data.endGroup();


        connect(this, &InterpretatorsSettings::interpretators_changed, this, &InterpretatorsSettings::changed);
    }
}

InterpretatorsSettings::~InterpretatorsSettings()
{
    if(is_destruct_saved()){
        save();
    }
}

bool InterpretatorsSettings::add_interpretator(const QString &name, const InterpretatorData &data)
{
    if(!is_loaded()) throw "not loaded";
    if(t_all.find(name) != end(t_all)) return false;
    t_all.insert(name, data);
    t_saved = false;
    emit interpretators_changed();
    return true;
}

bool InterpretatorsSettings::change_interpretator(const QString &name, const InterpretatorData &data)
{
    if(!is_loaded()) throw "not loaded";
     if(auto it = t_all.find(name); it == end(t_all)) return false;
     else{
         t_saved = false;
         *it = data;
         emit interpretators_changed();
     }
     return true;
}

bool InterpretatorsSettings::contains_interpretator(const QString &name) const
{
    if(!is_loaded()) throw "not loaded";
    if(auto it = t_all.find(name); it == end(t_all)) return false;
    else{
        return true;
    }
}

const InterpretatorData &InterpretatorsSettings::get_interpretator(const QString &name)
{
    if(!is_loaded()) throw "not loaded";
    if(auto it = t_all.find(name); it == end(t_all)) throw "invalid index";
    else{
        return *it;
    }
}

int InterpretatorsSettings::count() const
{
    return t_all.count();
}

QStringList InterpretatorsSettings::all_names() const
{
    return t_all.keys();
}

bool InterpretatorsSettings::is_loaded() const
{
    return t_loaded;
}

bool InterpretatorsSettings::is_saved() const
{
    return t_saved;
}

bool InterpretatorsSettings::is_destruct_saved() const
{
    return t_autosave;
}

void InterpretatorsSettings::save()
{
    if(!is_saved() && is_loaded()){
        t_data.clear();
        t_data.beginGroup("interpretators");

        for(const auto& name :t_all.keys()){
            t_data.beginGroup(name);
            t_data.setValue("params", t_all[name].params);
            t_data.setValue("path", t_all[name].path);
            t_data.endGroup();
        }

        t_data.endGroup();

    }
}

void InterpretatorsSettings::set_destruct_save(bool mode)
{
    t_autosave = mode;
}
