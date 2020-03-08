local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AagrData = require("Main.Aagr.data.AagrData")
local AagrProtocols = require("Main.Aagr.AagrProtocols")
local AagrDevourPanel = Lplus.Extend(ECPanelBase, "AagrDevourPanel")
local def = AagrDevourPanel.define
local instance
def.static("=>", AagrDevourPanel).Instance = function()
  if instance == nil then
    instance = AagrDevourPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._arenaInfo = nil
def.field("table")._waitInfoList = nil
def.field("table")._showInfoList = nil
local BULLETIN_COUNT = 2
local TWEEN_DELAY = 3
local SHOW_DURATION = 4
def.field("number")._curBulletinIdx = 0
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.static("table").ShowDevour = function(devourInfo)
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrDevourPanel:ShowDevour] show fail! not in arena.")
    if AagrDevourPanel.Instance():IsShow() then
      AagrDevourPanel.Instance():DestroyPanel()
    end
    return
  end
  AagrDevourPanel.Instance():_AddDevourInfo(devourInfo)
  if AagrDevourPanel.Instance():IsShow() then
    return
  end
  AagrDevourPanel.Instance():_InitData()
  AagrDevourPanel.Instance():CreatePanel(RESPATH.PREFAB_AAGR_DEVOUR_PANEL, 0)
end
def.method()._InitData = function(self)
  self._arenaInfo = AagrData.Instance():GetArenaInfo()
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:ShowNext()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Bulletins = {}
  for i = 1, BULLETIN_COUNT do
    local bulletin = self.m_panel:FindDirect("Group_0" .. i)
    GUIUtils.SetActive(bulletin, false)
    table.insert(self._uiObjs.Bulletins, bulletin)
  end
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
  else
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._arenaInfo = nil
  self._waitInfoList = nil
  self._showInfoList = nil
  self._curBulletinIdx = 0
end
def.method("table")._AddDevourInfo = function(self, devourInfo)
  if nil == devourInfo then
    warn("[ERROR][AagrDevourPanel:_AddDevourInfo] devourInfo nil.")
    return
  end
  if nil == self._waitInfoList then
    self._waitInfoList = {}
  end
  table.insert(self._waitInfoList, devourInfo)
  warn("[AagrDevourPanel:_AddDevourInfo] devourInfo:", Int64.tostring(devourInfo.killer_role_id), Int64.tostring(devourInfo.killed_role_id))
  if not self:IsShow() then
    return
  end
  self:TryShowNext()
end
def.method().TryShowNext = function(self)
  if self:GetWaitInfoCount() <= 0 then
    return
  end
  if self:GetShowInfoCount() < BULLETIN_COUNT and self:GetLastShowDuration() >= TWEEN_DELAY then
    self:ShowNext()
  end
end
def.method().ShowNext = function(self)
  local devourInfo
  if self:GetWaitInfoCount() > 0 then
    devourInfo = table.remove(self._waitInfoList, 1)
  end
  if nil == devourInfo then
    warn("[AagrDevourPanel:ShowNext] no more devourInfo.")
    return
  end
  local bulletin = self:GetBulletin()
  if nil == bulletin then
    warn("[ERROR][AagrDevourPanel:ShowNext] show next fail! bulletin nil at idx:", self._curBulletinIdx)
    return
  end
  warn("[AagrDevourPanel:ShowNext] show devourInfo:", Int64.tostring(devourInfo.killer_role_id), Int64.tostring(devourInfo.killed_role_id))
  devourInfo.lifeTime = 0
  if nil == self._showInfoList then
    self._showInfoList = {}
  end
  table.insert(self._showInfoList, devourInfo)
  local LabelNameA = bulletin:FindDirect("Img_BgTarget01/Label_TargetName")
  GUIUtils.SetText(LabelNameA, self:GetRoleName(devourInfo.killer_role_id))
  local ImgIconHeadA = bulletin:FindDirect("Img_BgTarget01/Img_IconHead")
  _G.SetAvatarIcon(ImgIconHeadA, devourInfo.killer_avatar_id)
  local LabelNameB = bulletin:FindDirect("Img_BgTarget02/Label_TargetName")
  GUIUtils.SetText(LabelNameB, self:GetRoleName(devourInfo.killed_role_id))
  local ImgIconHeadB = bulletin:FindDirect("Img_BgTarget02/Img_IconHead")
  _G.SetAvatarIcon(ImgIconHeadB, devourInfo.killed_avatar_id)
  local tweenPosition = bulletin:GetComponent("TweenPosition")
  local tweenAlpha = bulletin:GetComponent("TweenAlpha")
  tweenPosition:ResetToBeginning()
  tweenAlpha:ResetToBeginning()
  GUIUtils.SetActive(bulletin, true)
  tweenPosition:PlayForward()
  tweenAlpha:PlayForward()
end
def.method("=>", "userdata").GetBulletin = function(self)
  self._curBulletinIdx = self._curBulletinIdx + 1
  if self._curBulletinIdx > BULLETIN_COUNT then
    self._curBulletinIdx = 1
  end
  return self._uiObjs.Bulletins[self._curBulletinIdx]
end
def.method("=>", "number").GetWaitInfoCount = function(self)
  return self._waitInfoList and #self._waitInfoList or 0
end
def.method("=>", "number").GetShowInfoCount = function(self)
  return self._showInfoList and #self._showInfoList or 0
end
def.method("=>", "number").GetLastShowDuration = function(self)
  local showCount = self:GetShowInfoCount()
  if showCount > 0 then
    return self._showInfoList[showCount].lifeTime
  else
    return math.huge
  end
end
def.method("userdata", "=>", "string").GetRoleName = function(self, roleId)
  return self._arenaInfo and self._arenaInfo:GetPlayerName(roleId) or ""
end
def.method()._Update = function(self)
  if self:GetShowInfoCount() > 0 then
    local popIdxList = {}
    for idx, info in ipairs(self._showInfoList) do
      info.lifeTime = info.lifeTime + 1
      if info.lifeTime >= SHOW_DURATION then
        table.insert(popIdxList, idx, 1)
      end
    end
    if #popIdxList > 0 then
      for _, idx in ipairs(popIdxList) do
        table.remove(self._showInfoList, idx)
      end
    end
  end
  self:TryShowNext()
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_INFO_CHANGE, AagrDevourPanel.OnArenaInfoChange)
  end
end
def.static("table", "table").OnArenaInfoChange = function(params, context)
  local self = AagrDevourPanel.Instance()
  if self and self:IsShow() and nil == self._arenaInfo then
    self:_InitData()
  end
end
AagrDevourPanel.Commit()
return AagrDevourPanel
