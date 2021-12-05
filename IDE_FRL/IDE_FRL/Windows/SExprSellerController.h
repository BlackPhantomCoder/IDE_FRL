#ifndef SEXPRSELLERCONTROLLER_H
#define SEXPRSELLERCONTROLLER_H

#include <QtCore>
#include <QtWidgets>

#include <unordered_map>
#include "Interpretator/SExprSeller.h"
#include "MainWindowPartInt.h"

class SExprSellerController : public MainWindowPartInt
{
    Q_OBJECT
    friend class LoaderController;
public:
    explicit SExprSellerController(MainWindow *main);


    // MainWindowPartInt interface
public:
    virtual void init() override;
    virtual void save() override;

private slots:
    void t_add_fnc(SExprAction* act);
private:
    SExprSeller t_data;
};

#endif // SEXPRSELLERCONTROLLER_H
