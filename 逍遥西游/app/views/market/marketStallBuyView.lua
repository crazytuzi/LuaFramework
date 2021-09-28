CMarketStallBuyView = class("CMarketStallBuyView", CcsSubView)
function CMarketStallBuyView:ctor(itemObjId, paramTable)
  CMarketStallBuyView.super.ctor(self, "views/marketstall_buyview.json")
  self.m_ItemObjId = itemObjId
  paramTable = paramTable or {}
  self.m_ParamTable = paramTable
  local bg_x = paramTable.bg_x
  local bg_y = paramTable.bg_y
  local bgSize = paramTable.bgSize
  local m_size = self:getContentSize()
  self.m_UINode:setAnchorPoint(ccp(0.5, 0.5))
  local size = self.m_UINode:getSize()
  self:setPosition(ccp(bg_x - m_size.width / 2, bg_y))
  local btnBatchListener = {
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_subpro_1 = {
      listener = handler(self, self.Btn_Subpro_SL),
      variName = "btn_subpro_1"
    },
    btn_addpro_1 = {
      listener = handler(self, self.Btn_Addpro_SL),
      variName = "btn_addpro_1"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseListener = paramTable.closeListener or nil
  self.btn_close:setEnabled(true)
  self.txt_price_num = self:getNode("txt_price_num")
  self.txt_ZongJia = self:getNode("txt_price_num_2")
  self.txt_ShuiShou = self:getNode("txt_price_num_3")
  self.txt_num = self:getNode("txt_num")
  self.txt_percent = self:getNode("txt_percent")
  self:getNode("goodsName"):setVisible(false)
  self.packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  self.itemTypeId = self.packageItemIns:getTypeId()
  self.itemNum = self.packageItemIns:getProperty(ITEM_PRO_NUM)
  self.LimiteItemNum = 1
  self.itemName = self.packageItemIns:getProperty(ITEM_PRO_NAME)
  self.itemPrice = self.packageItemIns:getProperty(ITEM_PRO_PRICE)
  self.LimiteItemNum = data_Stall[self.itemTypeId].LimitPerSoldin or 1
  self.MaxPriceRatio = data_Stall[self.itemTypeId].MaxPriceRatio * 100 or 150
  self.MinPriceRatio = data_Stall[self.itemTypeId].MinPriceRatio * 100 or 50
  self.RevenueRatio = data_Stall[self.itemTypeId].RevenueRatio or 0.3
  self.orPrice = self.itemPrice
  self.m_itemNum = 1
  self.percent = 100
  self.txt_price_num:setText(tostring(self.itemPrice))
  self.txt_percent:setText(tostring(100 * Value2Str(self.itemPrice / self.orPrice, 0)) .. "%")
  self.txt_num:setText(tostring(self.m_itemNum))
  self:AutoLimitTxtPriceSize()
  local addpro_bg_DJ = self:getNode("price_bg")
  local x, y = addpro_bg_DJ:getPosition()
  local p = addpro_bg_DJ:getParent()
  self.btn_DJ_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_Addpro_DJ))
  self.btn_DJ_Max = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_Max_DJ))
  p:addChild(self.btn_DJ_addpoint)
  p:addChild(self.btn_DJ_Max)
  self.btn_DJ_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_DJ_Max:setPosition(ccp(x + 92, y - 26))
  self.btn_DJ_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_Subpro_DJ))
  p:addChild(self.btn_DJ_subpoint)
  self.btn_DJ_subpoint:setPosition(ccp(x - 88, y - 26))
  local addpro_bg_SL = self:getNode("price_bg_1")
  local x, y = addpro_bg_SL:getPosition()
  local p = addpro_bg_SL:getParent()
  self.btn_SL_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_Addpro_SL))
  self.btn_SL_Max = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_Max_SL))
  p:addChild(self.btn_SL_addpoint)
  p:addChild(self.btn_SL_Max)
  self.btn_SL_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_SL_Max:setPosition(ccp(x + 92, y - 26))
  self.btn_SL_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_Subpro_SL))
  p:addChild(self.btn_SL_subpoint)
  self.btn_SL_subpoint:setPosition(ccp(x - 88, y - 26))
  self.btn_SL_subpoint:setButtonDisableState(false)
  if self.itemNum <= 1 or self.LimiteItemNum == 1 then
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.btn_SL_Max:setButtonDisableState(false)
  end
  self:setTotalPriceAndTax()
  if paramTable.leftBtnFontSize ~= nil then
    self.btn_left:setTitleFontSize(paramTable.leftBtnFontSize)
  end
  if paramTable.rightBtnFontSize ~= nil then
    self.btn_right:setTitleFontSize(paramTable.rightBtnFontSize)
  end
  local lx, ly = self.btn_left:getPosition()
  local rx, ry = self.btn_right:getPosition()
  self.m_MidBtnPos = ccp((lx + rx) / 2, (ly + ry) / 2)
  local paramLeft = paramTable.leftBtn
  if paramLeft == nil or type(paramLeft) ~= "table" then
    self.btn_left:setEnabled(false)
  else
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
    self.m_LeftBtnListener = paramLeft.listener
  end
  local paramRight = paramTable.rightBtn
  if paramRight == nil or type(paramRight) ~= "table" then
    self.btn_right:setEnabled(false)
  else
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
    self.m_RightBtnListener = paramRight.listener
  end
  self:SetButtonsPos()
  self.list_detail = self:getNode("list_detail")
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
  if paramTable.fromPackageFlag == true then
    showSourceFlag = false
  end
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemObjId, {
    width = lSize.width
  }, paramTable.itemType, paramTable.eqptRoleId, nil, showSourceFlag, handler(self, self.OnItemDetialTextSizeChanged))
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  })
  self:getNode("boxbg"):addChild(self.m_ItemDetailHead)
  local isHuobanFlag = false
  if paramTable.isHuobanFlag == true then
    isHuobanFlag = true
  end
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemObjId, paramTable.itemType, paramTable.eqptRoleId, nil, paramTable.isCurrEquipShow, isHuobanFlag)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height - 10))
  if paramTable.enableTouchDetect ~= false then
    self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  end
  local isEqptFlag = false
  local tmpLargeType
  if self.m_ItemObjId == nil then
    tmpLargeType = GetItemTypeByItemTypeId(paramTable.itemType)
  else
    local tmpObj = g_LocalPlayer:GetOneItem(self.m_ItemObjId)
    tmpLargeType = tmpObj:getType()
  end
  if tmpLargeType == ITEM_LARGE_TYPE_EQPT or tmpLargeType == ITEM_LARGE_TYPE_XIANQI or tmpLargeType == ITEM_LARGE_TYPE_SENIOREQPT or tmpLargeType == ITEM_LARGE_TYPE_HUOBANEQPT or tmpLargeType == ITEM_LARGE_TYPE_NEIDAN then
    isEqptFlag = true
  end
  local tSize = self.m_ItemDetailText:getContentSize()
  if not isEqptFlag and lSize.height >= tSize.height then
    self.list_detail:setTouchEnabled(false)
  end
  self:setCoinIcon("box_coin1")
  self:setCoinIcon("box_coin2")
  self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  self:ListenMessage(MsgID_MoveScene)
