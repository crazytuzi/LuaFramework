local MODULE_NAME = (...)
local Lplus = require("Lplus")
local HomeVisitorUtils = Lplus.Class(MODULE_NAME)
local def = HomeVisitorUtils.define
def.static("number", "=>", "number").GetActionIdByIdx = function(idx)
  return 0
end
def.static("=>", "table").GetAllKindsOfGames = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MYSTERY_VISITOR_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    data.id = record:GetIntValue("id")
    data.desc = record:GetStringValue("desc")
    data.type = record:GetIntValue("type")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetGameCfgById = function(id)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MYSTERY_VISITOR_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_MYSTERY_VISITOR_CFG error<<<<")
    return nil
  end
  retData.id = record:GetIntValue("id")
  retData.desc = record:GetIntValue("desc")
  retData.type = record:GetIntValue("type")
  return retData
end
def.static("number", "=>", "table").GetDanceCfgById = function(id)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MYSTERY_VISITOR_DANCE_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_MYSTERY_VISITOR_DANCE_CFG error<<<<")
    return nil
  end
  retData.id = record:GetIntValue("id")
  retData.npc_id = record:GetIntValue("mystery_visitor_npc_id")
  retData.npc_service_id = record:GetIntValue("mystery_visitor_npc_service_id")
  retData.action_ids = {}
  local action_ids = retData.action_ids
  local actionInfoVecStruct = record:GetStructValue("action_infosStruct")
  local actionVecSize = actionInfoVecStruct:GetVectorSize("action_infos")
  for j = 1, actionVecSize do
    local oneResData = {}
    local resultsRecord = actionInfoVecStruct:GetVectorValueByIdx("action_infos", j - 1)
    local actionId = resultsRecord:GetIntValue("action_id")
    table.insert(action_ids, actionId)
  end
  return retData
end
def.static("number", "=>", "table").GetMusicCfgById = function(id)
  local retData = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MYSTERY_VISITOR_MUSIC, id)
  if record == nil then
    warn(">>>>Load DATA_MYSTERY_VISITOR_MUSIC error<<<<")
    return retData
  end
  retData.music_game_id = record:GetIntValue("music_game_id")
  retData.npc_id = record:GetIntValue("mystery_visitor_npc_id")
  retData.npc_service_id = record:GetIntValue("mystery_visitor_npc_service_id")
  retData.need_right_num = record:GetIntValue("need_right_num")
  return retData
end
def.static("=>", "table").GetNPCInfos = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MYSTERY_VISITOR_NPCINFO)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local npc_lib_id = record:GetIntValue("npc_lib_id")
    retData[npc_lib_id] = {}
    local npc_ids = retData[npc_lib_id]
    local npcidsStruct = record:GetStructValue("npcidsStruct")
    local npcVecSize = npcidsStruct:GetVectorSize("npcids")
    for j = 1, npcVecSize do
      local npcidCfg = npcidsStruct:GetVectorValueByIdx("npcids", j - 1)
      local map_cfg_id = npcidCfg:GetIntValue("map_cfg_id")
      local npc_id = npcidCfg:GetIntValue("npc_id")
      npc_ids[map_cfg_id] = npc_id
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
local MysteryVisitorType = require("consts.mzm.gsp.homeland.confbean.MysteryVisitorType")
def.static("number", "=>", "table").GetCfgInfoById = function(id)
  local retData = {}
  local gameInfo = HomeVisitorUtils.GetGameCfgById(id)
  if gameInfo == nil then
    return nil
  end
  if gameInfo.type == MysteryVisitorType.DANCE then
    local danceCfg = HomeVisitorUtils.GetDanceCfgById(gameInfo.id)
    retData.npc_id = danceCfg.npc_id
  elseif gameInfo.type == MysteryVisitorType.MUSIC_GAME then
    local musicCfg = HomeVisitorUtils.GetMusicCfgById(gameInfo.id)
    retData.npc_id = musicCfg.npc_id
  else
    return nil
  end
  return retData
end
return HomeVisitorUtils.Commit()
