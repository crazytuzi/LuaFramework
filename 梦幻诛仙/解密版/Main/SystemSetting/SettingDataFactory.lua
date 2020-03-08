local Lplus = require("Lplus")
local SettingDataFactory = Lplus.Class("SettingDataFactory")
local SettingModule = require("Main.SystemSetting.data.SettingData")
local SystemSettingModule = Lplus.ForwardDeclare("SystemSettingModule")
local SettingData = require("Main.SystemSetting.data.SettingData")
local SoundSettingData = require("Main.SystemSetting.data.SoundSettingData")
local ToggleSettingData = require("Main.SystemSetting.data.ToggleSettingData")
local ChoiceSettingData = require("Main.SystemSetting.data.ChoiceSettingData")
local NumSettingData = require("Main.SystemSetting.data.NumSettingData")
local def = SettingDataFactory.define
local CreateAndInit = function(class, type)
  local obj = class()
  obj.type = type
  return obj
end
def.static("number", "=>", "table").CreateSettingData = function(type)
  local SettingDataType = SystemSettingModule.SettingDataType
  if type == SettingDataType.Toggle then
    return CreateAndInit(ToggleSettingData, type)
  elseif type == SettingDataType.Sound then
    return CreateAndInit(SoundSettingData, type)
  elseif type == SettingDataType.Choice then
    return CreateAndInit(ChoiceSettingData, type)
  elseif type == SettingDataType.Num then
    return CreateAndInit(NumSettingData, type)
  else
    return CreateAndInit(SettingData, type)
  end
end
return SettingDataFactory.Commit()
