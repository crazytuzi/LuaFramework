local Lplus = require("Lplus")
local MenpaiStarUtils = Lplus.Class("MenpaiStarUtils")
local def = MenpaiStarUtils.define
def.static("number", "=>", "table").GetMenpaiStarMainCfg = function(menpaiId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MENPAISTAR_CMenPaiStarNpcCfg, menpaiId)
  if record == nil then
    warn("GetMenpaiStarMainCfg nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.menpai = record:GetIntValue("occupationType")
  cfg.npcId = record:GetIntValue("npcCfgid")
  cfg.effectNpcId = record:GetIntValue("effectNpcCfgid")
  cfg.voteServiceId = record:GetIntValue("voteServiceCfgid")
  cfg.candidateServiceId = record:GetIntValue("campaignBattleServiceCfgid")
  cfg.voterServiceId = record:GetIntValue("voteBattleServiceCfgid")
  return cfg
end
def.static("=>", "table").GetAllMenpaiStarMainCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MENPAISTAR_CMenPaiStarNpcCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.menpai = entry:GetIntValue("occupationType")
    cfg.npcId = entry:GetIntValue("npcCfgid")
    cfg.effectNpcId = entry:GetIntValue("effectNpcCfgid")
    cfg.voteServiceId = entry:GetIntValue("voteServiceCfgid")
    cfg.candidateServiceId = entry:GetIntValue("campaignBattleServiceCfgid")
    cfg.voterServiceId = entry:GetIntValue("voteBattleServiceCfgid")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "number", "number").GetPointByLv = function(lv)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MENPAISTAR_CVotePointCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.maxLevel = entry:GetIntValue("maxLevel")
    cfg.point = entry:GetIntValue("point")
    cfg.overflow = entry:GetIntValue("overflow")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(list, function(a, b)
    return a.maxLevel < b.maxLevel
  end)
  local point, overflow
  for _, v in ipairs(list) do
    if lv <= v.maxLevel then
      point = v.point
      overflow = v.overflow
      break
    end
  end
  if point == nil or overflow == nil then
    point = list[#list].point or 0
    overflow = list[#list].overflow or 0
  end
  return point, overflow
end
def.static("=>", "table").GetCanvassText = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MENPAISTAR_CCanvassTextCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local text = entry:GetStringValue("text")
    table.insert(list, text)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("=>", "table").GetVoteMoneyCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MENPAISTAR_CVoteAwardCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local value = entry:GetIntValue("value")
    table.insert(list, value)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(list)
  return list
end
def.static("=>", "table").GetVoteNumCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MENPAISTAR_SVoteNumCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local num = entry:GetIntValue("num")
    table.insert(list, num)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(list)
  return list
end
MenpaiStarUtils.Commit()
return MenpaiStarUtils
