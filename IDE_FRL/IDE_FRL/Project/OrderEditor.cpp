#include "OrderEditor.h"
#include <algorithm>
using namespace std;

OrderEditor::OrderEditor(Project* project, QWidget *parent) :
    QDialog(parent),
    t_project(project)
{
    setupUi(this);

    t_elems = to_list(&project->tree());
    sort(t_elems.begin(), t_elems.end(), [](FileTreeItem *lh, FileTreeItem *rh){ return lh->order() < rh->order();});

    for(auto* node: t_elems){
        if(node->is_dir()) continue;
        data_w->addItem(path_by_node(node));
    }

    data_w->setAcceptDrops(true);
    data_w->setDragEnabled(true);
    data_w->setDragDropMode(QAbstractItemView::InternalMove);

    connect(up_btn, &QPushButton::clicked, this, &OrderEditor::t_up);
    connect(down_btn, &QPushButton::clicked, this, &OrderEditor::t_down);
    connect(buttonBox, &QDialogButtonBox::accepted, this, &OrderEditor::t_accept);
}

void OrderEditor::t_up()
{
    auto index = data_w->currentIndex();
    if(index.row() == 0) return;
    auto* prev = data_w->takeItem(index.row() - 1);
    data_w->insertItem(data_w->currentIndex().row() + 1, prev);
}

void OrderEditor::t_down()
{
    auto index = data_w->currentIndex();
    if(index.row() == data_w->count()) return;
    auto* next = data_w->takeItem(index.row() + 1);
    data_w->insertItem(data_w->currentIndex().row() - 1, next);
}

void OrderEditor::t_accept()
{
    QMap<QString, size_t> mp;
    auto count =  data_w->count();
    for(auto i = 0; i < count; ++i){
        mp[data_w->item(i)->text()] = i;
    }
    for(auto* node: t_elems){
        if(node->is_dir()) continue;
        t_project->set_order(node, mp[path_by_node(node)]);
    }
}
