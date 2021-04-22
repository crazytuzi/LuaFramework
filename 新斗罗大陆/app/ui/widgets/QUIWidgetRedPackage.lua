-- @Author: DELL
-- @Date:   2020-03-27 18:29:11
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-02 15:16:56
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRedPackage = class("QUIWidgetRedPackage", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIWidgetRedPackage.EVENT_TOUCH_CLICK = "EVENT_TOUCH_CLICK"

function QUIWidgetRedPackage:ctor(options)
	local ccbFile = "ccb/Widget_SkyFall_RedPackage.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetRedPackage.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._isDowning = false
end

function QUIWidgetRedPackage:onEnter()
end

function QUIWidgetRedPackage:onExit()
end

function QUIWidgetRedPackage:setStartPosition(pos)
	self._startPos = pos
	self:setPosition(self._startPos)
end

function QUIWidgetRedPackage:runDownAction()
	self._isDowning = true
	self:setVisible(true)
	local speed = 280
	local moveHeight = display.ui_height+165
	local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(moveHeight/speed, ccp(0, -moveHeight)))
    actionArrayIn:addObject(CCFadeTo:create(0.2, 0))
    actionArrayIn:addObject(CCCallFunc:create(function ()
        self:setVisible(false)
        self:setPosition(self._startPos)
        self._isDowning = false
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self:runAction(ccsequence)

end

function QUIWidgetRedPackage:_onTriggerClick()
	self:stopAllActions()
	local ccbFile = "effects/tx_baoguang_effect.ccbi"
		local effect = QUIWidget.new(ccbFile)
		effect:setScale(0.05)
		self:addChild(effect)
	    local dur2 = q.flashFrameTransferDur(6)
		local arr = CCArray:create()
	    arr:addObject(CCDelayTime:create(dur2))
	    arr:addObject(CCCallFunc:create(function()
	    	effect:stopAllActions()
	    	effect:removeFromParent()
			self:setVisible(false)
			self._isDowning = false	    	
	    end))
		effect:runAction(CCSequence:create(arr))
        self:dispatchEvent({name = QUIWidgetRedPackage.EVENT_TOUCH_CLICK,posX = self:getPositionX(),posY = self:getPositionY()})
end

function QUIWidgetRedPackage:getIsDowning()
	return self._isDowning
end

function QUIWidgetRedPackage:getContentSize()
    return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRedPackage
