local Lplus = require("Lplus")
local WorldQuestionUtils = Lplus.Class("WorldQuestionUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = WorldQuestionUtils.define
def.static("number", "=>", "string").GetWorldQuestionContentById = function(id)
  local questionRecord = DynamicData.GetRecord(CFG_PATH.WORLD_QUESTION_LIB_CFG, id)
  if questionRecord == nil then
    warn("\228\184\150\231\149\140\231\173\148\233\162\152\233\162\152\229\186\147ID\228\184\141\229\173\152\229\156\168:" .. id)
    return nil
  end
  return DynamicRecord.GetStringValue(questionRecord, "question")
end
def.static("number", "=>", "string").GetWorldQuestionAwardItemNameById = function(id)
  local awardRecord = DynamicData.GetRecord(CFG_PATH.DATA_ITEMCFG, id)
  if awardRecord == nil then
    warn("\228\184\150\231\149\140\231\173\148\233\162\152\229\165\150\229\138\177\231\137\169\229\147\129ID\228\184\141\229\173\152\229\156\168:" .. id)
    return nil
  end
  return awardRecord:GetStringValue("name")
end
def.static("string", "table", "=>", "string").FormatChatAward = function(fmt, award)
  local winner = award.roleName
  local awards = award.items
  local awardStr = WorldQuestionUtils.FormatChatAwardInfo(awards)
  return string.format(fmt, winner, awardStr)
end
def.static("string", "table", "=>", "string").FormatAnnounceAward = function(fmt, award)
  local winner = award.roleName
  local awards = award.items
  local awardStr = WorldQuestionUtils.FormatAnnounceAwardInfo(awards)
  return string.format(fmt, winner, awardStr)
end
def.static("table", "=>", "string").FormatChatAwardInfo = function(awards)
  local awardBuffer = {}
  for itemId, num in pairs(awards) do
    local itemBase = ItemUtils.GetItemBase(itemId)
    local name = itemBase.name
    table.insert(awardBuffer, string.format("<font color=#%s>%sx%d</font>", ItemTipsMgr.Color[itemBase.namecolor], name, num))
  end
  return table.concat(awardBuffer, "\227\128\129")
end
def.static("table", "=>", "string").FormatAnnounceAwardInfo = function(awards)
  local awardBuffer = {}
  for itemId, num in pairs(awards) do
    local itemBase = ItemUtils.GetItemBase(itemId)
    local name = itemBase.name
    table.insert(awardBuffer, string.format("[%s]%sx%d[-]", ItemTipsMgr.Color[itemBase.namecolor], name, num))
  end
  return table.concat(awardBuffer, "\227\128\129")
end
def.static("=>", "boolean").IsCurrentPlayerCanViewQuestion = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return false
  end
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local activityRecord = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_CFG, constant.WorldQuestionConsts.ACTIVITYID)
  if activityRecord == nil then
    return false
  end
  local worldQuestionUnlockLevel = activityRecord:GetIntValue("levelMin")
  return heroLevel >= worldQuestionUnlockLevel
end
WorldQuestionUtils.Commit()
return WorldQuestionUtils
