--
-- Author: Qinyuanji
-- Date: 2014-11-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSystemSetting = class("QUIWidgetSystemSetting", QUIWidget)
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QSystemSetting = import("...controllers.QSystemSetting")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSystemsettingClient2 = import(".QUIWidgetSystemsettingClient2")
local QUIWidgetSwitchBtn = import("..widgets.QUIWidgetSwitchBtn")
local QUIWidgetSlider = import("..widgets.QUIWidgetSlider")
local QLogFile = import("...utils.QLogFile")


QUIWidgetSystemSetting.PAGE_MARGIN = 40
QUIWidgetSystemSetting.EVENT_RESPOND_IGNORE = 0.3


function QUIWidgetSystemSetting:ctor()
	local ccbFile = "ccb/Widget_Rongyao_wanjia2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onbtn1_handler", callback = handler(self, self._onbtn1_handler)},
		{ccbCallbackName = "onbtn2_handler", callback = handler(self, self._onbtn2_handler)},
		{ccbCallbackName = "onbtn3_handler", callback = handler(self, self._onbtn3_handler)},
		{ccbCallbackName = "onbtn4_handler", callback = handler(self, self._onbtn4_handler)},
		{ccbCallbackName = "onbtn5_handler", callback = handler(self, self._onbtn5_handler)},
		{ccbCallbackName = "onbtn6_handler", callback = handler(self, self._onbtn6_handler)},
		{ccbCallbackName = "onMusicSwitch", callback = handler(self, self._onMusicSwitch)},
		{ccbCallbackName = "onSoundEffectSwitch", callback = handler(self, self._onSoundEffectSwitch)},
		{ccbCallbackName = "onClickLogout", callback = handler(self, self._onClickLogout)},
		{ccbCallbackName = "onClickPlatfromCenter", callback = handler(self, self._onClickPlatfromCenter)},
		{ccbCallbackName = "onClickForum", callback = handler(self, self._onClickForum)},
		{ccbCallbackName = "onClickCustomerService", callback = handler(self, self._onClickCustomerService)},
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
		{ccbCallbackName = "onClickDebugVCS", callback = handler(self, self._onClickDebugVCS)},
		{ccbCallbackName = "onClickDebugLocalConfig", callback = handler(self, self._onClickDebugLocalConfig)},
		{ccbCallbackName = "onClickBindingPhone", callback = handler(self, self._onClickBindingPhone)},
		{ccbCallbackName = "onTriggerFullScreenHelp", callback = handler(self, self._onTriggerFullScreenHelp)},
		{ccbCallbackName = "onTriggerUploadLog", callback = handler(self, self._onTriggerUploadLog)},
	}
	QUIWidgetSystemSetting.super.ctor(self, ccbFile, callBacks, options)

    q.setButtonEnableShadow(self._ccbOwner.btn_uploadLog)
    q.setButtonEnableShadow(self._ccbOwner.btn_fs_help)

    self._contentWidth = 740
    self._contentHeight = 650
	self._lastMoveTime = q.time()

	local btnList = {
		{id = 1, isOpen = true},
		{id = 2, isOpen = true},
		{id = 3, isOpen = true},
		{id = 4, isOpen = true},
		{id = 5, isOpen = true},
		{id = 6, isOpen = true},
	}
	self._btnWidgetList = {}
	self._btnList = btnList
	self:initBtnList()

	self._ccbOwner.node_loginout:setVisible(false)
	self._ccbOwner.node_platformCenter:setVisible(false)
	self._ccbOwner.node_forum:setVisible(false)
	self._ccbOwner.node_customService:setVisible(false)
	self._ccbOwner.node_vcs:setVisible(false) 
	self._ccbOwner.node_local_config:setVisible(false) 
	self._ccbOwner.node_bindingPhone:setVisible(false)
	self._ccbOwner.node_uploadLog:setVisible(false)

	local index = 1
	if app:isDeliveryIntegrated() == true then
		local positions = {}
		local x, y = self._ccbOwner.node_platformCenter:getPosition()
		table.insert(positions, {x, y})
		x, y = self._ccbOwner.node_forum:getPosition()
		table.insert(positions, {x, y})
		x, y = self._ccbOwner.node_customService:getPosition()
		table.insert(positions, {x, y})
		x, y = self._ccbOwner.node_loginout:getPosition()
		table.insert(positions, {x, y})

		if FinalSDK.hasLogoutBtn() then
			self._ccbOwner.node_loginout:setVisible(true)
			self._ccbOwner.node_loginout:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
		
		if QDeliveryWrapper:isHasPlatformCenter() then
			self._ccbOwner.node_platformCenter:setVisible(true)
			self._ccbOwner.node_platformCenter:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
		if QDeliveryWrapper:isHasForum() then
			self._ccbOwner.node_forum:setVisible(true)
			self._ccbOwner.node_forum:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
		if QDeliveryWrapper:isHasCustomerService() then
			self._ccbOwner.node_customService:setVisible(true)
			self._ccbOwner.node_customService:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end

		if remote.bindingPhone:checkOpenBindingPhone() then
			self._ccbOwner.node_bindingPhone:setVisible(true)
			self._ccbOwner.node_bindingPhone:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end

		if device.platform == "ios" then
			self._ccbOwner.node_uploadLog:setVisible(true)
			self._ccbOwner.node_uploadLog:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
	else
		self._ccbOwner.node_loginout:setVisible(true)
		self._ccbOwner.node_vcs:setVisible(not not DISPLAY_VCS)
		self._ccbOwner.node_local_config:setVisible(not not DISPLAY_VCS)
		local positions = {}
		local x, y = self._ccbOwner.node_platformCenter:getPosition()
		table.insert(positions, {x, y})
		local x, y = self._ccbOwner.node_forum:getPosition()
		table.insert(positions, {x, y})
		x, y = self._ccbOwner.node_customService:getPosition()
		table.insert(positions, {x, y})
		x, y = self._ccbOwner.node_loginout:getPosition()
		table.insert(positions, {x, y})

		self._ccbOwner.node_loginout:setPosition(positions[index][1], positions[index][2])
		index = index + 1

		if DISPLAY_VCS then
			self._ccbOwner.node_vcs:setPosition(positions[index][1], positions[index][2])
			index = index + 1

			self._ccbOwner.node_local_config:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
		
		if remote.bindingPhone:checkOpenBindingPhone() then
			self._ccbOwner.node_bindingPhone:setVisible(true)
			self._ccbOwner.node_bindingPhone:setPosition(positions[index][1], positions[index][2])
			index = index + 1
		end
	end

	self._ccbOwner.node_fullscreen:setVisible(false)


	local y = self._ccbOwner.node_system_setting:getPositionY()
	local rowHight = 85
    local major = FULL_SCREEN_ADAPTATION_VERSION.major
    local minor = FULL_SCREEN_ADAPTATION_VERSION.minor
    local revision = FULL_SCREEN_ADAPTATION_VERSION.revision
	if app:isNativeLargerEqualThan(major, minor, revision) and display.width > UI_VIEW_MIN_WIDTH and false then
		local slider_y = self._ccbOwner.node_fullscreen:getPositionY()
		if index > 1 and index <= 4 then
			self._ccbOwner.node_fullscreen:setPositionY(slider_y + rowHight)
		elseif index <= 1 then
			self._ccbOwner.node_fullscreen:setPositionY(slider_y + rowHight+ rowHight)
		end
		self:initSliderBar()
	else
		y = y + 40
	end

	if index > 1 and index <= 4 then
		self._ccbOwner.node_system_setting:setPositionY(y + rowHight)
		self._contentHeight = self._contentHeight - rowHight
	elseif index <= 1 then
		self._ccbOwner.node_system_setting:setPositionY(y + rowHight + rowHight)
		self._contentHeight = self._contentHeight - rowHight - rowHight
	end

	if QNotification.isRemotePushEnable then
		if QNotification:isRemotePushEnable() then
			self:addSystemSetting()
		end
	end

	if HIDE_GAME_CDKEY then
		self._ccbOwner.node_cdkey:setVisible(false)
	end


	self:updateRedTips()
