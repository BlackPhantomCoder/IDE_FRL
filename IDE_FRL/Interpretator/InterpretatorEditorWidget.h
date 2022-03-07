#ifndef INTERPRETATOREDITORWIDGET_H
#define INTERPRETATOREDITORWIDGET_H

#include "ui_InterpretatorEditorWidget.h"

#include <QtCore>
#include <QtWidgets>
#include "Interpretator/Interpretator.h"


class InterpretatorCreatorWidget: public QDialog, Ui::InterpretatorEditorDialog
{
    Q_OBJECT

public:
    InterpretatorCreatorWidget(const QString& name = "", const InterpretatorData& data = {},  bool check_rewrite = true, QWidget* parent = nullptr);
private slots:
    void t_check_accept();
    void t_get_file_path();
private:
    bool t_check_rewrite;
};

#endif // INTERPRETATOREDITORWIDGET_H
