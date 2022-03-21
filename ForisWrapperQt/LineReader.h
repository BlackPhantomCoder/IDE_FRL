#ifndef LINEREADER_H
#define LINEREADER_H
#include <QtCore>
#include <QFile>
#include <queue>

class LineReader : public QObject
{
    Q_OBJECT
public:
    LineReader(QObject* parent = nullptr);

    bool is_empty() const;
    QString read_line();
signals:
    void appended();
public slots:
    void append_line(const QString& data);

private:
   std::queue<QString> t_data;
};

#endif // LINEREADER_H
