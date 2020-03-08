local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local PromotionNode = Lplus.Extend(TabNode, "PromotionNode")
local GUIUtils = require("GUI.GUIUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local MysteryStoreUtil = require("Main.Mall.MysteryStoreUtil")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PageEnum = require("consts.mzm.gsp.mall.confbean.PageEnum")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local MallUtility = require("Main.Mall.MallUtility")
local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
local MysteryStoreInterface = require("Main.Mall.MysteryStoreInterface")
local def = PromotionNode.define
local instance
local G_refreshedTimes = 0
def.field("number")._shopType = 0
def.field("number")._seletGoodsIdx = 0
def.field("table")._goodsInfos = nil
def.field("table")._tblShopGoods = nil
def.field("number")._curTabState = 1
def.field("table")._tabNodes = nil
def.field("table")._uiGOs = nil
def.field("userdata")._uiRoot = nil
def.field("table")._leftTabsList = nil
def.field("table")._buyConfirmDlg = nil
def.field("boolean")._bjustRefresh = false
def.field("number")._iSpecFreeFreshNum = 0
def.field("number")._iUseSpecFreshNum = 0
def.field("boolean")._bShowRedPt = false
def.const("table").EnumTabNode = {MYSTERY_STORE = 1, COMING_SOON = 2}
def.static("=>", PromotionNode).Instance = function()
  if instance == nil then
    instance = PromotionNode()
    instance._leftTabsList = {}
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  self._uiRoot = node
  self._tabNodes = {}
  local Node = {}
  Node.Show = PromotionNode.ShowMysteryStore
  Node.Hide = PromotionNode.HideMysteryStore
  self._tabNodes[PromotionNode.EnumTabNode.MYSTERY_STORE] = Node
  Node = {}
  Node.Show = PromotionNode.ShowComingSoon
  Node.Hide = PromotionNode.HideComingSoon
  self._tabNodes[PromotionNode.EnumTabNode.COMING_SOON] = Node
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PromotionNode.OnGoldMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PromotionNode.OnYuanBaoMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PromotionNode.OnYuanBaoMoneyChanged)
  self._tblShopGoods = {}
  local leftTabs = self._uiRoot:FindDirect("Group_TabList")
  local goodsList = self._uiRoot:FindDirect("Group_GoodsList")
  local lblHaveMoney = self._uiRoot:FindDirect("Group_Money/Label_HaveNum")
  local groupMoney = self._uiRoot:FindDirect("Group_Money")
  local groupRefreshTimes = self._uiRoot:FindDirect("Group_RestTimes")
  local lblLeftItem = self._uiRoot:FindDirect("Label_LeftItem")
  local groupComingSoon = self._uiRoot:FindDirect("Group_Empty")
  local btnRefresh = self._uiRoot:FindDirect("Img_Refresh")
  self._uiGOs = {}
  self._uiGOs.leftTabs = leftTabs
  self._uiGOs.goodsList = goodsList
  self._uiGOs.lblHaveMoney = lblHaveMoney
  self._uiGOs.groupMoney = groupMoney
  self._uiGOs.groupRefreshTimes = groupRefreshTimes
  self._uiGOs.groupComingSoon = groupComingSoon
  self._uiGOs.lblLeftItem = lblLeftItem
  self._uiGOs.btnRefresh = btnRefresh
  self._uiGOs.lblTalk = self._uiRoot:FindDirect("Img_Talk/Label03")
  self._uiGOs.groupGold = self._uiRoot:FindDirect("Group_Gold")
  self._uiGOs.btnHelp = self._uiRoot:FindDirect("Btn_Help")
  self:FillLeftTabs()
  self:SwitchTo(self._curTabState, false)
  PromotionNode.SetActiveRedPt(false)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PromotionNode.OnGoldMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PromotionNode.OnYuanBaoMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PromotionNode.OnYuanBaoMoneyChanged)
  self._curTabState = 1
  self._uiGOs = nil
  self._seletGoodsIdx = 0
  self._tblShopGoods = nil
  if self._buyConfirmDlg ~= nil and self._buyConfirmDlg:IsShow() then
    self._buyConfirmDlg:HidePanel()
  end
  self._buyConfirmDlg = nil
  self._bjustRefresh = false
  self._iUseSpecFreshNum = 0
  self._iSpecFreeFreshNum = 0
