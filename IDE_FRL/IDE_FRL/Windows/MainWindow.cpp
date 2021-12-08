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

MainWindow::MainWindow()
{
    t_menu = new Ui::MainWindowMenu();
    t_menu->setupUi(this);
    init_edit_menu();

    t_editor_w = new EditorWidget(this);
    t_project_w = new ProjectWidget(this);
    t_interpretator_w = new InterpretatorWidget(this);


    t_toolbar = new MainWindowToolbar(this);
    t_docks = new DocksControl(this);
    t_menu_c = new MainWindowMenuControl(this);
    t_sexpr_controller = new SExprSellerController(this);


    t_toolbar->init();
    t_docks->init();
    t_menu_c->init();
    t_sexpr_controller->init();


    t_set_enabled_interpretator_action(false);
    t_set_enabled_project_action(false);
    setCentralWidget(t_editor_w);

    t_connect_actions();
}

MainWindow::~MainWindow()
{
    t_interpretator_w->stop_interpretator();
    //auto& s = MyQApp::global_settings();

    t_toolbar->save();
    t_docks->save();
    t_menu_c->save();
    t_sexpr_controller->save();

    //qDebug() << "MainWindow destroyed" << endl;
}

void MainWindow::t_connect_actions()
{
    t_menu->interpretator_clear_action->setEnabled(!t_interpretator_w->clear_state());

    connect(t_editor_w->get_tab_widget(), &QTabWidget::currentChanged, this, &MainWindow::edit_menu); //меню правка
    connect(t_editor_w, &EditorWidget::need_proj_path, this, &MainWindow::set_proj_path_for_editor);
    t_menu->file_save->setShortcut(Qt::CTRL + Qt::Key_S);
    connect(this, &MainWindow::closed, this, &MainWindow::call_close_files);
    connect(t_menu->file_save, &QAction::triggered, t_editor_w, &EditorWidget::update_bufer);
    connect(t_menu->file_save, &QAction::triggered, t_editor_w, &EditorWidget::control_saved_state);

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
    connect(t_interpretator_w, &InterpretatorWidget::clear_state_changed,
            [this](bool state){t_menu->interpretator_clear_action->setEnabled(!state);});

    connect(t_project_w, &ProjectWidget::double_clicked_file,
            [this](const QModelIndex& index){
                if(t_project_w->exists_at(index))
                    t_editor_w->open_new_tab(t_project_w->path_at(index), EditorWidget::tab_pos::back);
    });
}

//инициализация без едитора
void MainWindow::init_edit_menu()
{
    t_menu->edit_undo->setShortcut(QKeySequence("Ctrl+Z"));
    t_menu->edit_undo->setEnabled(false);

    t_menu->edit_redo->setShortcut(QKeySequence("Ctrl+Y"));
    t_menu->edit_redo->setEnabled(false);

    t_menu->edit_copy->setShortcut(QKeySequence("Ctrl+C"));
    t_menu->edit_copy->setEnabled(false);

    t_menu->edit_cut->setShortcut(QKeySequence("Ctrl+X"));
    t_menu->edit_cut->setEnabled(false);

    t_menu->edit_put->setShortcut(QKeySequence("Ctrl+V"));
    t_menu->edit_put->setEnabled(false);

    t_menu->edit_delete->setEnabled(false);

    t_menu->edit_ctrl_all->setShortcut(QKeySequence("Ctrl+A"));
    t_menu->edit_ctrl_all->setEnabled(false);
}

