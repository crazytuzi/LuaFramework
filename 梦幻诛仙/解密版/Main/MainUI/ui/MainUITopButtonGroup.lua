local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local MainUITopButtonGroup = Lplus.Extend(ComponentBase, "MainUITopButtonGroup")
local HeroInterface = require("Main.Hero.Interface")
local RankListModule = require("Main.RankList.RankListModule")
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local GUIUtils = require("GUI.GUIUtils")
local RecallModule = require("Main.Recall.RecallModule")
local Vector = require("Types.Vector")
local def = MainUITopButtonGroup.define
local ButtonId = {
  OnHook = 1,
  Activity = 2,
  GameHome = 3,
  Grow = 4
}
def.const("table").ButtonId = ButtonId
def.const("table").ButtonNameMap = {
  [ButtonId.OnHook] = "Btn_Auto",
  [ButtonId.Activity] = "Btn_Activity",
  [ButtonId.GameHome] = "Group_GameHome",
  [ButtonId.Grow] = "Btn_Lead"
}
local instance
def.static("=>", MainUITopButtonGroup).Instance = function()
  if instance == nil then
    instance = MainUITopButtonGroup()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, MainUITopButtonGroup.OnPanelClose)
  Event.RegisterEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, MainUITopButtonGroup.OnDoublePointChange)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.GROW_NOTICE_CHANGE, MainUITopButtonGroup.OnGrowNoticeChange)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriend, MainUITopButtonGroup.OnNotifyRecallFriend)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, MainUITopButtonGroup.OnNotifyRecallFriendBigGiftAward)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, MainUITopButtonGroup.OnNotifyRecallFriendSignAward)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, MainUITopButtonGroup.OnPanelClose)
  Event.UnregisterEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, MainUITopButtonGroup.OnDoublePointChange)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.GROW_NOTICE_CHANGE, MainUITopButtonGroup.OnGrowNoticeChange)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriend, MainUITopButtonGroup.OnNotifyRecallFriend)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, MainUITopButtonGroup.OnNotifyRecallFriendBigGiftAward)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, MainUITopButtonGroup.OnNotifyRecallFriendSignAward)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, MainUITopButtonGroup.OnRecallInfoChange)
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.override().CheckDisplayable = function(self)
  if not self.m_container:IsMainInfoUIGroupOpened() then
    self:Hide()
    return
  end
  ComponentBase.CheckDisplayable(self)
end
def.method().InitUI = function(self)
  self:UpdateGameHomeReddot()
end
def.method().UpdateGameHomeReddot = function(self)
  if RecallModule.Instance():IsOpen(false) then
    self:UpdateNewGameHomeReddot()
  else
    self:UpdateOldGameHomeReddot()
  end
end
def.method().UpdateOldGameHomeReddot = function(self)
  if not _G.IsNil(self.m_node) then
    local haveRelationShipChainAward = RelationShipChainMgr.CanReciveGift() or RelationShipChainMgr.CanReciveFriendNumGift()
    local haveRecallFriendAward = RelationShipChainMgr.GetBigGiftAwardState() == 0 or RelationShipChainMgr.CanGetRecallFriendSignAward() or RelationShipChainMgr.CanReciveRecallFriendNumGift() or RelationShipChainMgr.ToadyCanRecallFriend()
    local Img_GameHomeRed = self.m_node:FindDirect("Group_GameHome/Btn_GameHome/Img_GameHomeRed")
    local needReddot = haveRelationShipChainAward or haveRecallFriendAward
    GUIUtils.SetActive(Img_GameHomeRed, needReddot)
    gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(Img_GameHomeRed.parent.parent, needReddot and 1 or 0)
  end
end
def.method().UpdateUI = function(self)
  self:UpdateDoublePointNum()
  require("Main.Grow.GrowModule").Instance():CheckNotice()
  local num = require("Main.Grow.GrowModule").Instance():HasNotice() and 1 or 0
  self:SetGrowNotifyMessageNum(num)
end
def.method().UpdateDoublePointNum = function(self)
  local DoublePointData = require("Main.OnHook.DoublePointData")
  local num = DoublePointData.Instance():GetFrozenPoolPointNum()
  self:SetDoublePointNum(num)
end
def.method("number").SetDoublePointNum = function(self, num)
  local Btn_Auto = self.m_node:FindDirect(MainUITopButtonGroup.ButtonNameMap[ButtonId.OnHook])
  local label = Btn_Auto:FindDirect("Label")
  if num > 0 then
    GUIUtils.SetActive(label, true)
  else
    GUIUtils.SetActive(label, false)
  end
  GUIUtils.SetText(label, string.format(textRes.MainUI[1], num))
end
def.method("number").SetGrowNotifyMessageNum = function(self, num)
  local btnName = MainUITopButtonGroup.ButtonNameMap[ButtonId.Grow]
  local btnObj = self.m_node:FindDirect(btnName)
  self:SetNotifyMessageNum(btnObj, "Img_Red", "Label_RedNum", num)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(btnObj, num)
end
def.method("userdata", "string", "string", "number").SetNotifyMessageNum = function(self, btnObj, imgName, labelName, num)
  if btnObj == nil then
    warn(debug.traceback("Can not find button gameobject!"))
    return
  end
  local img = btnObj:FindDirect(imgName)
  if num <= 0 then
    GUIUtils.SetActive(img, false)
  else
    GUIUtils.SetActive(img, true)
    GUIUtils.SetText(img:FindDirect(labelName), "")
  end
end
def.static("table", "table").OnPanelClose = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:InitUI()
  end
end
def.static("table", "table").OnDoublePointChange = function(params)
  local self = instance
  if self.m_node == nil then
    return
  end
  local num = params[1] or 0
  self:SetDoublePointNum(num)
end
def.static("table", "table").OnGrowNoticeChange = function(params)
  local self = instance
  local hasNotice = params[1]
  local num = hasNotice and 1 or 0
  self:SetGrowNotifyMessageNum(num)
end
def.static("table", "table").OnNotifyRecallFriend = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:InitUI()
  end
end
def.static("table", "table").OnNotifyRecallFriendBigGiftAward = function(param, context)
  local self = MainUITopButtonGroup.Instance()
  self:UpdateGameHomeReddot()
end
def.static("table", "table").OnNotifyRecallFriendSignAward = function(param, context)
  local self = MainUITopButtonGroup.Instance()
  self:UpdateGameHomeReddot()
end
def.static("table", "table").OnRecallInfoChange = function(param, context)
  local self = MainUITopButtonGroup.Instance()
  self:UpdateNewGameHomeReddot()
end
def.method().UpdateNewGameHomeReddot = function(self)
  if not _G.IsNil(self.m_node) then
    local Img_GameHomeRed = self.m_node:FindDirect("Group_GameHome/Btn_GameHome/Img_GameHomeRed")
    local needReddot = RecallModule.Instance():NeedReddot()
    GUIUtils.SetActive(Img_GameHomeRed, needReddot)
    gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(Img_GameHomeRed.parent.parent, needReddot and 1 or 0)
  end
end
MainUITopButtonGroup.Commit()
return MainUITopButtonGroup
