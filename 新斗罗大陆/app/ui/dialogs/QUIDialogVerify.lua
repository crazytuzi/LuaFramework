
local QUIDialog = import(".QUIDialog")
local QUIDialogVerify = class("QUIDialogVerify", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

local MOBILE_REWARD_KEY = "mobil_prove"
local WECHAT_REWARD_KEY = "wechat_prove"

function QUIDialogVerify:ctor(options)
	local ccbFile = "ccb/Dialog_WechatApprove.ccbi"
	local callbacks = {
		{ccbCallbackName = "onDisplayVerifyPhone", callback = handler(self, QUIDialogVerify._onDisplayVerifyPhone)},
		{ccbCallbackName = "onDisplayVerifyWechat", callback = handler(self, QUIDialogVerify._onDisplayVerifyWechat)},
		{ccbCallbackName = "onGetPhoneVerifyCode", callback = handler(self, QUIDialogVerify._onGetPhoneVerifyCode)},
		{ccbCallbackName = "onTriggerPhoneVerify", callback = handler(self, QUIDialogVerify._onTriggerPhoneVerify)},
		{ccbCallbackName = "onTriggerGetPhoneVerifyReward", callback = handler(self, QUIDialogVerify._onTriggerGetPhoneVerifyReward)},
		{ccbCallbackName = "onTriggerWechatVerify", callback = handler(self, QUIDialogVerify._onTriggerWechatVerify)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogVerify._onTriggerClose)},
	}
	QUIDialogVerify.super.ctor(self, ccbFile, callbacks, options)
	self.isAnimation = true

	local staticDatabase = QStaticDatabase:sharedDatabase()
	local mobileItems = staticDatabase:getLuckyDraw(MOBILE_REWARD_KEY)
	local wechatItems = staticDatabase:getLuckyDraw(WECHAT_REWARD_KEY)

	self._mobileItemNodes = self:_createRewardItemNode(mobileItems)
	self._wechatItemNodes = self:_createRewardItemNode(wechatItems)

	self._textFieldPhoneNumber = ui.newEditBox({image = "ui/none.png", 
												size = CCSize(250, 33), 
												x = 19, y = 20, 
												listener = handler(self, self.onEditBoxEvent)} )
	self._textFieldPhoneNumber:setInputMode(kEditBoxInputModePhoneNumber)
	self._textFieldPhoneNumber:setPlaceHolder("请输入您的手机号码")
	self._textFieldPhoneNumber:setPlaceholderFontColor(display.COLOR_WHITE)
    self._textFieldPhoneNumber:setFont(global.font_name, 26)

	self._textFieldPhoneVerifyCode = ui.newEditBox({image = "ui/none.png", 
													size = CCSize(250, 33), 
													x = 19, y = -26,
													listener = handler(self, self.onEditBoxEvent)} )
	self._textFieldPhoneVerifyCode:setInputMode(kEditBoxInputModeNumeric)
	self._textFieldPhoneVerifyCode:setPlaceHolder("请输入手机验证码")
	self._textFieldPhoneVerifyCode:setPlaceholderFontColor(display.COLOR_WHITE)
    self._textFieldPhoneVerifyCode:setFont(global.font_name, 26)

	self._textFieldWechatVerifyCode = ui.newEditBox({image = "ui/none.png", 
													 size = CCSize(300, 33),
													 x = 46, y = -35,
													 listener = handler(self, self.onEditBoxEvent)} )
	self._textFieldWechatVerifyCode:setPlaceHolder("请输入微信验证码")
	self._textFieldWechatVerifyCode:setPlaceholderFontColor(display.COLOR_WHITE)
    self._textFieldWechatVerifyCode:setFont(global.font_name, 26)

	self._ccbOwner.node_verifyPhoneEditRoot:addChild(self._textFieldPhoneNumber)
	self._ccbOwner.node_verifyPhoneEditRoot:addChild(self._textFieldPhoneVerifyCode)
	self._ccbOwner.node_verifyWechatEditRoot:addChild(self._textFieldWechatVerifyCode)

	local isDisplayMobileVerify = (remote.user.mobileAuth ~= true or remote.user.mobileAward ~= true)
	local isDisplayWechatVerify = ((remote.user.wechatAward ~= true) and ENABLE_WECHAT_VERIFY)
	self._isSelectVerifyPhone = true
	if isDisplayMobileVerify ~= true and isDisplayWechatVerify ~= true then
		self._ccbOwner.node_verifyRoot:setVisible(false)
	elseif isDisplayMobileVerify ~= true and isDisplayWechatVerify == true then
		self._ccbOwner.tab_verifyPhone:setVisible(false)
		self._ccbOwner.node_verifyPhone:setVisible(false)
		self._ccbOwner.tab_verifyWechat:setPosition(self._ccbOwner.tab_verifyPhone:getPosition())
		self._ccbOwner.node_verifyWechat:setVisible(true)
		self._ccbOwner.tabbtn_verifyWechat:setHighlighted(true)
		self._textFieldPhoneNumber:setVisible(false)
		self._textFieldPhoneVerifyCode:setVisible(false)
		for _, itemNode in ipairs(self._mobileItemNodes) do
			itemNode:setVisible(false)
		end
		self._isSelectVerifyPhone = false
	else
		self._ccbOwner.tabbtn_verifyPhone:setHighlighted(true)
		self._textFieldWechatVerifyCode:setVisible(false)
		for _, itemNode in ipairs(self._wechatItemNodes) do
			itemNode:setVisible(false)
		end
		if remote.user.mobileAuth ~= true then
			self._ccbOwner.node_getRewardStatus:setVisible(false)
		elseif remote.user.mobileAward ~= true then
			self._ccbOwner.node_phoneVerifyStatus:setVisible(false)
			self._textFieldPhoneNumber:setVisible(false)
			self._textFieldPhoneVerifyCode:setVisible(false)
		end
	end
