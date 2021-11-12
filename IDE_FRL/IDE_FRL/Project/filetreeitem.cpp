#include <QStringList>
#include <QStack>

#include "filetreeitem.h"
using namespace std;


FileTreeItem::FileTreeItem(const QString& name, bool file,  bool exists):
    t_file(file),
    t_exists(exists),
    t_name(name),
    m_parentItem(nullptr)
{

}

FileTreeItem::~FileTreeItem()
{
    qDeleteAll(m_childItems);
    if(m_parentItem){
        m_parentItem->m_childItems.removeAt(m_parentItem->m_childItems.indexOf(this));
    }
}

void FileTreeItem::appendChild(FileTreeItem *item)
{
    if(!is_dir()) throw "appending to file";
    if(item->is_dir()){
        auto it = begin(m_childItems);
        while(it != end(m_childItems) && (*it)->is_dir()){
            ++it;
        }
        m_childItems.insert(it, item);
    }
    else
        m_childItems.append(item);
    item->m_parentItem = this;
}

FileTreeItem *FileTreeItem::child(int row)
{
    return m_childItems.value(row);
}

int FileTreeItem::childCount() const
{
    return m_childItems.count();
}

int FileTreeItem::columnCount() const
{
    return 1;
}

QVariant FileTreeItem::data(int column) const
{
    if(column == 0) return t_name;
    throw "invalid index";
}

FileTreeItem *FileTreeItem::parentItem()
{
    return m_parentItem;
}

const QList<FileTreeItem *> &FileTreeItem::children() const
{
    return m_childItems;
}

void FileTreeItem::set_name(const QString &name)
{
    t_name = name;
}

bool FileTreeItem::is_file() const
{
    return  t_file;
}

bool FileTreeItem::is_dir() const
{
    return  !t_file;
}

bool FileTreeItem::exists() const
{
    return t_exists;
}

const QString &FileTreeItem::name() const
{
    return t_name;
}

int FileTreeItem::row() const
{
    if (m_parentItem)
        return m_parentItem->m_childItems.indexOf(const_cast<FileTreeItem*>(this));
    return 0;
}
#include <algorithm>
FileTreeItem* find_dir(FileTreeItem *where, const QString& name){
    if(where == nullptr) return nullptr;
    auto children = where->children();
    auto it = find_if(begin(children), end(children), [&name](FileTreeItem *rh){ return rh->is_dir() && rh->name() == name;});
    if(it == end(children)) return nullptr;
    else return *it;
}

FileTreeItem* find_file(FileTreeItem *where, const QString& name){
    if(where == nullptr) return nullptr;
    auto children = where->children();
    auto it = find_if(begin(children), end(children), [&name](FileTreeItem *rh){ return rh->is_file() && rh->name() == name;});
    if(it == end(children)) return nullptr;
    else return *it;
}

pair<FileTreeItem*, QStringList::const_iterator> find_by_path(FileTreeItem *root, QStringList::iterator b,  QStringList::iterator e, bool file){
    if(root == nullptr) return {nullptr, b};
    if(b == e) throw  "empty path";
    if(file){
        if(b == prev(e)){
            auto found_file = find_file(root, *b);
            return {found_file, (found_file != nullptr) ? e : b};
        }
        auto [found_dir, it] = find_by_path(root, b, prev(e), false);
        if(it == prev(e)){
            auto found_file = find_file(found_dir, *it);
            if(found_file != nullptr)
                return {found_file, e};
            else
                return {found_dir, it};
        }
        else
            return {found_dir, it};
    }
    auto* find_parent = root;
    FileTreeItem* found_child = nullptr;
    for(;;){
        found_child = find_dir(find_parent, *b);
        if(found_child == nullptr) return {find_parent, b};
        ++b;
        if(b == e) return {found_child, e};
        find_parent = found_child;
    }
    return {found_child, b};
}

bool path_into_tree(FileTreeItem *root, const QString &path, bool file, bool exists)
{
    if(root == nullptr) throw "root is empty";
    if(path.isEmpty()) return false;
    QStringList data = path.split('/');
    auto [found_child, it] = find_by_path(root, begin(data), end(data), file);
    if(it == end(data)) return false;

    if(found_child == nullptr){
        found_child = root;
    }
    while(it != prev(end(data))){
        auto* buf = new FileTreeItem(*it, false, exists);
        found_child->appendChild(buf);
        found_child = buf;
        ++it;
    }
    found_child->appendChild( new FileTreeItem(*it, file, exists));
    return true;
}

bool rem_by_path(FileTreeItem *root, const QString &path, bool file)
{
    if(root == nullptr) throw "root is empty";
    if(path.isEmpty()) return false;
    QStringList data = path.split('/');
    auto [found_child, it] = find_by_path(root, begin(data), end(data), file);
    if(it == end(data)){
        delete found_child;
        return true;
    }
    else{
        return false;
    }
}

QString dir_by_path(const QString &path)
{
    if(path.contains("/"))
        return path.mid(0, path.lastIndexOf("/"));
    else
        return {};
}

QList<FileTreeItem*> to_edirs_and_files(FileTreeItem *root)
{
    QList<FileTreeItem*>  result;
    QList<FileTreeItem*> data = {root};
    while(!data.isEmpty()){
        auto* node = data.first();
        data.pop_front();
        for(const auto& child : node->children()){
            if(child->is_dir()){
                if(child->childCount() == 0)
                    result.append(child);
                else
                    data.append(child);
            }
            else
                result.append(child);
        }
    }
    return result;
}

QString path_by_node(FileTreeItem *node)
{
    if(node->parentItem() == nullptr) return "";
    QString result;
    QStringList data;
    auto* parent = node->parentItem();
    while(parent->parentItem() != nullptr){
        data.append(parent->name());
        parent = parent->parentItem();
    }
    for(auto it = rbegin(data); it != rend(data); ++it){
        result += *it + "/";
    }
    return result + node->name();
}
