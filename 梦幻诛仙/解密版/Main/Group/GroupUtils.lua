local Lplus = require("Lplus")
local GroupUtils = Lplus.Class("GroupUtils")
local def = GroupUtils.define
def.static("=>", "number").GetGroupCreateLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "CREATE_GROUP_LEVEL")
  if nil == record then
    return 50
  end
  local createLevel = record:GetIntValue("value")
  return createLevel or 50
end
def.static("=>", "number").GetClientUpdateTime = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "CLIENT_GROUP_LIST_REFRESH_INTERVAL")
  if nil == record then
    return 60
  end
  local updatetime = record:GetIntValue("value")
  return updatetime or 60
end
def.static("=>", "number").GetGroupJoinLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "JOIN_GROUP_LEVEL")
  if nil == record then
    return 50
  end
  local joinLevel = record:GetIntValue("value")
  return joinLevel or 50
end
def.static("=>", "number").GetGroupMaxJoinNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "JOIN_GROUP_MAX_NUM")
  if nil == record then
    return 50
  end
  local maxJoinNum = record:GetIntValue("value")
  return maxJoinNum or 50
end
def.static("=>", "number").GetGroupMaxMemberNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "GROUP_MEMBER_MAX_NUM")
  if nil == record then
    return 50
  end
  local maxMemberNum = record:GetIntValue("value")
  return maxMemberNum or 50
end
def.static("=>", "number").GetGroupHeadIconNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "MEMBER_NUM_IN_GROUP_IMAGE")
  if nil == record then
    return 4
  end
  local headIconNum = record:GetIntValue("value")
  return headIconNum or 4
end
def.static("=>", "number").GetGroupMaxNameLength = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "GROUP_NAME_MAX_LENGTH")
  if nil == record then
    return 6
  end
  local maxNameLen = record:GetIntValue("value")
  return maxNameLen or 6
end
def.static("=>", "number").GetGroupMaxAnnounceLength = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_CONSTANTS, "GROUP_ANNOUNCEMENT_MAX_LENGTH")
  if nil == record then
    return 50
  end
  local maxAnnounceLen = record:GetIntValue("value")
  return maxAnnounceLen or 50
end
def.static("=>", "number").GetCurGroupLimitNum = function()
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if nil == heroProp then
    return 0
  end
  local heroLevel = heroProp.level
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_GROUP_NUM_LIMIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local curLimitNum = 0
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local lowerLevel = record:GetIntValue("lowerLevel")
    local upperLevel = record:GetIntValue("upperLevel")
    if heroLevel >= lowerLevel and heroLevel < upperLevel then
      curLimitNum = record:GetIntValue("limitNum") or 0
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return curLimitNum
end
GroupUtils.Commit()
return GroupUtils
