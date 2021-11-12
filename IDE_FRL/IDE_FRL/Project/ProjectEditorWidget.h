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
    void on_cancel_btn_clicked();

private:
    void t_from_project();
private:
    Project* t_project;
    QStringList t_interetators;
};

#endif // PROJECTEDITORWIDGET_H
