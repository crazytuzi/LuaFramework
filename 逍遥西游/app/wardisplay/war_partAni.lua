local warSkillName = class("warSkillName", function()
  local cLayer = display.newNode()
  return cLayer
end)
function warSkillName:ctor(skillID)
  self.m_SkillBg = display.newSprite("xiyou/warskill/skillname_bg.png")
  self:addChild(self.m_SkillBg)
  local path = string.format("xiyou/warskill/skillname_%d.png", skillID)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
  if os.exists(fullPath) then
    self.m_SkillName = display.newSprite(path)
    if self.m_SkillName then
      self:addChild(self.m_SkillName, 1)
      self.m_SkillName:setPosition(20, 5)
    end
  end
  self.m_onCleanup = false
  self:setNodeEventEnabled(true)
end
function warSkillName:Clear()
  self.m_SkillBg:runAction(CCFadeOut:create(0.5))
  if self.m_SkillName then
    self.m_SkillName:runAction(CCFadeOut:create(0.5))
  end
end
function warSkillName:onCleanup()
  self.m_onCleanup = true
end
function warSkillName:DeleteSelf()
  if self.m_onCleanup ~= false then
    return
  end
  self:removeFromParentAndCleanup(true)
end
return warSkillName
