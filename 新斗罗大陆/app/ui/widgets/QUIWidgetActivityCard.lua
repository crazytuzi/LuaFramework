local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityCard = class("QUIWidgetActivityCard", QUIWidget)

local QPayUtil = import("...utils.QPayUtil")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

-- 月卡放在精彩任务里，但还是走每日任务逻辑,领取的次数是以每日任务次数
function QUIWidgetActivityCard:ctor( ... )
	local ccbFile = "ccb/Widget_Activity_yueka.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
  		{ccbCallbackName = "onTriggerPrime", callback = handler(self, self._onTriggerPrime)}, 
  		{ccbCallbackName = "onTriggerDrawNormal", callback = handler(self, self._onTriggerDrawNormal)},
  		{ccbCallbackName = "onTriggerDrawPrime", callback = handler(self, self._onTriggerDrawPrime)},
  		{ccbCallbackName = "onTriggerCardInfo1", callback = handler(self, self._onTriggerCardInfo1)},
		{ccbCallbackName = "onTriggerCardInfo2", callback = handler(self, self._onTriggerCardInfo2)},
		{ccbCallbackName = "onTriggerRecharge", callback = handler(self, self._onTriggerRecharge)},
  		{ccbCallbackName = "onTriggertMakeUp", callback = handler(self, self._onTriggertMakeUp)},
  	}
	QUIWidgetActivityCard.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_makeUpBox)

	self:update()
end

function QUIWidgetActivityCard:onEnter()
	QUIWidgetActivityCard.super.onEnter()

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

function QUIWidgetActivityCard:onExit()
	self._exit = true
	if self._userEventProxy ~= nil then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end
	if self._rechargeProgress then
    	scheduler.unscheduleGlobal(self._rechargeProgress)
    	self._rechargeProgress = nil
    end
end

function QUIWidgetActivityCard:timeRefreshHandler(e)
	if e.time == nil or e.time == 5 then
		self:update()
	end
end

function QUIWidgetActivityCard:update()
	local recharge = db:getRecharge()
    self._monthlyRecharge = {}
    for k, v in pairs(recharge) do
        if v.type == 2 then
            table.insert(self._monthlyRecharge, v)
        end
    end
    table.sort( self._monthlyRecharge, function (x, y)
        return x.RMB < y.RMB
	end )
	
	local multipleNum = remote.task:getCardMultiple()
	local maxDays = QStaticDatabase:sharedDatabase():getConfigurationValue("month_card_date")
    local index = 1
    local activeState = 0
    for k, v in ipairs(self._monthlyRecharge) do
		local remainingDays = (remote.recharge["monthCard" .. index .. "EndTime"]/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(DAY)
		if remainingDays > 0 and remainingDays <= maxDays then
			activeState = activeState + 1
		end
		self._ccbOwner["button" .. index]:setVisible(remainingDays <= 0)
		self._ccbOwner["button_lab" .. index]:setVisible(remainingDays <= 0)
		self._ccbOwner["drawButton" .. index]:setVisible(remainingDays > 0 and remote.task:checkTaskisDone(tostring(200000 + index)))
		self._ccbOwner["drawButton_lab" .. index]:setVisible(remainingDays > 0 and remote.task:checkTaskisDone(tostring(200000 + index)))
		self._ccbOwner["drawn" .. index]:setVisible(remainingDays > 0 and remote.task:checkTaskisComplete(tostring(200000 + index)))
		self._ccbOwner["sp_shengyu" .. index]:setVisible(remainingDays > 0)
		self._ccbOwner["node_day_token_double" .. index]:setVisible(multipleNum > 1)
		
		remainingDays = remainingDays - 1 
		if remainingDays < 0 then
			remainingDays = 30
		end
		self._ccbOwner["remaining" .. index]:setString(string.format("%d", remainingDays))
		self:showExpireTip(remainingDays, index)
		index = index + 1 
    end

    local titleId = 800
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(titleId)
	self._ccbOwner.node_chenghao:removeAllChildren()
	self._ccbOwner.node_chenghao:addChild(titleBox)

	self._ccbOwner.btn_recharge:setVisible(false)
	if activeState == 2 then
		self._ccbOwner.btn_recharge:setVisible(true)
	end

	local makeUpInfo = remote.user.monthCardSupplementResponse
	self._ccbOwner.node_makeUp:setVisible(false)
	if not q.isEmpty(makeUpInfo) then
		local maxMakeUpNum = makeUpInfo.monthCard1 or 0
		if makeUpInfo.monthCard2 and maxMakeUpNum < makeUpInfo.monthCard2 then
			maxMakeUpNum = makeUpInfo.monthCard2
		end
		self._ccbOwner.tf_makeUp_tps:setString(maxMakeUpNum .. "日")
		self._ccbOwner.node_makeUp:setVisible(maxMakeUpNum > 0)
	end
end

function QUIWidgetActivityCard:showExpireTip(remainingDay, index)
	local tipDay = QStaticDatabase:sharedDatabase():getConfigurationValue("month_card_expire")
	self._ccbOwner["node_expire_tip_"..index]:setVisible(false)

	if remainingDay >= 0 and remainingDay < tipDay then
		self._ccbOwner["node_expire_tip_"..index]:setVisible(true)
	end
end

function QUIWidgetActivityCard:refresh( ... )
	self:update()
end

function QUIWidgetActivityCard:setInfo( ... )
	self:refresh()
end

function QUIWidgetActivityCard:_onTriggerNormal(event)
	if q.buttonEventShadow(event, self._ccbOwner.button1) == false then return end
	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(self._monthlyRecharge[1].RMB, self._monthlyRecharge[1].type)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 10)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(self._monthlyRecharge[1].RMB, self._monthlyRecharge[1].type,"yueka30tian")
		else
			QPayUtil:pay(self._monthlyRecharge[1].RMB, self._monthlyRecharge[1].type,"yueka30tian")
		end
	end
