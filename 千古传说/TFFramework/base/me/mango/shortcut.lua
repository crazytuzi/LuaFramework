--
-- Author: MiYu
-- Date: 2014-02-20 14:40:50
--

----------------------------------------
-- TFUIBase
----------------------------------------
TFUIBase = TFUIBase or {}

--[[
    base shortcut
]]
-- behaviour
function TFUIBase:removeSelf(cleanup)
    if not tolua.isnull(self) then
        if cleanup ~= false then cleanup = true end
        self:removeFromParentAndCleanup(cleanup)
    end
end

function TFUIBase:addTo(target, zorder, tag)
    target:addChild(self, zorder or 0, tag or 0)
    return self
end

function TFUIBase:show()
    self:setVisible(true)
    return self
end

function TFUIBase:hide()
    self:setVisible(false)
    return self
end

function TFUIBase:center()
    self:setPosition(ccp(me.cx, me.cy))
    return self
end

function TFUIBase:pos(x, y)
    if not y then 
        self:setPosition(x)
    else 
        self:setPosition(ccp(x, y))
    end
    return self
end

function TFUIBase:anchorPoint(x, y)
    if not y then 
        self:setAnchorPoint(x)
    else 
        self:setAnchorPoint(ccp(x, y))
    end
    return self
end

function TFUIBase:size(x, y)
    if not y then 
        self:setSize(x)
    else 
        self:setSize(ccs(x, y))
    end
    return self
end

-- actions

function TFUIBase:timeOut(callback, delay, ...)
    local seqArr = TFVector:create()
    local tParam = {...}
    delay = delay or 0
	seqArr:addObject(CCDelayTime:create(delay))
	seqArr:addObject(CCCallFunc:create(function() callback(self, unpack(tParam)) end))
	action = CCSequence:create(seqArr)
    return self:runAction(action)
end

function TFUIBase:fadeIn(time)
    self:runAction(CCFadeIn:create(time))
    return self
end

function TFUIBase:fadeOut(time)
    self:runAction(CCFadeOut:create(time))
    return self
end

function TFUIBase:fadeTo(time, opacity)
    self:runAction(CCFadeTo:create(time, opacity))
    return self
end

function TFUIBase:moveTo(time, x, y)
    self:runAction(CCMoveTo:create(time, CCPoint(x or self:getPositionX(), y or self:getPositionY())))
    return self
end

function TFUIBase:moveBy(time, x, y)
    self:runAction(CCMoveBy:create(time, CCPoint(x or 0, y or 0)))
    return self
end

function TFUIBase:rotateTo(time, rotation)
    self:runAction(CCRotateTo:create(time, rotation))
    return self
end

function TFUIBase:rotateXTo(time, rotation)
    self:runAction(CCRotateTo:create(time, rotation, 0))
    return self
end

function TFUIBase:rotateYTo(time, rotation)
    self:runAction(CCRotateTo:create(time, 0, rotation))
    return self
end

function TFUIBase:rotateBy(time, rotation)
    self:runAction(CCRotateBy:create(time, rotation))
    return self
end

function TFUIBase:rotateXBy(time, rotation)
    self:runAction(CCRotateBy:create(time, rotation, 0))
    return self
end

function TFUIBase:rotateYBy(time, rotation)
    self:runAction(CCRotateBy:create(time, 0, rotation))
    return self
end

function TFUIBase:scaleTo(time, scale)
    self:runAction(CCScaleTo:create(time, scale))
    return self
end

function TFUIBase:scaleBy(time, scale)
    self:runAction(CCScaleBy:create(time, scale))
    return self
end

function TFUIBase:skewTo(time, sx, sy)
    self:runAction(CCSkewTo:create(time, sx or self:getSkewX(), sy or self:getSkewY()))
end

function TFUIBase:skewBy(time, sx, sy)
    self:runAction(CCSkewBy:create(time, sx or 0, sy or 0))
end

function TFUIBase:tintTo(time, r, g, b)
    self:runAction(CCTintTo:create(time, r or 0, g or 0, b or 0))
    return self
end

function TFUIBase:tintBy(time, r, g, b)
    self:runAction(CCTintBy:create(time, r or 0, g or 0, b or 0))
    return self
end