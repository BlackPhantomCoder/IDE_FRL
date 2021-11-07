#include "GlobalSettings.h"
#include "SettringJson.h"

QSettings &global_settings()
{
    static auto settings = SettringJson("/main_settings.json");
    return settings;
}
