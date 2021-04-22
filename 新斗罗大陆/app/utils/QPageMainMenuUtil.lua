-- @Author: xurui
-- @Date:   2018-06-11 10:43:12
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-16 18:32:30
local QPageMainMenuUtil = class("QPageMainMenuUtil")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..ui.widgets.QUIWidgetAnimationPlayer")
local QUIWidgetIconAniTips = import("..ui.widgets.QUIWidgetIconAniTips")
local QQuickWay = import("..utils.QQuickWay")
local QUserData = import("..utils.QUserData")
function QPageMainMenuUtil:ctor(options)
	self._activityPostShowStated = {}  							--活动公告的是否已经展示过了
end

function QPageMainMenuUtil:viewDidAppear( ... )
end

function QPageMainMenuUtil:viewWillDisappear( ... )
end

--xurui: 检查首充奖励的icon
function QPageMainMenuUtil:checkFirstRechargeStated(key)
	-- local rechargeActivityInfo = QResPath("menu_icon")[key]
	-- local activityInfo = {}
	local isVisible = false
	local tipVisible = false
	local index = 1

	-- 首充奖励
	if ENABLE_FIRST_RECHARGE then
		if ENABLE_CHARGE(true) then
			local configs = QStaticDatabase.sharedDatabase():getStaticByName("first_recharge_new")
			local configList = {}
			for _, config in pairs(configs) do
				table.insert(configList, config)
			end
			table.sort(configList, function(a, b)
					return a.id < b.id
				end)

			if not remote.firstRecharge or not remote.firstRecharge.firstRechargeReward or #remote.firstRecharge.firstRechargeReward < #configList then
				isVisible = true
				local completeNum = 0
				local rewardDic = {}
				local recordType = nil
				for _, id in ipairs(remote.firstRecharge.firstRechargeReward or {}) do
					completeNum = completeNum + id
					rewardDic[id] = true
				end

				if completeNum < 3 then
					index = 1
					-- activityInfo = rechargeActivityInfo[index]
					recordType = FIRST_RECHARGE_TIPS.LEVEL_ONE
				else
					index = 2
					-- activityInfo = rechargeActivityInfo[index]
					recordType = FIRST_RECHARGE_TIPS.LEVEL_TWO
				end
				
				local currentRMBNum = QVIPUtil:rechargedRMBNum()
				for _, config in ipairs(configList) do
					local curRMBCondition = config.add_recharge
					if currentRMBNum >= curRMBCondition then
						if not rewardDic[config.id] then
							tipVisible = true
						end
					end
				end

				-- if remote.firstRecharge.firstClick ~= true then
				if not app:getUserOperateRecord():getRecordByType(recordType) then
					tipVisible = true
				end
			end
		end
	end

	--开服基金
	if isVisible == false and false then
		index = 3
		if remote.user.fundStatus ~= 1 then
			isVisible = true
			-- activityInfo = rechargeActivityInfo[index]
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FIRST_RECHARGE) then
				tipVisible = true
			end
		end
	end

	--双月卡 影藏掉
	if isVisible == false and false then
		index = 4
		local remainingDays1 = (remote.recharge["monthCard1EndTime"]/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
		if remainingDays1 <= 0 and remote.task:checkTaskisDone(tostring(200001)) == false then
			isVisible = true
			-- activityInfo = rechargeActivityInfo[index]
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FIRST_RECHARGE) then
				tipVisible = true
			end
		end

		if isVisible == false then
			local remainingDays2 = (remote.recharge["monthCard2EndTime"]/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
			if remainingDays2 <= 0 and remote.task:checkTaskisDone(tostring(200002)) == false then
				isVisible = true
				-- activityInfo = rechargeActivityInfo[index]
				if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FIRST_RECHARGE) then
					tipVisible = true
				end
			end
		end
	end

	local getShopItem = function(vipLevel)
		local shopItem = nil
		local shopItems = remote.stores:getStoresById(SHOP_ID.vipShop)
		if shopItems ~= nil then
			for i = 1, #shopItems, 1 do
				if vipLevel == QVIPUtil:getVIPLevelByShopId(shopItems[i].good_group_id) then
					shopItem = shopItems[i]
					break
				end
			end
		end

		return shopItem
	end
	
	return isVisible, index, tipVisible
end

function QPageMainMenuUtil:openFirstRechargeDialog(rechargeActivitType)
	if rechargeActivitType == nil then return end
	
	if rechargeActivitType == 1 then
		-- remote.firstRecharge.firstClick = true
		app:getUserOperateRecord():setRecordByType(FIRST_RECHARGE_TIPS.LEVEL_ONE, true)
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRechargeNew", options = {}})
	elseif rechargeActivitType == 2 then
		-- remote.firstRecharge.firstClick = true
		app:getUserOperateRecord():setRecordByType(FIRST_RECHARGE_TIPS.LEVEL_TWO, true)
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRechargeNew", options = {}})
	elseif rechargeActivitType == 3 then
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRecharge", options = {type = rechargeActivitType,
			callBack = function() self._isShowTip = true end}})
	elseif rechargeActivitType == 4 then
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRecharge", options = {type = rechargeActivitType,
			callBack = function() self._isShowTip = true end}})
	elseif rechargeActivitType == 5 then
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRecharge", options = {type = rechargeActivitType,
			callBack = function() self._isShowTip = true end}})
	elseif rechargeActivitType == 6 then
		return app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRecharge", options = {type = rechargeActivitType,
			callBack = function() self._isShowTip = true end}})
	end
end

function QPageMainMenuUtil:checkFirstRechargeNew(callback)
	if ENABLE_FIRST_RECHARGE and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.FIRST_RECHARGE_POSTER) then
		if ENABLE_CHARGE(true) then
			local configs = QStaticDatabase.sharedDatabase():getStaticByName("first_recharge_new")
			local config1 = configs["1"]
			local config2 = configs["2"]
			if config1.add_recharge ~= 1 or config2.add_recharge ~= 18 then
				config1 = {}
				config2 = {}
				for _, config in pairs(configs) do
					if config.add_recharge == 1 then
						config1 = config
					elseif config.add_recharge == 18 then
						config2 = config
					end
				end
			end
			if next(config1) ~= nil and next(config2) ~= nil then
				local poster1 = function ()
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRechargePoster", 
						options = {level = 1, config = config1, cb = callback}})
				end
				local poster2 = function ()
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFirstRechargePoster", 
						options = {level = 2, config = config2, cb = callback}})
				end

				local currentRMBNum = QVIPUtil:rechargedRMBNum()
				if currentRMBNum < config1.add_recharge then
					poster1()
					return
				elseif currentRMBNum < config2.add_recharge then
					poster2()
					return
				end
			end
		end
	end

	if callback then
		callback()
	end
end
--检查嘉年华公告
function QPageMainMenuUtil:checkActivityJianianhua(callback)
	if not app.unlock:checkLock("UNLOCK_CARNIVAL") then 
		if callback then
			callback()
		end
		return
	end
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_JIANIANHUA) then
		local tbl = {}
	    tbl[remote.activity.TYPE_ACTIVITY_FOR_SEVEN] = 1
	    local activityInfo = remote.activity:getActivityData(tbl)

		local openServerTime = (remote.user.openServerTime or 0) / 1000
		local nowTime = q.serverTime()
		local offsetTime = (nowTime - openServerTime) / DAY
		if offsetTime <= 3 then 
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_JIANIANHUA)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPost", 
				options = {activityInfo = activityInfo, activityType = 8, callback = callback}})	
		else
			if callback then
				callback()
			end
		end
	else
		if callback then
			callback()
		end
	end
