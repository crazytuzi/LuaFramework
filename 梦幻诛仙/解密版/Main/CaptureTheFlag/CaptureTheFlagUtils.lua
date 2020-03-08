local Lplus = require("Lplus")
local CaptureTheFlagUtils = Lplus.Class("CaptureTheFlagUtils")
local def = CaptureTheFlagUtils.define
def.static("number", "=>", "table").GetBattleCfg = function(battleId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CSingleBattleCfg, battleId)
  if not record then
    warn("GetBattleCfg nil:", battleId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.playLibId = record:GetIntValue("playLibId")
  cfg.matchDuration = record:GetIntValue("matchDuration")
  cfg.prepareDuration = record:GetIntValue("prepareDuration")
  cfg.cleanDuration = record:GetIntValue("cleanDuration")
  cfg.fightMap = record:GetIntValue("fightMap")
  cfg.camp1 = record:GetIntValue("camp1")
  cfg.camp2 = record:GetIntValue("camp2")
  cfg.protectedInterval = record:GetIntValue("protectedInterval")
  cfg.diffScores = record:GetIntValue("diffScores")
  return cfg
end
def.static("number", "=>", "table").GetCampCfg = function(campId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CCampCfg, campId)
  if not record then
    warn("GetCampCfg nil:", campId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.campName = record:GetStringValue("campName")
  cfg.campNameIcon = record:GetStringValue("campNameIcon")
  cfg.icon = record:GetStringValue("icon")
  cfg.enterX = record:GetIntValue("enterX")
  cfg.enterY = record:GetIntValue("enterY")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.gatherIcon = record:GetIntValue("grabIngIconId")
  return cfg
end
def.static("number", "=>", "table").GetBattlePlays = function(playLib)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CTSingleBattlePlayLibCfg, playLib)
  if not record then
    warn("GetBattlePlays nil:", campId)
    return nil
  end
  local playList = {}
  local playStruct = record:GetStructValue("playStruct")
  local playSize = DynamicRecord.GetVectorSize(playStruct, "playList")
  for i = 0, playSize - 1 do
    local rec = playStruct:GetVectorValueByIdx("playList", i)
    local playType = rec:GetIntValue("playType")
    local playId = rec:GetIntValue("cfgId")
    playList[playType] = playId
  end
  return playList
end
def.static("number", "=>", "table").GetCTFCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CTGrabPositionCfg, cfgId)
  if not record then
    warn("GetCTFCfg nil:", cfgId)
    return nil
  end
  local towers = {}
  local positionStruct = record:GetStructValue("positionStruct")
  local positionSize = DynamicRecord.GetVectorSize(positionStruct, "positionList")
  for i = 0, positionSize - 1 do
    local rec = positionStruct:GetVectorValueByIdx("positionList", i)
    local towerId = rec:GetIntValue("position")
    table.insert(towers, towerId)
  end
  return towers
end
def.static("number", "=>", "table").GetTowerCfg = function(towerId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CPositionInfoCfg, towerId)
  if not record then
    warn("GetTowerCfg nil:", towerId)
    return nil
  end
  local tower = {}
  tower.id = id
  tower.positionName = record:GetStringValue("positionName")
  tower.positionX = record:GetIntValue("positionX")
  tower.positionY = record:GetIntValue("positionY")
  tower.sourceAddValue = record:GetIntValue("sourceAddValue")
  tower.positionGrabInterval = record:GetIntValue("positionGrabInterval")
  tower.positionProtectInterval = record:GetIntValue("positionProtectInterval")
  local defaultPositionMapCfgId = record:GetIntValue("defaultPositionMapCfgId")
  tower.defaultPositionMapCfg = CaptureTheFlagUtils.GetTowerEffect(defaultPositionMapCfgId)
  tower.camps = {}
  local campStruct = record:GetStructValue("campStruct")
  local campSize = DynamicRecord.GetVectorSize(campStruct, "campList")
  for i = 0, campSize - 1 do
    local rec = campStruct:GetVectorValueByIdx("campList", i)
    local campId = rec:GetIntValue("campId")
    local positionCfg = rec:GetIntValue("positionCfg")
    tower.camps[campId] = CaptureTheFlagUtils.GetTowerEffect(positionCfg)
  end
  return tower
end
def.static("number", "=>", "table").GetTowerEffect = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CPositionMapCfg, id)
  if not record then
    warn("GetTowerEffect nil:", id)
    return nil
  end
  local cfg = {}
  cfg.modelId = record:GetIntValue("modelId")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.miniMapIcon = record:GetIntValue("miniMapIcon")
  cfg.mapModelId = record:GetIntValue("mapModelId")
  cfg.positionX = record:GetIntValue("positionX")
  cfg.positionY = record:GetIntValue("positionY")
  return cfg
end
def.static("number", "=>", "table").GetAreaCfg = function(areaId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CGatherAreaCfg, areaId)
  if not record then
    warn("GetAreaCfg nil:", areaId)
    return nil
  end
  local cfg = {}
  cfg.id = areaId
  cfg.name = record:GetStringValue("areaName")
  return cfg
end
def.static("number", "=>", "table").GetGatherItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CGatherItemCfg, id)
  if not record then
    warn("GetGatherItemCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.name = record:GetStringValue("gatherItemname")
  cfg.interval = record:GetIntValue("gatherInterval")
  cfg.source = record:GetIntValue("source")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.icon = record:GetIntValue("miniMapIcon")
  return cfg
end
def.static("number", "=>", "table").GetResPointCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CResourcePointCfg, id)
  if not record then
    warn("GetResPointCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.initial_resource_point = record:GetIntValue("initial_resource_point")
  cfg.max_resource_point = record:GetIntValue("max_resource_point")
  return cfg
end
def.static("number", "=>", "table").GetBuffInfoCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBuffInfoCfg, id)
  if not record then
    warn("GetBuffInfoCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.buff_cfg_id = record:GetIntValue("buff_cfg_id")
  cfg.type = record:GetIntValue("type")
  cfg.model_id = record:GetIntValue("model_id")
  cfg.mini_map_icon_id = record:GetIntValue("mini_map_icon_id")
  cfg.effect_id = record:GetIntValue("effect_id")
  return cfg
end
def.static("number", "=>", "number").GetBuffInfoCfgIdByBuffCfgId = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BuffCfgid2InfoCfgidCfg, id)
  if not record then
    warn("GetBuffInfoCfgIdByBuffCfgId -1:", id)
    return -1
  end
  local buff_info_cfg_id = record:GetIntValue("buff_info_cfg_id")
  return buff_info_cfg_id
end
def.static("number", "=>", "table").GetMissionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBattleTaskCfg, id)
  if not record then
    warn("GetMissionCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.taskType = record:GetIntValue("taskType")
  cfg.needNum = record:GetIntValue("needNum")
  cfg.taskDesc = record:GetStringValue("taskDesc")
  return cfg
end
def.static("string").ShowInBattlefieldChannel = function(msg)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.BATTLEFIELD)
  Toast(msg)
end
return CaptureTheFlagUtils.Commit()
