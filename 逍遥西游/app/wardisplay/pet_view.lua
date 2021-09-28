local CPetView = class("CPetView", CRoleViewBase)
function CPetView:ctor(pos, roleData, warScene)
  CPetView.super.ctor(self, pos, roleData, warScene)
  if roleData.hasND == 1 then
    self:addNeiDanAni()
  end
end
function CPetView:getType()
  return LOGICTYPE_PET
end
function CPetView:getNameColor()
  local nameColor = NameColor_Pet[self.m_Zs] or ccc3(255, 150, 0)
  return nameColor
end
function CPetView:addNeiDanAni()
  self.m_NeiDanAureole = CreateSeqAnimation("xiyou/ani/nd_aureole.plist", -1, nil, nil, false, 8)
  self:addNode(self.m_NeiDanAureole, NeiDanCircleZOrder)
end
function CPetView:setShapeAniWhenDead()
  CPetView.super.setShapeAniWhenDead(self)
  if self.m_NeiDanAureole ~= nil then
    self.m_NeiDanAureole:runAction(CCFadeOut:create(1))
  end
end
return CPetView
