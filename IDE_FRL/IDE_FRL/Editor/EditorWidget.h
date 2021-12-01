#ifndef EDITORWIDGET_H
#define EDITORWIDGET_H

#include <QtCore>
#include <QtWidgets>

#include "ui_EditorWidget.h"
#include "Qsci/qsciscintilla.h"
#include "Qsci/qscilexercpp.h"
#include <set>
class SExprAction;

class EditorWidget : public QWidget, private Ui::EditorWidget
{
    Q_OBJECT

public:
        enum class tab_pos {back};
public:
    explicit EditorWidget(QWidget *parent = nullptr);

    QString get_sexpr();
    int tabs_count();

public slots:
    //предполагаем что тексты уникальны -> нужно переделать в пути к файлам абсолютые + возможно(относительные)
    void close_tab(const QString& text);
    void close_tab(int index);
    void open_new_tab(const QString& text, tab_pos pos);
    void set_sexpr_menu(QMenu* menu);

private slots:
    void on_tabWidget_tabCloseRequested(int index);
    void on_tabWidget_tabBarDoubleClicked(int index);

    void t_tab_removed(int index);

    void t_sexpr_apply(QAction* act, const QString& str);
private:
    QStringList t_pathes;
    QsciScintilla* init_editor();

    //хранилище SExprAction
    QMenu* t_s_expr_actions = nullptr;
};

#endif // EDITORWIDGET_H
