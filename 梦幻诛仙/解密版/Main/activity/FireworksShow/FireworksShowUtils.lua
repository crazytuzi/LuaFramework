local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FireworksShowUtils = Lplus.Class(MODULE_NAME)
local def = FireworksShowUtils.define
local instance
def.static("=>", FireworksShowUtils).Instance = function()
  if instance == nil then
    instance = FireworksShowUtils()
  end
  return instance
end
def.static("=>", "table").GetAllFireworksShowCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FIREWORKS_FESTIVAL_CFG)
  if entries == nil then
    warn(string.format("GetAllFireworksShowCfgs return {}"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activityId")
    cfg.switchId = record:GetIntValue("switchId")
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetFireworksShowCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FIREWORKS_FESTIVAL_CFG, activityId)
  if record == nil then
    warn(string.format("GetFireworksShowCfg(%d) return nil", activityId))
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.findTime = record:GetIntValue("findTime")
  cfg.totalCount = record:GetIntValue("totalCount")
  cfg.needCount = record:GetIntValue("needCount")
  cfg.collectSucEffectId = record:GetIntValue("collectSucEffectId")
  cfg.countDown = record:GetIntValue("countDown")
  cfg.countDownEffectId = record:GetIntValue("countDownEffectId")
  cfg.showMapId = record:GetIntValue("showMapId")
  cfg.fireworkEffectId = record:GetIntValue("fireworkEffectId")
  cfg.fireworkEffectDuration = record:GetIntValue("fireworkEffectDuration")
  cfg.fireworkFixAwardId = record:GetIntValue("fireworkFixAwardId")
  cfg.awardInterval = record:GetIntValue("awardInterval")
  cfg.switchId = record:GetIntValue("switchId")
  cfg.collectSucMusicId = record:GetIntValue("collectSucMusicId")
  cfg.countDownMusicId = record:GetIntValue("countDownMusicId")
  cfg.fireworkMusicId = record:GetIntValue("fireworkMusicId")
  cfg.hitAwardCountMax = record:GetIntValue("hitAwardCountMax")
  cfg.showStartBroCount = record:GetIntValue("showStartBroCount")
  cfg.showStartBroInterval = record:GetIntValue("showStartBroInterval")
  return cfg
end
return FireworksShowUtils.Commit()
