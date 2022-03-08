#ifndef SETTRINGJSON_H
#define SETTRINGJSON_H

#include <QString>
#include <QSettings>

//реализация QSettings c хранением в JSON
class SettringJson: public QSettings
{
    Q_OBJECT
public:
    static const QSettings::Format json_format;
public:
    SettringJson(const QString &organization, const QString &application, QObject *parent = nullptr);
    SettringJson(Scope scope, const QString &organization, const QString &application = QString(), QObject *parent = nullptr);
    SettringJson(const QString &fileName, QObject *parent = nullptr);
    SettringJson(QObject * parent = nullptr);
private:
    static bool readJsonFile(QIODevice &device, QSettings::SettingsMap &map);
    static bool writeJsonFile(QIODevice &device, const QSettings::SettingsMap &map);
};
#endif // SETTRINGJSON_H