end

function QUIDialogVerify:_createRewardItemNode(luckyDrawElement)
	if luckyDrawElement == nil then
		return {}
	end

	local itemNodes = {}
	if luckyDrawElement.type_1 ~= nil or luckyDrawElement.id_1 ~= nil then
		local itemNode = QUIWidgetItemsBox.new()
		itemNode:setGoodsInfo(luckyDrawElement.id_1, luckyDrawElement.type_1, luckyDrawElement.num_1)
		self._ccbOwner.node_item1:addChild(itemNode)
   		itemNode:setPromptIsOpen(true)
		table.insert(itemNodes, itemNode)
	end

	if luckyDrawElement.type_2 ~= nil or luckyDrawElement.id_2 ~= nil then
		local itemNode = QUIWidgetItemsBox.new()
		itemNode:setGoodsInfo(luckyDrawElement.id_2, luckyDrawElement.type_2, luckyDrawElement.num_2)
		self._ccbOwner.node_item2:addChild(itemNode)
   		itemNode:setPromptIsOpen(true)
		table.insert(itemNodes, itemNode)
	end

	if luckyDrawElement.type_3 ~= nil or luckyDrawElement.id_3 ~= nil then
		local itemNode = QUIWidgetItemsBox.new()
		itemNode:setGoodsInfo(luckyDrawElement.id_3, luckyDrawElement.type_3, luckyDrawElement.num_3)
		self._ccbOwner.node_item3:addChild(itemNode)
   		itemNode:setPromptIsOpen(true)
		table.insert(itemNodes, itemNode)
	end

	local itemCount = #itemNodes
	if itemCount == 1 then
		itemNodes[1]:getParent():setPosition(self._ccbOwner.node_item2:getPosition())
	elseif itemCount == 2 then
		itemNodes[1]:getParent():setPosition(self._ccbOwner.node_item2_1:getPosition())
		itemNodes[2]:getParent():setPosition(self._ccbOwner.node_item2_2:getPosition())
	end

	return itemNodes;
