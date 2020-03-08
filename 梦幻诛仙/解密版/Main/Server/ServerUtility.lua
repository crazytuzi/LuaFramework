local Lplus = require("Lplus")
local ServerUtility = Lplus.Class("ServerUtility")
local AwardServerTableName = require("consts.mzm.gsp.award.confbean.AwardServerTableName")
local def = ServerUtility.define
local instance
def.static("=>", ServerUtility).Instance = function()
  if instance == nil then
    instance = ServerUtility()
    instance:Init()
  end
  return instance
end
def.static("number", "=>", "table").GetServerLevelCfg = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SERVER_LEVEL_CFG, level)
  if record == nil then
    warn("GetServerLevelCfg(" .. level .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = level
  cfg.duration = record:GetIntValue("duration")
  return cfg
end
def.static("number", "=>", "number").GetNextServerLevel = function(curlevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SERVER_LEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local nextlevel = curlevel
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local level = record:GetIntValue("level")
    if curlevel < level then
      if curlevel < nextlevel then
        nextlevel = math.min(nextlevel, level)
      else
        nextlevel = level
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return nextlevel
end
def.static("number", "number", "=>", "table").GetServerLevelAwardCfg = function(roleLevel, serverLevel)
  local MultiXmlHelper = require("Main.Common.MultiXmlHelper")
  local xmlDataType = MultiXmlHelper.GetXmlDataType()
  if xmlDataType < 0 then
    return ServerUtility.GetDefaultServerLevelAwardCfg(roleLevel, serverLevel)
  end
  local mapCfg = ServerUtility.GetMultiServerLevelMappingCfg(xmlDataType)
  if mapCfg == nil then
    return ServerUtility.GetDefaultServerLevelAwardCfg(roleLevel, serverLevel)
  end
  return ServerUtility._GetServerLevelAwardCfg(roleLevel, serverLevel, mapCfg.mapType)
end
def.static("number", "number", "=>", "table").GetDefaultServerLevelAwardCfg = function(roleLevel, serverLevel)
  return ServerUtility._GetServerLevelAwardCfg(roleLevel, serverLevel, AwardServerTableName.serverCfgDefault or 0)
end
def.static("number", "number", "number", "=>", "table")._GetServerLevelAwardCfg = function(roleLevel, serverLevel, mappingType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MULTI_SERVER_LEVEL_AWARD_CFG, mappingType)
  if record == nil then
    warn(string.format("GetRecord(%s,%d) return nil", CFG_PATH.DATA_MULTI_SERVER_LEVEL_AWARD_CFG, mappingType))
    return nil
  end
  local cfgsStruct = record:GetStructValue("cfgsStruct")
  local size = cfgsStruct:GetVectorSize("cfgs")
  local selectedCfg
  for i = 0, size - 1 do
    local record = cfgsStruct:GetVectorValueByIdx("cfgs", i)
    selectedCfg = ServerUtility._FilterServerLevelAwardEffect(record, selectedCfg, roleLevel, serverLevel)
  end
  return selectedCfg
end
def.static("userdata", "table", "number", "number", "=>", "table")._FilterServerLevelAwardEffect = function(record, selectedCfg, roleLevel, serverLevel)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.levelMin = record:GetIntValue("levelMin")
  cfg.levelMax = record:GetIntValue("levelMax")
  cfg.effectLevel = record:GetIntValue("effectLevel")
  local deltaLevel = serverLevel - roleLevel
  if deltaLevel >= cfg.levelMin and deltaLevel <= cfg.levelMax and serverLevel >= cfg.effectLevel then
    cfg.roleExpMod = record:GetFloatValue("roleExpMod")
    if selectedCfg == nil or selectedCfg.effectLevel < cfg.effectLevel then
      selectedCfg = cfg
    end
  end
  return selectedCfg
end
def.static("number", "=>", "table").GetMultiServerLevelMappingCfg = function(xmlDataType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MULTI_SERVER_LEVEL_MAPPING_CFG, xmlDataType)
  if record == nil then
    warn("GetMultiServerLevelMappingCfg(" .. xmlDataType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.mapType = record:GetIntValue("cfgName")
  return cfg
end
def.static("=>", "string").GetServerLevelTipContent = function()
  local nextStartTime = require("Main.Server.ServerModule").Instance():GetNextServerLevelStartTime()
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local tipContent = string.format(textRes.Hero[3], serverLevelData.level)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local cfg = ServerUtility.GetServerLevelAwardCfg(heroProp.level, serverLevelData.level)
  if cfg and cfg.roleExpMod > 1 then
    local bonouce = require("Common.MathHelper").Round((cfg.roleExpMod - 1) * 100)
    tipContent = tipContent .. "\n" .. string.format(textRes.Hero[40], bonouce)
  end
  if serverLevelData.reachMaxLevel then
    local maxLevelTip = textRes.Server[5]
    tipContent = string.format([[
%s
%s]], tipContent, maxLevelTip)
  elseif nextStartTime ~= 0 then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local t = AbsoluteTimer.GetServerTimeTable(nextStartTime:ToNumber())
    local nextTimeTip = string.format(textRes.Hero[18], t.year, t.month, t.day, t.hour, t.min)
    tipContent = string.format([[
%s
%s]], tipContent, nextTimeTip)
  end
  local tipId = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("SERVER_LEVEL_DESC_ID")
  local hoverTip = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  if hoverTip ~= "" then
    tipContent = tipContent .. "\n" .. hoverTip
  end
  return tipContent
end
def.static().ShowServerLevelTip = function()
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tmpPosition = {
    x = 0,
    y = 0,
    z = 0
  }
  local tipContent = ServerUtility.GetServerLevelTipContent()
  CommonUITipsDlg.Instance():ShowDlg(tipContent, tmpPosition)
end
return ServerUtility.Commit()
