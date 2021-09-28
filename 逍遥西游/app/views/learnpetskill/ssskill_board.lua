CSSSkill_Board_Item = class(".CSSSkill_Board_Item", function()
  return Widget:create()
end)
function CSSSkill_Board_Item:ctor(skillId)
  self.m_SkillId = skillId
  local iconPath = data_getSkillShapePath(skillId)
  self.m_SkillIcon = display.newSprite(iconPath)
  self:addNode(self.m_SkillIcon)
  self.m_SkillIcon:setAnchorPoint(ccp(0.5, 0.5))
  local size = self.m_SkillIcon:getContentSize()
  self.m_SkillIcon:setPosition(ccp(0, size.height / 2))
  local skillName = data_getSkillName(skillId)
  local nameTxt = ui.newTTFLabel({
    text = skillName,
    size = 17,
    font = KANG_TTF_FONT,
    color = ccc3(75, 47, 16),
    dimensions = CCSize(85, 60),
    align = ui.TEXT_ALIGN_CENTER,
    valign = ui.TEXT_VALIGN_CENTER
  })
  self:addNode(nameTxt)
  nameTxt:setAnchorPoint(ccp(0.5, 0.5))
  local size = nameTxt:getContentSize()
  nameTxt:setPosition(ccp(0, -size.height / 2 + 8))
  self.m_NameTxt = nameTxt
  self:SetSelected(false, false)
end
function CSSSkill_Board_Item:getSkillId()
  return self.m_SkillId
end
function CSSSkill_Board_Item:setFadeOutAct(dt)
  local opacity = 255
  if not self.m_IsSelcted then
    opacity = 150
  end
  self.m_SkillIcon:setOpacity(0)
  self.m_SkillIcon:runAction(CCFadeTo:create(dt, opacity))
  if self.m_SelectedIcon then
    self.m_SelectedIcon:setOpacity(0)
    self.m_SelectedIcon:runAction(CCFadeTo:create(dt, opacity))
  end
  self.m_NameTxt:setOpacity(0)
  self.m_NameTxt:runAction(CCFadeTo:create(dt, 255))
end
function CSSSkill_Board_Item:SetTouchState(iTouch, scaleAction)
  if iTouch then
    if scaleAction ~= false then
      if self.m_SkillIcon._scaleAct ~= nil then
        self.m_SkillIcon:stopAction(self.m_SkillIcon._scaleAct)
        self.m_SkillIcon._scaleAct = nil
      end
      self.m_SkillIcon._scaleAct = CCScaleTo:create(0.15, 1)
      self.m_SkillIcon:runAction(self.m_SkillIcon._scaleAct)
    else
      self.m_SkillIcon:setScale(1)
    end
  elseif scaleAction ~= false then
    if self.m_SkillIcon._scaleAct ~= nil then
      self.m_SkillIcon:stopAction(self.m_SkillIcon._scaleAct)
      self.m_SkillIcon._scaleAct = nil
    end
    self.m_SkillIcon._scaleAct = CCScaleTo:create(0.15, 0.9)
    self.m_SkillIcon:runAction(self.m_SkillIcon._scaleAct)
  else
    self.m_SkillIcon:setScale(0.9)
  end
end
function CSSSkill_Board_Item:SetSelected(iSel, scaleAction)
  self.m_IsSelcted = iSel
  if iSel then
    if self.m_SelectedIcon == nil then
      local size = self.m_SkillIcon:getContentSize()
      self.m_SelectedIcon = display.newSprite("views/rolelist/pic_role_selected.png")
      self.m_SkillIcon:addChild(self.m_SelectedIcon, 10)
      self.m_SelectedIcon:setPosition(size.width / 2, size.height / 2)
      self.m_SelectedIcon:setScale(0.8)
    end
    self.m_SelectedIcon:setVisible(true)
    self.m_SkillIcon:setOpacity(255)
    self:SetTouchState(true, scaleAction)
  else
    if self.m_SelectedIcon ~= nil then
      self.m_SelectedIcon:setVisible(false)
    end
    self.m_SkillIcon:setOpacity(150)
    self:SetTouchState(false, scaleAction)
  end
end
function CSSSkill_Board_Item:getIconSize()
  return self.m_SkillIcon:getContentSize()
