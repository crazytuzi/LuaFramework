local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMainMenuLightController = class("QUIWidgetMainMenuLightController", QUIWidget)

QUIWidgetMainMenuLightController.TIME_INTERVAL = 1--60*MIN
QUIWidgetMainMenuLightController.TIME_START = 11*HOUR + 43*MIN
QUIWidgetMainMenuLightController.TIME_END = 11*HOUR + 45*MIN

function QUIWidgetMainMenuLightController:ctor(options)
	QUIWidgetMainMenuLightController.super.ctor(self,nil,nil,options)
end

function QUIWidgetMainMenuLightController:onEnter()
	QUIWidgetMainMenuLightController.super.onEnter(self)
    -- self._userEventProxy = cc.EventProxy.new(remote.user)
    -- self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self,self.refreshTimeHandler))

    self:startTimeCount()
end

function QUIWidgetMainMenuLightController:onExit()
	QUIWidgetMainMenuLightController.super.onExit(self)
	-- if self._userEventProxy ~= nil then
	-- 	self._userEventProxy:removeAllEventListeners()
	-- 	self._userEventProxy = nil
	-- end
	self:endTimeCount()
end

-- function QUIWidgetMainMenuLightController:refreshTimeHandler()
	
-- end

function QUIWidgetMainMenuLightController:startTimeCount()
	if self.isInit == nil then
		self:initLayer()
	end
	self:endTimeCount()
	self.timeHandler = scheduler.scheduleGlobal(handler(self, self.refreshLayer), QUIWidgetMainMenuLightController.TIME_INTERVAL)
end

function QUIWidgetMainMenuLightController:endTimeCount( ... )
	if self.timeHandler ~= nil then
		scheduler.unscheduleGlobal(self.timeHandler)
		self.timeHandler = nil
	end
end

function QUIWidgetMainMenuLightController:initLayer()
	self.isInit = true
	local startC4,endC4 = self:getColor()
	self.layer = CCLayerGradient:create(startC4, endC4)
	self:addChild(self.layer)
end

function QUIWidgetMainMenuLightController:refreshLayer()
	if self.isInit == nil then
		self:initLayer()
	end
	local startC4,endC4 = self:getColor()
	self.layer:setStartColor(ccc3(startC4.r, startC4.g, startC4.b))
	self.layer:setEndColor(ccc3(endC4.r, endC4.g, endC4.b))
	self.layer:setStartOpacity(startC4.a)
	self.layer:setEndOpacity(endC4.a)
end

function QUIWidgetMainMenuLightController:getColor()
	do
		return ccc4(0,0,0,0),ccc4(0,0,0,0)
	end

	local todayTime = q.serverTime() - q.getTimeForHMS(0,0,0)
	if todayTime < self.TIME_START then
		return ccc4(0,0,0,0),ccc4(0,0,0,0)
	elseif todayTime > self.TIME_END then
		return ccc4(0,0,0,50),ccc4(0,0,0,10)
	end
	local totalTime = self.TIME_END - self.TIME_START
	local offsetTime = todayTime - self.TIME_START
	local rate1 = math.abs(math.sin((offsetTime/totalTime)*math.pi))
	local rate2 = math.abs(math.sin((offsetTime/(totalTime*2))*math.pi))
	local startR = 255 * rate1
	local startG = 255 * rate1
	local startB = 0
	local startA = 50 * rate2
	local endR = 255 * rate1
	local endG = 0
	local endB = 0
	local endA = 10 * rate2
	return ccc4(startR,startG,startB,startA),ccc4(endR,endG,endB,endA)
end



return QUIWidgetMainMenuLightController