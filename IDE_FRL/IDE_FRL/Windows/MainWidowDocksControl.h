#ifndef MAINWIDGET_H
#define MAINWIDGET_H

#include <QtWidgets>
#include <QtCore>

#include "Project/Project.h"

class MainWindow;

class DocksControl : public QObject{
    Q_OBJECT
    enum dock_widget : int {project, interpretator, none};
public:
    DocksControl(MainWindow* window);
    void save();
signals:
    void dock_state_changed(QDockWidget* w);
public slots:
    void hide(QWidget* w);
    void show(QWidget* w);
private:
    QString t_title_by_mode(dock_widget mode);
    QWidget* t_w_by_mode(dock_widget mode);
    dock_widget t_mode_by_w(QWidget* w);
    void t_load_docks();
    void t_load_dock(dock_widget mode, Qt::DockWidgetArea side);
    dock_widget t_default_m_by_side(Qt::DockWidgetArea side);
private:
    MainWindow* t_main;
    QHash<QWidget*, QDockWidget*> t_w_to_dw;
};


#endif // MAINWIDGET_H
