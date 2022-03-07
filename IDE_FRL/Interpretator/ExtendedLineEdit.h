#ifndef EXTENDEDLINEEDIT_H
#define EXTENDEDLINEEDIT_H

#include <QtWidgets>

class ExtendedLineEdit : public QLineEdit{
    Q_OBJECT
public:
    ExtendedLineEdit(QWidget* parent);

signals:
    void KeyUpPressed();
    void KeyDownPressed();
    // QObject interface
protected:
    virtual void keyPressEvent(QKeyEvent *event) override;
};

#endif // EXTENDEDLINEEDIT_H
