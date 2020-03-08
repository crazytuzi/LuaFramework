local Lplus = require("Lplus")
local ChatRedGiftData = Lplus.Class("ChatRedGiftData")
local def = ChatRedGiftData.define
local _instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
def.field("table").isChannelRedGiftOpen = nil
def.field("table").redGiftChannel = nil
def.field("table").newChatRedGift = nil
def.field("number").leftTimes = 0
def.static("=>", ChatRedGiftData).Instance = function()
  if _instance == nil then
    _instance = ChatRedGiftData()
    _instance:Init()
  end
  return _instance
end
def.method().Init = function(self)
  self.redGiftChannel = {}
  self.isChannelRedGiftOpen = {}
  self.newChatRedGift = {}
  self.leftTimes = constant.ChatGiftConsts.dayLimitNum
end
def.method("table").AddNewChatRedGift = function(self, _redGiftInfo)
  if _redGiftInfo.channelType and _redGiftInfo.channelSubType then
    if not self.newChatRedGift[_redGiftInfo.channelType] then
      self.newChatRedGift[_redGiftInfo.channelType] = {}
    end
    self.newChatRedGift[_redGiftInfo.channelType][_redGiftInfo.channelSubType] = _redGiftInfo
  end
end
def.method("number", "number", "=>", "table").GetNewChatRedGiftByChannelType = function(self, _channelType, _channelSubType)
  if self.newChatRedGift and self.newChatRedGift[_channelType] and self.newChatRedGift[_channelType][_channelSubType] then
    return self.newChatRedGift[_channelType][_channelSubType]
  end
  return nil
end
def.method("table").OpenChatRedGift = function(self, _redGiftInfo)
  if self.newChatRedGift and _redGiftInfo and _redGiftInfo.channelType and self.newChatRedGift[_redGiftInfo.channelType] and _redGiftInfo.channelSubType and self.newChatRedGift[_redGiftInfo.channelType][_redGiftInfo.channelSubType] and self.newChatRedGift[_redGiftInfo.channelType][_redGiftInfo.channelSubType].redGiftId == _redGiftInfo.redGiftId then
    self.newChatRedGift[_redGiftInfo.channelType][_redGiftInfo.channelSubType] = nil
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, {redGiftInfo = _redGiftInfo})
  end
end
def.method("number", "number", "=>", "boolean").HasNewChatRedGiftByChannelType = function(self, _channelType, _channelSubType)
  if self.newChatRedGift and self.newChatRedGift[_channelType] and self.newChatRedGift[_channelType][_channelSubType] then
    return true
  end
  return false
end
def.method("string", "number", "number").AddRedGiftChannel = function(self, redGiftIdStr, _channelType, _channelSubType)
  if not self.redGiftChannel then
    self.redGiftChannel = {}
  end
  self.redGiftChannel[redGiftIdStr] = {channelType = _channelType, channelSubType = _channelSubType}
end
def.method("string", "=>", "table").GetRedGiftChannel = function(self, _redGiftId)
  if not self.redGiftChannel then
    self.redGiftChannel = {}
  end
  return self.redGiftChannel[_redGiftId] or {channelType = -1, channelSubType = -1}
end
def.method("boolean", "=>", "boolean").IsRedGiftOpen = function(self, isShowToast)
  local ActivityInterface = require("Main.activity.ActivityInterface").Instance()
  if ActivityInterface._currentTotalActive >= constant.ChatGiftConsts.needActiviteValue then
    return true
  elseif isShowToast then
    Toast(string.format(textRes.ChatRedGift[7], constant.ChatGiftConsts.needActiviteValue))
  end
  return false
end
def.method("number", "=>", "boolean").IsCanShowRedGiftBtnByChannelType = function(self, _channelType)
  local allOpen, _param = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_CHATGIFT_ROLE)
  if not allOpen then
    return false
  end
  local typeid = -1
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  if _channelType == ChatMsgData.Channel.FACTION then
    typeid = Feature.TYPE_CHATGIFT_GANG
  elseif _channelType == ChatMsgData.Channel.GROUP then
    typeid = Feature.TYPE_CHATGIFT_GROUP
  end
  if typeid == -1 then
    return false
  end
  local open, param = FeatureOpenListModule.Instance():CheckFeatureOpen(typeid)
  if open then
    return true
  end
  return false
end
def.method("number").SetLeftTimes = function(self, _leftnum)
  self.leftTimes = _leftnum
end
def.static("=>", "number").GetTodayLeftRedGiftTimes = function()
  return _instance.leftTimes
end
def.static("=>", "number").GetSenRedGiftMinNum = function()
  return constant.ChatGiftConsts.minNum
end
def.static("=>", "number").GetSenRedGiftMaxNum = function()
  return constant.ChatGiftConsts.maxNum
end
def.static("=>", "table").GetChatRedGiftConfigs = function()
  local configslist = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHATREDGIFT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local _id = DynamicRecord.GetIntValue(entry, "id")
    local yuanbaonum = DynamicRecord.GetIntValue(entry, "moneyNum")
    local goldnum = DynamicRecord.GetIntValue(entry, "giftMoneyNum")
    table.insert(configslist, {
      id = _id,
      yuanbao = yuanbaonum,
      gold = goldnum
    })
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return #configslist > 0 and configslist or nil
end
def.static("number", "=>", "table").GetChatRedGiftConfigByIndex = function(index)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHATREDGIFT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local config
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    if id == index then
      config = {}
      config.yuanbaonum = DynamicRecord.GetIntValue(entry, "moneyNum")
      config.goldnum = DynamicRecord.GetIntValue(entry, "giftMoneyNum")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return config
end
return ChatRedGiftData.Commit()
