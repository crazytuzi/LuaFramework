local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local WorldBossUtility = Lplus.Class("WorldBossUtility")
local def = WorldBossUtility.define
def.static("string", "=>", "number").GetConstByName = function(constName)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORLD_BOSS_CFG, constName)
  if record == nil then
    return -1
  end
  return record:GetIntValue("value")
end
def.static("number", "=>", "table").GetMonsterCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MONSTER_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.modelId = record:GetIntValue("monsterModelId")
  cfg.figureId = record:GetIntValue("modelFigureId")
  cfg.colorId = record:GetIntValue("modelColorId")
  return cfg
end
def.static("=>", "table").GetAllRankAwards = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WORLD_BOSS_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local awards = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local award = {}
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    award.maxRank = DynamicRecord.GetIntValue(entry, "maxRank")
    award.minRank = DynamicRecord.GetIntValue(entry, "minRank")
    award.desc = DynamicRecord.GetStringValue(entry, "desc")
    table.insert(awards, award)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return awards
end
def.static("number", "=>", "table").GetItemsInMail = function(self, mailId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAIL_CFG, mailId)
  if not record then
    return nil
  end
  local items = {}
  local itemsStruct = record:GetStructValue("itemsStruct")
  local itemSize = itemsStruct:GetVectorSize("items")
  for i = 0, itemSize - 1 do
    local rec = itemsStruct:GetVectorValueByIdx("items", i)
    local itemInfo = {}
    itemInfo.itemId = rec:GetIntValue("itemid")
    itemInfo.itemNum = rec:GetIntValue("itemNum")
    table.insert(items, itemInfo)
  end
  return items
end
def.static("=>", "boolean").CanEnterWorldboss = function()
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if PlayerIsInFight() then
    Toast(textRes.WorldBoss[10])
    return false
  elseif myRole and myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.WorldBoss[11])
    return false
  end
  return true
end
def.static("table").PringWorldBossInfo = function(data)
  print("~~~~~~~~~Here comes the world boss~~~~~~~~~")
  print(string.format("My Stats--->Score: %d, Rank: %d", data.damagePoint, data.rank))
  print(string.format("Challenge Counts--->Total Bought: %d, Counts Left: %d", data.totalbuycount, data.challengeCount))
  print(string.format("Boss IDs--->Current Boss: %d, Next Boss: %d", data.monsterid, data.nextmonsterid))
  print(string.format("Activity End Time---->This week: %d, Next week: %d", Int64.ToNumber(data.endTime), Int64.ToNumber(data.nextStartTime)))
  print("~~~~~~~~~There goes the world boss~~~~~~~~~")
end
return WorldBossUtility.Commit()
