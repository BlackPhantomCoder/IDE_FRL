#ifndef MAINWINDOWTOOLBAR_H
#define MAINWINDOWTOOLBAR_H

#include <QObject>
#include <QPushButton>
#include <QToolBar>

class MainWindowToolbar
{
    friend class MainWindow;
public:
    MainWindowToolbar(MainWindow* parent);

private:
    QToolBar* toolbar_1;
    QPushButton* toolbar_1_start_interpretator_btn;
    QPushButton* toolbar_1_stop_interpretator_btn;
    QPushButton* toolbar_1_clear_interpretator_btn;

};
#endif // MAINWINDOWTOOLBAR_H