end
--检查游戏功能公告
function QPageMainMenuUtil:checkVersionPost(callback)
	local data = QStaticDatabase:sharedDatabase():getVersionPostInfo()
	if remote.stores.versionPost == true or next(data) == nil then
		if callback then
			callback()
		end
		return 
	end

	local nowTime = q.serverTime()
	local openServerTime = (remote.user.openServerTime or 0) / 1000
	local offsetTime = (nowTime - openServerTime) / DAY
	local convertTime = function(value)
		local time = q.getDateTimeByStr(value)
		time = q.OSTime(time)
		return time
	end
	local showDates = {}
	for _, value in pairs(data) do
		local needHide = tonumber(value.hide) or 0
		if not (needHide == 1 and FinalSDK.needHideActivity and FinalSDK.needHideActivity()) then
			local showDayTbl = string.split(tostring(value.need_days), ";")
			local startDay = tonumber(showDayTbl[1]) or 0
			local endDay = tonumber(showDayTbl[2]) or 0
			local level = value.level_min or 0
			if remote.user.level >= level then
				if value.is_hot_blood == 1 then -- 热血服
					if remote.user.isWarmBloodServer and offsetTime >= startDay and offsetTime <= endDay then
						table.insert(showDates, value)
					end
				elseif value.is_yinyongbao == 1 then
					local costNum = db:getConfigurationValue("yingyongbao_bafu_money") or 300

					if remote.user.newTotalRecharge >= costNum 
						and value.channel 
						and tostring(value.channel) == FinalSDK.getChannelID() 
						then
						local info = app:getUserOperateRecord():getRecordByType("PUBLICITY_MAP_CHANNEL"..value.channel.."isYinyongbao"..remote.user.userId)
						if not info  then
							table.insert(showDates, value)
						end
					end

				elseif offsetTime > startDay then
					local openTime = convertTime(value.open_time)
					local closeTime = convertTime(value.end_time)
					local isHide = db:checkItemShields(value.id, SHIELDS_TYPE.PUBLICITY_MAP)
					if nowTime >= openTime and nowTime <= closeTime and not isHide then
						-- 对一次弹脸活动看看记录时间是否在活动时间内
						if value.type == 2 then 
							local recordTime = app:getUserOperateRecord():getRecordByType("PUBLICITY_MAP_"..(value.id or 0))
							if not recordTime or recordTime < openTime or recordTime > closeTime then
								table.insert(showDates, value)
							end
						elseif value.channel then
							if tostring(value.channel) == FinalSDK.getChannelID() then -- 应用宝特殊弹框
								if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("PUBLICITY_MAP_CHANNEL"..value.channel) then
									table.insert(showDates, value)
								end
							end
						else
							table.insert(showDates, value)
						end
					end
				end
			end
		end
	end
	table.sort(showDates, function(a, b)
		if a.type ~= b.type then
			return a.type < b.type
		else
			return a.id < b.id
		end
	end)

	local index = 1
	local showPost
	showPost = function()
		if showDates[index] then
			-- 记录一次弹脸活动时间
			local activity = showDates[index] 
			if activity.is_yinyongbao == 1 then
				app:getUserOperateRecord():setRecordByType("PUBLICITY_MAP_CHANNEL"..activity.channel.."isYinyongbao"..remote.user.userId, true)
			end

			if activity.type == 2 then
				app:getUserOperateRecord():setRecordByType("PUBLICITY_MAP_"..(activity.id or 0), nowTime)

				local publicityMapRewardRequest = {id = activity.id}
				local request = {api = "PUBLICITY_MAP_GET", publicityMapRewardRequest = publicityMapRewardRequest}
				app:getClient():requestPackageHandler("PUBLICITY_MAP_GET", request)
			end
			if activity.channel and tostring(activity.channel) == FinalSDK.getChannelID() then
				if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("PUBLICITY_MAP_CHANNEL"..activity.channel) then
					app:getUserOperateRecord():recordeCurrentTime("PUBLICITY_MAP_CHANNEL"..activity.channel)
				end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAdvertisingInfo",
				options = {data = showDates[index], callback = showPost}})
			index = index + 1
			remote.stores.versionPost = true
		else
			if callback then
				callback()
			end
		end
	end 
	showPost()
end

