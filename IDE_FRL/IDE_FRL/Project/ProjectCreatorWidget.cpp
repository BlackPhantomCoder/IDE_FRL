#include "ProjectCreatorWidget.h"

#include <QFile>
#include <QDir>
#include <QMessageBox>
#include <QFileDialog>

#include "Settings/MyQApp.h"
#include "Project.h"

ProjectCreatorWidget::ProjectCreatorWidget(QWidget *parent) :
    QDialog(parent)
{
    setupUi(this);

    t_interetators = MyQApp::interpretator_settings().all_names();

    interpretator_chose->addItems(t_interetators);

    connect(cancel_btn, &QPushButton::clicked, this, &QDialog::reject);
    connect(create_btn, &QPushButton::clicked, this, &ProjectCreatorWidget::t_check_accept);
    connect(path_to_dir_btn, &QPushButton::clicked, this, &ProjectCreatorWidget::t_get_file_path);
}

QString ProjectCreatorWidget::path()
{
    return t_get_dir() + t_get_name() + ".json";
}

QString ProjectCreatorWidget::t_get_name()
{
    return project_name->text();
}

QString ProjectCreatorWidget::t_get_dir()
{
    return project_dir->text();
}

QString ProjectCreatorWidget::t_get_interpretator()
{
    return interpretator_chose->currentText();
}

void ProjectCreatorWidget::t_check_accept()
{
    auto name = t_get_name();
    auto dir_path = t_get_dir();
    auto file_path = path();
    auto interpretator = t_get_interpretator();

    if(dir_path.isEmpty()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Введите имя папки проекта"),
                                      QMessageBox::Ok);
         return;
    }

    dir_path += "/";

    if(t_get_name().isEmpty()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Введите имя файла проекта"),
                                      QMessageBox::Ok);
         return;
    }

    if(interpretator.isEmpty()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Не задан интерпретатор"),
                                      QMessageBox::Ok);
        return;
    }


    QDir dir(dir_path);
    if(!dir.exists()){
        auto result = dir.mkpath(dir_path);
        if(!result){
            QMessageBox::warning(this, tr("Внимание"),
                                           tr("Ошибка создания папки"),
                                          QMessageBox::Ok);
            return;
        }
    }


    QFile file(file_path);
    if(file.exists()){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Файл уже существует"),
                                      QMessageBox::Ok);
        return;
    }
    auto result = file.open(QIODevice::WriteOnly);
    file.close();
    if(!result){
        QMessageBox::warning(this, tr("Внимание"),
                                       tr("Ошибка создания файла"),
                                      QMessageBox::Ok);
        return;
    }

    auto p = new Project(file_path, this);
    p->set_project_name(name);
    p->set_interpretator_name(interpretator);
    p->save();
    delete p;

    accept();
}

void ProjectCreatorWidget::t_get_file_path()
{
    auto file_name = QFileDialog::getExistingDirectory(this,
        tr("Выберите папку"));
    if(file_name.isEmpty()) return;
    project_dir->setText(file_name);
}
