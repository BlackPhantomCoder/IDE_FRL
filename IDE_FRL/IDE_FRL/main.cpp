#include <QApplication>

#include <QtDebug>
#include "Windows/MainWindow.h"
#include "Project/ProjectWidget.h"
#include "Settings/GlobalSettings.h"

using namespace std;

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    auto* w = new MainWindow();
    w->show();

    return a.exec();
}
