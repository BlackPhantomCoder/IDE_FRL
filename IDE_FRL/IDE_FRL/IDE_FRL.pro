QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17
CONFIG += qscintilla2

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    Interpretator.cpp \
    InterpretatorWidget.cpp \
    LexerLisp.cpp \
    MainWindow.cpp \
    Project/Project.cpp \
    Project/ProjectWidget.cpp \
    Project/filetreeitem.cpp \
    Project/treemodel.cpp \
    Settings/GlobalSettings.cpp \
    Settings/SettringJson.cpp \
    main.cpp \

HEADERS += \
    Interpretator.h \
    InterpretatorWidget.h \
    LexerLisp.h \
    MainWindow.h \
    Project/Project.h \
    Project/ProjectWidget.h \
    Project/filetreeitem.h \
    Project/treemodel.h \
    Settings/GlobalSettings.h \
    Settings/SettringJson.h \

FORMS += \
    InterpretatorWidget.ui \
    MainWindow.ui \
    Project/ProjectWidget.ui \

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
