local Lplus = require("Lplus")
local MarriageUtils = Lplus.Class("MarriageUtils")
local TitleInterface = require("Main.title.TitleInterface")
local def = MarriageUtils.define
def.static("=>", "table").GetMarriageLevels = function()
  local levels = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MARRIAGE_LEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.marriageName = record:GetStringValue("marriageName")
    cfg.itemOrMoney = record:GetIntValue("itemOrMoney")
    cfg.moneyType = record:GetIntValue("moneyType")
    cfg.moneyNum = record:GetIntValue("moneyNum")
    cfg.itemid = record:GetIntValue("itemid")
    cfg.itemNum = record:GetIntValue("itemNum")
    cfg.marriageTip = record:GetIntValue("marriageTip")
    cfg.effectid = record:GetIntValue("effectid")
    cfg.lastTime = record:GetIntValue("lastTime")
    cfg.isToAll = record:GetCharValue("isToAll") ~= 0
    table.insert(levels, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return levels
end
def.static("number", "=>", "table").GetMarriageLevel = function(levelId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARRIAGE_LEVEL_CFG, levelId)
  if record ~= nil then
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.marriageName = record:GetStringValue("marriageName")
    cfg.itemOrMoney = record:GetIntValue("itemOrMoney")
    cfg.moneyType = record:GetIntValue("moneyType")
    cfg.moneyNum = record:GetIntValue("moneyNum")
    cfg.itemid = record:GetIntValue("itemid")
    cfg.itemNum = record:GetIntValue("itemNum")
    cfg.marriageTip = record:GetIntValue("marriageTip")
    cfg.effectid = record:GetIntValue("effectid")
    cfg.lastTime = record:GetIntValue("lastTime")
    cfg.isToAll = record:GetCharValue("isToAll") ~= 0
    return cfg
  else
    warn("Get MarriageCfg nil:" .. levelId)
    return nil
  end
end
def.static("=>", "table").GetRedPackets = function()
  local redPackets = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RED_PACKET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.giftName = record:GetStringValue("giftName")
    cfg.moneyType = record:GetIntValue("moneyType")
    cfg.moneyNum = record:GetIntValue("moneyNum")
    table.insert(redPackets, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return redPackets
end
def.static("number", "=>", "table").GetRedPacket = function(redId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RED_PACKET_CFG, redId)
  if record ~= nil then
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.giftName = record:GetStringValue("giftName")
    cfg.moneyType = record:GetIntValue("moneyType")
    cfg.moneyNum = record:GetIntValue("moneyNum")
    return cfg
  else
    warn("Get RedPacktCfg nil:" .. redId)
    return nil
  end
end
def.static("=>", "table").GetCoupleTitles = function()
  local titles = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COUPLE_APPELLATION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.titleName = record:GetStringValue("titleName")
    cfg.moneyType = record:GetIntValue("moneyType")
    cfg.moneyNum = record:GetIntValue("moneyNum")
    cfg.manTitle = record:GetIntValue("manTitle")
    cfg.womenTitle = record:GetIntValue("womenTitle")
    table.insert(titles, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return titles
end
def.static("number", "string", "=>", "string").CombineTitle = function(titleId, name)
  local cfg = TitleInterface.GetAppellationCfg(titleId)
  if cfg then
    local appellation = cfg.appellationName
    local combinedAppellation = string.format(appellation, name)
    return combinedAppellation
  end
  return ""
end
def.static("=>", "table").GetMarriageSkills = function()
  local skills = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COUPLE_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local record = entry
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.skillId = record:GetIntValue("skillId")
    cfg.needFriendValue = record:GetIntValue("needFriendValue")
    cfg.factorA = record:GetIntValue("factorA")
    cfg.factorB = record:GetIntValue("factorB")
    table.insert(skills, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return skills
end
def.static("=>", "table").GetAllBless = function()
  local blesses = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WEDDGING_BLESS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local bless = record:GetStringValue("content")
    table.insert(blesses, bless)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return blesses
end
def.static("number", "=>", "table").GetNpcRedBagCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_REDBAG_CFG, id)
  if record ~= nil then
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.iconId = record:GetIntValue("iconid")
    cfg.content = record:GetStringValue("content")
    return cfg
  else
    warn("Get GetNpcRedBagCfg nil:" .. id)
    return nil
  end
end
def.static("number", "=>", "table").GetWeddingFellowCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WEDDING_FOLLOW_CFG, id)
  if record ~= nil then
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.theBestMan = record:GetIntValue("groomsmanNpcid")
    cfg.bridesMaid = record:GetIntValue("bridesmaidNpcid")
    return cfg
  else
    warn("Get GetWeddingFellowCfg nil:" .. id)
    return nil
  end
end
def.static("=>", "table").GetAllLiPaoNPC = function()
  local npcs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PLPAO_NPC)
  if entries == nil then
    return npcs
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local npcid = record:GetIntValue("npcid")
    table.insert(npcs, npcid)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return npcs
end
MarriageUtils.Commit()
return MarriageUtils
