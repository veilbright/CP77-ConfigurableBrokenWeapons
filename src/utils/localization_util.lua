require("./utils/json_util")

local LocalizationUtil = {}

local logtag = "LocalizationUtil"
local localization_path = "i18n.default.json"

local i18n_table = {}

-- LOCALIZATIONMANAGER FUNCTIONS --

function LocalizationUtil:initialize()
  i18n_table = ProtectedLoadJSONFile(localization_path)
end

---@param key string
---@return string
function LocalizationUtil:get_translation(key)
  if i18n_table[key] == nil then
    LogError(logtag, key.."is not a valid key")
  end
  return i18n_table[key]
end

return LocalizationUtil