#ifndef MAINWINDOWTOOLBAR_H
#define MAINWINDOWTOOLBAR_H

#include <QObject>
#include <QPushButton>
#include <QToolBar>

#include "MainWindowPartInt.h"

class MainWindowToolbar : public MainWindowPartInt
{
    Q_OBJECT
    friend class MainWindow;
public:
    MainWindowToolbar(MainWindow* parent);

    // MainWindowPartInt interface
public:
    virtual void init() override;

private:
    void t_sinc_btn_w_action(QPushButton* btn, QAction* act);
private:
    QToolBar* toolbar_1;
    QPushButton* toolbar_1_start_interpretator_btn;
    QPushButton* toolbar_1_stop_interpretator_btn;
    QPushButton* toolbar_1_clear_interpretator_btn;

};
#endif // MAINWINDOWTOOLBAR_H