end

function QUIDialogVerify:viewDidAppear()
    QUIDialogVerify.super.viewDidAppear(self)

	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIDialogVerify:viewWillDisappear()
    QUIDialogVerify.super.viewWillDisappear(self)
    
 	self.prompt:removeItemEventListener()

    if self._phoneVerifyCodeRequest then
    	self._phoneVerifyCodeRequest:cancel()
    	self._phoneVerifyCodeRequest:release()
    	self._phoneVerifyCodeRequest = nil
    end

    if self._phoneVerifyCodeScheduler then
    	scheduler.unscheduleGlobal(self._phoneVerifyCodeScheduler)
		self._phoneVerifyCodeScheduler = nil
    end
end

function QUIDialogVerify:_onDisplayVerifyPhone()
	if self._isSelectVerifyPhone then
		self._ccbOwner.tabbtn_verifyPhone:setSelected(false)
		self._ccbOwner.tabbtn_verifyPhone:setHighlighted(true)
		return
	end

	self._ccbOwner.tabbtn_verifyPhone:setSelected(false)
	self._ccbOwner.tabbtn_verifyPhone:setHighlighted(true)
	self._ccbOwner.node_verifyPhone:setVisible(true)

	self._ccbOwner.tabbtn_verifyWechat:setSelected(true)
	self._ccbOwner.tabbtn_verifyWechat:setHighlighted(false)
	self._ccbOwner.node_verifyWechat:setVisible(false)

	self._textFieldPhoneNumber:setVisible(true)
	self._textFieldPhoneVerifyCode:setVisible(true)
	self._textFieldWechatVerifyCode:setVisible(false)

	if remote.user.mobileAuth == true and remote.user.mobileAward ~= true then
		self._textFieldPhoneNumber:setVisible(false)
		self._textFieldPhoneVerifyCode:setVisible(false)
	end

	for _, itemNode in ipairs(self._mobileItemNodes) do
		itemNode:setVisible(true)
	end

	for _, itemNode in ipairs(self._wechatItemNodes) do
		itemNode:setVisible(false)
	end

	self._isSelectVerifyPhone = true
end

function QUIDialogVerify:_onDisplayVerifyWechat()
	if self._isSelectVerifyPhone ~= true then
		self._ccbOwner.tabbtn_verifyWechat:setSelected(false)
		self._ccbOwner.tabbtn_verifyWechat:setHighlighted(true)
		return
	end

	self._ccbOwner.tabbtn_verifyWechat:setSelected(false)
	self._ccbOwner.tabbtn_verifyWechat:setHighlighted(true)
	self._ccbOwner.node_verifyWechat:setVisible(true)

	self._ccbOwner.tabbtn_verifyPhone:setSelected(true)
	self._ccbOwner.tabbtn_verifyPhone:setHighlighted(false)
	self._ccbOwner.node_verifyPhone:setVisible(false)

	self._textFieldPhoneNumber:setVisible(false)
	self._textFieldPhoneVerifyCode:setVisible(false)
	self._textFieldWechatVerifyCode:setVisible(true)

	for _, itemNode in ipairs(self._mobileItemNodes) do
		itemNode:setVisible(false)
	end

	for _, itemNode in ipairs(self._wechatItemNodes) do
		itemNode:setVisible(true)
	end

	self._isSelectVerifyPhone = false
end

function QUIDialogVerify:onEditBoxEvent()
	-- body
end