--检查活动公告
function QPageMainMenuUtil:checkActivityPost(callback)
	local openServerTime = (remote.user.openServerTime or 0) / 1000
	local nowTime = q.serverTime()
	local offsetTime = (nowTime - openServerTime) / DAY

	local activityInfo
	local activityType = 1
	--连续充值
	if offsetTime <= 7 then
		local tbl = {}
		--zxs modify屏蔽连续充值弹脸
        --tbl[remote.activity.TYPE_ACTIVITY_FOR_REPEATPAY] = 1
        local data = remote.activity:getActivityData(tbl)
        if data and data[1] and self._activityPostShowStated[data[1].activityId] == nil then
			activityInfo = data[1]
		end
		if nil ~= activityInfo then
			local todayTargetId = remote.activity:getDayChargeByAcitivityId(activityInfo.activityId)
			if nil ~= todayTargetId then
				for _,v in ipairs(activityInfo.targets) do
					if v.activityTargetId == todayTargetId then
						if remote.activity:checkCompleteByTargetId(v) == true then
							activityInfo = nil
							break
						end
					end
				end
			else
				local isFind = false
				for _,v in ipairs(activityInfo.targets) do
					if v.completeNum == 2 then
						isFind = true
					end
				end
				if isFind == false then
					activityInfo = nil
				end
			end
		end
	elseif 7 < offsetTime and offsetTime <= 14 and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FOR_WEEK) then
		local tbl = {}
        tbl[remote.activity.TYPE_ACTIVITY_FOR_WEEK] = 1
        local data = remote.activity:getActivityData(tbl)
        if data and data[1] and self._activityPostShowStated[data[1].activityId] == nil then
        	local isShow = false
        	for i, target in pairs(data[1].targets) do
        		if target.completeNum ~= 3 then
        			isShow = true
        			break
        		end
        	end
        	if isShow then
				activityInfo = data[1]
				activityType = 3
			end
		end
	elseif remote.activityMonthFund:isMonthFundOpen(remote.activityMonthFund.TYPE_1) and not remote.activityMonthFund:isFundAwardOpen(remote.activityMonthFund.TYPE_1) and 
		app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND) and offsetTime > 14 then
		-- 268月基金
		activityType = 4
		if self._activityPostShowStated[remote.activityMonthFund.TYPE_1] == nil then
	        activityInfo = remote.activityMonthFund:getMonthFundInfo()
	        activityInfo.activityId = remote.activityMonthFund.TYPE_1
       end
  	elseif remote.activityMonthFund:isMonthFundOpen(remote.activityMonthFund.TYPE_2) and not remote.activityMonthFund:isFundAwardOpen(remote.activityMonthFund.TYPE_2) and 
		app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND_2) and offsetTime > 14 then
		-- 168月基金
		activityType = 4.5
		if self._activityPostShowStated[remote.activityMonthFund.TYPE_2] == nil then
	        activityInfo = remote.activityMonthFund:getMonthFundInfo()
	        activityInfo.activityId = remote.activityMonthFund.TYPE_2
	   	end
    elseif remote.activityRounds:getWeekFund() and remote.activityRounds:getWeekFund():getActivityActiveState() and remote.activityRounds:getWeekFund():checkWeekFoundIsBuyTime() and
    	app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_WEEK_FUND) and offsetTime > 14 then
		-- 周基金
		activityType = 5
		if self._activityPostShowStated[remote.activityRounds.WEEKFUND_TYPE] == nil then
	        activityInfo = remote.activityRounds:getWeekFund():getWeekFundInfo()
	        activityInfo.activityId = remote.activityRounds.WEEKFUND_TYPE
       end
	end
	-- 新服基金
	local newServiceFund = remote.activityRounds:getNewServiceFund()
	if activityInfo == nil and newServiceFund and newServiceFund:getActivityActiveState() and newServiceFund:checkWeekFoundIsBuyTime() and
    	app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_NEWSERVICE_FUND) then
    	if newServiceFund.luckyDrawId == newServiceFund.NEW_SERVICE_FUND_7 then
			activityType = 6
    	else
			activityType = 7
		end
		local tbl = {}
        tbl[remote.activity.TYPE_NEW_SERVICE_FUND] = 1
    	local data = remote.activity:getActivityData(tbl)
        if data and data[1] and self._activityPostShowStated[data[1].activityId] == nil then
			activityInfo = data[1]
		end
   end



	--开服竞赛
	if activityInfo == nil and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FOR_FORCE) then
		if offsetTime > 3 and offsetTime <= 7 and remote.user.level >= db:getConfigurationValue("FORCE_COMPETITION_LEVEL") then
			local tbl = {}
	        tbl[remote.activity.TYPE_ACTIVITY_FOR_FORCE] = 1
        	local data = remote.activity:getActivityData(tbl)
	        if data and data[1] and self._activityPostShowStated[data[1].activityId] == nil then
				activityInfo = data[1]
				activityType = 2
			end
		end
	end

   --新服直冲活动
   local newSvrRechargeProxy = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
   if activityInfo == nil and newSvrRechargeProxy then
   		local atyTable = {remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE,remote.activity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS}
   		for i,v in ipairs(atyTable) do
   			local needShow = newSvrRechargeProxy:checkNeedPromptByThemeId(v)
   			if needShow then
   				local info = newSvrRechargeProxy:getNewServerRechargeConfigByThemeId(v)
   				if info and self._activityPostShowStated[info.activity_id] == nil then
					activityInfo = {themeId = v , activityId = info.activity_id}
					activityType = 8
					newSvrRechargeProxy:setNewServerRechargePromptRecordByThemeId(v)
					break
   				end
   			end
   		end
   end

	if activityInfo then
		self._activityPostShowStated[activityInfo.activityId] = 1
		QPrintTable(activityInfo)
		if activityInfo.activityId == remote.activityMonthFund.TYPE_1 then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND)
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityMonthFundPost", 
				options = {activityInfo = activityInfo, callback = handler(self, self.checkActivityPost), endBack = callback}})
			return
		elseif activityInfo.activityId == remote.activityMonthFund.TYPE_2 then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND_2) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_MONTH_FUND_2)
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityMonthFundPost", 
				options = {activityInfo = activityInfo, callback = handler(self, self.checkActivityPost), endBack = callback}})
			return
		elseif activityInfo.activityId == remote.activityRounds.WEEKFUND_TYPE then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_WEEK_FUND) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_WEEK_FUND)
			end
		elseif activityType == 3 then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FOR_WEEK) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_FOR_WEEK)
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPoster3", 
				options = {activityInfo = activityInfo, callback = handler(self, self.checkActivityPost), endBack = callback}})
			return
		elseif activityType == 6 or activityType == 7 then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_NEWSERVICE_FUND) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_NEWSERVICE_FUND)
			end
		elseif activityType == 2 then
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FOR_FORCE) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_FOR_FORCE)
			end
		elseif activityType == 8 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityNewServerRecharge"
				, options = {themeId = activityInfo.themeId , callback = handler(self, self.checkActivityPost), endBack = callback}})	
			return
		else
			if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_FOR_REPEATPAY) then
				app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_FOR_REPEATPAY)
			end
		end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPost", 
			options = {activityInfo = activityInfo, activityType = activityType, callback = handler(self, self.checkActivityPost), endBack = callback}})
	else
		if callback then
			callback()
		end
	end
end

function QPageMainMenuUtil:checkQuestionnaire( ... )
	local questionnaire = remote.activity:getQuestionnaireInfo()
	if q.isEmpty(questionnaire) == false then

		local nowTime = q.serverTime() * 1000
		if (questionnaire.startAt or 0) <= nowTime and (questionnaire.endAt or 0) > nowTime then
			return true
		end
	end

	return false
end

function QPageMainMenuUtil:openQuestionnaire( ... )
	local questionnaire = remote.activity:getQuestionnaireInfo()
	if q.isEmpty(questionnaire) == false then
		if questionnaire.url then
			local roleId = remote.user.userId
			local serverId = remote.selectServerInfo.serverId
			local userId = remote.user.name
			local questionId = questionnaire.activityId
			local platformId = 5
			if device.platform == "ios" and FinalSDK.getChannelID() == "101" then
				platformId = 6
			end

			device.openURL(string.format(questionnaire.url, roleId, serverId, userId, questionId, platformId))
		end
	end
end

function QPageMainMenuUtil:checkTavernAward()
	local scoreConfig = db:getConfigurationValue("WUHUNDIAN_JIFEN_DANGWEI")
	local scores = string.split(scoreConfig, ";")
	local curScore = remote.user.luckydrawAdvanceTotalScore or 0
	local curTurn = remote.user.luckydrawAdvanceRewardRow or 0
	local getBoxStr = remote.user.luckydrawAdvanceRewardGotBoxs or ""
	local getBoxList = string.split(getBoxStr, ";") or {}

	local maxScore = 0
	-- 三档位信息
	for i = 1, #scores do
		if maxScore < tonumber(scores[i]) then
			maxScore = tonumber(scores[i])
		end
	end

	-- 当前轮次积分
	curScore = curScore - curTurn*maxScore
	if curScore > maxScore then
		curScore = maxScore
	end

    -- 是否没被领取
    local hasNotAwardGot = function(luckyId)
		for i, v in pairs(getBoxList) do
			if luckyId == v then
				return false
			end
		end
		return true
	end
	for i = 1, #scores do
		local luckyId = "wuhundianjifen_"..i
		if curScore >= tonumber(scores[i]) and hasNotAwardGot(luckyId) then
			return true
		end
	end
	return false
end

function QPageMainMenuUtil:checkChestTip(chestNode)
	if remote.user:getChestState() then
		chestNode:setVisible(true)
	end
	if self:checkTavernAward() then
		chestNode:setVisible(true)
	end
end

