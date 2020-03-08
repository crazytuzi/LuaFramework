local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AagrUtils = require("Main.Aagr.AagrUtils")
local AagrData = require("Main.Aagr.data.AagrData")
local AagrHallPanel = Lplus.Extend(ECPanelBase, "AagrHallPanel")
local def = AagrHallPanel.define
local instance
def.static("=>", AagrHallPanel).Instance = function()
  if instance == nil then
    instance = AagrHallPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._hallInfo = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.static().ShowPanel = function()
  if not AagrData.Instance():IsInHall() then
    warn("[ERROR][AagrHallPanel:ShowPanel] show fail! not in hall.")
    if AagrHallPanel.Instance():IsShow() then
      AagrHallPanel.Instance():DestroyPanel()
    end
    return
  end
  AagrHallPanel.Instance():_InitData()
  if AagrHallPanel.Instance():IsShow() then
    AagrHallPanel.Instance():UpdateUI()
    return
  end
  AagrHallPanel.Instance():CreatePanel(RESPATH.PREFAB_AAGR_HALL_PANEL, 0)
end
def.method()._InitData = function(self)
  self._hallInfo = AagrData.Instance():GetHallInfo()
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:UpdateUI()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_UpdateCountdown()
  end)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.LabelRound = self.m_panel:FindDirect("Img_Bg/Group_Time/Label")
  self._uiObjs.LabelTime = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Num")
  self._uiObjs.LabelRoleNum = self.m_panel:FindDirect("Img_Bg/Group_Num/Label_Num")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show and nil == self._hallInfo then
    self:_InitData()
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  if self._hallInfo then
    warn("[AagrHallPanel:UpdateUI] round, roleNum, bPreparing, stageEndTime:", self._hallInfo.round, self._hallInfo.roleNum, self._hallInfo.bPreparing, os.date("%c", self._hallInfo.stageEndTime))
    local rountStr = textRes.Aagr.HALL_ROUNT_PREPARE
    if not self._hallInfo.bPreparing then
      rountStr = textRes.Aagr.HALL_ROUNT_ARENA
    end
    GUIUtils.SetText(self._uiObjs.LabelRound, string.format(rountStr, self._hallInfo.round))
    GUIUtils.SetText(self._uiObjs.LabelRoleNum, self._hallInfo.roleNum)
  else
    warn("[AagrHallPanel:UpdateUI] hallinfo nil.")
    GUIUtils.SetText(self._uiObjs.LabelRound, string.format(textRes.Aagr.HALL_ROUNT_PREPARE, 1))
    GUIUtils.SetText(self._uiObjs.LabelTime, AagrUtils.GetCountdownText(textRes.Aagr.HALL_COUNTDOWN, 0))
    GUIUtils.SetText(self._uiObjs.LabelRoleNum, 0)
  end
  self:_UpdateCountdown()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._hallInfo = nil
end
def.method()._UpdateCountdown = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.LabelTime) then
    local countdown = self._hallInfo and math.max(0, self._hallInfo.stageEndTime - _G.GetServerTime()) or 0
    GUIUtils.SetText(self._uiObjs.LabelTime, AagrUtils.GetCountdownText(textRes.Aagr.HALL_COUNTDOWN, countdown))
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
    eventFunc(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_HALL_INFO_CHANGE, AagrHallPanel.OnHallInfoChange)
  end
end
def.static("table", "table").OnHallInfoChange = function(params, context)
  local self = AagrHallPanel.Instance()
  if self and self:IsShow() then
    if nil == self._hallInfo then
      self:_InitData()
    end
    self:UpdateUI()
  end
end
AagrHallPanel.Commit()
return AagrHallPanel
