local Lplus = require("Lplus")
local ChatBubbleMgr = Lplus.Class("ChatBubbleMgr")
local def = ChatBubbleMgr.define
local instance
local Cls = ChatBubbleMgr
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ChatBubbleUtils = require("Main.Chat.ChatBubble.ChatBubbleUtils")
local const = constant.ChatBubbleConsts
def.field("table")._bubblesMap = nil
def.field("number")._wearBubbleId = const.defaultChatBubbleCfgId
local G_showRedDot
def.static("=>", ChatBubbleMgr).Instance = function()
  if instance == nil then
    instance = ChatBubbleMgr()
    instance._bubblesMap = {}
  end
  return instance
end
def.method().Init = function(self)
  local defaultCfg = ChatBubbleUtils.GetBubbleCfgById(const.defaultChatBubbleCfgId)
  _G.DefaultBubbleCfg = defaultCfg
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SUseChatBubbleItemRsp", Cls.OnSUseItemResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SUseChatBubbleItemError", Cls.OnSUseItemFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SSynChatBubbleInfo", Cls.OnSSynBubbleInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SPutOnChatBubbleRsp", Cls.OnSPutOnBubbleRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SPutOffChatBubbleRsp", Cls.OnSPutOffBubbleRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chatbubble.SNotifyChatBubbleExpire", Cls.OnSSynBubbleExpired)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, Cls.OnLeaveWorld)
end
def.static("=>", "table").GetMyBubblesList = function()
  local retData = {}
  for cfgId, bubbleInfo in pairs(instance._bubblesMap) do
    table.insert(retData, bubbleInfo)
  end
  return retData
end
def.static("=>", "table").GetMyBubbleMap = function()
  return instance._bubblesMap or {}
end
def.static("number", "=>", "table").GetMyBubbleByCfgId = function(cfgId)
  return instance._bubblesMap[cfgId]
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_CHAT_BUBBLE)
  return bFeatureOpen
end
def.static("=>", "boolean").IsShowRedDot = function()
  if not Cls.IsFeatureOpen() then
    return false
  end
  if G_showRedDot == nil then
    Cls._checkReddot()
  end
  return G_showRedDot
end
def.static()._checkReddot = function()
  local bubbleMap = Cls.GetMyBubbleMap()
  for cfgId, bubbleInfo in pairs(bubbleMap) do
    if bubbleInfo.tagNew ~= nil and bubbleInfo.tagNew then
      G_showRedDot = true
      return
    end
  end
  G_showRedDot = false
end
def.static("number", "boolean").SetTagNew = function(cfgId, bIsNew)
  if instance._bubblesMap[cfgId] ~= nil then
    instance._bubblesMap[cfgId].tagNew = bIsNew
    Cls._checkReddot()
    Event.DispatchEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, nil)
  end
end
def.static("number", "=>", "table").GetBubbleCfgById = function(cfgId)
  return ChatBubbleUtils.GetBubbleCfgById(cfgId)
end
function _G.SetAvatarBubble(uiObj)
  local bubbleCfg = ChatBubbleUtils.GetBubbleCfgById(instance._wearBubbleId)
  ChatBubbleUtils.SetSprite(uiObj, bubbleCfg.uiResource)
end
def.static("=>", "number").GetWearBubbleId = function()
  return instance._wearBubbleId
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  instance._bubblesMap = {}
  instance._wearBubbleId = const.defaultChatBubbleCfgId
end
local ChatBubbleInfo = require("netio.protocol.mzm.gsp.chatbubble.ChatBubbleInfo")
def.static("number", "number").CSendUseItemReq = function(bagId, itemKey)
  local p = require("netio.protocol.mzm.gsp.chatbubble.CUseChatBubbleItemReq").new(bagId, itemKey)
  gmodule.network.sendProtocol(p)
end
def.static("number").CPutOnBubbleReq = function(cfgId)
  local p = require("netio.protocol.mzm.gsp.chatbubble.CPutOnChatBubbleReq").new(cfgId)
  gmodule.network.sendProtocol(p)
