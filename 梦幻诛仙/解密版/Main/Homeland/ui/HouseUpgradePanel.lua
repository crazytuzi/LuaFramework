local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HouseUpgradePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local HouseMgr = require("Main.Homeland.HouseMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local def = HouseUpgradePanel.define
def.field("table").m_UIGOs = nil
def.field("number").m_selPayMethod = 0
def.field("table").m_house = nil
def.field("table").m_currency = nil
def.field("table").m_levelUpNeeds = nil
local instance
def.static("=>", HouseUpgradePanel).Instance = function()
  if instance == nil then
    instance = HouseUpgradePanel()
    instance:Init()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = HouseUpgradePanel.Instance()
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UPGRADE_HOUSE_PANEL, 1)
end
def.method().Init = function(self)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.m_house = HouseMgr.Instance():GetMyHouse()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.House_LevelUp_Success, HouseUpgradePanel.OnHouseUpgrade)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, HouseUpgradePanel.OnLeaveHomeland)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_house = nil
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(HouseUpgradePanel.OnCurrencyChanged)
  end
  self.m_currency = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.House_LevelUp_Success, HouseUpgradePanel.OnHouseUpgrade)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, HouseUpgradePanel.OnLeaveHomeland)
  instance = nil
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Current = self.m_UIGOs.Img_Bg:FindDirect("Group_Current")
  self.m_UIGOs.Group_Result = self.m_UIGOs.Img_Bg:FindDirect("Group_Result")
  self.m_UIGOs.Group_Full = self.m_UIGOs.Img_Bg:FindDirect("Group_Full")
  self.m_UIGOs.Label_Number = self.m_UIGOs.Img_Bg:FindDirect("Label_Number")
  self.m_UIGOs.Group_CostMake = self.m_panel:FindDirect("Group_CostMake")
  self.m_UIGOs.Group_HaveMoney = self.m_UIGOs.Group_CostMake:FindDirect("Group_HaveMoney")
  self.m_UIGOs.Label_HaveMoneyNum = self.m_UIGOs.Group_HaveMoney:FindDirect("Label_HaveMoneyNum")
  self.m_UIGOs.Img_HaveMoneyIcon = self.m_UIGOs.Group_HaveMoney:FindDirect("Img_HaveMoneyIcon")
  self.m_UIGOs.Group_CostMoney = self.m_UIGOs.Group_CostMake:FindDirect("Group_CostMoney")
  self.m_UIGOs.Label_CostMoneyNum = self.m_UIGOs.Group_CostMoney:FindDirect("Label_CostMoneyNum")
  self.m_UIGOs.Img_CostMoneyIcon = self.m_UIGOs.Group_CostMoney:FindDirect("Img_CostMoneyIcon")
end
def.method().UpdateUI = function(self)
  if self.m_house:IsReachMaxLevel() then
    self:ShowHouseMaxLevelView()
  else
    self:ShowHouseUpgradeView()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Add" then
    self:OnAddBtnClick()
  elseif id == "Btn_Confirm" then
    self:OnConfirmBtnClick()
  elseif id == "Btn_Tips" then
    self:OnTipsBtnClick()
  end
end
def.method().ShowHouseMaxLevelView = function(self)
  GUIUtils.SetActive(self.m_UIGOs.Group_Full, true)
  GUIUtils.SetActive(self.m_UIGOs.Group_Current, false)
  GUIUtils.SetActive(self.m_UIGOs.Group_Result, false)
  GUIUtils.SetActive(self.m_UIGOs.Label_Number, false)
  local curLevel = self.m_house:GetLevel()
  local curLevelInfo = HouseMgr.Instance():GetHouseLevelInfo(curLevel)
  local Img_Bg = self.m_UIGOs.Group_Full:FindDirect("Img_Bg")
  local Texture = Img_Bg:FindDirect("Texture")
  GUIUtils.SetTexture(Texture, curLevelInfo.icon)
  local Label_Current = Img_Bg:FindDirect("Label_Current")
  GUIUtils.SetText(Label_Current, curLevelInfo.name)
  local Label_Number = Img_Bg:FindDirect("Label_Number")
  GUIUtils.SetText(Label_Number, curLevelInfo.maxGeomancy)
