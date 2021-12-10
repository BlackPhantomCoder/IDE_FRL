#include "IDESettingsEditor.h"

#include "Settings/MyQApp.h"


IDESettingsEditor::IDESettingsEditor(QWidget *parent) :
    QDialog(parent)
{
    setupUi(this);

    t_intpath_now_path = MyQApp::now_int_settings_path();
    t_intpath_def_path = MyQApp::default_int_settings_path();

    intpath_custom->setChecked(t_intpath_now_path != t_intpath_def_path);
    t_intpath_change_state(
                t_intpath_now_path != t_intpath_def_path,
                (t_intpath_now_path != t_intpath_def_path) ? t_intpath_now_path: t_intpath_def_path
    );

    connect(intpath_custom, &QCheckBox::stateChanged, this, &IDESettingsEditor::t_intpath_state_changed);
    connect(intpath_chose, &QPushButton::clicked, this, &IDESettingsEditor::t_intpath_chose_path);
    connect(buttonBox, &QDialogButtonBox::accepted, this, &IDESettingsEditor::t_accept);
}

void IDESettingsEditor::t_accept()
{
    if(!t_intpath_accept()) return;
    //

    t_intpath_apply();
    accept();
}


void IDESettingsEditor::t_intpath_state_changed(int arg1)
{
    t_intpath_change_state(arg1 == Qt::CheckState::Checked);
}

void IDESettingsEditor::t_intpath_apply()
{
    auto path = intpath->text();
    if(t_intpath_now_path == path) return;


    auto copy = QMessageBox::question(
                this,
                "Путь к настройками интерпретатора",
                "Путь изменился. Скопировать старые настройки?",
                QMessageBox::StandardButton::Ok | QMessageBox::StandardButton::Cancel
    ) == QMessageBox::StandardButton::Ok;
//    auto reload = QMessageBox::question(
//                this,
//                "Путь к настройками интерпретатора",
//                "Путь изменился. Требуется перезагрузка. Выполнить?",
//                QMessageBox::StandardButton::Ok | QMessageBox::StandardButton::Cancel
//    ) == QMessageBox::StandardButton::Ok;


    QMessageBox::warning(
                this,
                "Путь к настройками интерпретатора",
                "Путь изменился. Требуется перезагрузка.",
                QMessageBox::StandardButton::Ok
    );
    if(!MyQApp::set_new_int_settings_path(path, copy)){
        QMessageBox::warning(
                    this,
                    "Внимание",
                    "Ошибка при изменении пути к настройкам интерпретатора",
                    QMessageBox::StandardButton::Ok
        );
    }

//    if(reload){
//        auto* obj = new restart_later();
//        obj->deleteLater();
//    }
}

bool IDESettingsEditor::t_intpath_accept()
{
    if(intpath_custom->checkState() != Qt::CheckState::Checked) return true;
    auto path = intpath->text();
    //qDebug() << path.mid(0, path.lastIndexOf("/")) <<endl;
    if(!QDir(path.mid(0, path.lastIndexOf("/"))).exists()){
        QMessageBox::information(
                    this,
                    "Путь к настройками интерпретатора",
                    "Несуществующая папка",
                    QMessageBox::StandardButton::Ok
        );
        return false;
    }
    if(path.mid(path.lastIndexOf("/"), path.size()).isEmpty()){
        QMessageBox::information(
                    this,
                    "Путь к настройками интерпретатора",
                    "Недопустимое имя файла",
                    QMessageBox::StandardButton::Ok
        );
        return false;
    }
    return true;
}

void IDESettingsEditor::t_intpath_chose_path()
{
    auto s = QFileDialog::getOpenFileName(this, QString(), QString(), "*.json");
    if(!s.isEmpty()){
        intpath->setText(s);
    }
}

void IDESettingsEditor::t_intpath_reload_info()
{

}

void IDESettingsEditor::t_intpath_change_state(bool state, const QString& path)
{
    bool sauto = path.isEmpty();
    if(state){
        intpath_chose->setEnabled(true);
        intpath->setEnabled(true);
        intpath->setText((sauto) ? ((t_intpath_now_path != t_intpath_def_path) ? t_intpath_now_path: ""): t_intpath_now_path);
    }
    else{
        intpath_chose->setEnabled(false);
        intpath->setEnabled(false);
        intpath->setText((sauto) ? (t_intpath_def_path) : path);
    }
}
