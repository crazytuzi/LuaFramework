local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local FurnitureShopPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local FurnitureShop = require("Main.Homeland.FurnitureShop")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = FurnitureShopPanel.define
local dlg
def.field("table")._itemList = nil
def.field("table")._curSelectItem = nil
def.field("number").digitalEntered = 0
def.field("number")._maxBuyNum = 0
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.field("number").lastNeedIndex = 0
def.field("number").targetItemId = 0
def.field("table").moneyDatas = nil
def.field("table").m_UIGOs = nil
def.static("=>", FurnitureShopPanel).Instance = function()
  if nil == dlg then
    dlg = FurnitureShopPanel()
    dlg.m_TrigGC = true
  end
  return dlg
end
def.static().ShowPanel = function()
  local dlg = FurnitureShopPanel.Instance()
  if dlg.m_panel and dlg.m_panel.isnil == false then
    dlg:DestroyPanel()
  end
  FurnitureShop.Instance():GetSellList()
  dlg:CreatePanel(RESPATH.PREFAB_FURNITURE_SHOP_PANEL, 1)
end
def.static("number").ShowPanelWithItemId = function(itemId)
  local dlg = FurnitureShopPanel.Instance()
  dlg.targetItemId = itemId
  FurnitureShopPanel.ShowPanel()
end
def.override().OnCreate = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    self:DestroyPanel()
    return
  end
  self:SetModal(true)
  self._itemList = FurnitureShop.Instance():GetSellList() or {}
  self:InitUI()
  self._curSelectItem = {}
  self:FillShopItems()
  self:SelectTargetItem()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Shop_Info, FurnitureShopPanel.OnSyncShopInfo)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, FurnitureShopPanel.OnNewDay)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, FurnitureShopPanel.OnLeaveHouseSence)
end
def.override().OnDestroy = function(self)
  if self.moneyDatas then
    for k, v in pairs(self.moneyDatas) do
      v:UnregisterCurrencyChangedEvent(FurnitureShopPanel.OnMoneyChanged)
    end
  end
  self.moneyDatas = nil
  self._curSelectItem = nil
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Shop_Info, FurnitureShopPanel.OnSyncShopInfo)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, FurnitureShopPanel.OnNewDay)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, FurnitureShopPanel.OnLeaveHouseSence)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Img_Bg1 = self.m_UIGOs.Img_Bg0:FindDirect("Img_Bg1")
  self.m_UIGOs.Label_Times = self.m_UIGOs.Img_Bg1:FindDirect("Label_Times")
  self.m_UIGOs.Label_RefreshTime = self.m_UIGOs.Img_Bg1:FindDirect("Label_RefreshTime")
  self.m_UIGOs.Label_TimesDesc = self.m_UIGOs.Img_Bg1:FindDirect("Label")
  self.m_UIGOs.Btn_Refresh = self.m_UIGOs.Img_Bg1:FindDirect("Btn_Refresh")
  self.m_UIGOs.Grid_Items = self.m_UIGOs.Img_Bg1:FindDirect("Img_BgItems/Scroll View_Items/Grid_Items")
  GUIUtils.SetText(self.m_UIGOs.Label_RefreshTime, textRes.Homeland[34])
  self:UpdateRefreshTimes()
  if #self._itemList == 0 then
    self.m_UIGOs.Img_Bg1:SetActive(false)
  end
end
def.method().FillShopItems = function(self)
  self._maxBuyNum = 99
  local count = #self._itemList
  if count > 0 then
    self.m_UIGOs.Img_Bg1:SetActive(true)
  end
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local gridGO = bg:FindDirect("Img_Bg1/Img_BgItems/Scroll View_Items/Grid_Items")
  self:SetGridItemCount(gridGO, count)
  self:FillShopList(gridGO, self._itemList)
end
def.method("userdata", "table").FillShopList = function(self, gridGO, itemList)
  local index = 1
  for i = index, #itemList do
    local itemObj = gridGO:GetChild(i)
    local itemInfo = itemList[i]
    self:FillItemInfo(i, itemObj, itemInfo)
  end
