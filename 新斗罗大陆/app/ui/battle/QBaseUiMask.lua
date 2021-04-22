
local QBaseUiMask = class("QBaseUiMask", function()
    return CCClippingNode:create()
end)

function QBaseUiMask:ctor(options)
    self._stencil = CCDrawNode:create()
    self:setStencil(self._stencil)
    self._maskSize = CCSizeMake(0, 0)

    if options == nil then 
        options = {}
    end

    self._hideWhenFull = options.hideWhenFull
end

function QBaseUiMask:setMaskSize(size)
    if size ~= nil then
        self._maskSize = size
    end  
end

function QBaseUiMask:preUpdate(percent)
    self._percent = percent
    if percent <= 0 or (percent >= 1 and self._hideWhenFull == true) then
        -- hide the whole node
        self:setVisible(false)
        return QDEF.HANDLED
    end

    -- show this node
    self:setVisible(true)

    if percent >= 1 then
        -- show full, and hide stencil
        self:setInverted(true)
        self._stencil:setVisible(false)
        return QDEF.HANDLED
    end

    -- show node with stencil
    self:setInverted(false)
    self._stencil:setVisible(true)

    return
end

function QBaseUiMask:getPercent()
    if self._percent == nil then
        self._percent = 0
    end
    if self._percent <= 0 then
        return 0
    elseif self._percent >= 1 then
        return 1
    end

    return self._percent
end

function QBaseUiMask:update(percent)
    printError("please create a new class based on QBaseUiMask and override function update")
end

return QBaseUiMask