local _chatItemSortFunc = function(id_a, id_b)
  if id_a == nil or id_b == nil then
    return false
  end
  local itemObj_a = g_LocalPlayer:GetOneItem(id_a)
  local itemObj_b = g_LocalPlayer:GetOneItem(id_b)
  if itemObj_a == nil then
    return false
  elseif itemObj_b == nil then
    return true
  end
  local eqpt_a = g_LocalPlayer:GetRoleIdFromItem(id_a)
  local eqpt_b = g_LocalPlayer:GetRoleIdFromItem(id_b)
  if eqpt_a ~= nil and eqpt_b == nil then
    return true
  elseif eqpt_a == nil and eqpt_b ~= nil then
    return false
  elseif eqpt_a ~= nil and eqpt_b ~= nil then
    if eqpt_a == g_LocalPlayer:getMainHeroId() and eqpt_b ~= g_LocalPlayer:getMainHeroId() then
      return true
    elseif eqpt_a ~= g_LocalPlayer:getMainHeroId() and eqpt_b == g_LocalPlayer:getMainHeroId() then
      return false
    end
  end
  local i_A = 100
  local i_B = 100
  local tempDict = {
    ITEM_LARGE_TYPE_DRUG,
    ITEM_LARGE_TYPE_EQPT,
    ITEM_LARGE_TYPE_SENIOREQPT,
    ITEM_LARGE_TYPE_SHENBING,
    ITEM_LARGE_TYPE_XIANQI,
    ITEM_LARGE_TYPE_GIFT,
    ITEM_LARGE_TYPE_OTHERITEM,
    ITEM_LARGE_TYPE_NEIDAN,
    ITEM_LARGE_TYPE_STUFF,
    ITEM_LARGE_TYPE_LIANYAOSHI
  }
  for index, largeType in ipairs(tempDict) do
    if largeType == itemObj_a:getType() then
      i_A = index
    end
    if largeType == itemObj_b:getType() then
      i_B = index
    end
  end
  if i_A ~= i_B then
    return i_A < i_B
  end
  local largeType = itemObj_a:getType()
  if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_SENIOREQPT or largeType == ITEM_LARGE_TYPE_SHENBING or largeType == ITEM_LARGE_TYPE_XIANQI then
    local w_A = 100
    local w_B = 100
    local tempDict = {
      ITEM_DEF_EQPT_WEAPON_XIANGLIAN,
      ITEM_DEF_EQPT_WEAPON_JIAN,
      ITEM_DEF_EQPT_WEAPON_DAO,
      ITEM_DEF_EQPT_WEAPON_BIAN,
      ITEM_DEF_EQPT_WEAPON_CHUI,
      ITEM_DEF_EQPT_WEAPON_GUN,
      ITEM_DEF_EQPT_WEAPON_ZHUA,
      ITEM_DEF_EQPT_WEAPON_QIANG,
      ITEM_DEF_EQPT_WEAPON_FU,
      ITEM_DEF_EQPT_WEAPON_SHAN,
      ITEM_DEF_EQPT_WEAPON_GOU,
      ITEM_DEF_EQPT_WEAPON_FUCHEN,
      ITEM_DEF_EQPT_WEAPON_QUANTAO,
      ITEM_DEF_EQPT_WEAPON_SIDAI,
      ITEM_DEF_EQPT_WEAPON_PAN,
      ITEM_DEF_EQPT_WEAPON_TOUKUI,
      ITEM_DEF_EQPT_WEAPON_YIFU,
      ITEM_DEF_EQPT_WEAPON_XIEZI,
      ITEM_DEF_EQPT_WEAPON_YAODAI,
      ITEM_DEF_EQPT_WEAPON_GUANJIAN,
      ITEM_DEF_EQPT_WEAPON_CHIBANG,
      ITEM_DEF_EQPT_WEAPON_MIANJU,
      ITEM_DEF_EQPT_WEAPON_PIFENG
    }
    for index, wType in ipairs(tempDict) do
      if wType == itemObj_a:getProperty(ITEM_PRO_EQPT_TYPE) then
        w_A = index
      end
      if wType == itemObj_b:getProperty(ITEM_PRO_EQPT_TYPE) then
        w_B = index
      end
    end
    if w_A ~= w_B then
      return w_A < w_B
    end
  end
  local shapeA = itemObj_a:getTypeId()
  local shapeB = itemObj_b:getTypeId()
  if shapeA ~= shapeB then
    return shapeA < shapeB
  end
  local numA = itemObj_a:getProperty(ITEM_PRO_NUM)
  local numB = itemObj_b:getProperty(ITEM_PRO_NUM)
  if numA ~= numB then
    return numA > numB
  end
  return id_a < id_b
