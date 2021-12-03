#include "ExtendedLineEdit.h"

ExtendedLineEdit::ExtendedLineEdit(QWidget *parent):
    QLineEdit(parent)
{

}

void ExtendedLineEdit::keyPressEvent(QKeyEvent *event)
{
    if (event->key() == Qt::Key_Up)
    {
         emit KeyUpPressed();
         return;
    }
    if(event->key() == Qt::Key_Down)
    {
        emit KeyDownPressed();
        return;
    }
    return QLineEdit::keyPressEvent(event);
}
