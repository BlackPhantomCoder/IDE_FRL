#include "Windows/MainWindow.h"
#include "Settings/MyQApp.h"

using namespace std;

int main(int argc, char *argv[])
{

    auto app = MyQApp(argc, argv);

    auto w = MainWindow();
    w.show();

    return app.exec();
}
