local SettingsController = {}

local logtag = "SettingsController"

local saved_settings_path = "./data/saved_settings.json"
local presets_path = "./data/presets.json"

local valid_presets = false
local preset_list = {}
local preset_settings = {}

SettingsController.settings_menu = {}
SettingsController.native_settings = {}
SettingsController.active_settings = {}
SettingsController.pending_settings = {}
SettingsController.preset_selected = 0

-- LOCAL FUNCTIONS --

-- Loads settings from file
local function load_saved_settings()
  local is_valid = false
  is_valid, SettingsController.pending_settings = IsSuccessProtectedLoadJSONFile(saved_settings_path)

  if (not is_valid) then
      LogDebug(logtag, "No saved settings were found")
      return
  end

  -- verify all settings are set before applying
  for name, value in pairs(SettingsController.active_settings) do
      if SettingsController.pending_settings[name] == nil then
          LogDebug(logtag, name.." not found in "..saved_settings_path)
          SettingsController.pending_settings[name] = value
      end
  end

  SettingsController.apply_pending_settings()
end

local function load_presets()
  valid_presets, preset_settings = IsSuccessProtectedLoadJSONFile(presets_path)

  -- if presets are loaded, make the list for the selector
  if valid_presets then
      for i, preset_table in ipairs(preset_settings) do
          local preset_name = ""

          -- if presets aren't loading correctly, they aren't valid
          if preset_table.key == nil then
              if preset_table.name == nil then                                    -- for custom presets without keys
                  valid_presets = false
                  LogDebug(logtag, "Loaded presets are not valid")
                  return
              else
                  preset_name = preset_table.name                                 -- as long as name is present, use that
                  preset_table.name = nil
              end
          else
              preset_name = LocalizationManager:get_translation(preset_table.key) -- otherwise use localization
              preset_table.key = nil
          end

          preset_list[i] = preset_name
      end
  else
      LogDebug(logtag, "Loaded presets are not valid")
  end
end

-- SETTINGSUTIL FUNCTIONS --

function SettingsController:new ()
  local o = {}   -- create object
  setmetatable(o, self)
  self.__index = self

  self.native_settings = GetMod("nativeSettings")
  if (self.native_settings == nil) then
    LogError(logtag, "NativeSettings mod not found")
  end

  return o
end

---@param settings table
-- Sets pending_settings to the passed table's values (passed table should be set up: {name, value})
function SettingsController:set_pending_settings(settings)
  for name, value in pairs(settings) do
    if self.active_settings[name] ~= nil then
      self.pending_settings[name] = value
    else
      LogDebug(logtag, name.." == nil in default_settings table")
    end
  end
end

-- Writes active_settings to file
function SettingsController:save_settings()
  WriteJSONFile(saved_settings_path, self.active_settings)
end

-- Applies settings based on preset selected
function SettingsController:apply_preset()
  for key, value in pairs(preset_settings[self.preset_selected]) do
    if value ~= nil and self.settings_menu[key] ~= nil then          -- makes sure the setting exists and isn't being set to nil
      if self.native_settings ~= nil then
        self.native_settings.setOption(self.settings_menu[key], value)
      else
        LogError(logtag, "NativeSettings == nil")
      end
    end
  end
end

---@param apply_pending_settings_fn function
-- Configures a basic NativeSettings menu with the preset subcategory and the start of the settings subcategory
function SettingsController:create_settings_menu(apply_pending_settings_fn)
  self.base_path = "/"..LocalizationManager:get_translation("modName")
  self.presets_path = self.base_path.."/presets"
  self.settings_path = self.settings_path.."/settings"

  -- adds NativeSettings tab and subcategories
  if not self.native_settings.pathExists(self.base_path) then
    self.native_settings.addTab(self.base_path, LocalizationManager:get_translation("modName"), apply_pending_settings_fn)
  end
  if not self.native_settings.pathExists(presets_path) and valid_presets then
    self.native_settings.addSubcategory(presets_path, LocalizationManager:get_translation("settings.presets.name"))
  end
  if not self.native_settings.pathExists(self.settings_path) then
    self.native_settings.addSubcategory(self.settings_path, LocalizationManager:get_translation("settings.settings.name"))
  end
end