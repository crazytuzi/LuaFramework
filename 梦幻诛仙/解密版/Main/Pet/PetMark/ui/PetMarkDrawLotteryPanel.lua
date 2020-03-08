local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkDrawLotteryPanel = Lplus.Extend(ECPanelBase, "PetMarkDrawLotteryPanel")
local GUIUtils = require("GUI.GUIUtils")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local LotteryType = require("consts.mzm.gsp.petmark.confbean.LotteryType")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local def = PetMarkDrawLotteryPanel.define
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", PetMarkDrawLotteryPanel).Instance = function()
  if instance == nil then
    instance = PetMarkDrawLotteryPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_MARK_LOTTERY_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.itemTipHelper = AwardItemTipHelper()
  self:InitUI()
  self:UpdateData()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, PetMarkDrawLotteryPanel.OnCreditChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkDrawLotteryPanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.itemTipHelper = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, PetMarkDrawLotteryPanel.OnCreditChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkDrawLotteryPanel.OnFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Type01 = self.m_panel:FindDirect("Img_Bg/Group_Type01")
  self.uiObjs.Group_Type02 = self.m_panel:FindDirect("Img_Bg/Group_Type02")
end
def.method().UpdateData = function(self)
  self:FillDrawLotteryInfo(self.uiObjs.Group_Type01, LotteryType.LOTTERY1, TokenType.PET_MARK_SCORE1, constant.CPetMarkConstants.LOTTERY_COST1, constant.CPetMarkConstants.TEN_LOTTERY_COST1)
  self:FillDrawLotteryInfo(self.uiObjs.Group_Type02, LotteryType.LOTTERY2, TokenType.PET_MARK_SCORE2, constant.CPetMarkConstants.LOTTERY_COST2, constant.CPetMarkConstants.TEN_LOTTERY_COST2)
end
def.method("userdata", "number", "number", "number", "number").FillDrawLotteryInfo = function(self, group, lotteryType, tokenType, cost1, cost10)
  local Group_Ji = group:FindDirect("Group_Ji")
  local Label_Name = Group_Ji:FindDirect("Label_Name")
  local Label_Num = Group_Ji:FindDirect("Label_Num")
  local tokenCfg = ItemUtils.GetTokenCfg(tokenType)
  local tokenNum = ItemModule.Instance():GetCredits(tokenType)
  GUIUtils.SetText(Label_Name, tokenCfg.name)
  GUIUtils.SetText(Label_Num, tokenNum:tostring())
  local Label_Cost1 = group:FindDirect("Group_Cost/Group_Cost01/Group_Cost_1/Label_Num")
  local Label_Cost10 = group:FindDirect("Group_Cost/Group_Cost02/Group_Cost_10/Label_Num")
  GUIUtils.SetText(Label_Cost1, cost1)
  GUIUtils.SetText(Label_Cost10, cost10)
  local lotteryCfg = PetMarkUtils.GetPetMarkLotteryCfg(lotteryType)
  local displayItems = lotteryCfg.items
  local Group_Item = group:FindDirect("Group_Item")
  local childrenCount = Group_Item.transform.childCount
  for i = 1, childrenCount do
    local uiItem = Group_Item.transform:GetChild(i - 1).gameObject
    if displayItems[i] then
      GUIUtils.SetActive(uiItem, true)
      local Img_Icon = uiItem:FindDirect("Img_Icon")
      local itemId = displayItems[i]
      local itemBase = ItemUtils.GetItemBase(itemId)
      GUIUtils.SetTexture(Img_Icon, itemBase.icon)
      uiItem.name = string.format("LotteryItem_%d_%d", lotteryType, i)
      self.itemTipHelper:RegisterItem2ShowTip(itemId, uiItem)
    else
      GUIUtils.SetActive(uiItem, false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_CommonOne" then
    self:OnClickBtnCommonOne()
  elseif id == "Btn_CommonTen" then
    self:OnClickBtnCommonTen()
  elseif id == "Btn_HighOne" then
    self:OnClickBtnHighOne()
  elseif id == "Btn_HighTen" then
    self:OnClickBtnHighTen()
  elseif id == "Btn_CommonAddJing" or id == "Btn_HighAddJing" then
    self:OnClickBtnDecompose()
  elseif id == "Btn_HelpCommon" then
    self:OnClickCommonTips()
  elseif id == "Btn_HelpHigh" then
    self:OnClickHighTips()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnClickBtnCommonOne = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE1)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.LOTTERY_COST1) then
    Toast(textRes.Pet.PetMark[26])
    return
  end
  PetMarkMgr.Instance():DrawLotteryCommonOne()
end
def.method().OnClickBtnCommonTen = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE1)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.TEN_LOTTERY_COST1) then
    Toast(textRes.Pet.PetMark[26])
    return
  end
  PetMarkMgr.Instance():DrawLotteryCommonTen()
end
def.method().OnClickBtnHighOne = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE2)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.LOTTERY_COST2) then
    Toast(textRes.Pet.PetMark[26])
    return
  end
  PetMarkMgr.Instance():DrawLotteryHighOne()
end
def.method().OnClickBtnHighTen = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE2)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.TEN_LOTTERY_COST2) then
    Toast(textRes.Pet.PetMark[26])
    return
  end
  PetMarkMgr.Instance():DrawLotteryHighTen()
end
def.method().OnClickCommonTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPetMarkConstants.LOTTERY1_TIPS_ID)
end
def.method().OnClickHighTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPetMarkConstants.LOTTERY2_TIPS_ID)
end
def.method().OnClickBtnDecompose = function(self)
  require("Main.Pet.PetMark.ui.PetMarkDecomposePanel").Instance():ShowPanel()
end
def.static("table", "table").OnCreditChange = function(params, context)
  local self = instance
  self:UpdateData()
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_MARK and not param.open then
    instance:DestroyPanel()
  end
end
PetMarkDrawLotteryPanel.Commit()
return PetMarkDrawLotteryPanel
