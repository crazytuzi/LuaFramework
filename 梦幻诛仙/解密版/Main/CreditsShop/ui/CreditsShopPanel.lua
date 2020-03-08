local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CreditsShopPanel = Lplus.Extend(ECPanelBase, "CreditsShopPanel")
local def = CreditsShopPanel.define
local CreditsShopData = require("Main.CreditsShop.data.CreditsShopData")
local CreditsShopUtility = require("Main.CreditsShop.CreditsShopUtility")
local GUIUtils = require("GUI.GUIUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local instance
def.field(CreditsShopData).data = nil
def.field("table").uiTbl = nil
def.field("number").selectCreditType = 0
def.field("number").lastItemListNum = 0
def.field("number").selectItemId = 0
def.field("number").digitalEntered = 1
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.static("=>", CreditsShopPanel).Instance = function()
  if instance == nil then
    instance = CreditsShopPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.data = CreditsShopData.Instance()
end
def.method("number").ShowPanel = function(self, selectType)
  if self:IsShow() then
    return
  end
  self.data:InitCreditType()
  self.data:InitCreditItems()
  self.selectCreditType = selectType
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CREDITS_SHOP_PANEL, 1)
end
def.override().OnCreate = function(self)
  self.uiTbl = CreditsShopUtility.FillCreditsShopUI(self.uiTbl, self.m_panel)
  self:FillCreditItemsList(true)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, CreditsShopPanel.OnCreditChange)
  Event.RegisterEvent(ModuleId.CREDITSSHOP, gmodule.notifyId.CreditsShop.SucceedBuyItem, CreditsShopPanel.SucceedBuyItem)
end
def.override().OnDestroy = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, CreditsShopPanel.OnCreditChange)
  Event.UnregisterEvent(ModuleId.CREDITSSHOP, gmodule.notifyId.CreditsShop.SucceedBuyItem, CreditsShopPanel.SucceedBuyItem)
end
def.method().Clear = function(self)
  self.selectCreditType = 0
  self.lastItemListNum = 0
  self.selectItemId = 0
  self.digitalEntered = 1
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").SucceedBuyItem = function(params, tbl)
  local self = instance
  self.digitalEntered = 1
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
  if self.selectCreditType == params[1] then
    self:FillSelectItemInfo()
  end
end
def.static("table", "table").OnCreditChange = function(params, tbl)
  local self = instance
  self:FillSelectItemPrice()
end
def.method("boolean").FillCreditItemsList = function(self, bFillBtn)
  self.selectItemId = 0
  self.digitalEntered = 1
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
  local btnList = self.data:GetCreditType()
  local creditItemList = self.data:GetCreditItems(self.selectCreditType)
  if bFillBtn then
    self:FillCreditButtons(btnList)
  end
  self:FillCreditItemList(creditItemList)
  self:FillSelectItemInfo()
end
def.method("table").FillCreditButtons = function(self, btnList)
  local uiList = self.uiTbl.List_Class:GetComponent("UIList")
  uiList:set_itemCount(#btnList)
  uiList:Resize()
  local index = 0
  local buttons = uiList:get_children()
  for i = 1, #btnList do
    local btnUI = buttons[i]
    local btnInfo = btnList[i]
    self:FillBtnInfo(btnUI, i, btnInfo)
    if self.selectCreditType == btnInfo.type then
      index = i
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  GameUtil.AddGlobalLateTimer(0.1, true, function()
    if not uiList.isnil and index > 0 then
      uiList:DragToMakeVisible(index - 1, 32)
    end
  end)
end
def.method("userdata", "number", "table").FillBtnInfo = function(self, btnUI, index, btnInfo)
  local btnName = btnUI:FindDirect(string.format("Label_%d", index)):GetComponent("UILabel")
  local btnType = btnUI:FindDirect(string.format("Label_Type_%d", index))
  btnName:set_text(btnInfo.name)
  btnType:SetActive(false)
  btnType:GetComponent("UILabel"):set_text(btnInfo.type)
  if self.selectCreditType == btnInfo.type then
    btnUI:GetComponent("UIToggle"):set_value(true)
  else
    btnUI:GetComponent("UIToggle"):set_value(false)
  end
end
def.method("table").FillCreditItemList = function(self, creditItemList)
  self:ClearItemObjects()
  GameUtil.AddGlobalTimer(0.01, true, function()
    self:CreateItemObjects(#creditItemList)
    self:FillCreditItems(creditItemList)
  end)
end
def.method().ClearItemObjects = function(self)
  local gridTemplate = self.uiTbl.Grid_Items
  for i = 1, self.lastItemListNum do
    CreditsShopUtility.DeleteLastGroup(self.lastItemListNum, "Img_BgItem%d", gridTemplate)
    self.lastItemListNum = self.lastItemListNum - 1
  end
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_panel and false == self.m_panel.isnil then
      self.uiTbl["Scroll View_Items"]:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("number").CreateItemObjects = function(self, curItemListNum)
  local gridTemplate = self.uiTbl.Grid_Items
  local itemTemplate = self.uiTbl.Img_BgItem
  itemTemplate:SetActive(false)
  for j = 1, curItemListNum do
    self.lastItemListNum = self.lastItemListNum + 1
    CreditsShopUtility.AddLastGroup(self.lastItemListNum, "Img_BgItem%d", gridTemplate, itemTemplate)
  end
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_panel and false == self.m_panel.isnil then
      self.uiTbl["Scroll View_Items"]:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("table").FillCreditItems = function(self, creditItemList)
  local gridTemplate = self.uiTbl.Grid_Items
  local index = 1
  for k, v in pairs(creditItemList) do
    local itemUI = gridTemplate:FindDirect(string.format("Img_BgItem%d", index))
    self:FillItemInfo(itemUI, index, v)
    index = index + 1
  end
end
def.method("userdata", "number", "table").FillItemInfo = function(self, itemUI, index, itemInfo)
  local Label_Name = itemUI:FindDirect("Label_Name"):GetComponent("UILabel")
  local Label_ItemId = itemUI:FindDirect("Label_ItemId")
  local Label_Price = itemUI:FindDirect("Img_BgPrice/Label_Price"):GetComponent("UILabel")
  local Img_MoneyIcon = itemUI:FindDirect("Img_BgPrice/Img_MoneyIcon"):GetComponent("UISprite")
  local Img_Icon = itemUI:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
  Label_ItemId:SetActive(false)
  Label_ItemId:GetComponent("UILabel"):set_text(itemInfo.itemId)
  Label_Name:set_text(itemBase.name)
  Label_Price:set_text(itemInfo.price)
  GUIUtils.FillIcon(Img_Icon, itemBase.icon)
  itemUI:GetComponent("UIToggle"):set_value(false)
  local iconId = self.data:GetTypeIconId(self.selectCreditType)
  CreditsShopUtility.FillIcon(iconId, Img_MoneyIcon)
end
def.method().FillSelectItemInfo = function(self)
  if self.selectItemId == 0 then
    self.uiTbl.Group_NoChoice:SetActive(true)
    if textRes.Mall.CreditsTypStr[self.selectCreditType] then
      self.uiTbl.Group_NoChoice:FindDirect("Label"):GetComponent("UILabel"):set_text(textRes.Mall.CreditsTypStr[0])
    end
    self.uiTbl.Group_ItemInfo:SetActive(false)
    self:FillSelectItemPrice()
  else
    self.uiTbl.Group_NoChoice:SetActive(false)
    self.uiTbl.Group_ItemInfo:SetActive(true)
    self:FillSelectItemBasic()
    self:FillSelectItemPrice()
  end
end
def.method().FillSelectItemBasic = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local Label_DetailName = self.uiTbl.Group_Detail:FindDirect("Img_Title/Label_DetailName"):GetComponent("UILabel")
  local Label_ItemLevel = self.uiTbl.Group_Detail:FindDirect("Label_ItemLevel"):GetComponent("UILabel")
  local Label_ItemType = self.uiTbl.Group_Detail:FindDirect("Label_ItemType"):GetComponent("UILabel")
  local Icon_Item = self.uiTbl.Group_Detail:FindDirect("Icon_Frame/Icon_Item"):GetComponent("UITexture")
  local Label_DetailContent = self.uiTbl.Group_Detail:FindDirect("Label_DetailContent"):GetComponent("UILabel")
  Label_DetailName:set_text(itemBase.name)
  Label_ItemLevel:set_text(itemBase.itemTypeName)
  Label_ItemType:set_text(itemBase.itemTypeName)
  GUIUtils.FillIcon(Icon_Item, itemBase.icon)
  local desc = require("Main.Item.ItemTipsMgr").Instance():GetSimpleDescription(itemBase)
  desc = require("Main.Chat.HtmlHelper").RemoveHtmlTag(desc)
  desc = string.trim(desc)
  Label_DetailContent:set_text(desc)
end
def.method().FillSelectItemPrice = function(self)
  local group = self.uiTbl.Group_Buy
  if self.selectItemId == 0 then
    group = self.uiTbl.Group_NoChoice:FindDirect("Group_Buy")
  end
  local Label_Num = group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel")
  local Label_CostNum = group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel")
  Label_Num:set_text(self.digitalEntered)
  local price = self.data:GetItemPrice(self.selectCreditType, self.selectItemId)
  local cost = price * self.digitalEntered
  Label_CostNum:set_text(cost)
  local iconId = self.data:GetTypeIconId(self.selectCreditType)
  local Img_MoneyIcon1 = group:FindDirect("Label_Cost/Img_BgCost/Img_MoneyIcon"):GetComponent("UISprite")
  local Img_MoneyIcon2 = group:FindDirect("Label_Have/Img_BgHave/Img_MoneyIcon"):GetComponent("UISprite")
  CreditsShopUtility.FillIcon(iconId, Img_MoneyIcon1)
  CreditsShopUtility.FillIcon(iconId, Img_MoneyIcon2)
  local credits = ItemModule.Instance():GetCredits(self.selectCreditType)
  if credits == nil then
    credits = Int64.new(0)
  end
  local Label_HaveNum = group:FindDirect("Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel")
  Label_HaveNum:set_text(Int64.tostring(credits))
  if credits:lt(cost) then
    Label_CostNum:set_textColor(Color.red)
  else
    Label_CostNum:set_textColor(Color.white)
  end
end
def.method("number").OnItemSelect = function(self, itemId)
  self.selectItemId = itemId
  self.digitalEntered = 1
  self:FillSelectItemInfo()
end
def.method().OnSetNumBtnClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, CreditsShopPanel.OnDigitalKeyboardCallback, {self = self})
  CommonDigitalKeyboard.Instance():SetPos(-26, -1)
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  self.digitalEntered = value
  self:UpdateEnteredValue()
  self:SetEnteredValue()
end
def.method().UpdateEnteredValue = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local max = itemBase.pilemax
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if max < self.digitalEntered then
    Toast(string.format(textRes.NPCStore[22], max))
    self.digitalEntered = max
    CommonDigitalKeyboard.Instance():SetEnteredValue(self.digitalEntered)
  elseif self.digitalEntered < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
    CommonDigitalKeyboard.Instance():SetEnteredValue(0)
  else
    CommonDigitalKeyboard.Instance():SetEnteredValue(self.digitalEntered)
  end
end
def.method().SetEnteredValue = function(self)
  local Label_Num = self.uiTbl.Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(self.digitalEntered)
  self:FillSelectItemPrice()
end
def.method().OnMinusNumClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  if self.digitalEntered - 1 < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
  else
    self.digitalEntered = self.digitalEntered - 1
  end
  self:SetEnteredValue()
end
def.method().OnAddNumClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local max = itemBase.pilemax
  if max < self.digitalEntered + 1 then
    Toast(string.format(textRes.NPCStore[22], max))
    self.digitalEntered = max
  else
    self.digitalEntered = self.digitalEntered + 1
  end
  self:SetEnteredValue()
end
def.method("string", "boolean").onPress = function(self, id, state)
end
def.method("string", "boolean").ItemNumOnPress = function(self, id, state)
  if id == "Btn_Add" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnIncPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnIncPropTimer)
      self.pressedTime = 0
    end
  elseif id == "Btn_Minus" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnDecPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnDecPropTimer)
      self.pressedTime = 0
    end
  end
end
def.method("number").OnIncPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.incPropTime = self.incPropTime + dt
  if interval <= self.incPropTime then
    self:OnAddNumClick()
    self.incPropTime = self.incPropTime - interval
  end
end
def.method("number").OnDecPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.decPropTime = self.decPropTime + dt
  if interval <= self.decPropTime then
    self:OnMinusNumClick()
    self.decPropTime = self.decPropTime - interval
  end
end
def.method().OnBuyClick = function(self)
  if self.selectCreditType == TokenType.LADDER_SCORE and not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LADDER) then
    return
  end
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local price = self.data:GetItemPrice(self.selectCreditType, self.selectItemId)
  local cost = price * self.digitalEntered
  local credits = ItemModule.Instance():GetCredits(self.selectCreditType)
  if credits == nil then
    credits = Int64.new(0)
  end
  if credits:lt(cost) then
    local creditName = CreditsShopData.Instance():GetCreditTypeName(self.selectCreditType)
    Toast(string.format(textRes.Mall[4], creditName))
    return
  end
  local p = require("netio.protocol.mzm.gsp.mall.CExchangeItemUseJifen").new(self.selectCreditType, self.selectItemId, self.digitalEntered)
  gmodule.network.sendProtocol(p)
end
def.method("number").OnTypeSelect = function(self, type)
  if type == TokenType.LADDER_SCORE and not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LADDER) then
    return
  end
  self.selectCreditType = type
  self:FillCreditItemsList(false)
end
def.method().OnTipsBtnClicked = function(self)
  local tipId = 701609610
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  elseif nil ~= string.find(id, "Img_BgItem") then
    local itemId = clickobj:FindDirect("Label_ItemId"):GetComponent("UILabel"):get_text()
    self:OnItemSelect(tonumber(itemId))
  elseif "Btn_Buy" == id then
    self:OnBuyClick()
  elseif "Label_Num" == id then
    self:OnSetNumBtnClick()
  elseif "Btn_Minus" == id then
    self:OnMinusNumClick()
  elseif "Btn_Add" == id then
    self:OnAddNumClick()
  elseif string.sub(id, 1, #"Btn_CreditsClass_") == "Btn_CreditsClass_" then
    local index = tonumber(string.sub(id, #"Btn_CreditsClass_" + 1, -1))
    local type = clickobj:FindDirect(string.format("Label_Type_%d", index)):GetComponent("UILabel"):get_text()
    self:OnTypeSelect(tonumber(type))
  elseif id == "Btn_Tips" then
    self:OnTipsBtnClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  end
end
return CreditsShopPanel.Commit()
