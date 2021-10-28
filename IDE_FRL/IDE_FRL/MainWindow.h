#ifndef MAINWINDOW1_H
#define MAINWINDOW1_H

#include "ui_MainWindow.h"
#include "Qsci/qsciscintilla.h"
#include "Qsci/qscilexercpp.h"


class MainWindow : public QMainWindow, private Ui::MainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);

private:
    QsciScintilla *textEdit;
};

#endif // MAINWINDOW1_H
