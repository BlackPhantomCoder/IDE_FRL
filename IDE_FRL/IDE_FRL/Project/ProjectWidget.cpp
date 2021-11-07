#include "ProjectWidget.h"
#include <QTreeView>
#include <QFileSystemModel>
#include <QSortFilterProxyModel>
#include <QDebug>
#include <QMenu>
#include <QFile>
#include <QInputDialog>
#include <QLineEdit>
#include <QMessageBox>
#include <QFileDialog>

#include "treemodel.h"
#include "filetreeitem.h"

ProjectWidget::ProjectWidget(Project& project, QWidget *parent) :
    QWidget(parent),
    t_project(&project)
{
    setupUi(this);
    treeView = new DeselectableTreeView(this);
    horizontalLayout->addWidget(treeView);

    t_model = new ProjectModel(*t_project, this);
    treeView->setModel(t_model);

    treeView->setContextMenuPolicy(Qt::CustomContextMenu);
    connect(treeView, SIGNAL(customContextMenuRequested(const QPoint &)), this, SLOT(onCustomContextMenu(const QPoint &)));
}


void ProjectWidget::onCustomContextMenu(const QPoint &point)
{
    auto index = treeView->currentIndex();
    auto* menu = (QMenu*)nullptr;
    if (index.isValid())
        menu =  t_context_by_index(index);
    else
        menu = t_root_context_menu();
    menu->popup(treeView->viewport()->mapToGlobal(point));
}

void ProjectWidget::create_and_add_file(const QModelIndex &ind)
{
    bool ok;
    auto text = QInputDialog::getText(this, tr("Введите имя файла"),
                                         tr("Имя файла:"), QLineEdit::Normal,
                                         "", &ok);
    if (ok && !text.isEmpty()){

        auto path = (!(t_model->is_root(ind)) ? t_model->get_path(ind) + "/" : "") + text;
        {
            QFile file(t_project->path() + "/" + path);
            if(file.exists()){
                QMessageBox::warning(this, tr("Внимание"),
                                               tr("Файл уже существует"),
                                              QMessageBox::Ok);
                return;
            }
            auto result = file.open(QIODevice::WriteOnly);
            file.close();
            if(!result){
                QMessageBox::warning(this, tr("Внимание"),
                                               tr("Ошибка создания файла"),
                                              QMessageBox::Ok);
                return;
            }
        }
        t_model->add(ind, text, true);
    }
}

void ProjectWidget::create_and_add_dir(const QModelIndex &ind)
{
    bool ok;
    auto text = QInputDialog::getText(this, tr("Введите имя директории"),
                                         tr("Имя директории:"), QLineEdit::Normal,
                                         "", &ok);
    if (ok && !text.isEmpty()){
        auto path = (!(t_model->is_root(ind)) ? t_model->get_path(ind) + "/" : "") + text;
        {
            QDir dir(t_project->path());
            auto result = dir.mkpath(path);
            if(!result){
                QMessageBox::warning(this, tr("Внимание"),
                                               tr("Ошибка создания папки"),
                                              QMessageBox::Ok);
                return;
            }
        }
        t_model->add(ind, text, false);
    }
}

void ProjectWidget::add_exist_file(const QModelIndex &ind)
{
    auto file_name = QFileDialog::getOpenFileName(this,
        tr("Выберете файл"), t_project->path());
    if(file_name.isEmpty()) return;
    auto ppath = t_project->path();
    if(ppath.size() > file_name.size() || ppath != file_name.midRef(0, ppath.size())){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Ошибка добавления файла\nФайл должен находится в папке проекта!"),
                                      QMessageBox::Ok);
    }
    else{
        auto rel_name = file_name.mid(ppath.size(), file_name.size());
        if(rel_name[0] == "/") rel_name.remove(0, 1);
        t_model->add(ind, rel_name, true);
    }
}