function QPageMainMenuUtil:checkUnionTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:checkLock("UNLOCK_UNION") then
		local unionRedpacket, unionFight, unionPlunder, unionRate
		if remote.redpacket:checkRedpacketRedTip() then
			specialTipNode:setVisible(true)
			unionRedpacket = self:createSpecialTip(specialTipNode, "_unionRedpacketTip", 1, 8, "", "down")
		else
			self:removeSpecialTip("_unionRedpacketTip")
		end

		if remote.union:checkSocietyDungeonRedTips() then
			specialTipNode:setVisible(true)
			unionFight = self:createSpecialTip(specialTipNode, "_unionSpecailTip", 1, 4, "", "down")
		elseif remote.unionDragonWar:checkHaveFightCount() then
			specialTipNode:setVisible(true)
			unionFight = self:createSpecialTip(specialTipNode, "_unionSpecailTip", 1, 4, "", "down")
		elseif remote.consortiaWar:checkFightRedTips() then
			specialTipNode:setVisible(true)
			unionFight = self:createSpecialTip(specialTipNode, "_unionSpecailTip", 1, 4, "", "down")
		else
			self:removeSpecialTip("_unionSpecailTip")
		end

		local _, _, isActive = remote.plunder:updateTime()
		if remote.plunder:checkPlunderUnlock() and isActive then
			specialTipNode:setVisible(true)
			unionPlunder = self:createSpecialTip(specialTipNode, "_unionPlunderTip", 1, 6, "", "down")
		else
			self:removeSpecialTip("_unionPlunderTip")
		end

		if self:checkRateActivity(702) then
			specialTipNode:setVisible(true)
			unionRate = self:createSpecialTip(specialTipNode, "_unionRateTip", 2, 0, "宗门\n翻倍", "down")
		else
			self:removeSpecialTip("_unionRateTip")
		end

		local tips = {unionRedpacket, unionFight, unionPlunder, unionRate}
		self:alternatelyShowTip(tips)

		if remote.union:checkUnionRedTip() then
			tipNode:setVisible(true)
		end
	end
end

function QPageMainMenuUtil:checkMetalCityTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)	
	specialTipNode:setVisible(false)
	if remote.metalCity:checkMetalCityUnlock() then 

	    local fightCount = remote.metalCity:getMetalCityFightCount()
	    if fightCount > 0 then
			specialTipNode:setVisible(true)
			self:createSpecialTip(specialTipNode, "_metalCitySpecialTip", 1, 4, "", "right")
		else
			self:removeSpecialTip("_metalCitySpecialTip")
	    end

	    if remote.metalCity:checMainPageRedTip() then
			tipNode:setVisible(true)
			return
		end
	end

	if remote.metalAbyss:checkMetalAbyssIsUnLock() then 
		
	    if remote.metalAbyss:checMainPageRedTip() then
			tipNode:setVisible(true)
			return
		end
	end

end

function QPageMainMenuUtil:checkCollegeTrainTip( tipNode, specialTipNode )
	if tipNode == nil or specialTipNode == nil then return end
	tipNode:setVisible(false)	
	specialTipNode:setVisible(false)
	local mockbattle_ = remote.mockbattle:checkRedTips() 
	if remote.collegetrain:checkCollegeTrainRedTips() or  mockbattle_ then 
	    tipNode:setVisible(true)

		local collegeInfo = remote.collegetrain:getCollegeMyInfo()
		local todayCommentCount = 0
		if collegeInfo then
			todayCommentCount = collegeInfo.todayCommentCount or 0
		end

		local speacial_ = todayCommentCount < 1 or mockbattle_

	    if speacial_ then
			specialTipNode:setVisible(true)
			self:createSpecialTip(specialTipNode, "_collegeTrainSpecialTip", 1, 4, "", "right")
		else
			self:removeSpecialTip("_collegeTrainSpecialTip")
	    end
	end	
end

function QPageMainMenuUtil:checkBlackSoulTowerTip( tipNode, specialTipNode )
	if tipNode == nil or specialTipNode == nil then return end
	tipNode:setVisible(false)	
	specialTipNode:setVisible(false)	
	local soulTowerTips = remote.soultower:checkRedTip()
	local blackbattle_ = remote.blackrock:checkRedTip()
	if blackbattle_ or  soulTowerTips then 
	    tipNode:setVisible(true)

    	local awardInfo = remote.soultower:getSoulTowerRoundEndAward()
    	local myRank = remote.soultower:getMySeverRank()
		if q.isEmpty(awardInfo) == false or myRank <= 0 then
			specialTipNode:setVisible(true)
			self:createSpecialTip(specialTipNode, "_blackSoulTowerSpecialTip", 1, 4, "", "right")	
		else
			self:removeSpecialTip("_blackSoulTowerSpecialTip")
		end

	 --    local soulTowerInfo = remote.soultower:getMySoulTowerInfo()
	 --    local wave = soulTowerInfo and soulTowerInfo.wave or 0
	 --    if wave <= 0 then
		-- 	specialTipNode:setVisible(true)
		-- 	self:createSpecialTip(specialTipNode, "_blackSoulTowerSpecialTip", 1, 4, "", "right")
		-- else
		-- 	self:removeSpecialTip("_blackSoulTowerSpecialTip")
		-- end
	end		
end

function QPageMainMenuUtil:checkFightClubTips(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)	
	specialTipNode:setVisible(false)
	if app.unlock:getUnlockFightClub() then 
		if remote.fightClub:checkFightClubRedTips() then
			tipNode:setVisible(true)
		end
	    if remote.fightClub:getShowPlunderTips() then
			specialTipNode:setVisible(true)
			self:createSpecialTip(specialTipNode, "_fightClubSpecialTip", 1, 7, "", "down")
		else
			self:removeSpecialTip("_fightClubSpecialTip")
	    end
	end
end

