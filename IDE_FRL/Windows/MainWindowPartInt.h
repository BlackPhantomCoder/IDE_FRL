#ifndef MAINWINDOWPARTINT_H
#define MAINWINDOWPARTINT_H

#include <QObject>

class MainWindow;

//Интерфейс для класса-части MainWindow
class MainWindowPartInt : public QObject
{
    Q_OBJECT
public:
    explicit MainWindowPartInt(MainWindow *parent);
    virtual ~MainWindowPartInt() {};

    //функция, вызываемая в конструкторе
    virtual void init() {};
    //функция, вызываемая в деструкторе или при сохранении
    virtual void save() {};

protected:
    MainWindow* t_main;
};

#endif // MAINWINDOWPARTINT_H
