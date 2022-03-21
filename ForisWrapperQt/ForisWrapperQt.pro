QT -= gui

CONFIG += c++17 console
CONFIG -= app_bundle

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        ConsoleReader.cpp \
        DosWrapper.cpp \
        LineReader.cpp \
        main.cpp


CONFIG += debug_and_release

CONFIG(debug, debug|release)  {
    TARGET = $${TARGET}_debug
}
else {
    TARGET = $${TARGET}_release
}


DESTDIR = $$PWD/../run/fw/


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    ConsoleReader.h \
    DosWrapper.h \
    LineReader.h \
    StaticData.h
