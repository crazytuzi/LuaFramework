local roleshape = class("roleshape", function()
  return Widget:create()
end)
function roleshape:ctor(pos, param, dlgHandle, isMainShape)
  self:setNodeEventEnabled(true)
  self.m_Pos = pos
  self.m_Param = param
  self.m_DlgHandle = dlgHandle
  self.m_IsMainShape = isMainShape
  self:createShape()
  self.m_Name = ui.newTTFLabel({
    text = param.rName,
    font = KANG_TTF_FONT,
    size = 24,
    align = ui.TEXT_ALIGN_CENTER,
    color = ccc3(99, 182, 121)
  }):pos(0, -20)
  self:addNode(self.m_Name, 1)
end
function roleshape:createShape()
  local rTypeId = self.m_Param.rTypeID
  self.m_ShapeAni, offx, offy = createBodyByRoleTypeID(rTypeId)
  self.m_ShapeAni:setPosition(offx, offy)
  self:addNode(self.m_ShapeAni)
  self.m_ShapeAni:playAniWithName("guard_8", -1)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(shadow, -1)
  shadow:setPosition(0, 0)
end
function roleshape:getParam()
  return self.m_Param
end
function roleshape:getPos()
  return self.m_Pos
end
function roleshape:setPos(pos)
  self.m_Pos = pos
end
function roleshape:IsMainShape()
  return self.m_IsMainShape
end
function roleshape:onCleanup()
  self.m_DlgHandle = nil
end
local petshape = class("petshape", roleshape)
function petshape:ctor(pos, param, dlgHandle)
  petshape.super.ctor(self, pos, param, dlgHandle, false)
end
local heroshape = class("heroshape", roleshape)
function heroshape:ctor(pos, param, dlgHandle, isMainShape)
  heroshape.super.ctor(self, pos, param, dlgHandle, isMainShape)
  self.m_TouchNode = clickwidget.create(75, 130, 0.5, 0.1, function(touchNode, event)
    self:TouchOnRole(event)
  end)
  self:addChild(self.m_TouchNode)
end
function heroshape:TouchOnRole(event)
  if event == TOUCH_EVENT_BEGAN then
    self:onTouchBegan()
  elseif event == TOUCH_EVENT_MOVED then
    self:onTouchMoved()
  elseif event == TOUCH_EVENT_ENDED then
    self:onTouchEnded()
  elseif event == TOUCH_EVENT_CANCELED then
    self:onTouchEnded()
  end
end
function heroshape:setTouchState(iTouch)
  if iTouch then
    self.m_ShapeAni:setOpacity(180)
  else
    self.m_ShapeAni:setOpacity(255)
  end
end
function heroshape:onTouchBegan()
  self.m_DlgHandle:resetAllShapeState()
  self:setTouchState(true)
  self.m_InitZOrder = self:getZOrder()
  self:getParent():reorderChild(self, 99999)
  self.m_HasMoved = false
  local x, y = self:getPosition()
  self.m_DlgHandle:onDragBegan(ccp(x, y))
end
function heroshape:onTouchMoved()
  local touchPos = self.m_TouchNode:getTouchMovePos()
  local wPos = ccp(touchPos.x, touchPos.y)
  local parent = self:getParent()
  local pos = parent:convertToNodeSpace(wPos)
  local x, y = self:getPosition()
  if self.m_DeltaPos == nil then
    self.m_DeltaPos = ccp(pos.x - x, pos.y - y)
    local bodySize = self.m_ShapeAni:getTextureRect()
    local size = bodySize.size
    local offx = size.width / 2
    local offy = size.height
    if offx < self.m_DeltaPos.x then
      self.m_DeltaPos.x = offx
    elseif self.m_DeltaPos.x < -offx then
      self.m_DeltaPos.x = -offx
    end
    if offy < self.m_DeltaPos.y then
      self.m_DeltaPos.y = offy
    elseif self.m_DeltaPos.y < 0 then
      self.m_DeltaPos.y = 0
    end
  end
  if not self.m_HasMoved and (math.abs(pos.x - x - self.m_DeltaPos.x) > 10 or math.abs(pos.y - y - self.m_DeltaPos.y) > 10) then
    self.m_HasMoved = true
  end
  if self.m_HasMoved then
    self:setPosition(ccp(pos.x - self.m_DeltaPos.x, pos.y - self.m_DeltaPos.y))
  end
  self.m_DlgHandle:onDragMoved(ccp(x, y))
end
function heroshape:onTouchEnded()
  self:setTouchState(false)
  self:getParent():reorderChild(self, self.m_InitZOrder or 0)
  self.m_DeltaPos = nil
  if self.m_HasMoved then
    local x, y = self:getPosition()
    self.m_DlgHandle:onDragEnded(self, self.m_Pos, ccp(x, y))
  else
    self.m_DlgHandle:onClickRoleShape(self, self.m_Pos)
  end
end
local shapes = {petshape = petshape, heroshape = heroshape}
return shapes