end
def.method().FillLeftTabs = function(self)
  local btnList = {}
  local mallInfos = MallUtility.GetMallListByPageType(MysteryStoreInterface.PAGE_NUM)
  local roleLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  for i = 1, #mallInfos do
    local v = mallInfos[i]
    local mallCfg = MysteryStoreUtil.GetConstCfgByShopType(v.mallType)
    if roleLv >= mallCfg.minLevel then
      table.insert(btnList, v.mallType)
    end
  end
  table.sort(btnList, function(a, b)
    local cfgA = MallUtility.GetMallInfo(a)
    local cfgB = MallUtility.GetMallInfo(b)
    return cfgA.sort < cfgB.sort
  end)
  self._leftTabsList = btnList
  local tabList = self._uiGOs.leftTabs:FindDirect("Scroll View_Tab/List_Tab")
  local numTabs = #btnList + 1
  local ctrlTabLists = GUIUtils.InitUIList(tabList, numTabs)
  for i = 1, numTabs - 1 do
    local ctrl = ctrlTabLists[i]
    local lbl = ctrl:FindDirect(("Label_Tab_%d"):format(i))
    local mallInfo = MallUtility.GetMallInfo(btnList[i])
    GUIUtils.SetText(lbl, mallInfo.mallName)
  end
  local idx = numTabs
  local comingSoonGO = ctrlTabLists[idx]
  local lblTab = comingSoonGO:FindDirect(("Label_Tab_%d"):format(idx))
  GUIUtils.SetText(lblTab, textRes.Mall.MesteryStore[2])
