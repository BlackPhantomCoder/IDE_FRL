#ifndef IDESETTINGSEDITOR_H
#define IDESETTINGSEDITOR_H

#include "ui_IDESettingsEditor.h"

#include <QtCore>
#include <QtWidgets>

//Окно-Редактор настроек приложения
class IDESettingsEditor : public QDialog, private Ui::IDESettingsEditor
{
    Q_OBJECT

public:
    explicit IDESettingsEditor(QWidget *parent = nullptr);
private slots:
    void t_accept();

    void t_intpath_state_changed(int arg1);

private:

    void t_intpath_apply();
    bool t_intpath_accept();
    void t_intpath_chose_path();
    void t_intpath_reload_info();
    void t_intpath_change_state(bool state, const QString& path = "");
private:
    QString t_intpath_now_path;
    QString t_intpath_def_path;
};

#endif // IDESETTINGSEDITOR_H
