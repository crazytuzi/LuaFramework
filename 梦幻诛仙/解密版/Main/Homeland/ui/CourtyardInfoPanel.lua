local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CourtyardInfoPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = CourtyardInfoPanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_courtyard = nil
local instance
def.static("=>", CourtyardInfoPanel).Instance = function()
  if instance == nil then
    instance = CourtyardInfoPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PERFAB_COURTYARD_INFO_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, CourtyardInfoPanel.OnLeaveCourtyardSence)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, CourtyardInfoPanel.OnLoseHomelandControl)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, CourtyardInfoPanel.OnMyCourtyardBeautyChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, CourtyardInfoPanel.OnMyCourtyardCleannessChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, CourtyardInfoPanel.OnCourtyardLevelUp)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, CourtyardInfoPanel.OnLeaveCourtyardSence)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, CourtyardInfoPanel.OnLoseHomelandControl)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardBeautyChange, CourtyardInfoPanel.OnMyCourtyardBeautyChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, CourtyardInfoPanel.OnMyCourtyardCleannessChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, CourtyardInfoPanel.OnCourtyardLevelUp)
  self.m_UIGOs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Upgrade" then
    self:OnClickUpgradeBtn()
  elseif id == "Btn_Clean" then
    self:OnClickCleanBtn()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Lv = self.m_UIGOs.Img_Bg:FindDirect("Group_Lv")
  self.m_UIGOs.Group_Beauty = self.m_UIGOs.Img_Bg:FindDirect("Group_Beauty")
  self.m_UIGOs.Btn_Upgrade = self.m_UIGOs.Img_Bg:FindDirect("Btn_Upgrade")
  self.m_UIGOs.Group_Clean = self.m_UIGOs.Img_Bg:FindDirect("Group_Clean")
  self.m_UIGOs.Btn_Clean = self.m_UIGOs.Img_Bg:FindDirect("Btn_Clean")
  local Btn_Help = self.m_UIGOs.Img_Bg:FindDirect("Btn_Help")
  if Btn_Help then
    Btn_Help.name = "Btn_Tips_" .. tostring(constant.CHomelandCfgConsts.court_yard_info_tips_id)
  end
end
def.method().UpdateUI = function(self)
  self.m_courtyard = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetMyCourtyard()
  self:UpdateLevel()
  self:UpdateBeauty()
  self:UpdateCleanness()
end
def.method().UpdateLevel = function(self)
  local Label_Num = self.m_UIGOs.Group_Lv:FindDirect("Label_Num")
  local levelText = self.m_courtyard:GetLevel()
  GUIUtils.SetText(Label_Num, levelText)
end
def.method().UpdateBeauty = function(self)
  local Label_Num = self.m_UIGOs.Group_Beauty:FindDirect("Label_Num")
  local showName = self.m_courtyard:GetBeautyShowName()
  local beauty = self.m_courtyard:GetBeauty()
  local maxBeauty = self.m_courtyard:GetMaxBeauty()
  local beautyText = string.format("%s(%d/%d)", showName, beauty, maxBeauty)
  GUIUtils.SetText(Label_Num, beautyText)
end
def.method().UpdateCleanness = function(self)
  local Label_Num = self.m_UIGOs.Group_Clean:FindDirect("Label_Num")
  local showName = self.m_courtyard:GetCleannessShowName()
  local cleanness = self.m_courtyard:GetCleanness()
  local maxCleanness = self.m_courtyard:GetMaxCleanness()
  local text = string.format("%s(%d/%d)", showName, cleanness, maxCleanness)
  GUIUtils.SetText(Label_Num, text)
  self:UpdateCleanNotify()
end
def.method().UpdateCleanNotify = function(self)
  local Img_Red = self.m_UIGOs.Btn_Clean:FindDirect("Img_Red")
  local bHasNotify = require("Main.Homeland.CourtyardMgr").Instance():CanCourtyardBeCleand()
  GUIUtils.SetActive(Img_Red, bHasNotify)
end
def.method().OnClickCleanBtn = function(self)
  require("Main.Homeland.CourtyardMgr").Instance():CleanMyCourtyard()
end
def.method().OnClickUpgradeBtn = function(self)
  if self.m_courtyard:IsReachMaxLevel() then
    Toast(textRes.Homeland[92])
    return
  end
  require("Main.Homeland.ui.CourtyardUpgradePanel").Instance():ShowPanel()
end
def.static("table", "table").OnLeaveCourtyardSence = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnLoseHomelandControl = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnMyCourtyardBeautyChange = function()
  instance:UpdateBeauty()
end
def.static("table", "table").OnMyCourtyardCleannessChange = function()
  instance:UpdateCleanness()
end
def.static("table", "table").OnCourtyardLevelUp = function()
  instance:DestroyPanel()
end
return CourtyardInfoPanel.Commit()