end
local IsBind = require("consts.mzm.gsp.activity.confbean.IsBind")
def.method().UpdateGoodsList = function(self)
  local goodsList = self._uiGOs.goodsList:FindDirect("Scroll View_Goods/List_Tab")
  local numToShow = 0
  if self._goodsInfos then
    numToShow = #self._goodsInfos
  end
  local ctrlGoodsList = GUIUtils.InitUIList(goodsList, numToShow)
  local constCfg = MysteryStoreUtil.GetConstCfgByShopType(self._shopType)
  for i = 1, numToShow do
    local itemGO = ctrlGoodsList[i]
    local lblLimit = itemGO:FindDirect(("Label_ItemLimit_%d"):format(i))
    local lblName = itemGO:FindDirect(("Label_ItemName_%d"):format(i))
    local lblInnerLimit = itemGO:FindDirect(("Img_BgItem_%d/Label_%d"):format(i, i))
    local texGoods = itemGO:FindDirect(("Img_BgItem_%d/Texture_ItemIcon_%d"):format(i, i))
    local lblDiscount = itemGO:FindDirect(("Img_Sign_%d/Label_SaleNum_%d"):format(i, i))
    local lblOriPrice = itemGO:FindDirect(("Group_OriPri_%d/Label_OriPrice_%d"):format(i, i))
    local iconOri = itemGO:FindDirect(("Group_OriPri_%d/Img_Dep01_%d"):format(i, i))
    local lblCurPrice = itemGO:FindDirect(("Group_CurPri_%d/Label_CurPri_%d"):format(i, i))
    local iconCur = itemGO:FindDirect(("Group_CurPri_%d/Img_Dep02_%d"):format(i, i))
    local img_tag = itemGO:FindDirect(("Img_Sign_%d"):format(i))
    local img_SaleOut = itemGO:FindDirect(("Img_BgItem_%d/Img_SoldOut_%d"):format(i, i))
    local oneGoodsInfo = self._goodsInfos[i]
    local oneGoodsCfgInfo = MysteryStoreUtil.GetOneGoodsDataById(oneGoodsInfo.goods_id)
    local buyedNum = oneGoodsInfo.count
    local maxbuyNum = oneGoodsCfgInfo.maxbuynum
    if oneGoodsCfgInfo.maxbuyNum == -1 then
      GUIUtils.SetActive(lblInnerLimit, false)
      GUIUtils.SetActive(lblLimit, false)
    else
      GUIUtils.SetText(lblInnerLimit, oneGoodsCfgInfo.num)
      GUIUtils.SetText(lblLimit, string.format(textRes.Mall.MesteryStore[8], buyedNum, maxbuyNum))
    end
    GUIUtils.SetText(lblName, oneGoodsCfgInfo.ItemName)
    GUIUtils.SetTexture(texGoods, oneGoodsCfgInfo.icon)
    if buyedNum >= maxbuyNum then
      img_SaleOut:SetActive(true)
      GUIUtils.SetTextureEffect(texGoods:GetComponent("UITexture"), GUIUtils.Effect.Gray)
    else
      img_SaleOut:SetActive(false)
      GUIUtils.SetTextureEffect(texGoods:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    end
    local discount = oneGoodsInfo.sale / 10000
    if discount >= 1 then
      img_tag:SetActive(false)
    else
      img_tag:SetActive(true)
    end
    GUIUtils.SetText(lblDiscount, string.format(textRes.Mall.MesteryStore[7], discount * 10))
    GUIUtils.SetText(lblOriPrice, oneGoodsCfgInfo.price)
    local moneyData = CurrencyFactory.Create(oneGoodsCfgInfo.money_type)
    GUIUtils.SetSprite(iconOri, moneyData:GetSpriteName())
    local curPrice = math.floor(oneGoodsCfgInfo.price * discount)
    GUIUtils.SetText(lblCurPrice, curPrice)
    GUIUtils.SetSprite(iconCur, moneyData:GetSpriteName())
    local bang = itemGO:FindDirect("Img_Bang_" .. i)
    local zhuan = itemGO:FindDirect("Img_Zhuan_" .. i)
    local rarity = itemGO:FindDirect("Img_Xiyou_" .. i)
    if bang and zhuan then
      if oneGoodsCfgInfo.is_bind == IsBind.YES_BIND then
        bang:SetActive(true)
        zhuan:SetActive(false)
        GUIUtils.SetActive(rarity, false)
      else
        bang:SetActive(false)
        zhuan:SetActive(false)
        GUIUtils.SetActive(rarity, false)
      end
    end
    local showDiscountVal = discount * 10
    local background = itemGO:FindDirect(("Img_BgItemList_%d"):format(i))
    if showDiscountVal <= constCfg.addEffectThreshold then
      GUIUtils.SetLightEffect(background, GUIUtils.Light.Square)
    else
      GUIUtils.SetLightEffect(background, GUIUtils.Light.None)
    end
    local tag_sprite = "01"
    if showDiscountVal <= constCfg.line1 then
      tag_sprite = string.format("%02d", constCfg.tag_img1 or 1)
    elseif showDiscountVal <= constCfg.line2 then
      tag_sprite = string.format("%02d", constCfg.tag_img2 or 1)
    elseif showDiscountVal <= constCfg.line3 then
      tag_sprite = string.format("%02d", constCfg.tag_img3 or 1)
    else
      tag_sprite = string.format("%02d", constCfg.tag_img1 or 1)
    end
    GUIUtils.SetSprite(img_tag, "Img_Sign" .. tag_sprite)
  end
  GUIUtils.SetText(self._uiGOs.lblTalk, constCfg.min_discount or 0)
  self:UpdateUIOwnedYuanbao()
end
def.method("=>", "number").GetRefreshedTimes = function(self)
  return G_refreshedTimes
end
def.method("number", "=>", "userdata").GetMoneyNumByType = function(self, mtype)
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    warn(">>>mtype" .. mtype, " enum ignot = " .. MoneyType.GOLD_INGOT)
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.method().UpdateUIOwnedYuanbao = function(self)
  local moneyData = CurrencyFactory.Create(MoneyType.YUANBAO)
  local moneyNum = self:GetMoneyNumByType(MoneyType.YUANBAO)
  local icon = self._uiGOs.groupMoney:FindDirect("Img_MoneyIcon")
  local lbl = self._uiGOs.groupMoney:FindDirect("Label_HaveNum")
  GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
  GUIUtils.SetText(lbl, Int64.ToNumber(moneyNum))
  self:UpdateUIOwnedGold()
end
def.method().UpdateUIOwnedGold = function(self)
  local moneyData = CurrencyFactory.Create(MoneyType.GOLD)
  local moneyNum = self:GetMoneyNumByType(MoneyType.GOLD)
  local icon = self._uiGOs.groupGold:FindDirect("Img_GoldIcon")
  local lbl = self._uiGOs.groupGold:FindDirect("Label_HaveNum")
  GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
  GUIUtils.SetText(lbl, Int64.ToNumber(moneyNum))
end
def.method().UpdateUIRefreshTimes = function(self)
  local lbl = self._uiGOs.groupRefreshTimes:FindDirect("Label_RestNum")
  local constCfg = MysteryStoreUtil.GetConstCfgByShopType(self._shopType)
  local refreshedTimes = self:GetRefreshedTimes()
  local lblRefresh = self._uiGOs.btnRefresh:FindDirect("Label_Name")
  local iconMoneyParent = self._uiGOs.btnRefresh:FindDirect("Group_Dep")
  iconMoneyParent:SetActive(true)
  iconMoneyParent:FindDirect("Label_CurPri"):SetActive(false)
  iconMoneyParent:FindDirect("Label_Name"):SetActive(false)
  local iconMoney = iconMoneyParent:FindDirect("Img_MoneyIcon")
  local refreshCostCfg = MysteryStoreUtil.GetRefreshCostCfgById(refreshedTimes + 1)
  local leftSpecTimes = self._iSpecFreeFreshNum - self._iUseSpecFreshNum
  if refreshCostCfg.moneyNum == 0 or leftSpecTimes > 0 then
    GUIUtils.EnableButton(self._uiGOs.btnRefresh, true)
    iconMoney:SetActive(false)
    GUIUtils.SetText(lblRefresh, textRes.Mall.MesteryStore[11])
    if leftSpecTimes > 0 then
      GUIUtils.SetLightEffect(self._uiGOs.btnRefresh, GUIUtils.Light.Square)
    else
      GUIUtils.SetLightEffect(self._uiGOs.btnRefresh, GUIUtils.Light.None)
    end
  else
    GUIUtils.SetLightEffect(self._uiGOs.btnRefresh, GUIUtils.Light.None)
    if refreshCostCfg.moneyType ~= nil then
      local moneyData = CurrencyFactory.Create(refreshCostCfg.moneyType)
      local moneyTypeName = moneyData:GetName()
      iconMoney:SetActive(true)
      GUIUtils.SetSprite(iconMoney, moneyData:GetSpriteName())
      GUIUtils.SetText(lblRefresh, textRes.Mall.MesteryStore[12]:format(refreshCostCfg.moneyNum, ""))
    end
  end
  if refreshedTimes == -1 then
    GUIUtils.SetText(lbl, "--")
  else
    GUIUtils.SetText(lbl, constCfg.dailyMaxRefresTimes - refreshedTimes)
  end
  if refreshedTimes >= constCfg.dailyMaxRefresTimes and leftSpecTimes <= 0 then
    iconMoneyParent:SetActive(false)
    GUIUtils.EnableButton(self._uiGOs.btnRefresh, false)
    GUIUtils.SetText(lblRefresh, textRes.Mall.MesteryStore[14])
    GUIUtils.SetLightEffect(self._uiGOs.btnRefresh, GUIUtils.Light.None)
  else
    GUIUtils.EnableButton(self._uiGOs.btnRefresh, true)
    iconMoneyParent:SetActive(true)
  end
end
def.method("boolean").UpdateUIMysteryStore = function(self, bShow)
  self._uiGOs.goodsList:SetActive(bShow)
  self._uiGOs.lblLeftItem:SetActive(bShow)
  self._uiGOs.groupRefreshTimes:SetActive(bShow)
  self._uiGOs.btnRefresh:SetActive(bShow)
  self._uiGOs.groupMoney:SetActive(bShow)
  self._uiGOs.groupGold:SetActive(bShow)
  self._uiGOs.btnHelp:SetActive(bShow)
  self:UpdateGoodsList()
end
def.method("boolean").UpdateUIComingSoon = function(self, bShow)
  self._uiGOs.groupComingSoon:SetActive(bShow)
end
def.method("number", "boolean").SwitchTo = function(self, idx, bNeedRefresh)
  self:SetCurState(idx)
  local uiToggle = self._uiGOs.leftTabs:FindDirect(("Scroll View_Tab/List_Tab/Tab_BD_%d"):format(idx))
  if uiToggle ~= nil then
    uiToggle:GetComponent("UIToggle"):set_value(true)
  end
  local countShopType = #self._leftTabsList
  if idx <= countShopType then
    local mallInfo = MallUtility.GetMallInfo(self._leftTabsList[idx] or 0)
    if self._tblShopGoods[mallInfo.mallType] == nil or bNeedRefresh then
      self._shopType = mallInfo.mallType
      self._goodsInfos = nil
      G_refreshedTimes = -1
      PromotionNode.SendReqMysteryShopInfo(mallInfo.mallType)
    else
      self._goodsInfos = self._tblShopGoods[mallInfo.mallType]
    end
  end
  if self._tabNodes == nil then
    return
  end
  if idx <= countShopType then
    idx = PromotionNode.EnumTabNode.MYSTERY_STORE
  else
    idx = PromotionNode.EnumTabNode.COMING_SOON
  end
  for k, v in pairs(self._tabNodes) do
    if k == idx then
      v.Show()
    else
      v.Hide()
    end
  end
end
def.method().RepullGoodsList = function(self)
  self._tblShopGoods = {}
  self:SwitchTo(self._curTabState, true)
end
def.static().ShowMysteryStore = function()
  local self = PromotionNode.Instance()
  if self._uiGOs == nil then
    return
  end
  self:UpdateUIMysteryStore(true)
end
def.static().HideMysteryStore = function()
  local self = PromotionNode.Instance()
  if self._uiGOs == nil then
    return
  end
  self:UpdateUIMysteryStore(false)
end
def.static().ShowComingSoon = function()
  local self = PromotionNode.Instance()
  if self._uiGOs == nil then
    return
  end
  self:UpdateUIComingSoon(true)
end
def.static().HideComingSoon = function()
  local self = PromotionNode.Instance()
  if self._uiGOs == nil then
    return
  end
  self:UpdateUIComingSoon(false)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Tab_BD_%d") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    self:SwitchTo(idx, false)
  elseif id == "Img_Refresh" then
    if self._iSpecFreeFreshNum > self._iUseSpecFreshNum then
      CommonConfirmDlg.ShowConfirm(textRes.Mall.MesteryStore[1], textRes.Mall.MesteryStore[15], function(select)
        if select == 1 then
          PromotionNode.SendSpecFreeRefreshReq(self._shopType)
        end
      end, nil)
    else
      self:OnBtnRefreshClick()
    end
  elseif id == "Btn_AddYuanbao" then
    self:OnBtnBuyYuanbaoClick()
  elseif id == "Btn_AddGold" then
    self:GotoBuyMoney(MoneyType.GOLD, false)
  elseif id == "Btn_Help" then
    local tipsID = MysteryStoreUtil.GetConstCfgByShopType(self._shopType).hoverTipsId
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  elseif id == "Img_MoneyIcon" then
    require("Main.Item.ItemModule").Instance():ShowYuanbaoDetail(1)
  elseif string.find(id, "Img_BgItemList_%d") ~= nil then
    if self._goodsInfos == nil then
      return
    end
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    self:OnGoodsItemClick(idx, clickobj)
  end
end
def.method("number").SetCurState = function(self, state)
  self._curTabState = state
end
def.method().OnBtnRefreshClick = function(self)
  local constCfg = MysteryStoreUtil.GetConstCfgByShopType(self._shopType)
  local refreshedTimes = self:GetRefreshedTimes()
  if refreshedTimes >= constCfg.dailyMaxRefresTimes then
    Toast(textRes.Mall.MesteryStore[3])
    return
  end
  local refreshCostCfg = MysteryStoreUtil.GetRefreshCostCfgById(refreshedTimes + 1)
  if refreshCostCfg.moneyType == nil then
    return
  end
  local moneyData = CurrencyFactory.Create(refreshCostCfg.moneyType)
  local moneyTypeName = moneyData:GetName()
  local ownedMoneyNum = self:GetMoneyNumByType(refreshCostCfg.moneyType)
  if Int64.lt(ownedMoneyNum, refreshCostCfg.moneyNum) then
    local content = string.format(textRes.Mall.MesteryStore[5], moneyTypeName)
    CommonConfirmDlg.ShowConfirm(textRes.Mall.MesteryStore[1], content, function(select)
      if select == 1 then
        local mtype = refreshCostCfg.moneyType
        self:GotoBuyMoney(mtype, false)
      end
    end, nil)
  else
    local content = ""
    if refreshCostCfg.moneyNum <= 0 then
      ownedMoneyNum = Int64.new(0)
      content = string.format(textRes.Mall.MesteryStore[13], constCfg.dailyMaxRefresTimes - refreshedTimes)
    else
      content = string.format(textRes.Mall.MesteryStore[4], constCfg.dailyMaxRefresTimes - refreshedTimes, refreshCostCfg.moneyNum, moneyTypeName)
    end
    CommonConfirmDlg.ShowConfirm(textRes.Mall.MesteryStore[1], content, function(select)
      if select == 1 then
        PromotionNode.SendReqRefreshMysteryShop(self._shopType, refreshCostCfg.moneyType, ownedMoneyNum)
      end
    end, nil)
  end
end
def.method("number", "boolean").GotoBuyMoney = function(self, mtype, bconfirm)
  if mtype == MoneyType.YUANBAO then
    if bconfirm then
      _G.GotoBuyYuanbao()
    else
      self:OnBtnBuyYuanbaoClick()
    end
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
def.method().OnBtnBuyYuanbaoClick = function(self)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
def.method("number", "userdata").OnGoodsItemClick = function(self, idx, source)
  self._seletGoodsIdx = idx
  local goodsInfo = self._goodsInfos[self._seletGoodsIdx]
  local oneGoodsCfgInfo = MysteryStoreUtil.GetOneGoodsDataById(goodsInfo.goods_id)
  local numCanBuy = oneGoodsCfgInfo.maxbuynum
  if numCanBuy == -1 then
  else
    numCanBuy = oneGoodsCfgInfo.maxbuynum - goodsInfo.count
  end
  if numCanBuy ~= -1 and numCanBuy <= 0 then
    Toast(textRes.Mall.MesteryStore[10])
    return
  end
  local param = {}
  param.id = oneGoodsCfgInfo.itemId
  param.icon = oneGoodsCfgInfo.icon
  param.name = oneGoodsCfgInfo.ItemName
  param.typeName = oneGoodsCfgInfo.itemTypeName
  param.level = oneGoodsCfgInfo.useLevel
  param.desc = oneGoodsCfgInfo.desc
  local discount = goodsInfo.sale / 10000
  param.price = math.floor(oneGoodsCfgInfo.price * discount)
  param.moneyIcon = CurrencyFactory.Create(oneGoodsCfgInfo.money_type):GetSpriteName()
  param.numToBuy = 1
  param.avaliableNum = numCanBuy
  param.numItems = oneGoodsCfgInfo.num
  param.funcCaculateTotalPrice = PromotionNode.CaculateTotal
  param.buyCallback = PromotionNode.OnBuyGoodsCallback
  local UIBuyConfirmPanel = require("Main.Mall.ui.UIBuyConfirmPanel")
  self._buyConfirmDlg = UIBuyConfirmPanel.Instance()
  self._buyConfirmDlg:ShowPanel(param)
end
def.static("number").OnBuyGoodsCallback = function(buyNum)
  local self = PromotionNode.Instance()
  if self._uiGOs == nil or self._seletGoodsIdx == 0 then
    return
  end
  if self._bjustRefresh then
    Toast(textRes.Mall.MesteryStore[9])
    self._bjustRefresh = false
    return
  end
  local goodsInfo = self._goodsInfos[self._seletGoodsIdx]
  local goodsCfgInfo = MysteryStoreUtil.GetOneGoodsDataById(goodsInfo.goods_id)
  local moneyType = goodsCfgInfo.money_type
  local moneyNum = self:GetMoneyNumByType(moneyType)
  local needMoney = PromotionNode.CaculateTotal(buyNum)
  if Int64.lt(moneyNum, needMoney) then
    self:GotoBuyMoney(moneyType, true)
  else
    PromotionNode.SendBuyMysteryGoodsReq(self._shopType, self._seletGoodsIdx, goodsInfo.goods_id, buyNum, moneyType, moneyNum)
  end
end
def.static("number", "=>", "number").CaculateTotal = function(num)
  local self = PromotionNode.Instance()
  local goodsInfo = self._goodsInfos[self._seletGoodsIdx]
  local goodsCfgInfo = MysteryStoreUtil.GetOneGoodsDataById(goodsInfo.goods_id)
  local realPrice = math.floor(goodsInfo.sale / 10000 * goodsCfgInfo.price * num)
  return realPrice
end
def.static("table", "table").OnGoldMoneyChanged = function(p, c)
  local self = PromotionNode.Instance()
  self:UpdateUIOwnedGold()
end
def.static("table", "table").OnYuanBaoMoneyChanged = function(p, c)
  local self = PromotionNode.Instance()
  self:UpdateUIOwnedYuanbao()
end
def.static("=>", "boolean").IsActiveRedPt = function()
  local self = PromotionNode.Instance()
  return self._bShowRedPt
end
def.static("boolean").SetActiveRedPt = function(bActive)
  local self = PromotionNode.Instance()
  self._bShowRedPt = bActive
  Event.DispatchEvent(ModuleId.PAY, gmodule.notifyId.Pay.RECHARTE_RETURN_STATUS, nil)
end
def.static("table", "table").OnActReset = function(p, context)
end
def.static("number", "number", "number", "number", "number", "userdata").SendBuyMysteryGoodsReq = function(shopType, goods_index, goods_id, count, money_type, ownedYB)
  warn(">>>>Send BuyMysteryGoodsReq<<<<")
  local p = require("netio.protocol.mzm.gsp.mysteryshop.CBuyMysteryGoodsReq").new(shopType, goods_index, goods_id, count, money_type, ownedYB)
  gmodule.network.sendProtocol(p)
end
def.static("number").SendReqMysteryShopInfo = function(shopType)
  warn(">>>>Send ReqMysteryShopInfo<<<<")
  local p = require("netio.protocol.mzm.gsp.mysteryshop.CReqMysteryShopInfo").new(shopType)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "userdata").SendReqRefreshMysteryShop = function(shopType, mtype, ownedYB)
  warn(">>>>Send ReqRefreshMysteryShop")
  local p = require("netio.protocol.mzm.gsp.mysteryshop.CReqRefreshMysteryShop").new(shopType, mtype, ownedYB)
  gmodule.network.sendProtocol(p)
