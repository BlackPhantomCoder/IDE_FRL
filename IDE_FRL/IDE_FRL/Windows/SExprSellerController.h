#ifndef SEXPRSELLERCONTROLLER_H
#define SEXPRSELLERCONTROLLER_H

#include <QtCore>
#include <QtWidgets>

#include <unordered_map>
#include "Interpretator/SExprSeller.h"

class MainWindow;

class SExprSellerController : public QObject
{
    Q_OBJECT
public:
    explicit SExprSellerController(MainWindow *main = nullptr);

    void save();
private slots:
    void t_add_fnc(SExprAction* act);
private:
    MainWindow* t_main;

    SExprSeller t_data;
};

#endif // SEXPRSELLERCONTROLLER_H
