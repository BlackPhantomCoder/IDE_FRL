#ifndef TEST_H
#define TEST_H

#include <QPoint>
#include <QContextMenuEvent>
#include <QTreeView>
#include "treemodel.h"
#include "ui_ProjectWidget.h"
#include "Project.h"

//Реализация отмены выделения
class DeselectableTreeView : public QTreeView
{
public:
    DeselectableTreeView(QWidget *parent = nullptr) : QTreeView(parent) {}
    virtual ~DeselectableTreeView()  = default;

private:
    virtual void mousePressEvent(QMouseEvent *event);
};

//Виджет управления файлами в проекте
class ProjectWidget : public QWidget, private Ui::ProjectWidgetUI
{
    Q_OBJECT

public:
    explicit ProjectWidget(QWidget *parent = nullptr);

    Project* project();

    QString path_at(const QModelIndex& index) const;
    bool is_file_at(const QModelIndex& index) const;
    bool exists_at(const QModelIndex& index) const;
signals:
    void project_changed();

    void created_and_added_file(const QModelIndex& index);
    void created_and_added_dir(const QModelIndex& index);

    void clicked_file(const QModelIndex& index);
    void double_clicked_file(const QModelIndex& index);

    void clicked_dir(const QModelIndex& index);
    void double_clicked_dir(const QModelIndex& index);

    void send_file_request(const QString& path);
public slots:
    void onCustomContextMenu(const QPoint &point);

    void send_file(const QModelIndex& ind);

    void create_and_add_file(const QModelIndex& ind);
    void create_and_add_dir(const QModelIndex& ind);

    void add_exist_file(const QModelIndex& ind);
    void add_exist_dir(const QModelIndex& ind);

    void remove_file(const QModelIndex& ind);
    void remove_dir(const QModelIndex& ind);

    void exclude_file(const QModelIndex& ind);
    void exclude_dir(const QModelIndex& ind);

    void set_project(Project* project);

private slots:
    void t_element_pressed(const QModelIndex &ind);
    void t_element_double_clicked(const QModelIndex &ind);
private:
    void t_init_menus();
    QMenu* t_context_by_index(const QModelIndex& ind);
    QMenu* t_root_context_menu();
    bool t_is_root_at(const QModelIndex& index) const;

    void t_init_project();

    template<class Fnc>
    void t_add_btn(QMenu* menu, const QString& text, Fnc f);
private:
    Project* t_project;
    ProjectModel* t_model;
    DeselectableTreeView* treeView;

};

#endif // TEST_H
