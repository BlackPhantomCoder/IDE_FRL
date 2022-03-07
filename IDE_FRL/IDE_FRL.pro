QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17
CONFIG += qscintilla2

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    Editor/EditorWidget.cpp \
    Interpretator/ExtendedLineEdit.cpp \
    Project/OrderEditor.cpp \
    Settings/IDESettingsEditor.cpp \
    Interpretator/Interpretator.cpp \
    Interpretator/InterpretatorEditorWidget.cpp \
    Interpretator/InterpretatorWidget.cpp \
    Editor/LexerLisp.cpp \
    Interpretator/SExprSeller.cpp \
    Settings/MyQApp.cpp \
    Windows/LoaderController.cpp \
    Windows/MainWidowDocksControl.cpp \
    Windows/MainWindowMenuControl.cpp \
    Windows/MainWindowPartInt.cpp \
    Windows/MainWindowToolbar.cpp \
    Project/ProjectCreatorWidget.cpp \
    Project/ProjectEditorWidget.cpp \
    Settings/InterpretatorsSettings.cpp \
    Windows/MainWindow.cpp \
    Project/Project.cpp \
    Project/ProjectWidget.cpp \
    Project/filetreeitem.cpp \
    Project/treemodel.cpp \
    Settings/SettringJson.cpp \
    Windows/SExprSellerController.cpp \
    main.cpp \

HEADERS += \
    Editor/EditorWidget.h \
    Interpretator/ExtendedLineEdit.h \
    Project/OrderEditor.h \
    Settings/IDESettingsEditor.h \
    Interpretator/Interpretator.h \
    Interpretator/InterpretatorEditorWidget.h \
    Interpretator/InterpretatorWidget.h \
    Editor/LexerLisp.h \
    Interpretator/SExprSeller.h \
    Settings/MyQApp.h \
    Windows/LoaderController.h \
    Windows/MainWidowDocksControl.h \
    Windows/MainWindowMenuControl.h \
    Windows/MainWindowPartInt.h \
    Windows/MainWindowToolbar.h \
    Project/ProjectCreatorWidget.h \
    Project/ProjectEditorWidget.h \
    Settings/InterpretatorsSettings.h \
    Windows/MainWindow.h \
    Project/Project.h \
    Project/ProjectWidget.h \
    Project/filetreeitem.h \
    Project/treemodel.h \
    Settings/SettringJson.h \
    Windows/SExprSellerController.h

FORMS += \
    Editor/EditorWidget.ui \
    Project/OrderEditor.ui \
    Project/ProjectCreatorWidget.ui \
    Settings/IDESettingsEditor.ui \
    Interpretator/InterpretatorWidget.ui \
    Interpretator/InterpretatorEditorWidget.ui \
    Project/ProjectEditorWidget.ui \
    Windows/MainWindowMenu.ui \
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

DESTDIR = $$PWD/../run/
# output
CONFIG += file_copies
COPIES += translations
translations.files = $$files($$PATH_SRC_ROOT/*.exe)
translations.path = $$DESTDIR


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
MAKE_CXXFLAGS += -MP
