#ifndef INTERPRETATOR_H
#define INTERPRETATOR_H

#include <QObject>
#include <QProcess>

struct InterpretatorData{
    bool relative = false;
    QString path = "";
    QString params = "";
};

class Interpretator : public QObject
{
    Q_OBJECT
public:
    explicit Interpretator(const InterpretatorData& data, QObject *parent = nullptr);
    ~Interpretator();

    bool run();
    bool is_runing() const;
    bool stop();

    void kill();

    void send(const QString& text, bool new_line);

signals:
    void response(QString);
    void finished();

private slots:
    void t_on_read_ready();
private:
    QProcess* t_process;
    InterpretatorData t_data;
};

#endif // INTERPRETATOR_H
