#include "SExprSellerController.h"

#include "MainWindow.h"

SExprSellerController::SExprSellerController(MainWindow *main):
    MainWindowPartInt(main)
{
    connect(&t_data, &SExprSeller::func_added, this, &SExprSellerController::t_add_fnc);
}

void SExprSellerController::init()
{
    for(auto i = SExprSeller::to_numb(SExprSeller::none_begin) + 1; i != SExprSeller::none_end; ++i){
        t_add_fnc(t_data.get_bi_func(SExprSeller::bi_func(i)));
    }
    t_main->t_editor_w->set_sexpr_menu(t_main->t_menu->interpretator_sexpr_menu);
}

void SExprSellerController::save()
{

}

void SExprSellerController::t_add_fnc(SExprAction* act)
{
    act->setEnabled(t_main->t_interpretator_w->is_running());
    connect(t_main->t_interpretator_w, &InterpretatorWidget::changed_state,
            [this, act](){act->setEnabled(t_main->t_interpretator_w->is_running());});
    connect(act, &SExprAction::applyed, [this](const QString& str){
        if(!t_main->t_start_interpretator_ask()) return;
        t_main->t_interpretator_w->send(str, true);}
    );
    t_main->t_menu->interpretator_sexpr_menu->addAction(act);
}
