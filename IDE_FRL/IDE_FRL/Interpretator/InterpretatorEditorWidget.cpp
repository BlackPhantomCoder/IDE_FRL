#include "InterpretatorEditorWidget.h"
#include "Settings/GlobalSettings.h"

#include <QMessageBox>
#include <QFileDialog>


InterpretatorCreatorWidget::InterpretatorCreatorWidget(const QString& name, const InterpretatorData& data, bool check_rewrite, QWidget *parent):
    QDialog(parent),
    t_check_rewrite(check_rewrite)
{
    setupUi(this);

    this->name->setText(name);
    params->setText(data.params);
    path->setText(data.path);

    connect(buttonBox, &QDialogButtonBox::accepted, this, &InterpretatorCreatorWidget::t_check_accept);
    connect(path_btn, &QPushButton::clicked, this, &InterpretatorCreatorWidget::t_get_file_path);
}

void InterpretatorCreatorWidget::t_check_accept()
{
    auto interpretator_name = name->text();
    auto interpretator_params = params->text();
    auto interpretator_path = path->text();

    if(interpretator_name.isEmpty()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Введите имя файла интерпретатора"),
                                      QMessageBox::Ok);
         return;
    }

    if(interpretator_path.isEmpty()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Введите путь к интерпретатору"),
                                      QMessageBox::Ok);
         return;
    }

    if(t_check_rewrite){
        auto exists = interpretator_settings().contains_interpretator(interpretator_name);
        if(exists){
            auto ans = QMessageBox::warning(this, tr("Внимание"),
                                           tr("Такой интерпертатор уже существет, перезаписать?"),
                                          QMessageBox::Ok| QMessageBox::Cancel);
            if(ans == QMessageBox::Cancel)
                return;
        }
    }
    if(!interpretator_settings().add_interpretator(interpretator_name, {interpretator_path, interpretator_params})){
        interpretator_settings().change_interpretator(interpretator_name, {interpretator_path, interpretator_params});
    }

    accept();
}

void InterpretatorCreatorWidget::t_get_file_path()
{
    auto file_name = QFileDialog::getOpenFileName(this,
        tr("Выберете файл"));
    if(file_name.isEmpty()) return;
    path->setText(file_name);
}
