CBuyNormalItemView = class("CBuyNormalItemView", CcsSubView)
function CBuyNormalItemView:ctor(pageNum, itemId, priceType, price, initNum)
  CBuyNormalItemView.super.ctor(self, "views/shop_buynormal.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_PageNum = pageNum
  self.m_ItemId = itemId
  self.m_PriceResType = priceType
  self.m_PriceNum = price
  if initNum == 0 then
    initNum = 1
  end
  self.m_BuyNum = initNum or 1
  self.m_NeedNum = price
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    }
  }
  local x, y = self:getNode("box_btnadd"):getPosition()
  self.btn_add = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Add))
  self:addChild(self.btn_add)
  self.btn_add:setPosition(ccp(x, y))
  self.btn_add:setTouchEnabled(true)
  local x, y = self:getNode("box_btnsub"):getPosition()
  self.btn_sub = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Sub))
  self:addChild(self.btn_sub)
  self.btn_sub:setPosition(ccp(x, y))
  self.btn_sub:setTouchEnabled(true)
  local x, y = self:getNode("box_btnaddten"):getPosition()
  self.btn_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10.png", handler(self, self.OnBtn_AddTen))
  self:addChild(self.btn_addten)
  self.btn_addten:setPosition(ccp(x, y))
  self.btn_addten:setTouchEnabled(true)
  self:addBatchBtnListener(btnBatchListener)
  self:setData()
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Market)
  CBuyNormalItemView.viewObj = self
end
function CBuyNormalItemView:setData()
  local tempNum = 0
  local itemId = self.m_ItemId
  if self.m_ItemImg then
    self.m_ItemImg:removeFromParent()
    self.m_ItemImg = nil
  end
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = itemId,
    autoSize = nil,
    num = tempNum,
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
  self:setNum(self.m_BuyNum)
  self:setOwnNum()
  if g_MissionMgr:isObjShortage(itemId) then
    local bg = self:getNode("bg")
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    local x, y = bg:getPosition()
    local size = bg:getContentSize()
    img:setAnchorPoint(ccp(0, 1))
    img:setPosition(ccp(x - size.width / 2, y + size.height / 2))
    self:addNode(img, 100)
  end
end
function CBuyNormalItemView:setNum(num)
  if num > 999 then
    num = 999
    self.btn_add:stopLongPressClick()
    self.btn_addten:stopLongPressClick()
  end
  local player = g_LocalPlayer
  self.m_BuyNum = num
  self:getNode("text_num"):setText(tostring(self.m_BuyNum))
  if self.m_PriceNum ~= nil then
    self.m_NeedNum = self.m_BuyNum * self.m_PriceNum
    self:getNode("text_allprice"):setText(tostring(self.m_NeedNum))
    local redFlag = false
    if self.m_PriceResType == RESTYPE_COIN then
      if player:getCoin() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_GOLD then
      if player:getGold() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_Honour then
      if player:getHonour() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_SILVER then
      if player:getSilver() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_XIAYI and player:getXiaYiValue() < self.m_NeedNum then
      redFlag = true
    end
    if redFlag then
      self:getNode("text_allprice"):setColor(VIEW_DEF_WARNING_COLOR)
    else
      self:getNode("text_allprice"):setColor(ccc3(255, 255, 255))
    end
  else
    self:getNode("text_allprice"):setText("--")
  end
  if self.m_BuyNum > 1 then
    self.btn_sub:setButtonDisableState(true)
  else
    self.btn_sub:setButtonDisableState(false)
    self.btn_sub:stopLongPressClick()
  end
end
function CBuyNormalItemView:setOwnNum()
  local myNum = g_LocalPlayer:GetItemNum(self.m_ItemId)
  self:getNode("text_own"):setText(tostring(myNum))
end
function CBuyNormalItemView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    if arg[3] == self.m_ItemId then
      self:setOwnNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    if arg[2] == self.m_ItemId then
      self:setOwnNum()
    end
  elseif msgSID == MsgID_MoneyUpdate or msgSID == MsgID_HonourUpdate then
    self:setNum(self.m_BuyNum)
  elseif msgSID == MsgID_Market_PriceUpdate and arg[1] == self.m_ItemId then
    self.m_PriceNum = arg[2]
    self:setNum(self.m_BuyNum)
  end