end
function CMarketStallBuyView:AutoLimitTxtPriceSize()
  AutoLimitObjSize(self.txt_price_num, 80)
end
function CMarketStallBuyView:OnItemDetialTextSizeChanged()
  self.list_detail:refreshView()
end
function CMarketStallBuyView:SetButtonsPos()
  if self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    self.btn_left:setPosition(self.m_MidBtnPos)
  elseif not self.btn_left:isEnabled() and self.btn_right:isEnabled() then
    self.btn_right:setPosition(self.m_MidBtnPos)
  end
end
function CMarketStallBuyView:ShowCloseBtn(btnWPos)
  self.btn_close:setEnabled(true)
  if btnWPos ~= nil then
    local p = self.btn_close:getParent()
    local pos = p:convertToNodeSpace(btnWPos)
    self.btn_close:setPosition(ccp(pos.x, pos.y))
  end
end
function CMarketStallBuyView:getItemObjId()
  return self.m_ItemObjId
end
function CMarketStallBuyView:UpdateLeftButton(paramLeft)
  if paramLeft == nil then
    self.btn_left:setEnabled(false)
  else
    self.btn_left:setEnabled(true)
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
    self.m_LeftBtnListener = paramLeft.listener
  end
  self:SetButtonsPos()
end
function CMarketStallBuyView:UpdateRightButton(paramRight)
  if paramRight == nil then
    self.btn_right:setEnabled(false)
  else
    self.btn_right:setEnabled(true)
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
    self.m_RightBtnListener = paramRight.listener
  end
  self:SetButtonsPos()
end
function CMarketStallBuyView:OnBtn_Left(btnObj, touchType)
  if self.m_LeftBtnListener then
    self.m_LeftBtnListener(self.m_ItemObjId, self.m_itemNum, self.TotalPrice)
  end
  if self.m_itemNum > 0 then
    local isCanSell = data_Stall[self.itemTypeId].CanSell
    if isCanSell == 1 then
      netsend.netstall.addedGoods(self.m_ItemObjId, self.m_itemNum, self.itemPrice, 0)
    else
      ShowNotifyTips("该物品不能上架")
    end
    self:CloseSelf()
  end
end
function CMarketStallBuyView:OnBtn_Right(btnObj, touchType)
  if self.m_RightBtnListener then
    self.m_RightBtnListener(self.m_ItemObjId)
  end
