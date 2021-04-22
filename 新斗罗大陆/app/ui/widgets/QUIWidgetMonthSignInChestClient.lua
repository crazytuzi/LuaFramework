-- 
-- zxs
-- 月度签到累计奖励
-- 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonthSignInChestClient = class("QUIWidgetMonthSignInChestClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetMonthSignInChestClient:ctor(options)
	local ccbFile = "ccb/Widget_DailySignln_award_baoxiang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBox1", callback = handler(self, self._onTriggerChest1)},
		{ccbCallbackName = "onTriggerBox2", callback = handler(self, self._onTriggerChest2)},
		{ccbCallbackName = "onTriggerBox3", callback = handler(self, self._onTriggerChest3)},
		{ccbCallbackName = "onTriggerBox4", callback = handler(self, self._onTriggerChest4)},
		{ccbCallbackName = "onTriggerBox5", callback = handler(self, self._onTriggerChest5)},
    }
    QUIWidgetMonthSignInChestClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMonthSignInChestClient:setInfo()
	self._totalDay = remote.monthSignIn:getCurrentMonthTotalDay()

	local serverData = remote.monthSignIn:getSignInServerInfo()
	local signInDay = serverData.index or 0
	self._ccbOwner.tf_sign_num:setString(signInDay.."/"..self._totalDay.."次")

	local needSignInDay = remote.monthSignIn:getCanPatchSignInNum()
	self._ccbOwner.tf_absence_num:setString(needSignInDay.."次")

	local chestAwardsInfo = remote.monthSignIn:getSignInChestAwardList()
	for i = 1, 5 do
		local stated = chestAwardsInfo[i].stated or 0
		self._ccbOwner["node_light"..i]:setVisible(stated == 1)
		self._ccbOwner["node_close"..i]:setVisible(stated == 0 or stated == 1)
		self._ccbOwner["node_open"..i]:setVisible(stated == 2)

		local times = chestAwardsInfo[i].times
		if times == "max" then
			self._ccbOwner["tf_day"..i]:setString("全勤")
		else
			self._ccbOwner["tf_day"..i]:setString(times.."天")
		end
	end

	local barScaleX = 0
	for i = 1, 5 do
		local times = chestAwardsInfo[i].times
		if times == "max" then
			times = self._totalDay
		else
			times = tonumber(times)
		end
		if signInDay >= times then
			barScaleX = barScaleX + 1/5
		else
			local nextDays = times
			local lastDays = 0
			if chestAwardsInfo[i-1] then
				lastDays = chestAwardsInfo[i-1].times
			end
			local days = nextDays-lastDays
			barScaleX = barScaleX + (signInDay-lastDays)/days * 1/5
			break
		end
	end

	self._ccbOwner.sp_bar:setScaleX(barScaleX)
end

function QUIWidgetMonthSignInChestClient:chestClickHandler(index)
	local chestAwardsInfo = remote.monthSignIn:getSignInChestAwardList()

	local awardInfo = chestAwardsInfo[index]
	local awards = {}
	local i = 1
	while awardInfo["type_"..i] do
        local typeName = remote.items:getItemType(awardInfo["type_"..i])
        table.insert(awards, {id = awardInfo["id_"..i], typeName = typeName, count = awardInfo["num_"..i]})
        i = i + 1
	end
	
	local day = awardInfo.times
	if day == "max" then
		day = self._totalDay
	else
		day = tonumber(day)
	end
	if awardInfo.stated == 1 then
		--请求获取
		remote.monthSignIn:requestMonthSignInChest(day, function (data)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards}, {isPopCurrentDialog = false}})
	    	dialog:setTitle("恭喜您获得累计签到奖励")
		end)
	else
		local tips = {
            {oType = "font", content = "领取条件：累计签到天数达到", size = 26, color = GAME_COLOR_LIGHT.mormal},
            {oType = "font", content = day, size = 24, color = GAME_COLOR_LIGHT.stress},
            {oType = "font", content = "天", size = 26, color = GAME_COLOR_LIGHT.mormal},
        }
		app:luckyDrawAlert(awardInfo.reward_id, tips, awards)
	end
end

function QUIWidgetMonthSignInChestClient:_onTriggerChest1()
	app.sound:playSound("common_small")

	self:chestClickHandler(1)
end

function QUIWidgetMonthSignInChestClient:_onTriggerChest2()
	app.sound:playSound("common_small")

	self:chestClickHandler(2)
end

function QUIWidgetMonthSignInChestClient:_onTriggerChest3()
	app.sound:playSound("common_small")

	self:chestClickHandler(3)
end

function QUIWidgetMonthSignInChestClient:_onTriggerChest4()
	app.sound:playSound("common_small")

	self:chestClickHandler(4)
end

function QUIWidgetMonthSignInChestClient:_onTriggerChest5()
	app.sound:playSound("common_small")

	self:chestClickHandler(5)
end

return QUIWidgetMonthSignInChestClient