function QPageMainMenuUtil:checkInvasionRedTips(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end
	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if not app.unlock:getUnlockInvasion() then return end

	local invasionAwardTip, invationFight

	local specialTime1 = remote.invasion:specialMoment(1)
	local specialTime2 = remote.invasion:specialMoment(2)
	if specialTime1 or specialTime2 then
		specialTipNode:setVisible(true)
		local str = "消耗\n减半"
		if specialTime2 then
			str = "积分\n翻倍"
		end
		invasionAwardTip = self:createSpecialTip(specialTipNode, "_invationSpecialTip", 2, 0, str, "right")
	else
		self:removeSpecialTip("_invationSpecialTip")
	end

	local invasions = remote.invasion:getInvasions()
	local fightCount = remote.invasion:currentTokenNumber()
	if #invasions > 0 and fightCount > 0 then
		specialTipNode:setVisible(true)
		invationFight = self:createSpecialTip(specialTipNode, "_invationFightTip", 1, 4, "", "right")
	else
		self:removeSpecialTip("_invationFightTip")
	end

	local tips = {invasionAwardTip, invationFight}
	self:alternatelyShowTip(tips)

	if remote.stores:checkFuncShopRedTips(SHOP_ID.invasionShop) then
		tipNode:setVisible(true)
	elseif remote.worldBoss:checkWorldBossRedTips() then
		tipNode:setVisible(true)
	elseif remote.invasion:checkKillAwards() then
		tipNode:setVisible(true)
	elseif remote.invasion:checkCanGenerateBoss() then
		tipNode:setVisible(true)		
	else
		if remote.invasion:invasionRewardApplicable() then
			tipNode:setVisible(true)
		end
	end
end

function QPageMainMenuUtil:checkSilvermineTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end
	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:checkLock("UNLOCK_SILVERMINE") then

		local silvermineFightTip, assistRateTip

		if remote.silverMine:checkSilverMineAttackCountRedTip() then
			specialTipNode:setVisible(true)
			silvermineFightTip = self:createSpecialTip(specialTipNode, "_silvermineSpecialTip", 1, 1, "", "down")
		else
			self:removeSpecialTip("_silvermineSpecialTip")
		end
		
		local assistNum = remote.silverMine:getMineAssistNum()
		if assistNum > 0 then
			specialTipNode:setVisible(true)
			assistRateTip = self:createSpecialTip(specialTipNode, "_assistSpecialTip", 1, 5, "", "down")
		else
			self:removeSpecialTip("_assistSpecialTip")
		end

		local tips = {silvermineFightTip, assistRateTip}
		self:alternatelyShowTip(tips)

		if remote.silverMine:checkSilverMineRedTip() then
			tipNode:setVisible(true)
		end
	end
end

function QPageMainMenuUtil:checkMaritimeRedTip(tipNode,specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end
	tipNode:setVisible(false)
	specialTipNode:setVisible(false)

	if remote.maritime:checkMaritimeRedTips() then
		tipNode:setVisible(true)
	end	

	local maritimeRedspecialTip
	if remote.maritime:checkSpecialTips() then
		specialTipNode:setVisible(true)
		maritimeRedspecialTip = self:createSpecialTip(specialTipNode, "_maritimeRedspecialTip", 1, 9, "", "right")
	else
		self:removeSpecialTip("_maritimeRedspecialTip")
	end

	local tips = {maritimeRedspecialTip}
	self:alternatelyShowTip(tips)

end

function QPageMainMenuUtil:checkArenaTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:getUnlockArena() == false then return end

	local arenaFightTip, arenaRateTip, arenaStakeTip
	if remote.arena:getTips(true) then
		specialTipNode:setVisible(true)
		arenaFightTip = self:createSpecialTip(specialTipNode, "_arenaSpecialTip", 1, 4, "", "down")
	elseif remote.sotoTeam:checkFightRedTips() then
		specialTipNode:setVisible(true)
		arenaFightTip = self:createSpecialTip(specialTipNode, "_arenaSpecialTip", 1, 4, "", "down")
	elseif remote.silvesArena:checkFightTips() then
		specialTipNode:setVisible(true)
		arenaFightTip = self:createSpecialTip(specialTipNode, "_arenaSpecialTip", 1, 4, "", "down")
	else
		self:removeSpecialTip("_arenaSpecialTip")
	end

	if self:checkRateActivity(606) then
		specialTipNode:setVisible(true)
		arenaRateTip = self:createSpecialTip(specialTipNode, "_arenaRateTip", 2, 0, "斗魂币\n 双倍", "down")
	else
		self:removeSpecialTip("_arenaRateTip")
	end

	if remote.silvesArena:checkStakeRedTips() then
		specialTipNode:setVisible(true)
		arenaStakeTip = self:createSpecialTip(specialTipNode, "_arenaStakeTip", 1, 11, "", "down")
	else
		self:removeSpecialTip("_arenaStakeTip")
	end

	local tips = {arenaFightTip, arenaRateTip, arenaStakeTip}
	self:alternatelyShowTip(tips)

	if remote.arena:getArenaTips() or remote.sotoTeam:checkRedTips() or remote.silvesArena:checkRedTips() then
		tipNode:setVisible(true)
	end
end

function QPageMainMenuUtil:checkInstanceTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)

	local arenaFightTip, arenaRateTip
	local tbl = {}
	-- *      600 普通副本碎片掉落翻倍
	-- *      601 普通副本金币掉落翻倍
	-- *      602 精英副本碎片掉落翻倍
	-- *      603 精英副本金币掉落翻倍
	-- *      701 普通副本材料掉落翻倍
 	if app.unlock:getUnlockElite() then 
 		tbl = {600, 601, 602, 603, 701}
	else
		tbl = {600, 601, 701}
	end
	for _, id in ipairs(tbl) do
		if self:checkRateActivity(id) then
			specialTipNode:setVisible(true)
			if id == 600 or id == 601 or id == 701 then
				arenaRateTip = self:createSpecialTip(specialTipNode, "_instanceRateTip", 2, 0, "材料\n翻倍", "right")
			else
				arenaRateTip = self:createSpecialTip(specialTipNode, "_instanceRateTip", 2, 0, "精英\n翻倍", "right")
			end
			break
		else
			self:removeSpecialTip("_instanceRateTip")
		end
	end
	

	local tips = {arenaFightTip, arenaRateTip}
	self:alternatelyShowTip(tips)

	if remote.instance:isShowRedPoint() or remote.welfareInstance:isShowRedPoint() or remote.nightmare:getDungeonRedPoint() then
		tipNode:setVisible(true)
	end
end

function QPageMainMenuUtil:checkThunderTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:getUnlockThunder(false) == false then return end

	local thunderFightTip, thunderRateTip

	if remote.thunder:checkThunderEliteFightCount() then
		specialTipNode:setVisible(true)
		thunderFightTip = self:createSpecialTip(specialTipNode, "_thunderSpecialTip", 1, 2, "", "right")
	else
		self:removeSpecialTip("_thunderSpecialTip")
	end

	if self:checkRateActivity(607) then
		specialTipNode:setVisible(true)
		thunderRateTip = self:createSpecialTip(specialTipNode, "_thunderRateTip", 2, 0, "杀戮币\n 双倍", "right")
	else
		self:removeSpecialTip("_thunderRateTip")
	end

	local tips = {thunderFightTip, thunderRateTip}
	self:alternatelyShowTip(tips)

	if remote.thunder:checkThunderRedTips() then
		tipNode:setVisible(true)
	end 
end 

function QPageMainMenuUtil:checkSunWarTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:checkLock("UNLOCK_SUNWELL") == false then return end

	local sunWarFightTip, sunWarRateTip, totemChallengeFightTip

	if remote.sunWar:checkSunWarCanRevive() then
		specialTipNode:setVisible(true)
		sunWarFightTip = self:createSpecialTip(specialTipNode, "_sunWarSpecialTip", 1, 3, "", "right")
	else
		self:removeSpecialTip("_sunWarSpecialTip")
	end

	if self:checkRateActivity(609) then
		specialTipNode:setVisible(true)
		sunWarRateTip = self:createSpecialTip(specialTipNode, "_sunWarRateTip", 2, 0, "海神币\n 双倍", "right")
	else
		self:removeSpecialTip("_sunWarRateTip")
	end

	if remote.totemChallenge:checkTips() then
		specialTipNode:setVisible(true)
		totemChallengeFightTip = self:createSpecialTip(specialTipNode, "_totemChallengeFightTip", 1, 4, "", "right")
	else
		self:removeSpecialTip("_totemChallengeFightTip")
	end

	local tips = {sunWarFightTip, sunWarRateTip, totemChallengeFightTip}
	self:alternatelyShowTip(tips)

	if remote.sunWar:isShowRedPointAtMainPage() or remote.totemChallenge:checkStoreTips() then
		tipNode:setVisible(true)
	end 
end 

function QPageMainMenuUtil:checkGloryTowerTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:getUnlockGloryTower() == false then return end

	local towerFightTip, towerRateTip

	if remote.tower:checkTowerCanFight() then
		specialTipNode:setVisible(true)
		towerFightTip = self:createSpecialTip(specialTipNode, "_towerSpecialTip", 1, 4, "", "right")
	else
		self:removeSpecialTip("_towerSpecialTip")
	end

	if self:checkRateActivity(611) then
		specialTipNode:setVisible(true)
		towerRateTip = self:createSpecialTip(specialTipNode, "_towerRateTip", 2, 0, "大魂师\n币双倍", "right")
	else
		self:removeSpecialTip("_towerRateTip")
	end

	local tips = {towerFightTip, towerRateTip}
	self:alternatelyShowTip(tips)

	if remote.tower:checkGloryTowerRedTips() then
		tipNode:setVisible(true)
	end 
end 

function QPageMainMenuUtil:checkStormArenaTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:checkLock("UNLOCK_STORM_ARENA") == false then return end

	local stromFightTip

	if remote.stormArena:checkCanFight() then
		specialTipNode:setVisible(true)
		stromFightTip = self:createSpecialTip(specialTipNode, "_stormSpecialTip", 1, 4, "", "right")
	else
		self:removeSpecialTip("_stormSpecialTip")
	end

	local tips = {stromFightTip}
	self:alternatelyShowTip(tips)

	if remote.stormArena:checkStormArenaRedTips() then
		tipNode:setVisible(true)
	end 
end 

function QPageMainMenuUtil:checkSanctuaryTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)
	if app.unlock:checkLock("UNLOCK_SANCTRUARY") == false then return end

	local sanctuaryFightTip
	if remote.sanctuary:checkFightRedTips() then
		specialTipNode:setVisible(true)
		sanctuaryFightTip = self:createSpecialTip(specialTipNode, "_sanctuarySpecialTip", 1, 4, "", "down")
	else
		self:removeSpecialTip("_sanctuarySpecialTip")
	end

	local tips = {sanctuaryFightTip}
	self:alternatelyShowTip(tips)

	if remote.sanctuary:checkRedTips() then
		tipNode:setVisible(true)
	end 
