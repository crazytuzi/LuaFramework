local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DoubleInteractionUtils = Lplus.Class(MODULE_NAME)
local Cls = DoubleInteractionUtils
local def = Cls.define
def.static("=>", "table").FastLoadAllCfg = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CDB_INTERACTION)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    data.id = record:GetIntValue("id")
    data.name = record:GetStringValue("name")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("userdata", "=>", "table")._readRecord = function(record)
  if record == nil then
    return nil
  end
  local data = {}
  data.id = record:GetIntValue("id")
  data.name = record:GetStringValue("name")
  data.actType = record:GetIntValue("actionType")
  data.activeActName = record:GetStringValue("activeActionName")
  data.passiceActName = record:GetStringValue("passiveActionName")
  data.playType = record:GetIntValue("playType")
  data.sfxId1 = record:GetIntValue("sfxId1")
  data.skeletonName1 = record:GetStringValue("skeletonName1")
  data.sfxId2 = record:GetIntValue("sfxId2")
  data.skeletonName2 = record:GetStringValue("skeletonName2")
  data.bAcceptAsDefault = record:GetCharValue("acceptInvitationOnTimeout") ~= 0
  data.channelStr = record:GetStringValue("channelDescription")
  data.strInviteDesc = record:GetStringValue("inviteDescription")
  data.extraSfxId = record:GetIntValue("extraSfxId")
  data.bCanSameGender = record:GetCharValue("targetCanBeSameGender") ~= 0
  data.relativeDir = record:GetIntValue("directionOffset")
  data.offsetX = record:GetIntValue("positionOffsetX")
  data.offsetY = record:GetIntValue("positionOffsetY")
  data.genderLimit = record:GetIntValue("activeRoleGenderLimit")
  data.boneName = record:GetStringValue("boneName") or ""
  data.activeRoleHideWeapon = record:GetCharValue("activeRoleHideWeapon") ~= 0
  data.passiveRoleHideWeapon = record:GetCharValue("passiveRoleHideWeapon") ~= 0
  return data
end
def.static("=>", "table").LoadAllCfg = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CDB_INTERACTION)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = Cls._readRecord(record)
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetCfgById = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CDB_INTERACTION, cfgId)
  if record == nil then
    warn("Load DATA_CDB_INTERACTION error cfgId", cfgId)
    return nil
  end
  local retData = Cls._readRecord(record)
  return retData
end
return Cls.Commit()
