CPetBoard = class(".CPetBoard", function()
  return Widget:create()
end)
function CPetBoard:ctor(param)
  self.m_NumPerRow = param.numPerRow or 4
  self.m_RowHeight = param.rowHeight or 130
  self.m_RowNumPerPage = param.rowsNum or 2
  self.m_SpaceX = param.spaceX or 15
  self.m_ClickListener = param.clickListener
  self.m_PetIns = {}
  local temp = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  self.m_PetIdList = DeepCopyTable(temp)
  self.m_RowNum = math.ceil(#self.m_PetIdList / self.m_NumPerRow)
  self.m_TotalPage = math.ceil(self.m_RowNum / self.m_RowNumPerPage)
  local w = 0
  local h = self.m_RowHeight * self.m_RowNumPerPage
  for row = 1, self.m_RowNum do
    local insList = {}
    self.m_PetIns[row] = insList
    local offx = self.m_SpaceX
    local offy = (self.m_RowNumPerPage - (row - 1) % self.m_RowNumPerPage - 0.5) * self.m_RowHeight
    for i = 1, self.m_NumPerRow do
      local index = (row - 1) * self.m_NumPerRow + i
      local petId = self.m_PetIdList[index]
      if petId ~= nil then
        local petObj = g_LocalPlayer:getObjById(petId)
        if petObj then
          local petTypeId = petObj:getTypeId()
          local petHead = createWidgetFrameHeadIconByRoleTypeID(petTypeId)
          self:addChild(petHead)
          local size = petHead:getContentSize()
          petHead:setPosition(ccp(offx + size.width / 2, offy))
          local ex, ey = petHead:getPosition()
          petHead.m_OriPosXY = ccp(ex, ey)
          offx = offx + size.width + self.m_SpaceX
          petHead:setScale(0.9)
          petHead._HeadIcon:setOpacity(150)
          insList[#insList + 1] = petHead
        end
      end
    end
    if w < offx then
      w = offx
    end
  end
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(w, h))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:creatPageIndexObj()
  self.m_PageIndex = -1
  self:ShowPetPage(1, false)
  self:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      self.m_HasTouchMoved = false
    elseif t == TOUCH_EVENT_MOVED then
      if not self.m_HasTouchMoved then
        local startPos = self:getTouchStartPos()
        local movePos = self:getTouchMovePos()
        if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 10 then
          self.m_HasTouchMoved = true
        end
      else
        local startPos = self:getTouchStartPos()
        local movePos = self:getTouchMovePos()
        self:DrugCurrPage(movePos.x - startPos.x)
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if not self.m_HasTouchMoved then
        local startPos = self:getTouchStartPos()
        local pos = self:convertToNodeSpace(ccp(startPos.x, startPos.y))
        self:CheckClick(pos.x, pos.y)
      else
        local startPos = self:getTouchStartPos()
        local endPos = self:getTouchEndPos()
        self:CheckDrag(endPos.x - startPos.x)
      end
    end
  end)
  self:setNodeEventEnabled(true)
end
function CPetBoard:creatPageIndexObj()
  if self.m_TotalPage > 1 then
    local spaceX = 25
    self.m_PageIndexObj = {}
    local size = self:getContentSize()
    for index = 1, self.m_TotalPage do
      local x = (index - self.m_TotalPage / 2 - 0.5) * spaceX + size.width / 2
      local y = -10
      local pageObj = display.newSprite("views/pic/pic_page_sel.png")
      pageObj:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(pageObj, 1)
      pageObj:setPosition(x, y)
      self.m_PageIndexObj[index] = pageObj
      local pageObjUnsel = display.newSprite("views/pic/pic_page_unsel.png")
      pageObjUnsel:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(pageObjUnsel)
      pageObjUnsel:setPosition(x, y)
    end
  end