end
def.static("number").SendSpecFreeRefreshReq = function(shoptype)
  warn(">>>>Send CReqRefreshMysteryShopFree")
  local p = require("netio.protocol.mzm.gsp.mysteryshop.CReqRefreshMysteryShopFree").new(shoptype)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSMysteryGoodsChangeInfo = function(p)
  warn(">>>>rcv SMysteryGoodsChangeInfo")
  local self = PromotionNode.Instance()
  self._tblShopGoods = self._tblShopGoods or {}
  self._tblShopGoods[p.shoptype] = self._tblShopGoods[p.shoptype] or {}
  local goodsList = self._tblShopGoods[p.shoptype]
  local goods_index = p.goods_index + 1
  if goodsList[goods_index] == nil then
    goodsList[goods_index] = {}
  end
  local goodsInfo = goodsList[goods_index]
  goodsInfo.goods_id = p.goods_id
  goodsInfo.shoptype = p.shoptype
  goodsInfo.count = p.count
  if self._uiGOs ~= nil then
    self:SwitchTo(self._curTabState, false)
  end
end
def.static("table").OnSMysteryShopErrorInfo = function(p)
  if p.error_code == 1 then
    warn(">>>>BUY_PAY_NOT_ENOUGH<<<<<")
  elseif p.error_code == 2 then
    warn(">>>>REFRESH_PAY_NOT_ENOUGH<<<<<")
  elseif p.error_code == 3 then
    warn(">>>>REFRESH_TIMES_NOT_ENOUGH<<<<<")
  elseif p.error_code == 4 then
    warn(">>>>GOODS_NOT_EXIST<<<<<")
  elseif p.error_code == 5 then
    warn(">>>>GOODS_BUY_COUNT_E\tRROR<<<<<")
  elseif p.error_code == 6 then
    warn(">>>>NO_FREE_TIMES_ERROR<<<<")
  end
