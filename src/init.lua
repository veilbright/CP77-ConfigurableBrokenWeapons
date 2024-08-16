require "./utils/log_util"
require "./utils/debug_util"

local ConfigurableBrokenWeapons = {}

ModName = "Configurable Broken Weapons"

DEBUG = true
local logtag = "Init"

-- Global Managers
LocalizationUtil = require("./utils/localization_util")

-- Managers
local SettingsManager = require("./core/settings_manager")
local TweakManager = require("./core/tweak_manager")

-- On CET Init, will initialize SettingsManager and observers
registerForEvent("onInit", function()
    LogDebug(logtag, "Start initialization")

    LocalizationUtil:initialize()
    SettingsManager:initialize(TweakManager)

    LogDebug(logtag, "End initialization")
end)

return ConfigurableBrokenWeapons