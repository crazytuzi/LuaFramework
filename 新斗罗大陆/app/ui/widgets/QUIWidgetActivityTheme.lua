-- 
-- zxs
-- 活动主题icon
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityTheme = class("QUIWidgetActivityTheme", QUIWidget)

QUIWidgetActivityTheme.EVENT_CLICK = "THEME_EVENT_CLICK"

function QUIWidgetActivityTheme:ctor( ... )
	local ccbFile = "ccb/Page_Mainmenu_icon.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetActivityTheme._onTriggerClick)},
  	}
	QUIWidgetActivityTheme.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._ccbOwner.node_icon_countdown:setVisible(false)
    self._c4 = ccc4f(0, 0.35, 45.0, 0.9)
end

function QUIWidgetActivityTheme:onEnter()
    self:getView():addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onFrame))
    self:getView():scheduleUpdate()
end

function QUIWidgetActivityTheme:onExit()
 --  	if self._seasonScheduler then
	-- 	scheduler.unscheduleGlobal(self._seasonScheduler)
	-- 	self._seasonScheduler = nil
	-- end

    self:getView():removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:getView():unscheduleUpdate()


end

function QUIWidgetActivityTheme:onFrame()
	self._c4.r = app:getScanningSpeed()
	setNodeScanningProgram(self._ccbOwner.node_scanning, self._c4)
end

function QUIWidgetActivityTheme:setInfo(themeInfo)
	local isGetIcon = false
	self._themeId = themeInfo.id
	-- 圖標
	if themeInfo then
		self._name = themeInfo.title
		self._ccbOwner.tf_name:setString(themeInfo.title or "节日狂欢")
		if themeInfo.icon then
			self:setIcon(themeInfo.icon)
		end
		self:handlerTimer()

	end

end

function QUIWidgetActivityTheme:getThemeId()
	return self._themeId
end

function QUIWidgetActivityTheme:setIcon(path)
	if not path then return end

	local texture = CCTextureCache:sharedTextureCache():addImage(path)
	if texture == nil then
		path = QResPath("default_page_main_icon")
		texture = CCTextureCache:sharedTextureCache():addImage(path)
	end
	self._ccbOwner.sp_icon:setTexture(texture)
	
	-- 背景
	local isDay = app:checkDayNightTime()
	local bgPath = QResPath("menu_icon")["icon_bg_daytime"]
	if not isDay then
		bgPath = QResPath("menu_icon")["icon_bg_evening"]
	end
	local texture = CCTextureCache:sharedTextureCache():addImage(bgPath)
	if texture then
		self._ccbOwner.sp_bg:setTexture(texture)
	end

	self:onFrame()
end

function QUIWidgetActivityTheme:isShowRedTips(bShow)
	self._ccbOwner.sp_red_tips:setVisible(bShow)
end


function QUIWidgetActivityTheme:handlerTimer()

	if self._themeId ~= remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE and self._themeId ~= remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS then
		return
	end
	print("handlerTimer")
	local proxyClass = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE) 
	local _svrData = proxyClass:getNewServerRechargeSvrDataByThemeId(self._themeId )
	if _svrData == nil then return end
    self._ccbOwner.node_icon_countdown:setVisible(true)
    QPrintTable(_svrData)
	self._endTime = _svrData.endAt / 1000
	print("handlerTimer"..self._endTime)


	if not self.tf_timer then
		self.tf_timer = CCLabelTTF:create("", global.font_default, 16)
		self.tf_timer:setColor(COLORS.A)
		self._ccbOwner.node_icon_countdown:addChild(self.tf_timer)
	end
	local func = function()
		local currTime = q.serverTime()
		local endTime = self._endTime - currTime
			if endTime > 0 then
	    		self.tf_timer:setString((q.converFun(endTime)))
	    	else
				self.tf_timer:stopAllActions()
	    		self.tf_timer:setString("活动结束")
	    	end
	end

	func()
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1))
	arr:addObject(CCCallFunc:create(func))
	self.tf_timer:stopAllActions()
	self.tf_timer:runAction(CCSequence:create(arr))
	self.tf_timer:runAction(CCRepeatForever:create(CCSequence:create(arr)))

end


function QUIWidgetActivityTheme:_onTriggerClick(event)
	if q.buttonEventShadow(event, self._ccbOwner.sp_icon) == false then return end

	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetActivityTheme.EVENT_CLICK, themeId = self._themeId})
end

return QUIWidgetActivityTheme