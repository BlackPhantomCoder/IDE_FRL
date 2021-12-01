#ifndef INTERPRETATORWIDGET2_H
#define INTERPRETATORWIDGET2_H

#include "ui_InterpretatorWidget.h"

#include "Interpretator.h"
#include "Project/Project.h"

class InterpretatorWidget : public QMainWindow, private Ui::InterpretatorWidget
{
    Q_OBJECT

public:
    explicit InterpretatorWidget(QWidget *parent = nullptr);
    ~InterpretatorWidget();


    Project* get_project();
    bool is_running() const;

    bool start_interpretator_w_answear();
    bool stop_interpretator_w_answear();

signals:
    void project_changed();

    void changed_state();
    void started();
    void stopped();

public slots:
    void set_project(Project* project);
    void start_interpretator();
    void stop_interpretator();
    void clear();

     void send(const QString& str, bool new_line = true);


private slots:
    void on_finished();

    void t_send();

    void on_response(const QString& input);


private:
    void t_change_state();
private:
    Interpretator* t_interpretator;
    Project* t_project;
};

#endif // INTERPRETATORWIDGET2_H
