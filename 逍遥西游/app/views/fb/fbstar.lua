local fbstar = class("fbstar", CcsUIConfigView)
function fbstar:ctor(star)
  fbstar.super.ctor(self, "views/fbstar.json")
  self:setStar(star)
end
function fbstar:setStar(star)
  if star == nil then
    star = 0
  end
  for index = 1, 3 do
    local picStar = self:getNode(string.format("star%d", index))
    picStar:setVisible(index <= star)
  end
  self:setVisible(star > 0)
end
function fbstar:setFadeIn(dt)
  for index = 1, 3 do
    local picStar = self:getNode(string.format("star%d", index))
    picStar:setOpacity(0)
    picStar:runAction(CCFadeIn:create(dt))
    local picStarGray = self:getNode(string.format("starGray%d", index))
    picStarGray:setOpacity(0)
    picStarGray:runAction(CCFadeIn:create(dt))
  end
end
function fbstar:setFadeOut(dt)
  for index = 1, 3 do
    local picStar = self:getNode(string.format("star%d", index))
    picStar:runAction(CCFadeOut:create(dt))
    local picStar = self:getNode(string.format("starGray%d", index))
    picStar:runAction(CCFadeOut:create(dt))
  end
end
return fbstar
