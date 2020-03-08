local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AagrData = require("Main.Aagr.data.AagrData")
local ArenaCountdownMgr = require("Main.Aagr.mgr.ArenaCountdownMgr")
local AagrStartPanel = Lplus.Extend(ECPanelBase, "AagrStartPanel")
local def = AagrStartPanel.define
local instance
def.static("=>", AagrStartPanel).Instance = function()
  if instance == nil then
    instance = AagrStartPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("number")._countdown = 0
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.static("number").ShowPanel = function(countdown)
  if not AagrData.Instance():IsInArena() or countdown <= 0 then
    warn("[ERROR][AagrStartPanel:ShowPanel] show fail! not in arena or countdown<=0:", countdown)
    if AagrStartPanel.Instance():IsShow() then
      AagrStartPanel.Instance():DestroyPanel()
    end
    return
  end
  if AagrStartPanel.Instance():IsShow() then
    AagrStartPanel.Instance():UpdateUI()
    return
  end
  AagrStartPanel.Instance():CreatePanel(RESPATH.PREFAB_AAGR_START_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:UpdateUI()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Time = self.m_panel:FindDirect("Img_Bg0/Label_Time")
end
def.method().UpdateUI = function(self)
  local countdown = ArenaCountdownMgr.Instance():GetCountdown()
  if countdown <= 0 then
    warn("[AagrStartPanel:UpdateUI] countdown end, DestroyPanel.")
    self:DestroyPanel()
  else
    self:ShowCountdown(countdown)
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
  self._countdown = 0
end
def.method()._Update = function(self)
  self:UpdateUI()
end
def.method("number").ShowCountdown = function(self, countdown)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Label_Time) then
    GUIUtils.SetText(self._uiObjs.Label_Time, countdown)
  end
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
  end
end
AagrStartPanel.Commit()
return AagrStartPanel
