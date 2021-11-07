#ifndef INTERPRETATOR_H
#define INTERPRETATOR_H

#include <QObject>
#include <QProcess>

class Interpretator : public QObject
{
    Q_OBJECT
public:
    explicit Interpretator(const QString& path, const QStringList& params, QObject *parent = nullptr);
    ~Interpretator();

    bool run();
    bool is_runing() const;
    bool stop();

    void kill();

    void send(const QString& text);

signals:
    void response(QString);
    void finished();

private slots:
    void on_read_ready();
    void on_finish(int exitCode, QProcess::ExitStatus exitStatus);
private:
    QProcess* t_process;
    QString t_path;
    QStringList t_params;
};

#endif // INTERPRETATOR_H
