QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17
CONFIG += qscintilla2

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    LexerLisp.cpp \
    MainWindow.cpp \
    main.cpp

HEADERS += \
    LexerLisp.h \
    MainWindow.h

FORMS += \
    MainWindow.ui

TRANSLATIONS += \
    IDE_FRL_ru_RU.ts

INCLUDEPATH += "libs\\qscintilla"

debug {
    LIBS += $${_PRO_FILE_PWD_}/libs/qscintilla/lib/qscintilla2_qt5d.lib
}

release {
    LIBS += $${_PRO_FILE_PWD_}/libs/qscintilla/lib/qscintilla2_qt5.lib
}


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