end
local G_canRefreshTimes = -1
def.static("table").OnSResMysteryShopInfo = function(p)
  warn(">>>>rcv server OnSResMysteryShopInfo")
  local self = PromotionNode.Instance()
  self._shopType = p.shoptype
  self._tblShopGoods = self._tblShopGoods or {}
  self._tblShopGoods[p.shoptype] = p.goods_list
  G_refreshedTimes = p.refresh_times
  self._iSpecFreeFreshNum = p.can_free_refresh_times
  self._iUseSpecFreshNum = p.used_free_refresh_times
  local maxSpecRefreshTimes = MysteryStoreUtil.GetConstCfgByShopType(self._shopType).specRefreshMaxTimes
  if G_canRefreshTimes ~= -1 and self._iSpecFreeFreshNum ~= G_canRefreshTimes then
    Toast(textRes.Mall.MesteryStore[16])
  end
  G_canRefreshTimes = self._iSpecFreeFreshNum
  if maxSpecRefreshTimes <= self._iUseSpecFreshNum then
    Toast(textRes.Mall.MesteryStore[17])
  end
  if self._uiGOs == nil then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local nowSec = _G.GetServerTime()
    local date = AbsoluteTimer.GetServerTimeTable(nowSec)
    if date.hour == 0 and date.min == 0 then
      PromotionNode.SetActiveRedPt(true)
    end
    return
  end
  if self._buyConfirmDlg ~= nil and self._buyConfirmDlg:IsShow() then
    self._bjustRefresh = true
  else
    self._bjustRefresh = false
  end
  self:SwitchTo(self._curTabState, false)
  self:UpdateUIRefreshTimes()
end
return PromotionNode.Commit()
