#include "MainWidget.h"

MainWidget::MainWidget( QWidget *parent) :
    QMainWindow(parent)
{
    setCorner(Qt::BottomLeftCorner, Qt::LeftDockWidgetArea);
    setCorner(Qt::TopLeftCorner, Qt::LeftDockWidgetArea);
    setCorner(Qt::BottomRightCorner, Qt::RightDockWidgetArea);
    setCorner(Qt::TopRightCorner, Qt::RightDockWidgetArea);

    t_dock_left = t_create_dock();
    t_dock_right = t_create_dock();
    t_dock_bottom = t_create_dock();

    addDockWidget(Qt::LeftDockWidgetArea, t_dock_left);
    addDockWidget(Qt::RightDockWidgetArea, t_dock_right);
    addDockWidget(Qt::BottomDockWidgetArea, t_dock_bottom);

    connect(t_dock_left, &QDockWidget::visibilityChanged, [this](){emit side_widget_state_changed(doks_type::left);});
    connect(t_dock_right, &QDockWidget::visibilityChanged, [this](){emit side_widget_state_changed(doks_type::right);});
    connect(t_dock_bottom, &QDockWidget::visibilityChanged, [this](){emit side_widget_state_changed(doks_type::bottom);});
}

QWidget *MainWidget::get_side_widget(MainWidget::doks_type type)
{
    return t_dock_by_side(type);
}

MainWidget::doks_state MainWidget::get_side_widget_state(MainWidget::doks_type type)
{
    return (t_dock_by_side(type)->isHidden()) ? doks_state::hidden :  doks_state::show;
}

QString MainWidget::get_side_widget_text(MainWidget::doks_type type)
{
    return t_dock_by_side(type)->windowTitle();
}

void MainWidget::set_side_widget(MainWidget::doks_type type, QWidget *widget, doks_state state)
{
    auto* w =t_dock_by_side(type);
    w->setWidget(widget);
    set_side_widget_state(type, state);
    emit side_widget_changed(type);
}

void MainWidget::set_side_widget_state(MainWidget::doks_type type, MainWidget::doks_state state)
{
    auto* w = t_dock_by_side(type);
    if((w->isHidden() && state != doks_state::hidden) || (!w->isHidden() && state == doks_state::hidden)){
        if(state == doks_state::hidden)
            w->setHidden(true);
        else
            w->setHidden(false);
    }
}

void MainWidget::set_side_widget_text(MainWidget::doks_type type, const QString &text)
{
    t_dock_by_side(type)->setWindowTitle(text);
    emit side_widget_text_changed(type);
}

QDockWidget *MainWidget::t_dock_by_side(MainWidget::doks_type type)
{
    switch (type) {
        case doks_type::bottom:
            return t_dock_bottom;
        case doks_type::left:
            return t_dock_left;
        case doks_type::right:
            return t_dock_right;
        default:
            throw "unknown doks_type";
    }
}

QDockWidget* MainWidget::t_create_dock()
{
    auto* dock = new QDockWidget(QString(""), this);
    dock->setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    dock->setFeatures(QDockWidget::DockWidgetMovable | QDockWidget::DockWidgetClosable);
    return dock;
}
