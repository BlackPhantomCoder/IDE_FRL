#include "InterpretatorWidget.h"

#include "Settings/GlobalSettings.h"
#include <QMessageBox>
#include <QDebug>
#include <QScrollBar>

InterpretatorWidget::InterpretatorWidget(QWidget *parent):
    QMainWindow(parent),
    t_interpretator(nullptr),
    t_project(nullptr)
{
    setupUi(this);
    t_finish_state = true;

    connect(this, &InterpretatorWidget::started, this, &InterpretatorWidget::changed_state);
    connect(this, &InterpretatorWidget::stopped, this, &InterpretatorWidget::changed_state);
    connect(input, &QLineEdit::returnPressed, this, &InterpretatorWidget::t_send);
}

InterpretatorWidget::~InterpretatorWidget()
{
    t_change_state(false);
    if(t_interpretator){
        disconnect(t_interpretator, &Interpretator::response, this, &InterpretatorWidget::on_response);
        t_interpretator->stop();
        delete t_interpretator;
        t_interpretator = nullptr;
    }
}

bool InterpretatorWidget::is_running() const
{
    return !t_finish_state;
}

bool InterpretatorWidget::start_interpretator_w_answear()
{
    if(!t_project) return false;
    if(t_interpretator) throw "интерпретатор уже открыт";
    if(t_project->interpretator_name().isEmpty()){
        QMessageBox::warning(this, "Внимание","Интерпретатор не задан");
        return false;
    }
    if(!interpretator_settings().contains_interpretator(t_project->interpretator_name())){
        QMessageBox::warning(this, "Внимание","Неизвестный интерпретатор");
        return false;
    }
    t_interpretator = new Interpretator(interpretator_settings().get_interpretator(t_project->interpretator_name()), this);
    connect(t_interpretator, &Interpretator::finished, this, &InterpretatorWidget::on_finished);
    auto result = t_interpretator->run();
    if(!result){
         QMessageBox::warning(this, "Внимание","Ошибка запуска");
         delete t_interpretator;
         t_interpretator = nullptr;
         return false;
    }
    connect(t_interpretator, &Interpretator::response, this, &InterpretatorWidget::on_response);

    t_change_state(true);
    emit started();
    return true;
}

bool InterpretatorWidget::stop_interpretator_w_answear()
{
    if(!t_interpretator) return false;
    auto result = t_interpretator->stop();
    t_change_state(false);
    if(!result){
         auto ans = QMessageBox::warning(this, "Внимание", "Интерпретатор не отвечает.\nЗавершить принудительно?", QMessageBox::Ok | QMessageBox::Cancel);
         if(ans == QMessageBox::Ok){
            t_interpretator->kill();
         }
         else{
             t_change_state(true);
             return false;
         }

    }
    delete t_interpretator;
    t_interpretator = nullptr;
    emit stopped();
    return true;
}

void InterpretatorWidget::set_project(Project *project)
{
    t_project = project;
    emit project_changed();
}

void InterpretatorWidget::start_interpretator()
{
    start_interpretator_w_answear();
}

void InterpretatorWidget::stop_interpretator()
{
    stop_interpretator_w_answear();
}

void InterpretatorWidget::clear()
{
    output->clear();
    scrollArea->verticalScrollBar()->setSliderPosition(scrollArea->verticalScrollBar()->maximumHeight());
}

void InterpretatorWidget::on_finished()
{
    if(t_finish_state){
         QMessageBox::warning(this, "Внимание","Интерпретатор закончил свою работу");
         t_change_state(false);
         delete t_interpretator;
         t_interpretator = nullptr;
         emit stopped();
    }
}

void InterpretatorWidget::t_send()
{
    if(input->text().isEmpty()) return;
    output->setText(output->text() + input->text() +"\n");
    t_interpretator->send(input->text());
    input->clear();
    scrollArea->verticalScrollBar()->setSliderPosition(scrollArea->verticalScrollBar()->maximumHeight());
}

void InterpretatorWidget::on_response(const QString &input)
{
    output->setText(output->text() + input);
    scrollArea->verticalScrollBar()->setSliderPosition(scrollArea->verticalScrollBar()->maximumHeight());
}

void InterpretatorWidget::t_change_state(bool processing)
{
    input->setEnabled(processing);
    t_finish_state = !processing;
}
