#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>

#include "Project.h"
class FileTreeItem;

//Модель проекта
class ProjectModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    enum data_role : int{
        is_file = Qt::ItemDataRole::UserRole + 1,
        is_root,
        is_exits,
        path
    };
public:
    explicit ProjectModel(Project& project,  QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    void add(const QModelIndex& ind, const QString& name, bool file);
    bool rem(const QModelIndex& ind);

private:
    bool t_is_file(const QModelIndex &index) const;
    bool t_is_root(const QModelIndex &index) const;
    bool t_is_exists(const QModelIndex &index) const;

    QString t_get_path(const QModelIndex &index) const;
private:
    Project* t_project;
};

//! [0]


#endif // TREEMODEL_H
