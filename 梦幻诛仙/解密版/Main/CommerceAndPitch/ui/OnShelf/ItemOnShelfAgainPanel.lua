local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemOnShelfAgainPanel = Lplus.Extend(ECPanelBase, "ItemOnShelfAgainPanel")
local ItemUtils = require("Main.Item.ItemUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = ItemOnShelfAgainPanel.define
local instance
def.field("function").callback = nil
def.field("table").tag = nil
def.field("table").item = nil
def.field("table").acceptItemId = nil
def.static("=>", ItemOnShelfAgainPanel).Instance = function()
  if nil == instance then
    instance = ItemOnShelfAgainPanel()
  end
  return instance
end
def.static("function", "table", "table").ShowItemOnShelfAgain = function(callback, tag, itemInfo)
  local dlg = ItemOnShelfAgainPanel.Instance()
  dlg.callback = callback
  dlg.tag = tag
  dlg.item = itemInfo
  dlg.acceptItemId = {}
  dlg:RequireToItemNewPrice()
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.ITEM_RECOMMEND_PRICE_RES, ItemOnShelfAgainPanel.OnSSyncRecommandPriceChange)
end
def.method().RequireToItemNewPrice = function(self)
  local tbl = {}
  table.insert(tbl, self.item.item.id)
  CommercePitchProtocol.CRecommendPriceChangeReq(tbl)
end
def.override().OnCreate = function(self)
  self:UpdateItemRecommandPrice(self.acceptItemId)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.ITEM_RECOMMEND_PRICE_RES, ItemOnShelfAgainPanel.OnSSyncRecommandPriceChange)
end
def.static("table", "table").OnSSyncRecommandPriceChange = function(params, context)
  ItemOnShelfAgainPanel.Instance().acceptItemId = params[1]
  ItemOnShelfAgainPanel.Instance():SetModal(true)
  ItemOnShelfAgainPanel.Instance():CreatePanel(RESPATH.PREFAB_PITCH_SELL_PANEL, 0)
end
def.method("table").UpdateItemRecommandPrice = function(self, tbl)
  local itemId = self.item.item.id
  if tbl[itemId] then
    self.item.recommandPrice = tbl[itemId]
  else
    local price, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(itemId)
    self.item.recommandPrice = price
  end
  self:UpdateInfo()
end
def.method("table", "=>", "number").GetLevel = function(self, itemBase)
  local lv = -1
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.MADE_MATERIAL then
    local EquipUtils = require("Main.Equip.EquipUtils")
    local matCfg = EquipUtils.GetEquipMakeMaterialInfo(itemBase.itemid)
    lv = matCfg.materialLevel
  elseif itemBase.itemType == ItemType.EQUIP then
    lv = itemBase.useLevel
  end
  return lv
