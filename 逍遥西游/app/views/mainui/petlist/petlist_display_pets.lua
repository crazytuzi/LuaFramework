function _petTypeSortFunc(id_a, id_b)
  if id_a == nil or id_b == nil then
    return false
  end
  local data_a = data_Pet[id_a]
  local data_b = data_Pet[id_b]
  local sortLvType_a = data_a.LEVELTYPE
  local sortLvType_b = data_b.LEVELTYPE
  if data_getPetTypeIsGaoJiShouHu(id_a) then
    sortLvType_a = 1.5
  end
  if data_getPetTypeIsGaoJiShouHu(id_b) then
    sortLvType_b = 1.5
  end
  if sortLvType_a ~= sortLvType_b then
    return sortLvType_a < sortLvType_b
  elseif data_a.OPENLV ~= data_b.OPENLV then
    return data_a.OPENLV < data_b.OPENLV
  else
    return id_a < id_b
  end
end
local CDisplayPetBoardItem = class("CDisplayPetBoardItem", function()
  return Widget:create()
end)
function CDisplayPetBoardItem:ctor(petTypeId, isSel, petObjId)
  self.m_PetTypeId = petTypeId
  self.m_onePetObjId = petObjId
  self.m_IsOpen = self:getIsOpen()
  if self.m_IsOpen then
    self.m_PetHeandBg = display.newSprite("views/mainviews/pic_headiconbg.png")
  else
    self.m_PetHeandBg = display.newGraySprite("views/mainviews/pic_headiconbg.png")
  end
  self.m_PetHeandBg:setAnchorPoint(ccp(0.5, 0.5))
  self:addNode(self.m_PetHeandBg)
  self.m_PetHead = createHeadIconByRoleTypeID(self.m_PetTypeId, nil, not self.m_IsOpen)
  self.m_PetHead:setAnchorPoint(ccp(0.5, 0.5))
  self:addNode(self.m_PetHead, 1)
  self.m_PetHead:setPosition(HEAD_OFF_X, HEAD_OFF_Y)
  self.m_SelectScale = 1
  self.m_UnSelectScale = 0.8
  self.m_SelectOpacity = 255
  self.m_UnSelectOpacity = 150
  self.m_IsSelected = isSel
  if isSel then
    self:setSelected(true)
  else
    self:setScale(self.m_UnSelectScale)
    self:SetOpacity(self.m_UnSelectOpacity)
  end
  self:setTouchEnabled(false)
end
function CDisplayPetBoardItem:getIsOpen()
  local petData = data_Pet[self.m_PetTypeId]
  if petData == nil then
    return false
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return false
  end
  return mainHero:getProperty(PROPERTY_ZHUANSHENG) > 0 or mainHero:getProperty(PROPERTY_ROLELEVEL) >= petData.OPENLV
end
function CDisplayPetBoardItem:getPetTypeID()
  return self.m_PetTypeId
end
function CDisplayPetBoardItem:getPetObjId()
  return self.m_onePetObjId
end
function CDisplayPetBoardItem:setFadeIn()
  local dt = 0.5
  local opacity = self.m_UnSelectOpacity
  if self.m_ChoosedFrame and self.m_ChoosedFrame:isVisible() then
    opacity = self.m_SelectOpacity
  end
  self.m_PetHeandBg:setOpacity(0)
  self.m_PetHeandBg:runAction(CCFadeTo:create(dt, opacity))
  self.m_PetHead:setOpacity(0)
  self.m_PetHead:runAction(CCFadeTo:create(dt, opacity))
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeTo:create(dt, opacity))
  end
end
function CDisplayPetBoardItem:setSelected(flag)
  self:stopAllActions()
  self.m_IsSelected = flag
  if flag then
    self:runAction(CCScaleTo:create(0.15, self.m_SelectScale))
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("views/rolelist/pic_role_selected.png")
      self:addNode(self.m_ChoosedFrame, 2)
      local x, y = self.m_PetHeandBg:getPosition()
      self.m_ChoosedFrame:setPosition(x, y)
    end
    self.m_ChoosedFrame:setVisible(true)
    self:SetOpacity(self.m_SelectOpacity)
  else
    self:runAction(CCScaleTo:create(0.15, self.m_UnSelectScale))
    if self.m_ChoosedFrame then
      self.m_ChoosedFrame:setVisible(false)
    end
    self:SetOpacity(self.m_UnSelectOpacity)
  end
