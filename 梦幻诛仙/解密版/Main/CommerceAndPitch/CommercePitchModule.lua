local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CommercePitchModule = Lplus.Extend(ModuleBase, "CommercePitchModule")
require("Main.module.ModuleId")
local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
local MallPanel = require("Main.Mall.ui.MallPanel")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
local def = CommercePitchModule.define
local instance
def.field(CommercePitchPanel)._dlg = nil
def.field(MallPanel)._dlg1 = nil
def.field(PitchData)._pitchData = nil
def.field(CommerceData)._commerceData = nil
def.field("boolean")._bIsByTask = false
def.field("number")._npcId = 0
def.field("table")._curRequirementByTask = nil
def.field("boolean")._bWaitToShow = false
def.field("number").lastCommerceBigGroup = 0
def.field("table").lastCommerceSmallGroup = nil
def.field("string").lastCommerceGroupInfo = ""
def.field("number").selectCommerceItemId = 0
def.field("number").lastPitchBigGroup = 0
def.field("table").lastPitchSmallGroup = nil
def.field("string").lastPitchGroupInfo = ""
def.field("number").selectPitchItemId = 0
def.field("table").selectPitchItemIds = nil
def.field("number").waitToShowState = 1
def.field("function").afterShowCallback = nil
def.field("boolean").showByTask = false
def.static("=>", CommercePitchModule).Instance = function()
  if nil == instance then
    instance = CommercePitchModule()
    instance._dlg = CommercePitchPanel.Instance()
    instance._dlg1 = MallPanel.Instance()
    instance._pitchData = PitchData.Instance()
    instance._commerceData = CommerceData.Instance()
  end
  return instance
end
def.override().Init = function(self)
  self.selectPitchItemIds = {}
  Timer:RegisterIrregularTimeListener(self.Update, self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SSyncMyShopingItem", CommercePitchModule.OnSSyncMyShopingItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SBuyItemRes", CommercePitchModule.OnBuyItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SSellItemRes", CommercePitchModule.OnSellItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SGetSellItemRes", CommercePitchModule.OnOffShelfItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SCommonResultRes", CommercePitchModule.OnCommonResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SSyncSellItemNotify", CommercePitchModule.OnSellItemNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SReSellExpireItemRes", CommercePitchModule.OnOverDateItemOnShelf)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SGetMoneyRes", CommercePitchModule.OnGetMoneyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SSyncItemExpire", CommercePitchModule.OnSellItemOverDateNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SUnlockGridRes", CommercePitchModule.OnUnlockGridRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SRecommendPriceChangeRes", CommercePitchModule.OnSSyncRecommandPriceChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SQueryItemRes", CommercePitchModule.OnSQueryItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSiftItemRes", CommercePitchModule.SSiftItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SFuMoSkillPreviewRes", CommercePitchModule.OnSFuMoSkillPreviewRes)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TRADING_CENTER_CLICK, CommercePitchModule._onShow)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, CommercePitchModule.OnNPCService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, CommercePitchModule.OnNPCServiceByTask)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SSyncShopingList", CommercePitchModule.OnSyncCommerceInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SBuyItemRes", CommercePitchModule.OnSucceedBuyCommerceItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SCommonResultRes", CommercePitchModule.OnCommerceCommonResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SSellItemRes", CommercePitchModule.OnCommerceSellItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SGetSellItemPriceRes", CommercePitchModule.OnCommerceGetSellItemPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SSyncBanShopingList", CommercePitchModule.OnSSyncBanShopingList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanghui.SGetShangHuiItemCalParams", CommercePitchModule.OnSGetShangHuiItemCalParams)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_Commerce, CommercePitchModule.OnSellToCommerce)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_All_To_Commerce, CommercePitchModule.OnSellAllToCommerce)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_Pitch, CommercePitchModule.OnSellToPitch)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_TradingArcade, CommercePitchModule.OnSellToTradingArcade)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommercePitchModule._onBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, CommercePitchModule._itemMoneySilverChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, CommercePitchModule._itemMoneyGoldChanged)
  CommercePitchProtocol.Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self._pitchData:SetAllNull()
  self._commerceData:SetAllNull()
  self._bIsByTask = false
  self._npcId = 0
  self._curRequirementByTask = nil
  self._bWaitToShow = false
  self.lastCommerceBigGroup = 0
  self.lastCommerceSmallGroup = nil
  self.lastCommerceGroupInfo = ""
  self.selectCommerceItemId = 0
  self.lastPitchBigGroup = 0
  self.lastPitchSmallGroup = nil
  self.lastPitchGroupInfo = ""
  self.selectPitchItemId = 0
  self.waitToShowState = 1
  self.afterShowCallback = nil
  self.showByTask = false
