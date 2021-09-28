local Package_COINPOS = -99999
function ShowAddBSDAfterWar(warType)
  if g_LocalPlayer:getLifeSkillBSD() == 0 and IsPVEWarType(warType) then
    ShowAddBSD()
  end
end
function ShowAddBSD()
  local curBSD = 0
  if g_LocalPlayer then
    curBSD = g_LocalPlayer:getLifeSkillBSD()
  end
  if curBSD >= LIFESKILL_MAX_BSD then
    ShowNotifyTips("饱食度已满，无需添加")
    return
  end
  getCurSceneView():addSubView({
    subView = CAddBSDView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CAddBSDView = class("CAddBSDView", CcsSubView)
function CAddBSDView:ctor(para)
  CAddBSDView.super.ctor(self, "views/addbaoshidu.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_makeitem = {
      listener = handler(self, self.OnBtn_MakeItem),
      variName = "btn_makeitem"
    },
    btn_buyitem = {
      listener = handler(self, self.OnBtn_BuyItem),
      variName = "btn_buyitem"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_coin = {
      listener = handler(self, self.OnBtn_Coin),
      variName = "btn_coin"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetBSDImg()
  self:UpdateBSD()
  self:SetPackage()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CAddBSDView:SetBSDImg()
  self.m_LifeSkillBSDImg = display.newSprite("views/lifeskill/lifeskill_bsd.png")
  self:addNode(self.m_LifeSkillBSDImg)
  local x, y = self:getNode("box_bsd"):getPosition()
  local size = self:getNode("box_bsd"):getContentSize()
  self.m_LifeSkillBSDImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
end
function CAddBSDView:UpdateBSD()
  local curBSD = g_LocalPlayer:getLifeSkillBSD()
  if curBSD >= LIFESKILL_MAX_BSD then
    self:CloseSelf()
    return
  end
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local needCoin = data_getBSDChangeCoin(lv, LIFESKILL_MAX_BSD - curBSD)
  self.m_NeedCoin = needCoin or 0
  local getBtnSize = self.btn_coin:getSize()
  if self.m_NeedCoinTxt == nil then
    self.m_NeedCoinTxt = RichText.new({
      width = getBtnSize.width,
      verticalSpace = 0,
      color = ccc3(0, 0, 0),
      font = KANG_TTF_FONT,
      fontSize = 23,
      align = CRichText_AlignType_Center
    })
    self.btn_coin:addChild(self.m_NeedCoinTxt, 10)
  end
  self.m_NeedCoinTxt:clearAll()
  if needCoin <= g_LocalPlayer:getCoin() then
    self.m_NeedCoinTxt:addRichText(string.format("#<IR1>%d#", needCoin))
  else
    self.m_NeedCoinTxt:addRichText(string.format("#<IR1,R>%d#", needCoin))
  end
  local size = self.m_NeedCoinTxt:getRichTextSize()
  self.m_NeedCoinTxt:setPosition(ccp(-getBtnSize.width / 2, -size.height / 2))
  self:getNode("txt_title"):setText(string.format("补充%d场饱食度", LIFESKILL_MAX_BSD - curBSD))
  self:getNode("btn_buyitem_txt"):setText("铜钱货摊")
end
function CAddBSDView:SetPackage()
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(90, 94),
    pageLines = 2,
    oneLineNum = 3
  }
  local tempSelectFunc = function(itemObj)
    local itemType = itemObj:getTypeId()
    if data_getLifeSkillType(itemType) ~= IETM_DEF_LIFESKILL_FOOD then
      return false
    end
    return true
  end
  self.m_PackageFrame = CPackageForBSD.new(function(itemObjId)
    if self then
      self:UseFood(itemObjId)
    end
  end, nil, param, tempSelectFunc)
  self.m_PackageFrame:setPosition(ccp(x, y + 40))
  self:addChild(self.m_PackageFrame, z + 100)
end
function CAddBSDView:UseFood(itemObjId)
  self:CloseEquipDetail()
  if itemObjId == Package_COINPOS then
    netsend.netlifeskill.addBSDWithMoney()
    return
  end
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if packageItemIns == nil then
    return
  end
  self.m_EquipDetail = CEquipDetail.new(itemObjId, {
    rightBtn = {
      btnText = "使用",
      listener = handler(self, self.OnUseItem)
    },
    closeListener = handler(self, self.CloseEquipDetail),
    fromPackageFlag = true,
    enableTouchDetect = false,
    opacityBg = 0
  })
  getCurSceneView():addSubView({
    subView = self.m_EquipDetail,
    zOrder = MainUISceneZOrder.menuView
  })
  local pos = self:getUINode():convertToWorldSpace(ccp(0, 0))
  pos = getCurSceneView():convertToNodeSpace(ccp(pos.x, pos.y))
  pos.y = pos.y + 115
  self.m_EquipDetail:setPosition(pos)
end
function CAddBSDView:OnUseItem(itemId)
  netsend.netitem.requestUseItem(itemId)
  self:CloseEquipDetail()
end
function CAddBSDView:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
  end
end
function CAddBSDView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CAddBSDView:OnBtn_Coin(obj, t)
  netsend.netlifeskill.addBSDWithMoney()
end
function CAddBSDView:OnBtn_MakeItem(obj, t)
  local curLifeSkillID, _ = g_LocalPlayer:getBaseLifeSkill()
  if curLifeSkillID == LIFESKILL_MAKEFOOD then
    ShowMakeLifeItem(curLifeSkillID)
    return
  else
    ShowNotifyTips("没有学会烹饪")
    return
  end
end
function CAddBSDView:OnBtn_BuyItem(obj, t)
  enterMarket({
    initViewType = MarketShow_InitShow_CoinView,
    initBaitanType = BaitanShow_InitShow_ShoppingView,
    initBaitanMainType = 6,
    initBaitanSubType = 1
  })
end
function CAddBSDView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_LifeSkillBSDUpdate then
    self:UpdateBSD()
  elseif msgSID == MsgID_MoneyUpdate then
    self:UpdateBSD()
  end
end
function CAddBSDView:Clear()
  self:CloseEquipDetail()
end
CPackageForBSD = class("CPackageForBSD", function()
  return Widget:create()
end)
function CPackageForBSD:ctor(clickListener, pageListener, listParam, exSelectFunc, exGetNumFunc, exGetCanUpgradeFunc)
  self.m_ClickListener = clickListener
  self.m_PageListener = pageListener
  self.m_ExSelectFunc = exSelectFunc or function(itemIns)
    return true
  end
  self.m_ExGetNumFunc = exGetNumFunc or function(itemIns)
    return itemIns:getProperty(ITEM_PRO_NUM)
  end
  self.m_ExGetCanUpgradeFunc = exGetCanUpgradeFunc or function(itemIns)
    return false
  end
  if listParam == nil then
    listParam = {}
  end
  self.m_ListParam = listParam
  self.m_XYSpace = listParam.xySpace or ccp(5, 2)
  self.m_ItemSize = listParam.itemSize or CCSize(100, 94)
  self.m_PageLines = listParam.pageLines or 4
  self.m_OneLineNum = listParam.oneLineNum or 5
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_MaxPageNum = listParam.maxPageNum
  self.m_PageIconOffY = listParam.pageIconOffY or -10
  if inRoleFlag == nil then
    inRoleFlag = false
  end
  self.m_InRoleFlag = inRoleFlag
  local mWidth = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  self.m_CurrPageIndex = -1
  self.m_CurrPageItemObjs = {}
  self:setTotalItemPosList()
  self.m_PagePoint = {}
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:ShowPackagePage(1, listParam.fadeoutAction)
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_ItemInfo)
  self.m_SelectedID = nil
end
function CPackageForBSD:getTotalPageNum()
  return self.m_TotalPageNum
end
function CPackageForBSD:getCurrPageIndex()
  return self.m_CurrPageIndex
end
function CPackageForBSD:getFrameSize()
  local w = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function CPackageForBSD:setTotalItemPosList()
  if self.m_TotalItemPosList == nil then
    self.m_TotalItemPosList = {}
  end
  local player = g_DataMgr:getPlayer()
  local OldPosList = DeepCopyTable(self.m_TotalItemPosList)
  self.m_TotalItemPosList = {}
  local typeList = {ITEM_LARGE_TYPE_LIFEITEM}
  for _, typeName in pairs(typeList) do
    local tempItemList = player:GetItemTypeList(typeName)
    for _, itemId in pairs(tempItemList) do
      local tempItemIns = player:GetOneItem(itemId)
      if tempItemIns ~= nil and self.m_ExSelectFunc(tempItemIns) then
        local tempPos = tempItemIns:getProperty(ITME_PRO_PACKAGE_POS)
        if tempPos ~= 0 and tempPos ~= nil then
          self.m_TotalItemPosList[#self.m_TotalItemPosList + 1] = tempPos
        end
      end
    end
  end
  table.sort(self.m_TotalItemPosList)
  for index, oldPos in ipairs(OldPosList) do
    if oldPos ~= Package_COINPOS then
      local tempId = g_LocalPlayer:GetItemIdByPos(oldPos)
      local tempItemIns = player:GetOneItem(tempId)
      if tempItemIns ~= nil then
        local tempLargeType = tempItemIns:getType()
        local isChooseLargeType = false
        for _, typeName in pairs(typeList) do
          if tempLargeType == typeName then
            isChooseLargeType = true
            break
          end
        end
        if isChooseLargeType and self.m_ExSelectFunc(tempItemIns) then
        else
          OldPosList[index] = 0
        end
      end
    end
  end
  local newItemPosList = {}
  for _, newPos in ipairs(self.m_TotalItemPosList) do
    local inFlag = false
    for _, oldPos in ipairs(OldPosList) do
      if oldPos == newPos then
        inFlag = true
        break
      end
    end
    if not inFlag then
      local hasEmptyFlag = false
      for index, oldPos in ipairs(OldPosList) do
        if oldPos ~= Package_COINPOS then
          local tempId = g_LocalPlayer:GetItemIdByPos(oldPos)
          if tempId == nil or tempId == 0 then
            OldPosList[index] = newPos
            hasEmptyFlag = true
            break
          end
        end
      end
      if not hasEmptyFlag then
        OldPosList[#OldPosList + 1] = newPos
      end
    end
  end
  self.m_TotalItemPosList = DeepCopyTable(OldPosList)
  if self.m_MaxPageNum then
    self.m_TotalPageNum = self.m_MaxPageNum
  else
    self.m_TotalPageNum = math.max(math.ceil(#self.m_TotalItemPosList / self.m_PageItemNum), 1)
  end
end
function CPackageForBSD:ShowPackagePage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  self.m_CurrPageIndex = pageIndex
  for _, obj in pairs(self.m_CurrPageItemObjs) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_CurrPageItemObjs = {}
  local pageItemIdList = {}
  local idIndex = 1 + self.m_PageItemNum * (self.m_CurrPageIndex - 1)
  local iWidth = self.m_ItemSize.width
  local iHeight = self.m_ItemSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local tempPos = self.m_TotalItemPosList[idIndex]
      local itemID = g_LocalPlayer:GetItemIdByPos(tempPos)
      local itemObj
      if tempPos == Package_COINPOS then
        itemObj = CPackageItemForBSD.new(itemPos, self.m_ExGetNumFunc, self.m_ExGetCanUpgradeFunc)
      else
        itemObj = CPackageFrameItem.new(tempPos, self.m_ExGetNumFunc, self.m_ExGetCanUpgradeFunc, nil, {})
      end
      itemObj:setSelected(self.m_SelectedID ~= nil and itemID == self.m_SelectedID)
      self:addChild(itemObj)
      local ox, oy = (iWidth + spacex) * (i - 1), (iHeight + spacey) * (self.m_PageLines - line)
      itemObj.m_OriPosXY = ccp(ox, oy)
      itemObj:setPosition(itemObj.m_OriPosXY)
      self.m_CurrPageItemObjs[#self.m_CurrPageItemObjs + 1] = itemObj
      idIndex = idIndex + 1
      if showAction == true then
        itemObj:setFadeIn()
      end
    end
  end
  if self.m_PageListener then
    self.m_PageListener(self.m_CurrPageIndex, self.m_TotalPageNum)
  end
  self:SetPagePoint()
end
function CPackageForBSD:SetPagePoint()
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
function CPackageForBSD:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex - 1, true)
  return true
end
function CPackageForBSD:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex + 1, true)
  return true
end
function CPackageForBSD:ReloadCurrPackge()
  self:setTotalItemPosList()
  local temp = self.m_CurrPageIndex
  self.m_CurrPageIndex = -1
  if temp > self.m_TotalPageNum then
    temp = self.m_TotalPageNum
  end
  self:ShowPackagePage(temp, false)
end
function CPackageForBSD:ClickPackageItem(itemID)
  if itemID == nil then
    return
  end
  if self.m_ClickListener then
    self.m_ClickListener(itemID)
  end
end
function CPackageForBSD:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self:ResetToOriPosXY()
    local startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(startPos)
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
      self:DrugCurrPage(movePos.x - startPos.x)
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
      self:DrugAtPos(startPos, endPos)
    else
      self:ClickAtPos()
    end
  end
end
function CPackageForBSD:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    local x, y = itemObj:getPosition()
    if x <= touchPos.x and touchPos.x <= x + self.m_ItemSize.width and y <= touchPos.y and touchPos.y <= y + self.m_ItemSize.height then
      itemObj:setTouchState(true)
      return itemObj
    end
  end
  return nil
end
function CPackageForBSD:getTouchBeganItem()
  return self.m_TouchBeganItem
end
function CPackageForBSD:JumpToItemPage(itemObjId, selectedFlag, showAction)
  if itemObjId == nil then
    return
  end
  local pageIndex, jumpToItemIndex
  for itemIndex, tempPos in pairs(self.m_TotalItemPosList) do
    local itemId = g_LocalPlayer:GetItemIdByPos(tempPos)
    if itemId == itemObjId and itemId ~= nil then
      jumpToItemIndex = itemIndex
      break
    end
  end
  if jumpToItemIndex ~= nil then
    if jumpToItemIndex % self.m_PageItemNum == 0 then
      pageIndex = jumpToItemIndex / self.m_PageItemNum
    else
      pageIndex = math.floor(jumpToItemIndex / self.m_PageItemNum) + 1
    end
  end
  if pageIndex ~= nil then
    self:ShowPackagePage(pageIndex, showAction)
  end
  if selectedFlag ~= false then
    self.m_SelectedID = itemObjId
    for _, item in pairs(self.m_CurrPageItemObjs) do
      if item:getItemID() == itemObjId then
        self.m_TouchBeganItem = item
        self:ClickPackageItem(itemObjId)
      end
      item:setSelected(false)
    end
    if self.m_SelectedID ~= nil then
      self.m_TouchBeganItem:setSelected(true)
    end
    self.m_TouchBeganItem:setTouchState(false)
    self.m_TouchBeganItem = nil
  end
  return pageIndex
end
function CPackageForBSD:ClickAtPos(startPos)
  if self.m_TouchBeganItem == nil then
    return
  end
  self:ClickPackageItem(self.m_TouchBeganItem:getItemID())
  self.m_SelectedID = self.m_TouchBeganItem:getItemID()
  for _, item in pairs(self.m_CurrPageItemObjs) do
    item:setSelected(false)
  end
  if self.m_SelectedID ~= nil then
    self.m_TouchBeganItem:setSelected(true)
  end
  self.m_TouchBeganItem:setTouchState(false)
  self.m_TouchBeganItem = nil
end
function CPackageForBSD:DrugAtPos(startPos, endPos)
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
function CPackageForBSD:ClearSelectItem()
  self.m_SelectedID = nil
  for _, item in pairs(self.m_CurrPageItemObjs) do
    item:setSelected(false)
  end
end
function CPackageForBSD:ResetToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    itemObj:stopAllActions()
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:setPosition(oriPosXY)
  end
end
function CPackageForBSD:DrugCurrPage(offx)
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    local oriPosXY = itemObj.m_OriPosXY
    local dx = offx / 30
    if dx < -7 then
      dx = -7
    elseif dx > 7 then
      dx = 7
    end
    itemObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
  end
end
function CPackageForBSD:BackToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:stopAllActions()
    itemObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CPackageForBSD:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem then
    self:ReloadCurrPackge()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:ReloadCurrPackge()
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    self:ReloadCurrPackge()
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    self:ReloadCurrPackge()
  end
end
function CPackageForBSD:onCleanup()
  self.m_ClickListener = nil
  self.m_PageListener = nil
  self.m_ExSelectFunc = nil
  self.m_ExGetNumFunc = nil
  self.m_ExGetCanUpgradeFunc = nil
end
CPackageItemForBSD = class("CPackageItemForBSD", function()
  return Widget:create()
end)
function CPackageItemForBSD:ctor(itemPos, exGetNumFunc, exGetCanUpgradeFunc)
  local itemBg = display.newSprite("xiyou/item/itembg.png")
  self.m_ItemBg = itemBg
  itemBg:setAnchorPoint(ccp(0, 0))
  self:addNode(itemBg)
  self.m_bgSize = itemBg:getContentSize()
  self.m_ItemIcon = nil
  self.m_ItemNumLabel = nil
  self.m_ItemTopRightIcon = nil
  self:SetIconImage()
  self:setTouchEnabled(false)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CPackageItemForBSD:getBoxSize()
  return self.m_bgSize
end
function CPackageItemForBSD:SetIconImage()
  if self.m_ItemIcon then
    self:removeNode(self.m_ItemIcon)
    self.m_ItemIcon = nil
    self.m_ItemNumLabel = nil
    self.m_ItemTopRightIcon = nil
  end
  local player = g_DataMgr:getPlayer()
  local iconPath = data_getResPathByResID(RESTYPE_COIN)
  local itemIcon = display.newSprite(iconPath)
  self.m_ItemIcon = itemIcon
  itemIcon:setAnchorPoint(ccp(0, 0))
  self:addNode(itemIcon)
  local iconSize = itemIcon:getContentSize()
  local x, y = (self.m_bgSize.width - iconSize.width) / 2, (self.m_bgSize.height - iconSize.height) / 2
  itemIcon:setPosition(x, y)
  local curBSD = g_LocalPlayer:getLifeSkillBSD()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local needCoin = data_getBSDChangeCoin(lv, LIFESKILL_MAX_BSD - curBSD)
  local num = needCoin
  local numLabel = CCLabelTTF:create(string.format("%s", num), ITEM_NUM_FONT, 22)
  numLabel:setAnchorPoint(ccp(1, 0))
  numLabel:setPosition(ccp(self.m_bgSize.width - 6 - x, 5 - y))
  if needCoin <= g_LocalPlayer:getCoin() then
    numLabel:setColor(ccc3(255, 255, 255))
  else
    numLabel:setColor(ccc3(255, 0, 0))
  end
  itemIcon:addChild(numLabel)
  AutoLimitObjSize(numLabel, 70)
  self.m_ItemNumLabel = numLabel
end
function CPackageItemForBSD:getItemID()
  return Package_COINPOS
end
function CPackageItemForBSD:setTouchState(flag)
  if flag then
    self.m_ItemBg:setColor(ccc3(200, 200, 200))
  else
    self.m_ItemBg:setColor(ccc3(255, 255, 255))
  end
end
function CPackageItemForBSD:setFadeIn()
  local dt = 0.5
  self.m_ItemBg:setOpacity(0)
  self.m_ItemBg:runAction(CCFadeIn:create(dt))
  if self.m_ItemIcon ~= nil then
    self.m_ItemIcon:setOpacity(0)
    self.m_ItemIcon:runAction(CCFadeIn:create(dt))
  end
  if self.m_ItemNumLabel ~= nil then
    self.m_ItemNumLabel:setOpacity(0)
    self.m_ItemNumLabel:runAction(CCFadeIn:create(dt))
  end
  if self.m_ItemTopRightIcon ~= nil then
    self.m_ItemTopRightIcon:setOpacity(0)
    self.m_ItemTopRightIcon:runAction(CCFadeIn:create(dt))
  end
  if self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeIn:create(dt))
  end
end
function CPackageItemForBSD:setSelected(flag)
  if flag == true then
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("xiyou/item/selecteditem.png")
      self:addNode(self.m_ChoosedFrame, 10)
      local size = self.m_ItemBg:getContentSize()
      self.m_ChoosedFrame:setPosition(ccp(size.width / 2, size.height / 2))
    end
  elseif self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:removeFromParent()
    self.m_ChoosedFrame = nil
  end
end
function CPackageItemForBSD:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_LifeSkillBSDUpdate then
    self:SetIconImage()
  elseif msgSID == MsgID_MoneyUpdate then
    self:SetIconImage()
  end
end
function CPackageItemForBSD:onCleanup()
  self:RemoveAllMessageListener()
end
