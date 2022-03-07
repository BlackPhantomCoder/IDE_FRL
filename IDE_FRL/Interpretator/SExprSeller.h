#ifndef SEXPRSELLER_H
#define SEXPRSELLER_H

#include <QtWidgets>
#include <QtCore>
#include <optional>
#include <unordered_set>

struct seller_func{
    QString name;
    QString func;
};


class SExprAction :  public QAction{
    Q_OBJECT
    friend class SExprSeller;
    friend bool operator<(SExprAction* lh, const QString& rh);
public:

    SExprAction(const seller_func& func, QObject* parent = nullptr);
    void apply(const QString& str) const;



signals:
    void applyed(const QString& str) const;
private:
     seller_func t_func;
};

class SExprSeller : public QObject
{
    Q_OBJECT
public:
    enum bi_func : int {none_begin, eval, macroexpand, none_end};
    static auto to_numb(bi_func b) {return int(b);}
public:
    explicit SExprSeller(QObject *parent = nullptr);

    SExprAction* get_bi_func(bi_func func);
    SExprAction* get_func(const QString& fnc);

    const std::unordered_set<SExprAction*>& funcs() const;
signals:
    void func_added(SExprAction* act);
    void func_deleted(const QString& name);
public slots:
    SExprAction* add_func(const seller_func& fnc);
    bool del_func(SExprAction* func);
private:
    std::unordered_set<SExprAction*> t_funcs;
    std::unordered_map<bi_func, SExprAction*> t_bifunc_act;
};

#endif // SEXPRSELLER_H
