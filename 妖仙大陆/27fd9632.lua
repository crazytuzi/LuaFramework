local Util = require "Zeus.Logic.Util"
local FlickHVExt = require "Zeus.Logic.FlickHVExt"

local LeftRightNavExt = {}
Util.WrapOOPSelf(LeftRightNavExt)

function LeftRightNavExt.New(leftBtn, rightBtn, onChangeCb, list, isCircle, flickCanvas, isH)
    local o = {}
    setmetatable(o, LeftRightNavExt)
    o:reset(leftBtn, rightBtn, onChangeCb, list, isCircle, flickCanvas, isH)
    return o
end

function LeftRightNavExt:reset(leftBtn, rightBtn, onChangeCb, list, isCircle, flickCanvas, isH)
    self._list = list
    self._leftBtn = leftBtn
    self._rightBtn = rightBtn
    self._onChangeCb = onChangeCb
    self._isCircle = isCircle
    if self._leftBtn then
        self._leftBtn.TouchClick = self._self_onBtnTouchClick
    end
    if self._rightBtn then
        self._rightBtn.TouchClick = self._self_onBtnTouchClick
    end

    self._selectIdx = -1
    self:selectIdx(1)

    if flickCanvas then
        local hFunc = isH and self._self__onFlick or nil
        local vFunc = not isH and self._self__onFlick or nil
        self._flickExt = FlickHVExt.New(flickCanvas, hFunc, vFunc)
    end
end

function LeftRightNavExt:getSelected()
    return self._selectIdx, self._list[self._selectIdx]
end

function LeftRightNavExt:resetData(list)
    self._list = list
    self._selectIdx = -1
    self:selectIdx(1)
end

function LeftRightNavExt:onBtnTouchClick(sender, isLeftBtn)
    if sender then
        isLeftBtn = sender == self._leftBtn
    end
    local isChange = false
    if isLeftBtn then
        isChange = self:selectIdx((self._selectIdx + #self._list - 2) % (#self._list) + 1)
    else
        isChange = self:selectIdx(self._selectIdx % (#self._list) + 1)
    end
    if isChange and self._onChangeCb then
        self._onChangeCb(self:getSelected())
    end
end

function LeftRightNavExt:_onFlick(isToNext)
    if not isToNext and (self._isCircle or self._selectIdx > 1) then
        self:onBtnTouchClick(self._leftBtn, true)
    elseif isToNext and (self._isCircle or self._selectIdx < #self._list) then
        self:onBtnTouchClick(self._rightBtn, false)
    end
end

function LeftRightNavExt:selectItem(data)
    local idx = table.indexOf(self._list, data)
    if idx then
        return self:selectIdx(idx)
    end
    return false
end

function LeftRightNavExt:selectIdx(idx)
    if idx <= 0 or idx > #self._list then return false end

    self._selectIdx = idx
    if self._leftBtn then
        self._leftBtn.Visible = #self._list > 1 and (self._isCircle or idx > 1)
    end
    if self._rightBtn then
        self._rightBtn.Visible = #self._list > 1 and (self._isCircle or idx < #self._list)
    end
    return true
end

return LeftRightNavExt