end
def.method().ShowHouseUpgradeView = function(self)
  GUIUtils.SetActive(self.m_UIGOs.Group_Full, false)
  GUIUtils.SetActive(self.m_UIGOs.Group_Current, true)
  GUIUtils.SetActive(self.m_UIGOs.Group_Result, true)
  GUIUtils.SetActive(self.m_UIGOs.Label_Number, true)
  local curLevel = self.m_house:GetLevel()
  local nextLevel = self.m_house:GetNextLevel()
  local curLevelInfo = HouseMgr.Instance():GetHouseLevelInfo(curLevel)
  local nextLevelInfo = HouseMgr.Instance():GetHouseLevelInfo(nextLevel)
  local Label_Current = self.m_UIGOs.Group_Current:FindDirect("Label_Current")
  local text = string.format(textRes.Homeland[11], curLevelInfo.name)
  GUIUtils.SetText(Label_Current, text)
  local Img_House = self.m_UIGOs.Group_Current:FindDirect("Img_House")
  GUIUtils.SetTexture(Img_House, curLevelInfo.icon)
  local LabelNext = self.m_UIGOs.Group_Result:FindDirect("LabelNext")
  local text = string.format(textRes.Homeland[12], nextLevelInfo.name)
  GUIUtils.SetText(LabelNext, text)
  local Img_House = self.m_UIGOs.Group_Result:FindDirect("Img_House")
  GUIUtils.SetTexture(Img_House, nextLevelInfo.icon)
  local levelUpNeeds = HouseMgr.Instance():GetHouseLevelUpNeeds(nextLevel)
  self.m_levelUpNeeds = levelUpNeeds
  local needCurrency = levelUpNeeds.currency
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(HouseUpgradePanel.OnCurrencyChanged)
  end
  self.m_currency = CurrencyFactory.Create(needCurrency.currencyType)
  self.m_currency:RegisterCurrencyChangedEvent(HouseUpgradePanel.OnCurrencyChanged)
  local spriteName = self.m_currency:GetSpriteName()
  local haveNum = self.m_currency:GetHaveNum()
  local needNum = needCurrency.number
  GUIUtils.SetSprite(self.m_UIGOs.Img_HaveMoneyIcon, spriteName)
  GUIUtils.SetSprite(self.m_UIGOs.Img_CostMoneyIcon, spriteName)
  GUIUtils.SetText(self.m_UIGOs.Label_HaveMoneyNum, tostring(haveNum))
  GUIUtils.SetText(self.m_UIGOs.Label_CostMoneyNum, tostring(needNum))
  GUIUtils.SetText(self.m_UIGOs.Label_Number, nextLevelInfo.maxGeomancy)
end
def.method().UpdateCurrencyNum = function(self)
  if self.m_currency == nil then
    return
  end
  local haveNum = self.m_currency:GetHaveNum()
  GUIUtils.SetText(self.m_UIGOs.Label_HaveMoneyNum, tostring(haveNum))
end
def.method().OnAddBtnClick = function(self)
  if self.m_currency == nil then
    return
  end
  self.m_currency:Acquire()
end
def.method().OnConfirmBtnClick = function(self)
  if self.m_levelUpNeeds == nil then
    return
  end
  local needNum = self.m_levelUpNeeds.currency.number
  local haveNum = self.m_currency:GetHaveNum()
  if needNum > haveNum then
    self.m_currency:AcquireWithQuery()
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local title = ""
  local moneyName = self.m_currency:GetName()
  local nextLevel = self.m_house:GetNextLevel()
  local nextLevelInfo = HouseMgr.Instance():GetHouseLevelInfo(nextLevel)
  local nextLevelHouseName = nextLevelInfo.name
  local desc = string.format(textRes.Homeland[57], tostring(needNum), moneyName, nextLevelHouseName)
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      HouseMgr.Instance():UpgradeMyHouse(HouseMgr.PayMethod.Currency)
    end
  end, nil)
end
def.method().OnTipsBtnClick = function(self)
  local tipId = 701605015
  require("Main.Common.TipsHelper").ShowHoverTip(tipId, 0, 0)
end
def.static("table", "table").OnCurrencyChanged = function()
  if instance == nil then
    return
  end
  instance:UpdateCurrencyNum()
end
def.static("table", "table").OnHouseUpgrade = function()
  if instance == nil then
    return
  end
  instance:UpdateUI()
end
def.static("table", "table").OnLeaveHomeland = function()
  if instance == nil then
    return
  end
  instance:DestroyPanel()
end
return HouseUpgradePanel.Commit()
