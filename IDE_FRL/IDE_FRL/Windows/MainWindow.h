#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "MainWidget.h"
#include "ui_MainWindowMenu.h"
#include <QObject>

#include "MainWidget.h"
#include "Editor/EditorWidget.h"
#include "Interpretator/InterpretatorWidget.h"
#include "Project/ProjectWidget.h"
#include "MainWindowToolbar.h"

class MainWindow : public MainWidget
{
    Q_OBJECT
public:
    MainWindow();
private:
    void t_init_toolbar();
    void t_connect_actions();

private slots:
    void t_on_view_interpretator_action_triggered();
    void t_on_view_project_files_action_triggered();

    void t_on_side_widget_state_changed(doks_type type);

    void t_on_interpretator_start_action_triggered();

    void t_on_interpretator_state_changed();

    void t_on_file_open_project();

    void t_on_interpretator_add_triggered();
    void t_on_interpretator_edit_triggered();
    void t_on_preject_settings_triggered();

    void t_close_project();

    void t_create_project();
    void t_project_save();
private:
    void t_open_project(const QString& path);

    // true если отмена
    bool t_close_project_check();
    // true если отмена
    bool t_project_need_save_check();

    void t_set_enabled_project_action(bool val);
    void t_set_enabled_interpretator_action(bool val);

protected:
    void closeEvent(QCloseEvent *event) override;
private:
    Project* t_project = nullptr;
    EditorWidget* t_editor_w = nullptr;
    ProjectWidget* t_project_w = nullptr;
    InterpretatorWidget* t_interpretator_w = nullptr;
    Ui::MainWindowMenu* t_menu = nullptr;
    MainWindowToolbar t_toolbar = nullptr;
};

#endif // MAINWINDOW_H
