-- @Author: xurui
-- @Date:   2019-06-04 15:14:29
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-06-12 11:16:38
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBindingPhoneYW = class("QUIDialogBindingPhoneYW", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QRichText = import("...utils.QRichText")

function QUIDialogBindingPhoneYW:ctor(options)
	local ccbFile = "ccb/Dialog_phone_bangding.ccbi"
	if device.platform == "ios" then 
		ccbFile = "ccb/Dialog_phone_bangding_ios.ccbi"
	end
    local callBacks = {
		{ccbCallbackName = "onTriggerCheck", callback = handler(self, self._onTriggerCheck)},
		{ccbCallbackName = "onTriggerGetCode", callback = handler(self, self._onTriggerGetCode)},
    }
    QUIDialogBindingPhoneYW.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    if self._ccbOwner.node_welcome then
		self._avatar = QSkeletonActor:create("jm_xiaowu")
    	self._avatar:playAnimation("animation", true)
    	self._avatar:setScale(0.6)
		self._ccbOwner.node_welcome:addChild(self._avatar)
	end


    self._codeEditBox = ui.newEditBox({image = "ui/none.png", listener = function () end, size = CCSize(180, 34)})
    self._codeEditBox:setFont(global.font_default, 26)
    self._codeEditBox:setMaxLength(20)
    self._codeEditBox:setFontColor(COLORS.j)
    self._ccbOwner.node_input_code:addChild(self._codeEditBox)

	self._numberEditBox = ui.newEditBox({image = "ui/none.png", listener = function () end, size = CCSize(307, 34)})
	self._numberEditBox:setFont(global.font_default, 26)
	self._numberEditBox:setMaxLength(20)
	self._numberEditBox:setFontColor(COLORS.j)
	self._ccbOwner.node_input_number:addChild(self._numberEditBox)
    self._numberEditBox:registerScriptEditBoxHandler(function(returnType)
    		local text = self._numberEditBox:getText()
    		self._numberEditBox:setText(string.sub(text or "", 1, 11))
	end)
end

function QUIDialogBindingPhoneYW:viewDidAppear()
	QUIDialogBindingPhoneYW.super.viewDidAppear(self)
	self:setContent()
	-- self:setInfo()
end

function QUIDialogBindingPhoneYW:viewWillDisappear()
  	QUIDialogBindingPhoneYW.super.viewWillDisappear(self)

  	if self._countdownScheduler then
  		scheduler.unscheduleGlobal(self._countdownScheduler)
  		self._countdownScheduler = nil
  	end
end

function QUIDialogBindingPhoneYW:setContent()
	self._ccbOwner.content:removeAllChildren()
	local channelid = FinalSDK.getChannelID()
	local describe = QUIWidgetHelpDescribe.new()

	local describeinfo = {}
	describeinfo.widthLimit = 430

	if device.platform == "ios" then
		describeinfo.defaultSize = 43
	else
		describeinfo.defaultSize = 17
	end

	describeinfo.offsetX = 0
	describeinfo.lineSpacing = 2
	describe:setInfo(describeinfo,QStaticDatabase:sharedDatabase():getChannelCloseDisc(channelid))
	self._ccbOwner.content:addChild(describe)
end

function QUIDialogBindingPhoneYW:_onTriggerCheck()
  	app.sound:playSound("common_small")

	local phoneNumber = self._numberEditBox:getText()
	local code = self._codeEditBox:getText()
	if phoneNumber == nil or phoneNumber == "" then
		app.tip:floatTip("请输入手机号")
		return
	end
	if code == nil or code == "" then
		app.tip:floatTip("请输入验证码")
		return
	end
	local openId = FinalSDK.getSessionId()
	local channel = FinalSDK.getChannelID()
	local response = remote.bindingPhone:bindingYwOpenid(openId, channel, phoneNumber, code)
	printTable(response)
	if response and response.code then
		app.tip:floatTip(response.msg)
		if response.code == 0 then
			self:playEffectOut()
		end
	end
end

function QUIDialogBindingPhoneYW:_onTriggerGetCode()
  	app.sound:playSound("common_small")

	local phoneNumber = self._numberEditBox:getText()
	if phoneNumber == nil or phoneNumber == "" then
		app.tip:floatTip("请输入手机号")
		return
	end
	local openId = FinalSDK.getSessionId()
	local channel = FinalSDK.getChannelID()
	local codeTbl = remote.bindingPhone:getCodeByYw(openId,channel,phoneNumber)
	if codeTbl and codeTbl.code then
		if codeTbl.code == 0 then
			remote.bindingPhone:setCountdownTime(q.serverTime())
			self:setGetCodeCountdown()
		else
			app.tip:floatTip(codeTbl.msg)
		end
	end
end

function QUIDialogBindingPhoneYW:setGetCodeCountdown()
  	if self._countdownScheduler then
  		scheduler.unscheduleGlobal(self._countdownScheduler)
  		self._countdownScheduler = nil
  	end

	local startTime = remote.bindingPhone:getCountdownTime()
	if startTime == 0 then return end

	self._ccbOwner.btn_getCode:setEnabled(false)
	makeNodeFromNormalToGray(self._ccbOwner.btn_getCode)

	local countdownFunc
	countdownFunc = function()
		local offset = startTime + MIN - q.serverTime()
		if offset > 0 then
			self._ccbOwner.tf_getCode:setString(string.format("%s秒", math.floor(offset)))
		else
			remote.bindingPhone:setCountdownTime(0)
			self._ccbOwner.tf_getCode:setString("获取验证码")
			self._ccbOwner.btn_getCode:setEnabled(true)
			makeNodeFromGrayToNormal(self._ccbOwner.btn_getCode)
		  	if self._countdownScheduler then
		  		scheduler.unscheduleGlobal(self._countdownScheduler)
		  		self._countdownScheduler = nil
		  	end
		end
	end

	self._countdownScheduler = scheduler.scheduleGlobal(countdownFunc, 1)
	countdownFunc()
end

-- function QUIDialogBindingPhoneYW:_onTriggerClose(event)
-- 	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
--   	app.sound:playSound("common_close")
-- 	self:playEffectOut()
-- end

function QUIDialogBindingPhoneYW:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogBindingPhoneYW
