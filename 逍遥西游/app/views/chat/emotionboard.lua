local Define_EmotionNum = Define_EmotionSY + Define_EmotionMoMo
local getRealEmotionIndex = function(eNumber)
  if eNumber <= Define_EmotionMoMo then
    return eNumber + 100
  else
    return eNumber - Define_EmotionMoMo
  end
end
CEmotionBoard = class(".CEmotionBoard", function()
  return Widget:create()
end)
function CEmotionBoard:ctor(param)
  self.m_NumPerRow = param.numPerRow or 7
  self.m_RowHeight = param.rowHeight or 40
  self.m_RowNumPerPage = param.rowsNum or 3
  self.m_SpaceX = param.spaceX or 7
  self.m_ObjWith = param.objWith or 30
  self.m_ClickListener = param.clickListener
  self.m_EmotionIns = {}
  self.m_RowNum = math.ceil(Define_EmotionNum / self.m_NumPerRow)
  self.m_TotalPage = math.ceil(self.m_RowNum / self.m_RowNumPerPage)
  local w = 0
  local h = self.m_RowHeight * self.m_RowNumPerPage
  for row = 1, self.m_RowNum do
    local insList = {}
    self.m_EmotionIns[row] = insList
    local offx = self.m_SpaceX
    local offy = (self.m_RowNumPerPage - (row - 1) % self.m_RowNumPerPage - 0.5) * self.m_RowHeight
    for i = 1, self.m_NumPerRow do
      local eNumber = (row - 1) * self.m_NumPerRow + i
      if eNumber > Define_EmotionNum then
        break
      end
      eNumber = getRealEmotionIndex(eNumber)
      local emote
      if eNumber <= Define_EmotionSY then
        local ePath = string.format("xiyou/emote/emote%d.plist", eNumber)
        emote = CreateSeqAnimation(ePath, -1)
      else
        local ePath = string.format("xiyou/emote/em%d.png", eNumber)
        emote = display.newSprite(ePath)
      end
      self:addNode(emote)
      local size = emote:getContentSize()
      emote:setPosition(offx + self.m_ObjWith / 2, offy)
      local ex, ey = emote:getPosition()
      emote.m_OriPosXY = ccp(ex, ey)
      offx = offx + self.m_ObjWith + self.m_SpaceX
      insList[#insList + 1] = emote
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
  self:ShowEmotePage(1, false)
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
function CEmotionBoard:creatPageIndexObj()
  local spaceX = 20
  self.m_PageIndexObj = {}
  local size = self:getContentSize()
  for index = 1, self.m_TotalPage do
    local x = (index - self.m_TotalPage / 2 - 0.5) * spaceX + size.width / 2
    local y = -12
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
function CEmotionBoard:ShowEmotePage(pageNum, showAction)
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
    local insList = self.m_EmotionIns[row]
    if insList then
      local v = row >= sRow and row <= eRow
      for _, ins in pairs(insList) do
        ins:setVisible(v)
        if showAction and v then
          ins:setOpacity(0)
          ins:runAction(CCFadeIn:create(0.3))
        end
      end
    end
  end
  for index = 1, self.m_TotalPage do
    local page = self.m_PageIndexObj[index]
    page:setVisible(index == self.m_PageIndex)
  end
end
function CEmotionBoard:ShowPrePage()
  if self.m_PageIndex <= 1 then
    return
  end
  self:ShowEmotePage(self.m_PageIndex - 1)
end
function CEmotionBoard:ShowNextPage()
  if self.m_PageIndex >= self.m_TotalPage then
    return
  end
  self:ShowEmotePage(self.m_PageIndex + 1)
end
function CEmotionBoard:CheckClick(tx, ty)
  local row = self.m_RowNumPerPage - math.ceil(ty / self.m_RowHeight) + 1
  row = row + (self.m_PageIndex - 1) * self.m_RowNumPerPage
  local insList = self.m_EmotionIns[row]
  if insList == nil then
    return
  end
  for i, ins in pairs(insList) do
    local x, y = ins:getPosition()
    local size = ins:getContentSize()
    if tx >= x - size.width / 2 - self.m_SpaceX / 2 and tx <= x + size.width / 2 + self.m_SpaceX / 2 then
      if self.m_ClickListener then
        local eNumber = (row - 1) * self.m_NumPerRow + i
        if eNumber <= Define_EmotionNum then
          eNumber = getRealEmotionIndex(eNumber)
          self.m_ClickListener(eNumber)
        end
      end
      break
    end
  end
end
function CEmotionBoard:CheckDrag(deltaX)
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
function CEmotionBoard:DrugCurrPage(offx)
  for _, eList in pairs(self.m_EmotionIns) do
    for _, emoteObj in pairs(eList) do
      local oriPosXY = emoteObj.m_OriPosXY
      local dx = offx / 10
      if dx < -7 then
        dx = -7
      elseif dx > 7 then
        dx = 7
      end
      emoteObj:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
    end
  end
end
function CEmotionBoard:BackToOriPosXY()
  for _, eList in pairs(self.m_EmotionIns) do
    for _, emoteObj in pairs(eList) do
      local oriPosXY = emoteObj.m_OriPosXY
      if emoteObj.__moveAction ~= nil then
        emoteObj:stopAction(emoteObj.__moveAction)
        emoteObj.__moveAction = nil
      end
      emoteObj.__moveAction = CCMoveTo:create(0.3, oriPosXY)
      emoteObj:runAction(emoteObj.__moveAction)
    end
  end
end
function CEmotionBoard:ResetToOriPosXY()
  for _, eList in pairs(self.m_EmotionIns) do
    for _, emoteObj in pairs(eList) do
      if emoteObj.__moveAction ~= nil then
        emoteObj:stopAction(emoteObj.__moveAction)
        emoteObj.__moveAction = nil
      end
      local oriPosXY = emoteObj.m_OriPosXY
      emoteObj:setPosition(oriPosXY)
    end
  end
end
function CEmotionBoard:onCleanup()
  self.m_ClickListener = nil
end
CEmotionBoardRecently = class(".CEmotionBoardRecently", function()
  return Widget:create()
end)
function CEmotionBoardRecently:ctor(param)
  self.m_NumPerRow = param.numPerRow or 7
  self.m_RowHeight = param.rowHeight or 40
  self.m_SpaceX = param.spaceX or 7
  self.m_ObjWith = param.objWith or 30
  self.m_ClickListener = param.clickListener
  self.m_EmotionNum = param.emotionNum or 9
  self.m_EmotionIdList = param.emotionIdList or {}
  self.m_EmotionIns = {}
  self.m_RowNum = math.ceil(self.m_EmotionNum / self.m_NumPerRow)
  local w = 0
  local h = self.m_RowHeight * self.m_RowNum
  for row = self.m_RowNum, 1, -1 do
    local insList = {}
    self.m_EmotionIns[row] = insList
    local offx = self.m_SpaceX
    local offy = (self.m_RowNum - row + 0.5) * self.m_RowHeight
    for i = 1, self.m_NumPerRow do
      local eNumber = self.m_EmotionIdList[(row - 1) * self.m_NumPerRow + i]
      if eNumber == nil then
        break
      end
      local emote
      if eNumber <= Define_EmotionSY then
        local ePath = string.format("xiyou/emote/emote%d.plist", eNumber)
        emote = CreateSeqAnimation(ePath, -1)
      else
        local ePath = string.format("xiyou/emote/em%d.png", eNumber)
        emote = display.newSprite(ePath)
      end
      self:addNode(emote)
      local size = emote:getContentSize()
      emote:setPosition(offx + self.m_ObjWith / 2, offy)
      offx = offx + self.m_ObjWith + self.m_SpaceX
      insList[#insList + 1] = emote
    end
    if w < offx then
      w = offx
    end
  end
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(w, h))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
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
      end
    elseif (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and not self.m_HasTouchMoved then
      local startPos = self:getTouchStartPos()
      local pos = self:convertToNodeSpace(ccp(startPos.x, startPos.y))
      self:CheckClick(pos.x, pos.y)
    end
  end)
  self:setNodeEventEnabled(true)
end
function CEmotionBoardRecently:CheckClick(tx, ty)
  local row = self.m_RowNum - math.ceil(ty / self.m_RowHeight) + 1
  local insList = self.m_EmotionIns[row]
  if insList == nil then
    return
  end
  for i, ins in pairs(insList) do
    local x, y = ins:getPosition()
    local size = ins:getContentSize()
    if tx >= x - size.width / 2 - self.m_SpaceX / 2 and tx <= x + size.width / 2 + self.m_SpaceX / 2 then
      if self.m_ClickListener then
        local eNumber = self.m_EmotionIdList[(row - 1) * self.m_NumPerRow + i]
        if eNumber ~= nil then
          self.m_ClickListener(eNumber)
        end
      end
      break
    end
  end
end
function CEmotionBoardRecently:onCleanup()
  self.m_ClickListener = nil
end
