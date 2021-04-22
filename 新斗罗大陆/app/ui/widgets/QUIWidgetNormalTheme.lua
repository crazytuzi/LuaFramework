-- 
-- Kumo.Wang
-- 非活動主題icon
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNormalTheme = class("QUIWidgetNormalTheme", QUIWidget)

QUIWidgetNormalTheme.EVENT_CLICK = "THEME_EVENT_CLICK"

function QUIWidgetNormalTheme:ctor( ... )
	local ccbFile = "ccb/Page_Mainmenu_icon.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetNormalTheme._onTriggerClick)},
  	}
	QUIWidgetNormalTheme.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_icon_countdown:setVisible(false)
    self._c4 = ccc4f(0, 0.35, 45.0, 0.9)
end

function QUIWidgetNormalTheme:onEnter()
    self:getView():addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onFrame))
    self:getView():scheduleUpdate()
end

function QUIWidgetNormalTheme:onExit()
    self:getView():removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:getView():unscheduleUpdate()
end

function QUIWidgetNormalTheme:onFrame()
	if self._showBtnInfo and self._showBtnInfo.haveScanning then
		self._c4.r = app:getScanningSpeed()
		setNodeScanningProgram(self._ccbOwner.node_scanning, self._c4)
	end
end

function QUIWidgetNormalTheme:setName(str)
	self._ccbOwner.tf_name:setString(str or "")
end

function QUIWidgetNormalTheme:setIcon(path)
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

function QUIWidgetNormalTheme:setCountdown(str, color)
	if self._ccbView then
		self._tfCountdown:setString(str)
		if color then
			self._tfCountdown:setColor(color)
		end
	end
end

function QUIWidgetNormalTheme:isShowCountdown(boo)
	self._ccbOwner.node_icon_countdown:setVisible(boo)
	if boo then
		local nameHeight = self._ccbOwner.tf_name:getContentSize().height
		local tfNamePosY = self._ccbOwner.tf_name:getPositionY()
		self._ccbOwner.node_icon_countdown:setPositionY(tfNamePosY - nameHeight/2 - 10)
	end
end

-- 是否顯示小紅點
function QUIWidgetNormalTheme:isShowRedTips(boo)
	self._ccbOwner.sp_red_tips:setVisible(boo)
end

-- 是否屏蔽小紅點
function QUIWidgetNormalTheme:isScreenRedTips(boo)
	self._ccbOwner.node_red_tips:setVisible(boo)
end

function QUIWidgetNormalTheme:setInfo(key, info, index)
	local isGetIcon = false

	self._themeKey = key
	self._themeInfo = info
	self._themeIndex = index or 1
	local resInfo = self._themeInfo and self._themeInfo[self._themeIndex]
	self._showBtnInfo = resInfo
	-- 圖標
	if resInfo then
		self._ccbOwner.tf_name:setString(resInfo.name or "")
		self:setIcon(resInfo.path)

		self._ccbOwner.node_icon_countdown:setVisible(false)
		if resInfo.isCountdown then
			if not self._tfCountdown then
				self._tfCountdown = CCLabelTTF:create("", global.font_default, 16)
			    self._tfCountdown:setColor(COLORS.A)
				self._ccbOwner.node_icon_countdown:addChild(self._tfCountdown)
			end
		else
			if self._tfCountdown then
				self._tfCountdown:removeFromParent()
				self._tfCountdown = nil
			end
		end
	end
end

function QUIWidgetNormalTheme:_onTriggerClick(event)
	if q.buttonEventShadow(event, self._ccbOwner.sp_icon) == false then return end
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetNormalTheme.EVENT_CLICK, themeKey = self._themeKey, themeIndex = self._themeIndex})
end

return QUIWidgetNormalTheme