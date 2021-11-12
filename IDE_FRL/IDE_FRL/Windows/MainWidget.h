#ifndef MAINWIDGET_H
#define MAINWIDGET_H

#include <QDockWidget>
#include <QMenuBar>
#include <QMainWindow>

#include "Project/Project.h"

class MainWidget : public QMainWindow
{
    Q_OBJECT
public:
    enum class doks_state {hidden, show};
    enum class doks_type {left, right, bottom};
public:
    explicit MainWidget(QWidget *parent = nullptr);

    QWidget* get_side_widget(doks_type type);
    doks_state get_side_widget_state(doks_type type);
    QString get_side_widget_text(doks_type type);

signals:
    void side_widget_changed(doks_type type);
    void side_widget_state_changed(doks_type type);
    void side_widget_text_changed(doks_type type);

public slots:

    void set_side_widget(doks_type type, QWidget* widget, doks_state state);
    void set_side_widget_state(doks_type type, doks_state state);
    void set_side_widget_text(doks_type type, const QString& text);

private:
    QDockWidget* t_dock_by_side(doks_type type);
    QDockWidget* t_create_dock();

private:
    QDockWidget* t_dock_bottom;
    QDockWidget* t_dock_left;
    QDockWidget* t_dock_right;
};

#endif // MAINWIDGET_H
