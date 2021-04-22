
local QBaseUiMask = import(".QBaseUiMask")
local QRectUiMask = class("QRectUiMask", QBaseUiMask)

function QRectUiMask:ctor(options)
    QRectUiMask.super.ctor(self, options)

    self._stencil = CCRectShape:create(CCSize(1, 1))
    self._stencil:setFill(true)
    self:setStencil(self._stencil)

    self._isLeftToRight = true
end

function QRectUiMask:setFromLeftToRight(isLeftToRight)
    self._isLeftToRight = isLeftToRight
end

function QRectUiMask:update(percent)
    if self:preUpdate(percent) == QDEF.HANDLED then
        return 
    end

    local size = self:getCascadeBoundingBox().size
    local margin = 0 -- TBD: move the magic number to config file
    local w = size.width - margin * 2 + (self._addWidth or 0)
    local stencil = self._stencil
    stencil:setSize(CCSizeMake(w * percent, size.height))
    if self._isLeftToRight == true then
        stencil:setPosition(w * (percent - 1.0) * 0.5 + margin, 0)
    else
        stencil:setPosition(w * (1.0 - percent) * 0.5 + margin, 0)
    end
end

function QRectUiMask:update2(from_percent, to_percent)
    local size = self:getCascadeBoundingBox().size
    local margin = 0 -- TBD: move the magic number to config file
    local w = size.width - margin * 2 + (self._addWidth or 0)
    local stencil = self._stencil
    stencil:setSize(CCSizeMake(w * math.abs(from_percent - to_percent), size.height))
    if self._isLeftToRight == true then
        stencil:setPosition(w * ((from_percent + to_percent) / 2 - 0.5) + margin, 0)
    else
        stencil:setPosition(w * (0.5 - (from_percent + to_percent) / 2) + margin, 0)
    end

    self._from_percent = from_percent
    self._to_percent = to_percent
end

function QRectUiMask:setAdditionalWidth(addWidth)
    self._addWidth = addWidth
end

function QRectUiMask:getFromToPercent()
    return self._from_percent, self._to_percent
end

return QRectUiMask
