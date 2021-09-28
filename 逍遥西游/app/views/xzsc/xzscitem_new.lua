CXZSCDlgItem = class("CXZSCDlgItem", CcsSubView)
function CXZSCDlgItem:ctor(rank, info)
  CXZSCDlgItem.super.ctor(self, "views/xzscitem.json")
  local rankPath
  if rank == 1 then
    rankPath = "views/paihangbang/phb_pic_rank1.png"
  elseif rank == 2 then
    rankPath = "views/paihangbang/phb_pic_rank2.png"
  elseif rank == 3 then
    rankPath = "views/paihangbang/phb_pic_rank3.png"
  end
  local ranktxt = self:getNode("rank")
  if rankPath == nil then
    ranktxt:setText(tostring(rank))
    ranktxt:setVisible(true)
  else
    ranktxt:setVisible(false)
    local p = ranktxt:getParent()
    local x, y = ranktxt:getPosition()
    local z = ranktxt:getZOrder()
    local rankIcon = display.newSprite(rankPath)
    p:addNode(rankIcon, z)
    rankIcon:setPosition(ccp(x, y))
  end
  local rolebg = self:getNode("rolebg")
  local p = rolebg:getParent()
  local x, y = rolebg:getPosition()
  local scalex = rolebg:getScaleX()
  local scaley = rolebg:getScaleY()
  local head = createHeadIconByRoleTypeID(info.rtype)
  p:addNode(head, 10)
  head:setScaleX(scalex)
  head:setScaleY(scaley)
  head:setPosition(ccp(x + HEAD_OFF_X * scalex, y + HEAD_OFF_Y * scaley))
  local name = self:getNode("name")
  name:setText(info.name)
  AutoLimitObjSize(name, 140)
  local zs = info.zs or 0
  local lv = info.lv or 0
  self:getNode("lv"):setText(string.format("%d转%d级", zs, lv))
  local star = info.star or 0
  self:getNode("star"):setText(tostring(star))
  local wincnt = info.wincnt or 0
  local warcnt = info.warcnt or 0
  self:getNode("win"):setText(string.format("%d/%d", wincnt, warcnt))
  local size = self:getContentSize()
  if rank % 2 == 0 then
    self.m_Bg_Split = display.newScale9Sprite("views/common/bg/bg1062.png", 4, 4, CCSize(10, 10))
    self.m_Bg_Split:setAnchorPoint(ccp(0, 0))
    self.m_Bg_Split:setContentSize(CCSize(size.width, size.height))
    self:addNode(self.m_Bg_Split, 0)
    self.m_Bg_Split:setPosition(ccp(0, 0))
  else
    self.m_Bg_Split = display.newScale9Sprite("views/common/bg/bg1063.png", 4, 4, CCSize(10, 10))
    self.m_Bg_Split:setAnchorPoint(ccp(0, 0))
    self.m_Bg_Split:setContentSize(CCSize(size.width, size.height))
    self:addNode(self.m_Bg_Split, 0)
    self.m_Bg_Split:setPosition(ccp(0, 0))
  end
end
function CXZSCDlgItem:Clear()
end
