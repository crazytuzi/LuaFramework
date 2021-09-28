local ProgressClip = class("ProgressClip", require("universal.ProgressBase"))
function ProgressClip:ctor(imgBar, imgBg, currValue, fullValue, horizontal, proListener)
  assert(imgBg and imgBar and fullValue, "@ProgressClip:ctor(). Params may be error.")
  local barSp = display.newSprite(imgBar)
  local bgSp = display.newSprite(imgBg)
  if horizontal == nil then
    horizontal = true
  end
  self.m_isHorizontal = horizontal
  self.m_ProListener = proListener
  local _w
  if self.m_isHorizontal then
    self._rect = barSp:getTextureRect()
    _w = self._rect.size.width
  else
    self._rect = barSp:getContentSize()
    _w = self._rect.height
  end
  ProgressClip.super.ctor(self, barSp, bgSp, fullValue, currValue, _w)
  self:setNodeEventEnabled(true)
  self:update()
  self:ignoreContentAdaptWithSize(false)
  local bgSize = bgSp:getContentSize()
  self:setSize(bgSize)
end
function ProgressClip:updateBarLength(_length)
  if self.m_isHorizontal then
    self._bar:setScaleX(math.min(_length / self._fullLength, 1))
  else
    self._bar:setScaleY(math.min(_length / self._fullLength, 1))
  end
  if self.m_ProListener ~= nil then
    self.m_ProListener(_length / self._fullLength)
  end
end
function ProgressClip:onCleanup()
  self.m_ProListener = nil
end
return ProgressClip
