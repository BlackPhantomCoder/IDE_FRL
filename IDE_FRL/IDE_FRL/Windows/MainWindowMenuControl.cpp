#include "MainWindowMenuControl.h"
#include "MainWindow.h"
#include "Settings/MyQApp.h"
#include <algorithm>
using namespace std;


MainWindowMenuControl::MainWindowMenuControl(MainWindow *main):
    QObject(main),
    t_main(main)
{
    t_load();
    connect(t_main, &MainWindow::project_opened, this, &MainWindowMenuControl::t_project_opened);
}

void MainWindowMenuControl::save()
{
    auto& s = MyQApp::global_settings();
    AT_GROUP(s, "MainWindow/MenuControl");
    {
        auto prjs = t_main->t_menu->file_last_projects_menu->actions();
        auto lst = QStringList{};
        transform(prjs.begin(), prjs.end(), back_inserter(lst), [](const auto* act){return act->text();});
        s.setValue("last", lst);
    }
}

void MainWindowMenuControl::t_project_opened()
{
    t_add(t_main->t_project->full_path());
}

void MainWindowMenuControl::t_clicked(const QString &path)
{
    t_main->t_open_project(path);
}

void MainWindowMenuControl::t_load()
{
    auto& s = MyQApp::global_settings();
    AT_GROUP(s, "MainWindow/MenuControl");
    {
        auto lst = s.value("last", QStringList{}).toStringList();
        for(const auto& str : lst){
            auto* act = new QAction(str, this);
            t_main->t_menu->file_last_projects_menu->addAction(act);
            connect(act, &QAction::triggered, [this, act](){t_clicked(act->text());});
        }
    }
}

void MainWindowMenuControl::t_add(const QString &path)
{
    auto* menu = t_main->t_menu->file_last_projects_menu;
    auto prjs = t_main->t_menu->file_last_projects_menu->actions();
    auto it = find_if(prjs.begin(), prjs.end(), [&path](const QAction* rh){return rh->text() == path;});
    if(it != end(prjs)){
        if(it == begin(prjs)) return;
        menu->removeAction(*it);
        menu->insertAction(prjs.front(), *it);
        return;
    }

    auto* act = new QAction(path, this);
    auto size = prjs.size();

    if(size == 5){
        t_del(prjs.back());
    }


    if(size != 0)
        menu->insertAction(prjs.front(), act);
    else
        menu->addAction(act);

    connect(act, &QAction::triggered, [this, act](){t_clicked(act->text());});
}

void MainWindowMenuControl::t_del(QAction *act)
{
    auto* menu = t_main->t_menu->file_last_projects_menu;
    menu->removeAction(act);
    delete act;
}
