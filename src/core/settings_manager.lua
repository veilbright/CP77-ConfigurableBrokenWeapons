local SettingsManager = {}

local logtag = "SettingsManager"

SettingsController = require("./utils/settings_controller")

local settings_controller = nil
local settings_menu = {}

function SettingsManager:create_settings_menu()
  settings_controller = SettingsController:new()
  settings_controller:create_settings_menu()
end