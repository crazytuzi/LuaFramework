CMarketShoppingView = class("CMarketShoppingView", CcsSubView)
function CMarketShoppingView:ctor(goodId, btnIfo, viewTag, paramTable, initnum)
  CMarketShoppingView.super.ctor(self, "views/market_buyview.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_close),
      variName = "btn_close"
    },
    btn_left = {
      listener = handler(self, self.Btn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.Btn_Right),
      variName = "btn_right"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ViewTag = viewTag
  self.m_initNum = initnum
  if paramTable ~= nil then
    self.m_UINode:setAnchorPoint(ccp(0.5, 0.5))
    local bg_x = paramTable.bg_x
    local bg_y = paramTable.bg_y
    local bgSize = paramTable.bgSize
    local m_size = self:getContentSize()
    if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
      self:setPosition(ccp(bg_x + m_size.width / 2 - 36, bg_y))
    elseif self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
      self:setPosition(ccp(bg_x + bgSize.width / 2 - m_size.width / 2, bg_y))
    end
  end
  self.m_paramTable = g_BaitanDataMgr:GetOneGoodSellingData(goodId) or {}
  self.m_id = goodId
  self.reAddGoodTag = false
  self.txt_percent = self:getNode("txt_percent")
  self.m_ItemObjId = self.m_id
  self.ItemObj = g_BaitanDataMgr:GetOneGood(self.m_ItemObjId)
  self.itemTypeId = self.ItemObj:getTypeId()
  self.m_PlayerId = self.m_paramTable.pid
  self.state = self.m_paramTable.s
  self.m_num = self.m_paramTable.num
  self.layer_coin = self:getNode("layer_coin")
  self.txt_goodPrice = self:getNode("txt_goodPrice")
  self.txt_tax = self:getNode("txt_price_num_1")
  self.list_detail = self:getNode("list_detail")
  self.lable_num = self:getNode("lable_num")
  if self.m_initNum == nil or self.m_initNum == 0 then
    self.m_initNum = 1
  end
  if self.m_num < self.m_initNum then
    self.m_initNum = self.m_num
  end
  self.itemNum = self.m_initNum
  self.lable_num:setText(self.itemNum)
  self.MaxPriceRatio = data_Stall[self.itemTypeId].MaxPriceRatio * 100 or 150
  self.MinPriceRatio = data_Stall[self.itemTypeId].MinPriceRatio * 100 or 50
  self.RevenueRatio = data_Stall[self.itemTypeId].RevenueRatio or 0.3
  local localPlayerId = g_LocalPlayer:getPlayerId()
  local isLocal = false
  if self.m_PlayerId == localPlayerId then
    isLocal = true
  end
  local addpro_bg_DJ = self:getNode("txt_pricebg")
  local x, y = addpro_bg_DJ:getPosition()
  local p = addpro_bg_DJ:getParent()
  self.btn_DJ_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_Addpro_DJ))
  p:addChild(self.btn_DJ_addpoint, 1)
  self.btn_DJ_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_DJ_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_Subpro_DJ))
  p:addChild(self.btn_DJ_subpoint, 1)
  self.btn_DJ_subpoint:setPosition(ccp(x - 88, y - 26))
  local addpro_bg_SL = self:getNode("price_bg_num")
  local x, y = addpro_bg_SL:getPosition()
  local p = addpro_bg_SL:getParent()
  self.btn_SL_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_Addpro_SL))
  p:addChild(self.btn_SL_addpoint, 1)
  self.btn_SL_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_SL_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_Subpro_SL))
  self.btn_Max = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_Max_SL))
  p:addChild(self.btn_SL_subpoint, 1)
  p:addChild(self.btn_Max, 1)
  self.btn_SL_subpoint:setPosition(ccp(x - 88, y - 26))
  self.btn_Max:setPosition(ccp(x + 95, y - 26))
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
    self:SetBtnShow()
  else
    self:setCoinIcon()
    self.btn_SL_addpoint:setVisible(false)
    self.btn_SL_subpoint:setVisible(false)
    self.btn_SL_addpoint:setEnabled(false)
    self.btn_SL_subpoint:setEnabled(false)
  end
  self.warningView = nil
  if self.m_num == 1 then
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.btn_Max:setButtonDisableState(false)
    self.btn_SL_subpoint:setButtonDisableState(false)
  elseif self.itemNum ~= 1 and self.itemNum == self.m_num then
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.btn_Max:setButtonDisableState(false)
    self.btn_SL_subpoint:setButtonDisableState(true)
  elseif self.itemNum ~= 1 and self.itemNum < self.m_num then
    self.btn_SL_addpoint:setButtonDisableState(true)
    self.btn_Max:setButtonDisableState(true)
    self.btn_SL_subpoint:setButtonDisableState(true)
  else
    self.btn_SL_addpoint:setButtonDisableState(true)
    self.btn_Max:setButtonDisableState(true)
    self.btn_SL_subpoint:setButtonDisableState(false)
  end
  local lx, ly = self.btn_left:getPosition()
  self.m_LeftBtnOldPosition = {lx, ly}
  local rx, ry = self.btn_right:getPosition()
  self.m_RightBtnOldPosition = {rx, ry}
  self.m_MidBtnPos = ccp((lx + rx) / 2, (ly + ry) / 2)
  local paramLeft = btnIfo.leftBtn
  if paramLeft == nil or type(paramLeft) ~= "table" then
    self.btn_left:setEnabled(false)
  else
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
  end
  local paramRight = btnIfo.rightBtn
  if paramRight == nil or type(paramRight) ~= "table" then
    self.btn_right:setEnabled(false)
  else
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
  end
  self:SetButtonsPos()
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  if not self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    local offy = 70
    self.list_detail:setPosition(ccp(x, y - offy))
    self.list_detail:ignoreContentAdaptWithSize(false)
    self.list_detail:setSize(CCSize(lSize.width, lSize.height + offy))
  end
  local showSourceFlag = true
  if self.m_paramTable.fromPackageFlag == true then
    showSourceFlag = false
  end
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemObjId, {
    width = lSize.width
  }, self.m_paramTable.itemType, self.m_paramTable.eqptRoleId, self.m_PlayerId, showSourceFlag, handler(self, self.OnItemDetialTextSizeChanged), true)
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  }, true)
  self:getNode("boxbg"):addChild(self.m_ItemDetailHead)
  local isHuobanFlag = false
  if self.m_paramTable.isHuobanFlag == true then
    isHuobanFlag = true
  end
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemObjId, self.m_paramTable.itemType, self.m_paramTable.eqptRoleId, self.m_PlayerId, self.m_paramTable.isCurrEquipShow, isHuobanFlag)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height - 10))
  self:setItemDetail()
  self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  self:ListenMessage(MsgID_MoveScene)
end
function CMarketShoppingView:AutoLimitTxtPriceSize()
  AutoLimitObjSize(self.goodsPrice, 80)
end
function CMarketShoppingView:popWarmingView()
  local warningView = CPopWarning.new({
    title = "提示",
    text = "商品已售罄或被玩家下架",
    confirmText = "确定",
    confirmCloseFlag = true,
    confirmFunc = function()
      warningView = nil
    end,
    align = CRichText_AlignType_Left
  })
  warningView:ShowCloseBtn(false)
  warningView:OnlyShowConfirmBtn()
end
function CMarketShoppingView:Btn_close()
  self:CloseSelf()
end
function CMarketShoppingView:Btn_Left()
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
    self:CloseSelf()
  elseif self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    netsend.netstall.offShelfProducts(self.m_id)
    self:CloseSelf()
  end
end
function CMarketShoppingView:Btn_Right()
  local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_id) or {}
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
    netsend.netstall.buyCommodity(self.m_id, self.itemNum)
    self:CloseSelf()
  elseif self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    if curGoodData.p == self.m_price and curGoodData.s == MARKET_SCROLL_ITEM_STATE_CANSELL then
      ShowNotifyTips("价格没有改变不能重新上架")
      return
    end
    print("MMMMMMMMMMMMMMMMMMMMMM物品重新上架;", tonumber(self.m_price))
    netsend.netstall.backShelves(self.m_id, tonumber(Value2Str(self.m_price, 0)))
    self:CloseSelf()
  end
