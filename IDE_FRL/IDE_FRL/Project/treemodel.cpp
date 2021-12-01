#include "filetreeitem.h"
#include "treemodel.h"

#include <QStringList>
#include <QFont>
using namespace std;

ProjectModel::ProjectModel(Project& project, QObject *parent)
    : QAbstractItemModel(parent)
{
    t_project = &project;
}

int ProjectModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return static_cast<FileTreeItem*>(parent.internalPointer())->columnCount();
    else
        return t_project->tree().columnCount();
}

void ProjectModel::add(const QModelIndex &ind, const QString &name, bool file)
{
    bool root = t_is_root(ind);
    auto path = (!root ? t_get_path(ind) + "/" :"") + name;
    auto parent = (!root ? ind.parent() : ind);
    beginInsertRows(parent, rowCount(parent), rowCount(parent));
    if(file){
        t_project->add_file(path);
    }
    else
        t_project->add_dir(path);
    endInsertRows();
}

bool ProjectModel::rem(const QModelIndex &ind)
{
    if(!ind.isValid())
        return false;
    auto parent = ind.parent();
    beginRemoveRows(parent, ind.row(), ind.row());
    auto* item = static_cast<FileTreeItem*>(ind.internalPointer());
    auto result = true;
    if(item->is_file())
        result = t_project->rem_file_w_answer(t_get_path(ind));
    else
        result = t_project->rem_dir_w_answer(t_get_path(ind));
    endRemoveRows();
    return result;
}

bool ProjectModel::t_is_file(const QModelIndex &index) const
{
    return data(index, data_role::is_file).toBool();
}

bool ProjectModel::t_is_root(const QModelIndex &index) const
{
    return data(index, data_role::is_root).toBool();
}

bool ProjectModel::t_is_exists(const QModelIndex &index) const
{
    return data(index, data_role::is_exits).toBool();
}

QString ProjectModel::t_get_path(const QModelIndex &index) const
{
    return data(index, data_role::path).toString();
}

QVariant ProjectModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()){
        if(role == data_role::is_root)
            return true;
//        if(role == data_role::is_file)
//            return false;

        return QVariant();
    }


    auto *item = static_cast<FileTreeItem*>(index.internalPointer());
    switch (role) {
        case Qt::DisplayRole:
            return item->data(index.column());
        case Qt::ForegroundRole:
            if(!item->exists())
                return QColor(Qt::gray);
            break;
        case Qt::FontRole:
            if(item->is_dir()){
                auto font = QFont();
                font.setBold(true);
                return font;
            }
            break;
        case data_role::is_exits:
            return item->exists();
        case data_role::is_file:
            return item->is_file();
        case data_role::is_root:
            return item == &t_project->tree();
        case data_role::path:
            return path_by_node(item);

        default:
            break;
    }
    return QVariant();
}

Qt::ItemFlags ProjectModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return 0;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QVariant ProjectModel::headerData(int section, Qt::Orientation orientation,
                               int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole)
        return t_project->tree().data(section);

    return QVariant();
}

QModelIndex ProjectModel::index(int row, int column, const QModelIndex &parent)
            const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();

    FileTreeItem *parentItem;

    if (!parent.isValid())
        parentItem = &t_project->tree();
    else
        parentItem = static_cast<FileTreeItem*>(parent.internalPointer());

    auto *childItem = parentItem->child(row);
    if (childItem)
        return createIndex(row, column, childItem);
    else
        return QModelIndex();
}

QModelIndex ProjectModel::parent(const QModelIndex &index) const
{
    if (!index.isValid())
        return QModelIndex();

    auto *childItem = static_cast<FileTreeItem*>(index.internalPointer());
    auto *parentItem = childItem->parentItem();

    if (parentItem == &t_project->tree())
        return QModelIndex();

    return createIndex(parentItem->row(), 0, parentItem);
}

int ProjectModel::rowCount(const QModelIndex &parent) const
{
    FileTreeItem *parentItem;
    if (parent.column() > 0)
        return 0;

    if (!parent.isValid())
        parentItem = &t_project->tree();
    else
        parentItem = static_cast<FileTreeItem*>(parent.internalPointer());

    return parentItem->childCount();
}
