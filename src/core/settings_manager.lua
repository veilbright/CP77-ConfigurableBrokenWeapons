require("./utils/log_util")

local SettingsManager = {}

local logtag = "SettingsManager"

local SettingsController = require("./utils/settings_controller")
local tweak_manager = {}

local settings = {
  broken_chance = 0.6,
  broken_override_chance = 0.5
}

local function create_settings_menu()
  local chance_max = 1.0
  local chance_min = 0.0
  local step = 0.01

  SettingsController.settings_menu.broken_chance = SettingsController.get_native_settings().addRangeFloat(
    SettingsController.get_settings_path(),
    LocalizationUtil:get_translation("settings.settings.brokenChance.label"),
    LocalizationUtil:get_translation("settings.settings.brokenChance.description"),
    chance_min,
    chance_max,
    step,
    "%.2f",
    SettingsController.get_active_settings().broken_chance,
    settings.broken_chance,
    function(value)
      SettingsController.pending_settings.broken_chance = value
    end
  )

  SettingsController.settings_menu.broken_override_chance = SettingsController.get_native_settings().addRangeFloat(
    SettingsController.get_settings_path(),
    LocalizationUtil:get_translation("settings.settings.brokenOverrideChance.label"),
    LocalizationUtil:get_translation("settings.settings.brokenOverrideChance.description"),
    chance_min,
    chance_max,
    step,
    "%.2f",
    SettingsController.get_active_settings().broken_override_chance,
    settings.broken_override_chance,
    function(value)
      SettingsController.pending_settings.broken_override_chance = value
    end
  )
end

---@param _tweak_manager table
function SettingsManager:initialize(_tweak_manager)
  LogDebug(logtag, "Start initialization")

  tweak_manager = _tweak_manager

  SettingsController:initialize(settings, SettingsManager.apply_pending_settings)
  SettingsController:create_settings_menu()
  create_settings_menu()

  LogDebug(logtag, "End initialization")
end

function SettingsManager.apply_pending_settings()
  tweak_manager:apply_settings(SettingsController.pending_settings)
end

return SettingsManager