end
function CBuyNormalItemView:OnBtn_Confirm(obj, t)
  if self.m_NeedNum == nil then
    return
  end
  local player = g_LocalPlayer
  if self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_NeedNum then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif self.m_PriceResType == RESTYPE_Honour and player:getHonour() < self.m_NeedNum then
    ShowNotifyTips("荣誉不足")
    return
  end
  self.m_Btn_Confirm:setTouchEnabled(false)
  local act1 = CCDelayTime:create(0.5)
  local act2 = CCCallFunc:create(function()
    self.m_Btn_Confirm:setTouchEnabled(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
  self:BuyItem()
end
function CBuyNormalItemView:BuyItem()
  local num = self.m_BuyNum
  netsend.netshop.shopbuyitem(self.m_PageNum, self.m_ItemId, num)
  self:OnClose()
end
function CBuyNormalItemView:OnBtn_Cancel(obj, t)
  self:OnClose()
end
function CBuyNormalItemView:OnBtn_Add(obj, t)
  self:setNum(self.m_BuyNum + 1)
end
function CBuyNormalItemView:OnBtn_Sub(obj, t)
  self:setNum(math.max(1, self.m_BuyNum - 1))
end
function CBuyNormalItemView:OnBtn_AddTen(obj, t)
  if self.m_BuyNum == 1 then
    self:setNum(10)
  else
    self:setNum(self.m_BuyNum + 10)
  end
end
function CBuyNormalItemView:OnClose()
  self:removeFromParent()
  if CBuyNormalItemView.viewObj == self then
    CBuyNormalItemView.viewObj = nil
  end
end
function CBuyNormalItemView:Clear()
  if CBuyNormalItemView.viewObj == self then
    CBuyNormalItemView.viewObj = nil
  end
end
CBuyXianGouItemView = class("CBuyXianGouItemView", CcsSubView)
function CBuyXianGouItemView:ctor(xgId)
  CBuyXianGouItemView.super.ctor(self, "views/shop_buynormal.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_XGId = xgId
  local xgData = data_ShopXianGou[xgId] or {}
  local allXGData = g_LocalPlayer:GetXianGouShopList()
  local price = xgData.price
  if price == 0 or price == nil then
    self.m_PriceNum = xgData.gold
    self.m_PriceResType = RESTYPE_GOLD
  else
    self.m_PriceNum = xgData.price
    self.m_PriceResType = RESTYPE_COIN
  end
  self.m_ItemId = xgData.itemid
  if initNum == 0 then
    initNum = 1
  end
  local hasNum = 0
  hasNum = allXGData[xgId] and (allXGData[xgId].num or 0)
  self.m_MaxNum = math.min(hasNum, xgData.numLimit)
  self.m_BuyNum = initNum or 1
  self.m_NeedNum = price
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    }
  }
  local x, y = self:getNode("box_btnadd"):getPosition()
  self.btn_add = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Add))
  self:addChild(self.btn_add)
  self.btn_add:setPosition(ccp(x, y))
  self.btn_add:setTouchEnabled(true)
  local x, y = self:getNode("box_btnsub"):getPosition()
  self.btn_sub = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Sub))
  self:addChild(self.btn_sub)
  self.btn_sub:setPosition(ccp(x, y))
  self.btn_sub:setTouchEnabled(true)
  local x, y = self:getNode("box_btnaddten"):getPosition()
  self.btn_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10.png", handler(self, self.OnBtn_AddTen))
  self:addChild(self.btn_addten)
  self.btn_addten:setPosition(ccp(x, y))
  self.btn_addten:setTouchEnabled(true)
  self:addBatchBtnListener(btnBatchListener)
  self:setData()
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  CBuyXianGouItemView.viewObj = self
end
function CBuyXianGouItemView:setData()
  local tempNum = 0
  local itemId = self.m_ItemId
  if self.m_ItemImg then
    self.m_ItemImg:removeFromParent()
    self.m_ItemImg = nil
  end
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = itemId,
    autoSize = nil,
    num = tempNum,
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
  self:setNum(self.m_BuyNum)
  self:setOwnNum()
