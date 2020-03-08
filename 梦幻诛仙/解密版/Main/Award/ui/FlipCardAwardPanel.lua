local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local FlipCardPanel = require("GUI.FlipCardPanel")
local FlipCardAwardPanel = Lplus.Extend(FlipCardPanel, CUR_CLASS_NAME)
local def = FlipCardAwardPanel.define
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local FlipCardAwardMgr = import("..mgr.FlipCardAwardMgr")
local AwardUtils = import("Main.Award.AwardUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local COUNT_DOWN_SECONDS = 5
def.field("table").timeoutAwardList = nil
local instance
def.static("=>", FlipCardAwardPanel).Instance = function()
  if instance == nil then
    instance = FlipCardAwardPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  COUNT_DOWN_SECONDS = AwardUtils.GetCommonAwardConsts("MULTI_AWARD_ROLE_END_TIME") or COUNT_DOWN_SECONDS
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  FlipCardPanel.ShowPanelEx(self, COUNT_DOWN_SECONDS)
end
def.override().OnCreate = function(self)
  FlipCardPanel.OnCreate(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_TAKED_MULTI_ROLE_AWARD, FlipCardAwardPanel.OnSyncAwardInfo)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_NOT_TAKE_MULTI_ROLE_AWARD, FlipCardAwardPanel.OnSyncNotTakeAwardInfo)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, FlipCardAwardPanel.OnMapChange)
  self:FlipAlreadyDrewCard()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MULTI_ROLE_FLIP_CARD_BEGIN, nil)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_TAKED_MULTI_ROLE_AWARD, FlipCardAwardPanel.OnSyncAwardInfo)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SYNC_NOT_TAKE_MULTI_ROLE_AWARD, FlipCardAwardPanel.OnSyncNotTakeAwardInfo)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, FlipCardAwardPanel.OnMapChange)
  self.timeoutAwardList = nil
  FlipCardAwardMgr.Instance():MoveToNextAward()
  FlipCardPanel.OnDestroy(self)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MULTI_ROLE_FLIP_CARD_END, nil)
end
def.override("number").OnCardSelected = function(self, index)
  if FlipCardAwardMgr.Instance():HasDrew() then
    Toast(textRes.JueZhanJiuXiao[5])
    return
  end
  FlipCardAwardMgr.Instance():SelectAward(index)
end
def.override("=>", "table").OnTimeout = function(self)
  local canClose = true
  local isfliped = self:FlipOverTimeoutAward()
  return {canClose, isfliped}
end
def.method().FlipAlreadyDrewCard = function(self)
  local curData = FlipCardAwardMgr.Instance():GetCurAwardData()
  if curData then
    for k, awardInfo in ipairs(curData.awarded) do
      local viewData = self:GetAwardInfoViewData(awardInfo)
      self:FlipOverAward(viewData)
    end
    if FlipCardAwardMgr.Instance():HasAllAwardGiven() then
      GameUtil.AddGlobalTimer(1, true, function()
        if self.m_panel and not self.m_panel.isnil then
          self:ForceEndCountDown()
        end
      end)
    end
  else
    self:DestroyPanel()
  end
end
def.method("table").FlipOverAward = function(self, viewData)
  self:FlipOverCard(viewData.index, viewData.itemId, viewData.num, viewData.name)
  if viewData.isMe then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.GetItemMsg(viewData.itemId, viewData.num)
  end
end
def.method("=>", "boolean").FlipOverTimeoutAward = function(self)
  if self.timeoutAwardList == nil then
    return false
  end
  local fliped = false
  local infoList = self.timeoutAwardList
  for i, info in ipairs(infoList) do
    local viewData = self:GetAwardInfoViewData(info)
    instance:FlipOverAward(viewData)
    fliped = true
  end
  self.timeoutAwardList = nil
  return fliped
end
def.method("table", "=>", "table").GetAwardInfoViewData = function(self, awardInfo)
  local viewData = {}
  viewData.index = awardInfo.index
  viewData.itemId = awardInfo.awardBean.id
  viewData.num = awardInfo.awardBean.count
  viewData.name = textRes.Award[12]
  local myRoleID = _G.GetHeroProp().id
  local curData = FlipCardAwardMgr.Instance():GetCurAwardData()
  if curData then
    for i, roleInfo in ipairs(curData.roles) do
      if roleInfo.roleid == awardInfo.roleid then
        viewData.name = roleInfo.rolename
        if roleInfo.roleid == myRoleID then
          viewData.isMe = true
        end
      end
    end
  end
  return viewData
end
def.static("table", "table").OnSyncAwardInfo = function(params, context)
  local info = params[1]
  local viewData = instance:GetAwardInfoViewData(info)
  instance:FlipOverAward(viewData)
end
def.static("table", "table").OnSyncNotTakeAwardInfo = function(params, context)
  local infoList = params[1]
  local self = instance
  self.timeoutAwardList = infoList
  self:ForceEndCountDown()
end
def.static("table", "table").OnMapChange = function(params)
end
return FlipCardAwardPanel.Commit()
