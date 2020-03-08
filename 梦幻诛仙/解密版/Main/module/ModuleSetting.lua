local Lplus = require("Lplus")
local ModuleSetting = Lplus.Class("ModuleSetting")
local def = ModuleSetting.define
local instance
def.static("=>", ModuleSetting).Instance = function()
  if instance == nil then
    instance = ModuleSetting()
  end
  return instance
end
def.method().Init = function(self)
  self:DisableDirectGlobalDefinition()
  self:SetupStringFormatExFunc()
  self:OverrideStringFormatFunc()
end
def.method().DisableDirectGlobalDefinition = function(self)
  if not Application.isEditor then
    return
  end
  _newG = {}
  _oldG = _G
  setmetatable(_newG, {
    __newindex = function(_, key, value)
      rawset(_oldG, key, value)
    end,
    __index = function(_, key)
      return rawget(_oldG, key)
    end
  })
  setmetatable(_oldG, {
    __newindex = function(_, key, value)
      local msg = "USE '_G.%s = value' INSTEAD OF SET GLOBAL VARIABLE"
      error(string.format(msg, key), 2)
    end,
    __index = function(_, key)
      return _newG[key]
    end
  })
  _G = _newG
end
def.method().SetupStringFormatExFunc = function(self)
  local string_format = string.format
  local function formatEx(...)
    local params = {
      ...
    }
    local format = params[1]
    if format == nil then
      error("bad argument #1 to 'format' (string expected, got no value)", 2)
    end
    local indexs = {}
    for index in string.gmatch(format, "%%(%d+)%$") do
      table.insert(indexs, index)
    end
    local format = string.gsub(format, "%%(%d+)%$", "%%")
    local newParams = {}
    table.insert(newParams, format)
    local defaultIndex = 1
    for i, index in ipairs(indexs) do
      table.insert(newParams, params[index + 1])
      defaultIndex = defaultIndex + 1
    end
    for index = defaultIndex, #params do
      table.insert(newParams, params[index + 1])
    end
    local state, result = pcall(string_format, unpack(newParams))
    if state == true then
      return result
    else
      error(result, 2)
    end
  end
  string.formatEx = formatEx
end
def.method().OverrideStringFormatFunc = function()
  utility.overridestringformat()
end
return ModuleSetting.Commit()
