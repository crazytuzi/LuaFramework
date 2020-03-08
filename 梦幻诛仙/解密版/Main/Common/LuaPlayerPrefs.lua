local Lplus = require("Lplus")
local LuaPlayerPrefs = Lplus.Class("LuaPlayerPrefs")
local LoginModule = require("Main.Login.LoginModule")
local def = LuaPlayerPrefs.define
local Scope = {
  Global = 1,
  Account = 2,
  Role = 3
}
def.const("table").Scope = Scope
def.const("string").Version = "0.1"
local LUA_PREFIX = "L_"
local ScopePrefixs = {
  [Scope.Global] = "G",
  [Scope.Account] = "A",
  [Scope.Role] = "R"
}
local function serialize(o, out)
  if type(o) == "number" then
    table.insert(out, o)
  elseif type(o) == "string" then
    o = string.gsub(o, "[\"\\]", "\\%1")
    table.insert(out, string.format("\"%s\"", o))
  elseif type(o) == "table" then
    table.insert(out, "{")
    for k, v in pairs(o) do
      if type(k) == "number" then
        table.insert(out, string.format("[%d]", k))
      else
        table.insert(out, string.format("['%s']", tostring(k)))
      end
      table.insert(out, "=")
      serialize(v, out)
      table.insert(out, ",")
    end
    table.insert(out, "}")
  elseif type(o) == "userdata" then
    table.insert(out, string.format("'%s'", tostring(o)))
  else
    error("cannot serialize a " .. type(o))
  end
end
local mt = {
  __tostring = function(t)
    local out = {}
    table.insert(out, "return ")
    serialize(t, out)
    return table.concat(out, "")
  end
}
local function GetScopeID(scope)
  local base = ScopePrefixs[scope]
  local id = base
  if scope == Scope.Global then
    id = string.format("%s_", id)
  elseif scope == Scope.Account then
    local account = LoginModule.Instance().userName
    id = string.format("%s_%s_", id, account)
  elseif scope == Scope.Role then
    if LoginModule.Instance().lastLoginRoleId == nil then
      return nil
    end
    local roleId = tostring(LoginModule.Instance().lastLoginRoleId)
    id = string.format("%s_%s_", id, roleId)
  end
  return id
end
local function GenKey(scope, key)
  local scopeId = GetScopeID(scope)
  if scopeId == nil then
    return nil
  end
  return LUA_PREFIX .. scopeId .. key
end
def.static("string", "table").SetGlobalTable = function(key, t)
  setmetatable(t, mt)
  local str = tostring(t)
  LuaPlayerPrefs.SetString(Scope.Global, key, str)
end
def.static("string", "=>", "table").GetGlobalTable = function(key)
  local str = LuaPlayerPrefs.GetString(Scope.Global, key)
  return assert(loadstring(str))()
end
def.static("string", "number").SetGlobalInt = function(key, value)
  LuaPlayerPrefs.SetInt(Scope.Global, key, value)
end
def.static("string", "=>", "number").GetGlobalInt = function(key)
  return LuaPlayerPrefs.GetInt(Scope.Global, key)
end
def.static("string", "number").SetGlobalFloat = function(key, value)
  LuaPlayerPrefs.SetFloat(Scope.Global, key, value)
end
def.static("string", "=>", "number").GetGlobalFloat = function(key)
  return LuaPlayerPrefs.GetFloat(Scope.Global, key)
end
def.static("string", "string").SetGlobalString = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Global, key, value)
end
def.static("string", "=>", "string").GetGlobalString = function(key)
  return LuaPlayerPrefs.GetString(Scope.Global, key)
end
def.static("string", "number").SetGlobalNumber = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Global, key, tostring(value))
end
def.static("string", "=>", "number").GetGlobalNumber = function(key)
  return tonumber(LuaPlayerPrefs.GetString(Scope.Global, key))
end
def.static("string", "=>", "boolean").HasGlobalKey = function(key)
  return LuaPlayerPrefs.HasKey(Scope.Global, key)
end
def.static("string").DeleteGlobalKey = function(key)
  LuaPlayerPrefs.DeleteKey(Scope.Global, key)
end
def.static("string", "table").SetAccountTable = function(key, t)
  setmetatable(t, mt)
  local str = tostring(t)
  LuaPlayerPrefs.SetString(Scope.Account, key, str)
end
def.static("string", "=>", "table").GetAccountTable = function(key)
  local str = LuaPlayerPrefs.GetString(Scope.Account, key)
  return assert(loadstring(str))()
end
def.static("string", "number").SetAccountInt = function(key, value)
  LuaPlayerPrefs.SetInt(Scope.Account, key, value)
end
def.static("string", "=>", "number").GetAccountInt = function(key)
  return LuaPlayerPrefs.GetInt(Scope.Account, key)
end
def.static("string", "number").SetAccountFloat = function(key, value)
  LuaPlayerPrefs.SetFloat(Scope.Account, key, value)
end
def.static("string", "=>", "number").GetAccountFloat = function(key)
  return LuaPlayerPrefs.GetFloat(Scope.Account, key)
end
def.static("string", "string").SetAccountString = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Account, key, value)
end
def.static("string", "=>", "string").GetAccountString = function(key)
  return LuaPlayerPrefs.GetString(Scope.Account, key)
