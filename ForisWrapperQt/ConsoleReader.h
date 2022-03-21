#ifndef CONSOLEREADER_H
#define CONSOLEREADER_H

#include <QObject>
#include <QThread>

#ifdef Q_OS_WIN
#include <QWinEventNotifier>
#include <windows.h>
#else
#include <QSocketNotifier>
#endif

class ConsoleReader : public QObject
{
    Q_OBJECT

public:
    ConsoleReader();
    ~ConsoleReader();

    bool is_finished() const;

    void finish();

signals:
    void finished();

    void received_line(const QString &strNewLine);

    void internal_received_line(const QString &strNewLine);

private:
#ifdef Q_OS_WIN
    QWinEventNotifier *t_notifier;
#else
    QSocketNotifier *t_notifier;
#endif

private slots:
    void on_received_line(const QString &strNewLine);
private:
    void t_finish();

private:
    QThread t_thread;
    bool t_finished;
};


#endif // CONSOLEREADER_H
