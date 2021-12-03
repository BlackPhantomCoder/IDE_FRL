#include "MainWindowToolbar.h"
#include "Windows/MainWindow.h"

MainWindowToolbar::MainWindowToolbar(MainWindow *parent):
    MainWindowPartInt(parent)
{
    toolbar_1 = new QToolBar("Панель инструментов", parent);

    toolbar_1->setAllowedAreas(Qt::TopToolBarArea);
    toolbar_1->setFloatable(false);

    toolbar_1_start_interpretator_btn = new QPushButton(QString("◀"), parent);
    toolbar_1_stop_interpretator_btn = new QPushButton(QString("■"), parent);
    toolbar_1_clear_interpretator_btn = new QPushButton(QString("⎚"), parent);

    toolbar_1->addWidget(toolbar_1_start_interpretator_btn);
    toolbar_1->addWidget(toolbar_1_stop_interpretator_btn);
    toolbar_1->addWidget(toolbar_1_clear_interpretator_btn);


    t_main->addToolBar(Qt::TopToolBarArea, toolbar_1);

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

void MainWindowToolbar::t_sinc_btn_w_action(QPushButton *btn, QAction *act)
{
    connect(
                btn,
                &QPushButton::clicked,
                act,
                &QAction::trigger
    );
    connect(
                act,
                &QAction::changed,
                [btn, act](){
                    btn->setEnabled(act->isEnabled());
                }
    );
}

void MainWindowToolbar::init()
{
    t_sinc_btn_w_action(toolbar_1_start_interpretator_btn, t_main->t_menu->interpretator_start_action);
    t_sinc_btn_w_action(toolbar_1_stop_interpretator_btn, t_main->t_menu->interpretator_stop_action);
    t_sinc_btn_w_action(toolbar_1_clear_interpretator_btn, t_main->t_menu->interpretator_clear_action);
}