function QUIDialogVerify:_onGetPhoneVerifyCode()
	local phoneNumber = self._textFieldPhoneNumber:getText()
	if phoneNumber == nil or string.len(phoneNumber) < 11 then
		app.tip:floatTip("请输入11位手机号码")
		return
	end

	local request = "app_id=RQn5mzvUHa&mobile=" .. phoneNumber .. "&time=" .. tostring(math.floor(q.time())) .. "&type=2"
	local verifyValue = crypto.md5(request .. "ZiX2dzZ6W1eIZWxQAg")
	request = request .. "&verify=" .. verifyValue
	printInfo("get phone binding verify code request:" .. request)
	local url = "http://sms.uuzuonline.com/api/sms/sendCode?" .. request
	if self._phoneVerifyCodeRequest then
		self._phoneVerifyCodeRequest:release()
		self._phoneVerifyCodeRequest = nil
	end
	self._phoneVerifyCodeRequest = network.createHTTPRequest(handler(self, QUIDialogVerify._onPhoneVerifyCodeRequestFinished), url)
	self._phoneVerifyCodeRequest:setTimeout(59)
	self._phoneVerifyCodeRequest:retain()
	self._phoneVerifyCodeRequest:start()

	self._ccbOwner.btn_getVerifyCode:setEnabled(false)
	self._timeLeft = 60
	self._ccbOwner.label_getVerifyCodeText:setString("剩余 " .. self._timeLeft .. " 秒")
	self._ccbOwner.label_getVerifyCodeTip:setVisible(true)
	self._phoneVerifyCodeScheduler = scheduler.scheduleGlobal(function()
		self._timeLeft = self._timeLeft - 1
		if self._timeLeft <= 0 then
			self._ccbOwner.btn_getVerifyCode:setEnabled(true)
			self._ccbOwner.label_getVerifyCodeText:setString("获取验证码")
			self._ccbOwner.label_getVerifyCodeTip:setVisible(false)
			scheduler.unscheduleGlobal(self._phoneVerifyCodeScheduler)
			self._phoneVerifyCodeScheduler = nil
		else
			self._ccbOwner.label_getVerifyCodeText:setString("剩余 " .. self._timeLeft .. " 秒")
		end
	end, 1.0)
end

function QUIDialogVerify:_onTriggerPhoneVerify()
	local phoneNumber = self._textFieldPhoneNumber:getText()
	local phoneVerifyCode = self._textFieldPhoneVerifyCode:getText()

	if phoneNumber == nil or string.len(phoneNumber) ~= 11 then
		app.tip:floatTip("请输入11位手机号码")
		return
	end

	if phoneVerifyCode == nil or string.len(phoneVerifyCode) ~= 6 then
		app.tip:floatTip("请输入6位验证码")
		return
	end

	if self._phoneVerifySessionId == nil then
		app.tip:floatTip("验证码过期，请重新获取")
		return
	end

	app:getClient():bindPhoneNumber(phoneNumber, phoneVerifyCode, self._phoneVerifySessionId, 
		function(data)
			-- success
			if data.mobileAuthStatus == 0 then
				printInfo("phone number bind success!")
				self._ccbOwner.node_getRewardStatus:setVisible(true)
				self._ccbOwner.node_phoneVerifyStatus:setVisible(false)
				self._textFieldPhoneNumber:setVisible(false)
				self._textFieldPhoneVerifyCode:setVisible(false)
			else
				printInfo("phone number bind faild, error code:" .. tostring(data.mobileAuthStatus));
				local faildDes = "手机号码绑定失败"
				if data.mobileAuthStatus == 1 then
					faildDes = "校验码错误"
				elseif data.mobileAuthStatus == 2 then
					faildDes = "无效的应用程序"
				elseif data.mobileAuthStatus == 3 then
					faildDes = "应用程序已经停止使用该功能"
				elseif data.mobileAuthStatus == 4 then
					faildDes = "无效时间戳"
				elseif data.mobileAuthStatus == 5 then
					faildDes = "缺少账号"
				elseif data.mobileAuthStatus == 6 then
					faildDes = "缺少密码"
				elseif data.mobileAuthStatus == 7 then
					faildDes = "密码不符合规则"
				elseif data.mobileAuthStatus == 8 then
					faildDes = "两次密码不一致"
				elseif data.mobileAuthStatus == 9 then
					faildDes = "账号已经被注册"
				elseif data.mobileAuthStatus == 10 then
					faildDes = "名字错误"
				elseif data.mobileAuthStatus == 11 then
					faildDes = "邮箱错误"
				elseif data.mobileAuthStatus == 12 then
					faildDes = "手机号码错误"
				elseif data.mobileAuthStatus == 13 then
					faildDes = "缺少必要参数"
				elseif data.mobileAuthStatus == 14 then
					faildDes = "不存在的账号"
				elseif data.mobileAuthStatus == 15 then
					faildDes = "用户已经绑定手机"
				elseif data.mobileAuthStatus == 16 then
					faildDes = "无效的手机验证码"
				elseif data.mobileAuthStatus == 17 then
					faildDes = "手机号码已经被其他账号绑定"
				elseif data.mobileAuthStatus == 99 then
					faildDes = "非法错误"
				end
				app:alert({content=faildDes,title="系统提示"}, false, true)
			end
		end, 
		function(...)
			-- failed
		end)
