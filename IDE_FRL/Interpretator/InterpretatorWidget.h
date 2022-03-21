#ifndef INTERPRETATORWIDGET2_H
#define INTERPRETATORWIDGET2_H

#include "ui_InterpretatorWidget.h"

#include "Interpretator.h"
#include "Project/Project.h"

#include <deque>

//Окно общения с интерпретатором
class InterpretatorWidget : public QMainWindow, private Ui::InterpretatorWidget
{
    Q_OBJECT

    static size_t maximum_last_sends;
public:
    explicit InterpretatorWidget(QWidget *parent = nullptr);
    ~InterpretatorWidget();


    Project* get_project();
    bool is_running() const;

    bool start_interpretator_w_answear();
    bool stop_interpretator_w_answear();

    bool clear_state() const;
    unsigned get_font_size() const;


signals:
    void project_changed();

    void changed_state();
    void started();
    void stopped();

    void clear_state_changed(bool new_state);

    void command_buf_clear_state_changed(bool not_cleared);
    void font_size_change();

public slots:
    void set_project(Project* project);
    void start_interpretator();
    void stop_interpretator();
    void clear();

    void send(const QString& str, bool silence_mode = false, bool new_line = true);

    void command_buf_clear();
    void set_font_size(unsigned val);



private slots:
    void on_finished();

    void t_send();

    void on_response(const QString& input);

    void t_set_last_send_up();
    void t_set_last_send_down();


private:
    void t_change_state();
private:
    Interpretator* t_interpretator;
    Project* t_project;

    bool t_clear_state = true;
    std::deque<QString> t_last_sends;
    bool t_last = false;
    size_t t_last_index = 0;


};

#endif // INTERPRETATORWIDGET2_H
