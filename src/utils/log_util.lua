---@param tag string
---@param text any
function LogDebug(tag, text)
  if DEBUG == true then
      spdlog.info(tostring("["..ModName.."] DEBUG "..tag..": "..text))
  end
end

---@param tag string
---@param text any
function LogError(tag, text)
  spdlog.info(tostring("["..ModName.."] ERROR "..tag..": "..text))
  print(tostring("["..ModName.."] ERROR "..tag..": "..text))
end