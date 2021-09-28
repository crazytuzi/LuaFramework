g_Click_PET_Head_View = nil
CPetDetailView = class("CPetDetailView", CcsSubView)
function CPetDetailView:ctor(petId, autoDel, posPara)
  CPetDetailView.super.ctor(self, "views/petdetail.json")
  print("CPetDetailView---create")
  self.m_AutoDel = autoDel
  self.m_Bg = self:getNode("bg")
  local bgPath = "views/mainviews/pic_headiconbg.png"
  local bgImg = display.newSprite(bgPath)
  local shapeID = data_getRoleShape(petId)
  local path = data_getHeadPathByShape(shapeID)
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("Img"):getPosition()
  local z = self:getNode("Img"):getZOrder()
  local size = self:getNode("Img"):getSize()
  local mSize = bgImg:getContentSize()
  bgImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  bgImg:setScale(size.width / mSize.width)
  bgImg:addChild(tempImg)
  tempImg:setAnchorPoint(ccp(0, 0))
  tempImg:setPosition(ccp(HEAD_OFF_X, HEAD_OFF_Y))
  self.m_Bg:addNode(bgImg, z)
  local iconPath = data_getPetIconPath(petId)
  local iconImg = display.newSprite(iconPath)
  local x, y = self:getNode("Icon"):getPosition()
  local z = self:getNode("Icon"):getZOrder()
  local size = self:getNode("Icon"):getSize()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  self.m_Bg:addNode(iconImg, z)
  local x, y = self:getNode("Desc"):getPosition()
  local descSize = self:getNode("Desc"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 23,
    color = ccc3(255, 255, 255)
  })
  self.m_Bg:addChild(tempDesc)
  local _, name = data_getRoleShapeAndName(petId)
  tempDesc:addRichText(name)
  tempDesc:newLine()
  local des = data_getRoleDes(petId)
  tempDesc:addRichText(string.format("%s", des))
  tempDesc:newLine()
  local realDescSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - realDescSize.height))
  local bgSize = self.m_Bg:getSize()
  local w = bgSize.width
  local h = bgSize.height
  if realDescSize.height > descSize.height then
    self.m_Bg:ignoreContentAdaptWithSize(false)
    self.m_Bg:setSize(CCSize(w, h + realDescSize.height - descSize.height))
    self.m_Bg:setPosition(ccp(0, h + realDescSize.height - descSize.height))
  end
  if self.m_AutoDel == true then
    self:AutoDelSelf()
  end
  tipsviewExtend.extend(self)
  tipssetposExtend.extend(self, posPara)
end
function CPetDetailView:AutoDelSelf()
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  self.m_DelSelfHandler = scheduler.scheduleGlobal(function()
    print("CPetDetailView---removeself")
    self:removeFromParent()
  end, 3)
end
function CPetDetailView:getViewSize()
  return self.m_Bg:getSize()
end
function CPetDetailView:Clear()
  print("CPetDetailView---del")
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  g_Click_PET_Head_View = nil
end
