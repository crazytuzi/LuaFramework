local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CourtyardUpgradePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
local def = CourtyardUpgradePanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_courtyard = nil
def.field("table").m_currency = nil
local instance
def.static("=>", CourtyardUpgradePanel).Instance = function()
  if instance == nil then
    instance = CourtyardUpgradePanel()
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
  self:CreatePanel(RESPATH.PERFAB_COURTYARD_LEVEL_UP_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, CourtyardUpgradePanel.OnLeaveCourtyardSence)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, CourtyardUpgradePanel.OnLoseHomelandControl)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, CourtyardUpgradePanel.OnCourtyardLevelUp)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, CourtyardUpgradePanel.OnLeaveCourtyardSence)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, CourtyardUpgradePanel.OnLoseHomelandControl)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, CourtyardUpgradePanel.OnCourtyardLevelUp)
  self.m_UIGOs = nil
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(CourtyardUpgradePanel.OnCurrencyChanged)
  end
  self.m_currency = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_QL_Add" then
    if self.m_currency then
      self.m_currency:Acquire()
    end
  elseif id == "Btn_Upgrade" then
    self:OnClickUpgradeBtn()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Cur = self.m_UIGOs.Img_Bg:FindDirect("Group_Cur")
  self.m_UIGOs.Group_Next = self.m_UIGOs.Img_Bg:FindDirect("Group_Next")
  self.m_UIGOs.Group_Money = self.m_UIGOs.Img_Bg:FindDirect("Group_Money")
  local Btn_Help = self.m_UIGOs.Img_Bg:FindDirect("Btn_Help")
  if Btn_Help then
    Btn_Help.name = "Btn_Tips_" .. tostring(constant.CHomelandCfgConsts.court_yard_level_up_tips_id)
  end
end
def.method().UpdateUI = function(self)
  local courtyard = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetMyCourtyard()
  local curLevel = courtyard:GetLevel()
  local nextLevel = courtyard:GetNextLevel()
  self:SetCourtyardInfo(self.m_UIGOs.Group_Cur, curLevel)
  self:SetCourtyardInfo(self.m_UIGOs.Group_Next, nextLevel)
  self:SetCurrencyInfo(nextLevel)
end
def.method("userdata", "number").SetCourtyardInfo = function(self, group, level)
  local Group_Lv = group:FindDirect("Group_Lv")
  local Group_Beauty = group:FindDirect("Group_Beauty")
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(level)
  local showName, maxBeauty
  if courtyardCfg then
    showName = courtyardCfg.showName
    maxBeauty = courtyardCfg.maxBeauty
  else
    showName = "level_" .. level
    maxBeauty = -1
  end
  GUIUtils.SetText(Group_Lv:FindDirect("Label_Num"), showName)
  GUIUtils.SetText(Group_Beauty:FindDirect("Label_Num"), maxBeauty)
end
def.method("number").SetCurrencyInfo = function(self, nextLevel)
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(CourtyardUpgradePanel.OnCurrencyChanged)
    self.m_currency = nil
  end
  local nextLevelCfg = HomelandUtils.GetCourtyardCfg(nextLevel)
  self.m_currency = CurrencyFactory.Create(nextLevelCfg.costMoneyType)
  self.m_currency:RegisterCurrencyChangedEvent(CourtyardUpgradePanel.OnCurrencyChanged)
  self:SetNeededCurrency(nextLevelCfg.costMoneyNum)
  self:UpdateOwnedCurrency()
end
def.method("number").SetNeededCurrency = function(self, needNum)
  local Img_QL_BgUseMoney = self.m_UIGOs.Group_Money:FindDirect("Img_QL_BgUseMoney")
  local Label_QL_UseMoneyNum = Img_QL_BgUseMoney:FindDirect("Label_QL_UseMoneyNum")
  local Img_QL_UseMoneyIcon = Img_QL_BgUseMoney:FindDirect("Img_QL_UseMoneyIcon")
  GUIUtils.SetText(Label_QL_UseMoneyNum, tostring(needNum))
  local spriteName = self.m_currency:GetSpriteName()
  GUIUtils.SetSprite(Img_QL_UseMoneyIcon, spriteName)
end
def.method().UpdateOwnedCurrency = function(self)
  local Img_QL_BgHaveMoney = self.m_UIGOs.Group_Money:FindDirect("Img_QL_BgHaveMoney")
  local Label_QL_HaveMoneyNum = Img_QL_BgHaveMoney:FindDirect("Label_QL_HaveMoneyNum")
  local Img_QL_HaveMoneyIcon = Img_QL_BgHaveMoney:FindDirect("Img_QL_HaveMoneyIcon")
  local haveNum = self.m_currency:GetHaveNum()
  GUIUtils.SetText(Label_QL_HaveMoneyNum, tostring(haveNum))
  local spriteName = self.m_currency:GetSpriteName()
  GUIUtils.SetSprite(Img_QL_HaveMoneyIcon, spriteName)
end
def.method().OnClickUpgradeBtn = function(self)
  local courtyard = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetMyCourtyard()
  local nextLevel = courtyard:GetNextLevel()
  local nextLevelCfg = HomelandUtils.GetCourtyardCfg(nextLevel)
  local costMoneyNum = nextLevelCfg.costMoneyNum
  local haveNum = self.m_currency:GetHaveNum()
  if haveNum:lt(costMoneyNum) then
    self.m_currency:AcquireWithQuery()
    return
  end
  CourtyardMgr.Instance():UpgradeMyCourtyard()
end
def.static("table", "table").OnLeaveCourtyardSence = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnLoseHomelandControl = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnCourtyardLevelUp = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnCurrencyChanged = function()
  instance:UpdateOwnedCurrency()
end
return CourtyardUpgradePanel.Commit()
