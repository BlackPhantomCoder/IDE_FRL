#ifndef TEST_H
#define TEST_H

#include <QPoint>
#include <QContextMenuEvent>
#include <QTreeView>
#include "treemodel.h"
#include "ui_ProjectWidget.h"
#include "Project.h"

class DeselectableTreeView : public QTreeView
{
public:
    DeselectableTreeView(QWidget *parent = nullptr) : QTreeView(parent) {}
    virtual ~DeselectableTreeView()  = default;

private:
    virtual void mousePressEvent(QMouseEvent *event);
};

class ProjectWidget : public QWidget, private Ui::ProjectWidgetUI
{
    Q_OBJECT

public:
    explicit ProjectWidget(Project& project, QWidget *parent = nullptr);
public slots:
    void onCustomContextMenu(const QPoint &point);

    void create_and_add_file(const QModelIndex& ind);
    void create_and_add_dir(const QModelIndex& ind);

    void add_exist_file(const QModelIndex& ind);
    void add_exist_dir(const QModelIndex& ind);

    void remove_file(const QModelIndex& ind);
    void remove_dir(const QModelIndex& ind);

    void exclude_file(const QModelIndex& ind);
    void exclude_dir(const QModelIndex& ind);
private:
    QMenu* t_context_by_index(const QModelIndex& ind);
    QMenu* t_root_context_menu();

    template<class Fnc>
    void t_add_btn(QMenu* menu, const QString& text, Fnc f);
private:
    Project* t_project;
    ProjectModel* t_model;
    DeselectableTreeView* treeView;
};

#endif // TEST_H
