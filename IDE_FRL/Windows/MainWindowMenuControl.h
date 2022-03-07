#ifndef MAINWINDOWMENUCONTROL_H
#define MAINWINDOWMENUCONTROL_H

#include <QtCore>
#include <QtWidgets>

#include "MainWindowPartInt.h"

class MainWindowMenuControl : public MainWindowPartInt
{
    Q_OBJECT
public:
    explicit MainWindowMenuControl(MainWindow *main);

    // MainWindowPartInt interface
public:
    virtual void init() override;
    virtual void save() override;

private slots:
    void t_project_opened();
    void t_clicked(const QString& path);

private:
    void t_load();
    void t_add(const QString& path);
    void t_del(QAction* act);
private:
    bool t_full;


};

#endif // MAINWINDOWMENUCONTROL_H