end
def.static("number").CPutOffBubbleReq = function(cfgId)
  local p = require("netio.protocol.mzm.gsp.chatbubble.CPutOffChatBubbleReq").new(cfgId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSUseItemResp = function(p)
  local bubbleInfo = p.chatBubbleInfo
  if instance._bubblesMap == nil then
    instance._bubblesMap = {}
  end
  local bHasBubble = instance._bubblesMap[bubbleInfo.chatBubbleCfgId] ~= nil
  instance._bubblesMap[bubbleInfo.chatBubbleCfgId] = bubbleInfo
  if not bHasBubble then
    if not require("Main.Avatar.ui.AvatarPanel").Instance():IsShow() then
      Toast(textRes.Chat.ChatBubble[13])
    end
    Cls.SetTagNew(bubbleInfo.chatBubbleCfgId, true)
  end
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleInfoChg, {cfgId = bubbleCfgId})
end
def.static("table").OnSUseItemFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.chatbubble.SUseChatBubbleItemError")
  if ERROR_CODE.ITEM_NOT_EXIST == p.errorCode then
    warn("[ERROR:Bubble item not exist]")
  elseif ERROR_CODE.ROLE_LEVEL_LOW == p.errorCode then
    warn("[ERROR: level is too low to using]")
  elseif ERROR_CODE.CHAT_BUBBLE_CLOSED == p.errorCode then
    warn("[ERROR: Bubble is closed]")
  elseif ERROR_CODE.ROLE_GENDER_ERROR == p.errorCode then
    warn("[ERROR: Gender not match]")
  elseif ERROR_CODE.ROLE_MENPAI_ERROR == p.errorCode then
    warn("[ERROR: Role occupation not match]")
  end
end
def.static("table").OnSSynBubbleInfos = function(p)
  instance._bubblesMap = {}
  for k, bubbleInfo in ipairs(p.chatBubbleInfos) do
    instance._bubblesMap[bubbleInfo.chatBubbleCfgId] = bubbleInfo
    if bubbleInfo.isOn == ChatBubbleInfo.ON then
      instance._wearBubbleId = bubbleInfo.chatBubbleCfgId
    end
  end
end
def.static("table").OnSPutOnBubbleRsp = function(p)
  local bubbleCfgId = p.chatBubbleCfgId
  for cfgId, bubbleInfo in pairs(instance._bubblesMap) do
    if bubbleInfo.chatBubbleCfgId == bubbleCfgId then
      bubbleInfo.isOn = ChatBubbleInfo.ON
      Cls.SetTagNew(bubbleCfgId, false)
    else
      bubbleInfo.isOn = ChatBubbleInfo.OFF
    end
  end
  if bubbleCfgId == const.defaultChatBubbleCfgId then
    Toast(textRes.Chat.ChatBubble[14]:format(textRes.Chat.ChatBubble[15]))
  else
    local bubbleCfg = ChatBubbleUtils.GetBubbleCfgById(bubbleCfgId)
    Toast(textRes.Chat.ChatBubble[14]:format(bubbleCfg.name))
  end
  instance._wearBubbleId = bubbleCfgId
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleInfoChg, {cfgId = bubbleCfgId})
end
def.static("table").OnSPutOffBubbleRsp = function(p)
  for cfgId, bubbleInfo in pairs(instance._bubblesMap) do
    if bubbleInfo.isOn == ChatBubbleInfo.ON then
      bubbleInfo.isOn = ChatBubbleInfo.OFF
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleInfoChg, {
        cfgId = bubbleInfo.chatBubbleCfgId
      })
      break
    end
  end
  instance._wearBubbleId = const.defaultChatBubbleCfgId
end
def.static("table").OnSSynBubbleExpired = function(p)
  local bubbleCfgId = p.chatBubbleCfgId
  if instance._bubblesMap[bubbleCfgId] ~= nil then
    instance._bubblesMap[bubbleCfgId] = nil
    if instance._wearBubbleId == bubbleCfgId then
      instance._wearBubbleId = const.defaultChatBubbleCfgId
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleTimeOut, {cfgId = bubbleCfgId})
  end
end
return ChatBubbleMgr.Commit()
