--
-- Author: Your Name
-- Date: 2015-02-14 15:59:08
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBuyVirtualLog = class("QUIWidgetBuyVirtualLog", QUIWidget)

local QUIWidgetBuyVirtualLogCell = import("..widgets.QUIWidgetBuyVirtualLogCell")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")

function QUIWidgetBuyVirtualLog:ctor(options)
	local ccbFile = "ccb/Widget_BuyAgain_Prompt.ccbi"
	local callBacks = {}
	QUIWidgetBuyVirtualLog.super.ctor(self, ccbFile, callBacks, options)

	self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
	self._pageContent = CCNode:create()

	local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
	local ccclippingNode = CCClippingNode:create()
	layerColor:setPositionX(self._ccbOwner.sheet_layout:getPositionX())
	layerColor:setPositionY(self._ccbOwner.sheet_layout:getPositionY())
	ccclippingNode:setStencil(layerColor)
	ccclippingNode:addChild(self._pageContent)

	self._ccbOwner.sheet:addChild(ccclippingNode)
	
	self._touchLayer = QUIGestureRecognizer.new()

	self._cellHeight = 35
	self._totalHeight = 0

end

function QUIWidgetBuyVirtualLog:onEnter()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.sheet,self._pageWidth, self._pageHeight, 0, -self._pageHeight/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QUIWidgetBuyVirtualLog:onExit()
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    if self._delayHandler ~= nil then
    	scheduler.unscheduleGlobal(self._delayHandler)
    end
end

function QUIWidgetBuyVirtualLog:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveTo(event.distance.y, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startY = event.y
  		self._pageY = self._pageContent:getPositionY()
  		self._isMove = true 
    elseif event.name == "moved" then
    	local offsetY = self._pageY + event.y - self._startY
		self:moveTo(offsetY, false)
	elseif event.name == "ended" then
  		self._isMove = false 
    end
end

function QUIWidgetBuyVirtualLog:_removeAction()
	if self._actionHandler ~= nil then
		self._pageContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIWidgetBuyVirtualLog:moveTo(posY, isAnimation)
	if isAnimation == false then
		self._pageContent:setPositionY(posY)
		return 
	end

	local contentY = self._pageContent:getPositionY()
	local targetY = 0
	if self._totalHeight <= self._pageHeight then
		targetY = 0
	elseif contentY + posY > self._totalHeight - self._pageHeight then
		targetY = self._totalHeight - self._pageHeight
	elseif contentY + posY < 0 then
		targetY = 0
	else
		targetY = contentY + posY
	end
	self:_contentRunAction(0, targetY)
end

function QUIWidgetBuyVirtualLog:_contentRunAction(posX,posY)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.15, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:_removeAction()
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._pageContent:runAction(ccsequence)
end

function QUIWidgetBuyVirtualLog:addLog(cost, receive, crit)
	if self._logs == nil then self._logs = {} end
	self._logs[#self._logs + 1] = {cost=cost, receive=receive, crit=crit, speed = 0.15}
	local speed = 2/#self._logs
	if speed > 0.15 then
		self._logs[#self._logs].speed = 0.15
	else
		self._logs[#self._logs].speed = speed
	end

	if self._delayFun == nil then
		self._delayFun = function ()
			table.remove(self._logs, 1)
			if #self._logs > 0 then
				self:_addLog(self._logs[1].cost, self._logs[1].receive, self._logs[1].crit)
				self._delayHandler = scheduler.performWithDelayGlobal(self._delayFun, self._logs[1].speed)
			end
		end
	end

	if #self._logs == 1 then
		self:_addLog(self._logs[1].cost, self._logs[1].receive, self._logs[1].crit)
		self._delayHandler = scheduler.performWithDelayGlobal(self._delayFun, self._logs[1].speed)
	end
end

function QUIWidgetBuyVirtualLog:_addLog(cost, receive, crit)
	local cell = QUIWidgetBuyVirtualLogCell.new()
	cell:addLog(cost, receive, crit)
	cell:setPositionY(-self._totalHeight)
	cell:setPositionX(self._pageWidth/2)
	self._pageContent:addChild(cell)
	self._totalHeight = self._totalHeight + self._cellHeight
	if self._isMove ~= true then
  		self:_removeAction()
		self:moveTo(self._totalHeight)
	end
end

return QUIWidgetBuyVirtualLog