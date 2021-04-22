-- @Author: xurui
-- @Date:   2019-05-16 11:20:24
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 11:12:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterActiveElite = class("QUIDialogSoulLetterActiveElite", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSoulLetterActiveEliteClient = import("..widgets.QUIWidgetSoulLetterActiveEliteClient")
local QPayUtil = import("...utils.QPayUtil")

function QUIDialogSoulLetterActiveElite:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_Activition.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogSoulLetterActiveElite.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("手札激活")

    -- if options then
    -- 	self._callBack = options.callBack
    -- end

    if options.callBack then
    	self._callBack = options.callBack
    end

       if options.expCallBack then
    	self._expCallBack = options.expCallBack
    end

	
	local flag_ = remote.flag:getLocalData(remote.flag.FLAG_FRIST_SOIL_LETTER_ACTIVE)
	self.first_buy = tonumber(flag_) ~= 1


 	self._activityProxy = remote.activityRounds:getSoulLetter()
 	self._client = {}
end

function QUIDialogSoulLetterActiveElite:viewDidAppear()
	QUIDialogSoulLetterActiveElite.super.viewDidAppear(self)
	if self._activityProxy.isOpen == false then
		self:popSelf()
		return
	end

	self:setInfo()
end

function QUIDialogSoulLetterActiveElite:viewWillDisappear()
  	QUIDialogSoulLetterActiveElite.super.viewWillDisappear(self)
end

function QUIDialogSoulLetterActiveElite:setInfo()
	local normal = self._activityProxy:getBuyExpConfigByType(2)
	local elite1 = self._activityProxy:getBuyExpConfigByType(3)
	local elite2 = self._activityProxy:getBuyExpConfigByType(4)

	local configs = {}
	if normal[1] then
		configs[#configs+1] = normal[1]
	end
	if elite1[1] then
		configs[#configs+1] = elite1[1]
	end
	if elite2[1] then
		configs[#configs+1] = elite2[1]
	end

	for i = 1, 3 do
		if configs[i] then
			if self._client[i] == nil then
				self._client[i] = QUIWidgetSoulLetterActiveEliteClient.new()
				self._ccbOwner["node_"..i]:addChild(self._client[i])
				self._client[i]:addEventListener(QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_ACTIVE, handler(self, self._clickActive))
				self._client[i]:addEventListener(QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_BUY, handler(self, self._clickBuy))
			end
			self._client[i]:setInfo(configs[i], self._activityProxy)
		end
	end

	self._ccbOwner.tf_elite_name:setString(string.format("%s和%s", configs[2].name, configs[3].name))
end


--获得魂师手札倒计时天数
function  QUIDialogSoulLetterActiveElite:getTimeDeadLineDays()
	local day = 28
	local endTime = self._activityProxy.endAt or 0
	if remote.user.openServerTime ~= nil and remote.user.openServerTime > 0 then

		local passTime = endTime - remote.user.openServerTime
		local dis_opensvr = math.floor(passTime/(DAY))
		if dis_opensvr <= 28 then
			local lastTime = endTime - q.serverTime()
			if lastTime > 0 then
				day = math.floor(lastTime/(DAY))
			end
		end
	end

	return day
end


--计算剩余可达到的最高等级 包含购买手札后的加成等级
function QUIDialogSoulLetterActiveElite:calGetMaxLevel(day,buy_type)
	local weekNum = self._activityProxy:getCurrentWeekNum()
	local weekExp = self._activityProxy:getWeekExp()--本周获得经验
	local maxExpConfig = self._activityProxy:getWeekMaxExp(weekNum)
	local can_achieve_exp = maxExpConfig.exp or 0

	if day >= 7 then
		local next_week_maxExpConfig = self._activityProxy:getWeekMaxExp(weekNum + 1)
		local next_exp = next_week_maxExpConfig.exp or 0
		can_achieve_exp = can_achieve_exp + next_exp
	end

	can_achieve_exp = can_achieve_exp - weekExp

	local activityInfo = self._activityProxy:getActivityInfo()
	local current_sum_Exp =  activityInfo.exp  or 0 
	local level = activityInfo.level or 1

	if level > 1 then
		for i= 1,level - 1 do
			local expConfig = self._activityProxy:getAwardsConfigByLevel(i)
			local maxExp = expConfig.exp or 1200
			current_sum_Exp = current_sum_Exp + maxExp
		end
	end

	local sum_all = can_achieve_exp + current_sum_Exp
	local max_level = math.floor((sum_all or 0) / 1200 ) + 1
	if buy_type == 4 then
		max_level = max_level + 20
	end

	return max_level
end

function QUIDialogSoulLetterActiveElite:_clickActive(event)
	if event == nil then return end
	app.sound:playSound("common_small")

	local info = event.info
	if q.isEmpty(info) == false then
		self._activityProxy:requestEliteActive(info.id, function()
			if self:safeCheck() then
				self:popSelf()

				self:showActiveDialog(info)
			end
		end)
	end
end


function QUIDialogSoulLetterActiveElite:_clickBuy(event)
	if event == nil then return end
	app.sound:playSound("common_small")
	local info = event.info

	local last_day = self:getTimeDeadLineDays()
	if last_day < 14 and self.first_buy then

		local max_level_= self:calGetMaxLevel(last_day,info.buy_type)
		if max_level_ < 60 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIWidgetSoulLetterActiveEliteTips",
			options = {info = info , title ="系统提示", day =last_day,max_level = max_level_ ,activityProxy = self._activityProxy,buyCallback = function ( info ) self:buyByInfo(info) end ,expCallback = function()
				self:popSelf()	
				if self._expCallBack then self._expCallBack() end
			end}})
			return
		end
	end

	self:buyByInfo(info)
end

function QUIDialogSoulLetterActiveElite:buyByInfo(info)
	if info == nil then return end

	if self.first_buy then
		remote.flag:set(remote.flag.FLAG_FRIST_SOIL_LETTER_ACTIVE, 1)
		self.first_buy = false
	end

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(info.price, 3)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(info.price, 3, nil)
		else
			QPayUtil:pay(info.price, 3, nil)
		end
	end
	self:popSelf()	
end


function QUIDialogSoulLetterActiveElite:showActiveDialog(info)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterActiveSuccess", 
		options = {info = info}}, {isPopCurrentDialog = false})
end

function QUIDialogSoulLetterActiveElite:_onTriggerHelp(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterHelp",
		options = {helpType = "help_battle_pass1"}})
end

function QUIDialogSoulLetterActiveElite:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulLetterActiveElite:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterActiveElite:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulLetterActiveElite
