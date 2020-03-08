local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangDungeonActivityTip = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local def = GangDungeonActivityTip.define
def.field("table").m_UIGOs = nil
def.field("function").m_onThink = nil
local instance
def.static("=>", GangDungeonActivityTip).Instance = function()
  if instance == nil then
    instance = GangDungeonActivityTip()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  if self.m_onThink == nil then
    self.m_onThink = self.DefaultThink
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_DUNGEON_ACT_TIP, 0)
end
def.method("function").ShowPanelWithThink = function(self, thinkfunc)
  self.m_onThink = thinkfunc
  self:ShowPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Timer:RegisterListener(self.Think, self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GangDungeonActivityTip.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, GangDungeonActivityTip.OnLeaveFight)
  if _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_onThink = nil
  Timer:RemoveListener(self.Think)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GangDungeonActivityTip.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, GangDungeonActivityTip.OnLeaveFight)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == false then
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Label_Time = self.m_panel:FindDirect("Label_Time")
end
def.method().UpdateUI = function(self)
  self:Think(0)
end
def.method("number").Think = function(self, dt)
  local msg
  if self.m_onThink then
    msg = self:m_onThink(dt)
  else
    msg = ""
  end
  GUIUtils.SetActive(self.m_UIGOs.Label_Time, msg ~= "")
  GUIUtils.SetText(self.m_UIGOs.Label_Time, msg)
end
def.method("number", "=>", "string").DefaultThink = function(self, dt)
  local stage = GangDungeonModule.Instance():GetDungeonStage()
  if stage == GangDungeonModule.DungeonStage.STG_BOSS_COUNTDOWN then
    return self:GetBossAppearCountDownTxt()
  elseif stage == GangDungeonModule.DungeonStage.STG_KILL_BOSS then
    return self:GetBossDisappearCountDownTxt()
  elseif stage == GangDungeonModule.DungeonStage.STG_FINISH_COUNTDOWN then
    return self:GetDungeonCloseCountDownTxt()
  elseif stage == GangDungeonModule.DungeonStage.STG_KILL_MONSTER then
    return self:GetDungeonTimeoutCloseCountDownTxt()
  else
    return ""
  end
end
def.method("=>", "string").GetBossAppearCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[40]:format(timeText)
end
def.method("=>", "string").GetBossDisappearCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[41]:format(timeText)
end
def.method("=>", "string").GetDungeonCloseCountDownTxt = function(self)
  local leftSeconds = GangDungeonModule.Instance():GetStageEndLeftSeconds()
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[42]:format(timeText)
end
def.method("=>", "string").GetDungeonTimeoutCloseCountDownTxt = function(self)
  local endTime = GangDungeonModule.Instance():GetTimeoutEndTimestamp()
  local curTime = _G.GetServerTime()
  local leftSeconds = math.max(0, endTime - curTime)
  local timeText = _G.SeondsToTimeText(leftSeconds)
  return textRes.GangDungeon[42]:format(timeText)
end
def.static("table", "table").OnEnterFight = function(params, context)
  instance:Show(false)
end
def.static("table", "table").OnLeaveFight = function(params, context)
  instance:Show(true)
end
return GangDungeonActivityTip.Commit()
