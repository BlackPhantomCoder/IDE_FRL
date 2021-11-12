#ifndef EDITORWIDGET_H
#define EDITORWIDGET_H

#include "ui_EditorWidget.h"

#include <QList>
#include "Qsci/qsciscintilla.h"
#include "Qsci/qscilexercpp.h"
#include <set>

class EditorWidget : public QWidget, private Ui::EditorWidget
{
    Q_OBJECT

public:
        enum class tab_pos {back};
public:
    explicit EditorWidget(QWidget *parent = nullptr);


    int tabs_count();

public slots:
    //предполагаем что тексты уникальны
    void close_tab(const QString& text);
    void close_tab(int index);
    void open_new_tab(const QString& text, tab_pos pos);

private slots:
    void on_tabWidget_tabCloseRequested(int index);
    void on_tabWidget_tabBarDoubleClicked(int index);

    void t_tab_removed(int index);
private:
    QStringList t_pathes;
    QsciScintilla* init_editor();
};

#endif // EDITORWIDGET_H
