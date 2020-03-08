local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemOnShelfNode = Lplus.Extend(TabNode, "ItemOnShelfNode")
local def = ItemOnShelfNode.define
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local GUIUtils = require("GUI.GUIUtils")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local PitchSellNode = Lplus.ForwardDeclare("PitchSellNode")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PitchItemOnShelfPanel = Lplus.ForwardDeclare("PitchItemOnShelfPanel")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local DisplayVer = {V1 = "V1", V2 = "V2"}
def.field("boolean").bIsItemListInit = false
def.field("table").uiTbl = nil
def.field("number").lastItemListNum = 0
def.field("table").selectItemIndexs = nil
def.field("number").canUseNum = 0
def.field("number").ONSELL_MAX_NUM_PER_GRID = 5
def.field("string").displayVer = DisplayVer.V1
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.uiTbl = CommercePitchUtils.FillPitchItemOnShelfUI(self.uiTbl, self.m_node)
  self.ONSELL_MAX_NUM_PER_GRID = CommercePitchUtils.GetOnSellMaxNumPerGrid()
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BAITAN_ALL_ON_SHELF) then
    self.displayVer = DisplayVer.V2
  else
    self.displayVer = DisplayVer.V1
  end
end
def.override().OnShow = function(self)
  if false == self.bIsItemListInit then
    self:InitUI()
    self.selectItemIndexs = {}
    for index, itemIndex in ipairs(PitchItemOnShelfPanel.Instance().itemIdCanSell) do
      local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[itemIndex]
      if itemInfo.isExpireItem then
        itemInfo.sellNum = itemInfo.count
        table.insert(self.selectItemIndexs, index)
      end
    end
    self:FillItemList()
  end
  self:UpdateSilverMoney()
end
def.override().OnHide = function(self)
end
def.method().InitUI = function(self)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Btn_Max = Group_Num:FindDirect("Btn_Max")
  local Label_TanName = Group_Num:FindDirect("Label_TanName")
  local Label_TanNum = Group_Num:FindDirect("Label_TanNum")
  local Label_Num = Group_Num:FindDirect("Img_BgNum/Label_Num")
  local isV2 = self.displayVer == DisplayVer.V2
  GUIUtils.SetActive(Btn_Max, isV2)
  GUIUtils.SetActive(Label_TanName, isV2)
  GUIUtils.SetActive(Label_TanNum, isV2)
  GUIUtils.AddBoxCollider(Label_Num)
end
def.method("number").SetCanUseNum = function(self, canUseNum)
  self.canUseNum = canUseNum + #PitchData.Instance():GetExpireSellItems()
end
def.method().FillItemList = function(self)
  if 0 == #PitchItemOnShelfPanel.Instance().itemIdCanSell then
    self.uiTbl.Group_Item0:SetActive(false)
    self.uiTbl.Group_Empty:SetActive(true)
    local Btn_ConfirmAll = self.uiTbl.Group_Empty:FindDirect("Btn_ConfirmAll")
    GUIUtils.SetActive(Btn_ConfirmAll, false)
  else
    self.uiTbl.Group_Item0:SetActive(true)
    self.uiTbl.Group_Empty:SetActive(false)
    self:UpdateItemObjects()
    self:FillRight(false)
    self:FillBag()
  end
  self:UpdateGridNum()
  self.bIsItemListInit = true
end
def.method().UpdateSilverMoney = function(self)
  self.uiTbl.Label_MoneyNum:GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
