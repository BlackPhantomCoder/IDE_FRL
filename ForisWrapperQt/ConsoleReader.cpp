#include "ConsoleReader.h"

#include <iostream>
using namespace std;
#include "StaticData.h"
using StaticData::qin;

ConsoleReader::ConsoleReader():
    t_finished(false)
{
    QObject::connect(
        this, &ConsoleReader::internal_received_line,
        this, &ConsoleReader::on_received_line,
        Qt::QueuedConnection
    );
#ifdef Q_OS_WIN
    t_notifier = new QWinEventNotifier(GetStdHandle(STD_INPUT_HANDLE));
#else
    t_notifier = new QSocketNotifier(fileno(stdin), QSocketNotifier::Read);
#endif
    t_notifier->moveToThread(&t_thread);
    QObject::connect(
        &t_thread , &QThread::finished,
        t_notifier, &QObject::deleteLater
    );
#ifdef Q_OS_WIN
    QObject::connect(t_notifier, &QWinEventNotifier::activated,
#else
    QObject::connect(t_notifier, &QSocketNotifier::activated,
#endif
    [this]() {
        if(qin->atEnd()) {
            t_finish();
            return;
        }
        auto line = QString();
        emit this->internal_received_line(qin->readLine());

//        if(!cin) {
//            t_finish();
//            return;
//        }
//        auto line = string();
//        getline(cin, line);
//        emit this->internal_received_line(QString::fromStdString(line));
    });
    connect(&t_thread, &QThread::finished, [this](){t_finished = true; emit finished();});

    //cout.tie();

    t_thread.start();
}

void ConsoleReader::on_received_line(const QString &strNewLine)
{
    emit received_line(strNewLine);
}

void ConsoleReader::t_finish()
{
    if(!t_finished){
        t_thread.quit();
        t_thread.wait();
        t_finished = true;
        emit finished();
    }

}

ConsoleReader::~ConsoleReader()
{
    t_finish();
}

bool ConsoleReader::is_finished() const
{
    return t_finished;
}

void ConsoleReader::finish()
{
    t_thread.terminate();
}

