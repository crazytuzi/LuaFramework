local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PrepareCountDownPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local def = PrepareCountDownPanel.define
def.field("number").leftTime = 0
def.field("number").endTime = 0
def.field("table").uiGOs = nil
local instance
def.static("=>", PrepareCountDownPanel).Instance = function()
  if instance == nil then
    instance = PrepareCountDownPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if not self:IsShow() then
    self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE_PREPARE, 0)
  end
end
def.method("=>", "boolean").CanShow = function(self)
  return GangDungeonModule.Instance():IsInPrepareMap()
end
def.override().OnCreate = function(self)
  if not self:CanShow() then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self.endTime = GangDungeonModule.Instance():GetPrepareEndTimestamp()
  Timer:RegisterListener(self.UpdateCountDown, self)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.LeaveGangDungeon, PrepareCountDownPanel.OnLeaveGangDungeon)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ChangeGangDungeonMap, PrepareCountDownPanel.OnChangeGangDungeonMap)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.PrepareRoleNumChanged, PrepareCountDownPanel.OnPrepareRoleNumChanged)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, PrepareCountDownPanel.OnOpenTimeChanged)
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateCountDown)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.LeaveGangDungeon, PrepareCountDownPanel.OnLeaveGangDungeon)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ChangeGangDungeonMap, PrepareCountDownPanel.OnChangeGangDungeonMap)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.PrepareRoleNumChanged, PrepareCountDownPanel.OnPrepareRoleNumChanged)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, PrepareCountDownPanel.OnOpenTimeChanged)
  self.uiGOs = nil
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateUI()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().UpdateLeftTime = function(self)
  local curTime = _G.GetServerTime()
  local endTime = self.endTime
  self.leftTime = endTime - curTime
  self.leftTime = self.leftTime > 0 and self.leftTime or 0
end
def.method().InitUI = function(self)
  self.uiGOs = {}
  self.uiGOs.Label_LeftTime = self.m_panel:FindDirect("Img_Bg/Img_LeftTime/Label_Num")
  self.uiGOs.Label_PersonNum = self.m_panel:FindDirect("Img_Bg/Img_PersonNum/Label_Num")
  self.uiGOs.Img_MovePower = self.m_panel:FindDirect("Img_Bg/Img_MovePower")
  GUIUtils.SetActive(self.uiGOs.Img_MovePower, false)
end
def.method().UpdateUI = function(self)
  self:UpdateCountDown(0)
  self:UpdateRoleNum()
end
def.method("number").UpdateCountDown = function(self, tk)
  self:UpdateLeftTime()
  if self.leftTime < 0 then
    return
  end
  local left = Seconds2HMSTime(self.leftTime)
  local leftTimeText = string.format(textRes.Gang[214], left.m, left.s)
  GUIUtils.SetText(self.uiGOs.Label_LeftTime, leftTimeText)
end
def.method().UpdateRoleNum = function(self)
  local roleNum = GangDungeonModule.Instance():GetPrepareSceneRoleNums()
  GUIUtils.SetText(self.uiGOs.Label_PersonNum, roleNum)
end
def.static("table", "table").OnLeaveGangDungeon = function(params, context)
  instance:Hide()
end
def.static("table", "table").OnChangeGangDungeonMap = function(params, context)
  if not instance:CanShow() then
    instance:Hide()
  end
end
def.static("table", "table").OnPrepareRoleNumChanged = function(params, context)
  instance:UpdateRoleNum()
end
def.static("table", "table").OnOpenTimeChanged = function(params, context)
  instance.endTime = GangDungeonModule.Instance():GetPrepareEndTimestamp()
  instance:UpdateCountDown(0)
end
return PrepareCountDownPanel.Commit()
