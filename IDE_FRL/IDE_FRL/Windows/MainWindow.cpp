#include "MainWindow.h"

#include <QToolBar>
#include <QMenuBar>
#include <QMenu>
#include <QComboBox>
#include <QPushButton>
#include <QString>

#include <QDebug>
#include <QMessageBox>
#include <QFileDialog>
#include <QInputDialog>

#include "Settings/MyQApp.h"
#include "Project/ProjectCreatorWidget.h"
#include "Interpretator/InterpretatorEditorWidget.h"
#include "Project/ProjectEditorWidget.h"
#include "Settings/IDESettingsEditor.h"

MainWindow::MainWindow():
   t_toolbar(this)
{
    t_menu = new Ui::MainWindowMenu();
    t_menu->setupUi(this);

    t_editor_w = new EditorWidget(this);
    t_project_w = new ProjectWidget(this);
    t_interpretator_w = new InterpretatorWidget(this);

    setCentralWidget(t_editor_w);

    t_docks = new DocksControl(this);
    t_menu_c = new MainWindowMenuControl(this);

    t_sexpr_controller = new SExprSellerController(this);

    t_set_enabled_interpretator_action(false);
    t_set_enabled_project_action(false);

    t_init_toolbar();
    t_connect_actions();
}

MainWindow::~MainWindow()
{
    t_interpretator_w->stop_interpretator();
    //auto& s = MyQApp::global_settings();
    t_docks->save();
    t_menu_c->save();
    t_sexpr_controller->save();

    //qDebug() << "MainWindow destroyed" << endl;
}

void MainWindow::t_init_toolbar()
{
    addToolBar(Qt::TopToolBarArea, t_toolbar.toolbar_1);

    connect(t_toolbar.toolbar_1_start_interpretator_btn, &QPushButton::clicked, this, &MainWindow::t_on_interpretator_start_action_triggered);
    connect(t_toolbar.toolbar_1_stop_interpretator_btn, &QPushButton::clicked , t_interpretator_w, &InterpretatorWidget::stop_interpretator);
    connect(t_toolbar.toolbar_1_clear_interpretator_btn, &QPushButton::clicked , t_interpretator_w, &InterpretatorWidget::clear);

//    tool1->addSeparator();
//    tool1->addWidget(butt3);
//    tool1->addSeparator();

//    auto* combo = new QComboBox(this);
//    combo->addItem(QString("Roflolisp"));
//    combo->addItem(QString("DOS_Roflolisp"));
//    tool1->addWidget(combo);

//    auto* tool2 = new QToolBar(this);
//    addToolBar(Qt::TopToolBarArea, tool2);
//    tool2->setAllowedAreas(Qt::TopToolBarArea);
//    tool2->setFloatable(false);
//    auto* butt4 = new QPushButton(QString("функции"));
//    auto* butt5 = new QPushButton(QString("доп. функции"));
//    tool2->addWidget(butt4);
//    tool2->addWidget(butt5);
}

void MainWindow::t_connect_actions()
{
    connect(t_menu->view_interpretator_action, &QAction::triggered, this, &MainWindow::t_on_view_interpretator_action_triggered);
    connect(t_menu->view_project_files_action, &QAction::triggered, this, &MainWindow::t_on_view_project_files_action_triggered);


    connect(t_menu->interpretator_start_action, &QAction::triggered, this, &MainWindow::t_on_interpretator_start_action_triggered);
    connect(t_menu->interpretator_stop_action, &QAction::triggered, t_interpretator_w, &InterpretatorWidget::stop_interpretator);
    connect(t_menu->interpretator_add_action,  &QAction::triggered, this, &MainWindow::t_on_interpretator_add_triggered);
    connect(t_menu->interpretator_edit_action,  &QAction::triggered, this, &MainWindow::t_on_interpretator_edit_triggered);
    connect(t_menu->interpretator_clear_action,  &QAction::triggered, t_interpretator_w, &InterpretatorWidget::clear);

    connect(t_menu->file_open_project_action, &QAction::triggered, this, &MainWindow::t_on_file_open_project);
    connect(t_menu->file_exit_action, &QAction::triggered, this, &MainWindow::close);
    connect(t_menu->file_create_project_action,  &QAction::triggered, this, &MainWindow::t_create_project);
    connect(t_menu->file_close_project_action,  &QAction::triggered, this, &MainWindow::t_close_project);
    connect(t_menu->file_save_project_action,  &QAction::triggered, this, &MainWindow::t_project_save);
    connect(t_menu->file_settings_action,  &QAction::triggered, [this](){
        auto* menu = new IDESettingsEditor();
        connect(this, &MainWindow::closed, menu, &QWidget::close);
        connect(this, &MainWindow::closed, menu, &QWidget::deleteLater);
        menu->show();
    });

    connect(t_menu->project_settings_action,  &QAction::triggered, this, &MainWindow::t_on_preject_settings_triggered);


    connect(t_docks, &DocksControl::dock_state_changed, this, &MainWindow::t_on_dock_widget_state_changed);



    connect(t_interpretator_w, &InterpretatorWidget::changed_state, this, &MainWindow::t_on_interpretator_state_changed);

    connect(t_project_w, &ProjectWidget::double_clicked_file,
            [this](const QModelIndex& index){
                if(t_project_w->exists_at(index))
                    t_editor_w->open_new_tab(t_project_w->path_at(index), EditorWidget::tab_pos::back);
            });
}

