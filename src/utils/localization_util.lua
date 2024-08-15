local LocalizationUtil = {}

local localization_path = "i18n.default.json"

local i18n_table = {}

-- LOCALIZATIONMANAGER FUNCTIONS --

function LocalizationUtil:initialize()
  i18n_table = ProtectedLoadJSONFile(localization_path)
end

---@param key string
---@return string
function LocalizationUtil:get_translation(key)
  return i18n_table[key]
end

return LocalizationUtil