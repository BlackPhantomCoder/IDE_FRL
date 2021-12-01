#include "SExprSeller.h"

#include <algorithm>
using  namespace std;

bool operator<(SExprAction* lh, const QString& rh){
    return lh->t_func.name < rh;
}

bool operator<(SExprAction* lh, const seller_func& rh){
    return lh < rh.name;
}

SExprSeller::SExprSeller(QObject *parent) :
    QObject(parent)
{
    t_bifunc_act[bi_func::eval] = new SExprAction({"eval", "EVAL"});
    t_bifunc_act[bi_func::macroexpand] = new SExprAction({"macroexpand", "MACROEXPAND"});
}

SExprAction *SExprSeller::get_bi_func(SExprSeller::bi_func func)
{
    return t_bifunc_act[func];
}

const std::unordered_set<SExprAction*>& SExprSeller::funcs() const
{
    return t_funcs;
}

SExprAction* SExprSeller::add_func(const seller_func &fnc)
{
    auto it = lower_bound(begin(t_funcs), end(t_funcs), fnc);
    if(it == end(t_funcs)) return nullptr;
    auto [it1, result] = t_funcs.insert(new SExprAction(fnc));
    emit func_added(*it1);
    return *it1;
}

SExprAction* SExprSeller::get_func(const QString &fnc)
{
     auto it = lower_bound(begin(t_funcs), end(t_funcs), fnc);
    if(it != end(t_funcs)){
        return *it;
    }
    return nullptr;
}

bool SExprSeller::del_func(SExprAction* func)
{
    auto it = lower_bound(begin(t_funcs), end(t_funcs), func);
    if(it != end(t_funcs)){
        emit func_deleted(func->t_func.name);
        t_funcs.erase(func);
        delete func;
        return true;
    }
    return false;
 }

SExprAction::SExprAction(const seller_func &func, QObject *parent)
    : QAction(func.name, parent), t_func(func)
{

}

void SExprAction::apply(const QString &str) const
{
    if(!isEnabled()) return;
    emit applyed(QString() + "(" + t_func.func + " " + str + ")");
}
