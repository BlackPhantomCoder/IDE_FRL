#ifndef PROJECTCREATORWIDGET_H
#define PROJECTCREATORWIDGET_H

#include "ui_ProjectCreatorWidget.h"
#include <QDialog>

class ProjectCreatorWidget : public QDialog, private Ui::ProjectCreatorWidget
{
    Q_OBJECT

public:
    explicit ProjectCreatorWidget(QWidget *parent = nullptr);

    QString path();


private slots:
    void t_check_accept();

private:
    void t_get_file_path();
private:
    QString t_get_name();
    QString t_get_dir();
    QString t_get_interpretator();

private:
    QStringList t_interetators;
};

#endif // PROJECTCREATORWIDGET_H
