local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SocialSpaceSettingMan = Lplus.Class(MODULE_NAME)
local def = SocialSpaceSettingMan.define
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SPACE_SETTING_KEY = "SOCIAL_SPACE_SETTING_KEY"
def.const("table").ACCESS_TYPE = ECSpaceMsgs.ACCESS_TYPE
def.const("number").SETTING_ENABLE = 1
def.const("number").SETTING_DISABLE = 0
local instance
def.static("=>", SocialSpaceSettingMan).Instance = function()
  if instance == nil then
    instance = SocialSpaceSettingMan()
    instance:Init()
  end
  return instance
end
local _setting_cache
def.static("=>", "table").GetSpaceSetting = function()
  if _setting_cache then
    return _setting_cache
  end
  local hasSetting = LuaPlayerPrefs.HasRoleKey(SPACE_SETTING_KEY)
  local setting
  if hasSetting then
    setting = LuaPlayerPrefs.GetRoleTable(SPACE_SETTING_KEY)
  else
    setting = require("Main.SocialSpace.data.social_space_default_setting")
  end
  _setting_cache = setting
  return setting
end
def.static().SaveSpaceSetting = function()
  local setting = SocialSpaceSettingMan.GetSpaceSetting()
  LuaPlayerPrefs.SetRoleTable(SPACE_SETTING_KEY, setting)
  LuaPlayerPrefs.Save()
end
def.static("string", "dynamic").SetSpaceSetting = function(key, value)
  local setting = SocialSpaceSettingMan.GetSpaceSetting()
  setting[key] = value
end
def.static().Clear = function()
  _setting_cache = nil
end
return SocialSpaceSettingMan.Commit()
