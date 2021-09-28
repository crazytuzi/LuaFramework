CMarketBuy = class("CMarketBuy", CcsSubView)
function CMarketBuy:ctor(itemId, price, initNum)
  CMarketBuy.super.ctor(self, "views/marketbuy.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_ItemTypeId = itemId
  self.m_PriceResType = RESTYPE_SILVER
  self.m_BuyNum = 1
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setData()
  self:setPriceNum(price)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Market)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMarketBuy:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    local d = arg[1]
    if d.newSilver ~= nil then
      self:setPriceNum(self.m_PriceNum)
    end
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    local itemTypeId = arg[3]
    if itemTypeId == self.m_ItemTypeId then
      self:setMyNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local itemTypeId = arg[2]
    if itemTypeId == self.m_ItemTypeId then
      self:setMyNum()
    end
  elseif msgSID == MsgID_Market_PriceUpdate and arg[1] == self.m_ItemTypeId then
    self:setPriceNum(arg[2])
  end
end
function CMarketBuy:setData()
  local itemId = self.m_ItemTypeId
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = itemId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0.3,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  pos:addChild(icon)
  self.m_ItemImg = icon
  local name = data_getItemName(itemId)
  self:getNode("txt_name"):setText(name)
  local itemPj = data_getItemPinjie(itemId)
  local color = NameColor_Item[itemPj] or NameColor_Item[0]
  self:getNode("txt_name"):setColor(color)
  local x, y = self:getNode("box_icon1"):getPosition()
  local z = self:getNode("box_icon1"):getZOrder()
  local size = self:getNode("box_icon1"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(self.m_PriceResType))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:setMyNum()
end
function CMarketBuy:setPriceNum(price)
  self.m_PriceNum = price
  if self.m_PriceNum == nil then
    local text_price = self:getNode("text_price")
    text_price:setText("--")
  else
    local text_price = self:getNode("text_price")
    text_price:setText(tostring(self.m_PriceNum))
    if g_LocalPlayer:getSilver() < self.m_PriceNum then
      text_price:setColor(VIEW_DEF_WARNING_COLOR)
    else
      text_price:setColor(ccc3(255, 255, 255))
    end
  end
end
function CMarketBuy:setMyNum()
  local num = g_LocalPlayer:GetItemNum(self.m_ItemTypeId)
  self:getNode("text_num"):setText(tostring(num))
end
function CMarketBuy:OnBtn_Confirm(obj, t)
  if self.m_PriceNum == nil then
    return
  end
  self.btn_confirm:setTouchEnabled(false)
  local act1 = CCDelayTime:create(0.5)
  local act2 = CCCallFunc:create(function()
    self.btn_confirm:setTouchEnabled(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
  netsend.netmarket.buyMarketItem(self.m_ItemTypeId, self.m_BuyNum)
end
function CMarketBuy:OnBtn_Cancel(obj, t)
  self:OnClose()
end
function CMarketBuy:OnClose()
  self:CloseSelf()
end
function CMarketBuy:Clear()
end
CMarketBuy_NoChange = class("CMarketBuy_NoChange", CBuyNormalItemView)
function CMarketBuy_NoChange:ctor(itemId, price, initNum)
  CMarketBuy_NoChange.super.ctor(self, 0, itemId, RESTYPE_SILVER, price, initNum)
end
function CMarketBuy_NoChange:BuyItem()
  netsend.netmarket.buyMarketItem(self.m_ItemId, self.m_BuyNum)
end
