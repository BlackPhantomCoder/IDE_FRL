#include "Windows/MainWindow.h"
#include "Settings/MyQApp.h"

using namespace std;

int main(int argc, char *argv[])
{
    MyQApp a(argc, argv);

    auto w = MainWindow();
    w.show();

    return a.exec();
}