end
def.static("table").OnSFuMoSkillPreviewRes = function(p)
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.FUMO_SKILL_PREVIEW_RES, {
    p.skillId,
    p.needVigor,
    p.itemId
  })
end
def.method("number", "number").CommerceBuyItemBySmallGroup = function(self, smallGroupId, itemId)
  local big, small = self._commerceData:GetGroupIndexBySmallGroupId(smallGroupId)
  self.lastCommerceBigGroup = big
  self.lastCommerceSmallGroup = {}
  self.lastCommerceSmallGroup.big = big
  self.lastCommerceSmallGroup.small = small
  self.lastCommerceGroupInfo = self.lastCommerceSmallGroup.big .. "_" .. self.lastCommerceSmallGroup.small
  self.selectCommerceItemId = itemId
  CommercePitchModule.Instance().showByTask = false
  CommercePitchModule.RequireToShowPanel(MallPanel.StateConst.Commerce)
  self.waitToShowState = MallPanel.StateConst.Commerce
end
def.method("number", "number").PitchBuyItemSmallGroup = function(self, smallGroupId, itemId)
  self:PitchBuyItemSmallGroupWithIdList(smallGroupId, {itemId})
end
def.method("number", "table").PitchBuyItemSmallGroupWithIdList = function(self, smallGroupId, itemIdList)
  local big, small = self._pitchData:GetGroupIndexBySmallGroupId(smallGroupId)
  self.lastPitchBigGroup = big
  self.lastPitchSmallGroup = {}
  self.lastPitchSmallGroup.big = big
  self.lastPitchSmallGroup.small = small
  self.lastPitchGroupInfo = self.lastPitchSmallGroup.big .. "_" .. self.lastPitchSmallGroup.small
  local itemIdMap = {}
  for i, v in ipairs(itemIdList) do
    itemIdMap[v] = true
  end
  self.selectPitchItemId = itemIdList[1] or 0
  self.selectPitchItemIds = itemIdMap
  CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.Pitch)
  self.waitToShowState = CommercePitchPanel.StateConst.Pitch
end
def.method("number", "number").CommerceBuyItemByBigGroup = function(self, bigGroupId, itemId)
  self.lastCommerceBigGroup = self._commerceData:GetBigGroupIndexByBigGroupId(bigGroupId)
  self.lastCommerceSmallGroup = {}
  self.lastCommerceSmallGroup.big = self.lastCommerceBigGroup
  self.lastCommerceSmallGroup.small = 0
  self.lastCommerceGroupInfo = self.lastCommerceSmallGroup.big .. "_" .. self.lastCommerceSmallGroup.small
  self.selectCommerceItemId = itemId
  CommercePitchModule.RequireToShowPanel(MallPanel.StateConst.Commerce)
  self.waitToShowState = MallPanel.StateConst.Commerce
