#include "SettringJson.h"

#include <QApplication>
#include <QtDebug>
#include <QJsonDocument>

const QSettings::Format SettringJson::json_format = QSettings::registerFormat("json", readJsonFile, writeJsonFile);

SettringJson::SettringJson(const QString &organization, const QString &application, QObject *parent)
:
 QSettings(json_format, QSettings::UserScope, organization, application,
   parent)
{
}

SettringJson::SettringJson(QSettings::Scope scope, const QString &organization, const QString &application, QObject *parent)
:
 QSettings(json_format, scope, organization, application, parent)
{
}

SettringJson::SettringJson(const QString &fileName, QObject *parent)
:
 QSettings(fileName, json_format, parent)
{
}


SettringJson::SettringJson(QObject *parent)
:
 QSettings(json_format, QSettings::UserScope,
   QCoreApplication::organizationName(),
   QCoreApplication::applicationName(), parent)
{
}

void processReadKey(QString& key, QSettings::SettingsMap &map, const QVariant& element)
{
    switch (element.type())
    {
    case QVariant::Map:
    {
        auto vMap = element.toMap();
        auto end = vMap.constEnd();

        for (auto it = vMap.constBegin(); it != end; ++it)
        {
            key.append(it.key());
            key.append("/");
            processReadKey(key, map, it.value());
        }

        break;
    }
    case QVariant::List:
    {
        //auto list = element.toList();
        map.insert(key.left(key.size() - 1), element);
//        map.insert(key + "size", list.count());
//        for (auto i = 0; i < list.count(); ++i)
//        {
//            key.append(QString::number(i + 1));
//            key.append("/");
//            processReadKey(key, map, list.at(i));
//        }
        break;
    }
    default:
        map.insert(key.left(key.size() - 1), element);
    }
    key.truncate(key.lastIndexOf("/", -2) + 1);
}

QVariant processWriteKey(QVariant& root, const QString& key, const QVariant& value)
{
    auto slashPos = key.indexOf('/');

    // If it is key
    if (slashPos < 0)
    {
        auto map = root.toMap();
        /** TODO VERY UGLY array detecting method
         * Key size always placed after all numeric keys (array indexes)
         * Convert root map to list and return it.
         * Warning. Index starts with 1
         */
//        if (key == "size")
//        {
//            auto list = QVariantList();
//            for (int i = 1; i <= value.toInt(); ++i)
//                list.append(map.value(QString::number(i)));
//            return list;
//        }
//        else
//        {
            map.insert(key, value);
            return map;
        //}
    }

    // get group name
    auto groupName = key.left(slashPos);

    // if name is number then it's row of array, convert to list
    auto map = root.toMap();
    auto item = map.value(groupName);
    map.insert(groupName, processWriteKey(item, key.mid(slashPos + 1), value));
    return map;
}

bool SettringJson::readJsonFile(QIODevice &device, QSettings::SettingsMap &map)
{
    auto error = QJsonParseError();
    auto document = QJsonDocument::fromJson(device.readAll(), &error);

    if (error.error == QJsonParseError::NoError)
    {
        if (!document.isEmpty()){
            auto str = QString();
            processReadKey(str, map, document.toVariant());
        }
    }
    else
        qWarning() << error.errorString();

    return true;
}

bool SettringJson::writeJsonFile(QIODevice &device, const QSettings::SettingsMap &map)
{
    auto result = QVariant();
    auto end = map.constEnd();

    for (auto it = map.constBegin(); it != end; ++it)
        result = processWriteKey(result, it.key(), it.value());

    device.write(QJsonDocument::fromVariant(result).toJson());
    return true;
}

