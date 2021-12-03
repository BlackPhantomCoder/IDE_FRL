#include "ProjectEditorWidget.h"
#include "Settings/MyQApp.h"

ProjectEditorWidget::ProjectEditorWidget(Project* project, QWidget *parent) :
    QDialog(parent),
    t_project(project)
{
    setupUi(this);

    auto interpretators = MyQApp::interpretator_settings().all_names();

    name_input->setText(t_project->project_name());
    interpretator_input->clear();

    auto it = interpretators.indexOf(t_project->interpretator_name());
    if(it < 0){
        interpretators.push_front(t_project->interpretator_name() + "(не найден)");
        it = 0;
    }
    interpretator_input->addItems(interpretators);
    interpretator_input->setCurrentIndex(it);
    t_default_index = it;

    connect(cancel_btn, &QPushButton::clicked, this, &ProjectEditorWidget::reject);
}

void ProjectEditorWidget::on_save_btn_clicked()
{
    if(interpretator_input->currentIndex() != t_default_index){
        t_project->set_interpretator_name(interpretator_input->currentText());
    }
    t_project->set_project_name(name_input->text());
    save_btn->setEnabled(false);
    accept();
}