end 


function QPageMainMenuUtil:checkRankTip(tipNode, specialTipNode)
	if tipNode == nil or specialTipNode == nil then return end

	tipNode:setVisible(false)
	specialTipNode:setVisible(false)

	local rankAwardTip
	if remote.rank:checkAwardTips() then
		specialTipNode:setVisible(true)
		rankAwardTip = self:createSpecialTip(specialTipNode, "_rankSpecialTip", 1, 10, "", "right")
	else
		self:removeSpecialTip("_rankSpecialTip")
	end

	local tips = {rankAwardTip}
	self:alternatelyShowTip(tips)

	if remote.rank:checkAwardTips() then
		tipNode:setVisible(true)
	end 
end 

function QPageMainMenuUtil:createSpecialTip(node, tipName, tipType, iconNum, str, dirction)
	if tipName and self[tipName] then
		self[tipName]:removeFromParent()
		self[tipName] = nil
	end

	local tipWidget = QUIWidgetIconAniTips.new()
	tipWidget:setInfo(tipType, iconNum, str, dirction)
	node:addChild(tipWidget)

	if tipName then 
		self[tipName] = tipWidget
	end

	return tipWidget
end

function QPageMainMenuUtil:removeSpecialTip(tipName)
	if tipName and self[tipName] then
		self[tipName]:removeFromParent()
		self[tipName] = nil
	end
end

--交替显示当前提示动画
function QPageMainMenuUtil:alternatelyShowTip(tipNodes)
	local tips = {}
	for i, v in pairs(tipNodes) do
		if v ~= nil then
			table.insert(tips, v)
		end
	end
	if #tips <= 1 then return end

	local showIndex = 0
	local tipNum = #tips

	local showTipEffect
	local checkShowTip

	showTipEffect = function(tip)
		if tip then
			local arrayIn = CCArray:create()
			arrayIn:addObject(CCScaleTo:create(0.2, 1))
			arrayIn:addObject(CCDelayTime:create(5))
			arrayIn:addObject(CCCallFunc:create(function()
					local arrayOut = CCArray:create()
					arrayOut:addObject(CCScaleTo:create(0.2, 0))
					arrayOut:addObject(CCCallFunc:create(function()
						checkShowTip()
					end))
					tip:runAction(CCSequence:create(arrayOut))
				end))
			tip:runAction(CCSequence:create(arrayIn))
		end
	end

	checkShowTip = function()
		showIndex = showIndex + 1
		if showIndex > tipNum then
			showIndex = 1
		end 

		local tip = tips[showIndex]
		if tip and tip:isVisible() then
			showTipEffect(tip)
		end
	end

	for _, tip in ipairs(tips) do
		tip:setScale(0)
	end

	checkShowTip()
end

function QPageMainMenuUtil:checkRateActivity(activityType)
	local multiple = remote.activity:getActivityMultipleYield(activityType)
	if multiple > 1 then
		return true
	else
		return false
	end
end

function QPageMainMenuUtil:checkBackground(mainPage)
	if mainPage == nil or mainPage._ccbOwner == nil then return end
	
	local isDay = app:checkDayNightTime()

	local alphaData = { --1,变色的节点；2,变色的透明度 
		{ {"btn_sunwell"}, 0.1 },
		{ {"sp_foreground_1", "btn_silvermine", "btn_shop", "btn_monopoly", "btn_sunwell"}, 0.2 },

		{ {"btn_instance", "btn_thunder", "sp_chest", "sp_rank", "btn_metalcity", "btn_union", "btn_arena", "btn_archaeology", 
			"btn_soulTrial"}, 0.1 },

		{ {"btn_invasion", "btn_time_machine", "btn_stormArena", "bg_land_front_1", "btn_fight_club"}, 0.15 }, 
		{ {"sp_rock", "btn_glory", "sparfield_mainbody", "sp_sparfield", "sp_sparfield_1", "btn_maritime"}, 0.3 },
		{ {"bg_land_front_3", "bg_land_front_4", "bg_land_front_1", "bg_land_front_2"}, 0.35},
		{ {"sp_camp", "bg_land_mid_1", "bg_land_mid_2"}, 0.4 },
	 }
	
	mainPage._ccbOwner.node_day_sky:setVisible(isDay) 
	mainPage._ccbOwner.node_sun_light:setVisible(isDay)
	mainPage._ccbOwner.node_night_sky:setVisible(not isDay)

	local color = {119, 125, 255}
	local mountainColor = {172, 144, 200}

	for _, value in ipairs(alphaData) do
		if q.isEmpty(value[1]) == false then
			local realColor = ccc3(255, 255, 255)
			if not isDay then
				local alpha = value[2]
				alpha = alpha > 1 and 1 or alpha
				local brightness = 5
				realColor = ccc3(255 - color[1] * alpha - brightness, 255 - color[2] * alpha - brightness, color[3] - brightness)
			end

			for _, sprite in ipairs(value[1]) do
				if mainPage._ccbOwner[sprite] then
					mainPage._ccbOwner[sprite]:setColor(realColor)
				end
			end
		end
	end

	local middleLands = {"bj_1", "bj_2", "bj_3"}
	for _, sprite in ipairs(middleLands) do
		local realColor = ccc3(255, 255, 255)
		if not isDay then
			local brightness = 35
			local saturation = 10
			local alpha = 0.5
			realColor = ccc3(255 - color[1] * alpha - brightness + saturation, 255 - color[2] * alpha - brightness + saturation, color[3] - brightness)
		end
		if mainPage._ccbOwner[sprite] then
			mainPage._ccbOwner[sprite]:setColor(realColor)
		end
	end

	local mountains = {"bj_far2_1", "bj_far2_2", "bj_far2_3"}
	for _, sprite in ipairs(mountains) do
		local realColor = ccc3(255, 255, 255)
		if not isDay then
			local brightness = 15
			realColor = ccc3(mountainColor[1] - brightness, mountainColor[2] - brightness, mountainColor[3] - brightness)
		end
		if mainPage._ccbOwner[sprite] then
			mainPage._ccbOwner[sprite]:setColor(realColor)
		end
	end

	return isDay