void MainWindow::t_on_view_interpretator_action_triggered()
{
    t_docks->show(t_interpretator_w);
}

void MainWindow::t_on_view_project_files_action_triggered()
{
    t_docks->show(t_project_w);
}

void MainWindow::t_on_dock_widget_state_changed(QDockWidget* w)
{
    auto state = w->isHidden();

    if(w->widget() == t_project_w){
        t_menu->view_project_files_action->setEnabled(state);
    }
    else if(w->widget() == t_interpretator_w){
        t_menu->view_interpretator_action->setEnabled(state);
    }
}


void MainWindow::t_on_interpretator_start_action_triggered()
{
    t_docks->show(t_interpretator_w);
    if(!t_interpretator_w->start_interpretator_w_answear()){
//        QMessageBox::warning(this, tr("Внимание"),
//                                        tr("Интерпретатор не запустился"),
//                                       QMessageBox::Ok);
    }
}

void MainWindow::t_on_interpretator_state_changed()
{
    t_set_enabled_interpretator_action(t_interpretator_w->is_running());
}

void MainWindow::t_on_file_open_project()
{
    auto file_name = QFileDialog::getOpenFileName(this,
        tr("Выберете файл проекта"), QString(), "*.json");
    if(file_name.isEmpty()) return;
    t_open_project(file_name);
}

void MainWindow::t_on_interpretator_add_triggered()
{
    auto w = InterpretatorCreatorWidget();
    w.exec();
}

void MainWindow::t_on_interpretator_edit_triggered()
{
    if(MyQApp::interpretator_settings().count() == 0){
        QMessageBox::warning(this, tr("Внимание"),
                                        tr("Нет доступных для редактирования интерпретаторов"),
                                       QMessageBox::Ok);
        return;
    }
    bool ok;
    QString item = QInputDialog::getItem(this, tr("Выбор интерпретатора"),
                                        tr("Интерперетатор:"), MyQApp::interpretator_settings().all_names(), 0, false, &ok);
    if (ok && !item.isEmpty()){

       auto w = InterpretatorCreatorWidget(item,  MyQApp::interpretator_settings().get_interpretator(item), false);
       w.exec();
    }
}

void MainWindow::t_on_preject_settings_triggered()
{
    auto w = ProjectEditorWidget(t_project, this);
    w.exec();
}

void MainWindow::t_close_project()
{
    t_close_project_check();
}

void MainWindow::t_create_project()
{
    auto w = ProjectCreatorWidget();
    if(auto r = w.exec(); r == QDialog::Accepted){
        t_open_project(w.path());
    }
}

void MainWindow::t_project_save()
{
    if(t_project) t_project->save();
}

void MainWindow::t_open_project(const QString &path)
{
    if(t_close_project_check())
        return;

    t_project = new Project(path);

    if(t_project->is_loaded()){
        if(t_project_w) t_project_w->set_project(t_project);
        if(t_interpretator_w) t_interpretator_w->set_project(t_project);
        t_set_enabled_project_action(true);
        emit project_opened();
    }
    else {
        delete t_project;
        t_project = nullptr;
        QMessageBox::warning(this, tr("Внимание"),
                                        tr("Ошибка загрузки проекта"),
                                       QMessageBox::Ok);
    }
}

bool MainWindow::t_close_project_check()
{
    if(t_project){
        if(t_project_need_save_check())
            return true;

        if(t_project_w) t_project_w->set_project(nullptr);
        if(t_interpretator_w) t_interpretator_w->set_project(nullptr);

        delete t_project;
        t_project = nullptr;

        t_set_enabled_project_action(false);
        emit project_closed();
    }
    return false;
}

bool MainWindow::t_project_need_save_check()
{
    if(t_project && t_project->is_loaded() && t_project->is_changed()){
        auto ans = QMessageBox::warning(this, tr("Внимание"),
                                        tr("Открытый проект не сохранён, сохранить?"),
                                       QMessageBox::Cancel|QMessageBox::No|QMessageBox::Ok);
        if(ans == QMessageBox::Ok)
            t_project->save();
        else if(ans == QMessageBox::Cancel)
            return true;
    }
    return false;
}

void MainWindow::t_set_enabled_project_action(bool val)
{
    t_menu->file_close_project_action->setEnabled(val);
    t_menu->file_save_project_action->setEnabled(val);
    t_menu->project_menu->setEnabled(val);
    t_menu->interpretator_start_action->setEnabled(val);
    t_toolbar.toolbar_1_start_interpretator_btn->setEnabled(val);
}

void MainWindow::t_set_enabled_interpretator_action(bool val)
{
    t_menu->interpretator_start_action->setEnabled(!val);
    t_menu->interpretator_stop_action->setEnabled(val);
    t_menu->interpretator_clear_action->setEnabled(val);
    t_toolbar.toolbar_1_start_interpretator_btn->setEnabled(!val);
    t_toolbar.toolbar_1_stop_interpretator_btn->setEnabled(val);
    t_toolbar.toolbar_1_clear_interpretator_btn->setEnabled(val);
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    if(t_project_need_save_check())
        event->ignore();
    else{
        emit closed();
        QWidget::closeEvent(event);
    }
}