end
def.method("userdata", "number").SetGridItemCount = function(self, gridGO, itemCount)
  local childCount = gridGO:get_childCount()
  local template = gridGO:GetChild(0)
  if template == nil then
    warn(string.format("%s don't have a template", gridGO.name))
    return
  end
  template:SetActive(false)
  local visibleChildCount = childCount - 1
  if itemCount > visibleChildCount then
    for i = visibleChildCount + 1, itemCount do
      local childGO = GameObject.Instantiate(template)
      childGO.parent = gridGO
      childGO.localPosition = Vector.Vector3.zero
      childGO.localScale = Vector.Vector3.one
    end
  elseif itemCount < visibleChildCount then
    for i = visibleChildCount, itemCount + 1, -1 do
      local childGO = gridGO:GetChild(i)
      GameObject.DestroyImmediate(childGO)
    end
  end
  local from = 1
  local to = itemCount
  for i = from, to do
    local childGO = gridGO:GetChild(i - from + 1)
    childGO:SetActive(true)
    childGO.name = template.name .. "_" .. i
  end
  gridGO:GetComponent("UIGrid"):Reposition()
  self.m_msgHandler:Touch(gridGO)
end
def.method("number", "userdata", "table").FillItemInfo = function(self, index, itemObj, itemInfo)
  local itemId = itemInfo.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  local Label_Name = itemObj:FindDirect("Label_Name")
  local Label_Price = itemObj:FindDirect("Img_BgPrice/Label_Price")
  local Img_MoneyIcon = itemObj:FindDirect("Img_BgPrice/Img_MoneyIcon")
  local Img_BgIcon = itemObj:FindDirect("Img_BgIcon")
  local Img_Icon = Img_BgIcon:FindDirect("Img_Icon")
  local Img_Selled = itemObj:FindDirect("Img_Sell")
  itemObj:GetComponent("UIToggle"):set_isChecked(false)
  GUIUtils.SetText(Label_Name, itemBase.name)
  GUIUtils.SetTexture(Img_Icon, itemBase.icon)
  GUIUtils.SetText(Label_Price, itemInfo.moneyNum)
  GUIUtils.SetItemCellSprite(Img_BgIcon, itemBase.namecolor)
  local moneyData = self:GetMoneyData(itemInfo.moneyType)
  local spriteName = moneyData:GetSpriteName()
  GUIUtils.SetSprite(Img_MoneyIcon, spriteName)
  local isSelled = itemInfo.num == 0
  GUIUtils.SetActive(Img_Selled, isSelled)
  local uiTexture = Img_Icon:GetComponent("UITexture")
  local effect = isSelled and GUIUtils.Effect.Gray or GUIUtils.Effect.Normal
  GUIUtils.SetTextureEffect(uiTexture, effect)
end
def.method("number", "number").SetItemSelectConst = function(self, index, requireNum)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local itemInfo = self._itemList[index]
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  local costs = 0
  local sellMoney = itemInfo.moneyNum
  self.digitalEntered = requireNum
  local moneyData = self:GetMoneyData(itemInfo.moneyType)
  group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):set_text(self.digitalEntered)
  costs = sellMoney * self.digitalEntered
  group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_text(costs)
  local Img_MoneyIcon = group:FindDirect("Label_Cost/Img_BgCost/Img_MoneyIcon")
  GUIUtils.SetSprite(Img_MoneyIcon, moneyData:GetSpriteName())
  if self:GetAndUpdateMoneyNum():lt(costs) then
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.white)
  end
end
def.method("=>", "userdata").GetAndUpdateMoneyNum = function(self)
  if self._curSelectItem == nil then
    return Int64.new(0)
  end
  local moneyData = self:GetMoneyData(self._curSelectItem.itemInfo.moneyType)
  local haveMoney = moneyData:GetHaveNum()
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local Label_HaveNum = group:FindDirect("Label_Have/Img_BgHave/Label_HaveNum")
  GUIUtils.SetText(Label_HaveNum, tostring(haveMoney))
  local Img_MoneyIcon = group:FindDirect("Label_Have/Img_BgHave/Img_MoneyIcon")
  GUIUtils.SetSprite(Img_MoneyIcon, moneyData:GetSpriteName())
  return haveMoney
end
def.method().UpdateHaveAndNeedMoney = function(self)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local costNum = group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):get_text()
  costNum = tonumber(costNum)
  if self:GetAndUpdateMoneyNum():lt(costNum) then
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.white)
  end
