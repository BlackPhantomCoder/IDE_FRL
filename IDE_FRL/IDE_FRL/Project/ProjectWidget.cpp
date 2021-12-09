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

ProjectWidget::ProjectWidget(QWidget *parent) :
    QWidget(parent),
    t_project(nullptr)
{
    setupUi(this);

}

QString ProjectWidget::path_at(const QModelIndex &index) const
{
    return t_model->data(index, ProjectModel::data_role::path).toString();
}

bool ProjectWidget::is_file_at(const QModelIndex &index) const
{
    return t_model->data(index, ProjectModel::data_role::is_file).toBool();
}

bool ProjectWidget::exists_at(const QModelIndex &index) const
{
    return t_model->data(index, ProjectModel::data_role::is_exits).toBool();
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

void ProjectWidget::send_file(const QModelIndex &ind)
{
    auto path = t_project->dir_path() + "/" + path_at(ind);
    QFile file(path);
    if(!file.exists()){
        auto ans = QMessageBox::warning(this, tr("Внимание"),
                                        tr("Файла уже не существует.\nУдалить из проекта?"),
                                       QMessageBox::Cancel|QMessageBox::Ok);
        if(ans == QMessageBox::Ok)
            exclude_file(ind);
        return;
    }
    emit send_file_request(path);
}

void ProjectWidget::create_and_add_file(const QModelIndex &ind)
{
    bool ok;
    auto text = QInputDialog::getText(this, tr("Введите имя файла"),
                                         tr("Имя файла:"), QLineEdit::Normal,
                                         "", &ok);
    if (ok && !text.isEmpty()){

        auto path = (!(t_is_root_at(ind)) ? path_at(ind) + "/" : "") + text;
        {
            QFile file(t_project->dir_path() + "/" + path);
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
        emit created_and_added_file(ind);
    }
}

void ProjectWidget::create_and_add_dir(const QModelIndex &ind)
{
    bool ok;
    auto text = QInputDialog::getText(this, tr("Введите имя директории"),
                                         tr("Имя директории:"), QLineEdit::Normal,
                                         "", &ok);
    if (ok && !text.isEmpty()){
        auto path = (!(t_is_root_at(ind)) ? path_at(ind) + "/" : "") + text;
        {
            QDir dir(t_project->dir_path());
            auto result = dir.mkpath(path);
            if(!result){
                QMessageBox::warning(this, tr("Внимание"),
                                               tr("Ошибка создания папки"),
                                              QMessageBox::Ok);
                return;
            }
        }
        t_model->add(ind, text, false);
        emit created_and_added_dir(ind);
    }
}

void ProjectWidget::add_exist_file(const QModelIndex &ind)
{
    auto file_name = QFileDialog::getOpenFileName(this,
        tr("Выберите файл"), t_project->dir_path());
    if(file_name.isEmpty()) return;
    auto ppath = t_project->dir_path();
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
        tr("Выберите папку"), t_project->dir_path());
    if(dir_name.isEmpty()) return;
    auto ppath = t_project->dir_path();
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
    auto path = t_project->dir_path() + "/" + path_at(ind);
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
    auto path = t_project->dir_path() + "/" + path_at(ind);
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

void ProjectWidget::set_project(Project *project)
{
    if(t_project){
        delete treeView;
        treeView = nullptr;
        delete t_model;
        t_model = nullptr;
    }
    t_project = project;
    t_init_project();
    emit project_changed();
}

void ProjectWidget::t_element_pressed(const QModelIndex &ind)
{
    if(is_file_at(ind))
        emit clicked_file(ind);
    else
        emit clicked_dir(ind);
}

void ProjectWidget::t_element_double_clicked(const QModelIndex &ind)
{
    if(is_file_at(ind))
        emit double_clicked_file(ind);
    else
        emit double_clicked_dir(ind);
}

QMenu *ProjectWidget::t_context_by_index(const QModelIndex &index)
{
    auto* menu = new QMenu(this);
    if(is_file_at(index)){
        if(exists_at(index)){
            t_add_btn(menu, "Отправить файл в интерпретатор", [this, index](){send_file(index);});
            t_add_btn(menu, "Удалить файл", [this, index](){remove_file(index);});
            t_add_btn(menu, "Исключить файл", [this, index](){exclude_file(index);});
        }
        else{
            t_add_btn(menu, "Исключить файл", [this, index](){exclude_file(index);});
        }
    }
    else{
        if(exists_at(index)){
            t_add_btn(menu, "Добавить папку",[this, index](){create_and_add_dir(index);});
            t_add_btn(menu, "Добавить файл",[this, index](){create_and_add_file(index);});
            t_add_btn(menu, "Удалить папку",[this, index](){remove_dir(index);});
            t_add_btn(menu, "Исключить папку",[this, index](){exclude_dir(index);});
        }
        else{
            t_add_btn(menu, "Исключить папку",[this, index](){exclude_dir(index);});
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

bool ProjectWidget::t_is_root_at(const QModelIndex &index) const
{
     return t_model->data(index, ProjectModel::data_role::is_root).toBool();
}

void ProjectWidget::t_init_project()
{
    if(t_project != nullptr){
        treeView = new DeselectableTreeView(this);
        horizontalLayout->addWidget(treeView);

        t_model = new ProjectModel(*t_project, this);
        treeView->setModel(t_model);

        treeView->setContextMenuPolicy(Qt::CustomContextMenu);
        connect(treeView, SIGNAL(customContextMenuRequested(const QPoint &)), this, SLOT(onCustomContextMenu(const QPoint &)));
        connect(treeView, &DeselectableTreeView::pressed, this, &ProjectWidget::t_element_pressed);
        connect(treeView, &DeselectableTreeView::doubleClicked, this, &ProjectWidget::t_element_double_clicked);
    }
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
