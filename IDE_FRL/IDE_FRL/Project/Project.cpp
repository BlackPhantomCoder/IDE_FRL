#include "Project.h"
#include <QDir>
#include <QCoreApplication>
#include <QApplication>
#include <QFile>
#include <QDebug>
#include <algorithm>

using namespace std;

Project::Project(const QString &path, QObject *parent):
    QObject(parent),
    t_data(new SettringJson(path, this)),
    t_dir_path(dir_by_path(path)),
    t_filename(path)
{
    t_filename.remove(t_dir_path + "/");
    if(QFile(path).exists() && t_data->status() == QSettings::NoError)
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
    if(t_loaded){
        delete t_root;
        t_root = nullptr;
    }
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
    if(path_into_tree(t_root, path, false, 0, t_f_or_d_exist_f)){
        t_changed = true;
        emit tree_added(path);
    }
}

void Project::add_file(const QString &path)
{
    if(!is_loaded()) throw "project not loaded";
    if(path.isEmpty()) throw "empty str";
    if(path_into_tree(t_root, path, true, ++t_last_order, t_f_or_d_exist_f)){
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

const QString &Project::dir_path() const
{
    return t_dir_path;
}

QString Project::full_path() const
{
    return t_dir_path + "/" + t_filename;
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
    if(name == t_name) return;
    t_changed = true;
    t_name = name;
    t_root->set_name(name);
    emit project_name_changed();
}

void Project::set_interpretator_name(const QString& name)
{
    if(!is_loaded()) throw "project not loaded";
    if(t_interpretator_name == name) return;
    t_interpretator_name = name;
    t_changed = true;
    emit interpretator_name_changed();
}

void Project::set_order(FileTreeItem *node, size_t order)
{
    if(node->is_dir()) return;
    if(node->order() == order)return;
    node->set_order(order);
    t_changed = true;
    emit tree_changed();
}

void Project::save()
{
    if(!is_loaded()) throw "project not loaded";
    if(is_changed()){
        t_data->setValue("name", t_name);
        auto files_and_edirs = to_edirs_and_files(t_root);
        QStringList files;
        QStringList edirs;

        auto elems = to_list(t_root);
        sort(elems.begin(), elems.end(), [](FileTreeItem *lh, FileTreeItem *rh){ return lh->order() < rh->order();});

        for(const auto& node: elems){
            if(node->is_file()){
                files.push_back(path_by_node(node));
            }
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
    t_f_or_d_exist_f = [this](const QString& lpath){
        auto bufd = QDir(t_dir_path + "/" + lpath);
        auto buff = QFile(t_dir_path + "/" + lpath);
        return  bufd.exists() || buff.exists();
    };

    t_name = t_data->value("name", QString{}).toString();
    t_root = new FileTreeItem(t_name, false, false, 0);
    t_interpretator_name = t_data->value("interpretator", QString{}).toString();
    auto files = t_data->value("files", QStringList{}).toStringList();
    auto empty_dirs = t_data->value("empty_dirs", QStringList{}).toStringList();
    t_last_order = 0;

    //qDebug() <<"max_found" <<endl;

    //qDebug() <<"folders" <<endl;
    for(const auto& folder : empty_dirs){
        path_into_tree(t_root, folder, false, 0, t_f_or_d_exist_f);
    }

    //qDebug() <<"files" <<endl;
    for(const auto& file : files){
        path_into_tree(t_root, file, true, ++t_last_order, t_f_or_d_exist_f);
    }
    //qDebug() <<"loaded" <<endl;
}