end
function CBuyXianGouItemView:setNum(num)
  if num > self.m_MaxNum then
    num = self.m_MaxNum
    local xgData = data_ShopXianGou[self.m_XGId] or {}
    local allXGData = g_LocalPlayer:GetXianGouShopList()
    local limit = xgData.numLimit
    local hasNum = 0
    hasNum = allXGData[self.m_XGId] and (allXGData[self.m_XGId].num or 0)
    local hasBuy = xgData.numLimit - hasNum
    if hasBuy <= 0 then
      ShowNotifyTips(string.format("该商品限购%d个", limit))
    else
      ShowNotifyTips(string.format("该商品限购%d个,已购%d个", limit, hasBuy))
    end
    self.btn_add:stopLongPressClick()
    self.btn_addten:stopLongPressClick()
  end
  local player = g_LocalPlayer
  self.m_BuyNum = num
  self:getNode("text_num"):setText(tostring(self.m_BuyNum))
  if self.m_PriceNum ~= nil then
    self.m_NeedNum = self.m_BuyNum * self.m_PriceNum
    self:getNode("text_allprice"):setText(tostring(self.m_NeedNum))
    local redFlag = false
    if self.m_PriceResType == RESTYPE_COIN then
      if player:getCoin() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_GOLD then
      if player:getGold() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_Honour then
      if player:getHonour() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_SILVER then
      if player:getSilver() < self.m_NeedNum then
        redFlag = true
      end
    elseif self.m_PriceResType == RESTYPE_XIAYI and player:getXiaYiValue() < self.m_NeedNum then
      redFlag = true
    end
    if redFlag then
      self:getNode("text_allprice"):setColor(VIEW_DEF_WARNING_COLOR)
    else
      self:getNode("text_allprice"):setColor(ccc3(255, 255, 255))
    end
  else
    self:getNode("text_allprice"):setText("--")
  end
  if self.m_BuyNum > 1 then
    self.btn_sub:setButtonDisableState(true)
  else
    self.btn_sub:setButtonDisableState(false)
    self.btn_sub:stopLongPressClick()
  end
end
function CBuyXianGouItemView:setOwnNum()
  local myNum = g_LocalPlayer:GetItemNum(self.m_ItemId)
  self:getNode("text_own"):setText(tostring(myNum))
end
function CBuyXianGouItemView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    if arg[3] == self.m_ItemId then
      self:setOwnNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    if arg[2] == self.m_ItemId then
      self:setOwnNum()
    end
  elseif msgSID == MsgID_MoneyUpdate or msgSID == MsgID_HonourUpdate then
    self:setNum(self.m_BuyNum)
  elseif msgSID == MsgID_Market_PriceUpdate and arg[1] == self.m_ItemId then
    self.m_PriceNum = arg[2]
    self:setNum(self.m_BuyNum)
  end
