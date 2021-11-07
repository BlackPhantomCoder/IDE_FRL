#ifndef INTERPRETATORWIDGET2_H
#define INTERPRETATORWIDGET2_H

#include "ui_InterpretatorWidget.h"

#include <memory>
#include "Interpretator.h"
#include "Project/Project.h"

class InterpretatorWidget : public QMainWindow, private Ui::InterpretatorWidget
{
    Q_OBJECT

public:
    explicit InterpretatorWidget(Project& project, QWidget *parent = nullptr);
    ~InterpretatorWidget();
private slots:
    void on_start_triggered();
    void on_stop_triggered();

    void on_finished();

    void on_pushButton_clicked();

    void on_response(const QString& input);

private:
    void t_change_state(bool processing);
private:
    std::unique_ptr<Interpretator> t_interpretator;
    Project* t_project;
    bool t_finish_state;
};

#endif // INTERPRETATORWIDGET2_H