end

function QUIDialogVerify:_onTriggerGetPhoneVerifyReward()
	if remote.user.mobileAuth ~= true then
		app.tip:floatTip("未绑定手机号码")
		return
	end

	app:getClient():getPhoneBindRewards(function (data)
			-- success
			remote.user.mobileAward = true
			self._ccbOwner.btn_getPhoneBindReward:setEnabled(false)
		end,
		function ( ... )
			app.tip:floatTip("领取奖励失败")
		end)
end

function QUIDialogVerify:_onTriggerWechatVerify()
	local wechatVerifyCode = self._textFieldWechatVerifyCode:getText()
	if wechatVerifyCode == nil or string.len(wechatVerifyCode) == 0 then
		app.tip:floatTip("请输入微信验证码")
		return
	end

	app:getClient():getWechatRewards(wechatVerifyCode, 
		function (data)
			-- success
			if remote.user.wechatAward ~= true then
				app.tip:floatTip("领取奖励失败")
			else
				app.tip:floatTip("已成功领取奖励，请查收邮件")
				self._ccbOwner.btn_getWechatReward:setEnabled(false)
			end
		end, 
		function ( ... )
			-- faild
		end)
end

function QUIDialogVerify:_onPhoneVerifyCodeRequestFinished(event)
	local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
    	local errorMsg = "发送手机验证码失败:" .. tostring(request:getErrorMessage()) .. ", 错误码" .. tostring(request:getErrorCode())
    	app.tip:floatTip(errorMsg)
    else
    	local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        app.tip:floatTip("发送手机验证码无响应")
	        return
	    else
	    	-- 请求成功，显示服务端返回的内容
		    local response = request:getResponseString()
		    printInfo("request success, get response:" .. tostring(response))
		    if response then
			    local response_lua = json.decode(response)
			    printTable(response_lua)
			    if response_lua.status ~= 0 then
			    	app.tip:floatTip("发送手机验证码失败，请重新发送")
			    	self._ccbOwner.btn_getVerifyCode:setEnabled(true)
					self._ccbOwner.label_getVerifyCodeText:setString("获取验证码")
					self._ccbOwner.label_getVerifyCodeTip:setVisible(false)
					if self._phoneVerifyCodeScheduler then
						scheduler.unscheduleGlobal(self._phoneVerifyCodeScheduler)
						self._phoneVerifyCodeScheduler = nil
					end
			    elseif response_lua.data and response_lua.data.session_id then
			    	self._phoneVerifySessionId = response_lua.data.session_id
			    	printInfo("session id:" .. self._phoneVerifySessionId)
			    end
			end
	    end
    end
 
    self._phoneVerifyCodeRequest:release()
    self._phoneVerifyCodeRequest = nil

end

function QUIDialogVerify:_onTriggerClose()
	app.sound:playSound("common_close")
	
	self:playEffectOut()
end

function QUIDialogVerify:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogVerify