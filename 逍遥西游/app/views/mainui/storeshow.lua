g_StoreView = nil
CStoreShow = class("CStoreShow", CcsSubView)
function CStoreShow:ctor(para)
  para = para or {}
  self.m_ViewPara = para
  self.m_InitStoreShow = para.InitStoreShow or StoreShow_ShopView
  CStoreShow.super.ctor(self, "views/store.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_shop = {
      listener = handler(self, self.OnBtn_Shop),
      variName = "btn_shop"
    },
    btn_recharge = {
      listener = handler(self, self.OnBtn_Recharge),
      variName = "btn_recharge"
    },
    btn_fanli = {
      listener = handler(self, self.OnBtn_Fanli),
      variName = "btn_fanli"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_shop,
      nil,
      ccc3(90, 0, 0),
      ccp(-2, 0)
    },
    {
      self.btn_recharge,
      nil,
      ccc3(90, 0, 0),
      ccp(-2, 0)
    },
    {
      self.btn_fanli,
      nil,
      ccc3(90, 0, 0),
      ccp(-2, 0)
    }
  })
  self.btn_shop:setTitleText("商\n城")
  self.btn_recharge:setTitleText("充\n值")
  self.btn_fanli:setTitleText("奖\n励")
  local size = self.btn_shop:getContentSize()
  self:adjustClickSize(self.btn_shop, size.width + 30, size.height, true)
  local size = self.btn_recharge:getContentSize()
  self:adjustClickSize(self.btn_recharge, size.width + 30, size.height, true)
  local size = self.btn_fanli:getContentSize()
  self:adjustClickSize(self.btn_fanli, size.width + 30, size.height, true)
  self:setGroupAllNotSelected(self.btn_shop)
  self.m_RechargeView = nil
  self.m_ShopView = nil
  self.m_FanliView = nil
  self:SelectView(self.m_InitStoreShow)
  g_StoreView = self
end
function CStoreShow:CreateView(viewNum)
  local tempViewNameDict = {
    [StoreShow_ShopView] = "m_ShopView",
    [StoreShow_RechargeView] = "m_RechargeView",
    [StoreShow_FanLiView] = "m_FanliView"
  }
  local viewObj = self[tempViewNameDict[i]]
  if viewObj == nil then
    local tempView
    if viewNum == StoreShow_ShopView then
      tempView = ShopView.new(self.m_ViewPara)
      self.m_ShopView = tempView
    elseif viewNum == StoreShow_RechargeView then
      tempView = RechargeView.new(self.m_ViewPara)
      self.m_RechargeView = tempView
    else
      tempView = RechargeFanliView.new()
      self.m_FanliView = tempView
    end
    if tempView ~= nil then
      self:addChild(tempView.m_UINode, 1)
      tempView:setPosition(ccp(0, 0))
    end
  end
end
function CStoreShow:SelectView(viewNum)
  if (viewNum == StoreShow_RechargeView or viewNum == StoreShow_FanLiView) and g_LocalPlayer:getCanShowRechargeView() == false then
    ShowNotifyTips("前往充值页面")
    device.openURL("http://h5.youvipwan.com/xingyue/dt1.html")
    viewNum = StoreShow_ShopView
  end
  local viewNumList = {
    StoreShow_ShopView,
    StoreShow_RechargeView,
    StoreShow_FanLiView
  }
  local tempViewNameDict = {
    [StoreShow_ShopView] = "m_ShopView",
    [StoreShow_RechargeView] = "m_RechargeView",
    [StoreShow_FanLiView] = "m_FanliView"
  }
  local tempBtnNameDict = {
    [StoreShow_ShopView] = self.btn_shop,
    [StoreShow_RechargeView] = self.btn_recharge,
    [StoreShow_FanLiView] = self.btn_fanli
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    self:CreateView(viewNum)
  end
  for _, i in pairs(viewNumList) do
    local viewObj = self[tempViewNameDict[i]]
    if viewObj ~= nil then
      viewObj:setVisible(i == viewNum)
      viewObj:setEnabled(i == viewNum)
      if viewObj.setMyTouchEnabled then
        viewObj:setMyTouchEnabled(i == viewNum)
      end
    end
  end
  if viewNum == StoreShow_ShopView then
    self.m_ShopView:ShowPage(self.m_ShopView.m_CurPageNum)
  elseif viewNum == StoreShow_RechargeView then
    self.m_RechargeView:ShowPage(self.m_RechargeView.m_PageNum)
  else
    self.m_FanliView:InitPage()
  end
  self.m_CurShowViewNum = viewNum
  self:setGroupBtnSelected(tempBtnNameDict[viewNum])
end
function CStoreShow:FlushViewData()
  self:SelectView(self.m_CurShowViewNum)
end
function CStoreShow:SetShopBtnClick(pageNum)
  if self.m_ShopView then
    self.m_ShopView:SetShopBtnClick(pageNum)
  end
end
function CStoreShow:OnBtn_Shop(btnObj, touchType)
  self:SelectView(StoreShow_ShopView)
end
function CStoreShow:OnBtn_Recharge(btnObj, touchType)
  self:SelectView(StoreShow_RechargeView)
end
function CStoreShow:OnBtn_Fanli(btnObj, touchType)
  self:SelectView(StoreShow_FanLiView)
end
function CStoreShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CStoreShow:Clear()
  if g_StoreView == self then
    g_StoreView = nil
  end
end
