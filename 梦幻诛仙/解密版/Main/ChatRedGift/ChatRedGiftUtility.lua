local Lplus = require("Lplus")
local ChatRedGiftUtility = Lplus.Class("ChatRedGiftUtility")
local def = ChatRedGiftUtility.define
def.static("table", "=>", "boolean").HasGetThisRedGift = function(memberList)
  if not memberList then
    return false
  end
  local selfRoleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for k, v in pairs(memberList) do
    if selfRoleId == v.roleId then
      return true
    end
  end
  return false
end
def.static("number", "number", "=>", "boolean").IsChatChanelOpened = function(_channelType, _channelSubType)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  if channelChatPanel.m_panel == nil then
    return false
  end
  if channelChatPanel.channelType == ChatMsgData.MsgType.CHANNEL and channelChatPanel.channelSubType == _channelType or channelChatPanel.channelType == ChatMsgData.MsgType.GROUP then
    return true
  end
  return false
end
def.static("number", "=>", "table").GetSendGiftByType = function(giftType)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SEND_GIFT)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local type = entry:GetIntValue("giftType")
    if giftType == type then
      local cfg = {}
      cfg.id = entry:GetIntValue("id")
      cfg.name = entry:GetStringValue("giftName")
      cfg.moneyType = entry:GetIntValue("moneyType")
      cfg.moneyNum = entry:GetIntValue("moneyNum")
      table.insert(ret, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return ret
end
def.static("number", "=>", "table").GetSendGiftCfg = function(giftid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SEND_GIFT, giftid)
  if record == nil then
    warn("GetSendGift nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("giftName")
  cfg.type = record:GetIntValue("giftType")
  cfg.moneyType = record:GetIntValue("moneyType")
  cfg.moneyNum = record:GetIntValue("moneyNum")
  return cfg
end
return ChatRedGiftUtility.Commit()
