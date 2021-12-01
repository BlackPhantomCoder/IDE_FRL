#include "MainWidowDocksControl.h"

#include "MainWindow.h"
#include "Settings/MyQApp.h"
#include <QtWidgets>

const auto areas = QSet{Qt::LeftDockWidgetArea, Qt::RightDockWidgetArea, Qt::BottomDockWidgetArea};

DocksControl::DocksControl(MainWindow *window):
    QObject(window),
    t_main(window)
{
    t_main->setCorner(Qt::BottomLeftCorner, Qt::LeftDockWidgetArea);
    t_main->setCorner(Qt::TopLeftCorner, Qt::LeftDockWidgetArea);
    t_main->setCorner(Qt::BottomRightCorner, Qt::RightDockWidgetArea);
    t_main->setCorner(Qt::TopRightCorner, Qt::RightDockWidgetArea);

    t_load_docks();
}

void DocksControl::save()
{
    auto& s = MyQApp::global_settings();
    AT_GROUP(s, "MainWindow/DocksControl");
    {
        s.remove("Docks");
        AT_GROUP(s, "Docks");
        for(auto it = t_w_to_dw.constKeyValueBegin(); it != t_w_to_dw.constKeyValueEnd(); ++it){
            const auto& [key, dock] = *it;
            auto side = t_main->dockWidgetArea(dock);
            AT_GROUP(s, QString::number(side));

            auto mode = t_mode_by_w(key);
            {
                AT_GROUP(s, QString::number(mode));
                s.setValue("hide", dock->isHidden());
                s.setValue("width", dock->width());
                s.setValue("height", dock->height());
            }

        }
    }
}

void DocksControl::hide(QWidget *w)
{
    auto it = t_w_to_dw.find(w);
    if(it != t_w_to_dw.end()){
        it.value()->hide();
    }
}

void DocksControl::show(QWidget *w)
{
    auto it = t_w_to_dw.find(w);
    if(it != t_w_to_dw.end()){
        it.value()->show();
    }
}

QString DocksControl::t_title_by_mode(DocksControl::dock_widget mode)
{
    switch (mode) {
    case dock_widget::interpretator:
        return "Интерпретатор";
    case dock_widget::project:
        return "Проект";
    default:
        break;
    }
    return "";
}

QWidget *DocksControl::t_w_by_mode(DocksControl::dock_widget mode)
{
    switch (mode) {
    case dock_widget::interpretator:
        return t_main->t_interpretator_w;
    case dock_widget::project:
        return t_main->t_project_w;
    default:
        break;
    }
    return nullptr;
}

DocksControl::dock_widget DocksControl::t_mode_by_w(QWidget *w)
{
    if(w == t_main->t_project_w) return  dock_widget::project;
    if(w == t_main->t_interpretator_w) return  dock_widget::interpretator;
    return dock_widget::none;
}

void DocksControl::t_load_docks(){
    auto& s = MyQApp::global_settings();
    AT_GROUP(s, "MainWindow/DocksControl/Docks");
    {
        auto buf = std::set<Qt::DockWidgetArea>{};
        std::copy(areas.begin(), areas.end(), std::inserter(buf, buf.begin()));

        for(const auto& side_str : s.childGroups()){
            AT_GROUP(s, side_str);
            auto side = Qt::DockWidgetArea(side_str.toInt());
            for(const auto& mode_str : s.childGroups()){
                AT_GROUP(s, mode_str);
                t_load_dock(dock_widget(mode_str.toInt()), side);
            }
            if(auto it = buf.find(side); it != end(buf))
                buf.erase(it);
        }

        for(auto side : buf){
            t_load_dock(t_default_m_by_side(side), side);
        }
    }
}

void DocksControl::t_load_dock(dock_widget mode, Qt::DockWidgetArea side)
{
    auto& s = MyQApp::global_settings();
    auto* w = t_w_by_mode(mode);
    if(w == nullptr) return;
    if(t_w_to_dw.find(w) != t_w_to_dw.end()) return;
    auto hide = s.value("hide", false).toBool();
    auto* dock = new QDockWidget(t_title_by_mode(mode), t_main);
    dock->setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea | Qt::BottomDockWidgetArea);
    dock->setFeatures(QDockWidget::DockWidgetMovable | QDockWidget::DockWidgetClosable);
    dock->setWidget(w);
    dock->setHidden(hide);
    t_main->addDockWidget(side, dock);
    connect(dock, &QDockWidget::visibilityChanged, [this, dock](){ emit DocksControl::dock_state_changed(dock);});
    t_w_to_dw.insert(w, dock);

    auto gw = s.value("width", dock->width()).toInt();
    auto gh = s.value("height", dock->height()).toInt();

    t_main->resizeDocks({dock}, {gw}, Qt::Orientation::Horizontal);
    t_main->resizeDocks({dock}, {gh}, Qt::Orientation::Vertical);
}

DocksControl::dock_widget DocksControl::t_default_m_by_side(Qt::DockWidgetArea side)
{
    if(side == Qt::LeftDockWidgetArea) return  dock_widget::project;
    if(side == Qt::BottomDockWidgetArea) return  dock_widget::interpretator;
    return dock_widget::none;
}
