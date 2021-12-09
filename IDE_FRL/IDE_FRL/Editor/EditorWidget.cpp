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

    //connect(tabWidget, &QTabWidget::tabCloseRequested, this, &EditorWidget::t_tab_removed);
    connect(tabWidget, &QTabWidget::currentChanged, this, &EditorWidget::change_bufer);

}

QString EditorWidget::get_sexpr()
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    int line, index;

    cur_edit->getCursorPosition(&line, &index);
    cur_edit->selectToMatchingBrace();
    QString str = cur_edit->selectedText();
    str = str.simplified();
    cur_edit->setSelection(line, index,line, index);

    if(str[0] != '('){
        str.push_front('(');
        str.push_back(')');
    }
    return str;
}

int EditorWidget::tabs_count()
{
    return tabWidget->count();
}

QTabWidget *EditorWidget::get_tab_widget()
{
    return tabWidget;
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
    {
        auto indexp = t_pathes.indexOf(tabWidget->tabText(index));
        t_pathes.removeAt(indexp);
        tabWidget->removeTab(index);
    }
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
            t_pathes.push_back(text);
            auto ed = init_editor();
            tabWidget->addTab(ed, text);

            //заполнение текстом
            QString proj_path = emit need_proj_path();
            proj_path += "/" + t_pathes.last();
            QFile file(proj_path);
            file.open(QIODevice::ReadOnly | QIODevice::Text);
            QString doc_text = "";
            doc_text = QString::fromUtf8(file.readAll());
            ed->append(doc_text);
            buf = doc_text;
            file.close();
            tabWidget->setCurrentWidget(ed);
            QPixmap pix(QSize(1,1));
            QBitmap bmp(QSize(1,1));
            bmp.fill();
            pix.setMask(bmp);
            tabWidget->setTabIcon(tabWidget->currentIndex(), QIcon(pix));
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
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->widget(index));
    QString txt = cur_edit->text();
    QString path = emit need_proj_path();
    path += "/" + tabWidget->tabText(index);
    //qDebug() << path;
    QFile file(path);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString doc_text = "";
    doc_text = QString::fromUtf8(file.readAll());
    file.close();
    if(txt != doc_text) {
        auto ans = QMessageBox::warning(this, tr("Внимание"),
                                        tr("Файл ") + tabWidget->tabText(index) + tr(" не сохранён, сохранить?"),
                                       QMessageBox::No|QMessageBox::Ok);
        if(ans == QMessageBox::Ok){
            QFile file(path);
            file.open(QIODevice::WriteOnly | QIODevice::Text);
            file.write(txt.toUtf8());
            file.close();
            //qDebug() << "sohranil";
        }
        if(ans == QMessageBox::No){
            //qDebug() << "ne sohranil";
        }
    }
    if(tabs_count() == 1){
        delete context;
        context = nullptr;
    }
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
void EditorWidget::ShowContextMenu(const QPoint &pos)
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    context = cur_edit->createStandardContextMenu();

    auto acts = context->actions();

    acts.at(0)->setText(tr("Отменить"));
    acts.at(1)->setText(tr("Повторить"));
    acts.at(3)->setText(tr("Вырезать"));
    acts.at(4)->setText(tr("Копировать"));
    acts.at(5)->setText(tr("Вставить"));
    acts.at(6)->setText(tr("Удалить"));
    acts.at(8)->setText(tr("Выделить всё"));

    context->exec(cur_edit->viewport()->mapToGlobal(pos));
}

void EditorWidget::set_margin_width()
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    int lns = cur_edit->lines();
    QString width = "00";
    for(int i = 0; lns > 9; ++i){
        lns /= 10;
        width += "0";
    }
    cur_edit->setMarginWidth(0, width);// Устанавливаем ширину поля
}

void EditorWidget::cursor_coord(int line, int index)
{
    lab1->setText(QString("Стр.: ") + QString::number(line+1));
    lab2->setText(QString("Симв.: ") + QString::number(index));
}

