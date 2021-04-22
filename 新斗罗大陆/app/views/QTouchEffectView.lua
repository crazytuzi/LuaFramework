local QBaseEffectView = import(".QBaseEffectView")
local QTouchEffectView = class("QBaseEffectView", QBaseEffectView)

QTouchEffectView.EVENT_TOUCH_END = "EVENT_TOUCH_END"

function QTouchEffectView:ctor(actor, skeletonView)
	self.super.ctor(self, actor, skeletonView)

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QTouchEffectView:onEnter()
    self.super.onEnter(self)

    self:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function QTouchEffectView:onExit()
    self:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

    self.super.onExit(self)
end

function QTouchEffectView:onTouch(event)
    local allow, warning = app.battle:isAllowControl()
    if not allow then
        app.tip:floatTip(warning)
        return
    end

    local scale = BATTLE_SCREEN_WIDTH / UI_DESIGN_WIDTH
    if event.x ~= nil then
        event.x = event.x * scale
    end
    if event.y ~= nil then
        event.y = event.y * scale
    end

    if event.name == "began" then
        self._isTouchOnMe = self:isTouchMoveOnMe(event.x, event.y)
        return self._isTouchOnMe
    elseif event.name == "ended" then
        if self._isTouchOnMe and self:isTouchMoveOnMe(event.x, event.y) then
            self:dispatchEvent({name = QTouchEffectView.EVENT_TOUCH_END})
        end
    end
end

function QTouchEffectView:isTouchMoveOnMe( x, y )
    local rect = self:getModel():getBoundingBox()
    if rect:containsPoint(ccp(x, y)) then
        return true
    end
    return false
end

function QTouchEffectView:getModel()
	return self._model
end

function QTouchEffectView:setModel(model)
    self._model = model
end

return QTouchEffectView