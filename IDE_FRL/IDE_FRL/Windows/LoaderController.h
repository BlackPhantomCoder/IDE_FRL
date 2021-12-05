#ifndef LOADERCONTROLLER_H
#define LOADERCONTROLLER_H


#include <QtCore>
#include <QtWidgets>
#include "Project/Project.h"
#include "MainWindowPartInt.h"

class LoaderController : public MainWindowPartInt
{
    Q_OBJECT
public:
    LoaderController(MainWindow* parent);

    // MainWindowPartInt interface
public:
    virtual void init() override;
    virtual void save() override;

private slots:
    void order_settings();
    void send_project();
    void send_file(const QString& path);

private:
    void t_send(const QStringList& files);
};


#endif // LOADERCONTROLLER_H
