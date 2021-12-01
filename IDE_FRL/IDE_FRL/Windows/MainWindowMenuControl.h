#ifndef MAINWINDOWMENUCONTROL_H
#define MAINWINDOWMENUCONTROL_H

#include <QObject>
#include <QtCore>
#include <QtWidgets>

class MainWindow;

class MainWindowMenuControl : public QObject
{
    Q_OBJECT
public:
    explicit MainWindowMenuControl(MainWindow *main);

    void save();

private slots:
    void t_project_opened();
    void t_clicked(const QString& path);

private:
    void t_load();
    void t_add(const QString& path);
    void t_del(QAction* act);
private:
    MainWindow* t_main;
    bool t_full;
};

#endif // MAINWINDOWMENUCONTROL_H
