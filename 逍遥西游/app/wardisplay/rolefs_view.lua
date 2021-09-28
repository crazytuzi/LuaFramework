local CRoleFenShenView = class("CRoleFenShenView", function()
  return Widget:create()
end)
function CRoleFenShenView:ctor(sorceViewObj, targetDir)
  self:setNodeEventEnabled(true)
  self.m_RoleOpacity = 150
  self.m_IsExist = true
  local fsDir
  if targetDir == DIRECTIOIN_LEFTUP then
    fsDir = DIRECTIOIN_RIGHTDOWN
  else
    fsDir = DIRECTIOIN_LEFTUP
  end
  if fsDir == nil then
    fsDir = sorceViewObj:getDirection()
  end
  self.m_TypeId = sorceViewObj:getShowingTypeId()
  self.m_Direction = fsDir
  local cList = sorceViewObj:getRanColorList()
  self:createShape(cList)
  local name = sorceViewObj:getRoleName()
  local nameColor = sorceViewObj:getNameColor()
  self:setName(name, nameColor)
  local hp, maxHp, mp, maxMp = sorceViewObj:getHpMpInfo()
  local flag = sorceViewObj:getHpMpShow()
  local bodyHeight = sorceViewObj:getBodyHeight()
  self:initHpAndMpBar(hp, maxHp, mp, maxMp, flag, bodyHeight)
  self:setGuard()
end
function CRoleFenShenView:getDirection()
  return self.m_Direction
end
function CRoleFenShenView:getShowingTypeId()
  return self.m_TypeId
end
function CRoleFenShenView:createShape(cList)
  local shape = data_getRoleShape(self.m_TypeId)
  self.m_ShapeAni, offx, offy = createWarBodyByShape(shape, self.m_Direction, cList)
  self.m_ShapeAni:setPosition(offx, offy)
  self:addNode(self.m_ShapeAni, RoleZOrder)
  self.m_ShapeAni:setOpacity(self.m_RoleOpacity)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(shadow, ShadowZOrder)
end
function CRoleFenShenView:setName(name, nameColor)
  self.m_Name = ui.newTTFLabelWithShadow({
    text = name,
    font = KANG_TTF_FONT,
    size = 24,
    align = ui.TEXT_ALIGN_CENTER,
    color = nameColor
  }):pos(0, -20)
  self.m_Name.shadow1:realign(1, 0)
  self:addNode(self.m_Name, RoleNameZOrder)
  self.m_Name:setOpacity(self.m_RoleOpacity)
end
function CRoleFenShenView:initHpAndMpBar(hp, maxHp, mp, maxMp, flag, bodyHeight)
  if maxMp > 0 then
    self.m_HpBar = ProgressClip.new("xiyou/pic/pic_HpBar_war.png", "xiyou/pic/pic_HpBarBg_war.png", hp, maxHp, true)
    self:addChild(self.m_HpBar, HPBarZOrder)
    local size = self.m_HpBar:getContentSize()
    self.m_HpBar:setPosition(ccp(-size.width / 2, bodyHeight + 15))
    self.m_HpBar:barOffset(2, -1)
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
    self.m_MpBar = ProgressClip.new("xiyou/pic/pic_MpBar_war.png", "xiyou/pic/pic_MpBarBg_war.png", mp, maxMp, true)
    self:addChild(self.m_MpBar, HPBarZOrder)
    local size = self.m_MpBar:getContentSize()
    self.m_MpBar:setPosition(ccp(-size.width / 2, bodyHeight))
    self.m_MpBar:barOffset(2, 5)
    self.m_MpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_MpBar:bar():setOpacity(self.m_RoleOpacity)
  else
    self.m_HpBar = ProgressClip.new("xiyou/pic/pic_HpBar_war.png", "xiyou/pic/pic_MpBarBg_war.png", hp, maxHp, true)
    self:addChild(self.m_HpBar, HPBarZOrder)
    local size = self.m_HpBar:getContentSize()
    self.m_HpBar:setPosition(ccp(-size.width / 2, bodyHeight))
    self.m_HpBar:barOffset(2, 5)
    self.m_HpBar:setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
  end
  if self.m_HpBar then
    self.m_HpBar:setVisible(flag)
  end
  if self.m_MpBar then
    self.m_MpBar:setVisible(flag)
  end
end
function CRoleFenShenView:setGuard()
  self.m_ShapeAni:playAniWithName("guard_" .. self:convertDir(self.m_Direction), -1)
end
function CRoleFenShenView:setAttack(skillID)
  if JudgeSkillIsMagicAttack(skillID) then
    self.m_ShapeAni:playAniWithName("magic_" .. self:convertDir(self.m_Direction), 1, handler(self, self.AutoDelete), false)
  else
    self.m_ShapeAni:playAniWithName("attack_" .. self:convertDir(self.m_Direction), 1, handler(self, self.AutoDelete), false)
  end
end
function CRoleFenShenView:convertDir(direction)
  return tostring(direction)
end
function CRoleFenShenView:AutoDelete()
  if self.m_IsExist ~= true then
    return
  end
  self:setGuard()
  self.m_ShapeAni:runAction(CCFadeTo:create(0.3, 0))
  self.m_Name:runAction(CCFadeTo:create(0.3, 0))
  if self.m_HpBar then
    self.m_HpBar:runAction(CCFadeTo:create(0.3, 0))
  end
  if self.m_MpBar then
    self.m_MpBar:runAction(CCFadeTo:create(0.3, 0))
  end
  self:runAction(transition.sequence({
    CCDelayTime:create(0.3),
    CCCallFunc:create(function()
      self:removeFromParent()
    end)
  }))
end
function CRoleFenShenView:onCleanup()
  self.m_IsExist = nil
  print("---->>>>CRoleFenShenView onCleanup")
end
return CRoleFenShenView