end
local CChatItemFrameItem = class("CChatItemFrameItem", function()
  return Widget:create()
end)
function CChatItemFrameItem:ctor(itemId)
  local itemBg = display.newSprite("xiyou/item/itembg.png")
  self.m_ItemBg = itemBg
  itemBg:setAnchorPoint(ccp(0, 0))
  self:addNode(itemBg)
  self.m_bgSize = itemBg:getContentSize()
  self.m_ItemIcon = nil
  self.m_ItemNumLabel = nil
  self.m_ItemId = itemId
  self:SetIconImage()
  self:SetItemNum()
  self:setTouchEnabled(false)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_ItemInfo)
end
function CChatItemFrameItem:getBoxSize()
  return self.m_bgSize
end
function CChatItemFrameItem:SetIconImage()
  if self.m_ItemIcon then
    self:removeNode(self.m_ItemIcon)
    self.m_ItemIcon = nil
    self.m_ItemNumLabel = nil
  end
  local player = g_DataMgr:getPlayer()
  if player == nil then
    return
  end
  local itemObj = player:GetOneItem(self.m_ItemId)
  if itemObj == nil then
    return
  end
  local itemShape = itemObj:getProperty(ITEM_PRO_SHAPE)
  local iconPath = data_getItemPathByShape(itemShape)
  local itemIcon = display.newSprite(iconPath)
  self.m_ItemIcon = itemIcon
  itemIcon:setAnchorPoint(ccp(0, 0))
  self:addNode(itemIcon)
  local iconSize = itemIcon:getContentSize()
  local x, y = (self.m_bgSize.width - iconSize.width) / 2, (self.m_bgSize.height - iconSize.height) / 2
  itemIcon:setPosition(x, y)
  if g_LocalPlayer:GetRoleIdFromItem(self.m_ItemId) ~= nil then
    local iconEquip = display.newSprite("views/pic/pic_itemequip.png")
    iconEquip:setAnchorPoint(ccp(0, 1))
    self:addNode(iconEquip, 20)
    iconEquip:setPosition(ccp(0, y + iconSize.height))
    self.m_IconEquip = iconEquip
  end
end
function CChatItemFrameItem:SetItemNum()
  local player = g_DataMgr:getPlayer()
  if player == nil then
    return
  end
  local itemObj = player:GetOneItem(self.m_ItemId)
  if itemObj == nil then
    return
  end
  if self.m_ItemIcon == nil then
    return
  end
  local canMerge = itemObj:getProperty(ITEM_PRO_CANMERGE)
  if canMerge ~= 0 and canMerge ~= 1 then
    local num = itemObj:getProperty(ITEM_PRO_NUM)
    if self.m_ItemNumLabel == nil then
      local numLabel = CCLabelTTF:create(string.format("%s", num), ITEM_NUM_FONT, 22)
      numLabel:setAnchorPoint(ccp(1, 0))
      local x, y = self.m_ItemIcon:getPosition()
      numLabel:setPosition(ccp(self.m_bgSize.width - 6 - x, 5 - y))
      numLabel:setColor(ccc3(255, 255, 255))
      self:addNode(numLabel, 10)
      self.m_ItemNumLabel = numLabel
    else
      self.m_ItemNumLabel:setString(string.format("%s", num))
    end
    AutoLimitObjSize(self.m_ItemNumLabel, 70)
  end
end
function CChatItemFrameItem:getItemID()
  return self.m_ItemId
end
function CChatItemFrameItem:setTouchState(flag)
  if flag then
    self.m_ItemBg:setColor(ccc3(200, 200, 200))
  else
    self.m_ItemBg:setColor(ccc3(255, 255, 255))
  end