//меню правка при изменении вкладки
void MainWindow::edit_menu(int n)
{
    if(n >= 0){
        t_editor_w->set_margin_width(); //костыль для маргинов при открытии файлов

        auto cur_edit = static_cast<QsciScintilla*>(t_editor_w->get_tab_widget()->widget(n));
        auto context = cur_edit->createStandardContextMenu();

        auto acts = context->actions();

        acts.at(0)->setText(tr("Отменить"));
        acts.at(1)->setText(tr("Повторить"));
        acts.at(3)->setText(tr("Вырезать"));
        acts.at(4)->setText(tr("Копировать"));
        acts.at(5)->setText(tr("Вставить"));
        acts.at(6)->setText(tr("Удалить"));
        acts.at(8)->setText(tr("Выделить всё"));

        t_menu->menu_2->clear();
        t_menu->menu_2->addActions(context->actions());

        //коннект на контроль
        connect(cur_edit, SIGNAL(textChanged()),
                    this, SLOT(control_edit_menu()));
        connect(cur_edit, SIGNAL(selectionChanged()),
                    this, SLOT(control_edit_menu()));

        if(cur_edit->isUndoAvailable()){
            t_menu->menu_2->actions().at(0)->setEnabled(true);
        }
        else{
            t_menu->menu_2->actions().at(0)->setEnabled(false);
        }
        if(cur_edit->isRedoAvailable()){
            t_menu->menu_2->actions().at(1)->setEnabled(true);
        }
        else{
            t_menu->menu_2->actions().at(1)->setEnabled(false);
        }
    }
    else{
        t_menu->menu_2->clear();

        t_menu->menu_2->addAction(t_menu->edit_undo);
        t_menu->menu_2->addAction(t_menu->edit_redo);
        t_menu->menu_2->addSeparator();
        t_menu->menu_2->addAction(t_menu->edit_copy);
        t_menu->menu_2->addAction(t_menu->edit_cut);
        t_menu->menu_2->addAction(t_menu->edit_put);
        t_menu->menu_2->addAction(t_menu->edit_delete);
        t_menu->menu_2->addSeparator();
        t_menu->menu_2->addAction(t_menu->edit_ctrl_all);
    }
}

//контроль меню правки
void MainWindow::control_edit_menu()
{
    auto cur_edit = static_cast<QsciScintilla*>(t_editor_w->get_tab_widget()->currentWidget());
    auto acts = t_menu->menu_2->actions();
    if(cur_edit->isUndoAvailable()){
        acts.at(0)->setEnabled(true);
    }
    else{
        acts.at(0)->setEnabled(false);
    }
    if(cur_edit->isRedoAvailable()){
        acts.at(1)->setEnabled(true);
    }
    else{
        acts.at(1)->setEnabled(false);
    }
    if(cur_edit->hasSelectedText()){
        acts.at(3)->setEnabled(true);
        acts.at(4)->setEnabled(true);

        acts.at(6)->setEnabled(true);
    }
    else{
        acts.at(3)->setEnabled(false);
        acts.at(4)->setEnabled(false);

        acts.at(6)->setEnabled(false);
    }
    if(cur_edit->text() == tr("")){
        acts.at(8)->setEnabled(false);
    }
    else{
        acts.at(8)->setEnabled(true);
    }
}

QString MainWindow::set_proj_path_for_editor()
{
    return t_project->dir_path();
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
        call_close_files();
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

void MainWindow::call_close_files()
{
    for(int i = t_editor_w->tabs_count()-1; i >= 0; --i){
        emit t_editor_w->get_tab_widget()->tabCloseRequested(i);
    }
}

void MainWindow::t_set_enabled_project_action(bool val)
{
    t_menu->file_close_project_action->setEnabled(val);
    t_menu->file_save_project_action->setEnabled(val);
    t_menu->project_menu->setEnabled(val);
    t_menu->interpretator_start_action->setEnabled(val);
}

void MainWindow::t_set_enabled_interpretator_action(bool val)
{
    t_menu->interpretator_start_action->setEnabled(!val);
    t_menu->interpretator_stop_action->setEnabled(val);
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

void MainWindow::on_file_save_triggered()
{
    auto cur_edit = static_cast<QsciScintilla*>(t_editor_w->get_tab_widget()->currentWidget());
    QString txt = cur_edit->text();
    QString path = t_project->dir_path();
    path += "/" + t_editor_w->get_tab_widget()->tabText(t_editor_w->get_tab_widget()->currentIndex());
    //qDebug() << path;
    QFile file(path);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(txt.toUtf8());
    file.close();
}
