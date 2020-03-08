local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MonkeyRunShopPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
local def = MonkeyRunShopPanel.define
def.const("number").MAX_BUY_NUM = 999
def.field("table").uiObjs = nil
def.field("number").shopIndex = 0
def.field("number").shopItemIndex = 0
def.field("number").buyItemCount = 1
local instance
def.static("=>", MonkeyRunShopPanel).Instance = function()
  if instance == nil then
    instance = MonkeyRunShopPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MONKEYRUN_SHOP_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:InitShopType()
  self:ChooseShopIndex(1)
  self:ShowActivityTime()
  self:UpdateShopItemDetail()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Shop_Change, MonkeyRunShopPanel.OnShopDataChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunShopPanel.OnOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.shopIndex = 0
  self.shopItemIndex = 0
  self.buyItemCount = 1
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Shop_Change, MonkeyRunShopPanel.OnShopDataChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunShopPanel.OnOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg1 = self.m_panel:FindDirect("Img_Bg1")
  self.uiObjs.Group_Type = self.uiObjs.Img_Bg1:FindDirect("Group_Type")
  self.uiObjs.Img_BgItems = self.uiObjs.Img_Bg1:FindDirect("Img_BgItems")
  self.uiObjs.Group_Date = self.uiObjs.Img_Bg1:FindDirect("Group_Date")
  self.uiObjs.Img_BgDetail = self.uiObjs.Img_Bg1:FindDirect("Img_BgDetail")
end
def.method().InitShopType = function(self)
  local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
  local Scrollview = self.uiObjs.Group_Type:FindDirect("Scrollview")
  local List_Class = Scrollview:FindDirect("List_Class")
  local uiList = List_Class:GetComponent("UIList")
  uiList.itemCount = #shopCfg
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #shopCfg do
    local uiItem = uiItems[i]
    local Label = uiItem:FindDirect("Label_" .. i)
    GUIUtils.SetText(Label, textRes.activity.MonkeyRunShopType[shopCfg[i].shopType] or textRes.activity.MonkeyRunShopType[-1])
  end
end
def.method("number").ChooseShopIndex = function(self, index)
  if self.shopIndex == index then
    return
  end
  self.shopIndex = index
  self.shopItemIndex = 0
  self.buyItemCount = 1
  self:UpdateShopTypeStatus()
  self:ClearShopItems()
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.uiObjs == nil then
      return
    end
    self:UpdateShopItems()
    self:AjustShopItems()
    self:UpdateShopItemDetail()
  end)
end
def.method().UpdateShopTypeStatus = function(self)
  local Scrollview = self.uiObjs.Group_Type:FindDirect("Scrollview")
  local List_Class = Scrollview:FindDirect("List_Class")
  local uiList = List_Class:GetComponent("UIList")
  local uiItems = uiList.children
  if uiItems[self.shopIndex] ~= nil then
    uiItems[self.shopIndex]:GetComponent("UIToggle").value = true
  end
