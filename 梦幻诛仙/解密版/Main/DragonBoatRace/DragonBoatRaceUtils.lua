local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DragonBoatRaceUtils = Lplus.Class(MODULE_NAME)
local def = DragonBoatRaceUtils.define
local _constants
local function initConstants(...)
  _constants = {}
  if constant.TODO then
    for k, v in pairs(constant.TODO) do
      _constants[k] = v
    end
  end
  local debug = true
  if debug then
    _constants.ENTRY_NPC_ID = 0
  end
end
def.static("string", "=>", "dynamic").GetConstant = function(name)
  if _constants == nil then
    initConstants()
  end
  return _constants[name]
end
def.static("number", "=>", "table").GetRaceActivityCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_ACTIVITY_CFG, id)
  if record == nil then
    warn("GetRaceActivityCfg(" .. id .. ") return nil")
    return nil
  end
  return DragonBoatRaceUtils._GetRaceActivityCfg(record)
end
def.static("userdata", "=>", "table")._GetRaceActivityCfg = function(record)
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.raceId = record:GetIntValue("raceId")
  cfg.npcId = record:GetIntValue("npcId")
  cfg.joinActivityServiceId = record:GetIntValue("joinActivityServiceId")
  cfg.switchId = record:GetIntValue("switchId")
  return cfg
end
def.static("=>", "table").GetAllRaceActivityCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DRAGON_BOAT_RACE_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local cfg = DragonBoatRaceUtils._GetRaceActivityCfg(record)
    cfgs[cfg.activityId] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetRaceCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_CFG, id)
  if record == nil then
    warn("GetRaceCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.boatInitSpeed = record:GetIntValue("boatInitSpeed")
  cfg.trackLen = record:GetIntValue("trackLen")
  cfg.trackCount = record:GetIntValue("trackCount")
  cfg.teamCount = record:GetIntValue("teamCount")
  cfg.showScoreTime = record:GetIntValue("showScoreTime")
  cfg.correctFXId = record:GetIntValue("correctCommandSpecialEffectId")
  cfg.wrongFXId = record:GetIntValue("wrongCommandSpecialEffectId")
  cfg.beginCountDownMusicId = record:GetIntValue("beginCountDownMusicId")
  cfg.backgroundMusicId = record:GetIntValue("backgroundMusicId")
  cfg.endPointMusicId = record:GetIntValue("endPointMusicId")
  cfg.endPointFXId = record:GetIntValue("endPointSpecialEffectId")
  cfg.hoverTipsId = record:GetIntValue("hoverTipsId")
  cfg.previewGUIId = record:GetIntValue("previewGUIId")
  cfg.activityGUIId = record:GetIntValue("activityGUIId")
  cfg.carrierName = record:GetStringValue("vehicleName")
  return cfg
end
def.static("number", "=>", "table").GetRacePhaseCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_PHASE_CFG, id)
  if record == nil then
    warn("GetRacePhaseCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.phaseNo = record:GetIntValue("phaseNo")
  cfg.commandTime = record:GetIntValue("commandTime")
  cfg.tipTime = record:GetIntValue("tipTime")
  cfg.speedUpUnit = record:GetFloatValue("speedUpUnit")
  cfg.maxSpeed = record:GetFloatValue("maxSpeed")
  cfg.speedDownUnit = record:GetFloatValue("speedDownUnit")
  cfg.minSpeed = record:GetFloatValue("minSpeed")
  cfg.prepareTime = record:GetIntValue("prepareTime")
  cfg.tip = record:GetStringValue("tip")
  cfg.accelerateFXId = record:GetIntValue("speedUpSpecialEffectId")
  cfg.decelerateFXId = record:GetIntValue("speedDownSpecialEffectId")
  return cfg
end
def.static("number", "=>", "table").GetRaceEventCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_EVENT_CFG, id)
  if record == nil then
    warn("GetRaceEventCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.FXId = record:GetIntValue("specialEffectId")
  cfg.FXAttachPos = record:GetIntValue("specialEffectLocation")
  cfg.speedChange = record:GetIntValue("delta")
  cfg.tip = record:GetStringValue("tip")
  return cfg
end
def.static("number", "=>", "table").GetRaceEventTriggerCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_EVENT_TRIGGER_CFG, id)
  if record == nil then
    warn("GetRaceEventTriggerCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.eventTimeType = record:GetIntValue("eventTimeType")
  cfg.eventTime = record:GetIntValue("eventTime")
  cfg.tipTime = record:GetIntValue("tipTime")
  return cfg
end
def.static("number", "=>", "table").GetRaceCommands = function(raceCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAGON_BOAT_RACE_COMMAND_CFG, raceCfgId)
  if record == nil then
    warn("GetRaceCommands(" .. raceCfgId .. ") return {}")
    return {}
  end
  local commands = {}
  local commandListStruct = record:GetStructValue("commandListStruct")
  local size = commandListStruct:GetVectorSize("commandList")
  for i = 0, size - 1 do
    local vectorRow = commandListStruct:GetVectorValueByIdx("commandList", i)
    local command = {}
    command.value = vectorRow:GetIntValue("commandType")
    command.name = vectorRow:GetStringValue("commandName")
    commands[command.value] = command
  end
  return commands
end
def.static("number", "=>", "userdata").GenAITeamId = function(no)
  local BASE = 0
  return Int64.new(BASE - no)
end
return DragonBoatRaceUtils.Commit()
