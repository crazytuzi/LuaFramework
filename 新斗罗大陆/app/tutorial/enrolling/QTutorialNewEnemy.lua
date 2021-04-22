local QTutorialPhase = import("..QTutorialPhase")
local QTutorialNewEnemy = class("QTutorialNewEnemy", QTutorialPhase)

local QUserData = import("...utils.QUserData")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QBattleManager = import("...controllers.QBattleManager")

function QTutorialNewEnemy:start()
	self._eventProxy = cc.EventProxy.new(app.battle)
    self._eventProxy:addEventListener(QBattleManager.NEW_ENEMY, handler(self, self._onNewEnemy))
end

function QTutorialNewEnemy:visit()
    if self._is_start then
        self:_showTutorial()
    end
end

function QTutorialNewEnemy:_showTutorial()
    if self._flag or (not app.scene._newEnemyTipsNode) then return end
    app.battle:pause()
    local touchNode = CCNode:create()
    touchNode:addChild(CCLayerColor:create(ccc4(0, 0, 0, 128), display.width, display.height)) 
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.scene:addChild(touchNode)
    touchNode:setTouchEnabled(true)
    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
    self._touchNode = touchNode
    -- self._handTouch = QUIWidgetTutorialHandTouch.new({word = "点击查看", direction = ("left")})
    self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
    local pos = {}
    pos.x,pos.y = app.scene._newEnemyTipsNode:getPosition()
    self._handTouch:setPosition(ccp(pos.x - 60,pos.y))
    app.scene:addChild(self._handTouch, 999)
    self:hightlightTips(touchNode)
    self._flag = true
end

function QTutorialNewEnemy:_onNewEnemy(event)
    if event.isShow and (not self._is_start) then
        self._is_start = true
    elseif (not event.isShow) and self._is_start then
        self:_touchEnd()
    end
end

function QTutorialNewEnemy:_onBattleEnd()
    if nil ~= self._eventProxy then
        self._eventProxy:removeAllEventListeners()
    end
end

function QTutorialNewEnemy:_onTouch(event)
    return true
end

function QTutorialNewEnemy:_touchEnd()
    self:dehighlightTips()
    self._is_start = false
    self._handTouch:removeFromParent()
    self._touchNode:removeFromParentAndCleanup(false)
    app:getUserData():setUserValueForKey("newEnemyTipsTutorial", QUserData.STRING_TRUE)
    self:finished()
end

function QTutorialNewEnemy:hightlightTips(highlightSheet)
    if self._tipsOriginalPos ~= nil then
        return
    end

    local tipsNode = app.scene._newEnemyTipsNode
    tipsNode:retain()
    self._tipsOriginalPos = ccp(tipsNode:getPosition())
    self._tipsNodeParent = tipsNode:getParent()
    local worldPos = tipsNode:getParent():convertToWorldSpace(self._tipsOriginalPos)
    tipsNode:removeFromParentAndCleanup(false)
    highlightSheet:addChild(tipsNode)
    tipsNode:setPosition(highlightSheet:convertToNodeSpace(worldPos))

end

function QTutorialNewEnemy:dehighlightTips()
    if self._tipsOriginalPos == nil then
        return
    end

    local tipsNode = app.scene._newEnemyTipsNode
    tipsNode:removeFromParentAndCleanup(false)
    self._tipsNodeParent:addChild(tipsNode)
    tipsNode:setPosition(self._tipsOriginalPos)
    tipsNode:release()
    self._tipsOriginalPos = nil
    self._tipsNodeParent = nil
end

return QTutorialNewEnemy