end

function QUIWidgetSystemSetting:initSliderBar()


	self._ccbOwner.node_fullscreen:setVisible(true)

	local fontcolor = ccc3(255,251,244)
	local outlinecolor = ccc3(200,94,37)
	local button_frame = QSpriteFrameByPath("ui/update_common/button.plist/btn_normal_orange_small.png")
	self._sliderBar = QUIWidgetSlider.new(display.LEFT_TO_RIGHT, {bar = "ui/update_common/screen_line.png"
		,button = button_frame}, {scale9 = true , button_scale = 0.5,scale9Size_={396,8} , AnchorPoint = {0,0.5}})
	self._sliderBar:addButtonText(18,fontcolor,outlinecolor)
	self._sliderBar:setAnchorPoint(0,0.5)
	self._sliderBar:setSliderEnabled(true)
	self._ccbOwner.node_slider:addChild(self._sliderBar)

    local cur_width = display.ui_width - UI_VIEW_MIN_WIDTH
    local width_  = 1
    if display.width > UI_VIEW_MIN_WIDTH then
		width_ = display.width - UI_VIEW_MIN_WIDTH
    end
    local value = tonumber(cur_width) / width_
    value = value * 100
    if value > 100 or value < 0 then
    	value = 100
    end
	self._sliderBar:setSliderValue(value)
	self._sliderBar:addSliderReleaseEventListener(function ( )
			print("addSliderReleaseEventListener")
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = "QUIDialogMyInformation_OpenScrollViewTouch" ,open = 1})
	end)	

	self._sliderBar:addSliderPressedEventListener(function ( )
			print("addSliderPressedEventListener")
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = "QUIDialogMyInformation_OpenScrollViewTouch" ,open = 2})
	end)

	self._sliderBar:addSliderValueChangedEventListener(function ( )
		self.slider_percent = self._sliderBar:getSliderValue()
		local float = self.slider_percent / 100
		self._sliderBar.barSprite_:setScaleX(float)
		local width_ = display.width - UI_VIEW_MIN_WIDTH
		width_ = width_ * float + UI_VIEW_MIN_WIDTH
		app:updateUIViewSize(CCSize(width_, display.height))		
	end)
end

function QUIWidgetSystemSetting:onEnter()
    self._bindingPhoneProxy = cc.EventProxy.new(remote.bindingPhone)
    self._bindingPhoneProxy:addEventListener(remote.bindingPhone.EVENT_UPDATE_BINDINGPHONE, handler(self, self.updateRedTips))

	self:loadSystemSettingState()
	self:refreshSystemSettingState()
end

function QUIWidgetSystemSetting:onExit()

	app:saveUIViewSize()

	if self._bindingPhoneProxy then
    	self._bindingPhoneProxy:removeAllEventListeners()
   		self._bindingPhoneProxy = nil
	end
end

function QUIWidgetSystemSetting:updateRedTips()
	self._ccbOwner.sp_binding_tip:setVisible(remote.bindingPhone:checkRedTips())
end

function QUIWidgetSystemSetting:initBtnList()
	for i, info in pairs(self._btnList) do
		local widget = QUIWidgetSwitchBtn.new()
        widget:addEventListener(QUIWidgetSwitchBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
		widget:setInfo(info)
		self._ccbOwner["node_btn_"..i]:addChild(widget)
		self._btnWidgetList[i] = widget
	end
end

function QUIWidgetSystemSetting:btnItemClickHandler(event)
	if q.time() - self._lastMoveTime < QUIWidgetSystemSetting.EVENT_RESPOND_IGNORE then
		return
	end
	local widget = event.widget or {}
	local info = event.info or {}
	local isOpen = not info.isOpen
    for i, v in pairs(self._btnList) do
    	if v.id == info.id then
			v.isOpen = isOpen
			break
		end
	end
    app:getSystemSetting():setSystemSetting(info.id, isOpen and "on" or "off")
    self:refreshSystemSettingState()
end

-- Remember the last state
function QUIWidgetSystemSetting:loadSystemSettingState()
	-- set settings state 
	self._musicOn = app:getSystemSetting():getMusicState() == "on" and true or false
	self._soundEffectOn = app:getSystemSetting():getSoundState() == "on" and true or false

	for i, info in pairs(self._btnList) do
		info.isOpen = app:getSystemSetting():getSystemSetting(i) == "on" and true or false
	end
end

function QUIWidgetSystemSetting:refreshSystemSettingState()
    for i, v in pairs(self._btnList) do
		self._btnWidgetList[i]:setInfo(v)
	end
    self._ccbOwner.music_on:setVisible(self._musicOn)
    self._ccbOwner.music_off:setVisible(not self._musicOn)
    self._ccbOwner.soundeffect_on:setVisible(self._soundEffectOn)
    self._ccbOwner.soundeffect_off:setVisible(not self._soundEffectOn)
end

function QUIWidgetSystemSetting:_onMusicSwitch()
 	if q.time() - self._lastMoveTime < QUIWidgetSystemSetting.EVENT_RESPOND_IGNORE then
		return
	end
	app.sound:playSound("common_item")

	self._musicOn = not self._musicOn
    self._ccbOwner.music_on:setVisible(self._musicOn)
    self._ccbOwner.music_off:setVisible(not self._musicOn)
    audio.setMusicVolume(self._musicOn and global.music_volume or 0)
    
	app:getSystemSetting():setMusicState(self._musicOn and "on" or "off")

end

function QUIWidgetSystemSetting:_onClickLogout(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_logout) == false then return end
	app:alert({content = "是否确定注销", title = "系统提示", callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
            if app:isDeliverySDKInitialzed() then
				scheduler.performWithDelayGlobal(function()
		                print("QDeliveryWrapper:logout()")
		                -- QDeliveryWrapper:logout()
		                if device.platform == "android" then
		                    self._logoutCallback = function ( ... )
		                    end
		                elseif device.platform == "ios" then
		                    app._isLogin = false
		                    self._logoutCallback = function ( ... )
		                        app:showLoading()
		                        scheduler.performWithDelayGlobal(function()
		                            app:afterSDKLogin()
		                        end, 1.5)
		                    end
		                end
		                FinalSDK:logout(self._logoutCallback)
		        end, 1)
			else
				local _logoutCallback = function() 
					if not app:isDeliveryIntegrated() then
						app:logout()
					end
				end
				FinalSDK:logout(_logoutCallback)
			end
        end
    end})
	
end

function QUIWidgetSystemSetting:_onTriggerFullScreenHelp(event) 
	--if q.buttonEventShadow(event, self._ccbOwner.btn_fs_help) == false then return end
	 app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFullScreenIntroDialog"
	 	, options = {}}, {isPopCurrentDialog = false})
