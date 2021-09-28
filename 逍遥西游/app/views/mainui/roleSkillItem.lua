MainUISkillItem = class("MainUISkillItem")
function MainUISkillItem:ctor(index, pos, iconSize, addToParent, zOrder, clickListener)
  self.m_Index = index
  self.m_Pos = pos
  self.m_Size = iconSize
  self.m_AddToParent = addToParent
  self.m_zOrder = zOrder or 0
  self.m_Listener = clickListener
  self.m_Icon = nil
  self.m_RoleId = nil
  self.m_SkillId = nil
end
function MainUISkillItem:Reflush(roleId, skillId)
  if skillId == nil then
    return
  end
  if self.m_RoleId == roleId and self.m_SkillId == skillId then
    return
  end
  self.m_RoleId = roleId
  self.m_SkillId = skillId
  local roleIns = g_LocalPlayer:getObjById(roleId)
  if roleIns == nil then
    return
  end
  if self.m_Icon then
    self.m_Icon:removeSelf()
  end
  local w = self.m_Size.width * 0.8
  local h = self.m_Size.height * 0.8
  self.m_OpenFlag = roleIns:getSkillIsOpen(skillId)
  local path = data_getSkillShapePath(skillId)
  if self.m_OpenFlag == false then
    self.m_SkillImg = display.newGraySprite(path)
  else
    self.m_SkillImg = display.newSprite(path)
  end
  local size = CCSize(w, h)
  local clickImg = createClickSkill({
    roleID = roleId,
    skillID = skillId,
    autoSize = size,
    LongPressTime = 0.2,
    clickListener = function(...)
      if self.m_Listener then
        self.m_Listener(self, skillId)
      end
    end,
    LongPressListener = nil,
    LongPressEndListner = nil,
    imgFlag = false,
    clickDel = nil
  })
  self.m_Icon = clickImg
  self.m_AddToParent:addChild(self.m_Icon, self.m_zOrder)
  self.m_Icon:setPosition(ccp(self.m_Pos.x - w / 2, self.m_Pos.y - h / 2))
  self.m_Icon:addNode(self.m_SkillImg)
  self.m_SkillImg:setPosition(ccp(size.width / 2, size.height / 2))
end
function MainUISkillItem:setSkillIconEnabled(b)
  if self.m_Icon then
    self.m_Icon:setEnabled(b)
    self.m_Icon:setTouchEnabled(b)
    self.m_Icon:setVisible(b)
  end
end
function MainUISkillItem:getSkillId()
  return self.m_SkillId
end
function MainUISkillItem:getOpenFlag()
  return self.m_OpenFlag
end
function MainUISkillItem:Clear()
  self.m_AddToParent = nil
  self.m_Listener = nil
end