end
def.method().UpdateRefreshTimes = function(self)
  local function showRefreshUI(isShow)
    GUIUtils.SetActive(self.m_UIGOs.Label_Times, isShow)
    GUIUtils.SetActive(self.m_UIGOs.Label_TimesDesc, isShow)
    GUIUtils.SetActive(self.m_UIGOs.Btn_Refresh, isShow)
  end
  local timesPerDay = FurnitureShop.Instance():GetRefreshTimesPerDay()
  if timesPerDay == 0 then
    showRefreshUI(false)
    return
  end
  showRefreshUI(true)
  local remainTimes = FurnitureShop.Instance():GetRefreshRemainTimes()
  local text = string.format(textRes.Homeland[33], remainTimes)
  GUIUtils.SetText(self.m_UIGOs.Label_Times, text)
end
def.method("number").FillItemSelectDetail = function(self, index)
  local itemInfo = self._itemList[index]
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local detail = bg:FindDirect("Img_BgDetail")
  local Label_DetailName = detail:FindDirect("Label_DetailName")
  local Label_Detail = detail:FindDirect("Label_Detail")
  local Img_BgIcon = detail:FindDirect("Img_BgIcon")
  local Img_Icon = Img_BgIcon:FindDirect("Img_Icon")
  local nameAndType = string.format([[
%s
%s]], itemBase.name, itemBase.itemTypeName)
  local item = {
    id = itemBase.itemid,
    extraMap = {}
  }
  local desc = ItemTipsMgr.Instance():GetDescription(item, itemBase)
  desc = string.gsub(desc, "<font color=#([0-9a-fA-F]+)>(.-)</font>", "%[%1%]%2%[-%]")
  desc = string.gsub(desc, "<br/>", "\n")
  desc = string.gsub(desc, "<.*>%[(.-)</.*>", "[%1")
  GUIUtils.SetText(Label_DetailName, nameAndType)
  GUIUtils.SetText(Label_Detail, desc)
  GUIUtils.SetTexture(Img_Icon, itemBase.icon)
  GUIUtils.SetItemCellSprite(Img_BgIcon, itemBase.namecolor)
  local gridTemplate = bg:FindDirect("Img_BgItems/Scroll View_Items/Grid_Items")
  local itemSale = gridTemplate:GetChild(index)
  itemSale:GetComponent("UIToggle"):set_isChecked(true)
end
def.method().SelectTargetItem = function(self)
  local index = 1
  if self.targetItemId ~= 0 then
    for i, v in ipairs(self._itemList) do
      if v.id == self.targetItemId then
        index = i
      end
    end
  end
  local itemObj = self.m_UIGOs.Grid_Items:FindDirect("Img_BgItem01_" .. index)
  if itemObj then
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel == nil then
        return
      end
      local uiScrollView = self.m_UIGOs.Grid_Items.parent:GetComponent("UIScrollView")
      uiScrollView:DragToMakeVisible(itemObj.transform, 40)
    end)
  end
  self:OnItemSelect(index)
end
def.method("number").OnItemSelect = function(self, index)
  local itemInfo = self._itemList[index]
  if itemInfo == nil then
    return
  end
  self._curSelectItem = {
    index = index,
    requireId = itemInfo.id,
    itemInfo = itemInfo
  }
  self._maxBuyNum = math.max(itemInfo.num, 1)
  self:FillItemSelectDetail(index)
  local needCount = 1
  self:SetItemSelectConst(index, needCount)
  self.targetItemId = itemInfo.id
end
def.method().OnBuyClick = function(self)
  if self._curSelectItem.itemInfo == nil then
    return
  end
  local itemInfo = self._curSelectItem.itemInfo
  if itemInfo.num == 0 then
    Toast(textRes.Homeland[87])
    return
  end
  local itemId = self._curSelectItem.requireId
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local itemCount = group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):get_text()
  itemCount = tonumber(itemCount)
  local clientGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local clientSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local needMoney = itemInfo.moneyNum * itemCount
  local moneyData = self:GetMoneyData(itemInfo.moneyType)
  local haveMoney = moneyData:GetHaveNum()
  if haveMoney:lt(needMoney) then
    moneyData:AcquireWithQuery()
    return
  end
  FurnitureShop.Instance():BuyFurnitureReq(itemId, itemCount)
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.digitalEntered = value
  self:UpdateEnteredValue()
  self:SetEnteredValue()
