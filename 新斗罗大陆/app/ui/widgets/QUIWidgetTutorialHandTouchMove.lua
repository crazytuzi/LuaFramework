
-- @Author: qinsiyang
-- @Date:   2019-10-22
-- 引导滑动效果


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTutorialHandTouchMove = class("QUIWidgetTutorialHandTouchMove", QUIWidget)
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetTutorialHandTouchMove:ctor(options)
	if not options then options = {} end
	local ccbFile = "ccb/Widget_TutorialHandTouchMove.ccbi"
	local callbacks = {}
	QUIWidgetTutorialHandTouchMove.super.ctor(self, ccbFile, callbacks, options)
	self._touchWidth = self._ccbOwner.touch_layer:getContentSize().width
	self._touchHeight = self._ccbOwner.touch_layer:getContentSize().height
    self._touchLayer = QUIGestureRecognizer.new({color = false})
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, self._touchWidth, self._touchHeight, self._ccbOwner.touch_layer:getPositionX(),
	self._ccbOwner.touch_layer:getPositionY(), handler(self, self.onTouchEvent))
	self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QUIWidgetTutorialHandTouchMove:onEnter()

end

function QUIWidgetTutorialHandTouchMove:onExit()

	self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

end

function QUIWidgetTutorialHandTouchMove:addCallBack(callback)
	self.callback_ = callback;
end

function QUIWidgetTutorialHandTouchMove:setActionPosition(_pos_X)

	self._ccbOwner.arr_action_node:removeAllChildren()
	local effect = QUIWidgetAnimationPlayer.new()
	effect:playAnimation("ccb/effects/jiantou_1.ccbi",nil,nil,false)
	self._ccbOwner.arr_action_node:addChild(effect)
	effect:setPositionX(_pos_X)

end


function QUIWidgetTutorialHandTouchMove:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
	if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    	if self._startY == nil then
    		return
    	end
    	local posY = event.distance.y

    	if math.abs(posY) ~= 0 then

			if	self.callback_ then
				self.callback_()
			end
		end
  	elseif event.name == "began" then
  		self._startY = event.y
    elseif event.name == "moved" then
    	if self._startY == nil  then
    		return
    	end
    	local offsetY = event.y - self._startY

		if	self.callback_  then
			self.callback_()
		end
	elseif event.name == "ended" then
    end
end



return QUIWidgetTutorialHandTouchMove