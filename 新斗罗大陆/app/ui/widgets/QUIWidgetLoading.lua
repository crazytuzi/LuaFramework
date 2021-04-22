
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLoading = class("QUIWidgetLoading", QUIWidget)
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QLogFile = import("...utils.QLogFile")

function QUIWidgetLoading:ctor(options)
	local ccbFile = "ccb/Widget_Loading.ccbi"
	local callBacks = {}
	QUIWidgetLoading.super.ctor(self, ccbFile, callBacks, options)
	self._animation = tolua.cast(self._ccbOwner.node_root:getUserObject(), "CCBAnimationManager")
	self._layer = self._ccbOwner.sprite_bg

	self:getView():setPosition(ccp(display.cx, display.cy))

	self._playing = false
	--用于延迟显示loading的定时器
	self._timeId = scheduler.scheduleGlobal(handler(self, QUIWidgetLoading._onTimer), 0.5)
	self:getView():setVisible(false)

	self._ccbOwner.sp_black_bg:setVisible(false)
	self._ccbOwner.node_text:setString("加载中")
	self._needDot = true
end

function QUIWidgetLoading:setCustomString(text, needDot)
	assert(text == nil or type(text) == "string", "")

	if text ~= nil then
		self._ccbOwner.node_text:setString(text)
	end

	self._customString = text
	self._needDot = needDot
end

function QUIWidgetLoading:Show()
	if self._startTime == nil then
		self._startTime = q.time()
	end
	--shou并没有延时出现，只是把背景和loading动画先隐藏起来
	self:getView():setVisible(true)
	self._ccbOwner.node_loading:setVisible(false)
	self._ccbOwner.node_text:setVisible(false)
	--self._layer:setVisible(false)
	self._layer:setOpacity(0)
	self._animation:runAnimationsForSequenceNamed("runloading")
	if self._timeId == nil then
		self._timeId = scheduler.scheduleGlobal(handler(self, QUIWidgetLoading._onTimer), 0.05)
	end
end

function QUIWidgetLoading:Hide()
	self._playing = false
	self:getView():setVisible(false)
	--隐藏起来时把timer kill掉 保证 只有一个timer
	if self._timeId then
		scheduler.unscheduleGlobal(self._timeId)
		self._timeId = nil
		self._startTime = nil
	end
end

function QUIWidgetLoading:_onFrame(dt)
    --self._fca:updateAnimation(dt)
end

function QUIWidgetLoading:_onTimer()
	if self.class == nil then return end

	if self._startTime then
		--计算从出现到定时器调用时的时间差
		local differ = q.time() - self._startTime

		--延迟显示时间
		if self._showTime == nil then
			self._showTime = QStaticDatabase:sharedDatabase():getConfigurationValue("LODING_TIME")
			self._showTime = (self._showTime or 500)/1000
		end

		if self:getView():isVisible() and differ > self._showTime then
			--printInfo("differ %f", differ)
			--self._layer:setVisible(true)
			--设置背景透明度让其显现出来
			self._layer:setOpacity(100)
			self._ccbOwner.node_loading:setVisible(true)
			self._ccbOwner.node_text:setVisible(true)
			if self._playing == false then
				--确保loading在一个网络请求时只运行一次
				self._playing = true
			else

			end
		end
	end

	-- "......"的更新
	if self._startTime then
		local text = self._customString and self._customString or "加载中"

		if not self._needDot then
			self._ccbOwner.node_text:setString(text)
		else
			if self._dotWidth == nil then
				self._ccbOwner.node_text:setString(text .. "..")
				local width2 = self._ccbOwner.node_text:getContentSize().width
				self._ccbOwner.node_text:setString(text .. ".")
				local width1 = self._ccbOwner.node_text:getContentSize().width
				self._dotWidth = width2 - width1

				self._originalPos = {x = self._ccbOwner.node_text:getPositionX(), y = self._ccbOwner.node_text:getPositionY()}
			end

			local differ = q.time() - self._startTime
			local dotnumber = math.floor(differ * 2) % 6 + 1
			local count = dotnumber
			local dot_text = ""
			while count > 0 do
				dot_text = dot_text .. "."
				count = count - 1
			end
			if self._dotNumber == nil or self._dotNumber ~= dotnumber then
				self._ccbOwner.node_text:setString(text .. dot_text)
				-- self._ccbOwner.node_text:setPosition(self._originalPos.x + (dotnumber - 1) * self._dotWidth / 2, self._originalPos.y)
				self._dotNumber = dotnumber
			end
		end
	end
end

function QUIWidgetLoading:setShowBlack(bVisible)
	self._ccbOwner.sp_black_bg:setVisible(bVisible)
end

function QUIWidgetLoading:onEnter()
	self._layer:setCascadeBoundingBox(CCRect(0, 0, display.width, display.height))
	self._layer:setTouchEnabled(true)
	self._layer:setTouchSwallowEnabled(true)
	--self._layer:setTouchPriority(-129)
	self._layer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetLoading._onTouch))
end

function QUIWidgetLoading:onExit()
	self._layer:setTouchEnabled(false)
	self._layer:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

	if self._timeId then
		scheduler.unscheduleGlobal(self._timeId)
		self._timeId = nil
	end
end

function QUIWidgetLoading:_onTouch(event)
	if event.name == "began" then
		return true
	end
end

function QUIWidgetLoading:sharedLoading()
	if app._loading == nil then
        app._loading = QUIWidgetLoading.new()
    end
    return app._loading
end

function QUIWidgetLoading:removeLoading()
	if app._loading then
        app._loading:removeFromParent()
        app._loading = nil
    end
end

return QUIWidgetLoading