end

function QPageMainMenuUtil:checkVIPPrerogative(callback)
	if app.tutorial and app.tutorial:isInTutorial() then
    	if callback then
    		callback()
    	end
		return
	end

    local currentRMBNum = QVIPUtil:rechargedRMBNum()
    local flag = remote.flag:getLocalData(remote.flag.VIP_PREROGATIVE)
    if currentRMBNum >= 1500 and tonumber(flag) ~= 1 and (FinalSDK.getChannelID() == "101" or FinalSDK.getChannelID() == "20" or FinalSDK.getChannelID() == "40"
    	or FinalSDK.getChannelID() == "60" or FinalSDK.getChannelID() == "61" or FinalSDK.getChannelID() == "62" or FinalSDK.getChannelID() == "63") then
		remote.flag:set(remote.flag.VIP_PREROGATIVE, 1)

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPPrerogative", 
			options = {callBack = function()
				if callback then
					callback()
				end
			end}})
    else
    	if callback then
    		callback()
    	end
    end
end

function QPageMainMenuUtil:checkAnimationLinkage(callback)
	if app.tutorial and app.tutorial:isInTutorial() then
    	if callback then
    		callback()
    	end
		return
	end

    local flag = remote.flag:getLocalData(remote.flag.ANIMATION_LINKAGE)
    flag = tonumber(flag) or 0

    local flagNewSection = remote.flag:getLocalData(remote.flag.ANIMATION_NEW_SECTION)
    flagNewSection = tonumber(flagNewSection) or 0
    if remote.instance:checkIsPassByDungeonId("wailing_caverns_5") and flagNewSection < 1 then
		remote.flag:set(remote.flag.ANIMATION_NEW_SECTION, 1)

		local options = {}
		options.data = {resource_1 = QResPath("animation_linkage_pic")[1]}
		options.callback = callback
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAdvertisingInfo", options = options})
    		
    elseif remote.instance:checkIsPassByDungeonId("deadmine_5") and flag < 2 then
		remote.flag:set(remote.flag.ANIMATION_LINKAGE, 2)

		local options = {}
		options.data = {resource_1 = QResPath("animation_linkage_pic")[2]}
		options.callback = callback
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAdvertisingInfo", options = options})
	else
		if callback then
			callback()
		end
	end
end

function QPageMainMenuUtil:checkUserComeBack(callback)
	if app.tutorial and app.tutorial:isInTutorial() then
    	if callback then
    		callback()
    	end
		return
	end

    remote.userComeBack:openDialog(callback)
end

function QPageMainMenuUtil:isShowSnow(mainPage)
	local date = q.date("%Y/%m/%d",q.serverTime())
	local snow = false
	local snowStartTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_winter_start")
	local snowEndTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_winter_end")
	if date >= snowStartTime and date <= snowEndTime then
		snow = true
	end
	
	local snowNode = {"node_decoration", "snow_decoration_3", "snow_decoration_5", "node_scense_snow", "snow_behind_1",
		"snow_behind_2", "snow_behind_3", "snow_behind_4", "snow_behind_5", "snow_behind_6", "snow_behind_di", "snow_behind_di1",
		"snow_behind_di2", "snow_behind_right", "snow_front_1", "snow_front_2", "snow_front_3", "snow_front_4", "snow_front_5",
		"snow_front_6", "snow_front_7", "snow_front_8", "snow_front_9", "snow_front_di", "snow_front_di1", "snow_front_di2",
		"snow_front_di3", "snow_front_di4", "snow_front_left", "snow_front_right", "snow_middle_1", "snow_middle_2", "snow_middle_3",
		"snow_middle_4", "snow_middle_left", "snow_middle_left1", "snow_middle_right", "snow_middle_right1"
	}
	if snow ~= true then 
		for _, node in ipairs(snowNode) do
			if mainPage._ccbOwner[node] then
				mainPage._ccbOwner[node]:setVisible(false)
			end
		end
	end

	return snow
end

function QPageMainMenuUtil:checksnow(mainPage)
	local snow = self:isShowSnow(mainPage)
	return snow
end

function QPageMainMenuUtil:checkCarnivalActivity(mainPage)
	local activityInfo = remote.activityCarnival:getActivityInfo()

	if q.isEmpty(activityInfo) and remote.activityCarnival:checkActivityIsAvailable() == false then
		mainPage._ccbOwner.node_carnival:setVisible(false)
	else
		mainPage._ccbOwner.node_carnival:setVisible(true)
		if activityInfo.title and mainPage:getPageMainMenuIcon() then
			mainPage:getPageMainMenuIcon():setIconWidgetName("node_carnival", activityInfo.title)
		end
		if activityInfo.title_icon and mainPage:getPageMainMenuIcon() then
			mainPage:getPageMainMenuIcon():setIconWidgetIcon("node_carnival", activityInfo.title_icon)
		end
	end

	local tip = remote.activityCarnival:checkCarnivalActivityTips()
	if mainPage:getPageMainMenuIcon() then
		mainPage:getPageMainMenuIcon():setIconWidgetRedTips("node_carnival", tip)
	end
end

function QPageMainMenuUtil:checkPrompt(mainPage)
	-- 世界BOSS
	if app.unlock:getUnlockWorldBoss() and remote.worldBoss:checkWorldBossIsUnlock() then
		self._promptGo = 1
		if mainPage:getPageMainMenuIcon() then
			mainPage:getPageMainMenuIcon():updateIconWidget("node_prompt", self._promptGo)
			mainPage:getPageMainMenuIcon():setIconWidgetRedTips("node_prompt", remote.worldBoss:getWorldBossFightCount() > 0)
		end
		mainPage._ccbOwner.node_prompt:setVisible(true)
		mainPage:updatePromptTime(self._promptGo)
		return
	end
	
	-- 极北之地
	local timeStr, color, isActive, isOpen = remote.plunder:updateTime()
	if remote.plunder:checkPlunderUnlock() and isActive then
		self._promptGo = 2
		if mainPage:getPageMainMenuIcon() then
			mainPage:getPageMainMenuIcon():updateIconWidget("node_prompt", self._promptGo)
			mainPage:getPageMainMenuIcon():setIconWidgetRedTips("node_prompt", remote.plunder:getLootCnt() > 0)
		end
		mainPage._ccbOwner.node_prompt:setVisible(true)
		mainPage:updatePromptTime(self._promptGo)
		return
	end
	mainPage._ccbOwner.node_prompt:setVisible(false)
end

function QPageMainMenuUtil:gotoPrompt()
	-- 世界BOSS
	if self._promptGo == 1 then
		QQuickWay:openWorldBoss()
	end
	
	-- 极北之地
	if self._promptGo == 2 then
		QQuickWay:openUnionPlunder()
	end
