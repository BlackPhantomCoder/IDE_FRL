#include "EditorWidget.h"

#include "LexerLisp.h"

#include "Interpretator/SExprSeller.h"

EditorWidget::EditorWidget(QWidget *parent) :
    QWidget(parent)
{
    setupUi(this);

    tabWidget->removeTab(1);
    tabWidget->removeTab(0);

    tabWidget->setTabsClosable(true);
    tabWidget->setUsesScrollButtons(true);
    tabWidget->setMovable(true);

    connect(tabWidget, &QTabWidget::tabCloseRequested, this, &EditorWidget::t_tab_removed);
}

QString EditorWidget::get_sexpr()
{
    return "stroka";
}

int EditorWidget::tabs_count()
{
    return tabWidget->count();
}

void EditorWidget::close_tab(const QString &text)
{
    if(t_pathes.contains(text)){
        auto index = t_pathes.indexOf(text);
        tabWidget->removeTab(index);
        t_pathes.removeAt(index);
    }
}

void EditorWidget::close_tab(int index)
{
    if(index < tabs_count())
        tabWidget->removeTab(index);
    else
        throw "invalid index";
}

void EditorWidget::open_new_tab(const QString &text, EditorWidget::tab_pos pos)
{
    switch (pos) {
    case tab_pos::back:
        if(t_pathes.contains(text)){
            auto index = t_pathes.indexOf(text);
            tabWidget->setCurrentIndex(index);
        }
        else{
            auto index = tabWidget->addTab(init_editor(), text);
            t_pathes.insert(index, text);
        }
        break;
    default:
        break;
    }
}

void EditorWidget::set_sexpr_menu(QMenu *menu)
{
    t_s_expr_actions = menu;
    //заготовка для отправки с-выражений
    connect(t_s_expr_actions, &QMenu::triggered, [this](QAction* act){ t_sexpr_apply(act, get_sexpr());});
}


void EditorWidget::on_tabWidget_tabCloseRequested(int index)
{
    close_tab(index);
}

void EditorWidget::on_tabWidget_tabBarDoubleClicked(int index)   //не работает по причине автоматически маленький тулбар
{
    if(index == -1){
        //action->trigger();
    }
}

void EditorWidget::t_tab_removed(int index)
{
    t_pathes.removeAt(index);
}

void EditorWidget::t_sexpr_apply(QAction *act, const QString &str)
{
    auto* sexpr = static_cast<SExprAction*>(act);
    sexpr->apply(str);
}

QsciScintilla* EditorWidget::init_editor(){
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
