MARKET_SCROLL_BUY_VIEW = 1
MARKET_SCROLL_SELL_VIEW = 2
marketShoppingBoard = class("marketShoppingBoard", function()
  return Widget:create()
end)
function marketShoppingBoard:ctor(viewTag, marketDirKey, listParam, initMid)
  listParam = listParam or {}
  self.m_ViewTag = viewTag or MARKET_SCROLL_BUY_VIEW
  self.m_MarketDirKey = marketDirKey
  self.m_initMid = initMid
  if self.m_MarketDirKey == 0 then
    self:SetFlushFlag(not g_BaitanDataMgr:GetIsSellingFlag())
  else
    self:SetFlushFlag(true)
  end
  self.m_GoodIDList = {}
  self.m_ClickListener = listParam.clickListener
  self.m_PageListener = listParam.pageListener
  self.m_XYSpace = listParam.xySpace or ccp(5, 15)
  self.m_HeadSize = listParam.headSize or CCSize(252, 100)
  self.m_PageLines = listParam.pageLines or 3
  self.m_OneLineNum = listParam.oneLineNum or 2
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_PageIconOffY = listParam.pageIconOffY or -30
  self.m_bgNode = listParam.bgNode
  local x, y = self.m_bgNode:getPosition()
  self.m_bg_x = x
  self.m_bg_y = y
  self.m_bgSize = self.m_bgNode:getContentSize()
  local mWidth = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  self.m_CurrSelectGoods = -1
  self.m_CurrPageIndex = -1
  self.m_CurrPageItemObjs = {}
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self:setTotalGoodsList()
  self.m_PagePoint = {}
  self:SetPagePoint()
  self:ShowPackagePage(1, listParam.fadeoutAction)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Stall)
