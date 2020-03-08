local Lplus = require("Lplus")
local ChatInputMgr = Lplus.Class("ChatInputMgr")
local def = ChatInputMgr.define
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local instance
def.static("=>", ChatInputMgr).Instance = function()
  if nil == instance then
    instance = ChatInputMgr()
  end
  return instance
end
local CheckFunctions = {
  [1] = function()
    return true
  end,
  [2] = function()
    return true
  end,
  [3] = function()
    return true
  end,
  [4] = function()
    return true
  end,
  [5] = function()
    return true
  end,
  [6] = function()
    return true
  end,
  [7] = function()
    return ChatInputMgr.Instance():CanOpenFabaoInput()
  end,
  [8] = function()
    return ChatInputMgr.Instance():CanOpenChatAtInput()
  end,
  [9] = function()
    return ChatInputMgr.Instance():CanOpenRedGiftInput()
  end,
  [10] = function()
    return ChatInputMgr.Instance():CanOpenChengweiInput()
  end,
  [11] = function()
    return ChatInputMgr.Instance():CanOpenTouxianInput()
  end,
  [12] = function()
    return ChatInputMgr.Instance():CanOpenMountsInput()
  end,
  [13] = function()
    return true
  end,
  [14] = function()
    return ChatInputMgr.Instance():CanOpenTurnedCardInput()
  end
}
def.method("number", "=>", "boolean").CanOpenSpecifyInput = function(self, targetState)
  local f = CheckFunctions[targetState]
  if f then
    return f()
  end
  return false
end
def.method("=>", "boolean").CanOpenFabaoInput = function(self)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local openLevel = require("Main.Fabao.FabaoUtils").GetFabaoConstValue("FABAO_OPEN_LEVEL")
  if heroLevel >= openLevel then
    return true
  else
    return false
  end
end
def.method("=>", "table").GetAllFabao = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local FabaoData = require("Main.Fabao.data.FabaoData")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local fabaosInBag = ItemModule.Instance():GetItemsByItemType(ItemModule.FABAOBAG, ItemType.FABAO_ITEM)
  local fabaosInWear = FabaoData.Instance():GetAllFabaoData()
  local allFabao = {}
  if fabaosInWear then
    for k, v in pairs(fabaosInWear) do
      local data = {}
      data.key = -1
      data.itemInfo = v
      table.insert(allFabao, data)
    end
  end
  if fabaosInBag then
    for k, v in pairs(fabaosInBag) do
      local data = {}
      data.key = k
      data.itemInfo = v
      table.insert(allFabao, data)
    end
  end
  return allFabao
end
def.method("=>", "boolean").CanOpenRedGiftInput = function(self)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  if channelChatPanel.m_panel ~= nil and channelChatPanel.channelType == ChatMsgData.MsgType.CHANNEL and ChatRedGiftData.Instance():IsCanShowRedGiftBtnByChannelType(channelChatPanel.channelSubType) then
    return true
  end
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  if SocialDlg.Instance().m_panel ~= nil and SocialDlg.Instance().curNode == SocialDlg.NodeId.Group and ChatRedGiftData.Instance():IsCanShowRedGiftBtnByChannelType(ChatMsgData.Channel.GROUP) then
    return true
  end
  return false
end
def.method("=>", "boolean").CanOpenChengweiInput = function(self)
  local titleInterface = require("Main.title.TitleInterface").Instance()
  local ownAppellations = titleInterface:GetOwnAppellations()
  return ownAppellations ~= nil and #ownAppellations > 0
end
def.method("=>", "boolean").CanOpenTouxianInput = function(self)
  local titleInterface = require("Main.title.TitleInterface").Instance()
  local ownTitles = titleInterface:GetOwnTitles()
  return ownTitles ~= nil and #ownTitles > 0
end
def.method("=>", "boolean").CanOpenChatAtInput = function(self)
  local atMgr = require("Main.Chat.At.AtMgr").Instance()
  return atMgr:IsOpen(false) and atMgr:CanOpenChatAtInput()
end
def.method().OpenRedGiftPanel = function(self)
  if ChatRedGiftData.Instance():IsRedGiftOpen(true) then
    local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    local tmpChannelType = -1
    local tmpChannelSubType = -1
    local tmpGroupId
    if channelChatPanel.m_panel ~= nil then
      tmpChannelType = channelChatPanel.channelType
      tmpChannelSubType = channelChatPanel.channelSubType
    end
    if SocialDlg.Instance().m_panel ~= nil and SocialDlg.Instance().curNode == SocialDlg.NodeId.Group then
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      tmpChannelType = ChatMsgData.MsgType.GROUP
      tmpChannelSubType = ChatMsgData.Channel.GROUP
      tmpGroupId = SocialDlg.Instance().m_GroupId
    end
    if tmpChannelType ~= -1 and tmpChannelSubType ~= -1 then
      Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Send_ChatRedGift, {
        _channelType = tmpChannelType,
        _channelSubType = tmpChannelSubType,
        _groupId = tmpGroupId
      })
    end
  end
end
def.method("=>", "boolean").CanOpenMountsInput = function(self)
  local MountsModule = require("Main.Mounts.MountsModule")
  return MountsModule.IsFunctionOpen()
end
def.method("=>", "boolean").CanOpenTurnedCardInput = function(self)
  return require("Main.TurnedCard.TurnedCardInterface").Instance():isOpenTurnedCard()
end
ChatInputMgr.Commit()
return ChatInputMgr
