#include "Interpretator.h"

//#include <QDebug>
#include <QtCore>

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
    auto path = ((t_data.relative) ? QCoreApplication::applicationDirPath() + "/" : "") +t_data.path;
    t_process->setWorkingDirectory(path.mid(0, path.lastIndexOf("/")));
    t_process->setNativeArguments(t_data.params);
    t_process->start(path);
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

void Interpretator::send(const QString &text, bool new_line)
{
    if(is_runing()){
        auto buf =  text + ((new_line) ?  "\r\n" : "");
        t_process->write(buf.toLocal8Bit(), buf.size());
    }
}
//#include <windows.h>
bool Interpretator::stop()
{
    if(is_runing()){
        t_process->terminate();
        t_process->waitForFinished(1000);
        if(t_process->state() != QProcess::NotRunning){
            t_process->closeWriteChannel();
            t_process->waitForFinished(3000);
            if(t_process->state() != QProcess::NotRunning){
                return false;
            }
        }
    }
    return true;
}

#include <QTextDecoder>

void Interpretator::t_on_read_ready()
{
    auto data =  t_process->readAllStandardOutput();

    auto *codec = QTextCodec::codecForName("cp866");

    auto result = codec->toUnicode(data);


    emit response(result);
}