end
def.method().UpdateItemObjects = function(self)
  local itemDVal = #PitchItemOnShelfPanel.Instance().itemIdCanSell - self.lastItemListNum
  local itemGridTemplate = self.uiTbl.Grid_Bag
  local itemTemplate = self.uiTbl.Img_BgBagItem01
  if itemDVal > 0 then
    for i = 1, itemDVal do
      self.lastItemListNum = self.lastItemListNum + 1
      CommercePitchUtils.AddLastGroup(self.lastItemListNum, "Img_BgBagItem0%d", itemGridTemplate, itemTemplate)
    end
  elseif itemDVal < 0 then
    local num = math.abs(itemDVal)
    for i = 1, num do
      CommercePitchUtils.DeleteLastGroup(self.lastItemListNum, "Img_BgBagItem01", itemGridTemplate, itemTemplate)
      self.lastItemListNum = self.lastItemListNum - 1
    end
  end
  local uiGrid = itemGridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().FillBag = function(self)
  local gridTemplate = self.uiTbl.Grid_Bag
  local itemTemplate = self.uiTbl.Img_BgBagItem01
  local count = 1
  local index = 1
  local bItemTemplateFill = false
  if false == bItemTemplateFill then
    self:FillItem(PitchItemOnShelfPanel.Instance().itemIdCanSell, index, count, itemTemplate)
    index = index + 1
    bItemTemplateFill = true
  end
  local preSelectedNum = #self.selectItemIndexs
  local isAutoSeclect = false
  for i = index, #PitchItemOnShelfPanel.Instance().itemIdCanSell do
    count = count + 1
    local itemNew = gridTemplate:GetChild(count - 1)
    local res = self:FillItem(PitchItemOnShelfPanel.Instance().itemIdCanSell, i, count, itemNew)
    if res then
      isAutoSeclect = true
    end
  end
  for i = 1, preSelectedNum do
    local itemObj = gridTemplate:GetChild(i - 1)
    if itemObj then
      itemObj:GetComponent("UIToggle"):set_isChecked(true)
    end
    if i == preSelectedNum and not isAutoSeclect then
      self:FillRight(true)
    end
  end
  self.lastItemListNum = #PitchItemOnShelfPanel.Instance().itemIdCanSell
end
def.method("table", "number", "number", "userdata", "=>", "boolean").FillItem = function(self, itemList, index, count, itemNew)
  local itemIndx = itemList[index]
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[itemIndx]
  warn("FillItem:", index, pretty(itemInfo))
  local itemBase = itemInfo.itemBase
  GUIUtils.SetItemCellSprite(itemNew, itemBase.namecolor)
  local Texture_BagIcon = itemNew:FindDirect("Texture_BagIcon")
  local uiTexture = Texture_BagIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  GUIUtils.SetActive(itemNew:FindDirect("Img_Sign"), itemInfo.isExpireItem)
  if itemInfo.isExpireItem then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
  local Labe_BagNuml = itemNew:FindDirect("Labe_BagNuml")
  Labe_BagNuml:GetComponent("UILabel"):set_text(itemInfo.count)
  local itemId = itemInfo.id
  if itemId == PitchItemOnShelfPanel.Instance().selectItemId and itemInfo.key == PitchItemOnShelfPanel.Instance().selectItemKey then
    itemNew:GetComponent("UIToggle"):set_isChecked(true)
    table.insert(self.selectItemIndexs, index)
    self:FillRight(true)
    PitchItemOnShelfPanel.Instance().selectItemId = 0
    PitchItemOnShelfPanel.Instance().selectItemKey = 0
    return true
  end
  return false
end
def.method("boolean").FillRight = function(self, bShowInfo)
  if false == bShowInfo then
    self.uiTbl.Group_Right:SetActive(false)
    self.uiTbl.Group_None:SetActive(true)
    local Btn_SelectAll = self.uiTbl.Group_None:FindDirect("Btn_SelectAll")
    GUIUtils.SetActive(Btn_SelectAll, self.displayVer == DisplayVer.V2)
  else
    self.uiTbl.Group_Right:SetActive(true)
    self.uiTbl.Group_None:SetActive(false)
    self:FillItemInfo()
  end
end
def.method("table", "=>", "number").GetLevel = function(self, itemBase)
  local lv = -1
  if itemBase.itemType == ItemType.MADE_MATERIAL then
    local EquipUtils = require("Main.Equip.EquipUtils")
    local matCfg = EquipUtils.GetEquipMakeMaterialInfo(itemBase.itemid)
    lv = matCfg.materialLevel
  elseif itemBase.itemType == ItemType.EQUIP then
    lv = itemBase.useLevel
  end
  return lv
end
def.method("number", "=>", "number").CalcRecommendSellNum = function(self, haveNum)
  local recommendSellNum = haveNum
  if recommendSellNum > self.ONSELL_MAX_NUM_PER_GRID then
    recommendSellNum = self.ONSELL_MAX_NUM_PER_GRID
  end
  return recommendSellNum
