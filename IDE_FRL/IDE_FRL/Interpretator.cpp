#include "Interpretator.h"

Interpretator::Interpretator(const QString &path, const QStringList& params, QObject *parent) :
    QObject(parent),
    t_path(path),
    t_params(params)
{
    t_process = new QProcess(this);
    t_process->setReadChannel(QProcess::ProcessChannel::StandardOutput);
    connect(t_process, &QProcess::readyRead, this, &Interpretator::on_read_ready);
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
    t_process->start(t_path, t_params);
    if( !t_process->waitForStarted(10000)) {
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

void Interpretator::on_read_ready()
{
    QString result = t_process->readAllStandardOutput();

    emit response(result);
}

void Interpretator::on_finish(int exitCode, QProcess::ExitStatus exitStatus)
{
    emit finished();
}
