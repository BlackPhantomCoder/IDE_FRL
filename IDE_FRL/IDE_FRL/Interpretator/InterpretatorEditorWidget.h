#ifndef INTERPRETATOREDITORWIDGET_H
#define INTERPRETATOREDITORWIDGET_H

#include <QObject>
#include "Interpretator/Interpretator.h"
#include "ui_InterpretatorEditorWidget.h"

class InterpretatorCreatorWidget: public QDialog, public Ui_Dialog
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
