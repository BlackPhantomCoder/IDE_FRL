#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "MainWidowDocksControl.h"
#include "ui_MainWindowMenu.h"
#include <QObject>

#include "MainWidowDocksControl.h"
#include "Editor/EditorWidget.h"
#include "Interpretator/InterpretatorWidget.h"
#include "Project/ProjectWidget.h"
#include "MainWindowToolbar.h"
#include "MainWindowMenuControl.h"
#include "SExprSellerController.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

    friend class LoaderController;
    friend class DocksControl;
    friend class MainWindowMenuControl;
    friend class SExprSellerController;
    friend class MainWindowToolbar;
public:
    MainWindow();
    ~MainWindow();

signals:
    void project_changed();
    void project_opened();
    void project_closed();
    void closed();

private:
    void t_connect_actions();
    void init_edit_menu();

private slots:
    void edit_menu(int);
    void control_edit_menu();
    QString set_proj_path_for_editor();
    void t_on_view_interpretator_action_triggered();
    void t_on_view_project_files_action_triggered();

    void t_on_dock_widget_state_changed(QDockWidget* w);

    void t_on_interpretator_state_changed();

    void t_on_file_open_project();

    void t_on_interpretator_add_triggered();
    void t_on_interpretator_edit_triggered();
    void t_on_interpretator_delete_triggered();
    void t_on_preject_settings_triggered();


    void t_start_interpretator();

    void t_close_project();

    void t_create_project();
    void t_project_save();

    void t_open_project(const QString& path);
    void on_file_save_action_triggered();

    void call_close_files(); //закрыть все файлы
    void on_help_about_action_triggered();

private:
    // true если отмена
    bool t_close_project_check();
    // true если отмена
    bool t_project_need_save_check();

    void t_set_enabled_project_action(bool val);
    void t_set_enabled_interpretator_action(bool val);


    void t_save();
    void t_load();
protected:
    void closeEvent(QCloseEvent *event) override;
private:
    Project* t_project = nullptr;
    EditorWidget* t_editor_w = nullptr;
    ProjectWidget* t_project_w = nullptr;
    InterpretatorWidget* t_interpretator_w = nullptr;
    Ui::MainWindowMenu* t_menu = nullptr;
    MainWindowToolbar* t_toolbar = nullptr;
    DocksControl* t_docks = nullptr;
    MainWindowMenuControl* t_menu_c = nullptr;
    SExprSellerController* t_sexpr_controller = nullptr;
    LoaderController* t_loader;
};

#endif // MAINWINDOW_H