end
function CMarketStallBuyView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CMarketStallBuyView:getBoxSize()
  return self:getNode("boxbg"):getContentSize()
end
function CMarketStallBuyView:setEffectClickArea(areaRect)
  self:enableCloseWhenTouchOutsideBySize(areaRect)
end
function CMarketStallBuyView:Btn_Subpro_DJ()
  if self.percent > self.MinPriceRatio then
    local subNum = self.orPrice * 0.05
    self.percent = self.percent - 5
    self.itemPrice = math.ceil(self.orPrice * (self.percent / 100))
    if self.percent <= self.MinPriceRatio then
      self.btn_DJ_subpoint:setButtonDisableState(false)
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_Max:setButtonDisableState(true)
      self.percent = self.MinPriceRatio
      self.itemPrice = math.ceil(self.orPrice * (self.percent / 100))
    elseif self.percent > self.MinPriceRatio and self.percent < self.MaxPriceRatio then
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_Max:setButtonDisableState(true)
    end
    self.txt_price_num:setText(tonumber(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
  else
    self.percent = self.MinPriceRatio
    self.itemPrice = math.ceil(self.orPrice * (self.percent / 100))
    self.txt_price_num:setText(tonumber(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
    ShowNotifyTips("价格已到达最低，不能再低了")
  end
  self:AutoLimitTxtPriceSize()
  self:setTotalPriceAndTax()
end
function CMarketStallBuyView:Btn_Addpro_DJ(...)
  if self.percent < self.MaxPriceRatio then
    local subNum = self.orPrice * 0.05
    self.percent = self.percent + 5
    self.itemPrice = math.ceil(self.orPrice * (self.percent / 100))
    if self.percent >= self.MaxPriceRatio then
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_DJ_addpoint:setButtonDisableState(false)
      self.btn_DJ_Max:setButtonDisableState(false)
    elseif self.percent < self.MaxPriceRatio and self.percent > self.MinPriceRatio then
      self.btn_DJ_subpoint:setButtonDisableState(true)
      self.btn_DJ_addpoint:setButtonDisableState(true)
      self.btn_DJ_Max:setButtonDisableState(true)
    end
    self.txt_price_num:setText(tonumber(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
  else
    self.percent = self.MaxPriceRatio
    self.itemPrice = self.orPrice * (self.percent / 100)
    self.txt_price_num:setText(tonumber(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
    ShowNotifyTips("价格已到达最高，不能再高了")
  end
  self:AutoLimitTxtPriceSize()
  self:setTotalPriceAndTax()
end
function CMarketStallBuyView:Btn_Max_DJ(...)
  if self.percent < self.MaxPriceRatio then
    local subNum = self.orPrice * (self.MaxPriceRatio / 100)
    self.itemPrice = tonumber(Value2Str(subNum, 0))
    self.percent = tonumber(Value2Str(subNum / self.orPrice, 2) * 100)
    self.btn_DJ_subpoint:setButtonDisableState(true)
    self.btn_DJ_addpoint:setButtonDisableState(false)
    self.btn_DJ_Max:setButtonDisableState(false)
    self.txt_price_num:setText(tostring(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
    self:setTotalPriceAndTax()
  else
    self.percent = self.MaxPriceRatio
    self.itemPrice = self.orPrice * (self.MaxPriceRatio / 100)
    self.txt_price_num:setText(tostring(self.itemPrice))
    self.txt_percent:setText(tostring(self.percent) .. "%")
    ShowNotifyTips("价格已到达最高，不能再高了")
  end
  self:AutoLimitTxtPriceSize()
end
function CMarketStallBuyView:Btn_Subpro_SL(...)
  if self.m_itemNum <= 1 then
    ShowNotifyTips("上架数量不能少于一个")
    return
  end
  if self.LimiteItemNum == 1 or 1 >= self.itemNum then
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.btn_SL_subpoint:setButtonDisableState(false)
    self.btn_SL_Max:setButtonDisableState(false)
  else
    self.m_itemNum = self.m_itemNum - 1
    if self.m_itemNum < self.LimiteItemNum then
      if self.m_itemNum < self.itemNum then
        self.btn_SL_addpoint:setButtonDisableState(true)
        self.btn_SL_Max:setButtonDisableState(true)
      else
        self.btn_SL_addpoint:setButtonDisableState(false)
        self.btn_SL_Max:setButtonDisableState(false)
      end
    else
      self.btn_SL_addpoint:setButtonDisableState(false)
      self.btn_SL_Max:setButtonDisableState(false)
    end
    if self.m_itemNum > 1 then
      self.btn_SL_subpoint:setButtonDisableState(true)
    else
      self.btn_SL_subpoint:setButtonDisableState(false)
    end
  end
  if self.m_itemNum <= self.itemNum and self.m_itemNum >= 1 then
    self.txt_num:setText(tostring(self.m_itemNum))
  end
  self:setTotalPriceAndTax()
end
function CMarketStallBuyView:Btn_Addpro_SL(...)
  if self.m_itemNum == self.LimiteItemNum then
    ShowNotifyTips("已到达了最大上架数量")
    return
  elseif self.m_itemNum >= self.itemNum then
    ShowNotifyTips("上架的数量不能大于背包中物品的数量")
    return
  end
  if self.LimiteItemNum == 1 or self.itemNum <= 1 then
    self.btn_SL_addpoint:setButtonDisableState(false)
    self.btn_SL_subpoint:setButtonDisableState(false)
    self.btn_SL_Max:setButtonDisableState(false)
  else
    self.m_itemNum = self.m_itemNum + 1
    if self.m_itemNum == self.LimiteItemNum then
      self.btn_SL_addpoint:setButtonDisableState(false)
      self.btn_SL_Max:setButtonDisableState(false)
    end
    if self.m_itemNum < self.LimiteItemNum then
      if self.m_itemNum < self.itemNum then
        self.btn_SL_addpoint:setButtonDisableState(true)
        self.btn_SL_Max:setButtonDisableState(true)
      else
        self.btn_SL_addpoint:setButtonDisableState(false)
        self.btn_SL_Max:setButtonDisableState(false)
      end
    else
      self.btn_SL_addpoint:setButtonDisableState(false)
      self.btn_SL_Max:setButtonDisableState(false)
    end
    if self.m_itemNum > 1 then
      self.btn_SL_subpoint:setButtonDisableState(true)
    else
      self.btn_SL_subpoint:setButtonDisableState(false)
    end
  end
  if self.m_itemNum <= self.itemNum and self.m_itemNum >= 1 then
    self.txt_num:setText(tostring(self.m_itemNum))
  end
  self:setTotalPriceAndTax()
end
function CMarketStallBuyView:Btn_Max_SL(...)
  if self.m_itemNum == self.itemNum or self.m_itemNum == self.LimiteItemNum then
    ShowNotifyTips("已到达了最大上架数量")
    return
  end
  if self.itemNum <= self.LimiteItemNum then
    self.m_itemNum = self.itemNum
  else
    self.m_itemNum = self.LimiteItemNum
  end
  self.btn_SL_Max:setButtonDisableState(false)
  self.txt_num:setText(tostring(self.m_itemNum))
  self.btn_SL_subpoint:setButtonDisableState(true)
  self.btn_SL_addpoint:setButtonDisableState(false)
  self:setTotalPriceAndTax()
end
function CMarketStallBuyView:setTotalPriceAndTax()
  self.TotalPrice = self.itemPrice * self.m_itemNum
  self.tax = self.TotalPrice * self.RevenueRatio
  if self.TotalPrice > 0 then
    self.txt_ZongJia:setText(tostring(self.TotalPrice))
  else
    self.txt_ZongJia:setText(tostring(0))
  end
  if self.tax > 0 then
    self.txt_ShuiShou:setText(tostring(Value2Str(self.tax, 0)))
  else
    self.txt_ShuiShou:setText(tostring(0))
  end
  if self.LimiteItemNum == 1 then
    self:getNode("txt_shuliang"):setVisible(false)
    self:getNode("price_bg_1"):setVisible(false)
    self:getNode("txt_num"):setVisible(false)
    if self.btn_SL_addpoint then
      self.btn_SL_addpoint:setEnabled(false)
      self.btn_SL_addpoint:setVisible(false)
    end
    if self.btn_SL_subpoint then
      self.btn_SL_subpoint:setEnabled(false)
      self.btn_SL_subpoint:setVisible(false)
    end
    if self.btn_SL_Max then
      self.btn_SL_Max:setEnabled(false)
      self.btn_SL_Max:setVisible(false)
    end
  else
    self:getNode("txt_shuliang"):setVisible(true)
    self:getNode("price_bg_1"):setVisible(true)
    self:getNode("txt_num"):setVisible(true)
    if self.btn_SL_addpoint then
      self.btn_SL_addpoint:setVisible(true)
    end
    if self.btn_SL_subpoint then
      self.btn_SL_subpoint:setVisible(true)
    end
  end
end
function CMarketStallBuyView:setCoinIcon(iconNode)
  local x, y = self:getNode(iconNode):getPosition()
  local z = self:getNode(iconNode):getZOrder()
  local size = self:getNode(iconNode):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2 + 7, y + size.height / 2))
  self:addNode(tempImg, z)
end
function CMarketStallBuyView:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemSource_Jump then
    self:CloseSelf()
  end
end
function CMarketStallBuyView:Clear()
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
  end
  self.m_LeftBtnListener = nil
  self.m_RightBtnListener = nil
  self.m_CloseListener = nil
end
