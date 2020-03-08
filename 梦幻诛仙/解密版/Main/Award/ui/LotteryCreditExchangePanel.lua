local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LotteryCreditExchangePanel = Lplus.Extend(ECPanelBase, "LotteryCreditExchangePanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LotteryAwardMgr = require("Main.Award.mgr.LotteryAwardMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = LotteryCreditExchangePanel.define
def.field("table").uiObjs = nil
def.field("table").m_items = nil
local instance
def.static("=>", LotteryCreditExchangePanel).Instance = function()
  if instance == nil then
    instance = LotteryCreditExchangePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_CREDIT_EXCHANGE_PANEL, 2)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.EXCHANGE_LOTTERY_SCORE_SUCCESS, LotteryCreditExchangePanel.OnExchangeSuccess)
end
def.method().UpdateUI = function(self)
  self:UpdateCreditScore()
  self:UpdateExchangeItems()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.EXCHANGE_LOTTERY_SCORE_SUCCESS, LotteryCreditExchangePanel.OnExchangeSuccess)
  self.uiObjs = nil
  self.m_items = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Texture_Icon" then
    self:OnTextureObjClicked(obj)
  elseif id == "Btn_Get" then
    self:OnBtnGetObjClicked(obj)
  elseif id == "Btn_Tip" then
    self:OnBtnTipClicked()
  end
end
def.method("userdata").OnTextureObjClicked = function(self, obj)
  local id = obj.parent.parent.name
  local index = tonumber(string.sub(id, #"item_" + 1, -1))
  if index == nil then
    return
  end
  local representItem = self.m_items[index].itemList[1]
  local itemId = representItem.itemId
  local anchorGO = obj.parent
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, anchorGO, 0, false)
end
def.method("userdata").OnBtnGetObjClicked = function(self, obj)
  local id = obj.parent.name
  local index = tonumber(string.sub(id, #"item_" + 1, -1))
  if index == nil then
    return
  end
  local scoreValue = self.m_items[index].scoreValue
  local cfgId = self.m_items[index].cfgId
  local val = LotteryAwardMgr.Instance():GetCreditScore()
  if scoreValue > val then
    Toast(textRes.Mibao[3])
    return
  end
  local representItem = self.m_items[index].itemList[1]
  local creditIcon = LotteryAwardMgr.Instance():GetCreditIconId()
  require("Main.Exchange.ui.ExchangeConfirmPanel").Instance():ShowPanelWithCurrenyIconId(representItem.itemId, 1, creditIcon, scoreValue, -1, function(num)
    local needScore = num * scoreValue
    if needScore > LotteryAwardMgr.Instance():GetCreditScore() then
      Toast(textRes.Mibao[3])
      return false
    end
    LotteryAwardMgr.Instance():ExchangeCreditScore(cfgId, num)
    return true
  end)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Credits_Num = self.uiObjs.Img_Bg0:FindDirect("Label_Credits/Label_Num")
  self.uiObjs.ScrollView = self.uiObjs.Img_Bg0:FindDirect("Scroll View_LeiDeng")
  self.uiObjs.List = self.uiObjs.ScrollView:FindDirect("List_LeiDeng")
end
def.method().UpdateCreditScore = function(self)
  local val = LotteryAwardMgr.Instance():GetCreditScore()
  GUIUtils.SetText(self.uiObjs.Label_Credits_Num, val)
end
def.method().UpdateExchangeItems = function(self)
  local items = LotteryAwardMgr.Instance():GetAllLotteryExchangeItems()
  self.m_items = items
  local count = #items
  local uiList = self.uiObjs.List:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i = 1, count do
    local itemObj = itemObjs[i]
    local itemInfo = items[i]
    self:SetItemInfo(itemObj, itemInfo)
  end
  self.m_msgHandler:Touch(self.uiObjs.List)
end
def.method("userdata", "table").SetItemInfo = function(self, itemObj, itemInfo)
  local representItem = itemInfo.itemList[1]
  local itemId = representItem.itemId
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemName = ""
  local namecolor = 0
  local iconId = 0
  local itemNum = itemInfo and itemInfo.num or ""
  if itemBase then
    itemName = itemBase.name
    namecolor = itemBase.namecolor
    iconId = itemBase.icon
  end
  local Img_BgIcon = itemObj:FindDirect("Img_BgIcon1")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local Label_Num = Img_BgIcon:FindDirect("Label_Num")
  local Label = itemObj:FindDirect("Label")
  local Label_CreditNum = itemObj:FindDirect("Label_Num")
  GUIUtils.SetTexture(Texture_Icon, iconId)
  GUIUtils.SetText(Label_Num, itemNum)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local color = HtmlHelper.NameColor[namecolor]
  if color then
    itemName = string.format("[%s]%s[-]", color, itemName)
  end
  GUIUtils.SetText(Label, itemName)
  local creditText = itemInfo.scoreValue
  GUIUtils.SetText(Label_CreditNum, creditText)
end
def.method().OnBtnTipClicked = function(self)
  local tipId = _G.constant.BaoKuConsts.describeTipsId2 or 0
  GUIUtils.ShowHoverTip(tipId, 0, 0)
end
def.static("table", "table").OnExchangeSuccess = function()
  instance:UpdateCreditScore()
end
return LotteryCreditExchangePanel.Commit()