void ProjectWidget::add_exist_dir(const QModelIndex &ind)
{
    auto dir_name = QFileDialog::getExistingDirectory(this,
        tr("Выберете папку"), t_project->path());
    if(dir_name.isEmpty()) return;
    auto ppath = t_project->path();
    if(ppath.size() > dir_name.size() || ppath != dir_name.midRef(0, ppath.size())){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Ошибка добавления папки\nПапка должена находится в папке проекта!"),
                                      QMessageBox::Ok);
    }
    else{
        auto rel_name = dir_name.mid(ppath.size(), dir_name.size());
        if(rel_name[0] == "/") rel_name.remove(0, 1);
        t_model->add(ind, rel_name, false);
    }
}

void ProjectWidget::remove_file(const QModelIndex& ind)
{
    auto path = t_project->path() + "/" + t_model->get_path(ind);
    QFile file(path);
    if(!file.exists()){
        auto ans = QMessageBox::warning(this, tr("Внимание"),
                                        tr("Файла уже не существует.\nУдалить из проекта?"),
                                       QMessageBox::Cancel|QMessageBox::Ok);
        if(ans == QMessageBox::Cancel)
            return;
    }
    else if(!file.remove()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Ошибка удаления файла"),
                                      QMessageBox::Ok);
        return;
    }
    exclude_file(ind);
}

void ProjectWidget::remove_dir(const QModelIndex &ind)
{
    auto path = t_project->path() + "/" + t_model->get_path(ind);
    QDir dir(path);
    if(!dir.exists()){
        auto ans = QMessageBox::warning(this, tr("Внимание"),
                                        tr("Папки уже не существует.\nУдалить из проекта?"),
                                       QMessageBox::Cancel|QMessageBox::Ok);
        if(ans == QMessageBox::Cancel)
            return;
    }
    else if(!dir.removeRecursively()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Ошибка удаления папки"),
                                      QMessageBox::Ok);
        return;
    }
    exclude_dir(ind);
}

void ProjectWidget::exclude_file(const QModelIndex &ind)
{
    t_model->rem(ind);
}

void ProjectWidget::exclude_dir(const QModelIndex &ind)
{
    t_model->rem(ind);
}

QMenu *ProjectWidget::t_context_by_index(const QModelIndex &index)
{
    auto* menu = new QMenu(this);
    if(t_model->is_file(index)){
        if(t_model->is_exists(index)){
            t_add_btn(menu, "Удалить файл", [this, index](){remove_file(index);});
        }
        else{
            t_add_btn(menu, "Исключить файл", [this, index](){exclude_file(index);});
        }
    }
    else{
        if(t_model->is_exists(index)){
            t_add_btn(menu, "Добавить папку",[this, index](){create_and_add_dir(index);});
            t_add_btn(menu, "Добавить файл",[this, index](){create_and_add_file(index);});
            t_add_btn(menu, "Удалить папку",[this, index](){remove_dir(index);});
        }
        else{
            t_add_btn(menu, "Иксключить папку",[this, index](){exclude_dir(index);});
        }
    }
    return menu;
}

QMenu *ProjectWidget::t_root_context_menu()
{
    auto * menu = new QMenu(this);

    t_add_btn(menu, "Добавить существующую папку",[this, index = QModelIndex()](){add_exist_dir(index);});
    t_add_btn(menu, "Добавить существующий файл",[this, index = QModelIndex()](){add_exist_file(index);});
    t_add_btn(menu, "Добавить папку",[this, index = QModelIndex()](){create_and_add_dir(index);});
    t_add_btn(menu, "Добавить файл",[this, index = QModelIndex()](){create_and_add_file(index);});

    return menu;
}

void DeselectableTreeView::mousePressEvent(QMouseEvent *event)

{
    QModelIndex item = indexAt(event->pos());

   if (item.isValid())
   {
       QTreeView::mousePressEvent(event);
   }
   else
   {
       clearSelection();
       const QModelIndex index;
       selectionModel()->setCurrentIndex(index, QItemSelectionModel::Select);
   }
}

template<class Fnc>
void ProjectWidget::t_add_btn(QMenu *menu, const QString& text, Fnc f)
{
    auto * device = new QAction(text, menu);
    connect(device, &QAction::triggered, f);
    menu->addAction(device);
}