end

function QUIWidgetSystemSetting:_onTriggerUploadLog(event)
	QLogFile:uploadTodayLogs(remote.user.clientCrashLogUrl, remote.user.serverEnv, function ( ... )
		app.tip:floatTip("日志上传成功，感谢您的支持！")
	end)
end

function QUIWidgetSystemSetting:_onClickPlatfromCenter(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_platfrom) == false then return end
	if QDeliveryWrapper:isHasPlatformCenter() then
		QDeliveryWrapper:openPlatformCenter()
	end
end

function QUIWidgetSystemSetting:_onClickForum(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_forum) == false then return end
	if QDeliveryWrapper:isHasForum() then
		QDeliveryWrapper:openForum()
	end
end

function QUIWidgetSystemSetting:_onClickCustomerService(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_service) == false then return end
	if QDeliveryWrapper:isHasCustomerService() then
		QDeliveryWrapper:openCustomerService()
	end
end

function QUIWidgetSystemSetting:_onClickDebugVCS(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_vcs) == false then return end
	app.tip:floatTip(
		"wow-client: "..tostring(COMMIT_WOW_CLIENT).." "..tostring(COMMIT_DATE_WOW_CLIENT).."\n"..
		"wow-ccb: "..tostring(COMMIT_WOW_CCB).." "..tostring(COMMIT_DATE_WOW_CCB).."\n"..
		"p4-changelist: "..tostring(CHANGELIST_P4)
		)
end

function QUIWidgetSystemSetting:_onClickDebugLocalConfig(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_local_config) == false then return end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLocalConfig"})
end

function QUIWidgetSystemSetting:_onClickBindingPhone(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_phone) == false then return end
	app.sound:playSound("common_small")

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.IOS_BINDING_PHONE) == true then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.IOS_BINDING_PHONE)
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBindingPhone"}, {isPopCurrentDialog = false})
end

function QUIWidgetSystemSetting:_onTriggerExchange(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_exchange) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogExchange"}, {isPopCurrentDialog = false})
end

function QUIWidgetSystemSetting:_onSoundEffectSwitch()
 	if q.time() - self._lastMoveTime < QUIWidgetSystemSetting.EVENT_RESPOND_IGNORE then
		return
	end
	app.sound:playSound("common_item")

	self._soundEffectOn = not self._soundEffectOn
    self._ccbOwner.soundeffect_on:setVisible(self._soundEffectOn)
    self._ccbOwner.soundeffect_off:setVisible(not self._soundEffectOn)
    audio.setSoundsVolume(self._soundEffectOn and global.sound_volume or 0)
	app:getSystemSetting():setSoundState(self._soundEffectOn and "on" or "off")
end

-- React on movement gesture
function QUIWidgetSystemSetting:onMove()
	if self.slider_move then return end
	self._lastMoveTime = q.time()
end

function QUIWidgetSystemSetting:endMove()
	if self.slider_move then return end
	self._lastMoveTime = q.time()
end

function QUIWidgetSystemSetting:getContentSize()
	return CCSize(self._contentWidth, self._contentHeight)
end

function QUIWidgetSystemSetting:addSystemSetting()
	-- body
	
	local temp = {}
	local pushList = QStaticDatabase:sharedDatabase():getRemoteNotification()
	for k, v in pairs(pushList) do
		if app.unlock:checkLock(v.unlock) then
			local temp2 = {}
			temp2.id = "PUSH_SET_"..v.id
			temp2.isOpen = remote:getNotifiCationSystemSetting(temp2.id) or 0
			temp2.label = v.switch
			
			table.insert(temp, temp2)
		end
	end

	for k, v in pairs(temp) do
		local item = QUIWidgetSystemsettingClient2.new()
		item:setInfo(v)
		self._ccbOwner.otherNode:addChild(item)
		item:setPosition(((k-1)%2)*340,  math.floor((k -1)/2)*(-75))
	end

	self._ccbOwner.systemSettingBg:setContentSize(CCSizeMake(738.0, 312 + 75 * (math.ceil(#temp/2))))
	self._contentHeight = self._contentHeight  + 75 * (math.floor(#temp/2))

end


return QUIWidgetSystemSetting