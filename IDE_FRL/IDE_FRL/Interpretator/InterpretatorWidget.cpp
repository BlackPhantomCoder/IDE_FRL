#include "InterpretatorWidget.h"

#include "Settings/MyQApp.h"
#include <QMessageBox>
#include <QDebug>
#include <QScrollBar>

size_t InterpretatorWidget::maximum_last_sends = 255;

InterpretatorWidget::InterpretatorWidget(QWidget *parent):
    QMainWindow(parent),
    t_interpretator(nullptr),
    t_project(nullptr)
{
    setupUi(this);

    output->setTextInteractionFlags(Qt::TextSelectableByMouse);

    connect(this, &InterpretatorWidget::started, this, &InterpretatorWidget::changed_state);
    connect(this, &InterpretatorWidget::stopped, this, &InterpretatorWidget::changed_state);
    connect(input, &ExtendedLineEdit::returnPressed, this, &InterpretatorWidget::t_send);
    connect(input, &ExtendedLineEdit::KeyDownPressed, this, &InterpretatorWidget::t_set_last_send_up);
    connect(input, &ExtendedLineEdit::KeyUpPressed, this, &InterpretatorWidget::t_set_last_send_down);


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
    auto data = MyQApp::interpretator_settings().get_interpretator(t_project->interpretator_name());
    data.params.replace("($project_path)", t_project->dir_path());
    data.params.replace("($ide_path)", MyQApp::applicationDirPath());

    t_interpretator = new Interpretator(data, this);
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

bool InterpretatorWidget::clear_state() const
{
    return t_clear_state;
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
    //scrollArea->verticalScrollBar()->setSliderPosition(scrollArea->verticalScrollBar()->maximumHeight());
    t_clear_state = true;
    emit clear_state_changed(clear_state());
}

void InterpretatorWidget::send(const QString &str,  bool silence_mode, bool new_line)
{
    if(is_running()){
        if(str.isEmpty()) return;
        if(!silence_mode){
            output->setText(output->text() + str + ((new_line) ? "\n": ""));
            t_last_sends.push_back(str);
            if(t_last_sends.size() > maximum_last_sends){
                t_last_sends.pop_front();
            }
        }
        else{
            if(new_line)output->setText(output->text() + "\n");
        }
        t_interpretator->send(str, new_line);
        if(t_clear_state){
            t_clear_state = false;
            emit clear_state_changed(clear_state());
        }
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
    t_last = false;
}

void InterpretatorWidget::on_response(const QString &input)
{
    output->setText(output->text() + input);
    if(t_clear_state){
        t_clear_state = false;
        emit clear_state_changed(clear_state());
    }
}

void InterpretatorWidget::t_set_last_send_down()
{
    if(t_last_sends.empty()) return;
    if(!t_last || t_last_index == 0){
        input->setText(t_last_sends.back());
        t_last_index = t_last_sends.size() - 1;
        t_last = true;
        return;
    }

    --t_last_index;
    input->setText(t_last_sends[t_last_index]);
}

void InterpretatorWidget::t_set_last_send_up()
{
    if(t_last_sends.empty()) return;
    if(!t_last || (t_last_index == t_last_sends.size() - 1)){
        input->setText(t_last_sends.front());
        t_last_index = 0;
        t_last = true;
        return;
    }

    ++t_last_index;
    input->setText(t_last_sends[t_last_index]);
}


void InterpretatorWidget::t_change_state()
{
    input->setEnabled(is_running());
}
