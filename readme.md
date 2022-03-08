# IDE For RLisp 
Интегрированная среда разработки для работы интерпретатора muLisp/FRL, разработанная в рамках курсовой работы курса Програмной инженерии.

## Основные возможности
* Текстовый редактор
    - Базовые функции редактирования текста (отменить, повторить, копировать, вставить и т.д.)
    - Подсветка синтаксиса
    - Расширенная работа с S-выражениями
* Интерпретатор
    - Является внешней программой (запускается из ide)
    - Дополнительно разработана оболочка над системой FORIS (ForisWrapper)
* Средства управления файлами (система проектов)
    - Создание, добавление, удаление файлов и т.д.
    - Параметры запуска интерпретатора
    - Средства загрузки файлов в интерпретатор
* Отладчик
    - Входит в состав интерпретатора в связи со спецификой языка

## Интерфейс
![Концепт приложения](https://github.com/BlackPhantomCoder/IDE_FRL/blob/master/readme_data/readme_app_concept.png)

## Использование/Документация
`В разработке`

## Сборка

### Каталог run
В него собирается IDE  
`Важно:` для стабильной работы IDE и ForisWrapper скачанные файлы должны быть разблокированы

* data - настройки приложения, настройки интерпретаторов
* examples - примеры проектов 
* roflolisp - версия [Собственного интерпретатора mulisp](https://github.com/BlackPhantomCoder/lisp_core)  
* fw - ForisWrapper (в эту папку создаётся exe при построении проекта)
    - data - данные, нужные ForisWrapper для запуска и работы
* qscintilla2_qt.dll - доп dll для работы IDE
* qscintilla2_qt5d.dll - доп dll для работы IDE в режиме отладки
* build_all.bat - пакетный файл, используемый для копирования нужных dll для IDE и ForisWrapper

### IDE 
С помощью Qt Creator:  
`файл проекта` IDE_FRL\IDE_FRL.pro  
`создаст` run\IDE_FRL_release.exe  
`далее` run\build_all.bat с параметром`путь до windeployqt.exe`  
`В итоге` в run лежит готовое приложение

### ForisFrapper 
С помощью Qt Creator:  
`файл проекта` ForisWrapperQt\ForisWrapperQt.pro  
`создаст` run\fw\ForisWrapperQt_release.exe  
`далее` run\build_all.bat с параметром `путь до windeployqt.exe`  
`В итоге` в run\fw лежит готовое приложение

## Создано с помощью
`Qt`  
`Qscintilla`

## Авторы  
[BlackPhantomCoder](https://github.com/BlackPhantomCoder)  
[NeonTower](https://github.com/NeonTower)
