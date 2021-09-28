function enterMarket(para)
  para = para or {}
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Market)
  if openFlag == false then
    ShowNotifyTips(tips)
  else
    local tempView = CMarket.new(para)
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
g_Market = nil
CMarket = class("CMarket", CcsSubView)
function CMarket:ctor(para)
  para = para or {}
  local initItemType = para.initItemType
  local initViewType = para.initViewType or MarketShow_InitShow_SilverView
  local initBaitanType = para.initBaitanType or BaitanShow_InitShow_ShoppingView
  local initBaitanMainType = para.initBaitanMainType
  local initBaitanSubType = para.initBaitanSubType
  local SilverItemAutoBuy = para.SilverAutoBuy
  self.CloseFunc = para.closeFunc
  CMarket.super.ctor(self, "views/market.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_SilverMarket = {
      listener = handler(self, self.Btn_SilverMarket),
      variName = "btn_SilverMarket"
    },
    btn_CoinMarket = {
      listener = handler(self, self.Btn_CoinMarket),
      variName = "btn_CoinMarket"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_SilverMarket,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_CoinMarket,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_CoinMarket:setTitleText("铜\n钱\n货\n摊")
  self.btn_SilverMarket:setTitleText("银\n币\n市\n场")
  self.bg_Panel = self:getNode("bg_Panel")
  self.initItemType = initItemType
  self.m_initMid = para.m_mid
  self.SilverItemAutoBuy = SilverItemAutoBuy
  self.m_ShoppingPanel = nil
  self.m_StallPanel = nil
  self.m_SilverMarketPanel = nil
  self.title_p1 = self:getNode("title_p1")
  self.title_p2 = self:getNode("title_p2")
  self:ListenMessage(MsgID_MoveScene)
  g_Market = self
  if initViewType == MarketShow_InitShow_SilverView then
    self:setGroupBtnSelected(self.btn_SilverMarket)
    self:ShowSilverMarket(self.initItemType, self.SilverItemAutoBuy)
  else
    self:setGroupBtnSelected(self.btn_CoinMarket)
    self:ShowCoinMarket(initBaitanType, initItemType, initBaitanMainType, initBaitanSubType)
  end
end
function CMarket:addObjPanel(obj)
  local parent = self.bg_Panel:getParent()
  local x, y = self.bg_Panel:getPosition()
  local order = self.bg_Panel:getZOrder()
  parent:addChild(obj.m_UINode, order)
  obj:setPosition(ccp(x, y))
end
function CMarket:getShoppingPanel()
  return self.m_ShoppingPanel
end
function CMarket:getStallPanel()
  return self.m_StallPanel
end
function CMarket:getSilverMarketPanel()
  return self.m_SilverMarketPanel
end
function CMarket:ShowSilverMarket(itemId, autpbuy)
  print("CMarket:ShowSilverMarket", itemId)
  if self.m_SilverMarketPanel == nil then
    self.m_SilverMarketPanel = CMarketSilver.new(self.initItemType, autpbuy, self.m_initMid)
    self:addObjPanel(self.m_SilverMarketPanel)
  end
  if self.m_ShoppingPanel then
    self.m_ShoppingPanel:CloseSelf()
    self.m_ShoppingPanel = nil
  end
  if self.m_StallPanel then
    self.m_StallPanel:CloseSelf()
    self.m_StallPanel = nil
  end
  self.title_p1:setText("银币")
  self.title_p2:setText("市场")
end
function CMarket:ShowCoinMarket(initBaitanType, initItemId, mainItemIdex, subIndex)
  print("CMarket:ShowCoinMarket", initItemId, mainItemIdex, subIndex)
  initBaitanType = initBaitanType or BaitanShow_InitShow_ShoppingView
  if initBaitanType == BaitanShow_InitShow_ShoppingView then
    if self.m_ShoppingPanel == nil then
      self.m_ShoppingPanel = CMarketShopping.new(initItemId, mainItemIdex, subIndex, self.m_initMid)
      self:addObjPanel(self.m_ShoppingPanel)
    end
    self.m_ShoppingPanel:SetBtnSelect(BaitanShow_InitShow_ShoppingView)
    if self.m_StallPanel then
      self.m_StallPanel:CloseSelf()
      self.m_StallPanel = nil
    end
  else
    if self.m_ShoppingPanel then
      self.m_ShoppingPanel:CloseSelf()
      self.m_ShoppingPanel = nil
    end
    if self.m_StallPanel == nil then
      self.m_StallPanel = CMarketStall.new()
      self:addObjPanel(self.m_StallPanel)
    end
  end
  if self.m_SilverMarketPanel then
    self.m_SilverMarketPanel:CloseSelf()
    self.m_SilverMarketPanel = nil
  end
  self.title_p1:setText("铜钱")
  self.title_p2:setText("货摊")
end
function CMarket:Btn_SilverMarket(obj, objType)
  self:ShowSilverMarket()
end
function CMarket:Btn_CoinMarket(obj, objType)
  self:ShowCoinMarket()
end
function CMarket:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemSource_Jump then
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  end
end
function CMarket:Clear()
  print("CMarket  Clear")
  if self.m_SilverMarketPanel then
    self.m_SilverMarketPanel:CloseSelf()
    self.m_SilverMarketPanel = nil
  end
  if self.m_ShoppingPanel then
    self.m_ShoppingPanel:CloseSelf()
    self.m_ShoppingPanel = nil
  end
  if self.m_StallPanel then
    self.m_StallPanel:CloseSelf()
    self.m_StallPanel = nil
  end
  if g_Market == self then
    g_Market = nil
  end
  if self.CloseFunc then
    self.CloseFunc()
  end
  self.CloseFunc = nil
end