void EditorWidget::control_font_size(const QString &text)
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    if(text == "30%") cur_edit->zoomTo(-10);
    else if(text == "50%") cur_edit->zoomTo(-7);
    else if(text == "75%") cur_edit->zoomTo(-3);
    else if(text == "100%") cur_edit->zoomTo(0);
    else if(text == "115%") cur_edit->zoomTo(2);
    else if(text == "140%") cur_edit->zoomTo(6);
    else if(text == "175%") cur_edit->zoomTo(10);
    else if(text == "200%") cur_edit->zoomTo(14);
}

void EditorWidget::control_combo2()
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    int zoom = cur_edit->SendScintilla(QsciScintillaBase::SCI_GETZOOM);
    if(zoom == -10) {if(combo2->currentText() != "30%") combo2->setCurrentText(tr("30%"));}
    else if(zoom == -7) {if(combo2->currentText() != "50%") combo2->setCurrentText(tr("50%"));}
    else if(zoom == -3) {if(combo2->currentText() != "75%") combo2->setCurrentText(tr("75%"));}
    else if(zoom == 0) {if(combo2->currentText() != "100%") combo2->setCurrentText(tr("100%"));}
    else if(zoom == 2) {if(combo2->currentText() != "115%") combo2->setCurrentText(tr("115%"));}
    else if(zoom == 6) {if(combo2->currentText() != "140%") combo2->setCurrentText(tr("140%"));}
    else if(zoom == 10) {if(combo2->currentText() != "175%") combo2->setCurrentText(tr("175%"));}
    else if(zoom == 14) {if(combo2->currentText() != "200%") combo2->setCurrentText(tr("200%"));}
}

void EditorWidget::control_set_sexpr(int,int)
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    if(cur_edit->SendScintilla(QsciScintillaBase::SCI_BRACEMATCH,
                            cur_edit->SendScintilla(QsciScintillaBase::SCI_GETCURRENTPOS)) >= 0 ||
        cur_edit->SendScintilla(QsciScintillaBase::SCI_BRACEMATCH,
                            cur_edit->SendScintilla(QsciScintillaBase::SCI_POSITIONBEFORE,
                            cur_edit->SendScintilla(QsciScintillaBase::SCI_GETCURRENTPOS))) >= 0)
    {
        auto acts = t_s_expr_actions->actions();
        for(auto& x: acts){
            x->setEnabled(true);
        }
    }
    else{
        auto acts = t_s_expr_actions->actions();
        for(auto& x: acts){
            x->setEnabled(false);
        }
    }
}

void EditorWidget::control_saved_state()
{
    auto cur_edit = static_cast<QsciScintilla*>(tabWidget->currentWidget());
    if(cur_edit){
        if(cur_edit->text() == buf){
            QPixmap pix(QSize(1,1));
            QBitmap bmp(QSize(1,1));
            bmp.fill();
            pix.setMask(bmp);
            tabWidget->setTabIcon(tabWidget->currentIndex(), QIcon(pix));
        }
        else{
            tabWidget->setTabIcon(tabWidget->currentIndex(), style()->standardIcon(QStyle::SP_MessageBoxWarning));
        }
    }
}

void EditorWidget::change_bufer(int n)
{
    if(n>=0)
    {
        QString proj_path = emit need_proj_path();
        proj_path += "/" + tabWidget->tabText(n);
        QFile file(proj_path);
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        QString doc_text = "";
        doc_text = QString::fromUtf8(file.readAll());
        buf = doc_text;
        file.close();
    }
}

void EditorWidget::update_bufer()
{
    change_bufer(tabWidget->currentIndex());
}

