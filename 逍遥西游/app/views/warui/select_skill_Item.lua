selectSkillItem = class("selectSkillItem", CcsSubView)
function selectSkillItem:ctor(roleId, skillId, callFunc, flagDict)
  flagDict = flagDict or {}
  local mpEnoughFlag = flagDict.mpEnoughFlag
  local openFlag = flagDict.openFlag
  local unKnownFlag = flagDict.unKnownFlag
  local cdFlag = flagDict.cdFlag
  local proFlag = flagDict.proFlag
  local hasUseFlag = flagDict.hasUseFlag
  local minRoundFlag = flagDict.minRoundFlag
  local hpEnoughFlag = flagDict.hpEnoughFlag
  local yiwangFlag = flagDict.yiwangFlag
  selectSkillItem.super.ctor(self, "views/select_skill_item.json")
  self.m_Handler = callFunc
  self.m_SkillId = skillId
  self.m_WarPos = pos
  self.m_RoleId = roleId
  self.m_OpenFlag = openFlag
  self.m_YiwangFlag = yiwangFlag
  self.m_MpEnoughFlag = mpEnoughFlag
  if hpEnoughFlag == nil then
    hpEnoughFlag = true
  end
  self.m_HpEnoughFlag = hpEnoughFlag
  self.m_UnKnownFlag = unKnownFlag
  if minRoundFlag == nil then
    minRoundFlag = true
  end
  self.m_MinRoundFlag = minRoundFlag
  self.m_HasUseFlag = hasUseFlag
  if self.m_HasUseFlag == nil then
    self.m_HasUseFlag = false
  end
  self.m_CDFlag = cdFlag
  if self.m_CDFlag == nil then
    self.m_CDFlag = true
  end
  self.m_ProFlag = proFlag
  if self.m_ProFlag == nil then
    self.m_ProFlag = true
  end
  local path = data_getSkillShapePath(skillId)
  local addText = ""
  if self.m_UnKnownFlag then
    self.m_SkillImg = display.newSprite("xiyou/skill/skill_unknown.png")
  elseif self.m_OpenFlag == false then
    self.m_SkillImg = display.newSprite(path)
    self.m_SkillImg:setColor(ccc3(180, 180, 180))
  elseif self.m_MinRoundFlag ~= true then
    self.m_SkillImg = display.newGraySprite(path)
  elseif self.m_YiwangFlag == true then
    self.m_SkillImg = display.newGraySprite(path)
    addText = "遗忘"
  elseif self.m_HasUseFlag then
    self.m_SkillImg = display.newGraySprite(path)
  elseif self.m_CDFlag ~= true then
    self.m_SkillImg = display.newGraySprite(path)
    addText = string.format("冷却\n(%d)", self.m_CDFlag)
  elseif self.m_ProFlag ~= true then
    self.m_SkillImg = display.newGraySprite(path)
    if self.m_ProFlag == "ll" then
      addText = "力量\n不足"
    elseif self.m_ProFlag == "gg" then
      addText = "根骨\n不足"
    elseif self.m_ProFlag == "lx" then
      addText = "灵性\n不足"
    elseif self.m_ProFlag == "mj" then
      addText = "敏捷\n不足"
    elseif self.m_ProFlag == "jin" then
      addText = "五行金\n不足"
    elseif self.m_ProFlag == "mu" then
      addText = "五行木\n不足"
    elseif self.m_ProFlag == "shui" then
      addText = "五行水\n不足"
    elseif self.m_ProFlag == "huo" then
      addText = "五行火\n不足"
    elseif self.m_ProFlag == "tu" then
      addText = "五行土\n不足"
    end
  elseif self.m_MpEnoughFlag == false then
    self.m_SkillImg = display.newGraySprite(path)
    addText = "魔法\n不足"
  elseif self.m_HpEnoughFlag == false then
    self.m_SkillImg = display.newGraySprite(path)
    addText = "气血\n不足"
  else
    self.m_SkillImg = display.newSprite(path)
  end
  if addText ~= "" then
    local txtObj = ui.newTTFLabel({
      text = addText,
      font = KANG_TTF_FONT,
      size = 20,
      color = ccc3(255, 0, 0)
    })
    txtObj:setAnchorPoint(ccp(0.5, 0.5))
    local tSize = self.m_SkillImg:getContentSize()
    txtObj:setPosition(ccp(tSize.width / 2, tSize.height / 2))
    self.m_SkillImg:addChild(txtObj)
  end
  local x, y = self:getNode("skillImg"):getPosition()
  local size = self:getNode("skillImg"):getSize()
  local clickImg
  local clickLongPressTime = 0.5
  if self.m_UnKnownFlag then
    clickLongPressTime = 0
  end
  clickImg = createClickSkill({
    roleID = roleId,
    skillID = skillId,
    autoSize = size,
    LongPressTime = clickLongPressTime,
    clickListener = handler(self, self.clickSkill),
    LongPressListener = nil,
    LongPressEndListner = nil,
    imgFlag = false,
    clickDel = nil
  })
  clickImg:setPosition(ccp(x, y))
  self.m_UINode:addChild(clickImg)
  clickImg:addNode(self.m_SkillImg)
  self.m_SkillImg:setPosition(ccp(size.width / 2, size.height / 2))
  self.m_ClickNode = clickImg
end
function selectSkillItem:clickSkill(obj, t)
  print("click skillitem", self.m_SkillId)
  if self.m_Handler then
    self.m_Handler(self)
  end
end
function selectSkillItem:getSkillId()
  return self.m_SkillId
end
function selectSkillItem:getUnKnownFlag()
  return self.m_UnKnownFlag
end
function selectSkillItem:getOpenFlag()
  return self.m_OpenFlag
end
function selectSkillItem:getMpEnoughFlag()
  return self.m_MpEnoughFlag
end
function selectSkillItem:getHpEnoughFlag()
  return self.m_HpEnoughFlag
end
function selectSkillItem:getMinRoundFlag()
  return self.m_MinRoundFlag
end
function selectSkillItem:getHasUseFlag()
  return self.m_HasUseFlag
end
function selectSkillItem:getYiwangFlag()
  return self.m_YiwangFlag
end
function selectSkillItem:setFadeIn()
  local dt = 0.5
  if self.m_SkillImg ~= nil then
    self.m_SkillImg:setOpacity(0)
    self.m_SkillImg:runAction(CCFadeIn:create(dt))
  end
end
function selectSkillItem:UnGetMessage()
  self.m_ClickNode:setTouchEnabled(false)
  self:setTouchEnabled(false)
end
function selectSkillItem:ShowLongPress()
  if g_Click_Skill_View ~= nil then
    g_Click_Skill_View:removeFromParentAndCleanup(true)
  end
  local size = self.m_ClickNode:getSize()
  local worldPos = self.m_ClickNode:convertToWorldSpace(ccp(0, 0))
  g_Click_Skill_View = CSkillDetailView.new(self.m_RoleId, self.m_SkillId, false, {
    x = worldPos.x,
    y = worldPos.y,
    w = size.width,
    h = size.height
  }, nil, nil, false, nil)
end
function selectSkillItem:Clear()
  self.m_Handler = nil
end
return selectSkillItem