end

function QPageMainMenuUtil:checkPlayerRecallPoster(callback)
	local userIdList = app:getUserOperateRecord():getRecordByType("PLAYER_RECALL_USERID") or {}
	local isRecord = false
	for _, userId in ipairs(userIdList) do
		if userId == remote.user.userId then
			isRecord = true
		end
	end
	if remote.playerRecall:isOpen() and not isRecord then
		table.insert(userIdList, remote.user.userId)
		app:getUserOperateRecord():setRecordByType("PLAYER_RECALL_USERID", userIdList)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPlayerRecallAlert", options = {callback = callback}})
	else
		if callback then
			callback()
		end
	end
end

function QPageMainMenuUtil:checkAnniversaryTime(pageMain)
	local date = q.date("%Y/%m/%d",q.serverTime())
	local show = false
	local startTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_anniversary_start")
	local endTime = QStaticDatabase:sharedDatabase():getConfigurationValue("main_scene_anniversary_end")

	if date >= startTime and date <= endTime then
		show = true
	end

	local index = 1
	while pageMain._ccbOwner["node_anniversary_"..index] do
		pageMain._ccbOwner["node_anniversary_"..index]:setVisible(show)
		index = index + 1
	end
end

function QPageMainMenuUtil:checkMaigcHerbPrompt(callback)
	local myMagicHerbList = remote.magicHerb:getMagicHerbItemList()
	local tipVisible = false
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MAGICHERB_MAX_COUNT) then
		tipVisible = true
	end

	local maxCount = db:getConfigurationValue("MAX_MAGIC_HERB_COUNT")
	if not maxCount then
		if callback then
			callback()
		end
		return
	end
	local promptCount = maxCount - 100
	if tipVisible and promptCount and #myMagicHerbList >= promptCount then
		local content = {}
        table.insert(content, {oType = "font", content = "魂师大人，您当前背包内的仙品数量已经超过了", size = 24, color = ccc3(255,215,172)})
        table.insert(content, {oType = "font", content = promptCount, size = 24, color = ccc3(255,255,255)})
        table.insert(content, {oType = "font", content = "个，当超过", size = 24, color = ccc3(255,215,172)})
        table.insert(content, {oType = "font", content = maxCount, size = 24, color = ccc3(255,255,255)})
        table.insert(content, {oType = "font", content = "个以后获得仙品将会丢失。仙品升级需要大量经验，快去消耗升级吧～", size = 24, color = ccc3(255,215,172)})
		local titlePath = QResPath("magicHerbPromptTitle")
		local uorType = DAILY_TIME_TYPE.MAGICHERB_MAX_COUNT
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPrompt", 
			options = {content = content, titlePath = titlePath, uorType = uorType, callback = callback}})
	else
		if callback then
			callback()
		end
	end
end

function QPageMainMenuUtil:checkSilvesArenaPoster(callback)
	local tipVisible = false
	local seasonStartAt = 0
	local state = remote.silvesArena:getCurState(true)
	if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_READY then
		seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_OPEN")
	elseif state == remote.silvesArena.STATE_PEAK then
		seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_OPEN_PEAK")
	end
	if seasonStartAt ~= 0 and remote.silvesArena.seasonInfo and remote.silvesArena.seasonInfo.seasonStartAt ~= seasonStartAt then
		tipVisible = true
	end
	if tipVisible then
		local content = {}
		if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_READY then
        	table.insert(content, {oType = "font", content = "魂师大人，西尔维斯大斗魂场已经开启报名了，优质的队友可是稀有资源哦，快来组队吧", size = 24, color = COLORS.a})
        elseif state == remote.silvesArena.STATE_PEAK then
        	local hasTop16Data, isInPeak, score, rank = remote.silvesArena:getMySilvesArenaAuditionRankInfo()
        	if hasTop16Data then
	        	if isInPeak then
		        	table.insert(content, {oType = "font", content = "恭喜魂师大人，您的小队在海选赛以", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = score.."分", size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "，第", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = rank.."名", size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "的优异成绩成为了", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = "16强", size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "，被邀请参加西尔维斯巅峰赛，快去看看吧～", size = 24, color = COLORS.a})
		        elseif score and rank then
		        	table.insert(content, {oType = "font", content = "魂师大人，很遗憾您的小队在海选赛的积分是", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = score.."分", size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "，排在第", size = 24, color = COLORS.a})
		        	table.insert(content, {oType = "font", content = rank.."名", size = 24, color = COLORS.b})
		        	table.insert(content, {oType = "font", content = "无缘16强，无法参加西尔维斯巅峰赛。", size = 24, color = COLORS.a})
		        end
	       	end
        end

        if q.isEmpty(content) then 
        	if callback then
				callback()
			end
			return 
        end
		local titlePath = QResPath("silves_arena_poster_title")
		local spAvatarPath = QResPath("silves_arena_poster_avatar")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPrompt", 
			options = {content = content, titlePath = titlePath, spAvatarPath = spAvatarPath, uorType = false, btnText = "前  往", okCallback = function()
				remote.silvesArena:openDialog(nil, callback)
			end}})
		if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_READY then
        	app:getUserOperateRecord():setRecordByType("SIVES_ARENA_OPEN", remote.silvesArena.seasonInfo.seasonStartAt)
        elseif state == remote.silvesArena.STATE_PEAK then
        	app:getUserOperateRecord():setRecordByType("SIVES_ARENA_OPEN_PEAK", remote.silvesArena.seasonInfo.seasonStartAt)
        end
	else
		if callback then
			callback()
		end
	end
end

function QPageMainMenuUtil:checkZhangbichenFormalPrompt(callback)
	-- if remote.user.needShowThemeFormalPicture then
	-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityZhangbichenPoster", options = {callback = callback}})
	-- else
		if callback then
			callback()
		end
	-- end
end


function QPageMainMenuUtil:checkMysteryStorePrompt(callback)
	local activityId = remote.activity:checkMysteryStoreActivityNeedPrompt()
	if activityId ~= 0 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMysteryStorePerview"
			, options = {callback = callback , activityId = activityId}})
	else
		if callback then
			callback()
		end
	end
end


function QPageMainMenuUtil:checkShowFullScreenSettings(callback)
	local ui_view_size =  app:getUserData():getValueForKey(QUserData.UI_VIEW_SIZE)
    local major = FULL_SCREEN_ADAPTATION_VERSION.major
    local minor = FULL_SCREEN_ADAPTATION_VERSION.minor
    local revision = FULL_SCREEN_ADAPTATION_VERSION.revision
    local recordManager = app:getUserOperateRecord()
	local fullSceneRecord = recordManager:getRecordByType(recordManager.RECORD_TYPES.FULL_SCENE_TIPS)
	if app:isNativeLargerEqualThan(major, minor, revision) and display.width > UI_VIEW_MIN_WIDTH  and not ui_view_size and fullSceneRecord ~= 1 and false then

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFullScreenTips", 
			options = {callback = callback}})
	else
		if callback then
			callback()
		end
	end

end
-- 有些功能不需要接受玩家邀请，客户端做屏蔽
function QPageMainMenuUtil:canNotShowInvite( )
	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
	if self._zhangbichenModel and self._zhangbichenModel:isInTheGame() then
		return true
	end

	return false
end

return QPageMainMenuUtil