end
def.method().UpdateInfo = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Right = Img_Bg0:FindDirect("Group_Right")
  local itemId = self.item.item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  local serviceMoney, _ = math.modf(self.item.price * 0.05 * self.item.item.number)
  local percent, _ = math.modf(((self.item.price - self.item.recommandPrice) / self.item.recommandPrice + 1) * 100)
  local Img_BgDescribe = Group_Right:FindDirect("Img_BgDescribe")
  local Label_Describe = Img_BgDescribe:FindDirect("Scroll View/Label_Describe")
  local itemCompare = ItemTipsMgr.Instance()._itemCompare
  ItemTipsMgr.Instance()._itemCompare = nil
  local description = ""
  local item = self.item.item
  if item then
    description = ItemTipsMgr.Instance():GetDescription(item, itemBase)
  end
  ItemTipsMgr.Instance()._itemCompare = itemCompare
  Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(description)
  local Img_BgRightItem = Group_Right:FindDirect("Img_BgRightItem")
  local Texture_RightIcon = Img_BgRightItem:FindDirect("Texture_RightIcon")
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemBase.icon)
  local Label_RightName = Group_Right:FindDirect("Label_RightName")
  Label_RightName:GetComponent("UILabel"):set_text(itemBase.name)
  local Label_Type = Group_Right:FindDirect("Label_Type")
  Label_Type:GetComponent("UILabel"):set_text(itemBase.itemTypeName)
  local Label_Lv = Group_Right:FindDirect("Label_Lv")
  local Label_LvTitle = Group_Right:FindDirect("Label_LvTitle")
  local lv = self:GetLevel(itemBase)
  if lv >= 0 then
    Label_LvTitle:SetActive(true)
    Label_Lv:SetActive(true)
    Label_Lv:GetComponent("UILabel"):set_text(lv)
  else
    Label_LvTitle:SetActive(false)
    Label_Lv:SetActive(false)
  end
  local Group_Price = Group_Right:FindDirect("Group_Price")
  local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
  local Label_Price = Img_BgPrice:FindDirect("Label_Price")
  local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
  local showPrice = math.ceil(self.item.price)
  local priceText = CommercePitchUtils.GetPitchColoredPriceText(showPrice)
  Label_Price:GetComponent("UILabel"):set_text(priceText)
  local str = textRes.Pitch[52]
  local textColor = Color.white
  local tmp = 0
  if percent > 100 then
    tmp = percent - 100
    str = str .. "+" .. tmp .. "%"
    textColor = Color.red
  elseif percent < 100 then
    tmp = percent - 100
    str = str .. tmp .. "%"
    textColor = Color.green
  end
  Label_PriceCompare:GetComponent("UILabel"):set_text(str)
  Label_PriceCompare:GetComponent("UILabel"):set_textColor(textColor)
  local Group_Num = Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(self.item.item.number)
  local Group_Tax = Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  self.item.percent = tmp / 100
  self.item.tmpPrice = self.item.price
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
  local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(self.item.item.id)
  local expRate = self.item.percent + rate
  local minRate = CommercePitchUtils.GetAdjustPriceRateMin() / 10000 - 1
  local maxRate = CommercePitchUtils.GetAdjustPriceRateMax() / 10000 - 1
  if expRate <= maxRate and expRate >= minRate then
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local Group_Right = Img_Bg0:FindDirect("Group_Right")
    local Group_Price = Group_Right:FindDirect("Group_Price")
    local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
    local Label_Price = Img_BgPrice:FindDirect("Label_Price")
    expRate = self:GetCompleteRate(expRate)
    local expPrice, _ = math.modf((expRate + 1) * self.item.recommandPrice)
    if maxPrice < expPrice then
      expPrice = maxPrice
      expRate = expPrice / self.item.recommandPrice - 1
      Toast(textRes.Pitch[22])
    elseif minPrice > expPrice then
      expPrice = minPrice
      expRate = expPrice / self.item.recommandPrice - 1
      Toast(textRes.Pitch[23])
    end
    local priceText = CommercePitchUtils.GetPitchColoredPriceText(expPrice)
    Label_Price:GetComponent("UILabel"):set_text(priceText)
    local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
    local str = textRes.Pitch[52]
    local tmpPercent = (1 + expRate) * 100
    tmpPercent, _ = math.modf(tmpPercent / 1)
    local textColor = Color.white
    if tmpPercent > 100 then
      local tmp = tmpPercent - 100
      str = str .. "+" .. tmp .. "%"
      textColor = Color.red
    elseif tmpPercent < 100 then
      local tmp = 100 - tmpPercent
      str = str .. "-" .. tmp .. "%"
      textColor = Color.green
    end
    Label_PriceCompare:GetComponent("UILabel"):set_text(str)
    Label_PriceCompare:GetComponent("UILabel"):set_textColor(textColor)
    self.item.percent = expRate
    self.item.tmpPrice = expPrice
    local Group_Tax = Group_Right:FindDirect("Group_Tax")
    local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
    local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
    local serviceMoney, _ = math.modf(expPrice * 0.05 * self.item.item.number)
    Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  elseif minRate > expRate then
    Toast(textRes.Pitch[16])
  elseif maxRate < expRate then
    Toast(textRes.Pitch[15])
  end
end
def.method().OnOffShelfClick = function(self)
  CommercePitchProtocol.CGetSellItemReq(self.item.shoppingid, self.item.item.id)
end
def.method().OnOnShelfAgainClick = function(self)
  if self.item == nil or self.item.item == nil or self.item.item.number <= 0 then
    Toast(textRes.Pitch[34])
    return
  end
  local serviceMoney = self.item.price * 0.05 * self.item.item.number
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(serviceMoney) then
    Toast(textRes.Pitch[26])
    return
  end
  CommercePitchProtocol.CReSellExpireItemReq(self.item.shoppingid, self.item.item.id, self.item.tmpPrice)
end
def.method().ShowServiceTips = function(self)
  local tipsId = CommercePitchUtils.GetPitchServiceTipsId()
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method("userdata").ShowSelectItemTips = function(self, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local item = self.item.item
  ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_MinusIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(-rate)
  elseif "Btn_AddIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(rate)
  elseif "Btn_Free" == id then
    self:OnOffShelfClick()
    self:DestroyPanel()
    self = nil
  elseif "Btn_Retry" == id then
    self:OnOnShelfAgainClick()
    self:DestroyPanel()
    self = nil
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Btn_Tips" == id then
    self:ShowServiceTips()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  elseif "Texture_RightIcon" == id then
    self:ShowSelectItemTips(clickobj.parent)
  elseif "Img_BgRightItem" == id then
    self:ShowSelectItemTips(clickobj)
  end
end
ItemOnShelfAgainPanel.Commit()
return ItemOnShelfAgainPanel
