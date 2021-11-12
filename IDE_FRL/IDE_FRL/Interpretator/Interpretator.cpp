#include "Interpretator.h"

#include <QDebug>

Interpretator::Interpretator(const InterpretatorData& data,  QObject *parent) :
    QObject(parent),
    t_data(data)
{
    t_process = new QProcess(this);
    t_process->setReadChannel(QProcess::ProcessChannel::StandardOutput);
    connect(t_process, &QProcess::readyRead, this, &Interpretator::t_on_read_ready);
    connect(t_process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), this, &Interpretator::finished);
}

Interpretator::~Interpretator()
{
    if(is_runing()){
        if(!stop()){
            kill();
        }
    }
}

bool Interpretator::run()
{
    t_process->setNativeArguments(t_data.params);
    t_process->start(t_data.path);
    if( !t_process->waitForStarted(5000)) {
        return false;
    }
    return true;
}

bool Interpretator::is_runing() const
{
    return t_process->state() == QProcess::Running;
}

void Interpretator::kill()
{
    if(is_runing()){
        t_process->kill();
        t_process->waitForFinished(5000);
    }
}


bool Interpretator::stop()
{
    if(is_runing()){
        t_process->closeWriteChannel();
        t_process->waitForFinished(5000);
        if(t_process->state() != QProcess::NotRunning){
            return false;
        }
    }
    return true;
}

void Interpretator::send(const QString &text)
{
    if(is_runing()){
        auto buf =  text.toStdString() + "\n";
        t_process->write(buf.c_str(), buf.size());
    }
}

void Interpretator::t_on_read_ready()
{
    QString result = t_process->readAllStandardOutput();

    emit response(result);
}