end
function CBuyXianGouItemView:OnBtn_Confirm(obj, t)
  if self.m_NeedNum == nil then
    return
  end
  local player = g_LocalPlayer
  if self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_NeedNum then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif self.m_PriceResType == RESTYPE_Honour and player:getHonour() < self.m_NeedNum then
    ShowNotifyTips("荣誉不足")
    return
  end
  self.m_Btn_Confirm:setTouchEnabled(false)
  local act1 = CCDelayTime:create(0.5)
  local act2 = CCCallFunc:create(function()
    self.m_Btn_Confirm:setTouchEnabled(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
  self:BuyItem()
end
function CBuyXianGouItemView:BuyItem()
  local num = self.m_BuyNum
  netsend.netshop.BuyXianGouItem(self.m_XGId, num)
  self:OnClose()
end
function CBuyXianGouItemView:OnBtn_Cancel(obj, t)
  self:OnClose()
end
function CBuyXianGouItemView:OnBtn_Add(obj, t)
  self:setNum(self.m_BuyNum + 1)
end
function CBuyXianGouItemView:OnBtn_Sub(obj, t)
  self:setNum(math.max(1, self.m_BuyNum - 1))
end
function CBuyXianGouItemView:OnBtn_AddTen(obj, t)
  if self.m_BuyNum == 1 then
    self:setNum(10)
  else
    self:setNum(self.m_BuyNum + 10)
  end
end
function CBuyXianGouItemView:OnClose()
  self:removeFromParent()
  if CBuyXianGouItemView.viewObj == self then
    CBuyXianGouItemView.viewObj = nil
  end
end
function CBuyXianGouItemView:Clear()
  if CBuyXianGouItemView.viewObj == self then
    CBuyXianGouItemView.viewObj = nil
  end
end
CBuySecretItemView = class("CBuySecretItemView", CcsSubView)
function CBuySecretItemView:ctor(pageNum, itemId, priceType, price, itemNum, smsdNo, xiaYiGoods_No)
  CBuySecretItemView.super.ctor(self, "views/shop_buysecret.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_PageNum = pageNum
  self.m_ItemId = itemId
  self.m_PriceResType = priceType
  self.m_PriceNum = price
  self.m_ItemNum = itemNum
  self.m_Smsd_No = smsdNo
  self.m_XiaYiGoods_No = xiaYiGoods_No
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setData()
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  CBuySecretItemView.viewObj = self
  return self
end
function CBuySecretItemView:setData()
  local itemId = self.m_ItemId
  if self.m_ItemImg then
    self.m_ItemImg:removeFromParent()
    self.m_ItemImg = nil
  end
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
  local player = g_LocalPlayer
  self:getNode("text_num"):setText(tostring(self.m_ItemNum))
  self:setOwnNum()
  self:getNode("text_allprice"):setText(tostring(self.m_PriceNum))
  local redFlag = false
  if self.m_PriceResType == RESTYPE_COIN then
    if player:getCoin() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_SILVER then
    if player:getSilver() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_XIAYI and player:getXiaYiValue() < self.m_PriceNum then
    redFlag = true
  end
  if redFlag then
    self:getNode("text_allprice"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("text_allprice"):setColor(ccc3(255, 255, 255))
  end
  if g_MissionMgr:isObjShortage(itemId) then
    local bg = self:getNode("bg")
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    local x, y = bg:getPosition()
    local size = bg:getContentSize()
    img:setAnchorPoint(ccp(0, 1))
    img:setPosition(ccp(x - size.width / 2, y + size.height / 2))
    self:addNode(img, 100)
  end
end
function CBuySecretItemView:setOwnNum()
  local myNum = g_LocalPlayer:GetItemNum(self.m_ItemId)
  self:getNode("text_own"):setText(tostring(myNum))
end
function CBuySecretItemView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    if arg[3] == self.m_ItemId then
      self:setOwnNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem and arg[2] == self.m_ItemId then
    self:setOwnNum()
  end
end
function CBuySecretItemView:OnBtn_Confirm(obj, t)
  local player = g_LocalPlayer
  if self.m_PageNum == Shop_Smsd_Page then
    if self.m_PriceResType == RESTYPE_GOLD and player:getGold() < self.m_PriceNum then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif self.m_PageNum == Shop_Xiayi_Page and player:getXiaYiValue() < self.m_PriceNum then
    ShowNotifyTips("侠义值不足")
    return
  end
  self.m_Btn_Confirm:setTouchEnabled(false)
  local act1 = CCDelayTime:create(0.5)
  local act2 = CCCallFunc:create(function()
    self.m_Btn_Confirm:setTouchEnabled(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
  if self.m_PageNum == Shop_Xiayi_Page then
    netsend.netshop.BuyXiaYiGoods(self.m_XiaYiGoods_No)
  elseif self.m_PageNum == Shop_Smsd_Page then
    netsend.netshop.shopbuyitem(self.m_PageNum, self.m_ItemId, self.m_ItemNum, self.m_Smsd_No)
  end
  self:OnClose()
end
function CBuySecretItemView:OnBtn_Cancel(obj, t)
  self:OnClose()
end
function CBuySecretItemView:OnClose()
  self:removeFromParent()
  CBuySecretItemView.viewObj = nil
end
function CBuySecretItemView:Clear()
  CBuySecretItemView.viewObj = nil
end
