-- @Author: xurui
-- @Date:   2019-06-04 15:14:29
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-06-12 11:16:38
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBindingPhone = class("QUIDialogBindingPhone", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogBindingPhone:ctor(options)
	local ccbFile = "ccb/Dialog_BindingPhone.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerCheck", callback = handler(self, self._onTriggerCheck)},
		{ccbCallbackName = "onTriggerGetCode", callback = handler(self, self._onTriggerGetCode)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogBindingPhone.super.ctor(self, ccbFile, callBacks, options)
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


    self._codeEditBox = ui.newEditBox({image = "ui/none.png", listener = function () end, size = CCSize(180, 40)})
    self._codeEditBox:setFont(global.font_default, 26)
    self._codeEditBox:setMaxLength(20)
    self._codeEditBox:setFontColor(COLORS.j)
    self._ccbOwner.node_input_code:addChild(self._codeEditBox)

	self._numberEditBox = ui.newEditBox({image = "ui/none.png", listener = function () end, size = CCSize(307, 40)})
	self._numberEditBox:setFont(global.font_default, 26)
	self._numberEditBox:setMaxLength(20)
	self._numberEditBox:setFontColor(COLORS.j)
	self._ccbOwner.node_input_number:addChild(self._numberEditBox)
    self._numberEditBox:registerScriptEditBoxHandler(function(returnType)
    		local text = self._numberEditBox:getText()
    		self._numberEditBox:setText(string.sub(text or "", 1, 11))
	end)
end

function QUIDialogBindingPhone:viewDidAppear()
	QUIDialogBindingPhone.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogBindingPhone:viewWillDisappear()
  	QUIDialogBindingPhone.super.viewWillDisappear(self)

  	if self._countdownScheduler then
  		scheduler.unscheduleGlobal(self._countdownScheduler)
  		self._countdownScheduler = nil
  	end
end

function QUIDialogBindingPhone:setInfo()
	local award = remote.bindingPhone:getBindingPhoneAwards()
	if self._itemBox == nil and q.isEmpty(award) == false then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:addChild(self._itemBox)
		self._itemBox:setGoodsInfo(nil, award.typeName, award.count)
	end

	local isAwards = remote.bindingPhone:checkCanGetAwards()
	self._ccbOwner.sp_get:setVisible(false)
	if isAwards then
		self:setChangeNumberEditBox()
	else
		self._ccbOwner.sp_get:setVisible(true)
		self:setPhoneNumber()
	end
end

function QUIDialogBindingPhone:setChangeNumberEditBox()
	self._ccbOwner.node_change:setVisible(true)
	self._ccbOwner.node_info:setVisible(false)
	-- self._ccbOwner.node_item:setPositionY(50)

	if self._numberEditBox then
		self._numberEditBox:setText("")
		self._numberEditBox:setVisible(true)
	end
	if self._codeEditBox then
		self._codeEditBox:setText("")
		self._codeEditBox:setVisible(true)
	end

	self:setGetCodeCountdown()
end

function QUIDialogBindingPhone:setPhoneNumber()
	self._ccbOwner.node_change:setVisible(false)
	self._ccbOwner.node_info:setVisible(true)
	self._ccbOwner.node_item:setPositionY(20)

	local phoneInfo = remote.user.userTelephoneInfo or {}

	local backNum = string.sub(phoneInfo.phoneNum or "", 8, 11)
	self._ccbOwner.tf_phone:setString("*******"..backNum)

	if self._numberEditBox then
		self._numberEditBox:setVisible(false)
	end
	if self._codeEditBox then
		self._codeEditBox:setVisible(false)
	end
end

function QUIDialogBindingPhone:_onTriggerChange()
  	app.sound:playSound("common_small")

  	self:setChangeNumberEditBox()
end

function QUIDialogBindingPhone:_onTriggerCheck()
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
	
	local isAwards = remote.bindingPhone:checkCanGetAwards()
	remote.bindingPhone:checkPhoneVerifyCode(phoneNumber, code, function()
		if self:safeCheck() then
			self:setInfo()

			if isAwards then
				self:showAwardsDialog()
			end
		end
	end)
end

function QUIDialogBindingPhone:showAwardsDialog()
	local award = remote.bindingPhone:getBindingPhoneAwards()

	if q.isEmpty(award) == false then
	    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
	    	options = {awards = {award}}}, {isPopCurrentDialog = false})
	    dialog:setTitle("恭喜获得绑定奖励")
	end
end

function QUIDialogBindingPhone:_onTriggerGetCode()
  	app.sound:playSound("common_small")

	local phoneNumber = self._numberEditBox:getText()
	if phoneNumber == nil or phoneNumber == "" then
		app.tip:floatTip("请输入手机号")
		return
	end

	remote.bindingPhone:getPhoneVerifyCode(phoneNumber, function()
		if self:safeCheck() then
			remote.bindingPhone:setCountdownTime(q.serverTime())
			self:setGetCodeCountdown()
		end
	end)
end

function QUIDialogBindingPhone:setGetCodeCountdown()
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

function QUIDialogBindingPhone:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogBindingPhone:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogBindingPhone
