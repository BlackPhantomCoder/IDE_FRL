#include "MainWindowToolbar.h"
#include "Windows/MainWindow.h"

MainWindowToolbar::MainWindowToolbar(MainWindow *parent)
{
    toolbar_1 = new QToolBar(parent);

    toolbar_1->setAllowedAreas(Qt::TopToolBarArea);
    toolbar_1->setFloatable(false);

    toolbar_1_start_interpretator_btn = new QPushButton(QString("◀"), parent);
    toolbar_1_stop_interpretator_btn = new QPushButton(QString("■"), parent);
    toolbar_1_clear_interpretator_btn = new QPushButton(QString("⎚"), parent);

    toolbar_1->addWidget(toolbar_1_start_interpretator_btn);
    toolbar_1->addWidget(toolbar_1_stop_interpretator_btn);
    toolbar_1->addWidget(toolbar_1_clear_interpretator_btn);
}
