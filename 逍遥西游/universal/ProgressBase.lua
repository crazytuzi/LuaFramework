local ProgressBase = class("ProgressBase", function()
  return Widget:create()
end)
function ProgressBase:ctor(barSp, bgSp, fullValue, currValue, fullLength)
  assert(bgSp and barSp and fullValue, "@ProgressBase:ctor(). Params may be error.")
  self._minLength = 0
  self._fullValue = fullValue
  self._currValue = currValue or fullValue
  self._currValue = math.min(self._currValue, self._fullValue)
  self:addNode(bgSp)
  bgSp:setAnchorPoint(ccp(0, 0))
  self._bg = bgSp
  self:addNode(barSp, 1)
  barSp:setAnchorPoint(ccp(0, 0))
  self._bar = barSp
  local _w, _h = self._bar:getContentSize()
  self._fullLength = fullLength or _w
  self._barHeight = _h
end
function ProgressBase:updateBarLength(_length)
  echoError("@ProgressBase:updateBarLength(). Must be overrided.")
end
function ProgressBase:bg()
  return self._bg
end
function ProgressBase:bar()
  return self._bar
end
function ProgressBase:bgSize(w, h)
  self._bg:size(w, h)
  return self
end
function ProgressBase:barOffset(x, y)
  self._bar:setPosition(x, y)
  self:reposLabel()
  return self
end
function ProgressBase:barHeight(v)
  self._barHeight = v
  self:update()
  self:reposLabel()
  return self
end
function ProgressBase:getFullLength()
  return self._fullLength
end
function ProgressBase:value(v, fullValue)
  if fullValue then
    self._fullValue = fullValue
  end
  self._currValue = self:chkValue(v)
  self:update()
  return self
end
function ProgressBase:showLabel(fontSize, fontColor, txt)
  if self._label then
    self._label:clear()
  end
  if txt == nil then
    txt = string.format("%d/%d", self._currValue, self._fullValue)
  end
  self._label = CCLabelTTF:create(txt, ITEM_NUM_FONT, fontSize)
  self._label:setColor(fontColor)
  self:addNode(self._label, 2)
  self:reposLabel()
  AutoLimitObjSize(self._label, self._fullLength - 20)
  return self
end
function ProgressBase:updateTempLength()
  local _length = 0
  if 0 < self._fullValue then
    _length = math.floor(self._fullLength * self._tempCurrValue / self._fullValue)
  end
  _length = math.max(self._minLength, _length)
  self:updateBarLength(_length)
  if 0 >= self._tempCurrValue then
    self._bar:setVisible(false)
  else
    self._bar:setVisible(true)
  end
  if self._label then
    self._label:text(string.format("%d/%d", self._tempCurrValue, self._fullValue))
    AutoLimitObjSize(self._label, self._fullLength - 20)
  end
end
function ProgressBase:updateActionLength(deltav)
  self._tempCurrValue = self._tempCurrValue + deltav
  self:updateTempLength()
end
function ProgressBase:updateActionLengthOver()
  self._tempCurrValue = self._currValue
  self:update()
end
function ProgressBase:progressTo(v, duration, fullValue)
  if fullValue then
    self._fullValue = fullValue
  end
  if duration == nil or duration <= 0 then
    self:value(v)
    return self
  end
  v = self:chkValue(v)
  self._tempCurrValue = self._currValue
  self._currValue = v
  if self._barAction ~= nil then
    self:stopAction(self._barAction)
    self._barAction = nil
  end
  local dt = 0.03
  local t = math.ceil(duration / dt)
  if t <= 0 then
    self:updateActionLengthOver()
    return self
  end
  local deltav = (v - self._tempCurrValue) / t
  local act1 = CCDelayTime:create(dt)
  local act2 = CCCallFunc:create(function()
    self:updateActionLength(deltav)
  end)
  local seq = CCSequence:createWithTwoActions(act1, act2)
  local seq2 = CCRepeat:create(seq, t)
  local act3 = CCCallFunc:create(function()
    self:updateActionLengthOver()
  end)
  self._barAction = CCSequence:createWithTwoActions(seq2, act3)
  self:runAction(self._barAction)
  return self
end
function ProgressBase:progressBy(v, duration)
  self:progressTo(self._currValue + v, duration)
  return self
end
function ProgressBase:progressFull(duration)
  self:progressTo(self._fullValue, duration)
  return self
end
function ProgressBase:setActionEnd(func)
  self._actionEndFunc = func
  return self
end
function ProgressBase:update()
  local _length = 0
  if 0 < self._fullValue then
    _length = math.floor(self._fullLength * self._currValue / self._fullValue)
  end
  _length = math.max(self._minLength, _length)
  self:updateBarLength(_length)
  if 0 >= self._currValue then
    self._bar:setVisible(false)
  else
    self._bar:setVisible(true)
  end
  if self._label then
    self._label:text(string.format("%d/%d", self._currValue, self._fullValue))
    AutoLimitObjSize(self._label, self._fullLength - 20)
  end
end
function ProgressBase:chkValue(v)
  v = checkint(v)
  return math.max(0, math.min(v, self._fullValue))
end
function ProgressBase:callActionEndFunc(v)
  if self._actionEndFunc then
    self._actionEndFunc()
  end
end
function ProgressBase:reposLabel()
  if self._label then
    local _x, _y = self._bg:getPosition()
    local size = self._bg:getContentSize()
    _x = _x + math.floor(size.width / 2)
    _y = _y + math.floor(size.height / 2)
    self._label:setPosition(_x, _y)
  end
end
function ProgressBase:getCurrentValue()
  return self._currValue
end
return ProgressBase
