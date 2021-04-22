
local QBaseUiMask = import(".QBaseUiMask")
local QFullCircleUiMask = class("QFullCircleUiMask", QBaseUiMask)

function QFullCircleUiMask:ctor(options)
    QFullCircleUiMask.super.ctor(self, options)
end

function QFullCircleUiMask:setRadius(radius)
    self:preUpdate(0.5)
    local stencil = self._stencil
    stencil:clear()
    -- stencil.drawCircle = self.drawCircle
    stencil:drawCircle(radius)
end

return QFullCircleUiMask
