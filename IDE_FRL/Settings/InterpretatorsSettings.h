#ifndef INTERPRETATORSSETTINGS_H
#define INTERPRETATORSSETTINGS_H

#include "Settings/SettringJson.h"
#include "Interpretator/Interpretator.h"

#include <QtCore>
#include <QtWidgets>

//Настройки интерпретаторов
class InterpretatorsSettings: public QObject
{
    Q_OBJECT
public:
    static bool create_setting(const QString& path);
public:
    InterpretatorsSettings(const QString& path, bool destruct_saved, QObject* parent = nullptr);
    ~InterpretatorsSettings();

    bool add_interpretator(const QString& name, const InterpretatorData& data);
    bool change_interpretator(const QString& name, const InterpretatorData& data);
    bool delete_interpretator(const QString& name);

    bool contains_interpretator(const QString& name) const;
    const InterpretatorData& get_interpretator(const QString& name);

    int count() const;

    QStringList all_names() const;


    bool is_loaded()const;
    bool is_saved()const;


    bool is_destruct_saved()const;

signals:
    void changed();
    void interpretators_changed();

    void saved();

public slots:
    void save();
    void set_destruct_save(bool mode);

private:
    bool t_loaded;
    bool t_saved;
    bool t_autosave = false;
    SettringJson t_data;
    QMap<QString, InterpretatorData> t_all;
};

#endif // INTERPRETATORSSETTINGS_H
