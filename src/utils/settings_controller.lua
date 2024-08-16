local SettingsController = {}

local logtag = "SettingsController"

local saved_settings_path = "./data/saved_settings.json"
local presets_path = "./data/presets.json"

local valid_presets = false
local preset_settings = {}

local default_settings = {}
local native_settings = {}
local active_settings = {}
local preset_list = {}
local preset_selected = 0
local apply_pending_settings_fn = nil

local base_path = ""
local presets_menu_path = ""
local settings_path = ""

local function apply_pending_settings()
  if apply_pending_settings_fn == nil then
    LogError(logtag, "apply_pending_settings_fn == nil")
    return
  end

  apply_pending_settings_fn()

  for name, value in pairs(SettingsController.pending_settings) do
    active_settings[name] = value
  end
end

-- SETTINGSUTIL FUNCTIONS --

SettingsController.pending_settings = {}
SettingsController.settings_menu = {}

---@param _default_settings table
---@param _apply_pending_settings_fn function
function SettingsController:initialize(_default_settings, _apply_pending_settings_fn)

  default_settings = _default_settings

  native_settings = GetMod("nativeSettings")
  apply_pending_settings_fn = _apply_pending_settings_fn

  if (native_settings == nil) then
    LogError(logtag, "NativeSettings mod not found")
  end

  SettingsController:load_saved_settings()
  SettingsController:load_presets()
end

function SettingsController.get_active_settings()
  return active_settings
end

function SettingsController.get_native_settings()
  return native_settings
end

function SettingsController.get_settings_path()
  return settings_path
end

function SettingsController:load_presets()
  valid_presets, preset_settings = IsSuccessProtectedLoadJSONFile(presets_path)

  -- if presets are loaded, make the list for the selector
  if valid_presets then
    for i, preset_table in ipairs(preset_settings) do
      local preset_name = ""

      -- if presets aren't loading correctly, they aren't valid
      if preset_table.key == nil then
        if preset_table.name == nil then                                  -- for custom presets without keys
          valid_presets = false
          LogDebug(logtag, "1 Loaded presets are not valid")
          return
        else
          preset_name = preset_table.name                                 -- as long as name is present, use that
          preset_table.name = nil
        end
      else
        preset_name = LocalizationUtil:get_translation(preset_table.key)  -- otherwise use localization
        preset_table.key = nil
      end

      preset_list[i] = preset_name
    end
  else
    LogDebug(logtag, "2 Loaded presets are not valid")
    return
  end
  if active_settings.preset == nil then
    active_settings.preset = 1
  end
end

-- Loads settings from file
function SettingsController:load_saved_settings()
  local is_valid = false
  is_valid, SettingsController.pending_settings = IsSuccessProtectedLoadJSONFile(saved_settings_path)

  if (not is_valid) then
      LogDebug(logtag, "No saved settings were found")
  end

  -- verify all settings are set before applying
  for name, value in pairs(default_settings) do
    if SettingsController.pending_settings[name] == nil then
      LogDebug(logtag, name.." not found in "..saved_settings_path)
      SettingsController.pending_settings[name] = value
    end
  end

  apply_pending_settings()
end

-- Writes active_settings to file
function SettingsController:save_settings()
  WriteJSONFile(saved_settings_path, active_settings)
end

-- Applies settings based on preset selected
function SettingsController.apply_preset()
  for key, value in pairs(preset_settings[preset_selected]) do
    if value ~= nil and SettingsController.settings_menu[key] ~= nil then          -- makes sure the setting exists and isn't being set to nil
      if native_settings ~= nil then
        native_settings.setOption(SettingsController.settings_menu[key], value)
      else
        LogError(logtag, "NativeSettings == nil")
      end
    end
  end
end

-- Configures a basic NativeSettings menu with the preset subcategory and the start of the settings subcategory
function SettingsController:create_settings_menu()
  base_path = "/"..LocalizationUtil:get_translation("modName")
  presets_menu_path = base_path.."/presets"
  settings_path = base_path.."/settings"

  -- adds NativeSettings tab and subcategories
  if not native_settings.pathExists(base_path) then
    native_settings.addTab(base_path, LocalizationUtil:get_translation("modName"), apply_pending_settings)
  end
  if not native_settings.pathExists(presets_menu_path) and valid_presets then
    native_settings.addSubcategory(presets_menu_path, LocalizationUtil:get_translation("settings.presets.name"))

    -- select preset string list
    native_settings.addSelectorString(
      presets_menu_path,
      LocalizationUtil:get_translation("settings.presets.select.label"),
      LocalizationUtil:get_translation("settings.presets.select.description"),
      preset_list,
      active_settings.preset,
      1,
      function(value)
        preset_selected = value
      end
    )

    -- apply preset button
    native_settings.addButton(
      presets_menu_path,
      LocalizationUtil:get_translation("settings.presets.apply.label"),
      LocalizationUtil:get_translation("settings.presets.apply.description"),
      LocalizationUtil:get_translation("settings.presets.apply.button.label"),
      45,
      function()
        SettingsController.apply_preset()
      end
    )

  end
  if not native_settings.pathExists(settings_path) then
    native_settings.addSubcategory(settings_path, LocalizationUtil:get_translation("settings.settings.name"))
  end
end

return SettingsController