end
def.method("number", "number", "number").ComemrceBuyItemByBigSmallIndex = function(self, bigIndex, smallIndex, itemId)
  self.lastCommerceBigGroup = bigIndex
  self.lastCommerceSmallGroup = {}
  self.lastCommerceSmallGroup.big = self.lastCommerceBigGroup
  self.lastCommerceSmallGroup.small = smallIndex
  self.lastCommerceGroupInfo = self.lastCommerceSmallGroup.big .. "_" .. self.lastCommerceSmallGroup.small
  self.selectCommerceItemId = itemId
  CommercePitchModule.RequireToShowPanel(MallPanel.StateConst.Commerce)
  self.waitToShowState = MallPanel.StateConst.Commerce
end
def.method("number", "number").PitchBuyItemBigGroup = function(self, bigGroupId, itemId)
  self:PitchBuyItemBigGroupWithIdList(bigGroupId, {itemId})
end
def.method("number", "table").PitchBuyItemBigGroupWithIdList = function(self, bigGroupId, itemIdList)
  self.lastPitchBigGroup = self._pitchData:GetBigGroupIndexByBigGroupId(bigGroupId)
  self.lastPitchSmallGroup = {}
  self.lastPitchSmallGroup.big = self.lastPitchBigGroup
  self.lastPitchSmallGroup.small = 0
  self.lastPitchGroupInfo = self.lastPitchSmallGroup.big .. "_" .. self.lastPitchSmallGroup.small
  local itemIdMap = {}
  for i, v in ipairs(itemIdList) do
    itemIdMap[v] = true
  end
  self.selectPitchItemId = itemIdList[1] or 0
  self.selectPitchItemIds = itemIdMap
  CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.Pitch)
  self.waitToShowState = CommercePitchPanel.StateConst.Pitch
end
def.static("number").RequireToShowPanel = function(stateId)
  local data = instance._pitchData
  data:UpdateSellList()
  if stateId == MallPanel.StateConst.Commerce then
    MallPanel.Instance():ShowPanel(stateId, instance.selectPitchItemId, 0)
  else
    CommercePitchPanel.ShowCommercePitchPanel(stateId)
  end
end
def.static("table").TradingArcadeBuy = function(params)
  if require("Main.TradingArcade.TradingArcadeUtils").CheckOpen() == false then
    return
  end
  CommercePitchModule.Instance().afterShowCallback = function()
    CommercePitchPanel.TradingArcadeBuy(params)
  end
  CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.TradingArcade)
  instance.waitToShowState = CommercePitchPanel.StateConst.TradingArcade
end
def.static("table", "table")._onBagInfoSyncronized = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdateBag()
  end
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
    instance._dlg1:UpdateBag()
  end
end
def.static("table", "table")._itemMoneySilverChanged = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    instance._dlg:UpdateSilverMoney()
  end
end
def.static("table", "table")._itemMoneyGoldChanged = function(p1, p2)
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil then
    instance._dlg1:UpdateGoldMoney()
  end
end
def.static("table", "table")._onShow = function(p1, p2)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if instance._dlg.m_panel == nil then
    local state = CommercePitchPanel.Instance().state
    if state == CommercePitchPanel.StateConst.TradingArcade and not require("Main.TradingArcade.TradingArcadeUtils").CheckOpenEx(true) then
      state = CommercePitchPanel.StateConst.Pitch
    end
    CommercePitchModule.RequireToShowPanel(state)
    instance.waitToShowState = state
    CommercePitchPanel.Instance().bOpenDefault = false
  else
    instance._dlg:DestroyPanel()
  end
