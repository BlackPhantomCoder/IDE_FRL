#include "Project.h"
#include <QDir>
#include <QCoreApplication>
#include <QApplication>
#include <QFile>

Project::Project(const QString &path, QObject *parent):
    QObject(parent),
    t_data(new SettringJson(path, this)),
    t_path(dir_by_path(path))
{
    if(t_data->status() == QSettings::NoError)
        t_init();
    else
        t_loaded = false;

    connect(this, &Project::tree_added, this, &Project::tree_changed);
    connect(this, &Project::tree_removed, this, &Project::tree_changed);
    connect(this, &Project::tree_changed, this, &Project::changed);

    connect(this, &Project::interpretator_name_changed, this, &Project::changed);
    connect(this, &Project::project_name_changed, this, &Project::tree_changed);
}

Project::~Project()
{
    delete t_root;
    t_root = nullptr;
}

Project::Project(QObject *parent):
    QObject(parent)
{
    t_loaded = false;
}

bool Project::is_loaded() const
{
    return t_loaded;
}

bool Project::is_changed() const
{
    return t_changed;
}

void Project::add_dir(const QString &path)
{
    if(!is_loaded()) throw "project not loaded";
    if(path.isEmpty()) throw "empty str";
    auto buf = QDir(t_path + "/" + path);
    if(path_into_tree(t_root, path, false, buf.exists())){
        t_changed = true;
        emit tree_added(path);
    }
}

void Project::add_file(const QString &path)
{
    if(!is_loaded()) throw "project not loaded";
    if(path.isEmpty()) throw "empty str";
     auto buf = QFile(t_path + "/" + path);
    if(path_into_tree(t_root, path, true, buf.exists())){
        t_changed = true;
        emit tree_added(path);
    }
}

void Project::rem_file(const QString &path)
{
   rem_file_w_answer(path);
}

void Project::rem_dir(const QString &path)
{
    rem_dir_w_answer(path);
}

FileTreeItem &Project::tree()
{
    if(!is_loaded()) throw "project not loaded";
    return *t_root;
}

const QString &Project::project_name() const
{
    return t_name;
}

const QString &Project::path() const
{
    return t_path;
}

const QString &Project::interpretator_name()
{
    if(!is_loaded()) throw "project not loaded";
    return t_interpretator_name;
}

bool Project::rem_file_w_answer(const QString &path)
{
    if(!is_loaded()) throw "project not loaded";
    if(path.isEmpty()) throw "empty str";
    if(rem_by_path(t_root, path, true)){
        t_changed = true;
        emit tree_removed(path);
        return true;
    }
    return false;
}

bool Project::rem_dir_w_answer(const QString &path)
{
    if(!is_loaded()) throw "project not loaded";
    if(path.isEmpty()) throw "empty str";
    if(rem_by_path(t_root, path, false)){
        t_changed = true;
        emit tree_removed(path);
        return true;
    }
    return false;
}

void Project::set_project_name(const QString &name)
{
    t_changed = true;
    t_name = name;
    t_root->set_name(name);
    emit project_name_changed();
}

void Project::set_interpretator_name(const QString& name)
{
    if(!is_loaded()) throw "project not loaded";
    if(t_interpretator_name != name){
        t_interpretator_name = name;
        t_changed = true;
        emit interpretator_name_changed();
    }
}

void Project::save()
{
    if(!is_loaded()) throw "project not loaded";
    if(is_changed()){
        t_data->setValue("name", t_name);
        auto files_and_edirs = to_edirs_and_files(t_root);
        QStringList files;
        QStringList edirs;
        for(const auto& node: files_and_edirs){
            if(node->is_file())
                files.push_back(path_by_node(node));
            else
                edirs.push_back(path_by_node(node));
        }
        t_data->setValue("files", files);
        t_data->setValue("empty_dirs", edirs);
        t_data->setValue("interpretator", t_interpretator_name);
        t_changed = false;
        emit saved();
    }
}

void Project::t_init()
{
    t_name = t_data->value("name").toString();
    t_root = new FileTreeItem(t_name, false, false);
    t_interpretator_name = t_data->value("interpretator").toString();
    auto files = t_data->value("files").toStringList();
    auto empty_dirs = t_data->value("empty_dirs").toStringList();

    for(const auto& folder : empty_dirs){
        auto buf = QDir(t_path + "/" + folder);
        path_into_tree(t_root, folder, false, buf.exists());
    }

    for(const auto& file : files){
        auto buf = QFile(t_path + "/" + file);
        path_into_tree(t_root, file, true, buf.exists());
    }
}
