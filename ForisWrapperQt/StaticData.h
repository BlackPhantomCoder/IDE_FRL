#ifndef STATICDATA_H
#define STATICDATA_H

#include <QtCore>
#include <memory>
#include <iostream>

namespace StaticData {
    static auto program_name = QString("ForisWrapper");
    static auto version_number = QString("v0.3.0");


    static auto qout = [](){
        //return &std::cout;
        auto result = std::make_unique<QTextStream>(stdout);
        result->setCodec(QTextCodec::codecForName("cp866"));
        return result;
    }();
    static auto qin = [](){
        auto result = std::make_unique<QTextStream>(stdin);
        result->setCodec(QTextCodec::codecForName("cp866"));
        return result;
    }();

}

//inline std::ostream& operator<<(std::ostream&  os, const QString& rh) {
//    if(os)
//        os << rh.toStdString();
//    return os;
//}

#endif // STATICDATA_H
