MapMonsterShape = class("MapMonsterShape", CMapRoleShape)
function MapMonsterShape:ctor(monsterId, monsterTypeId, type, param, posChangedListener)
  self.m_MonsterId = monsterId
  self.m_MonsterTypeId = monsterTypeId
  self.m_CreateType = type
  self.m_Param = param
  local shapeId = data_getRoleShape(self.m_MonsterTypeId)
  self.super.ctor(self, shapeId, LOGICTYPE_MONSTER, posChangedListener)
  self.m_MonsterOpa = data_getRoleShapOp(self.m_MonsterTypeId)
  if self.m_MonsterOpa == nil or self.m_MonsterOpa <= 0 then
    self.m_MonsterOpa = 255
  end
end
function MapMonsterShape:getShapeOpacity()
  return self.m_MonsterOpa
end
function MapMonsterShape:getMonsterTypeId()
  return self.m_MonsterTypeId
end
function MapMonsterShape:getParam()
  return self.m_Param
end
function MapMonsterShape:getCreateType()
  return self.m_CreateType
end
function MapMonsterShape:createFightIcon()
  self.m_MonsterFightIcon = display.newSprite("views/pic/pic_fighticon.png")
  self:addNode(self.m_MonsterFightIcon, 11)
  local x, y = 0, self.m_BodyHeight + 35
  local dx, dy = x, y + 5
  self.m_MonsterFightIcon:setPosition(ccp(x, y))
  self.m_MonsterFightIcon:runAction(CCRepeatForever:create(transition.sequence({
    CCMoveTo:create(0.5, ccp(dx, dy)),
    CCMoveTo:create(0.5, ccp(x, y))
  })))
end
function MapMonsterShape:setRoleName(name, color)
  self.m_RoleName = name
  if self.m_CreateType == MapMonsterType_GuanKa then
    name = name .. "(剧情)"
  end
  self.m_RoleNameColor = color
  if self.m_ShapeAni == nil then
    return
  end
  if self.m_NameTxt == nil then
    local nameTxt = ui.newTTFLabelWithShadow({
      text = name,
      font = KANG_TTF_FONT,
      size = 19
    })
    nameTxt.shadow1:realign(1, 0)
    if color ~= nil then
      nameTxt:setColor(color)
    end
    self:addNode(nameTxt, 11)
    self.m_NameTxt = nameTxt
    local s = nameTxt:getContentSize()
    self.m_NamePosDy = -s.height
    self.m_NameTxt:setPosition(ccp(-s.width / 2, self.m_NamePosDy))
  else
    self.m_NameTxt:setString(name)
  end
end