end
def.method().FillItemInfo = function(self)
  local index = self.selectItemIndexs[#self.selectItemIndexs]
  local lastIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[index]
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[lastIndex]
  local last = itemInfo.itemBase
  local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(last.itemid)
  local haveNum = itemInfo.count
  local sellNum = itemInfo.sellNum or self:CalcRecommendSellNum(haveNum)
  local price = itemInfo.price
  local serviceMoney, _ = math.modf(price * 0.05 * sellNum)
  local ScrollView = self.uiTbl.Group_Right:FindDirect("Scroll View")
  local Group_Info = self.uiTbl.Group_Right:FindDirect("Group_Info")
  local Label_LvTitle = Group_Info:FindDirect("Label_LvTitle")
  local Label_Lv = Group_Info:FindDirect("Label_Lv")
  local lv = self:GetLevel(last)
  if lv >= 0 then
    Label_LvTitle:SetActive(true)
    Label_Lv:SetActive(true)
    Label_Lv:GetComponent("UILabel"):set_text(lv)
  else
    Label_LvTitle:SetActive(false)
    Label_Lv:SetActive(false)
  end
  local Label_Type = Group_Info:FindDirect("Label_Type")
  Label_Type:GetComponent("UILabel"):set_text(last.itemTypeName)
  local Label_Describe = ScrollView:FindDirect("Label_Describe")
  local item = itemInfo.item
  if not itemInfo.isExpireItem then
    item = ItemModule.Instance():GetItemByBagIdAndItemKey(itemInfo.bagId, itemInfo.key)
  end
  local itemCompare = ItemTipsMgr.Instance()._itemCompare
  ItemTipsMgr.Instance()._itemCompare = nil
  local description = ""
  if item then
    description = ItemTipsMgr.Instance():GetDescription(item, last)
  end
  ItemTipsMgr.Instance()._itemCompare = itemCompare
  Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(description)
  local Img_BgRightItem = Group_Info:FindDirect("Img_BgRightItem")
  GUIUtils.SetItemCellSprite(Img_BgRightItem, last.namecolor)
  local Texture_RightIcon = Img_BgRightItem:FindDirect("Texture_RightIcon")
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), last.icon)
  local Label_RightName = Group_Info:FindDirect("Label_RightName")
  Label_RightName:GetComponent("UILabel"):set_text(last.name)
  local Group_Price = self.uiTbl.Group_Right:FindDirect("Group_Price")
  local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
  local Label_Price = Img_BgPrice:FindDirect("Label_Price")
  local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
  local showPrice = math.ceil(price)
  local priceText = CommercePitchUtils.GetPitchColoredPriceText(showPrice)
  Label_Price:GetComponent("UILabel"):set_text(priceText)
  Label_PriceCompare:GetComponent("UILabel"):set_text(textRes.Pitch[52])
  Label_PriceCompare:GetComponent("UILabel"):set_textColor(Color.white)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(sellNum)
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self:InitPriceAndRate(itemInfo)
  itemInfo.sellNum = sellNum
  self:UpdatePriceLabel(0)
  self:UpdateDisplayedItemGridNum()
end
def.method("table").InitPriceAndRate = function(self, itemInfo)
  if itemInfo.priceRate ~= nil then
    return
  end
  local minRate = CommercePitchUtils.GetAdjustPriceRateMin() / 10000
  local maxRate = CommercePitchUtils.GetAdjustPriceRateMax() / 10000
  if PitchData.Instance().itemPriceRecord[itemInfo.id] then
    itemInfo.price = PitchData.Instance().itemPriceRecord[itemInfo.id]
    itemInfo.notNeedComplete = true
  end
  local initRate = itemInfo.price / (itemInfo.recommandPrice or itemInfo.price)
  if maxRate < initRate then
    initRate = maxRate
  elseif minRate > initRate then
    initRate = minPrice
  end
  itemInfo.priceRate = initRate
  itemInfo.price = itemInfo.recommandPrice or itemInfo.price
  local haveNum = itemInfo.count
  local recommendSellNum = self:CalcRecommendSellNum(haveNum)
  itemInfo.sellNum = recommendSellNum
end
def.method("number", "=>", "number").GetCompleteRate = function(self, expRate)
  local bIsNegative = false
  if expRate < 0 then
    bIsNegative = true
    expRate = math.abs(expRate)
  end
  expRate = expRate * 10
  local _, small = math.modf(expRate / 1)
  if small >= 0.5 then
    expRate = math.ceil(expRate)
  else
    expRate = math.floor(expRate)
  end
  expRate = expRate / 10
  if bIsNegative then
    expRate = 0 - expRate
  end
  return expRate
