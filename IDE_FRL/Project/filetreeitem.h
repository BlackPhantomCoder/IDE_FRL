#ifndef TREEITEM_H
#define TREEITEM_H

#include <QList>
#include <QVariant>

//Дерево файлов и папок для проекта
class FileTreeItem
{
public:
    explicit FileTreeItem(const QString& name, bool file, bool exists, size_t order);
    ~FileTreeItem();

    //*this must be dir
    void appendChild(FileTreeItem *child);

    FileTreeItem *child(int row);
    int childCount() const;
    int columnCount() const;
    QVariant data(int column) const;
    int row() const;
    FileTreeItem *parentItem();


    const QList<FileTreeItem*>& children() const;

    bool is_file()const;
    bool is_dir()const;

    bool exists()const;

    void set_name(const QString& name);
    void set_order(size_t ord);
    const QString& name() const;
    size_t order() const;
private:
    QList<FileTreeItem*> m_childItems;
    bool t_file;
    bool t_exists;
    QString t_name;
    FileTreeItem *m_parentItem;
    size_t t_order;
};


QList<FileTreeItem*> to_list(FileTreeItem* node, bool root = true);

bool path_into_tree(FileTreeItem* root, const QString& path, bool file, size_t order, const std::function<bool(const QString&)>& is_exist_f);
bool rem_by_path(FileTreeItem* root, const QString& path, bool file);

//<Name, is_file>
QList<FileTreeItem*> to_edirs_and_files(FileTreeItem* root);

QString path_by_node(FileTreeItem* node);

QString dir_by_path(const QString& path);

#endif // TREEITEM_H
