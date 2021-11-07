#include "InterpretatorWidget.h"
#include <QMessageBox>

using namespace std;
InterpretatorWidget::InterpretatorWidget(Project &project, QWidget *parent) :
    QMainWindow(parent),
    t_project(&project)
{
    setupUi(this);
    t_finish_state = true;
}

InterpretatorWidget::~InterpretatorWidget()
{
    t_change_state(false);
    if(t_interpretator){
        disconnect(t_interpretator.get(), &Interpretator::response, this, &InterpretatorWidget::on_response);
        t_interpretator->stop();
    }
}

void InterpretatorWidget::on_start_triggered()
{
   t_interpretator = make_unique<Interpretator>(t_project->interpretator_path(), t_project->interpretator_params());
   connect(t_interpretator.get(), &Interpretator::finished, this, &InterpretatorWidget::on_finished);
   auto result = t_interpretator->run();
   if(!result){
        QMessageBox::warning(this, "Внимание","Ошибка запуска");
        return;
   }
   connect(t_interpretator.get(), &Interpretator::response, this, &InterpretatorWidget::on_response);

   t_change_state(true);
}

void InterpretatorWidget::on_stop_triggered()
{
        t_change_state(false);
    auto result = t_interpretator->stop();
    if(!result){
         auto ans = QMessageBox::warning(this, "Внимание", "Интерпретатор не отвечает.\nЗавершить принудительно?", QMessageBox::Ok | QMessageBox::Cancel);
         if(ans == QMessageBox::Ok){
            t_interpretator->kill();
         }
         else{
             t_change_state(true);
             return;
         }

    }
    t_interpretator = {};
}

void InterpretatorWidget::on_finished()
{
    if(t_finish_state){
         QMessageBox::warning(this, "Внимание","Интерпретатор закончил свою работу");
         t_change_state(false);
    }
}

void InterpretatorWidget::on_pushButton_clicked()
{
    output->setText(output->text() + input->text() +"\n");
    t_interpretator->send(input->text());
    input->clear();
}

void InterpretatorWidget::on_response(const QString &input)
{
    output->setText(output->text() + input);
}

void InterpretatorWidget::t_change_state(bool processing)
{
    stop->setEnabled(processing);
    start->setEnabled(!processing);
    pushButton->setEnabled(processing);
    input->setEnabled(processing);
    t_finish_state = processing;
}