end
function CMarketShoppingView:Btn_Subpro_DJ()
  local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_id) or {}
  if self.percent > self.MinPriceRatio then
    local subNum = self.orPrice * 0.05
    self.percent = self.percent - 5
    self.m_price = math.ceil(self.orPrice * (self.percent / 100))
    if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
      self.goodsPrice:setText(string.format("%d", self.m_num * self.m_price))
      self.tax = self.m_num * self.m_price * self.RevenueRatio
      self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
    else
      self.goodsPrice:setText(string.format("%d", self.m_price))
      self.tax = self.m_price * self.RevenueRatio
      self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
    end
    self:AutoLimitTxtPriceSize()
    self.txt_percent:setText(tostring(self.percent) .. "%")
    if self.percent > self.MinPriceRatio then
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(true)
    else
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(false)
    end
  else
    ShowNotifyTips("价格已到达最低，不能再低了")
  end
  self:UpdateBtnStateForReShangjia()
end
function CMarketShoppingView:Btn_Addpro_DJ()
  local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_id) or {}
  if self.percent < self.MaxPriceRatio then
    local subNum = self.orPrice * 0.05
    self.percent = self.percent + 5
    self.m_price = math.ceil(self.orPrice * (self.percent / 100))
    if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
      self.goodsPrice:setText(string.format("%d", self.m_num * self.m_price))
      self.tax = self.m_num * self.m_price * self.RevenueRatio
      self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
    else
      self.goodsPrice:setText(string.format("%d", self.m_price))
      self.tax = self.m_price * self.RevenueRatio
      self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
    end
    self:AutoLimitTxtPriceSize()
    self.txt_percent:setText(tostring(self.percent) .. "%")
    self.btn_DJ_addpoint:setButtonDisableState(true)
    if self.percent < self.MaxPriceRatio then
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_subpoint:setButtonDisableState(true)
    else
      self.btn_DJ_addpoint:setButtonDisableState(false)
      self.btn_DJ_subpoint:setButtonDisableState(true)
    end
  else
    ShowNotifyTips("价格已到达最高，不能再高了")
  end
  self:UpdateBtnStateForReShangjia()
end
function CMarketShoppingView:Btn_Subpro_SL()
  if self.itemNum > 1 then
    self.itemNum = self.itemNum - 1
    if self.itemNum <= 1 then
      if self.itemNum < self.m_num then
        self.btn_SL_addpoint:setButtonDisableState(true)
        self.btn_SL_subpoint:setButtonDisableState(false)
      else
        self.btn_SL_subpoint:setButtonDisableState(false)
        self.btn_SL_addpoint:setButtonDisableState(false)
      end
    elseif self.itemNum < self.m_num then
      self.btn_Max:setButtonDisableState(true)
      self.btn_SL_addpoint:setButtonDisableState(true)
      self.btn_SL_addpoint:setButtonEnabled(true)
    end
    self.btn_SL_subpoint:setButtonEnabled(true)
    self.btn_Max:setButtonDisableState(true)
  else
    ShowNotifyTips("购买数量不能少于1个")
  end
  self.lable_num:setText(self.itemNum)
  self.goodsPrice:setText(string.format("%d", self.itemNum * self.m_price))
  self:AutoLimitTxtPriceSize()
end
function CMarketShoppingView:Btn_Addpro_SL()
  if self.itemNum < self.m_num then
    self.itemNum = self.itemNum + 1
    if self.itemNum >= self.m_num then
      self.btn_SL_addpoint:setButtonDisableState(false)
      self.btn_Max:setButtonDisableState(false)
      self.btn_SL_subpoint:setButtonDisableState(true)
    elseif self.itemNum > 1 and self.itemNum < self.m_num then
      self.btn_Max:setButtonDisableState(true)
      self.btn_SL_addpoint:setButtonDisableState(true)
      self.btn_SL_subpoint:setButtonDisableState(true)
    end
    self.btn_SL_addpoint:setButtonEnabled(true)
  else
    ShowNotifyTips("购买数量不能大于市场现有数量")
  end
  self.lable_num:setText(self.itemNum)
  self.goodsPrice:setText(string.format("%d", self.itemNum * self.m_price))
  self:AutoLimitTxtPriceSize()
end
function CMarketShoppingView:Btn_Max_SL(...)
  if self.itemNum < self.m_num then
    self.itemNum = self.m_num
    self.lable_num:setText(self.itemNum)
    if self.itemNum > 1 then
      self.btn_SL_subpoint:setButtonDisableState(true)
    end
    self.btn_Max:setButtonDisableState(false)
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.goodsPrice:setText(string.format("%d", self.itemNum * self.m_price))
    self:AutoLimitTxtPriceSize()
  else
    ShowNotifyTips("购买数量不能大于市场现有数量")
  end