end
def.method("number").UpdatePriceLabel = function(self, rate)
  local Group_Price = self.uiTbl.Group_Right:FindDirect("Group_Price")
  local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
  local Label_Price = Img_BgPrice:FindDirect("Label_Price")
  local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  local index = self.selectItemIndexs[#self.selectItemIndexs]
  local lastIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[index]
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[lastIndex]
  local last = itemInfo.itemBase
  local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(last.itemid)
  local price = itemInfo.price
  local expRate = itemInfo.priceRate + rate
  local minRate = CommercePitchUtils.GetAdjustPriceRateMin() / 10000
  local maxRate = CommercePitchUtils.GetAdjustPriceRateMax() / 10000
  if expRate <= maxRate + 1.0E-6 and expRate >= minRate then
    local needComplete = rate ~= 0 or not itemInfo.notNeedComplete
    if needComplete then
      expRate = self:GetCompleteRate(expRate)
    end
    local expPrice, _ = math.modf((expRate + 1) * price)
    expPrice = expRate * price
    if maxPrice < expPrice then
      expPrice = maxPrice
      expRate = expPrice / price
      Toast(textRes.Pitch[22])
    elseif minPrice > expPrice then
      expPrice = minPrice
      expRate = expPrice / price
      Toast(textRes.Pitch[23])
    end
    local showPrice = require("Common.MathHelper").Ceil(expPrice)
    local priceText = CommercePitchUtils.GetPitchColoredPriceText(showPrice)
    Label_Price:GetComponent("UILabel"):set_text(priceText)
    local str = textRes.Pitch[52]
    local textColor = Color.white
    local percent = expRate * 100
    percent, _ = math.modf(percent / 1)
    if percent > 100 then
      local tmp = percent - 100
      str = str .. "+" .. tmp .. "%"
      textColor = Color.red
    elseif percent < 100 then
      local tmp = 100 - percent
      str = str .. "-" .. tmp .. "%"
      textColor = Color.green
    end
    Label_PriceCompare:GetComponent("UILabel"):set_text(str)
    Label_PriceCompare:GetComponent("UILabel"):set_textColor(textColor)
    itemInfo.priceRate = expRate
    local serviceMoney, _ = math.modf(expPrice * 0.05 * itemInfo.sellNum)
    Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  elseif minRate > expRate then
    Toast(textRes.Pitch[16])
  elseif expRate > maxRate + 1.0E-6 then
    Toast(textRes.Pitch[15])
  end
end
def.method("number").UpdateItemNum = function(self, addNum)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  local index = self.selectItemIndexs[#self.selectItemIndexs]
  local lastIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[index]
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[lastIndex]
  if itemInfo.isExpireItem then
    Toast(textRes.Pitch[25])
    return
  end
  local last = itemInfo.itemBase
  local price = itemInfo.price
  local curNum = tonumber(Label_Num:GetComponent("UILabel"):get_text())
  local expNum = curNum + addNum
  local have = itemInfo.count
  if expNum > have then
    Toast(textRes.Pitch[17])
    expNum = have
    local maxAddNum = have - curNum
    if self.displayVer == DisplayVer.V2 and maxAddNum > self:GetLeftOnShelfItemNum(index) then
      expNum = curNum + self:GetLeftOnShelfItemNum(index)
    end
  elseif expNum < 1 then
    expNum = 1
    Toast(textRes.Pitch[18])
  else
    local index = self:GetDisplayedItemIndex()
    if self.displayVer == DisplayVer.V1 and expNum > self.ONSELL_MAX_NUM_PER_GRID then
      Toast(textRes.Pitch[17])
      expNum = self.ONSELL_MAX_NUM_PER_GRID
    elseif self.displayVer == DisplayVer.V2 and addNum > self:GetLeftOnShelfItemNum(index) then
      self:ShowGridLimitedToast()
      expNum = curNum + self:GetLeftOnShelfItemNum(index)
    end
  end
  Label_Num:GetComponent("UILabel"):set_text(expNum)
  itemInfo.sellNum = expNum
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  local serviceMoney, _ = math.modf(itemInfo.priceRate * price * 0.05 * expNum)
  Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  if self.displayVer == DisplayVer.V2 then
    self:UpdateGridNum()
    self:UpdateDisplayedItemGridNum()
  end
end
def.method().UpdateGridNum = function(self)
  local sellListNum = self:GetOnShelfListNum()
  local sellGridNum = PitchData.Instance():GetSellGridNum()
  local str = sellListNum .. "/" .. sellGridNum
  self.uiTbl.Label_ItemNum:GetComponent("UILabel"):set_text(str)
  self:UpdateSelectAllBtn()
end
def.method().UpdateDisplayedItemGridNum = function(self)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Label_TanNum = Group_Num:FindDirect("Label_TanNum")
  local index = self:GetDisplayedItemIndex()
  local useGridNum = self:GetCanSellItemUseGridNum(index)
  local sellGridNum = PitchData.Instance():GetSellGridNum()
  local str = useGridNum
  GUIUtils.SetText(Label_TanNum, str)
end
def.method("=>", "number").GetOnShelfListNum = function(self)
  local sellListNum = #PitchData.Instance():GetSellList() - #PitchData.Instance():GetExpireSellItems()
  sellListNum = sellListNum + self:GetSelectsOnShelfGridNum()
  return sellListNum
end
def.method("=>", "number").GetSelectsOnShelfGridNum = function(self)
  local num = 0
  for i, index in ipairs(self.selectItemIndexs) do
    num = num + self:GetCanSellItemUseGridNum(index)
  end
  return num
end
def.method("number", "=>", "number").GetCanSellItemUseGridNum = function(self, index)
  local itemInfo = self:GetCanSellItemInfoByIndex(index)
  return math.floor((itemInfo.sellNum - 1) / self.ONSELL_MAX_NUM_PER_GRID) + 1
end
def.method("=>", "number").GetLeftOnShelfGridNum = function(self)
  return self.canUseNum - self:GetSelectsOnShelfGridNum()
end
def.method("number", "=>", "number").GetLeftOnShelfItemNum = function(self, index)
  local itemInfo = self:GetCanSellItemInfoByIndex(index)
  if itemInfo.sellNum >= itemInfo.count then
    return 0
  end
  local leftOnShelfGridNum = self:GetLeftOnShelfGridNum()
  local leftOnShelfItemNum = leftOnShelfGridNum * self.ONSELL_MAX_NUM_PER_GRID + (self.ONSELL_MAX_NUM_PER_GRID - itemInfo.sellNum % self.ONSELL_MAX_NUM_PER_GRID) % self.ONSELL_MAX_NUM_PER_GRID
  return leftOnShelfItemNum
end
def.method("number", "=>", "table").GetCanSellItemInfoByIndex = function(self, index)
  local lastIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[index]
  if lastIndex == nil then
    return nil
  end
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[lastIndex]
  return itemInfo
end
def.method("userdata", "string").OnItemSelect = function(self, clickobj, id)
  local leftOnShelfNum = self:GetLeftOnShelfGridNum()
  if leftOnShelfNum <= 0 and clickobj:GetComponent("UIToggle"):get_isChecked() then
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    self:ShowGridLimitedToast()
    return
  end
  local index = tonumber(string.sub(id, string.len("Img_BgBagItem0") + 1))
  local bSelect = clickobj:GetComponent("UIToggle"):get_isChecked()
  if bSelect then
    table.insert(self.selectItemIndexs, index)
  else
    local itemInfo = self:GetCanSellItemInfoByIndex(index)
    if itemInfo then
      itemInfo.sellNum = nil
    end
    for k, v in pairs(self.selectItemIndexs) do
      if v == index then
        table.remove(self.selectItemIndexs, k)
        break
      end
    end
    if 0 < #self.selectItemIndexs then
      bSelect = true
    end
  end
  self:FillRight(bSelect)
  self:UpdateGridNum()
end
def.method().OnShelfItemsClick = function(self)
  local level = require("Main.Hero.Interface").GetHeroProp().level
  if level < CommercePitchUtils.GetPitchOpenLevel() then
    Toast(string.format(textRes.Commerce[19], CommercePitchUtils.GetPitchOpenLevel()))
    return
  end
  if 0 == #self.selectItemIndexs then
    Toast(textRes.Pitch[28])
    return
  end
  local serviceMoney = 0
  local reSellItemMap = {}
  for k, v in pairs(self.selectItemIndexs) do
    local itemIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[v]
    local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[itemIndex]
    self:InitPriceAndRate(itemInfo)
    local item = itemInfo.itemBase
    local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(item.itemid)
    local price = itemInfo.price
    local sellPrice = price * itemInfo.priceRate
    serviceMoney = serviceMoney + sellPrice * 0.05 * itemInfo.sellNum
    if itemInfo.isExpireItem then
      reSellItemMap[tostring(itemInfo.shoppingid)] = true
    end
  end
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(serviceMoney) == true then
    Toast(textRes.Pitch[26])
    return
  end
  local unshelveItems = {}
  local expireItems = PitchData.Instance():GetExpireSellItems()
  for i, v in ipairs(expireItems) do
    if not reSellItemMap[tostring(v.shoppingid)] then
      table.insert(unshelveItems, v)
    end
  end
  if #unshelveItems > ItemModule.Instance():GetBagLeftSize() then
    Toast(textRes.Pitch[27])
    return
  end
  local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
  for k, v in pairs(self.selectItemIndexs) do
    local itemIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[v]
    local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[itemIndex]
    local item = itemInfo.itemBase
    local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(item.itemid)
    local price = itemInfo.price
    local sellPrice = price * itemInfo.priceRate
    if itemInfo.isExpireItem then
      CommercePitchProtocol.CReSellExpireItemReq(itemInfo.shoppingid, item.itemid, sellPrice)
    else
      local leftSellNum = itemInfo.sellNum
      repeat
        local sellNum
        if leftSellNum > self.ONSELL_MAX_NUM_PER_GRID then
          sellNum = self.ONSELL_MAX_NUM_PER_GRID
        else
          sellNum = leftSellNum
        end
        CommercePitchProtocol.CSellItemReq(itemInfo.bagId, itemInfo.key, item.itemid, sellPrice, sellNum)
        leftSellNum = leftSellNum - sellNum
      until leftSellNum <= 0
    end
  end
  for i, v in ipairs(unshelveItems) do
    CommercePitchProtocol.CGetSellItemReq(v.shoppingid, v.item.id)
  end
  self.m_base:DestroyPanel()
  self.m_base = nil
end
def.method().ShowServiceTips = function(self)
  local tipsId = CommercePitchUtils.GetPitchServiceTipsId()
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnAddGridClick = function(self)
  local sellGridNum = PitchData.Instance():GetSellGridNum()
  local gridShowNum = sellGridNum + 1
  if gridShowNum >= CommercePitchUtils.GetStallMax() then
    Toast(textRes.Pitch[20])
  else
    CommonConfirmDlg.ShowConfirm(textRes.Pitch[9], string.format(textRes.Pitch[10], CommercePitchUtils.GetExpendStallCostYuanBao()), function(s)
      if s == 1 then
        if self.m_base then
          self.m_base:DestroyPanel()
        end
        PitchSellNode.ExtendGridCallback(s, nil)
      end
    end, nil)
  end
end
def.method("userdata").ShowSelectItemTips = function(self, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local index = self:GetDisplayedItemIndex()
  local lastIndex = PitchItemOnShelfPanel.Instance().itemIdCanSell[index]
  local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[lastIndex]
  local item = itemInfo.item or itemInfo.key and ItemModule.Instance():GetItemByBagIdAndItemKey(itemInfo.bagId, itemInfo.key) or nil
  if item then
    ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  end
end
def.method("=>", "number").GetDisplayedItemIndex = function(self)
  return self.selectItemIndexs[#self.selectItemIndexs]
end
def.method("=>", "boolean").HasSelectAll = function(self)
  local leftGridNum = self:GetLeftOnShelfGridNum()
  if leftGridNum <= 0 then
    return true
  end
  if #self.selectItemIndexs >= #PitchItemOnShelfPanel.Instance().itemIdCanSell then
    return true
  end
  return false
end
def.method().SelectAll = function(self)
  self:UnSelectAll()
  local leftGridNum = self:GetLeftOnShelfGridNum()
  if leftGridNum <= 0 then
    self:ShowGridLimitedToast()
    return
  end
  for index, itemIndex in ipairs(PitchItemOnShelfPanel.Instance().itemIdCanSell) do
    local itemInfo = PitchItemOnShelfPanel.Instance().itemCanSell[itemIndex]
    itemInfo.sellNum = self:CalcRecommendSellNum(itemInfo.count)
    table.insert(self.selectItemIndexs, index)
    leftGridNum = leftGridNum - 1
    if leftGridNum <= 0 then
      break
    end
  end
end
def.method().UnSelectAll = function(self)
  if #self.selectItemIndexs > 0 then
    for _, index in ipairs(self.selectItemIndexs) do
      local itemInfo = self:GetCanSellItemInfoByIndex(index)
      if itemInfo then
        itemInfo.sellNum = nil
      end
      local itemGO = self.uiTbl.Grid_Bag:FindDirect("Img_BgBagItem0" .. index)
      GUIUtils.Toggle(itemGO, false)
    end
    self.selectItemIndexs = {}
  end
end
def.method().UpdateSelectAllBtn = function(self)
  local Btn_SelectAll = self.uiTbl.Group_Right:FindDirect("Btn_SelectAll")
  local Label = Btn_SelectAll:FindDirect("Label_Confirm")
  if self:HasSelectAll() then
    GUIUtils.SetText(Label, textRes.Pitch[38])
  else
    GUIUtils.SetText(Label, textRes.Pitch[37])
  end
end
def.method().OnClickSelectAllBtn = function(self)
  if self:HasSelectAll() then
    self:UnSelectAll()
  else
    self:SelectAll()
  end
  self:FillBag()
  self:UpdateGridNum()
end
def.method().OnClickMaxBtn = function(self)
  local index = self:GetDisplayedItemIndex()
  local itemInfo = self:GetCanSellItemInfoByIndex(index)
  if itemInfo.sellNum >= itemInfo.count then
    Toast(textRes.Pitch[17])
    return
  end
  local leftOnShelfGridNum = self:GetLeftOnShelfGridNum()
  if leftOnShelfGridNum <= 0 then
    self:ShowGridLimitedToast()
    return
  end
  local leftOnShelfItemNum = leftOnShelfGridNum * self.ONSELL_MAX_NUM_PER_GRID + (self.ONSELL_MAX_NUM_PER_GRID - itemInfo.sellNum % self.ONSELL_MAX_NUM_PER_GRID) % self.ONSELL_MAX_NUM_PER_GRID
  local maxNum = math.min(itemInfo.count - itemInfo.sellNum, leftOnShelfItemNum)
  self:UpdateItemNum(maxNum)
end
def.method().OnClickItemNumLabel = function(self)
  if self.displayVer == DisplayVer.V2 then
    local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
    CommonDigitalKeyboard.Instance():ShowPanelEx(-1, ItemOnShelfNode.OnDigitalKeyboardCallback, {self = self})
    CommonDigitalKeyboard.Instance():SetPos(-140, 0)
  end
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  local curNum = tonumber(Label_Num:GetComponent("UILabel"):get_text())
  local addNum = value - curNum
  self:UpdateItemNum(addNum)
  curNum = tonumber(Label_Num:GetComponent("UILabel"):get_text())
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if value > 0 then
    CommonDigitalKeyboard.Instance():SetEnteredValue(curNum)
  else
    CommonDigitalKeyboard.Instance():SetEnteredValue(0)
  end
end
def.method().ShowGridLimitedToast = function(self)
  Toast(string.format(textRes.Pitch[29], self.canUseNum))
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgBagItem0") then
    self:OnItemSelect(clickobj, id)
  elseif "Btn_MinusIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(-rate)
  elseif "Btn_AddIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(rate)
  elseif "Btn_MinusIN" == id then
    self:UpdateItemNum(-1)
  elseif "Btn_AddIN" == id then
    self:UpdateItemNum(1)
  elseif "Btn_Confirm" == id then
    self:OnShelfItemsClick()
  elseif "Btn_ItemAdd" == id then
    self:OnAddGridClick()
  elseif "Btn_Tips" == id then
    self:ShowServiceTips()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif "Texture_RightIcon" == id then
    self:ShowSelectItemTips(clickobj.parent)
  elseif id == "Btn_SelectAll" then
    self:OnClickSelectAllBtn()
  elseif id == "Btn_Max" then
    self:OnClickMaxBtn()
  elseif id == "Label_Num" and clickobj.parent.name == "Img_BgNum" then
    self:OnClickItemNumLabel()
  end
end
ItemOnShelfNode.Commit()
return ItemOnShelfNode