end
function marketShoppingBoard:setTotalGoodsList()
  self.m_GoodIDList = {}
  local goodData = {}
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
    goodData = g_BaitanDataMgr:GetGoodsData(self.m_MarketDirKey)
    local tempList = {}
    for goodID, _ in pairs(goodData) do
      tempList[#tempList + 1] = goodID
    end
    table.sort(tempList)
    self.m_GoodIDList = tempList
  else
    goodData = g_BaitanDataMgr:GetGoodsData(0)
    local tempList = {}
    for goodID, tempData in pairs(goodData) do
      local soutFlag = false
      local toutFlag = false
      local tixianFlag = false
      if 0 < tempData.num and 0 < tempData.son then
        tixianFlag = true
      end
      if tempData.num == nil or 0 >= tempData.num then
        soutFlag = true
      end
      if tempData.s == MARKET_SCROLL_ITEM_STATE_OTIME then
        toutFlag = true
      end
      if soutFlag == true then
        toutFlag = false
      end
      if tixianFlag == true then
        toutFlag = false
      end
      local sortNum = 999
      if soutFlag then
        sortNum = 1
      elseif tixianFlag then
        sortNum = 2
      elseif toutFlag then
        sortNum = 3
      end
      tempList[#tempList + 1] = {goodID, sortNum}
    end
    local cmp = function(d1, d2)
      if d1 == nil or d2 == nil then
        return false
      end
      if d1[2] ~= d2[2] then
        return d1[2] < d2[2]
      else
        return d1[1] < d2[1]
      end
    end
    table.sort(tempList, cmp)
    for _, tData in ipairs(tempList) do
      self.m_GoodIDList[#self.m_GoodIDList + 1] = tData[1]
    end
  end
  self.m_TotalPageNum = math.max(math.ceil(#self.m_GoodIDList / self.m_PageItemNum), 1)
  local showEmptyImageFlag = false
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW and #self.m_GoodIDList <= 0 then
    showEmptyImageFlag = true
  end
  self:showEmptyImageFlag(showEmptyImageFlag)
end
function marketShoppingBoard:showEmptyImageFlag(flag)
  if not flag then
    if self.m_EmptyLable then
      self.m_EmptyLable:removeFromParent()
      self.m_EmptyLable = nil
    end
    if self.m_EmptyIcon then
      self.m_EmptyIcon:removeFromParent()
      self.m_EmptyIcon = nil
    end
  else
    local size = self:getFrameSize()
    local x, y = size.width / 2, size.height / 2
    if self.m_EmptyLable == nil then
      self.m_EmptyLable = ui.newTTFLabel({
        text = "找遍了也没有发现有人卖哦",
        font = KANG_TTF_FONT,
        color = ccc3(78, 47, 20)
      })
      self.m_EmptyLable:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(self.m_EmptyLable, 2)
      self.m_EmptyLable:setPosition(ccp(x, y - 85))
      local fadein = CCFadeIn:create(0.5)
      self.m_EmptyLable:runAction(fadein)
    end
    if self.m_EmptyIcon == nil then
      self.m_EmptyIcon = display.newSprite("views/market/pic_empty.png")
      self.m_EmptyIcon:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(self.m_EmptyIcon, 1)
      self.m_EmptyIcon:setPosition(ccp(x, y))
      local fadein = CCFadeIn:create(0.5)
      self.m_EmptyIcon:runAction(fadein)
    end
  end
end
function marketShoppingBoard:ReloadCurrPackge()
  if self.m_CanFlushFlag == false then
    print("self.m_CanFlushFlag 为false，不刷新")
    return
  end
  self.m_TouchBeganItem = nil
  self:setTotalGoodsList()
  local temp = self.m_CurrPageIndex
  self.m_CurrPageIndex = -1
  if temp > self.m_TotalPageNum then
    temp = self.m_TotalPageNum
  end
  self:ShowPackagePage(temp, false)
end
function marketShoppingBoard:SetPagePoint()
  for page, pagePoint in pairs(self.m_PagePoint) do
    pagePoint:removeFromParent()
  end
  self.m_PagePoint = {}
  if self.m_TotalPageNum > 1 then
    local size = self:getSize()
    local midx = size.width / 2
    local spacex = 25
    for page = 1, self.m_TotalPageNum do
      local pagePointBg = display.newSprite("views/pic/pic_page_unsel.png")
      pagePointBg:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(pagePointBg)
      self.m_PagePoint[#self.m_PagePoint + 1] = pagePointBg
      local x = midx + (page - (self.m_TotalPageNum + 1) / 2) * spacex
      pagePointBg:setPosition(x, self.m_PageIconOffY)
    end
    local curPage = self.m_CurrPageIndex
    local pagePoint = display.newSprite("views/pic/pic_page_sel.png")
    pagePoint:setAnchorPoint(ccp(0.5, 0.5))
    self:addNode(pagePoint)
    local x = midx + (curPage - (self.m_TotalPageNum + 1) / 2) * spacex
    self.m_PagePoint[#self.m_PagePoint + 1] = pagePoint
    pagePoint:setPosition(x, self.m_PageIconOffY)
  end
end
function marketShoppingBoard:ShowPackagePage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  self.m_CurrPageIndex = pageIndex
  for _, obj in pairs(self.m_CurrPageItemObjs) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_CurrPageItemObjs = {}
  local idIndex = 1 + self.m_PageItemNum * (self.m_CurrPageIndex - 1)
  local iWidth = self.m_HeadSize.width
  local iHeight = self.m_HeadSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local goodId = self.m_GoodIDList[idIndex]
      if goodId ~= nil then
        local goodData = g_BaitanDataMgr:GetOneGoodSellingData(goodId)
        local itemObj = g_BaitanDataMgr:GetOneGood(goodId)
        if goodData ~= nil and itemObj ~= nil then
          local item = CMarketGoodsItem.new(goodId, self.m_ViewTag)
          self:addChild(item:getUINode())
          local ox, oy = (iWidth + spacex) * (i - 1), (iHeight + spacey) * (self.m_PageLines - line)
          item.m_OriPosXY = ccp(ox, oy)
          item:setPosition(item.m_OriPosXY)
          self.m_CurrPageItemObjs[#self.m_CurrPageItemObjs + 1] = item
          idIndex = idIndex + 1
          if showAction == true then
            item:setFadeIn()
          end
        end
      end
    end
  end
  if self.m_PageListener then
    self.m_PageListener(self.m_CurrPageIndex, self.m_TotalPageNum)
  end
  self:SetPagePoint(self.m_CurrPageIndex)
end
function marketShoppingBoard:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex - 1, true)
  return true
end
function marketShoppingBoard:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex + 1, true)
  return true
end
function marketShoppingBoard:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self:ResetToOriPosXY()
    self.startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(self.startPos)
    self.m_HasTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      self:ClearSelectItem()
      self:DrugCurrPage(movePos.x - startPos.x)
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      self:ClearSelectItem()
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
      self:DrugAtPos(startPos, endPos)
    else
      self:ClickAtPos()
    end
  end
end
function marketShoppingBoard:ClickAtPos()
  if self.m_TouchBeganItem == nil then
    return
  end
  self:ClearSelectItem()
  self.m_TouchBeganItem:SetItemChoosed(true)
  local itemId = self.m_TouchBeganItem:getItemID()
  self.m_TouchBeganItem = nil
  self:ClickPackageItem(itemId)
  for _, item in pairs(self.m_CurrPageItemObjs) do
    item:setTouchState(false)
  end
end
function marketShoppingBoard:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    local x, y = itemObj:getPosition()
    if x <= touchPos.x and touchPos.x <= x + self.m_HeadSize.width and y <= touchPos.y and touchPos.y <= y + self.m_HeadSize.height then
      itemObj:setTouchState(true)
      return itemObj
    end
  end
  return nil
end
function marketShoppingBoard:DrugAtPos(startPos, endPos)
  local offx = endPos.x - startPos.x
  if offx > 20 then
    if not self:ShowPrePackagePage() then
      self:BackToOriPosXY()
    end
  elseif offx < -20 then
    if not self:ShowNextPackagePage() then
      self:BackToOriPosXY()
    end
  else
    self:BackToOriPosXY()
  end
end
function marketShoppingBoard:ClearSelectItem()
  for _, petObj in pairs(self.m_CurrPageItemObjs) do
    petObj:SetItemChoosed(false)
  end
end
function marketShoppingBoard:ResetToOriPosXY()
  for _, petObj in pairs(self.m_CurrPageItemObjs) do
    petObj:stopAllActions()
    local oriPosXY = petObj.m_OriPosXY
    petObj:setPosition(oriPosXY)
  end
end
function marketShoppingBoard:DrugCurrPage(offx)
  for _, petObj in pairs(self.m_CurrPageItemObjs) do
    local oriPosXY = petObj.m_OriPosXY
    local dx = offx / 30
    if dx < -7 then
      dx = -7
    elseif dx > 7 then
      dx = 7
    end
    petObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
  end
end
function marketShoppingBoard:BackToOriPosXY()
  for _, petObj in pairs(self.m_CurrPageItemObjs) do
    local oriPosXY = petObj.m_OriPosXY
    petObj:stopAllActions()
    petObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function marketShoppingBoard:ClickPackageItem(goodId)
  print("ClickPackageItem", goodId)
  soundManager.playSound("xiyou/sound/clickbutton_2.wav")
  local oneGoodData = g_BaitanDataMgr:GetOneGoodSellingData(goodId)
  local itemObj = g_BaitanDataMgr:GetOneGood(goodId)
  if oneGoodData == nil or itemObj == nil then
    ShowNotifyTips("货品已失效")
    return
  end
  if self.m_ViewTag == MARKET_SCROLL_BUY_VIEW then
    if oneGoodData.num <= 0 then
      ShowNotifyTips("该货品已售罄")
      return
    end
    if oneGoodData.s == MARKET_SCROLL_ITEM_STATE_OTIME then
      ShowNotifyTips("该货品已超时")
      return
    end
  end
  if oneGoodData.ispet == 0 then
    if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
      if oneGoodData.num == 0 then
        netsend.netstall.withDrawals(goodId)
        return
      elseif oneGoodData.num > 0 and 0 < oneGoodData.son then
        netsend.netstall.withDrawals(goodId)
        return
      else
        local tempView = CMarketShoppingView.new(goodId, {
          leftBtn = {btnText = "下架"},
          rightBtn = {
            btnText = "重新上架"
          }
        }, MARKET_SCROLL_SELL_VIEW, {
          bg_x = self.m_bg_x,
          bg_y = self.m_bg_y,
          bgSize = self.m_bgSize
        })
        self.m_bgNode:getParent():addChild(tempView.m_UINode, MainUISceneZOrder.menuView)
      end
    else
      local needCount
      if self.m_initMid ~= nil then
        local itemObj = g_BaitanDataMgr:GetOneGood(goodId)
        if itemObj then
          needCount = g_MissionMgr:getMissionShortageObjs(self.m_initMid, itemObj.m_LtypeId, true)
        end
      end
      print(" ///////////    needCount ", needCount, self.m_initMid, goodId)
      local tempView = CMarketShoppingView.new(goodId, {
        leftBtn = {btnText = "取消"},
        rightBtn = {btnText = "购买"}
      }, MARKET_SCROLL_BUY_VIEW, {
        bg_x = self.m_bg_x,
        bg_y = self.m_bg_y,
        bgSize = self.m_bgSize
      }, needCount)
      self.m_bgNode:getParent():addChild(tempView.m_UINode, MainUISceneZOrder.menuView)
    end
  elseif self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    if oneGoodData.num == 0 then
      netsend.netstall.withDrawals(goodId)
      return
    else
      local tempView = CMarketPetView.new(goodId, oneGoodData.pid, {
        leftBtn = {btnText = "下架"},
        rightBtn = {
          btnText = "重新上架"
        },
        bg_x = self.m_bg_x,
        bg_y = self.m_bg_y,
        bgSize = self.m_bgSize
      }, true, MARKET_PET_SELF_SELL_VIEW, oneGoodData.state, oneGoodData.p)
      self.m_bgNode:getParent():addChild(tempView.m_UINode, MainUISceneZOrder.menuView)
    end
  else
    local tempView = CMarketPetView.new(goodId, oneGoodData.pid, {
      leftBtn = {btnText = "取消"},
      rightBtn = {btnText = "购买"},
      bg_x = self.m_bg_x,
      bg_y = self.m_bg_y,
      bgSize = self.m_bgSize
    }, true, MARKET_PET_BUY_VIEW, nil, oneGoodData.p)
    self.m_bgNode:getParent():addChild(tempView.m_UINode, MainUISceneZOrder.menuView)
  end
end
function marketShoppingBoard:SetFlushFlag(flag)
  self.m_CanFlushFlag = flag
end
function marketShoppingBoard:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Stall_GetOneDirData then
    if arg[1].dirKey == self.m_MarketDirKey then
      self:ReloadCurrPackge()
    end
  elseif msgSID == MsgID_Stall_DelOneGood then
    if arg[1].dirKey == self.m_MarketDirKey then
      self:ReloadCurrPackge()
    end
  elseif msgSID == MsgID_Stall_UpdateOneGood then
    if arg[1].dirKey == self.m_MarketDirKey and self.m_MarketDirKey == 0 then
      self:ReloadCurrPackge()
    end
  elseif msgSID == MsgID_Stall_StallOneGood then
    if arg[1].dirKey == self.m_MarketDirKey and self.m_MarketDirKey == 0 then
      self:ReloadCurrPackge()
    end
  elseif msgSID == MsgID_Stall_UpdateIsSellingFlag and self.m_MarketDirKey == 0 then
    self:SetFlushFlag(not g_BaitanDataMgr:GetIsSellingFlag())
    self:ReloadCurrPackge()
  end
end
function marketShoppingBoard:getToucheItem()
  return self.m_TouchBeganItem
end
function marketShoppingBoard:getTotalPageNum()
  return self.m_TotalPageNum
end
function marketShoppingBoard:getCurrPageIndex()
  return self.m_CurrPageIndex
end
function marketShoppingBoard:getFrameSize()
  local w = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function marketShoppingBoard:onCleanup()
  self.m_ClickListener = nil
  self.m_PageListener = nil
  self.m_CurrPageItemObjs = {}
end
