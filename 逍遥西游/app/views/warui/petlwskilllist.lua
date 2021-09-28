local CPetLWSkillFrame = class("CPetLWSkillFrame", function()
  return Widget:create()
end)
function CPetLWSkillFrame:ctor(skillList, listParam)
  skillList = skillList or {}
  if listParam == nil then
    listParam = {}
  end
  self.m_SkillIDList = DeepCopyTable(skillList)
  self.m_ListParam = listParam
  self.m_XYSpace = listParam.xySpace or ccp(5, 2)
  self.m_ItemSize = listParam.itemSize or CCSize(100, 94)
  self.m_PageLines = listParam.pageLines or 1
  self.m_OneLineNum = listParam.oneLineNum or 3
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_MaxPageNum = listParam.maxPageNum
  self.m_PageIconOffY = listParam.pageIconOffY or -10
  local mWidth = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  self:setTotalSkillIDList()
  self.m_CurrPageIndex = -1
  self.m_CurrPageSkillObjs = {}
  self.m_LongPressHandler = nil
  self.m_HasLongPressFlag = false
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
end
function CPetLWSkillFrame:setTotalSkillIDList()
  if self.m_MaxPageNum then
    self.m_TotalPageNum = self.m_MaxPageNum
  else
    self.m_TotalPageNum = math.max(math.ceil(#self.m_SkillIDList / self.m_PageItemNum), 1)
  end
end
function CPetLWSkillFrame:ShowPackagePage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  self.m_CurrPageIndex = pageIndex
  for _, obj in pairs(self.m_CurrPageSkillObjs) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_CurrPageSkillObjs = {}
  local pageItemIdList = {}
  local idIndex = 1 + self.m_PageItemNum * (self.m_CurrPageIndex - 1)
  local iWidth = self.m_ItemSize.width
  local iHeight = self.m_ItemSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local data = self.m_SkillIDList[(pageIndex - 1) * self.m_PageItemNum + (line - 1) * self.m_OneLineNum + i]
      if data ~= nil then
        local roleId, skillId, callFunc, flagDict = unpack(data, 1, 4)
        local skillObj = selectSkillItem.new(roleId, skillId, callFunc, flagDict)
        self:addChild(skillObj.m_UINode)
        skillObj:UnGetMessage()
        local ox, oy = (iWidth + spacex) * (i - 1), (iHeight + spacey) * (self.m_PageLines - line)
        skillObj.m_OriPosXY = ccp(ox, oy)
        skillObj:setPosition(skillObj.m_OriPosXY)
        self.m_CurrPageSkillObjs[#self.m_CurrPageSkillObjs + 1] = skillObj
        idIndex = idIndex + 1
        if showAction == true then
          skillObj:setFadeIn()
        end
      end
    end
  end
  self:setSelectSkill(self.m_SelectSkillId)
  self:SetPagePoint()
end
function CPetLWSkillFrame:SetPagePoint()
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
function CPetLWSkillFrame:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex - 1, true)
  return true
end
function CPetLWSkillFrame:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex + 1, true)
  return true
end
function CPetLWSkillFrame:ReloadCurrPackge()
  self:setTotalSkillIDList()
  local temp = self.m_CurrPageIndex
  self.m_CurrPageIndex = -1
  if temp > self.m_TotalPageNum then
    temp = self.m_TotalPageNum
  end
  self:ShowPackagePage(temp, false)
end
function CPetLWSkillFrame:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self:ResetToOriPosXY()
    local startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(startPos)
    self.m_HasTouchMoved = false
    self.m_LongPressMoveDel = 0
    if self.m_LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_LongPressHandler)
    end
    self.m_LongPressHandler = scheduler.scheduleGlobal(handler(self, self.longPressSchedule), 0.5)
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    self.m_LongPressMoveDel = self.m_LongPressMoveDel + math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y)
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem then
        self.m_TouchBeganItem = nil
      end
      self:DrugCurrPage(movePos.x - startPos.x)
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem = nil
      end
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
      self:DrugAtPos(startPos, endPos)
    end
    if self.m_HasLongPressFlag == false then
      if self.m_HasTouchMoved then
      else
        self:ClickAtPos()
      end
    else
      self:unLongPressSchedule()
    end
    if self.m_LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_LongPressHandler)
    end
    self.m_HasLongPressFlag = false
  end
