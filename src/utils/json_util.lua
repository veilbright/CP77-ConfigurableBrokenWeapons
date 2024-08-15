local logtag = "JSONUtil"

---@param filepath string
---@return table, boolean
-- How to call: is_valid, content = pcall(function() return LoadJSONFile(filepath) end)
function LoadJSONFile(filepath)
  local file = io.open(filepath, "r")

  if file == nil then
      LogDebug(logtag, "Failed to load "..filepath)
      error()
  end

  local contents = file:read("*a")
  return json.decode(contents), true
end

---@param filepath string
---@return table
-- Loads a JSON file as a table. Logs an error if JSON isn't valid or file doesn't exist. Returns contents
function ProtectedLoadJSONFile(filepath)
  local is_successful, content = IsSuccessProtectedLoadJSONFile(filepath)
  return content
end

---@param filepath string
---@return boolean, table
-- Loads a JSON file as a table. Logs an error if JSON isn't valid or file doesn't exist. Returns is_successful, contents
function IsSuccessProtectedLoadJSONFile(filepath)
  local is_successful, content = pcall(function() return LoadJSONFile(filepath) end)

  if not is_successful then
      LogError(logtag, filepath.." is not valid JSON")
      return false, {}
  end

  return true, content
end

---@param filepath string
---@param contents_table table
-- Writes a table as JSON to a filepath
function WriteJSONFile(filepath, contents_table)
  local is_valid_json, contents = pcall(function() return json.encode(contents_table) end)

  if not is_valid_json then
      LogError(logtag, contents)
      return
  end

  if (contents == nil) then
      LogDebug(logtag, "Contents of "..filepath.." == nil")
      return
  end

  local file = io.open(filepath, "w+")
  if file ~= nil then
      file:write(contents)
      file:close()
  else
      LogError(logtag, file.." == nil")
  end
end