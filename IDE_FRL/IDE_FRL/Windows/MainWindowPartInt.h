#ifndef MAINWINDOWPARTINT_H
#define MAINWINDOWPARTINT_H

#include <QObject>

class MainWindow;

class MainWindowPartInt : public QObject
{
    Q_OBJECT
public:
    explicit MainWindowPartInt(MainWindow *parent);
    virtual ~MainWindowPartInt() {};

    virtual void init() {};
    virtual void save() {};

protected:
    MainWindow* t_main;
};

#endif // MAINWINDOWPARTINT_H
