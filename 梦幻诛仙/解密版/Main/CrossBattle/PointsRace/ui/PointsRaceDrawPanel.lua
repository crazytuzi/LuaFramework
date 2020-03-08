local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local PointsRaceDrawPanel = Lplus.Extend(ECPanelBase, "PointsRaceDrawPanel")
local def = PointsRaceDrawPanel.define
local instance
def.static("=>", PointsRaceDrawPanel).Instance = function()
  if instance == nil then
    instance = PointsRaceDrawPanel()
  end
  return instance
end
def.const("number").SHOW_DURATION = 5.5
def.field("table")._uiObjs = nil
def.field("number")._zondId = 0
def.field("number")._showTimerID = 0
def.static("number").ShowPanel = function(zondId)
  if not PointsRaceMgr.Instance():IsDrawOpen(true) then
    if PointsRaceDrawPanel.Instance():IsShow() then
      PointsRaceDrawPanel.Instance():DestroyPanel()
    end
    return
  end
  PointsRaceDrawPanel.Instance():InitData(zondId)
  if PointsRaceDrawPanel.Instance():IsShow() then
    PointsRaceDrawPanel.Instance():ShowDraw()
    return
  end
  PointsRaceDrawPanel.Instance():CreatePanel(RESPATH.PREFAB_POINTS_RACE_DRAW_PANEL, 0)
end
def.method("number").InitData = function(self, zondId)
  self._zondId = zondId
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Tween_Qian = self.m_panel:FindDirect("Tween_Qian")
  self._uiObjs.Img_Label = self._uiObjs.Tween_Qian:FindDirect("UI_SaiQuChouQian/DingChouQian_DH/SaiQu_DH/ShuZi/Label")
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:ShowDraw()
  else
  end
end
def.method().ShowDraw = function(self)
  self:_ClearShowTimer()
  GUIUtils.SetActive(self._uiObjs.Tween_Qian, false)
  GUIUtils.SetText(self._uiObjs.Img_Label, self._zondId)
  GUIUtils.SetActive(self._uiObjs.Tween_Qian, true)
  self._showTimerID = GameUtil.AddGlobalTimer(PointsRaceDrawPanel.SHOW_DURATION, true, function()
    self:DestroyPanel()
  end)
end
def.method()._ClearShowTimer = function(self)
  if self._showTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._showTimerID)
    self._showTimerID = 0
  end
end
def.override().OnDestroy = function(self)
  self:_ClearShowTimer()
end
PointsRaceDrawPanel.Commit()
return PointsRaceDrawPanel
