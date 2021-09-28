g_Click_MONSTER_Head_View = nil
CMonsterDetailView = class("CMonsterDetailView", CcsSubView)
function CMonsterDetailView:ctor(monsterId, isBoss, autoDel, posPara)
  CMonsterDetailView.super.ctor(self, "views/monsterdetail.json")
  print("CMonsterDetailView---create")
  self.m_AutoDel = autoDel
  self.m_Bg = self:getNode("bg")
  local bgPath = "views/mainviews/pic_headiconbg.png"
  if isBoss then
    bgPath = "views/mainviews/pic_headiconbg_s.png"
  end
  local bgImg = display.newSprite(bgPath)
  local shapeID = data_getRoleShape(monsterId)
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
  local shape, name = data_getRoleShapeAndName(monsterId)
  tempDesc:addRichText(name)
  tempDesc:newLine()
  if isBoss == true then
    tempDesc:addRichText("#<R>BOSS#")
    tempDesc:newLine()
  end
  local des = data_getRole_MonsterDes(shape)
  tempDesc:addRichText(string.format("%s", des))
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
function CMonsterDetailView:AutoDelSelf()
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  self.m_DelSelfHandler = scheduler.scheduleGlobal(function()
    print("CMonsterDetailView---removeself")
    self:removeFromParent()
  end, 3)
end
function CMonsterDetailView:getViewSize()
  return self.m_Bg:getSize()
end
function CMonsterDetailView:Clear()
  print("CMonsterDetailView---del")
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  g_Click_MONSTER_Head_View = nil
end