end
function CPetBoard:ShowPetPage(pageNum, showAction)
  if self.m_PageIndex == pageNum then
    return
  end
  if showAction == nil then
    showAction = true
  end
  self.m_PageIndex = pageNum
  local sRow = (self.m_PageIndex - 1) * self.m_RowNumPerPage + 1
  local eRow = sRow + self.m_RowNumPerPage - 1
  for row = 1, self.m_RowNum do
    local insList = self.m_PetIns[row]
    if insList then
      local v = row >= sRow and row <= eRow
      for _, ins in pairs(insList) do
        ins:setVisible(v)
        if showAction and v then
          ins._HeadIcon:setOpacity(0)
          ins._BgIcon:setOpacity(0)
          if ins == self.m_LastSelectIns then
            ins._HeadIcon:runAction(CCFadeIn:create(0.3))
            ins._BgIcon:runAction(CCFadeIn:create(0.3))
            if ins._selectFrame ~= nil then
              ins._selectFrame:setOpacity(0)
              ins._selectFrame:runAction(CCFadeIn:create(0.3))
            end
          else
            ins._HeadIcon:runAction(CCFadeTo:create(0.3, 150))
            ins._BgIcon:runAction(CCFadeTo:create(0.3, 150))
          end
        end
      end
    end
  end
  if self.m_PageIndexObj then
    for index = 1, self.m_TotalPage do
      local page = self.m_PageIndexObj[index]
      page:setVisible(index == self.m_PageIndex)
    end
  end
end
function CPetBoard:ShowPrePage()
  if self.m_PageIndex <= 1 then
    return
  end
  self:ShowPetPage(self.m_PageIndex - 1)
end
function CPetBoard:ShowNextPage()
  if self.m_PageIndex >= self.m_TotalPage then
    return
  end
  self:ShowPetPage(self.m_PageIndex + 1)
end
function CPetBoard:CheckClick(tx, ty)
  local row = self.m_RowNumPerPage - math.ceil(ty / self.m_RowHeight) + 1
  row = row + (self.m_PageIndex - 1) * self.m_RowNumPerPage
  local insList = self.m_PetIns[row]
  if insList == nil then
    return
  end
  for i, ins in pairs(insList) do
    local x, y = ins:getPosition()
    local size = ins:getContentSize()
    if tx >= x - size.width / 2 - self.m_SpaceX / 2 and tx <= x + size.width / 2 + self.m_SpaceX / 2 then
      if self.m_ClickListener then
        local index = (row - 1) * self.m_NumPerRow + i
        local petId = self.m_PetIdList[index]
        if petId ~= nil then
          self.m_ClickListener(petId)
        end
      end
      if self.m_LastSelectIns ~= nil then
        self.m_LastSelectIns:stopAllActions()
        self.m_LastSelectIns:runAction(CCScaleTo:create(0.15, 0.9))
        self.m_LastSelectIns._HeadIcon:setOpacity(150)
        if self.m_LastSelectIns._selectFrame ~= nil then
          self.m_LastSelectIns._selectFrame:removeFromParentAndCleanup(true)
          self.m_LastSelectIns._selectFrame = nil
        end
      end
      if ins._selectFrame == nil then
        ins._selectFrame = display.newSprite("views/rolelist/pic_role_selected.png")
        ins:addNode(ins._selectFrame, 99)
        local size = ins:getSize()
        ins._selectFrame:setPosition(ccp(0, 0))
      end
      ins:stopAllActions()
      ins:runAction(CCScaleTo:create(0.15, 1))
      ins._HeadIcon:setOpacity(255)
      self.m_LastSelectIns = ins
      break
    end
  end
end
function CPetBoard:CheckDrag(deltaX)
  if deltaX > 20 then
    self:ResetToOriPosXY()
    self:ShowPrePage()
  elseif deltaX < -20 then
    self:ResetToOriPosXY()
    self:ShowNextPage()
  else
    self:BackToOriPosXY()
  end
end
function CPetBoard:DrugCurrPage(offx)
  for _, eList in pairs(self.m_PetIns) do
    for _, petObj in pairs(eList) do
      local oriPosXY = petObj.m_OriPosXY
      local dx = offx / 10
      if dx < -7 then
        dx = -7
      elseif dx > 7 then
        dx = 7
      end
      petObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
    end
  end
end
function CPetBoard:BackToOriPosXY()
  for _, eList in pairs(self.m_PetIns) do
    for _, petObj in pairs(eList) do
      local oriPosXY = petObj.m_OriPosXY
      petObj:stopAllActions()
      petObj:runAction(CCMoveTo:create(0.3, oriPosXY))
    end
  end
end
function CPetBoard:ResetToOriPosXY()
  for _, eList in pairs(self.m_PetIns) do
    for _, petObj in pairs(eList) do
      petObj:stopAllActions()
      local oriPosXY = petObj.m_OriPosXY
      petObj:setPosition(oriPosXY)
    end
  end
end
function CPetBoard:onCleanup()
  self.m_ClickListener = nil
  self.m_LastSelectIns = nil
end