end
def.method().ClearShopItems = function(self)
  local Scroll_View_Items = self.uiObjs.Img_BgItems:FindDirect("Scroll View_Items")
  local Grid_Items = Scroll_View_Items:FindDirect("Grid_Items")
  local Grid_Template = Grid_Items:FindDirect("Img_BgItem")
  GUIUtils.SetActive(Grid_Template, false)
  local unuseIdx = 1
  local itemObjParent = Grid_Items
  while true do
    local itemObj = itemObjParent:FindDirect("ShopItem_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  Grid_Items:GetComponent("UIGrid"):Reposition()
end
def.method().UpdateShopItems = function(self)
  local Scroll_View_Items = self.uiObjs.Img_BgItems:FindDirect("Scroll View_Items")
  local Grid_Items = Scroll_View_Items:FindDirect("Grid_Items")
  local Grid_Template = Grid_Items:FindDirect("Img_BgItem")
  GUIUtils.SetActive(Grid_Template, false)
  local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
  if shopCfg[self.shopIndex] == nil then
    warn("no shop cfg at index " .. self.shopIndex)
    return
  end
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData == nil then
    return
  end
  local itemCount = #shopCfg[self.shopIndex].items
  local itemObjParent = Grid_Items
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  for i = 1, itemCount do
    local itemObj = itemObjParent:FindDirect("ShopItem_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(Grid_Template)
      itemObj.name = "ShopItem_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector.Vector3.one
      GUIUtils.SetActive(itemObj, true)
    end
    itemObj:GetComponent("UIToggle").value = self.shopItemIndex == i
    local shopItem = shopCfg[self.shopIndex].items[i]
    local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(shopItem.fixAwardId)
    if awardCfg and #awardCfg.itemList > 0 then
      local itemId = awardCfg.itemList[1].itemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      local itemIcon = itemObj:FindDirect("Img_BgIcon/Img_Icon")
      local uiTexture = itemIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      local Label_Name = itemObj:FindDirect("Label_Name")
      GUIUtils.SetText(Label_Name, itemBase.name)
      local Label_Num = itemObj:FindDirect("Label_Num")
      local canBuyNum = shopData:GetItemCanBuyCount(shopItem.id)
      if shopItem.exchangeMaxCount == -1 then
        GUIUtils.SetText(Label_Num, "")
      else
        if canBuyNum == -1 then
          canBuyNum = shopItem.exchangeMaxCount
        end
        GUIUtils.SetText(Label_Num, canBuyNum)
      end
      local Img_BgPrice = itemObj:FindDirect("Img_BgPrice")
      local Label_Price = Img_BgPrice:FindDirect("Label_Price")
      local Img_MoneyIcon = Img_BgPrice:FindDirect("Img_MoneyIcon")
      local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
      local tokenCfg = ItemUtils.GetTokenCfg(TokenType.XIAO_HUI_KUAI_PAO_POINT)
      GUIUtils.SetText(Label_Price, shopItem.pointCount)
      if tokenCfg then
        GUIUtils.SetSprite(Img_MoneyIcon, tokenCfg.icon)
      end
    end
  end
end
def.method().AjustShopItems = function(self)
  local Scroll_View_Items = self.uiObjs.Img_BgItems:FindDirect("Scroll View_Items")
  local Grid_Items = Scroll_View_Items:FindDirect("Grid_Items")
  Grid_Items:GetComponent("UIGrid"):Reposition()
  Scroll_View_Items:GetComponent("UIScrollView"):ResetPosition()
end
def.method("number").ChooseShopItem = function(self, idx)
  if self.shopItemIndex == idx then
    return
  end
  self.shopItemIndex = idx
  self.buyItemCount = 1
  self:UpdateShopItemDetail()
end
def.method().ShowActivityTime = function(self)
  local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(curActivityId)
  local startTime = AbsoluteTimer.GetServerTimeTable(openTime)
  local endTime = AbsoluteTimer.GetServerTimeTable(closeTime)
  local Label_Time = self.uiObjs.Group_Date:FindDirect("Label_Time")
  GUIUtils.SetText(Label_Time, string.format(textRes.activity[815], startTime.year, startTime.month, startTime.day, endTime.year, endTime.month, endTime.day))
end
def.method().UpdateShopItemDetail = function(self)
  local Group_NoChoice = self.uiObjs.Img_BgDetail:FindDirect("Group_NoChoice")
  local Group_ItemInfo = self.uiObjs.Img_BgDetail:FindDirect("Group_ItemInfo")
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  local tokenCfg = ItemUtils.GetTokenCfg(TokenType.XIAO_HUI_KUAI_PAO_POINT)
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData == nil then
    return
  end
  local curPoint = shopData:GetCurrentShopPoint()
  if self.shopItemIndex == 0 then
    GUIUtils.SetActive(Group_NoChoice, true)
    GUIUtils.SetActive(Group_ItemInfo, false)
    local Group_Buy = Group_NoChoice:FindDirect("Group_Buy")
    local Label_Num = Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num")
    local Label_CostNum = Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum")
    local Img_MoneyCostIcon = Group_Buy:FindDirect("Label_Cost/Img_BgCost/Img_MoneyIcon")
    local Label_OwnNum = Group_Buy:FindDirect("Label_Have/Img_BgHave/Label_HaveNum")
    local Img_MoneyOwnIcon = Group_Buy:FindDirect("Label_Have/Img_BgHave/Img_MoneyIcon")
    GUIUtils.SetText(Label_Num, "1")
    GUIUtils.SetText(Label_CostNum, "0")
    GUIUtils.SetText(Label_OwnNum, curPoint:tostring())
    if tokenCfg then
      GUIUtils.SetSprite(Img_MoneyCostIcon, tokenCfg.icon)
      GUIUtils.SetSprite(Img_MoneyOwnIcon, tokenCfg.icon)
    end
  else
    GUIUtils.SetActive(Group_NoChoice, false)
    GUIUtils.SetActive(Group_ItemInfo, true)
    local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
    if shopCfg[self.shopIndex] == nil then
      warn("no shop cfg at index " .. self.shopIndex)
      return
    end
    if shopCfg[self.shopIndex].items[self.shopItemIndex] == nil then
      warn("no shop item cfg at type and index" .. self.shopIndex, self.shopItemIndex)
      return
    end
    local shopItem = shopCfg[self.shopIndex].items[self.shopItemIndex]
    local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(shopItem.fixAwardId)
    if awardCfg and 0 < #awardCfg.itemList then
      local itemId = awardCfg.itemList[1].itemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      local Label_DetailName = Group_ItemInfo:FindDirect("Group_Detail/Img_Title/Label_DetailName")
      local Label_Type = Group_ItemInfo:FindDirect("Group_Detail/Img_Title/Label_Type")
      local Label_DetailContent = Group_ItemInfo:FindDirect("Group_Detail/Label_DetailContent")
      GUIUtils.SetText(Label_DetailName, itemBase.name)
      GUIUtils.SetText(Label_Type, string.format(textRes.activity[836], itemBase.itemTypeName))
      GUIUtils.SetText(Label_DetailContent, itemBase.desc)
    end
    local Group_Buy = Group_ItemInfo:FindDirect("Group_Buy")
    local Label_Num = Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num")
    local Label_CostNum = Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum")
    local Img_MoneyCostIcon = Group_Buy:FindDirect("Label_Cost/Img_BgCost/Img_MoneyIcon")
    local Label_OwnNum = Group_Buy:FindDirect("Label_Have/Img_BgHave/Label_HaveNum")
    local Img_MoneyOwnIcon = Group_Buy:FindDirect("Label_Have/Img_BgHave/Img_MoneyIcon")
    GUIUtils.SetText(Label_Num, self.buyItemCount)
    local costStr = ""
    local needMoney = shopItem.pointCount * self.buyItemCount
    if not Int64.lt(curPoint, needMoney) then
      costStr = string.format("%d", needMoney)
    else
      costStr = string.format("[ff0000]%d[-]", needMoney)
    end
    GUIUtils.SetText(Label_CostNum, costStr)
    GUIUtils.SetText(Label_OwnNum, curPoint:tostring())
    if tokenCfg then
      GUIUtils.SetSprite(Img_MoneyCostIcon, tokenCfg.icon)
      GUIUtils.SetSprite(Img_MoneyOwnIcon, tokenCfg.icon)
    end
  end
end
def.method("number").ChangeBuyItemCount = function(self, change)
  if self.shopItemIndex == 0 then
    Toast(textRes.activity[816])
    return
  end
  local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
  if shopCfg[self.shopIndex] == nil then
    Toast(textRes.activity[816])
    return
  end
  if shopCfg[self.shopIndex].items[self.shopItemIndex] == nil then
    Toast(textRes.activity[816])
    return
  end
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData == nil then
    Toast(textRes.activity[816])
    return
  end
  local shopItem = shopCfg[self.shopIndex].items[self.shopItemIndex]
  local canBuyCount = shopData:GetItemCanBuyCount(shopItem.id)
  local changeCount = self.buyItemCount + change
  if shopItem.exchangeMaxCount == -1 then
    canBuyCount = MonkeyRunShopPanel.MAX_BUY_NUM
  else
    if canBuyCount == -1 then
      canBuyCount = shopItem.exchangeMaxCount
    end
    canBuyCount = math.min(canBuyCount, MonkeyRunShopPanel.MAX_BUY_NUM)
  end
  if changeCount < 1 then
    Toast(textRes.activity[817])
    changeCount = 1
  elseif canBuyCount < changeCount then
    Toast(string.format(textRes.activity[818], canBuyCount))
    changeCount = math.max(1, canBuyCount)
  end
  self.buyItemCount = changeCount
end
def.method().AjustBuyItemCount = function(self)
  local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
  if shopCfg[self.shopIndex] == nil then
    return
  end
  if shopCfg[self.shopIndex].items[self.shopItemIndex] == nil then
    return
  end
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData == nil then
    return
  end
  local shopItem = shopCfg[self.shopIndex].items[self.shopItemIndex]
  if shopItem.exchangeMaxCount ~= -1 then
    if canBuyCount == -1 then
      canBuyCount = shopItem.exchangeMaxCount
    end
    if canBuyCount == 0 then
      self.buyItemCount = 1
    else
      self.buyItemCount = math.min(self.buyItemCount, canBuyCount)
    end
  end
end
def.method().BuySelectedShopItem = function(self)
  if self.shopItemIndex == 0 then
    Toast(textRes.activity[816])
    return
  end
  local shopCfg = MonkeyRunUtils.GetMonkeyRunShopCfg()
  if shopCfg[self.shopIndex] == nil then
    Toast(textRes.activity[816])
    return
  end
  if shopCfg[self.shopIndex].items[self.shopItemIndex] == nil then
    Toast(textRes.activity[816])
    return
  end
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData == nil then
    Toast(textRes.activity[816])
    return
  end
  local shopItem = shopCfg[self.shopIndex].items[self.shopItemIndex]
  local nowCanBuyCount = shopData:GetItemCanBuyCount(shopItem.id)
  local curPoint = shopData:GetCurrentShopPoint()
  local needMoney = shopItem.pointCount * self.buyItemCount
  if Int64.lt(curPoint, needMoney) then
    Toast(textRes.activity[827])
    return
  end
  if nowCanBuyCount == 0 then
    Toast(textRes.activity[826])
    return
  end
  MonkeyRunMgr.Instance():BuyMonkeyRunShopItem(shopItem.id, self.buyItemCount)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Btn_CreditsClass_") then
    local idx = tonumber(string.sub(id, #"Btn_CreditsClass_" + 1))
    self:OnClickBtnShopType(idx)
  elseif string.find(id, "ShopItem_") then
    local idx = tonumber(string.sub(id, #"ShopItem_" + 1))
    self:OnClickBtnShopItem(idx)
  elseif id == "Btn_Minus" then
    self:OnClickBtnMinus()
  elseif id == "Btn_Add" then
    self:OnClickBtnAdd()
  elseif id == "Btn_Tips" then
    self:OnClickBtnTips()
  elseif id == "Btn_Buy" then
    self:OnClickBtnBuy()
  elseif id == "Btn_Help" then
    self:OnClickBtnHelp()
  elseif id == "Label_Num" then
    self:OnClickLabelNum()
  end
end
def.method("number").OnClickBtnShopType = function(self, shopIndex)
  self:ChooseShopIndex(shopIndex)
end
def.method("number").OnClickBtnShopItem = function(self, itemIdx)
  self:ChooseShopItem(itemIdx)
end
def.method().OnClickBtnAdd = function(self)
  self:ChangeBuyItemCount(1)
  self:UpdateShopItemDetail()
end
def.method().OnClickBtnMinus = function(self)
  self:ChangeBuyItemCount(-1)
  self:UpdateShopItemDetail()
end
def.method().OnClickBtnTips = function(self)
  Toast(textRes.activity[819])
end
def.method().OnClickBtnBuy = function(self)
  self:BuySelectedShopItem()
end
def.method().OnClickBtnHelp = function(self)
  local curActivityId = MonkeyRunMgr.Instance():GetCurrentActivityId()
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  GUIUtils.ShowHoverTip(activityCfg.pointExchangeTipId, 0, 0)
end
def.method().OnClickLabelNum = function(self)
  if self.shopItemIndex == 0 then
    Toast(textRes.activity[816])
    return
  end
  local NumberPad = require("GUI.CommonDigitalKeyboard")
  NumberPad.Instance():ShowPanelEx(-1, function(num)
    self:ChangeBuyItemCount(num - self.buyItemCount)
    self:UpdateShopItemDetail()
    if num > 0 then
      NumberPad.Instance():SetEnteredValue(self.buyItemCount)
    end
  end, nil)
end
def.static("table", "table").OnShopDataChange = function(params, context)
  local self = instance
  self:UpdateShopItems()
  self:AjustShopItems()
  self:AjustBuyItemCount()
  self:UpdateShopItemDetail()
end
def.static("table", "table").OnOpenChange = function(params, context)
  local self = instance
  if not MonkeyRunMgr.Instance():IsActivityOpened() then
    self:DestroyPanel()
  end
end
return MonkeyRunShopPanel.Commit()
