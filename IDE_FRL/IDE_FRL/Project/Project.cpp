#include "Project.h"
#include <QDir>
#include <QCoreApplication>
#include <QApplication>
#include <QFile>

Project::Project(const QString &path):
    t_data(path),
    t_path(dir_by_path(path))
{
    t_root = new FileTreeItem("Project", false, false);
    t_interpretator_path = t_data.value("interpretator").toString();
    t_interpretator_params = t_data.value("interpretator params").toStringList();
    auto files = t_data.value("files").toStringList();
    auto empty_dirs = t_data.value("empty_dirs").toStringList();

    for(const auto& folder : empty_dirs){
        auto buf = QDir(t_path + "/" + folder);
        path_into_tree(t_root, folder, false, buf.exists());
    }

    for(const auto& file : files){
        auto buf = QFile(t_path + "/" + file);
        path_into_tree(t_root, file, true, buf.exists());
    }
}

Project::~Project()
{
    auto files_and_edirs = to_edirs_and_files(t_root);
    QStringList files;
    QStringList edirs;
    for(const auto& node: files_and_edirs){
        if(node->is_file())
            files.push_back(path_by_node(node));
        else
            edirs.push_back(path_by_node(node));
    }
    t_data.setValue("files", files);
    t_data.setValue("empty_dirs", edirs);
    t_data.setValue("interpretator", t_interpretator_path);
    t_data.setValue("interpretator params", t_interpretator_params);
    delete t_root;
}

void Project::add_dir(const QString &path)
{
    if(path.isEmpty()) throw "empty str";
    auto buf = QDir(t_path + "/" + path);
    path_into_tree(t_root, path, false, buf.exists());
}

void Project::add_file(const QString &path)
{
    if(path.isEmpty()) throw "empty str";
     auto buf = QFile(t_path + "/" + path);
    path_into_tree(t_root, path, true, buf.exists());
}

bool Project::rem_file(const QString &path)
{
    if(path.isEmpty()) throw "empty str";
    return rem_by_path(t_root, path, true);;
}

bool Project::rem_dir(const QString &path)
{
    if(path.isEmpty()) throw "empty str";
    return rem_by_path(t_root, path, false);;
}

FileTreeItem &Project::tree()
{
    return *t_root;
}

const QString &Project::path() const
{
    return t_path;
}

const QString &Project::interpretator_path()
{
    return t_interpretator_path;
}

const QStringList &Project::interpretator_params()
{
    return t_interpretator_params;
}

void Project::set_interpretator_path(const QString& path)
{
    t_interpretator_path = path;
}

void Project::set_interpretator_params(const QStringList &params)
{
    t_interpretator_params = params;
}