end
function CPetLWSkillFrame:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, itemObj in pairs(self.m_CurrPageSkillObjs) do
    local x, y = itemObj:getPosition()
    if x <= touchPos.x and touchPos.x <= x + self.m_ItemSize.width and y <= touchPos.y and touchPos.y <= y + self.m_ItemSize.height then
      return itemObj
    end
  end
  return nil
end
function CPetLWSkillFrame:ClickAtPos(startPos)
  if self.m_TouchBeganItem == nil then
    return
  end
  local skillId = self.m_TouchBeganItem:getSkillId()
  if skillId == nil then
    return
  end
  self.m_TouchBeganItem:clickSkill()
  self.m_TouchBeganItem = nil
end
function CPetLWSkillFrame:longPressSchedule()
  if self.m_LongPressHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_LongPressHandler)
  end
  local startPos = self:getTouchStartPos()
  local movePos = self:getTouchMovePos()
  if self.m_LongPressMoveDel > 40 then
    return
  end
  if self.m_TouchBeganItem == nil then
    return
  end
  local skillId = self.m_TouchBeganItem:getSkillId()
  if skillId == nil then
    return
  end
  if self.m_LongPressHandler then
    self.m_TouchBeganItem:ShowLongPress()
    self.m_HasLongPressFlag = true
  end
end
function CPetLWSkillFrame:unLongPressSchedule()
  if g_Click_Skill_View ~= nil then
    g_Click_Skill_View:removeFromParentAndCleanup(true)
    g_Click_Skill_View = nil
  end
end
function CPetLWSkillFrame:DrugAtPos(startPos, endPos)
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
function CPetLWSkillFrame:ResetToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageSkillObjs) do
    itemObj:stopAllActions()
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:setPosition(oriPosXY)
  end
end
function CPetLWSkillFrame:DrugCurrPage(offx)
  for _, itemObj in pairs(self.m_CurrPageSkillObjs) do
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
function CPetLWSkillFrame:BackToOriPosXY()
  for _, itemObj in pairs(self.m_CurrPageSkillObjs) do
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:stopAllActions()
    itemObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CPetLWSkillFrame:onCleanup()
  self.m_SkillIDList = {}
end
function CPetLWSkillFrame:JumpToItemPage(skillId, selectedFlag, showAction)
  if skillId == nil then
    return
  end
  local pageIndex, jumpToItemIndex
  for index, tData in pairs(self.m_SkillIDList) do
    local roleId, tSkillId, callFunc, mpEnoughFlag, openFlag, unKnownFlag, cdFlag, proFlag, hasUseFlag = unpack(tData, 1, 9)
    if skillId == tSkillId then
      jumpToItemIndex = index
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
  return pageIndex
end
function CPetLWSkillFrame:setSelectSkill(skillId)
  self.m_SelectSkillId = skillId
  print("setSelectSkill", skillId)
  for _, btn in pairs(self.m_CurrPageSkillObjs) do
    if btn then
      if btn._SelectFlag then
        btn._SelectFlag:removeFromParent()
        btn._SelectFlag = nil
      end
      if skillId == btn:getSkillId() then
        local tempSprite = display.newSprite("views/common/btn/selected.png")
        tempSprite:setAnchorPoint(ccp(0.3, 0.3))
        local size = btn:getContentSize()
        tempSprite:setPosition(ccp(size.width / 2, size.height / 2))
        btn:addNode(tempSprite, 1)
        btn._SelectFlag = tempSprite
      end
    end
  end
end
return CPetLWSkillFrame
