local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleWaitingHallPanel = Lplus.Extend(ECPanelBase, "CrossBattleWaitingHallPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleWaitingHallPanel.define
def.field("table").uiObjs = nil
def.field("number").leftTime = 0
def.field("string").desc = ""
def.field("function").infoHandler = nil
def.field("number").timerId = 0
def.field("userdata").waitEffect = nil
local instance
def.static("=>", CrossBattleWaitingHallPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleWaitingHallPanel()
  end
  return instance
end
def.method("number", "string").ShowPanel = function(self, leftTime, desc)
  if self:IsShow() then
    return
  end
  self.leftTime = leftTime
  self.desc = desc
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_WAITING_HALL, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateLeftTime()
  self:StartTimer()
end
def.override().OnDestroy = function(self)
  self:StopTimer()
  self:RemoveWaitTips()
  self.uiObjs = nil
  self.leftTime = 0
  self.infoHandler = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Label_Time = self.m_panel:FindDirect("Label_Time")
end
def.method().UpdateLeftTime = function(self)
  if self.uiObjs == nil then
    return
  end
  local t = _G.Seconds2HMSTime(self.leftTime)
  GUIUtils.SetText(self.uiObjs.Label_Time, string.format(textRes.CrossBattle.CrossBattleSelection[7], t.m, t.s, self.desc))
end
def.method().StartTimer = function(self)
  if self.timerId == 0 then
    self.timerId = GameUtil.AddGlobalTimer(1, false, function()
      self:Tick()
      self:UpdateLeftTime()
    end)
  end
end
def.method().Tick = function(self)
  if self.leftTime <= 0 then
    self.leftTime = 0
  else
    self.leftTime = self.leftTime - 1
    if self.leftTime <= 0 then
      self:ShowWaitTips()
    end
  end
end
def.method().ShowWaitTips = function(self)
  Toast(textRes.CrossBattle[110])
  if self.waitEffect == nil then
    local effectCfg = GetEffectRes(constant.CrossBattleConsts.cross_battle_match_wait_effect_id)
    if effectCfg ~= nil then
      self.waitEffect = require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "CrossBattleWaitingHallPanel", 0, 200, -1, false)
    else
      warn("no effect id:" .. constant.CrossBattleConsts.cross_battle_match_wait_effect_id)
    end
  end
end
def.method().RemoveWaitTips = function(self)
  if self.waitEffect ~= nil then
    require("Fx.GUIFxMan").Instance():RemoveFx(self.waitEffect)
    self.waitEffect = nil
  end
end
def.method().StopTimer = function(self)
  if self.timerId > 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("number").SetLeftTime = function(self, leftTime)
  self.leftTime = leftTime
end
def.method("function").SetBattleInfoHandler = function(self, cb)
  self.infoHandler = cb
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Detail" then
    self:OnBtnDetailClick()
  end
end
def.method().OnBtnDetailClick = function(self)
  if self.infoHandler then
    self.infoHandler()
  end
end
CrossBattleWaitingHallPanel.Commit()
return CrossBattleWaitingHallPanel