end

function QUIWidgetActivityCard:_onTriggerPrime(event)
	if q.buttonEventShadow(event, self._ccbOwner.button2) == false then return end
	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(self._monthlyRecharge[2].RMB, self._monthlyRecharge[2].type)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 10)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(self._monthlyRecharge[2].RMB, self._monthlyRecharge[2].type,"zhizunyueka30tian")
		else
			QPayUtil:pay(self._monthlyRecharge[2].RMB, self._monthlyRecharge[2].type,"zhizunyueka30tian")
		end
	end
end

function QUIWidgetActivityCard:_onTriggerDrawNormal(event)
	if q.buttonEventShadow(event, self._ccbOwner.drawButton1) == false then return end
	app.sound:playSound("common_confirm")
	remote.task:drawCard("200001")
end

function QUIWidgetActivityCard:_onTriggerDrawPrime(event)
	if q.buttonEventShadow(event, self._ccbOwner.drawButton2) == false then return end
	app.sound:playSound("common_confirm")
	remote.task:drawCard("200002")
end

function QUIWidgetActivityCard:_onTriggerCardInfo1(event)
	if q.buttonEventShadow(event, self._ccbOwner.btnMessage1) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIWidgetActivityCard:_onTriggerCardInfo2(event)
	if q.buttonEventShadow(event, self._ccbOwner.btnMessage2) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIWidgetActivityCard:_onTriggerRecharge(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recharge) == false then return end

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
end

-- 领取补领奖励
function QUIWidgetActivityCard:_onTriggertMakeUp(event)
	app.sound:playSound("common_small")
	
	local oldToken = remote.user.token
	remote.activity:obtainMonthCardSupplementRequest(function(data)
		local makeUpInfo = remote.user.monthCardSupplementResponse
		if not q.isEmpty(makeUpInfo) then
			remote.user:update(data.wallet)
			self._ccbOwner.node_makeUp:setVisible(false)
			local newToken = remote.user.token
			if newToken > oldToken then
				local awards = {}
				table.insert(awards, {id = "item", typeName = ITEM_TYPE.TOKEN_MONEY, count = newToken - oldToken})
				local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				options = {awards = awards}},{isPopCurrentDialog = false} )
				local title = ""
				if makeUpInfo.monthCard1 and makeUpInfo.monthCard1 > 0 and makeUpInfo.monthCard2 and makeUpInfo.monthCard2 > 0 then
					title = string.format("奖励补领成功，获得%d日的普通月卡奖励和%d日的至尊月卡奖励", makeUpInfo.monthCard1, makeUpInfo.monthCard2)
				elseif makeUpInfo.monthCard1 and makeUpInfo.monthCard1 > 0 then
					title = string.format("奖励补领成功，获得%d日的普通月卡奖励", makeUpInfo.monthCard1)
				elseif makeUpInfo.monthCard2 and makeUpInfo.monthCard2 > 0 then
					title = string.format("奖励补领成功，获得%d日的至尊月卡奖励", makeUpInfo.monthCard2)
				end
				dialog:setTitleOffsetY(-20)
				dialog:setTitle(title)
	
				remote.user:update({monthCardSupplementResponse = {}})
			end
		end
	end)
end


return QUIWidgetActivityCard