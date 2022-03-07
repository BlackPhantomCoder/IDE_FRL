#ifndef ORDEREDITOR_H
#define ORDEREDITOR_H
#include "ui_OrderEditor.h"
#include <QtCore>
#include <QtWidgets>

#include "Project/Project.h"

class OrderEditor : public QDialog, Ui::OrderDialog
{
    Q_OBJECT
public:
    explicit OrderEditor(Project* project, QWidget *parent = nullptr);

private slots:
    void t_up();
    void t_down();
    void t_accept();

private:
    Project* t_project;
    QList<FileTreeItem*> t_elems;
};

#endif // ORDEREDITOR_H
