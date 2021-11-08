#include "MainWindow.h"
#include "LexerLisp.h"

MainWindow::MainWindow(Project& project, QWidget *parent) :
    QMainWindow(parent),
    t_project(&project)
{
    setupUi(this);

    setCorner(Qt::BottomLeftCorner, Qt::LeftDockWidgetArea);
    setCorner(Qt::TopLeftCorner, Qt::LeftDockWidgetArea);
    setCorner(Qt::BottomRightCorner, Qt::RightDockWidgetArea);
    setCorner(Qt::TopRightCorner, Qt::RightDockWidgetArea);

    auto textEdit = init_editor();
    edits.push_back(textEdit);
    setCentralWidget(tabWidget);

    auto textEdit2 = init_editor();
    edits.push_back(textEdit2);

    init_toolbars();
    init_docks();
    init_tabs();
}

QsciScintilla* MainWindow::init_editor(){
    auto *edit = new QsciScintilla; // инитилизируем редактор
    edit->setUtf8(true); // мы же хотим читать кириллицу

    auto* lex = new LexerLisp(this); // создаем лексер (схему подсветки)
    lex->setDefaultFont(QFont("Consolas", 14));

    edit->setLexer(lex); // задаем лексер нашему редактору
    edit->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOn);
    edit->setMarginType(0,QsciScintilla::NumberMargin);// Установить номер строки для отображения на полях 0.
    edit->setMarginLineNumbers(0,true);// Включить номера строк для этого поля
    edit->setMarginWidth(0,25);// Устанавливаем ширину поля

    auto combo2 = new QComboBox(edit);
    combo2->addItem(QString("100%"));
    combo2->addItem(QString("125%"));
    combo2->setMaximumWidth(65);

    auto lab1 = new QLabel(QString("Стр: "), edit);
    lab1->setMaximumWidth(65);
    auto lab2 = new QLabel(QString("Симв:"), edit);
    lab2->setMaximumWidth(65);


    edit->addScrollBarWidget(combo2, Qt::AlignLeft);
    edit->addScrollBarWidget(lab2, Qt::AlignRight);
    edit->addScrollBarWidget(lab1, Qt::AlignRight);

    return edit;
}

void MainWindow::init_toolbars(){
    tool1 = new QToolBar();
    addToolBar(Qt::TopToolBarArea, tool1);
    tool1->setAllowedAreas(Qt::TopToolBarArea);
    tool1->setFloatable(false);

    butt = new QPushButton(QString("кнопка"));
    butt2 = new QPushButton(QString("ещё кнопка"));
    butt3 = new QPushButton(QString("+ кнопка"));
    tool1->addWidget(butt);
    tool1->addWidget(butt2);
    tool1->addSeparator();
    tool1->addWidget(butt3);
    tool1->addSeparator();

    combo = new QComboBox();
    combo->addItem(QString("Roflolisp"));
    combo->addItem(QString("DOS_Roflolisp"));
    tool1->addWidget(combo);

    tool2 = new QToolBar();
    addToolBar(Qt::TopToolBarArea, tool2);
    tool2->setAllowedAreas(Qt::TopToolBarArea);
    tool2->setFloatable(false);
    butt4 = new QPushButton(QString("функции"));
    butt5 = new QPushButton(QString("доп. функции"));
    tool2->addWidget(butt4);
    tool2->addWidget(butt5);
}

#include "Project/ProjectWidget.h"
#include "InterpretatorWidget.h"

void MainWindow::init_docks(){
    dock = new QDockWidget(QString("Файлы проекта"), this);
    dock->setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    dock->setWidget(new ProjectWidget(*t_project, this));
    dock->setFeatures(QDockWidget::DockWidgetMovable | QDockWidget::DockWidgetClosable);
    addDockWidget(Qt::LeftDockWidgetArea, dock);

    dock2 = new QDockWidget(QString("Консоль"), this);
    dock2->setAllowedAreas(Qt::AllDockWidgetAreas);
    dock2->setWidget(new InterpretatorWidget(*t_project, this));
    dock2->setFeatures(QDockWidget::DockWidgetMovable | QDockWidget::DockWidgetClosable);
    addDockWidget(Qt::BottomDockWidgetArea, dock2);
}

void MainWindow::init_tabs(){
    tabWidget->removeTab(1);
    tabWidget->removeTab(0);
    tabWidget->setTabsClosable(true);
    tabWidget->setUsesScrollButtons(true);
    tabWidget->setMovable(true);

    tabWidget->addTab(edits[0], QString("roflolisp"));
    tabWidget->addTab(edits[1], QString("roflolisp2"));
}

void MainWindow::on_tabWidget_tabCloseRequested(int index)
{
    tabWidget->removeTab(index);
    delete edits[index];            //после передвижения вкладок работает некорректно
    edits.removeAt(index);
}

void MainWindow::on_action_29_triggered()
{
    dock->show();
}

void MainWindow::on_action_30_triggered()
{
    dock2->show();
}

void MainWindow::on_action_triggered()
{
    auto new_edit = init_editor();
    edits.push_back(new_edit);
    tabWidget->addTab(edits.last(), QString("roflolisp_name"));
}

void MainWindow::on_tabWidget_tabBarDoubleClicked(int index)   //не работает по причине автоматически маленький тулбар
{
    if(index == -1){
        action->trigger();
    }
}
