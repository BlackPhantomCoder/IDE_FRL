#ifndef MAINWINDOW1_H
#define MAINWINDOW1_H

#include "ui_MainWindow.h"
#include <QGridLayout>
#include <QTabBar>
#include <QDockWidget>
#include <QToolBar>
#include <QPushButton>
#include <QComboBox>
#include <QLabel>
#include <QList>
#include "Qsci/qsciscintilla.h"
#include "Qsci/qscilexercpp.h"


class MainWindow : public QMainWindow, private Ui::MainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);

private slots:
    void on_tabWidget_tabCloseRequested(int index);

    void on_action_29_triggered();

    void on_action_30_triggered();

    void on_action_triggered();

    void on_tabWidget_tabBarDoubleClicked(int index);

private:
    //QsciScintilla *textEdit;
    QList<QsciScintilla *> edits;
    QDockWidget *dock;
    QDockWidget *dock2;
    QToolBar *tool1;
    QToolBar *tool2;
    QPushButton* butt;
    QPushButton* butt2;
    QPushButton* butt3;
    QComboBox* combo;
    QPushButton* butt4;
    QPushButton* butt5;

    QsciScintilla* init_editor();
    void init_toolbars();
    void init_docks();
    void init_tabs();
};

#endif // MAINWINDOW1_H