end
def.static("table").OnSyncCommerceInfo = function(p)
  local data = instance._commerceData
  for k, v in pairs(p.shoppingItemList) do
    data:UpdateItemInfo(v)
  end
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:RefreshCommerceItemsInfo()
  end
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
    instance._dlg1:RefreshCommerceItemsInfo()
  end
  data:SetOnceFinished(true)
  data:SetRefeshTime(GetServerTime())
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_ITEM_PRICE_CHANGE, nil)
end
def.static("table").OnCommerceCommonResultRes = function(p)
  local SCommonResultRes = require("netio.protocol.mzm.gsp.shanghui.SCommonResultRes")
  if p.res == SCommonResultRes.ALL_SELLED or p.res == SCommonResultRes.BUY_TOO_MUCH or p.res == SCommonResultRes.BAG_FULL or p.res == SCommonResultRes.SELL_TOO_MUCH or p.res == SCommonResultRes.FALL_TOO_MUCH or p.res == SCommonResultRes.SELL_ERROR_GOLD_MAX or p.res == SCommonResultRes.GET_ITEM_ERROR_INDEX or p.res == SCommonResultRes.MULTI_BUY_OWN_TOO_MUCH or p.res == SCommonResultRes.MULTI_BUY_TOO_MUCH then
    Toast(textRes.Commerce.ErrorCode[p.res])
  else
    if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
      instance._dlg:CommerceCommonResultRes(p.res)
    end
    if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
      instance._dlg1:CommerceCommonResultRes(p.res)
    end
  end
end
def.static("table").OnSucceedBuyCommerceItem = function(p)
  local data = instance._commerceData
  data:UpdateItemInfo(p.itemInfo)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:SucceedBuyCommerceItem(p.costGold, p.canBuyNum, p.itemInfo.itemId, p.buyNum)
  end
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
    instance._dlg1:SucceedBuyCommerceItem(p.costGold, p.canBuyNum, p.itemInfo.itemId, p.buyNum)
  end
  data:UpdateItemCanBuyNum(p.itemInfo.itemId, p.canBuyNum)
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_BUY_SUCCESS, {
    itemId = p.itemInfo.itemId,
    canBuyNum = p.canBuyNum,
    buyNum = p.buyNum,
    costGold = p.costGold
  })
end
def.static("table").OnCommerceSellItemRes = function(p)
  local data = instance._commerceData
  data:UpdateItemInfo(p.itemInfo)
  MallPanel.SucceedSellBagItem(p.earnGold, p.canSellNum)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UnSelectLastSellItem()
  end
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
    instance._dlg1:UnSelectLastSellItem()
  end
end
def.static("table").OnCommerceGetSellItemPriceRes = function(p)
  MallPanel.SellToCommerceEx(p.bagid, p.itemKey, p.itemId, p.price)
end
def.static("table").OnSSyncBanShopingList = function(p)
  CommerceData.Instance():setBanItemList(p.banItemList)
  if instance._dlg1 and instance._dlg1.m_panel and false == instance._dlg1.m_panel.isnil and instance._dlg1.m_panel:get_activeInHierarchy() then
    instance._dlg1:RefreshCommerceItemsInfo()
  end
end
def.static("table").OnSGetShangHuiItemCalParams = function(p)
  warn("-----<<<<>>>>>>>OnSGetShangHuiItemCalParams:", p.itemId, p.canBuyNum, p.orgDayPrice, p.recommandPrice)
  CommerceData.Instance():SetCalcItemPriceInfo(p.itemId, p.canBuyNum, p.orgDayPrice, p.recommandPrice)
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.COMMERCE_CALC_ITEM_PRICE_INFO, {
    itemId = p.itemId
  })
end
def.static("table", "table").OnSellToCommerce = function(p1, p2)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local price = p1.shPrice or -1
  if price < 0 and p1.priceFlow then
    price = -2
  end
  MallPanel.SellToCommerce(p1.bagId, p1.itemKey, p1.itemId, price)
end
def.static("table", "table").OnSellAllToCommerce = function(p1, p2)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local price = p1.shPrice or -1
  if price < 0 and p1.priceFlow then
    price = -2
  end
  MallPanel.SellAllToCommerce(p1.bagId, p1.itemKey, p1.itemId, p1.itemNum, price)