end
function CDisplayPetBoardItem:SetOpacity(a)
  self.m_PetHeandBg:setOpacity(a)
  self.m_PetHead:setOpacity(a)
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(a)
  end
end
CDisplayPetBoard = class("CDisplayPetBoard", function()
  return Widget:create()
end)
function CDisplayPetBoard:ctor(listParam, isMarket)
  self.m_PetTypeList = listParam.petTypeList
  self.m_ClickListener = listParam.clickListener
  self.m_PageListener = listParam.pageListener
  self.m_XYSpace = listParam.xySpace or ccp(5, 2)
  self.m_HeadSize = listParam.headSize or CCSize(75, 75)
  self.m_PageLines = listParam.pageLines or 4
  self.m_OneLineNum = listParam.oneLineNum or 3
  self.m_petObjIdList = listParam.petObjIdList or {}
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_ShowPagePoint = listParam.showPagePoint
  local mWidth = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  local initType = listParam.initType
  self.m_CurrSelectPet = -1
  self.m_CurrPageIndex = -1
  self.m_CurrPagePetObjs = {}
  self:setTotalPetList()
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self.m_PagePoint = {}
  self:SetPagePoint()
  local hasInit = false
  if initType ~= nil then
    for index, pType in ipairs(self.m_PetTypeList) do
      if initType == pType then
        local initPage = math.ceil(index / self.m_PageItemNum)
        self:ShowPackagePage(initPage, listParam.fadeoutAction)
        self:SetSelectPet(initType)
        hasInit = true
        break
      end
    end
  end
  if not hasInit then
    self:ShowPackagePage(1, listParam.fadeoutAction)
    if not isMarket then
      self:SetSelectAtIndex(1)
    end
  end
  self:setNodeEventEnabled(true)
end
function CDisplayPetBoard:SetSelectAtIndex(index)
  self.m_TouchBeganItem = self.m_CurrPagePetObjs[index]
  self:ClickAtPos()
end
function CDisplayPetBoard:SetSelectPet(petTypeId)
  for _, obj in pairs(self.m_CurrPagePetObjs) do
    if obj:getPetTypeID() == petTypeId then
      self.m_TouchBeganItem = obj
      self:ClickAtPos()
    end
  end
end
function CDisplayPetBoard:getTotalPageNum()
  return self.m_TotalPageNum
end
function CDisplayPetBoard:getCurrPageIndex()
  return self.m_CurrPageIndex