QsciScintilla* EditorWidget::init_editor(){
    auto *edit = new QsciScintilla; // инитилизируем редактор
    edit->setUtf8(true); // мы же хотим читать кириллицу

    //меню
    context = edit->createStandardContextMenu();
    auto acts = context->actions();

    acts.at(0)->setText(tr("Отменить"));
    acts.at(1)->setText(tr("Повторить"));
    acts.at(3)->setText(tr("Вырезать"));
    acts.at(4)->setText(tr("Копировать"));
    acts.at(5)->setText(tr("Вставить"));
    acts.at(6)->setText(tr("Удалить"));
    acts.at(8)->setText(tr("Выделить всё"));

    edit->setContextMenuPolicy( Qt::CustomContextMenu );
    connect(edit, SIGNAL(customContextMenuRequested(const QPoint &)),
                this, SLOT(ShowContextMenu(const QPoint &)));
    connect(edit, SIGNAL(linesChanged()),
                this, SLOT(set_margin_width()));
    connect(edit, SIGNAL(cursorPositionChanged(int, int)),
                this, SLOT(control_set_sexpr(int, int)));
    connect(edit, SIGNAL(textChanged()),
                this, SLOT(control_saved_state()));


    auto* lex = new LexerLisp(this); // создаем лексер (схему подсветки)
    lex->setDefaultFont(QFont("Consolas", 14));

    //скобки
    edit->setBraceMatching(QsciScintilla::SloppyBraceMatch);
    edit->setMatchedBraceBackgroundColor(QColor(200,200,250));
    edit->setMatchedBraceForegroundColor(Qt::white);

    edit->setUnmatchedBraceBackgroundColor(QColor(250,150,150));
    edit->setUnmatchedBraceForegroundColor(Qt::white);


    edit->setLexer(lex); // задаем лексер нашему редактору
    edit->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOn);

    //микронастройки едитора
    edit->setMarginType(0,QsciScintilla::NumberMargin);// Установить номер строки для отображения на полях 0.
    edit->setMarginLineNumbers(0,true);// Включить номера строк для этого поля
    edit->setMarginWidth(0, "00");// Устанавливаем ширину поля

    edit->setIndentationsUseTabs(false);
    edit->setTabWidth(4);
    edit->setIndentationGuides(true);
    edit->setTabIndents(true);
    edit->setAutoIndent(true);
    connect(edit, SIGNAL(SCN_ZOOM()),
                this, SLOT(set_margin_width()));

    //автокомплит
    edit->setAutoCompletionSource(QsciScintilla::AcsAll);
    edit->setAutoCompletionThreshold(6);
    edit->setAutoCompletionCaseSensitivity(false);
    edit->setAutoCompletionReplaceWord(false);
    edit->setAutoCompletionUseSingle(QsciScintilla::AcusNever);

    auto api = new QsciAPIs(lex);
    auto keyws = (QString(lex->keywords(1)) + tr(" ") + QString(lex->keywords(2))).split(" ");
    for(auto& k : keyws){
        api->add(k);
    }
    api->prepare();

    connect(edit, SIGNAL(textChanged()),
                edit, SLOT(autoCompleteFromAll()));

    //масштаб
    combo2 = new QComboBox(edit);
    combo2->addItem(QString("30%"));
    combo2->addItem(QString("50%"));
    combo2->addItem(QString("75%"));
    combo2->addItem(QString("100%"));
    combo2->addItem(QString("115%"));
    combo2->addItem(QString("140%"));
    combo2->addItem(QString("175%"));
    combo2->addItem(QString("200%"));
    combo2->setCurrentText(QString("100%"));
    combo2->setMaximumWidth(65);
    connect(combo2, SIGNAL(currentTextChanged(const QString&)),
                this, SLOT(control_font_size(const QString&)));
    connect(edit, SIGNAL(SCN_ZOOM()),
                this, SLOT(control_combo2()));

    //строка/символ
    lab1 = new QLabel(QString("Стр: "), edit);
    lab1->setMaximumWidth(65);
    lab2 = new QLabel(QString("Симв: "), edit);
    lab2->setMaximumWidth(65);
    connect(edit, SIGNAL(cursorPositionChanged(int, int)),
                this, SLOT(cursor_coord(int, int)));


    edit->setEolMode(QsciScintilla::EolUnix);  //??? челы попутали названия
    edit->addScrollBarWidget(combo2, Qt::AlignLeft);
    edit->addScrollBarWidget(lab2, Qt::AlignRight);
    edit->addScrollBarWidget(lab1, Qt::AlignRight);

    return edit;
}