end
def.static("table", "table").OnSellToPitch = function(p1, p2)
  if _G.CheckCrossServerAndToast() then
    return
  end
  CommercePitchModule.Instance().afterShowCallback = function()
    CommercePitchPanel.SellToPitch(p1.itemKey, p1.itemId)
  end
  CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.Pitch)
  instance.waitToShowState = CommercePitchPanel.StateConst.Pitch
end
def.static("table", "table").OnSellToTradingArcade = function(p1, p2)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if require("Main.TradingArcade.TradingArcadeUtils").CheckOpen() == false then
    return
  end
  CommercePitchModule.Instance().afterShowCallback = function()
    CommercePitchPanel.SellToTradingArcade(p1.itemKey, p1.itemId)
  end
  CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.TradingArcade)
  instance.waitToShowState = CommercePitchPanel.StateConst.TradingArcade
end
def.static("table").OnSSyncMyShopingItem = function(p)
  local data = instance._pitchData
  data:SetSellGridNum(p.shopGridSize)
  data:SetSellListEmpty()
  for k, v in pairs(p.MyShoppingItemList) do
    data:AddSellItem(v)
  end
end
def.static("table").OnSQueryItemRes = function(p)
  local data = instance._pitchData
  data:SetShoppingItemInfo(p.index, p.iteminfo)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:ShowPitchItemTips(p.index, p.iteminfo)
  end
end
def.static("table").OnOffShelfItemRes = function(p)
  local data = instance._pitchData
  data:RemoveSellItem(p.shoppingid)
  local num = data:GetChangedSelledItemNum()
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, {num})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    Toast(textRes.Pitch[12])
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").OnCommonResultRes = function(p)
  if p.UNLOCK_GRID_NEED_MORE_YUANBAO == p.res then
    _G.GotoBuyYuanbao()
    return
  end
  local text = textRes.Pitch.SCommonResultRes[p.res]
  if text then
    Toast(text)
  else
    warn(string.format("OnCommonResultRes p.res=%d not handle", p.res))
  end
end
def.static("table").OnSellItemNotify = function(p)
  local data = instance._pitchData
  data:SellItemShowOff(p.shoppingid, p.sellNum, p.num)
  local num = data:GetChangedSelledItemNum()
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, {num})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchSellList()
  end
  local itemInfo = data:GetOnSellItem(p.shoppingid)
  if itemInfo == nil then
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemId = itemInfo.item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase == nil then
    return
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local text = string.format(textRes.Pitch[30], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  Toast(text)
end
def.static("table").OnOverDateItemOnShelf = function(p)
  local data = instance._pitchData
  data:SellItemOnShelfAgain(p.shoppingid, p.price)
  local num = data:GetChangedSelledItemNum()
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, {num})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").OnSellItemRes = function(p)
  local data = instance._pitchData
  data:AddSellItem(p.myShoppingItem)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    Toast(textRes.Pitch[13])
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").OnGetMoneyRes = function(p)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Pitch[19], PersonalHelper.Type.Silver, Int64.new(p.money))
  local data = instance._pitchData
  data:UpdateItemState(p.shoppingid)
  local num = data:GetChangedSelledItemNum()
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, {num})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").OnSellItemOverDateNotify = function(p)
  local data = instance._pitchData
  data:SellItemOverDate(p.shoppingid)
  local num = data:GetChangedSelledItemNum()
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, {num})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").SSiftItemRes = function(p)
  if instance._dlg then
    instance._dlg:FillConditionItemId(p.siftCfgid, p.itemList)
  end
  if instance._dlg1 and instance.waitToShowState == MallPanel.StateConst.Commerce then
    instance._dlg1:FillConditionItemId(p.siftCfgid, p.itemList)
  end
