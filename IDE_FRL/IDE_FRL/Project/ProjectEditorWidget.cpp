#include "ProjectEditorWidget.h"
#include "Settings/MyQApp.h"

ProjectEditorWidget::ProjectEditorWidget(Project* project, QWidget *parent) :
    QDialog(parent),
    t_project(project)
{
    setupUi(this);

    t_interetators = MyQApp::interpretator_settings().all_names();
    t_interetators.push_front("");

    t_from_project();

    connect(cancel_btn, &QPushButton::clicked, this, &ProjectEditorWidget::reject);
}

void ProjectEditorWidget::on_save_btn_clicked()
{
    t_project->set_project_name(name_input->text());
    auto input = interpretator_input->currentText();
    if(!input.isEmpty())
        t_project->set_interpretator_name(input);
}

void ProjectEditorWidget::on_cancel_btn_clicked()
{
    t_from_project();
}

void ProjectEditorWidget::t_from_project()
{
    name_input->setText(t_project->project_name());
    interpretator_input->clear();
    interpretator_input->addItems(t_interetators);
    auto ind = t_interetators.indexOf(t_project->interpretator_name());
    interpretator_input->setCurrentIndex(((ind< 0) ? 0 : ind));
}