end
function CDisplayPetBoard:getFrameSize()
  local w = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function CDisplayPetBoard:setTotalPetList()
  table.sort(self.m_PetTypeList, _petTypeSortFunc)
  self.m_TotalPageNum = math.max(math.ceil(#self.m_PetTypeList / self.m_PageItemNum), 1)
end
function CDisplayPetBoard:SetPagePoint()
  if self.m_ShowPagePoint ~= false then
    local size = self:getSize()
    local midx = size.width / 2
    for page = 1, self.m_TotalPageNum do
      local pagePointBg = display.newSprite("views/pic/pic_page_unsel.png")
      pagePointBg:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(pagePointBg)
      local pagePoint = display.newSprite("views/pic/pic_page_sel.png")
      pagePoint:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(pagePoint)
      self.m_PagePoint[page] = pagePoint
      local x = midx + (page - (self.m_TotalPageNum + 1) / 2) * 25
      local y = -30
      pagePointBg:setPosition(x, y + 10)
      pagePoint:setPosition(x, y + 10)
    end
  end
end
function CDisplayPetBoard:OnPageChanged(curPage)
  if self.m_ShowPagePoint ~= false then
    for page, pagePoint in pairs(self.m_PagePoint) do
      pagePoint:setVisible(page == curPage)
    end
  end
end
function CDisplayPetBoard:ShowPackagePage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  self.m_CurrPageIndex = pageIndex
  for _, obj in pairs(self.m_CurrPagePetObjs) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_CurrPagePetObjs = {}
  local idIndex = 1 + self.m_PageItemNum * (self.m_CurrPageIndex - 1)
  local iWidth = self.m_HeadSize.width
  local iHeight = self.m_HeadSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local petTypeId = self.m_PetTypeList[idIndex]
      local petObjId = self.m_petObjIdList[idIndex]
      if petObjId ~= nil then
        local petIns = g_LocalPlayer:getObjById(petObjId)
        petTypeId = petIns:getTypeId()
      end
      if petTypeId ~= nil then
        local petObj = CDisplayPetBoardItem.new(petTypeId, self.m_CurrSelectPet == petTypeId, petObjId)
        self:addChild(petObj)
        local ox, oy = (iWidth + spacex) * (i - 1) + iWidth * 0.5, (iHeight + spacey) * (self.m_PageLines - line) + iHeight * 0.5
        petObj.m_OriPosXY = ccp(ox, oy)
        petObj:setPosition(petObj.m_OriPosXY)
        self.m_CurrPagePetObjs[#self.m_CurrPagePetObjs + 1] = petObj
        idIndex = idIndex + 1
        if showAction == true then
          petObj:setFadeIn()
        end
      end
    end
  end
  if self.m_PageListener then
    self.m_PageListener(self.m_CurrPageIndex, self.m_TotalPageNum)
  end
  self:OnPageChanged(self.m_CurrPageIndex)
end
function CDisplayPetBoard:ShowPrePackagePage()
  if self.m_CurrPageIndex <= 1 then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex - 1, true)
  return true
end
function CDisplayPetBoard:ShowNextPackagePage()
  if self.m_CurrPageIndex >= self.m_TotalPageNum then
    return false
  end
  self:ShowPackagePage(self.m_CurrPageIndex + 1, true)
  return true
end
function CDisplayPetBoard:OnTouchEvent(touchObj, event)
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
    else
      self:ClickAtPos()
    end
  end
end
function CDisplayPetBoard:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, headObj in pairs(self.m_CurrPagePetObjs) do
    local x, y = headObj:getPosition()
    if touchPos.x >= x - self.m_HeadSize.width / 2 and touchPos.x <= x + self.m_HeadSize.width / 2 and touchPos.y >= y - self.m_HeadSize.height / 2 and touchPos.y <= y + self.m_HeadSize.height / 2 then
      return headObj
    end
  end
  return nil
end
function CDisplayPetBoard:ClickAtPos()
  if self.m_TouchBeganItem == nil then
    return
  end
  local petTypeId = self.m_TouchBeganItem:getPetTypeID()
  local petObjId = self.m_TouchBeganItem:getPetObjId()
  if self.m_ClickListener then
    self.m_ClickListener(petTypeId, petObjId)
  end
  self.m_TouchBeganItem:setSelected(true)
  self.m_TouchBeganItem = nil
  self.m_CurrSelectPet = petTypeId
end
function CDisplayPetBoard:DrugAtPos(startPos, endPos)
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
function CDisplayPetBoard:ClearSelectItem()
  for _, petObj in pairs(self.m_CurrPagePetObjs) do
    petObj:setSelected(false)
  end
  self.m_CurrSelectPet = -1
end
function CDisplayPetBoard:ResetToOriPosXY()
  for _, petObj in pairs(self.m_CurrPagePetObjs) do
    petObj:stopAllActions()
    local oriPosXY = petObj.m_OriPosXY
    petObj:setPosition(oriPosXY)
  end
end
function CDisplayPetBoard:DrugCurrPage(offx)
  for _, petObj in pairs(self.m_CurrPagePetObjs) do
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
function CDisplayPetBoard:BackToOriPosXY()
  for _, petObj in pairs(self.m_CurrPagePetObjs) do
    local oriPosXY = petObj.m_OriPosXY
    petObj:stopAllActions()
    petObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CDisplayPetBoard:onCleanup()
  self.m_ClickListener = nil
  self.m_PageListener = nil
end