end
def.static("table").OnBuyItemRes = function(p)
  local data = instance._pitchData
  data:UpdateShoppingItemNum(p.index, p.itemid, p.num)
  local itemInfo = data:GetShoppingInfoByIndexAndId(p.index, p.itemid)
  if itemInfo and p.buy_res == p.class.NOT_IN_SELL then
    itemInfo.isUnShelve = true
  elseif itemInfo and 0 == itemInfo.num then
    itemInfo.isSoldOut = true
  end
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:OnBuyItemRes(p)
  end
end
def.static("table").OnUnlockGridRes = function(p)
  local data = instance._pitchData
  data:SetSellGridNum(p.gridSize)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchSellList()
  end
end
def.static("table").OnSSyncRecommandPriceChange = function(p)
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.ITEM_RECOMMEND_PRICE_RES, {
    p.itemId2price
  })
end
def.method("=>", "number").GetNpcId = function(self)
  return self._npcId
end
def.method("=>", "boolean").GetIsByTask = function(self)
  return self._bIsByTask
end
def.method("=>", "table").GetCurRequirementByTask = function(self)
  return self._curRequirementByTask
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  if NPCServiceConst.PitchTask ~= tbl[1] or _G.CheckCrossServerAndToast() then
    return
  end
  local NPCID = tbl[2]
  instance._npcId = NPCID
  instance._curRequirementByTask = {}
  instance._bIsByTask = false
  if instance._dlg.m_panel == nil then
    CommercePitchPanel.Instance().stateByTask = CommercePitchPanel.StateConst.Pitch
    CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.Pitch)
    instance.waitToShowState = CommercePitchPanel.StateConst.Pitch
  end
end
def.static("number", "=>", "boolean").isCommerceItem = function(siftId)
  local curRequire = CommercePitchModule.Instance():GetCurRequirementByTask()
  if nil ~= curRequire then
    for k, v in pairs(curRequire) do
      if siftId == k then
        local needNum = v
        local itemList = {}
        local list = {siftId}
        for x, y in pairs(list) do
          table.insert(itemList, y)
        end
        local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(k)
        if 0 ~= group and 0 ~= smallGroup then
          return false
        else
          local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(k)
          if bigGroup ~= 0 then
            CommercePitchModule.Instance().selectCommerceItemId = k
            return true
          end
          for m, n in pairs(itemList) do
            local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(n)
            if 0 ~= group2 and 0 ~= smallGroup2 then
              return false
            else
              local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(n)
              if bigGroup ~= 0 then
                CommercePitchModule.Instance().selectCommerceItemId = n
                return true
              end
              local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(CommercePitchUtils.ItemIdToConditionId(n))
              if 0 ~= group2 and 0 ~= smallGroup2 then
                return false
              end
            end
          end
        end
      end
    end
  end
  return false
end
def.static("table", "table").OnNPCServiceByTask = function(tbl, p2)
  if NPCServiceConst.PitchTask ~= tbl[1] and NPCServiceConst.MallTask ~= tbl[1] or _G.CheckCrossServerAndToast() then
    return
  end
  local targetGraphID = tbl.targetGraphID
  if targetGraphID then
    local TaskInterface = require("Main.task.TaskInterface")
    local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
    local graphCfg = TaskInterface.GetTaskGraphCfg(targetGraphID)
    if graphCfg and graphCfg.taskType == TaskConsts.TASK_TYPE_TRIAL then
      instance:ShowTrialTaskQuery(tbl)
      return
    end
  end
  local NPCID = tbl[2]
  local siftId = tbl[3]
  local needNum = tbl[4]
  instance._npcId = NPCID
  instance._curRequirementByTask = {}
  instance._curRequirementByTask[siftId] = needNum
  instance._bIsByTask = true
  if NPCServiceConst.MallTask == tbl[1] then
    if instance._dlg1.m_panel == nil then
      CommercePitchPanel.Instance().stateByTask = MallPanel.StateConst.Commerce
      MallPanel.Instance().stateByTask = MallPanel.StateConst.Commerce
      CommercePitchModule.RequireToShowPanel(MallPanel.StateConst.Commerce)
      instance.waitToShowState = MallPanel.StateConst.Commerce
      CommercePitchModule.Instance().showByTask = true
      CommercePitchModule.Instance().selectCommerceItemId = siftId
    end
  elseif NPCServiceConst.PitchTask == tbl[1] then
    if CommercePitchModule.isCommerceItem(siftId) == true then
      if instance._dlg1.m_panel == nil then
        CommercePitchModule.Instance().showByTask = true
        CommercePitchPanel.Instance().stateByTask = MallPanel.StateConst.Commerce
        MallPanel.Instance().stateByTask = MallPanel.StateConst.Commerce
        CommercePitchModule.RequireToShowPanel(MallPanel.StateConst.Commerce)
        instance.waitToShowState = MallPanel.StateConst.Commerce
      end
    elseif instance._dlg.m_panel == nil then
      CommercePitchPanel.Instance().stateByTask = CommercePitchPanel.StateConst.Pitch
      CommercePitchModule.Instance().showByTask = true
      CommercePitchModule.RequireToShowPanel(CommercePitchPanel.StateConst.Pitch)
      instance.waitToShowState = CommercePitchPanel.StateConst.Pitch
    end
  end
