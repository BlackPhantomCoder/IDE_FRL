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
    Project(QObject* parent = nullptr);
    Project(const QString& path, QObject* parent = nullptr);
    ~Project();

    bool is_loaded() const;
    bool is_changed() const;

    FileTreeItem& tree();

    const QString& project_name() const;
    const QString& dir_path() const;
    QString full_path() const;
    const QString& interpretator_name();

    bool rem_file_w_answer(const QString& path);
    bool rem_dir_w_answer(const QString& path);

signals:
    void changed();
    void tree_changed();
    void tree_added(const QString& path);
    void tree_removed(const QString& path);
    void interpretator_name_changed();
    void project_name_changed();

    void saved();

public slots:
    void set_project_name(const QString& name);

    //only relative paths
    void add_dir(const QString& path);
    void add_file(const QString& path);

    void rem_file(const QString& path);
    void rem_dir(const QString& path);

    void set_interpretator_name(const QString& name);

    //
    void set_order(FileTreeItem* node, size_t order);

    void save();

private:
    void t_init();

private:
    std::function<bool(const QString)> t_f_or_d_exist_f;
    bool t_loaded;
    bool t_changed = false;
    QString t_name;
    SettringJson* t_data;
    QString t_dir_path;
    QString t_filename;
    FileTreeItem* t_root;
    QString t_interpretator_name;
    size_t t_last_order;
};

#endif // PROJECT_H
