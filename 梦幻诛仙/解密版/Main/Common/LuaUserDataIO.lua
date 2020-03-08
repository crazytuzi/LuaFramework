local MODULE_NAME = (...)
local Lplus = require("Lplus")
local LuaUserDataIO = Lplus.Class(MODULE_NAME)
local LuaTableWriter = require("Main.Common.LuaTableWriter")
local def = LuaUserDataIO.define
local _userDataDir
def.static("string", "string", "table").WriteUserData = function(relativePath, userDataName, userData)
  local absPath = LuaUserDataIO.GetUserDataAbsPath(relativePath)
  GameUtil.CreateDirectoryForFile(absPath)
  LuaTableWriter.SaveTable(userDataName, absPath, userData)
end
def.static("string", "=>", "table").ReadUserData = function(relativePath)
  local absPath = LuaUserDataIO.GetUserDataAbsPath(relativePath)
  local rets = {
    pcall(dofile, absPath)
  }
  if rets[1] == true then
    local userData = rets[2]
    return userData
  else
    local errorMsg = rets[2]
    warn(string.format("LuaUserDataIO: ReadUserData failed (%s).", errorMsg))
    return nil
  end
end
def.static("string", "=>", "boolean").IsUserDataExist = function(relativePath)
  local absPath = LuaUserDataIO.GetUserDataAbsPath(relativePath)
  if _G.FileExists(absPath) then
    return true
  else
    return false
  end
end
def.static("=>", "string").GetUserDataDir = function()
  if _userDataDir == nil then
    _userDataDir = string.format("%s/UserData", GameUtil.GetAssetsPath())
  end
  return _userDataDir
end
def.static("string", "=>", "string").GetUserDataAbsPath = function(relativePath)
  local userDataDir = LuaUserDataIO.GetUserDataDir()
  if relativePath == nil then
    return userDataDir
  end
  return string.format("%s/%s", userDataDir, relativePath)
end
return LuaUserDataIO.Commit()