end
def.method("number").Update = function(self, tick)
  local intervalTime = GetServerTime() - self._commerceData:GetRefeshTime()
  if self._dlg and self._dlg.m_panel and intervalTime > CommercePitchUtils.GetCommerceRequireRefeshTime() and self._commerceData:GetOnceFinished() then
    instance._dlg:RefeshCommerce()
  end
  if self._dlg1 and self._dlg1.m_panel and intervalTime > CommercePitchUtils.GetCommerceRequireRefeshTime() and self._commerceData:GetOnceFinished() then
    instance._dlg1:RefeshCommerce()
  end
  if self._dlg and self._dlg.m_panel and false == self._dlg.m_panel.isnil and self._dlg.m_panel:get_activeInHierarchy() then
    self._dlg:UpdatePitchTimeLabel()
  end
  if false == self._pitchData:GetOnceFinished() then
    return
  end
  local lastFreeTime = self._pitchData:GetLastFreeRefeshTime()
  local lastAutoTime = self._pitchData:GetLastAutoRefeshTime()
  local curTime = GetServerTime()
  local freeTime = curTime - lastFreeTime
  local autoTime = curTime - lastAutoTime
  if freeTime >= CommercePitchUtils.GetPitchFreeRefeshTime() then
    self._pitchData:SetIsFreeRefesh(true)
    if self._dlg and self._dlg.m_panel and false == self._dlg.m_panel.isnil and self._dlg.m_panel:get_activeInHierarchy() then
      self._dlg:TimeToRefeshPitch()
    end
  else
    self._pitchData:SetIsFreeRefesh(false)
  end
end
def.method("table").ShowTrialTaskQuery = function(self, params)
  local confirmDlg = require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Pitch[40], textRes.Pitch[41], textRes.Pitch[42], textRes.Pitch[43], 0, 30, function(s)
    if s == 1 then
      params.targetGraphID = nil
      CommercePitchModule.OnNPCServiceByTask(params, nil)
    elseif s == 0 then
      local TaskInterface = require("Main.task.TaskInterface")
      local graphID, taskID = params.targetGraphID, params.targetTaskID
      local endTime = TaskInterface.Instance():GetLegendTime(taskID, graphID) or Int64.new(0)
      endTime = endTime:ToNumber()
      local now = _G.GetServerTime()
      if endTime <= now then
        Toast(textRes.Task[92])
      else
        require("Main.OnHook.OnHookModule").EnterRecommendMapToOnHook()
      end
    end
  end, {
    unique = self.ShowTrialTaskQuery
  })
  if confirmDlg ~= nil then
    confirmDlg:ShowCloseBtn()
  end
end
CommercePitchModule.Commit()
return CommercePitchModule
