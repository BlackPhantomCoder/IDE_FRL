#include "MainWindow.h"
#include "LexerLisp.h"
MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent)
{
    setupUi(this);

    textEdit = new QsciScintilla; // инитилизируем редактор
    //textEdit->setUtf8(true); // мы же хотим читать кириллицу
    setCentralWidget(textEdit); // задаем редактор в ui
    auto* lex = new LexerLisp(this); // создаем лексер (схему подсветки)
    textEdit->setLexer(lex); // задаем С++ лексер нашему редактору
}