end
def.static("string", "number").SetAccountNumber = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Account, key, tostring(value))
end
def.static("string", "=>", "number").GetAccountNumber = function(key)
  return tonumber(LuaPlayerPrefs.GetString(Scope.Account, key))
end
def.static("string", "=>", "boolean").HasAccountKey = function(key)
  return LuaPlayerPrefs.HasKey(Scope.Account, key)
end
def.static("string").DeleteAccountKey = function(key)
  LuaPlayerPrefs.DeleteKey(Scope.Account, key)
end
def.static("string", "table").SetRoleTable = function(key, t)
  setmetatable(t, mt)
  local str = tostring(t)
  LuaPlayerPrefs.SetString(Scope.Role, key, str)
end
def.static("string", "=>", "table").GetRoleTable = function(key)
  local str = LuaPlayerPrefs.GetString(Scope.Role, key)
  return assert(loadstring(str))()
end
def.static("string", "number").SetRoleInt = function(key, value)
  LuaPlayerPrefs.SetInt(Scope.Role, key, value)
end
def.static("string", "=>", "number").GetRoleInt = function(key)
  return LuaPlayerPrefs.GetInt(Scope.Role, key)
end
def.static("string", "number").SetRoleFloat = function(key, value)
  LuaPlayerPrefs.SetFloat(Scope.Role, key, value)
end
def.static("string", "=>", "number").GetRoleFloat = function(key)
  return LuaPlayerPrefs.GetFloat(Scope.Role, key)
end
def.static("string", "string").SetRoleString = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Role, key, value)
end
def.static("string", "=>", "string").GetRoleString = function(key)
  return LuaPlayerPrefs.GetString(Scope.Role, key)
end
def.static("string", "number").SetRoleNumber = function(key, value)
  LuaPlayerPrefs.SetString(Scope.Role, key, tostring(value))
end
def.static("string", "=>", "number").GetRoleNumber = function(key)
  return tonumber(LuaPlayerPrefs.GetString(Scope.Role, key)) or 0
end
def.static("string", "=>", "boolean").HasRoleKey = function(key)
  return LuaPlayerPrefs.HasKey(Scope.Role, key)
end
def.static("string").DeleteRoleKey = function(key)
  LuaPlayerPrefs.DeleteKey(Scope.Role, key)
end
def.static("number", "string", "table").SetTable = function(scope, key, t)
  setmetatable(t, mt)
  local str = tostring(t)
  LuaPlayerPrefs.SetString(key, str)
end
def.static("number", "string", "=>", "table").GetTable = function(scope, key)
  local str = LuaPlayerPrefs.GetString(key)
  local t = assert(loadstring(str))()
  return t
end
def.static("number", "string", "number").SetInt = function(scope, key, value)
  local key = GenKey(scope, key)
  if key == nil then
    return
  end
  PlayerPrefs.SetInt(key, value)
end
def.static("number", "string", "=>", "number").GetInt = function(scope, key)
  local key = GenKey(scope, key)
  if key == nil then
    return 0
  end
  LuaPlayerPrefs._CheckVersion()
  local value = PlayerPrefs.GetInt(key)
  return value
end
def.static("number", "string", "number").SetFloat = function(scope, key, value)
  local key = GenKey(scope, key)
  if key == nil then
    return
  end
  PlayerPrefs.SetFloat(key, value)
end
def.static("number", "string", "=>", "number").GetFloat = function(scope, key)
  local key = GenKey(scope, key)
  if key == nil then
    return 0
  end
  LuaPlayerPrefs._CheckVersion()
  local value = PlayerPrefs.GetFloat(key)
  return value
end
def.static("number", "string", "string").SetString = function(scope, key, value)
  local key = GenKey(scope, key)
  if key == nil then
    return
  end
  if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    value = WWW.EscapeURL(value)
  end
  PlayerPrefs.SetString(key, value)
end
def.static("number", "string", "=>", "string").GetString = function(scope, key)
  local key = GenKey(scope, key)
  if key == nil then
    return ""
  end
  LuaPlayerPrefs._CheckVersion()
  local value = PlayerPrefs.GetString(key)
  if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    value = WWW.UnEscapeURL(value)
  end
  return value
end
def.static("number", "string", "number").SetNumber = function(scope, key, value)
  LuaPlayerPrefs.SetString(key, tostring(value))
end
def.static("number", "string", "=>", "number").GetNumber = function(scope, key)
  return tonumber(LuaPlayerPrefs.GetString(key))
end
def.static("number", "string", "=>", "boolean").HasKey = function(scope, key)
  local key = GenKey(scope, key)
  if key == nil then
    return false
  end
  return PlayerPrefs.HasKey(key)
end
def.static("number", "string").DeleteKey = function(scope, key)
  local key = GenKey(scope, key)
  if key == nil then
    return
  end
  PlayerPrefs.DeleteKey(key)
end
def.static().DeleteAll = function()
  PlayerPrefs.DeleteAll()
end
def.static().Save = function()
  PlayerPrefs.Save()
end
local versionKey = "__LUA__PREFS__VERSION__"
local prefsVersion
def.static()._CheckVersion = function()
end
return LuaPlayerPrefs.Commit()
