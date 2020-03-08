local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RunningXuanGongData = require("Main.Soaring.data.RunningXuanGongData")
local TaskYZXGMgr = require("Main.Soaring.TaskYZXGMgr")
local UIRunningXuanGong = Lplus.Extend(ECPanelBase, "UIRunningXuanGong")
local def = UIRunningXuanGong.define
local instance
def.static("=>", UIRunningXuanGong).Instance = function()
  if instance == nil then
    instance = UIRunningXuanGong()
  end
  return instance
end
def.field("table")._uiGOs = nil
def.field("number")._curExp = 0
def.field("number")._timerID = 0
def.field("boolean")._bPlayingEffect = false
def.const("number").EFFECT_DURATION = 1.3
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_RUNNINGXUANGONG, 1)
  self:SetModal(true)
end
def.method().Reset = function(self)
  self._curExp = 0
  if 0 < self._timerID then
    GameUtil.RemoveGlobalTimer(self._timerID)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Reset()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self._curExp = RunningXuanGongData.Instance():GetCurrentExp()
    self:UpdateBall()
  end
  self:HandleEventListeners(show)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.SOARING, gmodule.notifyId.Soaring.YZXG_ADD_EXP_SUC, UIRunningXuanGong.OnAddExpSuc)
  end
end
def.method().InitUI = function(self)
  self._uiGOs = {}
  self._uiGOs.ballSlider = self.m_panel:FindDirect("Img_Bg/Btn_Ball/Slider_Prograss"):GetComponent("UISlider")
  self._uiGOs.Label_Slider = self.m_panel:FindDirect("Img_Bg/Btn_Ball/Slider_Prograss/Label_Slider"):GetComponent("UILabel")
  self._uiGOs.fx = self.m_panel:FindDirect("Img_Bg/Fx")
end
def.method().UpdateBall = function(self)
  local rate = self._curExp / RunningXuanGongData.Instance():GetFullExp()
  self._uiGOs.ballSlider:set_sliderValue(rate)
  self._uiGOs.Label_Slider:set_text(self._curExp .. "/" .. RunningXuanGongData.Instance():GetFullExp())
  if rate >= 1 then
    self:PlayEffect()
  end
end
def.static("table", "table").OnAddExpSuc = function(p1, P2)
  UIRunningXuanGong.Instance():AddExpSuc(p1[1])
  UIRunningXuanGong.Instance():UpdateBall()
end
def.method("number").AddExpSuc = function(self, addexp)
  self._curExp = self._curExp + addexp
end
def.override().OnDestroy = function(self)
  if self._uiGOs ~= nil then
    self._uiGOs = nil
  end
  self:Reset()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Ball" then
    self:OnBtnInjectExpClick()
  end
end
def.method().PlayEffect = function(self)
  if self._bPlayingEffect then
    self._uiGOs.fx:SetActive(false)
  end
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
  end
  self._bPlayingEffect = true
  self._uiGOs.fx:SetActive(true)
  self._timerID = GameUtil.AddGlobalTimer(UIRunningXuanGong.EFFECT_DURATION, true, function()
    self:OnPlayEffectFinish()
  end)
end
def.method().OnPlayEffectFinish = function(self)
  self._bPlayingEffect = false
  self._uiGOs.fx:SetActive(false)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
  end
end
def.method().OnBtnInjectExpClick = function(self)
  TaskYZXGMgr.Send_CDevelopItemInDevelopItemActivityReq()
  self:PlayEffect()
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
return UIRunningXuanGong.Commit()
