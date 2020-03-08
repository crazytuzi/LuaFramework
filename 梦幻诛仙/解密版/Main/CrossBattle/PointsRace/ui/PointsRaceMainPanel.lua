local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local PointsRaceMainPanel = Lplus.Extend(ECPanelBase, "PointsRaceMainPanel")
local def = PointsRaceMainPanel.define
local instance
def.static("=>", PointsRaceMainPanel).Instance = function()
  if instance == nil then
    instance = PointsRaceMainPanel()
  end
  return instance
end
def.const("number").UPDATE_INTERVAL = 1
def.field("table")._uiObjs = nil
def.field("number")._timerID = 0
def.static().ShowPanel = function()
  if not PointsRaceMgr.Instance():IsRaceOpen(true) then
    if PointsRaceMainPanel.Instance():IsShow() then
      PointsRaceMainPanel.Instance():DestroyPanel()
    end
    return
  end
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  if not PointsRaceUtils.IsCrossBattlePointsRaceStage() then
    warn("[PointsRaceMainPanel:ShowPanel] ShowPanel fail, PointsRaceUtils.IsCrossBattlePointsRaceStage()==false.")
    if PointsRaceMainPanel.Instance():IsShow() then
      PointsRaceMainPanel.Instance():DestroyPanel()
    end
    return
  end
  if PointsRaceMainPanel.Instance():IsShow() then
    PointsRaceMainPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_POINTS_RACE_MAIN_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Time = self.m_panel:FindDirect("Group_Time/Label_Time")
  self._uiObjs.Btn_Detail = self.m_panel:FindDirect("Group_Time/Btn_Detail")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_ClearTimer()
  local curStage = PointsRaceData.Instance():GetCurStage()
  if curStage == PointsRaceMgr.StageEnum.PREPARE or curStage == PointsRaceMgr.StageEnum.MATCHING or curStage == PointsRaceMgr.StageEnum.STOP_MATCH then
    GUIUtils.SetActive(self._uiObjs.Label_Time, true)
    self:UpdateCountDown()
    self._timerID = GameUtil.AddGlobalTimer(PointsRaceMainPanel.UPDATE_INTERVAL, false, function()
      self:UpdateCountDown()
    end)
  else
    GUIUtils.SetActive(self._uiObjs.Label_Time, false)
  end
end
def.method().UpdateCountDown = function(self)
  if nil == self._uiObjs then
    return
  end
  local countdown = 0
  local curStage = PointsRaceData.Instance():GetCurStage()
  if curStage == PointsRaceMgr.StageEnum.MATCHING then
    if not _G.PlayerIsInFight() then
      countdown = PointsRaceData.Instance():GetNextMatchCountdown()
    end
  else
    countdown = PointsRaceData.Instance():GetStageCountdown()
  end
  if countdown > 0 then
    local min = math.floor(countdown / 60)
    local second = math.floor(countdown % 60)
    local countdownStr
    if curStage == PointsRaceMgr.StageEnum.PREPARE then
      countdownStr = string.format(textRes.PointsRace.RACE_ROUND_PREPARE_COUNTDOWN, min, second)
    elseif curStage == PointsRaceMgr.StageEnum.MATCHING then
      countdownStr = string.format(textRes.PointsRace.RACE_ROUND_MATCHING_COUNTDOWN, min, second)
    elseif curStage == PointsRaceMgr.StageEnum.STOP_MATCH then
      countdownStr = string.format(textRes.PointsRace.RACE_ROUND_STOP_MATCH_COUNTDOWN, min, second)
    end
    if countdownStr then
      GUIUtils.SetActive(self._uiObjs.Label_Time, true)
      GUIUtils.SetText(self._uiObjs.Label_Time, countdownStr)
    else
      GUIUtils.SetActive(self._uiObjs.Label_Time, false)
    end
  else
    warn("[PointsRaceMainPanel:UpdateCountDown] countdown 0, hide countdown.")
    self:_ClearTimer()
    GUIUtils.SetActive(self._uiObjs.Label_Time, false)
  end
end
def.override().OnDestroy = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Detail" then
    self:OnBtn_Detail()
  end
end
def.method().OnBtn_Detail = function(self)
  local PointsRaceInfoPanel = require("Main.CrossBattle.PointsRace.ui.PointsRaceInfoPanel")
  PointsRaceInfoPanel.ShowPanel()
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.POINTS_RACE_MATCH_CD_CHANGE, PointsRaceMainPanel.OnMatchCountdownChange)
  end
end
def.static("table", "table").OnMatchCountdownChange = function(param, context)
  local self = instance
  if self:IsShow() then
    self:UpdateUI()
  end
end
PointsRaceMainPanel.Commit()
return PointsRaceMainPanel
