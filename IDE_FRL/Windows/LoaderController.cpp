#include "LoaderController.h"

#include "MainWindow.h"
#include "Project/OrderEditor.h"
#include <algorithm>
using namespace std;

LoaderController::LoaderController(MainWindow *parent):
    MainWindowPartInt(parent)
{

}

void LoaderController::init()
{
    t_main->t_menu->project_send_to_int_action->setEnabled(false);
    t_main->t_menu->project_order_settings_action->setEnabled(false);
    connect(t_main, &MainWindow::project_changed,
            [this](){t_main->t_menu->project_send_to_int_action->setEnabled(t_main->t_project);});
    connect(t_main, &MainWindow::project_changed,
            [this](){t_main->t_menu->project_order_settings_action->setEnabled(t_main->t_project);});

    connect(t_main->t_menu->project_send_to_int_action, &QAction::triggered, this, &LoaderController::send_project);
    connect(t_main->t_menu->project_order_settings_action, &QAction::triggered, this, &LoaderController::order_settings);
    connect(t_main->t_project_w, &ProjectWidget::send_file_request,  this, &LoaderController::send_file);
}

void LoaderController::save()
{

}

void LoaderController::order_settings()
{
    auto w = OrderEditor(t_main->t_project);
    w.exec();
}

void LoaderController::send_project()
{
    auto all = to_list(&t_main->t_project->tree());
    sort(all.begin(), all.end(), [](FileTreeItem *lh, FileTreeItem *rh){ return lh->order() < rh->order();});
    auto files = QStringList{};
    for(auto* node : all){
        if(node->is_file()){

            files.append(t_main->t_project->dir_path() + "/" + path_by_node(node));
        }
    }
    t_send(files);
}

void LoaderController::send_file(const QString &path)
{
    t_send(QStringList{path});
}

void LoaderController::t_send(const QStringList& files)
{
    if(!t_main->t_interpretator_w->is_running()){
        auto ans = QMessageBox::warning(t_main, tr("Внимание"),
                                        tr("Интерпретатор не запущен, запустить?"),
                                        QMessageBox::Cancel|QMessageBox::Yes);
        if(ans == QMessageBox::Yes){
            t_main->t_start_interpretator();
        }
        else return;
    }
    auto str = QString( "(eval ((lambda !!x!!"
                        "(movd break !!break!!)"
                        "(DEFUN BREAK"
                        "    (nlambda (!!f!! !!msg!!)"
                        "        (THROW 'BREAK-THROW)"
                        "    )"
                        ")"
                        "(UNWIND-PROTECT"
                        "    ((lambda (!!lst!! !!x!!)"
                        "        (loop"
                        "            ((null !!lst!!) T)"
                        "            (setq !!x!! (car !!lst!!))"
                        "            (setq !!lst!! (cdr !!lst!!))"
                        "            (princ |loading |)"
                        "            (print !!x!!)"
                        "            ((null (rds !!x!!)) (princ |load error|) (TERPRI 1) nil)"
                        "            (UNWIND-PROTECT"
                        "                (CATCH 'BREAK-THROW "
                        "                    (loop (print (eval (read))))"
                        "                )"
                        "                (rds)"
                        "            )"
                        "        )"
                        "    ) !!x!!)"
                        "    (progn"
                        "        (MOVD !!BREAK!! BREAK)"
                        "        (REMD !!BREAK!!)"
                        "    )"
                        "))");
    for(auto& file : files){
        str += " ";
        str += "|"+file +"|";
    }

    t_main->t_interpretator_w->send(str + "))", true);
}