end
function CMarketShoppingView:setCoinIcon()
  local x, y = self:getNode("box_coin2"):getPosition()
  local z = self:getNode("box_coin2"):getZOrder()
  local size = self:getNode("box_coin2"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
end
function CMarketShoppingView:setDJCoin(...)
  local x, y = self:getNode("layer_coin"):getPosition()
  local z = self:getNode("layer_coin"):getZOrder()
  local size = self:getNode("layer_coin"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  local parent = self:getNode("layer_coin"):getParent()
  parent:addNode(tempImg, z)
end
function CMarketShoppingView:setItemDetail()
  local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_id) or {}
  self.m_price = self.m_paramTable.p
  self.orPrice = self.ItemObj:getProperty(ITEM_PRO_PRICE)
  local quzheng = Value2Str(self.m_price / self.orPrice, 3) * 100
  if quzheng < 55 and quzheng > 50 then
    self.percent = math.floor(Value2Str(self.m_price / self.orPrice, 3) * 100)
  else
    self.percent = math.ceil(Value2Str(self.m_price / self.orPrice, 3) * 100)
  end
  self.goodsPrice = self:getNode("lable_price")
  if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    self.tax = self.m_num * self.m_price * self.RevenueRatio
    self.goodsPrice:setText(string.format("%d", self.m_num * self.m_price))
    self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
  else
    self.goodsPrice:setText(string.format("%d", self.itemNum * self.m_price))
    self.tax = self.m_price * self.RevenueRatio
    self.txt_tax:setText(tostring(Value2Str(self.tax, 0)))
  end
  self:AutoLimitTxtPriceSize()
  self.txt_percent:setText(tostring(self.percent .. "%"))
  if self.percent >= self.MaxPriceRatio then
    self.btn_DJ_addpoint:setButtonDisableState(false)
  elseif self.percent <= self.MinPriceRatio then
    self.btn_DJ_subpoint:setButtonDisableState(false)
  end
  self:UpdateBtnStateForReShangjia()
end
function CMarketShoppingView:UpdateBtnStateForReShangjia()
  if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    local curGoodData = g_BaitanDataMgr:GetOneGoodSellingData(self.m_id) or {}
    local ShowReShangjiaFlag = true
    if curGoodData.p == self.m_price and curGoodData.s == MARKET_SCROLL_ITEM_STATE_CANSELL then
      ShowReShangjiaFlag = false
    end
    if ShowReShangjiaFlag then
      self.btn_left:setEnabled(true)
      self.btn_right:setEnabled(true)
      self:SetButtonsPos()
    else
      self.btn_left:setEnabled(true)
      self.btn_right:setEnabled(false)
      self:SetButtonsPos()
    end
  end
end
function CMarketShoppingView:confirmToBuy(id)
  netsend.netstall.buyCommodity(id, 1)
end
function CMarketShoppingView:SetButtonsPos()
  if self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    self.btn_left:setPosition(self.m_MidBtnPos)
  elseif not self.btn_left:isEnabled() and self.btn_right:isEnabled() then
    self.btn_right:setPosition(self.m_MidBtnPos)
  else
    self.btn_left:setPosition(ccp(self.m_LeftBtnOldPosition[1], self.m_LeftBtnOldPosition[2]))
    self.btn_right:setPosition(ccp(self.m_RightBtnOldPosition[1], self.m_RightBtnOldPosition[2]))
  end
end
function CMarketShoppingView:SetBtnShow()
  self:setDJCoin()
  self.btn_DJ_addpoint:setVisible(false)
  self.btn_DJ_subpoint:setVisible(false)
  self.btn_DJ_addpoint:setEnabled(false)
  self.btn_DJ_subpoint:setEnabled(false)
  self:getNode("txt_tax"):setVisible(false)
  self:getNode("txt_percent"):setVisible(false)
  self:getNode("txt_num"):setVisible(true)
  self.btn_SL_addpoint:setVisible(true)
  self.btn_SL_subpoint:setVisible(true)
  self.btn_SL_addpoint:setEnabled(true)
  self.btn_SL_addpoint:setEnabled(true)
end
function CMarketShoppingView:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemSource_Jump then
    self:CloseSelf()
  end
end
