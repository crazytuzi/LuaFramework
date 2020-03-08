local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIBuyConfirmPanel = Lplus.Extend(ECPanelBase, "UIBuyConfirmPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local def = UIBuyConfirmPanel.define
local instance
def.field("table")._uiCfg = nil
def.field("table")._uiGOs = nil
def.static("=>", UIBuyConfirmPanel).Instance = function()
  if instance == nil then
    instance = UIBuyConfirmPanel()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self:InitUI()
end
def.method().InitUI = function(self)
  local groupRight = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  self._uiGOs.groupRight = groupRight
  local icon = groupRight:FindDirect("Img_BgRightItem/Texture_RightIcon")
  GUIUtils.SetTexture(icon, self._uiCfg.icon or 0)
  local lblAvaNum = groupRight:FindDirect("Img_BgRightItem/Label_Num")
  local avaNum = self._uiCfg.numItems
  if avaNum == nil or avaNum == -1 then
    lblAvaNum:SetActive(false)
  else
    GUIUtils.SetText(lblAvaNum, avaNum)
  end
  local lblName = groupRight:FindDirect("Label_RightName")
  GUIUtils.SetText(lblName, self._uiCfg.name or "")
  local lblTypeName = groupRight:FindDirect("Label_Type")
  local typeName = self._uiCfg.typeName
  if typeName == nil or typeName == "" then
    lblTypeName:SetActive(false)
  else
    lblTypeName:SetActive(true)
    GUIUtils.SetText(lblTypeName, typeName)
  end
  local lblLv = groupRight:FindDirect("Label_Lv")
  local lv = self._uiCfg.level
  if lv == nil or lv == -1 then
    lblLv:SetActive(false)
  else
    lblLv:SetActive(true)
    GUIUtils.SetText(lblLv, lv)
  end
  local groupPrice = groupRight:FindDirect("Group_Price")
  local moneyIcon = self._uiCfg.moneyIcon
  local price = self._uiCfg.price
  if price == nil or price == -1 then
    groupPrice:SetActive(false)
  else
    local iconMoney = groupPrice:FindDirect("Img_Money")
    local lblPrice = groupPrice:FindDirect("Label_Price")
    GUIUtils.SetSprite(iconMoney, moneyIcon)
    GUIUtils.SetText(lblPrice, price)
  end
  local labelDesc = groupRight:FindDirect("Img_BgDescribe/Scroll View/Label_Describe"):GetComponent("NGUIHTML")
  local desc = self._uiCfg.desc
  desc = desc or ""
  labelDesc:ForceHtmlText("<p align=center valign=middle linespacing=8><font size=18>" .. desc .. "</font></p>")
  self:SetChooseNumAndNeedMoney()
end
def.override().OnDestroy = function(self)
  self._uiCfg = nil
  self._uiGOs = nil
end
def.method("table").ShowPanel = function(self, uiCfg)
  self._uiCfg = uiCfg
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LUCKY_STAR_CONFIRM_PANEL, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Texture_RightIcon" then
    self:OnItemIconClick(obj)
  elseif id == "Btn_Max" then
    self:OnBtnMaxClick()
  elseif id == "Btn_Add" then
    self:OnBtnAddClick()
  elseif id == "Btn_Minus" then
    self:OnBtnMinusClick()
  elseif id == "Btn_Buy" then
    self:OnBtnBuyClick()
  end
end
def.method().OnBtnMinusClick = function(self)
  self._uiCfg.numToBuy = math.max(1, self._uiCfg.numToBuy - 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnBtnAddClick = function(self)
  self._uiCfg.numToBuy = math.min(self._uiCfg.avaliableNum, self._uiCfg.numToBuy + 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnBtnMaxClick = function(self)
  self._uiCfg.numToBuy = self._uiCfg.avaliableNum
  self:SetChooseNumAndNeedMoney()
end
def.method().OnBtnBuyClick = function(self)
  if self._uiCfg.buyCallback ~= nil then
    self._uiCfg.buyCallback(self._uiCfg.numToBuy)
  end
  self:HidePanel()
end
def.method("userdata").OnItemIconClick = function(self, go)
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(self._uiCfg.id, go, 0, false)
end
def.method().SetChooseNumAndNeedMoney = function(self)
  local Group_Num = self._uiGOs.groupRight:FindDirect("Group_Num")
  local Label_Num = Group_Num:FindDirect("Img_BgNum/Label_Num")
  if self._uiCfg.avaliableNum == -1 then
    GUIUtils.SetText(Label_Num, self._uiCfg.numToBuy)
  else
    GUIUtils.SetText(Label_Num, string.format("%d/%d", self._uiCfg.numToBuy, self._uiCfg.avaliableNum))
  end
  local totalMoney = self._uiCfg.funcCaculateTotalPrice(self._uiCfg.numToBuy)
  local Btn_Buy = self._uiGOs.groupRight:FindDirect("Btn_Buy")
  local Label_MoneyNum = Btn_Buy:FindDirect("Label_MoneyNum")
  local iconMoney = Btn_Buy:FindDirect("Img_BgNum")
  if self._uiCfg.moneyIcon ~= nil then
    GUIUtils.SetSprite(iconMoney, self._uiCfg.moneyIcon)
  end
  if totalMoney == 0 then
    GUIUtils.SetText(Label_MoneyNum, textRes.Mall.MesteryStore[6])
  else
    GUIUtils.SetText(Label_MoneyNum, totalMoney)
  end
end
return UIBuyConfirmPanel.Commit()