end
CSSSkill_Board = class(".CSSSkill_Board", function()
  return Widget:create()
end)
function CSSSkill_Board:ctor(petObj, param)
  self.m_PetObj = petObj
  if param == nil then
    param = {}
  end
  self.m_NumPerRow = param.numPerRow or 3
  self.m_RowHeight = param.rowHeight or 115
  self.m_RowNumPerPage = param.rowsNum or 2
  self.m_SpaceX = param.spaceX or 12
  self.m_ObjWith = param.objWith or 80
  self.m_ClickListener = param.clickListener
  self.m_SSSkillIns = {}
  self.m_AllSSSkill = {}
  for skillId, data in pairs(data_SpecialPetSkill) do
    self.m_AllSSSkill[#self.m_AllSSSkill + 1] = skillId
  end
  local _ssskillSortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a < b
  end
  table.sort(self.m_AllSSSkill, _ssskillSortFunc)
  self.m_RowNum = math.ceil(#self.m_AllSSSkill / self.m_NumPerRow)
  self.m_TotalPage = math.ceil(self.m_RowNum / self.m_RowNumPerPage)
  local w = 0
  local h = self.m_RowHeight * self.m_RowNumPerPage
  local defaultIns
  for row = 1, self.m_RowNum do
    local insList = {}
    self.m_SSSkillIns[row] = insList
    local offx = 0
    local offy = (self.m_RowNumPerPage - (row - 1) % self.m_RowNumPerPage - 0.5) * self.m_RowHeight - 5
    for i = 1, self.m_NumPerRow do
      local eNumber = (row - 1) * self.m_NumPerRow + i
      local skillId = self.m_AllSSSkill[eNumber]
      if skillId == nil then
        break
      end
      local skillIns = CSSSkill_Board_Item.new(skillId)
      if defaultIns == nil then
        defaultIns = skillIns
      end
      self:addChild(skillIns)
      skillIns:setPosition(ccp(offx + self.m_ObjWith / 2, offy))
      local ex, ey = skillIns:getPosition()
      skillIns.m_OriPosXY = ccp(ex, ey)
      offx = offx + self.m_ObjWith + self.m_SpaceX
      insList[#insList + 1] = skillIns
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
  self:ShowSSSKillPage(1, false)
  if defaultIns ~= nil then
    self:OnClickSkill(defaultIns)
  end
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
        self:CheckClickSkill(pos.x, pos.y)
      else
        local startPos = self:getTouchStartPos()
        local endPos = self:getTouchEndPos()
        self:CheckDrag(endPos.x - startPos.x)
      end
    end
  end)
  self:setNodeEventEnabled(true)
end
function CSSSkill_Board:creatPageIndexObj()
  local spaceX = 20
  self.m_PageIndexObj = {}
  local size = self:getContentSize()
  for index = 1, self.m_TotalPage do
    local x = (index - self.m_TotalPage / 2 - 0.5) * spaceX + size.width / 2
    local y = 5
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
function CSSSkill_Board:ShowSSSKillPage(pageNum, showAction)
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
    local insList = self.m_SSSkillIns[row]
    if insList then
      local v = row >= sRow and row <= eRow
      for _, ins in pairs(insList) do
        ins:setVisible(v)
        if showAction and v then
          ins:setFadeOutAct(0.3)
        end
      end
    end
  end
  for index = 1, self.m_TotalPage do
    local page = self.m_PageIndexObj[index]
    page:setVisible(index == self.m_PageIndex)
  end
end
function CSSSkill_Board:ShowPrePage()
  if self.m_PageIndex <= 1 then
    return
  end
  self:ShowSSSKillPage(self.m_PageIndex - 1)
end
function CSSSkill_Board:ShowNextPage()
  if self.m_PageIndex >= self.m_TotalPage then
    return
  end
  self:ShowSSSKillPage(self.m_PageIndex + 1)
end
function CSSSkill_Board:CheckClickSkill(tx, ty)
  local row = self.m_RowNumPerPage - math.ceil(ty / self.m_RowHeight) + 1
  row = row + (self.m_PageIndex - 1) * self.m_RowNumPerPage
  local insList = self.m_SSSkillIns[row]
  if insList == nil then
    return
  end
  local ssSkillNum = #self.m_AllSSSkill
  for i, ins in pairs(insList) do
    local x, y = ins:getPosition()
    local size = ins:getIconSize()
    if tx >= x - size.width / 2 and tx <= x + size.width / 2 and ty >= y and ty <= y + size.height then
      self:OnClickSkill(ins)
      break
    end
  end
end
function CSSSkill_Board:OnClickSkill(ins)
  if self.m_LastClickIns == ins then
    return
  end
  local skillId = ins:getSkillId()
  if self.m_LastClickIns ~= nil then
    self.m_LastClickIns:SetSelected(false, true)
  end
  self.m_LastClickIns = ins
  ins:SetSelected(true, true)
  if self.m_ClickListener then
    local skillId = ins:getSkillId()
    self.m_ClickListener(skillId)
  end
end
function CSSSkill_Board:CheckDrag(deltaX)
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
function CSSSkill_Board:DrugCurrPage(offx)
  for _, objList in pairs(self.m_SSSkillIns) do
    for _, skillObj in pairs(objList) do
      local oriPosXY = skillObj.m_OriPosXY
      local dx = offx / 10
      if dx < -7 then
        dx = -7
      elseif dx > 7 then
        dx = 7
      end
      skillObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
    end
  end
end
function CSSSkill_Board:BackToOriPosXY()
  for _, objList in pairs(self.m_SSSkillIns) do
    for _, skillObj in pairs(objList) do
      local oriPosXY = skillObj.m_OriPosXY
      if skillObj.__moveAction ~= nil then
        skillObj:stopAction(skillObj.__moveAction)
        skillObj.__moveAction = nil
      end
      skillObj.__moveAction = CCMoveTo:create(0.3, oriPosXY)
      skillObj:runAction(skillObj.__moveAction)
    end
  end
end
function CSSSkill_Board:ResetToOriPosXY()
  for _, objList in pairs(self.m_SSSkillIns) do
    for _, skillObj in pairs(objList) do
      if skillObj.__moveAction ~= nil then
        skillObj:stopAction(skillObj.__moveAction)
        skillObj.__moveAction = nil
      end
      local oriPosXY = skillObj.m_OriPosXY
      skillObj:setPosition(oriPosXY)
    end
  end
end
function CSSSkill_Board:onCleanup()
  self.m_PetObj = nil
  self.m_ClickListener = nil
end
