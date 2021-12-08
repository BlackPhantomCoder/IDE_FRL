#ifndef EDITORWIDGET_H
#define EDITORWIDGET_H

#include <QtCore>
#include <QtWidgets>
#include <QStyle>

#include "ui_EditorWidget.h"
#include "Qsci/qsciscintilla.h"
#include "Qsci/qscilexercpp.h"
#include "Qsci/qsciapis.h"
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
    QTabWidget* get_tab_widget();

public slots:
    //предполагаем что тексты уникальны -> нужно переделать в пути к файлам абсолютые + возможно(относительные)
    void close_tab(const QString& text);
    void close_tab(int index);
    void open_new_tab(const QString& text, tab_pos pos);
    void set_sexpr_menu(QMenu* menu);
    void set_margin_width();
    void control_saved_state();
    void update_bufer();
signals:
    //void edit_menu(QMenu*);
    QString need_proj_path();

private slots:
    void on_tabWidget_tabCloseRequested(int index);
    void on_tabWidget_tabBarDoubleClicked(int index);

    void t_tab_removed(int index);

    void t_sexpr_apply(QAction* act, const QString& str);

    void ShowContextMenu(const QPoint &pos);

    void cursor_coord(int, int);
    void control_font_size(const QString&);
    void control_combo2();
    void control_set_sexpr(int,int);
    void change_bufer(int);
private:
    QStringList t_pathes;
    QsciScintilla* init_editor();

    //хранилище SExprAction
    QMenu* t_s_expr_actions = nullptr;

    QMenu* context = nullptr;
    QComboBox* combo2 = nullptr;
    QLabel* lab1 = nullptr;
    QLabel* lab2 = nullptr;
    QString buf; //буфер сохранения
};

#endif // EDITORWIDGET_H
