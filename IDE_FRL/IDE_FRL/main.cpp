#include "MainWindow.h"

#include <QApplication>
#include <memory>

#include "Project/ProjectWidget.h"
#include "Interpretator.h"
#include "InterpretatorWidget.h"
using namespace std;

unique_ptr<Project> project;

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    project = make_unique<Project>(QApplication::applicationDirPath() + "/project1/settings.json");

    auto w1 = InterpretatorWidget(*project.get());
    w1.show();

//    MainWindow w2;
//    w2.show();

    auto w = ProjectWidget(*project.get());
    w.show();

    return a.exec();
}
