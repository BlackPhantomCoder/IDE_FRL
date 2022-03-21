#include "LineReader.h"
#include <algorithm>
#include <iterator>
using namespace std;

LineReader::LineReader(QObject* parent ):
    QObject(parent)
{

}

bool LineReader::is_empty() const
{
    return empty(t_data);
}

QString LineReader::read_line()
{
    auto result = move(t_data.back());
    t_data.pop();
    return result;
}


void LineReader::append_line(const QString &data)
{
    t_data.push(data);
    emit appended();
}
