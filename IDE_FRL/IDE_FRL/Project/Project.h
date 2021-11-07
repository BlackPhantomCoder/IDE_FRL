#ifndef PROJECT_H
#define PROJECT_H

#include "Settings/SettringJson.h"
#include <QObject>
#include <variant>
#include <QString>
#include <QList>
#include <QFileSystemModel>

#include "filetreeitem.h"

class Project: public QObject
{
    Q_OBJECT
public:
    Project(const QString& path);
    ~Project();

    //only ralative paths
    void add_dir(const QString& path);
    void add_file(const QString& path);

    bool rem_file(const QString& path);
    bool rem_dir(const QString& path);

    FileTreeItem& tree();

    const QString& path() const;
    const QString& interpretator_path();
    const QStringList& interpretator_params();

    void set_interpretator_path(const QString& path);
    void set_interpretator_params(const QStringList& params);
private:
    SettringJson t_data;
    QString t_path;
    FileTreeItem* t_root;
    QString t_interpretator_path;
    QStringList t_interpretator_params;
};

#endif // PROJECT_H
