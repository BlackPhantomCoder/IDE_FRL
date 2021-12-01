#include "InterpretatorWidget.h"

#include "Settings/MyQApp.h"
#include <QMessageBox>
#include <QDebug>
#include <QScrollBar>

InterpretatorWidget::InterpretatorWidget(QWidget *parent):
    QMainWindow(parent),
    t_interpretator(nullptr),
    t_project(nullptr)
{
    setupUi(this);

    connect(this, &InterpretatorWidget::started, this, &InterpretatorWidget::changed_state);
    connect(this, &InterpretatorWidget::stopped, this, &InterpretatorWidget::changed_state);
    connect(input, &QLineEdit::returnPressed, this, &InterpretatorWidget::t_send);

    QObject::connect(scrollArea->verticalScrollBar(), &QScrollBar::rangeChanged,
                     [this](){scrollArea->verticalScrollBar()->setSliderPosition(scrollArea->verticalScrollBar()->maximum());});
}

InterpretatorWidget::~InterpretatorWidget()
{
    if(is_running()){
        disconnect(t_interpretator, &Interpretator::response, this, &InterpretatorWidget::on_response);
        auto result = t_interpretator->stop();
        if(!result)t_interpretator->kill();
        delete t_interpretator;
        t_interpretator = nullptr;
    }
}

bool InterpretatorWidget::is_running() const
{
    return t_interpretator && t_interpretator->is_runing();
}

bool InterpretatorWidget::start_interpretator_w_answear()
{
    if(!t_project) return false;
    if(t_interpretator) throw "интерпретатор уже открыт";
    if(t_project->interpretator_name().isEmpty()){
        QMessageBox::warning(this, "Внимание","Интерпретатор не задан");
        return false;
    }
    if(!MyQApp::interpretator_settings().contains_interpretator(t_project->interpretator_name())){
        QMessageBox::warning(this, "Внимание","Неизвестный интерпретатор");
        return false;
    }
    t_interpretator = new Interpretator(MyQApp::interpretator_settings().get_interpretator(t_project->interpretator_name()), this);
    connect(t_interpretator, &Interpretator::finished, this, &InterpretatorWidget::on_finished);
    auto result = t_interpretator->run();
    if(!result){
         QMessageBox::warning(this, "Внимание","Ошибка запуска");
         delete t_interpretator;
         t_interpretator = nullptr;
         return false;
    }
    connect(t_interpretator, &Interpretator::response, this, &InterpretatorWidget::on_response);

    t_change_state();
    emit started();
    return true;
}

bool InterpretatorWidget::stop_interpretator_w_answear()
{
    if(!is_running()) return false;
    disconnect(t_interpretator, &Interpretator::finished, this, &InterpretatorWidget::on_finished);
    auto result = t_interpretator->stop();
    if(!result){
         auto ans = QMessageBox::warning(this, "Внимание", "Интерпретатор не отвечает.\nЗавершить принудительно?", QMessageBox::Ok | QMessageBox::Cancel);
         if(ans == QMessageBox::Ok){
            t_interpretator->kill();
         }
         else{
             return false;
         }

    }
    t_change_state();
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

void InterpretatorWidget::send(const QString &str, bool new_line)
{
    if(is_running()){
        if(str.isEmpty()) return;
        output->setText(output->text() + str + ((new_line) ? "\n": ""));
        t_interpretator->send(str);
    }
}

void InterpretatorWidget::on_finished()
{
    if(!is_running()){
         QMessageBox::warning(this, "Внимание","Интерпретатор закончил свою работу");
         delete t_interpretator;
         t_interpretator = nullptr;
    }
    t_change_state();
    emit stopped();
}

void InterpretatorWidget::t_send()
{
    send(input->text());
    input->clear();
}

void InterpretatorWidget::on_response(const QString &input)
{
    output->setText(output->text() + input);
}

void InterpretatorWidget::t_change_state()
{
    input->setEnabled(is_running());
}