end
function CChatItemFrameItem:setFadeIn()
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
  if self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeIn:create(dt))
  end
  if self.m_IconEquip ~= nil then
    self.m_IconEquip:setOpacity(0)
    self.m_IconEquip:runAction(CCFadeIn:create(dt))
  end
end
function CChatItemFrameItem:setSelected(flag)
  if flag == true then
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("xiyou/item/selecteditem.png")
      self:addNode(self.m_ChoosedFrame, 99)
      local size = self.m_ItemBg:getContentSize()
      self.m_ChoosedFrame:setPosition(ccp(size.width / 2, size.height / 2))
    end
  elseif self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:removeFromParent()
    self.m_ChoosedFrame = nil
  end
end
function CChatItemFrameItem:onCleanup()
  self:RemoveAllMessageListener()
end
function CChatItemFrameItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    if para.itemId == self.m_ItemId then
      self:SetItemNum()
    end
  end
end
CChatItemFrame = class("CChatItemFrame", function()
  return Widget:create()
end)
function CChatItemFrame:ctor(clickListener, listParam)
  self.m_ClickListener = clickListener
  if listParam == nil then
    listParam = {}
  end
  self.m_ListParam = listParam
  self.m_XYSpace = listParam.xySpace or ccp(5, 2)
  self.m_ItemSize = listParam.itemSize or CCSize(100, 94)
  self.m_PageLines = listParam.pageLines or 4
  self.m_OneLineNum = listParam.oneLineNum or 5
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_PageIconOffY = listParam.pageIconOffY or -30
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
function CChatItemFrame:getTotalPageNum()
  return self.m_TotalPageNum
end
function CChatItemFrame:getCurrPageIndex()
  return self.m_CurrPageIndex
end
function CChatItemFrame:getFrameSize()
  local w = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function CChatItemFrame:setTotalItemPosList()
  self.m_TotalItemIdList = g_LocalPlayer:GetAllItemIdListExceptHuoBanAndTask()
  table.sort(self.m_TotalItemIdList, _chatItemSortFunc)
  self.m_TotalPageNum = math.max(math.ceil(#self.m_TotalItemIdList / self.m_PageItemNum), 1)
end
function CChatItemFrame:ShowPackagePage(pageIndex, showAction)
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
      local itemID = self.m_TotalItemIdList[idIndex]
      if itemID ~= nil then
        local itemObj = CChatItemFrameItem.new(itemID)
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
  end
  self:SetPagePoint()
end
function CChatItemFrame:SetPagePoint()
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
function CChatItemFrame:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex - 1, true)
  return true
end
function CChatItemFrame:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex + 1, true)
  return true
end
function CChatItemFrame:ReloadCurrPackge()
  self:setTotalItemPosList()
  local temp = self.m_CurrPageIndex
  self.m_CurrPageIndex = -1
  if temp > self.m_TotalPageNum then
    temp = self.m_TotalPageNum
  end
  self.m_SelectedID = nil
  self:ShowPackagePage(temp, false)
end
function CChatItemFrame:ClickPackageItem(itemID)
  if itemID == nil then
    return
  end
  if self.m_ClickListener then
    self.m_ClickListener(itemID)
  end
end
function CChatItemFrame:OnTouchEvent(touchObj, event)
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
function CChatItemFrame:checkTouchBeganPos(pos)
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
function CChatItemFrame:getTouchBeganItem()
  return self.m_TouchBeganItem
end
function CChatItemFrame:ClickAtPos(startPos)
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
function CChatItemFrame:DrugAtPos(startPos, endPos)
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
function CChatItemFrame:ClearSelectItem()
  self.m_SelectedID = nil
  for _, item in pairs(self.m_CurrPageItemObjs) do
    item:setSelected(false)
  end
end
function CChatItemFrame:ResetToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    itemObj:stopAllActions()
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:setPosition(oriPosXY)
  end
end
function CChatItemFrame:DrugCurrPage(offx)
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
function CChatItemFrame:BackToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageItemObjs) do
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:stopAllActions()
    itemObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CChatItemFrame:OnMessage(msgSID, ...)
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
function CChatItemFrame:onCleanup()
  self.m_ClickListener = nil
  self:RemoveAllMessageListener()
end
