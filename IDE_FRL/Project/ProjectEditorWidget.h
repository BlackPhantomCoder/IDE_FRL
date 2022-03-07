#ifndef PROJECTEDITORWIDGET_H
#define PROJECTEDITORWIDGET_H

#include <QDialog>
#include "ui_ProjectEditorWidget.h"
#include "Project/Project.h"

class ProjectEditorWidget : public QDialog, private Ui::ProjectEditorWidget
{
    Q_OBJECT

public:
    explicit ProjectEditorWidget(Project* project, QWidget *parent = nullptr);
private slots:
    void on_save_btn_clicked();
private:
    Project* t_project;
    int t_default_index = 0;
};

#endif // PROJECTEDITORWIDGET_H
