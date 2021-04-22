-- @Author: xurui
-- @Date:   2019-05-15 19:15:05
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 11:29:06
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterBuyExp = class("QUIDialogSoulLetterBuyExp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSoulLetterBuyExpClient = import("..widgets.QUIWidgetSoulLetterBuyExpClient")

function QUIDialogSoulLetterBuyExp:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_Levelup.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogSoulLetterBuyExp.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("手札直升")
	
    if options then
    	self._callBack = options.callBack
    end

 	self._activityProxy = remote.activityRounds:getSoulLetter()
 	self._client = {}
end

function QUIDialogSoulLetterBuyExp:viewDidAppear()
	QUIDialogSoulLetterBuyExp.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogSoulLetterBuyExp:viewWillDisappear()
  	QUIDialogSoulLetterBuyExp.super.viewWillDisappear(self)
end

function QUIDialogSoulLetterBuyExp:setInfo()
	local configs = self._activityProxy:getBuyExpConfigByType(1)

	for i = 1, 4 do
		if configs[i] then
			if self._client[i] == nil then
				self._client[i] = QUIWidgetSoulLetterBuyExpClient.new()
				self._ccbOwner["node_"..i]:addChild(self._client[i])
				self._client[i]:addEventListener(QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_BUY, handler(self, self._clickBuy))
			end
			self._client[i]:setInfo(configs[i], self._activityProxy)
		end
	end
end

function QUIDialogSoulLetterBuyExp:_clickBuy(event)
	if event == nil then return end
	app.sound:playSound("common_small")

	local info = event.info
	if q.isEmpty(info) == false then
		local addLevel = math.floor(info.exp / 1200)

		local buyFunc = function()
			self._activityProxy:requestEliteActive(info.id, function()
				self._addLevel = addLevel
				self._addExp = info.exp
				if self:safeCheck() then
					self:playEffectOut()
				end
			end)
		end

			
		local activityInfo = self._activityProxy:getActivityInfo()
		if activityInfo.level + addLevel > 100 then
			app:alert({content = "购买后手札等级将超出上限，是否确认购买？", title = "系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					if buyFunc then
						buyFunc()
					end
				end
			end}, true, true)
			return 
		end

		buyFunc()
	end
end

function QUIDialogSoulLetterBuyExp:_onTriggerHelp(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterHelp",
		options = {helpType = "help_battle_pass2"}})
end

function QUIDialogSoulLetterBuyExp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulLetterBuyExp:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterBuyExp:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._addLevel, self._addExp)
	end
end

return QUIDialogSoulLetterBuyExp