end
def.method().UpdateEnteredValue = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if self.digitalEntered > self._maxBuyNum then
    Toast(string.format(textRes.NPCStore[22], self._maxBuyNum))
    self.digitalEntered = self._maxBuyNum
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
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):set_text(self.digitalEntered)
  self:SetItemSelectConst(self._curSelectItem.index, self.digitalEntered)
end
def.method("number", "=>", "table").GetMoneyData = function(self, moneyType)
  if self.moneyDatas == nil then
    self.moneyDatas = {}
  end
  if self.moneyDatas[moneyType] == nil then
    local currency = CurrencyFactory.Create(moneyType)
    currency:RegisterCurrencyChangedEvent(FurnitureShopPanel.OnMoneyChanged)
    self.moneyDatas[moneyType] = currency
  end
  return self.moneyDatas[moneyType]
end
def.method().OnSetNumBtnClick = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, FurnitureShopPanel.OnDigitalKeyboardCallback, {self = self})
  CommonDigitalKeyboard.Instance():SetPos(-26, -1)
end
def.method().OnMinusNumClick = function(self)
  if self.digitalEntered - 1 < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
  else
    self.digitalEntered = self.digitalEntered - 1
  end
  self:SetEnteredValue()
end
def.method().OnAddNumClick = function(self)
  if self.digitalEntered + 1 > self._maxBuyNum then
    Toast(string.format(textRes.NPCStore[22], self._maxBuyNum))
    self.digitalEntered = self._maxBuyNum
  else
    self.digitalEntered = self.digitalEntered + 1
  end
  self:SetEnteredValue()
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
def.method("string", "boolean").onPress = function(self, id, state)
  self:ItemNumOnPress(id, state)
end
def.method().OnRefreshBtnClick = function(self)
  local remainTimes = FurnitureShop.Instance():GetRefreshRemainTimes()
  if remainTimes == 0 then
    Toast(textRes.Homeland[35])
    return
  end
  local refreshNeeds = FurnitureShop.Instance():GetRefreshNeeds()
  local moneyData = self:GetMoneyData(refreshNeeds.moneyType)
  local title = ""
  local desc = string.format(textRes.Homeland[38], refreshNeeds.moneyNum, moneyData:GetName())
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      local haveNum = moneyData:GetHaveNum()
      if haveNum:lt(refreshNeeds.moneyNum) then
        moneyData:AcquireWithQuery()
        return
      end
      FurnitureShop.Instance():RefreshSellList()
    end
  end, nil)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if nil ~= string.find(id, "Img_BgItem01_") then
    local indexStr = string.sub(id, string.len("Img_BgItem01_") + 1)
    local index = tonumber(indexStr)
    if index then
      self:OnItemSelect(index)
    end
  elseif "Btn_Buy" == id then
    self:OnBuyClick()
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Label_Num" == id then
    self:OnSetNumBtnClick()
  elseif "Btn_Minus" == id then
    self:OnMinusNumClick()
  elseif "Btn_Add" == id then
    self:OnAddNumClick()
  elseif "Modal" == id then
    self:Hide()
  elseif id == "Btn_Refresh" then
    self:OnRefreshBtnClick()
  elseif id == "Btn_AddSiliver" or id == "Sprite" then
    self:OnAddCurrencyBtnClick()
  end
end
def.method().OnAddCurrencyBtnClick = function(self)
  if self._curSelectItem == nil then
    return
  end
  if self._curSelectItem.itemInfo == nil then
    return
  end
  local moneyData = self:GetMoneyData(self._curSelectItem.itemInfo.moneyType)
  moneyData:Acquire()
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").OnMoneyChanged = function()
  if dlg.m_panel == nil then
    return
  end
  dlg:UpdateHaveAndNeedMoney()
end
def.static("table", "table").OnSyncShopInfo = function()
  if dlg.m_panel == nil then
    return
  end
  dlg._itemList = FurnitureShop.Instance():GetSellList() or {}
  dlg:FillShopItems()
  dlg:SelectTargetItem()
  dlg:UpdateRefreshTimes()
end
def.static("table", "table").OnNewDay = function()
  if dlg.m_panel == nil then
    return
  end
  FurnitureShop.Instance():ReqSellList()
end
def.static("table", "table").OnLeaveHouseSence = function()
  dlg:DestroyPanel()
end
FurnitureShopPanel.Commit()
return FurnitureShopPanel
