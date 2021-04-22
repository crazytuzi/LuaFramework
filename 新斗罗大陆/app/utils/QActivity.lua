--
-- Author: Your Name
-- Date: 2015-03-19 12:25:03
-- 精彩活动
--
local QBaseModel = import("..models.QBaseModel")
local QActivity = class("QActivity",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")
local QLogFile = import("..utils.QLogFile")

QActivity.EVENT_UPDATE = "EVENT_UPDATE"
QActivity.EVENT_CHANGE = "EVENT_CHANGE"
QActivity.EVENT_COMPLETE_UPDATE = "EVENT_COMPLETE_UPDATE"
QActivity.EVENT_OTHER_CHANGE = "EVENT_OTHER_CHANGE"
QActivity.EVENT_128RECHARGE_UPDATE = "EVENT_128RECHARGE_UPDATE"

QActivity.EVENT_QIANSHITANGSAN_UPDATE = "EVENT_QIANSHITANGSAN_UPDATE"


QActivity.EVENT_CHANNEL_AWARD_INFO_UPDATE = "EVENT_CHANNEL_AWARD_INFO_UPDATE"


QActivity.TYPE_ACTIVITY = 1 --精彩活动
QActivity.TYPE_ACTIVITY_FOR_SEVEN = 3 --七日活动
QActivity.TYPE_ACTIVITY_FOR_FUND = 2 --开服基金
QActivity.TYPE_ACTIVITY_FOR_TIGER = 4 --聚宝龙穴
QActivity.TYPE_ACTIVITY_FOR_FORCE = 5 --开服竞赛
QActivity.TYPE_ACTIVITY_FOR_RATE = 6 --倍率活动
QActivity.TYPE_ACTIVITY_FOR_PREPAY = 7 --预充值宣传
QActivity.TYPE_ACTIVITY_FOR_PREPAYGET = 8 --预充值回馈
QActivity.TYPE_ACTIVITY_FOR_CARD = 9 --月卡活动
QActivity.TYPE_ACTIVITY_FOR_REPEATPAY = 10 --连续充值活动
QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 = 11  --8-14日活动
QActivity.TYPE_ACTIVITY_FOR_HOLIDAY = 12  --节假日活动
QActivity.TYPE_ACTIVITY_FOR_DESC = 14  --描述类活动
QActivity.TYPE_ACTIVITY_FOR_WEEK = 15  --周礼包类活动
QActivity.TYPE_ACTIVITY_FOR_CARNIVAL = 16  --节日狂欢活动
QActivity.TYPE_ACTIVITY_FOR_CARNIVAL_EXCHANGE = 17  --节日狂欢兑换活动
QActivity.TYPE_ACTIVITY_SUPER_MONDAY = 18  --超级星期一活动
QActivity.TYPE_ACTIVITY_FOR_LEVEL_GIFT = 20  --热血服冲级礼包
QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE = 21  --热血服等级竞赛
QActivity.TYPE_PSEUDO_ACTIVITY = 101 -- 伪精彩活动

QActivity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW = 25  --新版1-7日活动
QActivity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW = 26  --新版8-14日活动

QActivity.TYPE_MONTHFUND = 501 --月基金 --客户端定义 
QActivity.TYPE_WEEKFUND = 502 --周基金 --客户端定义 
QActivity.TYPE_NEW_SERVICE_FUND = 503  --新服基金 --客户端定义
QActivity.TYPE_SEVEN_ENTRY1 = 530 --7日登录 
QActivity.TYPE_FOURTEEN_ENTRY1 = 531 --14日登录
QActivity.TYPE_SEVEN_ENTRY2 = 532 --7日累计登录
QActivity.TYPE_FOURTEEN_ENTRY2 = 533 --14日累计登录
QActivity.TYPE_FENG_CE_FAN_LI = 601 --封测返利
QActivity.TYPE_CELEBRITY_HALL_RANK = 1001 --3
QActivity.TYPE_FORGE = 701 --铸造活动
QActivity.TYPE_VIP_INHERIT = 801  --vip继承
QActivity.TYPE_VIP_GIFT_DAILY = "a300" --每日福利
QActivity.TYPE_VIP_GIFT_WEEK = "a301" --每周礼包
QActivity.TYPE_CRYSTAL_SHOP = 821  -- 水晶商店活动 客户端定义
QActivity.TYPE_ACTIVITY_TARGET_ITEM = 715 --收集目标道具（仅活动产出和道具转换）

QActivity.TYPE_VERSION_CHANGE_LOGIN = 719 --版更登录活动

QActivity.TIME1 = 8 --七日活动时间
QActivity.TIME2 = 7 --七日活动有效时间
QActivity.TIME3 = 7 --开服竞赛有效时间

QActivity.TIME4 = 8 --8-14日 活动开启时间
QActivity.TIME5 = 15 --8-14日 活动结束时间
QActivity.TIME6 = 14 --8-14日 活动有效时间


QActivity.TYPE_ACTIVITY_FOR_WENJUAN = 99 --删测 问卷调查

QActivity.TIME_WENJUAN_START = 7 -- 4/26 问卷开启时间
QActivity.TIME_WENJUAN_END = 7 --5/3 问卷结束时间

QActivity.EVENT_RECIVED_QUESTIONNAIRE = "EVENT_RECIVED_QUESTIONNAIRE"    --接收调查问卷消息

QActivity.THEME_ACTIVITY_NONE = 0
QActivity.THEME_ACTIVITY_NORMAL = 1
QActivity.THEME_ACTIVITY_LIMIT = 2
QActivity.THEME_ACTIVITY_FORGE = 23  --铸造活动主题
QActivity.THEME_ACTIVITY_SOUL_LETTER = 25  --魂师手札活动主题
QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1 = 38 -- 鼠年春节活动1
QActivity.THEME_ACTIVITY_RAT_FESTIVAL_2 = 39 -- 鼠年春节活动2
QActivity.THEME_ACTIVITY_ZHANGBICHEN_PREHEAT = 48 -- 張碧晨主題曲活動預熱
QActivity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL = 49 -- 張碧晨主題曲活動正式

QActivity.THEME_ACTIVITY_QIANSHITANGSAN = 52 -- 前世唐三的神秘商店
QActivity.THEME_ACTIVITY_SKIN_SHOP = 54 -- 皮肤商店
QActivity.THEME_ACTIVITY_HIGHTEA = 55 -- 下午茶
QActivity.THEME_ACTIVITY_MAZE_EXPLORE = 58 --破碎位面

QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE = 62       --新服直冲
QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS = 63 --新服直冲皮肤

QActivity.THEME_ACTIVITY_RESOURCE_TREASURES = 67 -- 资源夺宝
QActivity.THEME_ACTIVITY_CUSTOM_SHOP = 68 -- 订制商店

QActivity.VIP_GIFT_DAILY = 28 --每日福利
QActivity.VIP_GIFT_WEEK = 29	--每周礼包

-- 精彩活动
local NORMAL_TYPE = {
	QActivity.TYPE_ACTIVITY, 
	QActivity.TYPE_ACTIVITY_FOR_TIGER,
	-- QActivity.TYPE_ACTIVITY_FOR_FUND,
	QActivity.TYPE_ACTIVITY_FOR_FORCE,
	QActivity.TYPE_ACTIVITY_FOR_RATE,
	QActivity.TYPE_ACTIVITY_FOR_PREPAY,
	QActivity.TYPE_MONTHFUND,
	QActivity.TYPE_WEEKFUND,
	QActivity.TYPE_CELEBRITY_HALL_RANK,
	QActivity.TYPE_ACTIVITY_FOR_DESC,
	QActivity.TYPE_ACTIVITY_FOR_LEVEL_GIFT,
	QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE,
	QActivity.TYPE_PSEUDO_ACTIVITY,
}

--活动目标类型枚举类型 对应 activityTargetId
QActivity.ACTIVITY_TARGET_TYPE ={	

	FREE_GET_DALIY = 720,                        --活动期间每日免费领取
	FREE_RECHARGE_DALIY = 721,                   --活动期间每日直冲购买
	RECHARGE_PURCHASE = 722,                     --直冲购买
	USE_TO_SHOW_AWARD = 723,                     --用于显示奖励
}



--活动id类型枚举类型 对应 activityId 活动ID
QActivity.ACTIVITY_TYPE = {
	QIANSHITANGSAN = 30,             -- 	前世唐三


}

--对应recharge表中的type
QActivity.RECHARGE_TYPE = {
	FIRST_RECHARGE = 1,		--首次充值
	MONTH_CARD = 2,			--月卡充值
	SOUL_LETTER = 3,		--手札充值
	RECHARGE_GIFT = 4,		--等级礼包
	DALIY_RECHARGE = 5,		--每日礼包
	DIRECT_RECHARGE = 6,	--直冲购买
	SEVEN_RECHARGE = 7,	    --嘉年华跟半月礼包
	NEW_SERVER_RECHARGE = 8,	--新服直冲
	CUSTOM_SHOP_RECHARGE = 9,	--订制商店直冲
}



--平台专属活动id
QActivity.ACTIVITY_CHANNEL ={	

	GAME_CENTER_VIVO	= 1,	--vivo游戏中心登陆
	GAME_CENTER_OPPO	= 2,	--oppo游戏中心登陆
	CARNIVAL_DAY_OPPO	= 3,	--oppo狂欢日
	REAL_NAME_OPPO		= 4,	--oppo实名制奖励
}

QActivity.ACTIVITY_CHANNEL_REFRESH_TYPE = {
	
	DALIY_REFRESH = 1,
	MONTH_REFRESH = 2,
	NEVER_REFRESH = 3,
}

function QActivity:ctor(options)
	QActivity.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self:registerHandlerFun()

	self.activities = {}
	self._activityOtherData = {} --非精彩活动、七日活动的数据
	self._progressData = {}
	self._rechargeRecords = {}
	self._dayRecharge = {}

	self._dataProxy = {}
	self._activityThemeList = {}	-- 主题活动

	self._questionnaireDict = {}            --问卷调查信息
    self._dispatchList = {}

    self._channelAwardIds = {}

	-- self.famousPersonData = nil -- 用来缓存来自老服的名人堂活动数据
end

function QActivity:init()
	self._remoteEventProxy = cc.EventProxy.new(remote)
    self._remoteEventProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.updateAchievesForList))
    self._remoteEventProxy:addEventListener(remote.DUNGEON_UPDATE_EVENT, handler(self, self.updateAchievesForList))
    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.updateAchievesForList))

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.updateAchievesForList))
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.markUpdateHandler))

    --xurui:注册问卷调查后台推送的监听
    app:getClient():pushReqRegister("SEND_YUEWEN_QUESTION_CHANGE", handler(self, self._onNewQuestionnaireReceived))


end

function QActivity:disappear()
	if self._remoteEventProxy ~= nil then
		self._remoteEventProxy:removeAllEventListeners()
		self._remoteEventProxy = nil
	end
	if self._userEventProxy ~= nil then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end
	if self._itemProxy ~= nil then
		self._itemProxy:removeAllEventListeners()
		self._itemProxy = nil 
	end
end

-- 可以放入精彩活动里的本地活动
function QActivity:canInsertNormal(type)

	for i = 1, #NORMAL_TYPE do
		if type == NORMAL_TYPE[i] then
			return true
		end
	end

	if type == remote.activity.TYPE_ACTIVITY_FOR_REPEATPAY and remote.activity:checkIsAllComplete(type) then
		return true
	end

    if type == remote.activity.TYPE_ACTIVITY_FOR_PREPAYGET and remote.activity:checkIsAllComplete(type) then
        return true
    end

    if ENABLE_CHARGE() and type == remote.activity.TYPE_ACTIVITY_FOR_CARD then
        return true
    end

	return false
end

function QActivity:getActivityByTheme(themeId)
	self:shortData()
	local activities = {}
	for _, value in ipairs(self.activities) do
		-- 把本地活动放入精彩活动里
		if (not value.subject or value.subject == QActivity.THEME_ACTIVITY_NONE) then
			if themeId == QActivity.THEME_ACTIVITY_NORMAL and self:canInsertNormal(value.type) then
				if value.start_at and value.end_at then
					local curTime = q.serverTime()*1000
					local endAt = value.end_at
					if value.award_end_at and value.award_end_at > value.end_at then
						endAt = value.award_end_at
					end
					if curTime >= value.start_at and curTime < endAt then
						table.insert(activities, value)
					end
				else
					table.insert(activities, value)
				end
			end
		end
		
		-- 有主题的活动
		if value.subject and value.subject == themeId then
			if value.start_at and value.end_at then
				local curTime = q.serverTime()*1000
				local endAt = value.end_at
				if value.award_end_at and value.award_end_at > value.end_at then
					endAt = value.award_end_at
				end
				if themeId == QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1 and value.show_at and curTime >= value.show_at and curTime < endAt then
					table.insert(activities, value)
				elseif curTime >= value.start_at and curTime < endAt then
					table.insert(activities, value)
				end
			else
				table.insert(activities, value)
			end
		end
	end
	-- 封测活动放进精彩活动里
	if self.fcflData and themeId == QActivity.THEME_ACTIVITY_NORMAL then
		table.insert(activities, self.fcflData)
	end
	if self.vipInheritData and themeId == QActivity.THEME_ACTIVITY_NORMAL then
		-- 未领取
		if not remote.user.warmBloodVipGet then
			table.insert(activities, self.vipInheritData)
		end
	end

	return activities
end

function QActivity:getActivityData(typeNames)
	self:shortData()
	local activities = {}
	for _, value in ipairs(self.activities) do
		if typeNames[value.type] ~= nil then
			if value.type == QActivity.TYPE_CELEBRITY_HALL_RANK then
				if value.start_at and value.end_at then
					local curTime = q.serverTime()*1000
					if curTime >= value.start_at and curTime < value.end_at then
						table.insert(activities, value)
					end
				end
			else
				table.insert(activities, value)
			end
		end
	end

	if self.fcflData then
		local isFind = false
        for _, value in ipairs(activities) do
            if value.type == QActivity.TYPE_FENG_CE_FAN_LI then
                isFind = true
                break
            end
        end
		if not isFind then
			table.insert(activities, self.fcflData)
		end
	end
	return activities
end

function QActivity:getActivityThemeList()
	return self._activityThemeList
end

function QActivity:updateFCFL(data)
	if data and data.rechargeFeedback and data.rechargeFeedback.rechargeAmount > 0 and self.fcflData then
		self.fcflData.rechargeFeedback = data.rechargeFeedback
   	end
end

function QActivity:getActivityDataLegth()
	return table.nums(self.activities)
end

--请求数据活动列表
function QActivity:requestActivityData()
	self.activities = {}
	self._activityOtherData = {} --非精彩活动、七日活动的数据
	self._progressData = {}
	self.fcflData = nil
	self.vipInheritData = nil

    self:loadLocalActivity()

	-- 每日礼包 魂晶商店活动 放限时活动里（开服大于14天）
	if remote.crystal:getIsOpenCrystalShop() then
		local nowTime = q.serverTime()
		local openServerTime = (remote.user.openServerTime or 0) / 1000
		local offsetTime = (nowTime - openServerTime) / DAY
		print("开服时间=",offsetTime)
		if offsetTime > 14 then 
			table.insert(self.activities,{type = QActivity.TYPE_CRYSTAL_SHOP, weight = 10,activityId = QActivity.TYPE_CRYSTAL_SHOP, 
				title = "每日礼包",isLocal = true,subject = QActivity.THEME_ACTIVITY_LIMIT,targets = {}})
		end
	end

	app:getClient():activityListRequest()

	if remote.user.isRechargeFeedbackOpen then
        app:getClient():getRechargeFeedbackInfo(function( data )
        		if data and data.rechargeFeedback and data.rechargeFeedback.rechargeAmount > 0 then
	                data.title = "封测返利"
	                local config = QStaticDatabase.sharedDatabase():getRechargeFeedback()
	                data.targets = {}
	                for _, value in pairs(config) do
	                    table.insert(data.targets, value)
	                end
	                data.activityId = "kfjj"
	                data.type = remote.activity.TYPE_FENG_CE_FAN_LI
	                self.fcflData = data
               	end
            end)
    end

    -- 热血服
    if remote.user.isWarmBloodServer and remote.user.warmBloodVipCanExtend and not remote.user.warmBloodVipGet then
    	local info = {}
        info.title = "vip福利"
        info.activityId = "vipInherit"
        info.type = remote.activity.TYPE_VIP_INHERIT
        info.targets = {}
        self.vipInheritData = info
    end

    --拉取渠道的奖励列表
	if self:checkHaveChannelGameCenterAty() then
    	self:activityChannelMainInfoRequest()
    end

end

--[[
	活动的mark更新
]]
function QActivity:markUpdateHandler(event)
	if event.time == nil or event.time == 0 then
		self:updateDaliyData()
		self:refreshActivity(true)
		self:resetDaliyData()
	end
end

-- 更新活动
function QActivity:updateAchievesForList()
	local isChange = false
	local currentTime = q.serverTime()
	local deleteAcitivties = {}
	for index, value in pairs(self.activities) do
		if value.type ~= QActivity.TYPE_MONTHFUND then
			if value.award_end_at ~= nil and currentTime > ((value.award_end_at or 0)/1000) and value.permanent ~= true then
				table.insert(deleteAcitivties, value.activityId)
				isChange = true
			else
				if self:checkActivityState(value) == true and isChange == false then
					isChange = true
				end
			end
		end
	end
	
	for _, activityId in ipairs(deleteAcitivties) do
		self:removeActivity(activityId)
	end

	-- 主题信息
	local themeList = {}
	for i, activity in pairs(self.activities) do
		-- 除了需要固定位置的精彩活动与限时活动
		if activity.subject and activity.subject ~= 0 and 
			activity.subject ~= QActivity.THEME_ACTIVITY_NORMAL and
			activity.subject ~= QActivity.THEME_ACTIVITY_LIMIT then
			themeList[activity.subject] = true
		end
	end
	self._activityThemeList = {}
	for themeId, v in pairs(themeList) do
		local themeInfo = db:getActivityThemeInfoById(themeId)
		table.insert(self._activityThemeList, themeInfo)
	end

	if isChange == true then
		self:dispatchEvent({name = QActivity.EVENT_CHANGE})
	end
end

--排序
function QActivity:shortData()
	self:updateAchievesForList()
	for index1,value1 in pairs(self.activities) do
		-- 强制刷新每个activity的index，不然在排序的时候会出现不稳定情况
		value1.index = index1
		-- if value1.index == nil then
		-- 	value1.index = index1
		-- end
		self:shortTargets(value1)
	end
	self:shortActivities()
end


function QActivity:getActivityRedTipsTypes( info )
	-- body
	-- 3 可领取 2 新活动 1 可购买 0 无红点
	local typeName = info.type or 1
	-- 因為新年祝福活動有預覽功能，因此為了區分又不影響原來的小紅點機制，在0～1之間，增加幾個檔次
	local returnType = 0

	if typeName == QActivity.TYPE_ACTIVITY_FOR_CARD then
		if self:checkMonthCardReady() then
			return 3
		end
	end	

	if typeName == QActivity.TYPE_MONTHFUND then
		return remote.activityMonthFund:getRedTipsType(info.activityId)
	end	

	if typeName == QActivity.TYPE_WEEKFUND then
    	local weekFund = remote.activityRounds:getWeekFund()
    	if weekFund == nil then return 0 end
    	if weekFund:checkRedTips() then
    		return 3
    	end
    	return 0
	end	

	if info.subject == QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
		local curTime = q.serverTime() * 1000
		local startTime = info.start_at
		local oneDay = DAY * 1000
		if curTime >= startTime then
			-- 已經開啟
			returnType = 0.2
		elseif curTime + oneDay >= startTime then
			-- 明日開啟
			return 0.1
		else
			-- 未開啟
			return 0
		end
	end

	if self:checkActivityFundCanBuy(info.type,info) then
		return 1
	end

	if info.isHaveComplete then
		local isExchangeActvity = false
		if info.targets then
			for _,v in pairs(info.targets) do
				if self:isExchangeActivity(v.type) then
					isExchangeActvity = true
					break;
				end
			end
		end
		if isExchangeActvity then
			if not self:isActivityClicked(info) then
				return 2
			else
				return 1
			end
		else
			return 3
		end
	end

	if not self:isActivityClicked(info) then
		return 2
	end

	return returnType
end

--排序整个activity
function QActivity:shortActivities()
	table.sort(self.activities, function (item1, item2)

		-- 是否有红点 
		local type1 = self:getActivityRedTipsTypes(item1)
		local type2 = self:getActivityRedTipsTypes(item2)
		if type1 == type2 then
			local weight1 = item1.weight or 0
			local weight2 = item2.weight or 0

			if weight1 ~= weight2 then
				return weight1 > weight2
			end
			if item1.index ~= item2.index then
				return item1.index < item2.index
			end
			if item1.activityId ~= item2.activityId then
				return item1.activityId > item2.activityId
			end
		else
			return type1 > type2
		end
	end)
end

--排序每个targets
function QActivity:shortTargets(info)
	table.sort(info.targets, function (item1, item2)
		if item1.completeNum ~= item2.completeNum then
			if item1.completeNum == 2 or item2.completeNum == 3 then
				return true
			elseif item1.completeNum == 3 or item2.completeNum == 2 then
				return false
			end
		end
		if item1.index ~= item2.index then
			return item1.index < item2.index
		end
		return item1.activityTargetId < item2.activityTargetId
	end)
end


function QActivity:resetMysteryStoreActivityPromptTime(activityId)
	local curTime = q.serverTime()
	app:getUserData():setUserValueForKey(activityId .. "-" .. remote.user.userId,tostring(curTime))
end


function QActivity:checkMysteryStoreActivityNeedPrompt()
	local activityList = self:getActivityByTheme(remote.activity.THEME_ACTIVITY_QIANSHITANGSAN)

	for i,activity in ipairs(activityList or {}) do
		local time = app:getUserData():getUserValueForKey(activity.activityId .. "-" .. remote.user.userId)
		if time then
			if not q.isSameDayTime(tonumber(time) , 0) then
				return activity.activityId
			else
				return 0
			end
		else
			return activity.activityId
		end
	end

	return 0
end

--[[
	0 不存在任何需求数量 --一般是描述活动
	1 未完成的目标
	2 已经完成未领取
	3 已经领取
]]
function QActivity:checkActivityState(info)
	local currentTime = q.serverTime()
	local isHaveComplete = false
	--特殊处理兑换类活动 红点不影响主界面红点状态
	local isPageMainmenuComplete = false

	local isAllTargetsComplete = true
	
	local isChange = false
	local changeFun = function (state)
		if isChange == false then
			isChange = state
		end
	end
	
	local isAwardsActivity = false -- 是否在领奖期间
	local isActivity = false -- 是否在活动期间
	if info.permanent == true then
		isAwardsActivity = true
		isActivity = true
	else 
		local startTime = (info.award_at or 0)/1000
		local endTime = (info.award_end_at or 0)/1000
		if currentTime >= startTime and currentTime <= endTime then
			isAwardsActivity = true
		end
		if info.start_at == nil and info.end_at == nil then
			isActivity = true
		end
		local startTime = (info.start_at or 0)/1000
		local endTime = (info.end_at or 0)/1000
		if currentTime >= startTime and currentTime <= endTime then
			isActivity = true
		end
	end
	if info.targets == nil then info.targets = {} end
	local activityId = info.activityId
	for index,target in pairs(info.targets) do
		-- 强制刷新每个target的index，不然在排序的时候会出现不稳定情况
		-- target.index = index
		if target.index == nil then
			target.index = index
		end
		if target.activityId == nil then
			target.activityId = activityId
		end
		local completeNum = 0
		if target.value == nil then
			completeNum = 0
		else
			if self:checkCompleteByTargetId(target) == true then
				completeNum = 3
			else
				if isAllTargetsComplete then
					isAllTargetsComplete = false
				end

				local data = self._progressData[target.activityId][target.activityTargetId]

				if isActivity == true then
					if data ~= nil and data.completeCount == 1 and QActivity.TYPE_ACTIVITY_FOR_REPEATPAY == info.type then
						target.haveNum = target.value
					else
						target.haveNum = self:getTypeNum(target)
					end
				elseif isAwardsActivity == true then
					target.haveNum = data.progress
				end

				if self:checkActivityFundCanBuy(info.type,info) then
					isHaveComplete = true
					isPageMainmenuComplete = true 
				end
	            
	            --增加一个根据活动类型来判断是否完成该活动的
				if target.haveNum ~= nil and target.haveNum >= target.value and self:checkActivityByType(info.type, target) then
					completeNum = 2

					--钻石兑换
					local price
					if target.type == 300 then
						-- price = tonumber(target.value2) or 0
						-- if price <= remote.user.token then
						-- 	isHaveComplete = true
						-- end
					elseif target.type == 301 then
						-- price = tonumber(target.value2) or 0
						-- if price <= remote.user.money then
						-- 	isHaveComplete = true
						-- end
					
					elseif target.type == 302 then
						local isAllContentment = false
						if string.find(target.value3, "#") then
							local items = string.split(target.value3, "#") 
							local count = #items
							isAllContentment = false
							for i=1,count,1 do
								local obj = string.split(items[i], "^")
						        if #obj == 2 then
						        	local num = remote.items:getItemsNumByID(tonumber(obj[1])) or 0
						        	if tonumber(obj[1]) == nil then
						        		local itemType = remote.items:getItemType(obj[1])
						        		num = remote.user[itemType]
						        	end

						        	if num >= (tonumber(obj[2]) or 0) then
						        		isAllContentment = true
						        		break;
						        	end
						        end
							end
						else
							local items = string.split(target.value3, ";") 
							local count = #items
							isAllContentment = true
							for i=1,count,1 do
								local obj = string.split(items[i], "^")
						        if #obj == 2 then
						        	local num = remote.items:getItemsNumByID(tonumber(obj[1])) or 0
						        	if tonumber(obj[1]) == nil then
						        		local itemType = remote.items:getItemType(obj[1])
						        		num = remote.user[itemType]
						        	end

						        	if num < (tonumber(obj[2]) or 0) then
						        		isAllContentment = false
						        		break;
						        	end
						        end
							end
						end

						if isAllContentment then
							-- isHaveComplete = true
						else
							completeNum = 1
						end
 					elseif target.type == 709 then  --超级星期一终极大奖
						local date = q.date("*t", currentTime)
						if date.wday == 2 then
							completeNum = 2
							isHaveComplete = true
							isPageMainmenuComplete = true
						else
							completeNum = 1
						end
					else
						isHaveComplete = true
						isPageMainmenuComplete = true
					end
				else
					completeNum = 1
				end
			end
		end
		changeFun(target.completeNum ~= completeNum)
		target.completeNum = completeNum
	end
	
	--特殊活动处理
	if info.roundType then
		isHaveComplete = remote.activityRounds:checkActivityComplete(info)
		isPageMainmenuComplete = isHaveComplete
	end

	if isAllTargetsComplete == false then
		isHaveComplete = isHaveComplete or self:checkActivityTipEveryDay(info)

		--连续充值设置每日红点提醒
		if info.type == QActivity.TYPE_ACTIVITY_FOR_REPEATPAY then
			info.tip_type = 1
			isHaveComplete = isHaveComplete or self:checkActivityTipEveryDay(info)
			isPageMainmenuComplete = isPageMainmenuComplete or isHaveComplete
		end

	end
	changeFun(info.isHaveComplete ~= isHaveComplete) 
	info.isHaveComplete = isHaveComplete
	info.isPageMainmenuComplete = isPageMainmenuComplete
	info.isAllTargetsComplete = isAllTargetsComplete

	return isChange
end

--[[
注册一个数据代理
代理需要实现以下方法
getWidget 获取一个widget显示
getBtnTips 获取一个按钮的显示
initTips 初始化小红点提示
]]
function QActivity:registerDataProxy(activityId, dataProxy)
	self._dataProxy[activityId] = dataProxy
	for index, activity in ipairs(self.activities) do
		if activity.activityId == activityId and activity.type ~= self.TYPE_PSEUDO_ACTIVITY then
			table.remove(self.activities, index)
		end
	end
end

--获取一个数据代理
function QActivity:unregisterDataProxy(activityId)
	if self._dataProxy[activityId] then
		self._dataProxy[activityId] = nil
	end
end

--获取一个数据代理
function QActivity:getDataProxyByActivityId(activityId)
	return self._dataProxy[activityId]
end

--检查活动的每日提醒
function QActivity:checkActivityTipEveryDay(activity)
	if activity.tip_type == 1 then
		return app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("activity_"..activity.activityId)
	end
	return false
end

--设置活动的每日提醒
function QActivity:setActivityTipEveryDay(activity)
	if activity and activity.tip_type == 1 then
		if self:checkActivityTipEveryDay(activity) == true then
			app:getUserOperateRecord():recordeCurrentTime("activity_"..activity.activityId)
			self:refreshActivity()
		end
	end
end

--检查活动是否完成的时候加一个特殊判断
function QActivity:checkActivityByType(type, target)
	if type == QActivity.TYPE_ACTIVITY_FOR_FUND then
		if target.type ~= 521 then
			return remote.user.fundStatus == 1
		end
	end
	return true
end

function QActivity:checkIsWenjuanComplete( typeName )
	-- body
	if typeName == QActivity.TYPE_ACTIVITY_FOR_WENJUAN then
		if self:checkActivityIsInDays(QActivity.TIME_WENJUAN_START, QActivity.TIME_WENJUAN_END) == false then
			return false
		end
	end
	return true
end

--是否全部完成
--七日活动先判断是不是在七日内
--如果有描述性活动则算没完成
--所有活动都先判断是不是都完成了，再判断是不是在有效期内
function QActivity:checkIsAllComplete(typeName)
	if typeName == QActivity.TYPE_ACTIVITY_FOR_FORCE or typeName == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE then
		if self:checkActivityIsInDays(0, QActivity.TIME3) == true then
			return true
		end
	end
	if typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN then
		if self:checkActivityIsInDays(0, QActivity.TIME1) == false then
			return false
		end
	end

	if typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 then
		if self:checkActivityIsInDays(7, QActivity.TIME1) == false or self:checkActivitySeven2Open() then
			return false
		end
	end

	if typeName == QActivity.TYPE_MONTHFUND then
		if remote.activityMonthFund ~= nil then 
			return true 
		end
	end	

	local isNoComplete = false
	for _,value in pairs(self.activities) do
		if value.type == typeName then
			if q.serverTime() < ((value.award_end_at or 0)/1000) or value.permanent == true then
				--特殊处理 开服基金 每购买 显示小红点 
				if self:checkActivityFundCanBuy(typeName,value) then
					isNoComplete = true
					break
				end
				if value.targets ~= nil and #value.targets > 0 then
					for _,target in pairs(value.targets) do
						if self:checkCompleteByTargetId(target) == false then
							isNoComplete = true
							break
						end
					end
				else
					isNoComplete = true
					break
				end
			end
		end
	end

	return isNoComplete
end

--是否有活动可以领取
function QActivity:checkIsComplete(typeName)
	if typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN then
		if self:checkActivityIsInDays(0, QActivity.TIME1) == false then
			return false
		end
	end

	if typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 then
		if self:checkActivityIsInDays(7, QActivity.TIME1) == false then
			return false
		end
	end

	if typeName == QActivity.TYPE_ACTIVITY_FOR_CARD then
		return self:checkMonthCardReady()
	end	

	if typeName == QActivity.TYPE_WEEKFUND then
    	local weekFund = remote.activityRounds:getWeekFund()
    	if weekFund == nil then return false end
    	return weekFund:checkRedTips()
	end

	if typeName == QActivity.TYPE_MONTHFUND then
		return remote.activityMonthFund:checkRedTips(remote.activityMonthFund.TYPE_1) or remote.activityMonthFund:checkRedTips(remote.activityMonthFund.TYPE_2)
	end	

	for _,value in pairs(self.activities) do
		if  value.type == typeName and not self:isActivityClicked(value) then
			return true
		end

		if typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN or typeName == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 then
			if value.type == typeName then
				local unlockDay = self:getActivitySevenUnlockDay(typeName)
				local index = string.split(value.params, ",")
				local currentDay = tonumber(index[1]) or 0
				if currentDay <= unlockDay and value.isHaveComplete == true then
					return true
				end
			end
		else
			if value.type == typeName and value.isPageMainmenuComplete == true then
				return true
			end
		end
		
	end
	return false
end

-- 是否该主题所有活动完成
function QActivity:checkIsAllThemeComplete(themeId)
	local chechIsComplete = function(typeName)
		if typeName == QActivity.TYPE_ACTIVITY_FOR_FORCE or typeName == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE then
			if self:checkActivityIsInDays(0, QActivity.TIME3) == true then
				return true
			end
		end
		return false
	end

	local chechThemeIsComplete = function(themeId)
		if themeId == QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE or themeId == QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS then
			 local newSvrRechargeProxy = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
			 if newSvrRechargeProxy then
			 	local svrData = newSvrRechargeProxy:getNewServerRechargeSvrDataByThemeId(themeId)
			 	if svrData.awardCount and svrData.awardCount >=1 then
					return true
			 	end
			 end

		end
		return false
	end

	local activityList = self:getActivityByTheme(themeId)
	local isNoComplete = false

	for _,value in pairs(activityList) do
		if chechIsComplete(value.type) then
			isNoComplete = true
			break
		end
		local isInTime = q.serverTime() < ((value.award_end_at or 0)/1000) 
		if chechThemeIsComplete(value.subject) then
			if isInTime then
				isNoComplete = false
			else
				isNoComplete = true
			end
			break
		end
		if isInTime or value.permanent == true then
			--特殊处理 开服基金 每购买 显示小红点 
			if self:checkActivityFundCanBuy(value.type, value) then
				isNoComplete = true
				break
			end
			if value.targets ~= nil and #value.targets > 0 then
				for _,target in pairs(value.targets) do
					if self:checkCompleteByTargetId(target) == false then
						isNoComplete = true
						break
					end
				end
			else
				isNoComplete = true
				break
			end
		elseif value.activityId == QActivity.TYPE_CRYSTAL_SHOP then
			isNoComplete = true
			break			
		end
	end
	
	return isNoComplete
end

--主题里是否有活动可以领取
function QActivity:checkIsThemeComplete(themeId)
	local activityList = self:getActivityByTheme(themeId)
	-- QPrintTable(activityList)
	for _,value in pairs(activityList) do
		if value.type == QActivity.TYPE_ACTIVITY_FOR_CARD then
			local monthCard = self:checkMonthCardReady()
			if monthCard == true then
				print("--------QActivity.TYPE_ACTIVITY_FOR_CARD--------")
				return true
			end
		end	
		if value.type == QActivity.TYPE_MONTHFUND then
			local monthFund = remote.activityMonthFund:checkRedTips(value.activityId)
			if monthFund == true then
				print("--------QActivity.TYPE_MONTHFUND--------")
				return true
			end
		end	
		if value.type == QActivity.VIP_GIFT_DAILY then
			if remote.activityVipGift:checkDailyRedTips() then
				print("--------QActivity.VIP_GIFT_DAILY--------")
				return true
			end
		end
		if value.type == QActivity.VIP_GIFT_WEEK then
			if remote.activityVipGift:checkWeekRedTips() then
				print("--------QActivity.VIP_GIFT_WEEK--------")
				return true
			end
		end
		if value.type == QActivity.TYPE_VIP_INHERIT then
			if not remote.user.warmBloodVipGet then
				print("--------QActivity.TYPE_VIP_INHERIT--------")
				return true
			end
		end
		if value.type == QActivity.TYPE_CRYSTAL_SHOP then
			if remote.crystal:checkCrystalRedtips() then
				print("--------QActivity.TYPE_CRYSTAL_SHOP--------")
				return true
			end
		end

		if value.type == QActivity.TYPE_ACTIVITY_FOR_REPEATPAY then
			if self:checkIsSixRepeatPayActivity(value) and self:checkIsSixRepeatPayComplete(value) then
				print("--------QActivity.TYPE_ACTIVITY_FOR_REPEATPAY--------")
				return true
			end
		end

		if themeId == QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
			local curTime = q.serverTime() * 1000
			local startTime = value.start_at
			if curTime >= startTime then
				-- 已經開啟
				if not self:isActivityClicked(value) then
				print("--------QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1--------1")
					return true
				end
				
				if value.isPageMainmenuComplete and not self:checkIsSixRepeatPayActivity(value) then
				print("--------QActivity.THEME_ACTIVITY_RAT_FESTIVAL_1--------2")
					return true
				end
			end
		elseif themeId == QActivity.THEME_ACTIVITY_QIANSHITANGSAN then
			if not self:isActivityClicked(value) then
				print("themeId == QActivity.THEME_ACTIVITY_QIANSHITANGSAN ===1")
				return true
			end	

			if self:checkActivityCanGetAward(value) then
				print("themeId == QActivity.THEME_ACTIVITY_QIANSHITANGSAN ===2")
				return true
			end
		elseif themeId == QActivity.THEME_ACTIVITY_MAZE_EXPLORE then
			local mazeExploreProxy = remote.activityRounds:getMazeExplore()
			if mazeExploreProxy then
				return mazeExploreProxy:checkRedTips()
			end

			return false

		elseif themeId == QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE or themeId == QActivity.THEME_ACTIVITY_NEW_SERVER_RECHARGE_SKINS then
			if not self:isActivityClicked(value , true) then
				print("themeId == "..themeId.."===1")
				return true
			end	

			local atyProxy = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
			if atyProxy then
				return atyProxy:checkRedTips(themeId)
			end

			return false
		elseif themeId == QActivity.THEME_ACTIVITY_CUSTOM_SHOP then

			local atyProxy = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)
			if atyProxy then
				return atyProxy:checkRedTips()
			end

			return false			
		else
			if not self:isActivityClicked(value) then
				print("themeId == OTHER ===2")
				return true
			end
			
			if value.isPageMainmenuComplete and not self:checkIsSixRepeatPayActivity(value) then
				print("themeId == OTHER ===2")
				return true
			end
		end

		if value.type == QActivity.TYPE_PSEUDO_ACTIVITY then
			local dataProxy = self:getDataProxyByActivityId(value.activityId)
			if dataProxy and dataProxy.getBtnTips then
				return dataProxy:getBtnTips(value)
			end
		end
	end
	return false
end
-- 是否是6元豪华签到
function QActivity:checkIsSixRepeatPayActivity( info )
	if info == nil then return false end
	local targets = info.targets or {}
	if next(targets) == nil then return false end
	if info.type ~= QActivity.TYPE_ACTIVITY_FOR_REPEATPAY then return false end --不是连冲活动返回flase
	local isSixValueRepay = true
	for _, target in ipairs(targets) do
		if target.value2 ~= 6 and (target.value2 ~= 0 and target.value2 ~= nil) then 
			isSixValueRepay = false
			break
		end
	end	

	return isSixValueRepay
end
-- 检查豪华签到状态
function QActivity:checkIsSixRepeatPayComplete(info)
	if info == nil then return false end
	local targets = info.targets or {}
	if next(targets) == nil then return false end

	local isClicked = app:getUserOperateRecord():isActivityClicked(info.activityId)

	if isClicked then
		local todayTargetId = remote.activity:getDayChargeByAcitivityId(info.activityId)

		local autoisActivity = remote.crystal:checkTodayIsActivity()
		local newRecharge = remote.crystal:getNewTurnAutoPay()

		local completeTable = {}
		if autoisActivity and not newRecharge then
			for _, target in ipairs(targets) do
				if target.completeNum == 3 or target.completeNum == 2  and target.index ~= 6 and todayTargetId ~= target.activityTargetId then
					table.insert(completeTable,target)
				end
			end
			table.sort( completeTable, function(a,b)
				return a.index > b.index
			end )
			if next(completeTable) ~= nil then
				todayTargetId = completeTable[1].activityTargetId
			end
		end

		local targetInfo = {}
		for _, v in ipairs(targets) do
			if v.activityTargetId == todayTargetId then
				targetInfo = v
				break
			end
		end

		if targetInfo.completeNum ~= 2 or remote.activity:checkCompleteByTargetId(targetInfo) then
			return false 
		else
			if remote.activity:checkIsActivityAward(info.activityId) == false then
				return false
			end
			return true
		end
	else
		return true
	end
end

function QActivity:checkActivityCanGetAward( info )
	if info == nil then return false end
	local targets = info.targets or {}
	if next(targets) == nil then return false end
	local activityId = info.activityId
	for i,target in ipairs(targets) do
		if target.type ~= remote.activity.ACTIVITY_TARGET_TYPE.USE_TO_SHOW_AWARD then --排除展示用的类型
			local progressData = remote.activity:getActivityTargetProgressDataById(activityId, target.activityTargetId)
			if tonumber(progressData.completeCount or 0) > tonumber(progressData.awardCount or 0) then
				-- QPrintTable(progressData)
				return true
			end
		end
	end
	return false
end


--检查双月卡是否激活状态  cardNum 单个月卡激活状态
function QActivity:checkMonthCardActive(cardNum)
	if cardNum then
		if cardNum == 1 and remote.recharge.monthCard1EndTime then
			local remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/DAY
			return remainingDays > 0
		elseif cardNum == 2 and remote.recharge.monthCard2EndTime then
			local remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/DAY
			return remainingDays > 0
		end
	else
		if not remote.recharge.monthCard1EndTime or not remote.recharge.monthCard2EndTime then
			return false
		end
		local remainingDays1 = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/DAY
	    local remainingDays2 = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/DAY
	    local isActiveMonthCard = (remainingDays1 > 0 and remainingDays2 > 0)
	    return isActiveMonthCard
	end
end

--检查月卡奖励是否领取
function QActivity:checkMonthCardReady()

	if remote.task:checkTaskisDone("200001") then
		return true
	end

	if remote.task:checkTaskisDone("200002")  then
		return true
	end

	local makeUpInfo = remote.user.monthCardSupplementResponse
	if not q.isEmpty(makeUpInfo) then
		if makeUpInfo.monthCard1 and makeUpInfo.monthCard1 > 0 then
			return true
		end
		if makeUpInfo.monthCard2 and makeUpInfo.monthCard2 > 0 then
			return true
		end
	end

	return false
end

function QActivity:checkActivityIsInDays(beginDay, durationDay, beginHour, _bMergeTime)
	local server_time = remote.user.openServerTime 
	if _bMergeTime then
		server_time = remote.user.serverMergeAt
	end

	if server_time ~= nil and server_time > 0 then
	    local creatDate = q.date("*t", (server_time or 0) /1000)
	    creatDate.hour = beginHour or 0
	    creatDate.min = 0
	    creatDate.sec = 0

	    local beginTime = q.OSTime(creatDate) + beginDay * DAY
	    local endTime = beginTime + durationDay * DAY
	    local nowTime = q.serverTime()

	    -- print("endTime nowTime beginTime ", (endTime - nowTime)/DAY)
		if nowTime < endTime and beginTime < nowTime then
			return true
		end

		return false
	end
	return true
end


--8-14日活动开启时间
function QActivity:checkActivitySeven2Open(  )
	-- body
	return not self.is8To14DayActivityOpen  --q.OSTime({year=2016, month = 6, day = 30,hour = 0,min = 0, sec = 0}) - remote.user.openServerTime/1000 > 7*24*60*60
end

--是否有七日活动指定天数可以领取
function QActivity:checkActivitySevenDayIsComplete(day)
	for _,value in ipairs(self.activities) do
		if (value.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN or value.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2) then 
			if value.day == day and value.isHaveComplete == true then
				return true
			end
		end

	end
	return false
end

--是否有七日活动指定天数指定栏目可以领取
function QActivity:checkActivitySevenDayMenuIsComplete(day, number)
	for _,value in ipairs(self.activities) do
		if (value.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN or value.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2) then
			if value.isHaveComplete == true and value.day == day and value.number == number then 
				return true
			end
		end
	end
	return false
end

function QActivity:getActivitySevenUnlockDay(activityType)
    local startIndex = 1
	local tbl = {}
	tbl[activityType] = 1
    if activityType == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 then
    	startIndex = 8
	end
    local data = self:getActivityData(tbl)
	local getActivityByDay = function(day)
		local daysValue = {}
		for _, value in pairs(data) do
			local index = string.split(value.params, ",")
			if tonumber(index[1]) ~= nil and tonumber(index[1]) == day then
				table.insert(daysValue, value)
			end
		end
		return daysValue
	end

    local currTime = q.serverTime() * 1000
	local unlockDay = 1
    for i = startIndex, startIndex + 6 do
    	local values = getActivityByDay(i)
		if values ~= nil and #values > 0 and currTime >= values[1].start_at and currTime <= values[1].award_end_at then
			unlockDay = i
		end
    end

    return unlockDay
end

function QActivity:checkActivitySevenAwrdsTip(activityType)
	local jifenAwardsTbl = {}
	local scoreInfo = db:getStaticByName("activity_carnival_new_reward") or {}
	for _,value in pairs(scoreInfo) do
		if value.type == activityType then
			table.insert(jifenAwardsTbl,value)			
		end
	end
	local currentScore = remote.user.calnivalPoints or 0
	local recivedcommonAwards = remote.user.gotCommonCalnivalPrizeIds or {}
	local recivedSpecialAwards = remote.user.gotSpecialCalnivalPrizeIds or {}
	local isShowLock = remote.user.calnivalPrizeIsActive or false
	if activityType == 2 then
		currentScore = remote.user.celebration_points or 0
		recivedcommonAwards = remote.user.gotCommonCelebrationPrizeIds or {}
		recivedSpecialAwards = remote.user.gotSpecialCelebrationPrizeIds or {}
		isShowLock = remote.user.celebrationPrizeIsActive or false
	end

	local checkCommonReward = function(index)
		for _, value in pairs(recivedcommonAwards) do
			if value == index then
				return true
			end
		end
		return false
	end

	local checkSpecialReward = function(index)
		for _, value in pairs(recivedSpecialAwards) do
			if value == index then
				return true
			end
		end
		return false
	end

	for _,v in pairs(jifenAwardsTbl) do
		if currentScore >= v.condition and ( not checkCommonReward(v.id)  or (not checkSpecialReward(v.id) and isShowLock )) then
			return true
		end
	end

	return false
end


function QActivity:getEntryRewardConfig(entryType)
	local config ={}
	for _,value_data in ipairs(self.activities) do
		if value_data.type == entryType then
			for i,target in ipairs(value_data.targets) do
				local data_ ={}
				data_.activityTargetId =  target.activityTargetId
				data_.value = target.value
				data_.type = entryType
				data_.awards = target.awards
				data_.activityId = target.activityId
				data_.awardseffect = target.effectItemIdList
				data_.index = target.index
				data_.repeatCount = target.repeatCount
				table.insert(config, data_)
			end
		end
	end

	return config	
end

function QActivity:checkSevenEntryAllCompleteNew( entryType)
	local config = self:getEntryRewardConfig(entryType) or {}
	local isGetLocalAwards = false
	if q.isEmpty(config) then
		return false
	end
	local checkFunc = function(targetInfo)
		if isGetLocalAwards then
			local recivedAwards = remote.user.gotEnterRewards or {} --判断领取记录，老版七日登陆必须奖励领完主界面按钮才消失
			for _, value in pairs(recivedAwards) do
				if value == targetInfo.activityTargetId then
					return true
				end
			end
			return false
		else
			return remote.activity:checkCompleteByTargetId(targetInfo)
		end
	end

	for i, entryDay in pairs(config) do
		local isGet = checkFunc(entryDay)
		if not isGet then
			return true
		end
	end

	return false
end

function QActivity:checkSevenEntryAllComplete(entryType)
	local recivedAwards = remote.user.gotEnterRewards or {}
	local loginDaysCount = remote.user.loginDaysCount or 0

	local checkFunc
	checkFunc = function(targetId)
		for _, value in pairs(recivedAwards) do
			if value == targetId then
				return true
			end
		end
		return false
	end

	if entryType == QActivity.TYPE_SEVEN_ENTRY1 then
		local entryDaysConfig1 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY1)
		--local entryDaysConfig2 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY2)
		for i, entryDay in pairs(entryDaysConfig1) do
			if checkFunc(entryDay.activityTargetId) == false then
				return true
			end
		end
		-- for i, entryDay in pairs(entryDaysConfig2) do
		-- 	if checkFunc(entryDay.activityTargetId) == false then
		-- 		return true
		-- 	end
		-- end
	elseif entryType == QActivity.TYPE_FOURTEEN_ENTRY1 and loginDaysCount >= 7 then
		local entryDaysConfig1 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_FOURTEEN_ENTRY1)
		--local entryDaysConfig2 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_FOURTEEN_ENTRY2)
		for i, entryDay in pairs(entryDaysConfig1) do
			if checkFunc(entryDay.activityTargetId) == false then
				return true
			end
		end
		-- for i, entryDay in pairs(entryDaysConfig2) do
		-- 	if checkFunc(entryDay.activityTargetId) == false then
		-- 		return true
		-- 	end
		-- end
	end
	return false
end

function QActivity:checkSevenEntryPageMainViewIcon(entryType)
	local recivedAwards = remote.user.gotEnterRewards or {}
	local loginDaysCount = remote.user.loginDaysCount or 0

	-- local checkFunc
	-- checkFunc = function(targetId)
	-- 	for _, value in pairs(recivedAwards) do
	-- 		if value == targetId then
	-- 			return true
	-- 		end
	-- 	end
	-- 	return false
	-- end
	local checkFunc = function(targetInfo)
		return remote.activity:checkCompleteByTargetId(targetInfo)
	end

	local entryDaysConfig1 = self:getEntryRewardConfig(entryType) or {}
	if entryType == QActivity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW then
		-- local entryDaysConfig1 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY1)
		
		table.sort( entryDaysConfig1, function(a,b)
			return a.value < b.value
		end )
		local dayMark = {2,5}
		for i, entryDay in pairs(entryDaysConfig1) do
			for _,v in ipairs(dayMark) do
				if loginDaysCount < v then
					if checkFunc(entryDay) == false then
						return true,false,v
					else
						return true,true,v
					end
				else
					if checkFunc(entryDay) == false then 
						if entryDay.value <= loginDaysCount and entryDay.value == v then --第二天胡列娜未领取，主界面一直显示胡列娜icon
							return true , false,v
						end
					end
				end
			end

			-- if loginDaysCount < 2 then
			-- 	if checkFunc(entryDay) == false then
			-- 		return true,false,2
			-- 	else
			-- 		return true,true,2
			-- 	end
			-- else
			-- 	if checkFunc(entryDay) == false then 
			-- 		if entryDay.value <= loginDaysCount and entryDay.value == 2 then --第二天胡列娜未领取，主界面一直显示胡列娜icon
			-- 			return true , false,2
			-- 		elseif entryDay.value <= loginDaysCount and entryDay.value == 5 then
			-- 			return true , false ,5
			-- 		end
			-- 	end
			-- end
		end
	end	

	return false,false , 7
end

function QActivity:checkActivitySevenEntryAwrdsTip(entryType)
	local recivedAwards = remote.user.gotEnterRewards or {}
	local loginDaysCount = remote.user.loginDaysCount or 0

	-- local checkFunc
	-- checkFunc = function(targetId)
	-- 	for _, value in pairs(recivedAwards) do
	-- 		if value == targetId then
	-- 			return true
	-- 		end
	-- 	end
	-- 	return false
	-- end
	local checkFunc = function(targetInfo)
		return remote.activity:checkCompleteByTargetId(targetInfo)
	end
	local entryDaysConfig1 = self:getEntryRewardConfig(entryType) or {}
	if entryType == QActivity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW then
		-- local entryDaysConfig1 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_SEVEN_ENTRY1)
		for i, entryDay in pairs(entryDaysConfig1) do
			if loginDaysCount >= entryDay.value and checkFunc(entryDay) == false then
				return true
			end
		end
	elseif entryType == QActivity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW then
		-- local entryDaysConfig1 = QStaticDatabase:sharedDatabase():getEntryRewardConfig(QActivity.TYPE_FOURTEEN_ENTRY1)
		for i, entryDay in pairs(entryDaysConfig1) do
			if loginDaysCount >= entryDay.value and checkFunc(entryDay) == false then
				return true
			end
		end
	end
	return false
end

--加载本地活动配置
function QActivity:loadLocalActivity()
	local isSevenDay = self:checkActivityIsInDays(0, QActivity.TIME1)
	local isin30Day = self:checkActivityIsInDays(0, QActivity.TIME5)
	local time = 0
	local currTime = q.serverTime() * 1000
	if remote.user.openServerTime ~= nil and remote.user.openServerTime > 0 then
	    local creatDate = q.date("*t", remote.user.openServerTime/1000)
	    creatDate.hour = 0
	    creatDate.min = 0
	    creatDate.sec = 0
	    time = q.OSTime(creatDate)
	end
	local activities = QStaticDatabase:sharedDatabase():getActivities()
	local targets = QStaticDatabase:sharedDatabase():getActivityTarget()
	local cloneActivity = {}
	for _, activity in pairs(activities) do
		activity = q.cloneShrinkedObject(activity)
		if activity.type == QActivity.TYPE_ACTIVITY_FOR_FUND and not isin30Day then --开服基金
			activity.weight = nil
		end
		if not(activity.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN and isSevenDay == false) and activity.type ~= QActivity.TYPE_ACTIVITY_SUPER_MONDAY then
			if activity.permanent ~= true then
				local day = string.split(tostring(activity.params), ",")[1]
				day = tonumber(day)
				if activity.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN then --七日活动
					activity.award_at = remote.user.openServerTime + (day-1) * DAY * 1000
					activity.award_end_at = (time + QActivity.TIME1 * DAY) * 1000
					activity.start_at = remote.user.openServerTime + (day-1) * DAY * 1000
					activity.end_at = (time + QActivity.TIME2 * DAY) * 1000
				elseif activity.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2 then
					activity.award_at = remote.user.openServerTime + (day-1) * DAY * 1000
					activity.award_end_at = (time + (QActivity.TIME1 + 7) * DAY) * 1000
					activity.start_at = remote.user.openServerTime + (day-1) * DAY * 1000
					activity.end_at = (time + (QActivity.TIME2 + 7) * DAY) * 1000
				elseif activity.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE or activity.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_GIFT then --热血服等级竞赛
					activity.award_at = time * 1000
					activity.award_end_at = (time + day * DAY) * 1000
					activity.start_at = time * 1000
					activity.end_at = (time + day * DAY) * 1000
				elseif activity.type == QActivity.TYPE_ACTIVITY_FOR_FORCE then --开服竞赛
					activity.award_at = remote.user.openServerTime
					activity.award_end_at = (time + (remote.user.activityForceCalculateDay or QActivity.TIME3) * DAY) * 1000
					activity.start_at = remote.user.openServerTime
					activity.end_at = (time + (remote.user.activityForceCalculateDay or QActivity.TIME3) * DAY) * 1000
				elseif activity.type == QActivity.TYPE_ACTIVITY_FOR_RATE then-- 倍率活动
					local startAt, endAt = remote.calendar:getCalendarStartTime(activity.params)
					local day14 = remote.user.openServerTime + (day-1) * DAY * 1000
					-- 大于开服14天
					if startAt <= day14 then
						startAt = q.serverTime() + 2*DAY * 1000
						endAt = startAt + (DAY - 1) * 1000 
					end
					activity.start_at = startAt
					activity.end_at = endAt
					activity.award_at = activity.start_at
					activity.award_end_at = activity.end_at
				else
					if activity.start_at then
						activity.start_at = remote.user.openServerTime + (activity.start_at - 1) * DAY * 1000
					else
						activity.start_at = remote.user.openServerTime
					end

					if activity.end_at then
						activity.end_at = time*1000 + activity.end_at * DAY * 1000
					end

					if activity.award_at then
						activity.award_at = remote.user.openServerTime + (activity.award_at - 1) * DAY * 1000
					else
						activity.award_at = remote.user.openServerTime
					end
					if activity.award_end_at then
						activity.award_end_at = time*1000 + activity.award_end_at * DAY * 1000
					end
				end
			end
			local canAdd = false
			if activity.permanent == true then
				canAdd = true
			else
				if activity.end_at then 
					if currTime > activity.end_at then
						if activity.award_end_at and activity.award_end_at > currTime then
							canAdd = true
						else
							canAdd = false
						end
					else
						canAdd = true
					end
				else
					canAdd = true
				end
			end
			-- 热血服
			if activity.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE or activity.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_GIFT then --热血服等级竞赛
				if not remote.user.isWarmBloodServer then
					canAdd = false
				end
			end

			if canAdd then
				activity.targets = {}
				for _, target in pairs(targets) do
					if target.activityId == activity.activityId then
						target = q.cloneShrinkedObject(target)
						if not target.repeatCount then
							target.repeatCount = 1
						end
						table.insert(activity.targets, target)
					end
				end
				activity.isLocal = true --是否本地配置活动
				if not self._dataProxy[activity.activityId] then
					table.insert(cloneActivity, activity)
				end
			end
		end
		if self._dataProxy[activity.activityId] then
			if #self._dataProxy[activity.activityId].activity > 0 then
				table.insert(cloneActivity, self._dataProxy[activity.activityId].activity)
			end
		end
	end
	self:setData(cloneActivity)
end

--记录返回的精彩活动信息
function QActivity:setData(data)
	for _, activity in pairs(data) do
		if self._progressData[activity.activityId] == nil then
			self._progressData[activity.activityId] = {}
		end
		if activity.targets ~= nil then
			for _,target in pairs(activity.targets) do
				if self._progressData[activity.activityId][target.activityTargetId] == nil then
					self._progressData[activity.activityId][target.activityTargetId] = {complete = false, progress = 0, completeCount = 0, awardCount = 0, param1 = 0}
				end
			end
		end
		if activity.records ~= nil then
			for _,record in pairs(activity.records) do
				local completeCount = record.completeCount or 0
				local awardCount = record.awardCount or 0
				self._progressData[activity.activityId][record.activityTargetId] = {complete = false, completeCount = completeCount, awardCount = awardCount, progress = record.complete_progress, param1 = record.param1}
			end
		end

		local isFind = false
		for index,value in ipairs(self.activities) do
			if value.activityId == activity.activityId then  --是否本地配置活动
				if value.isLocal ~= true then
					for key,child in pairs(activity) do
						value[key] = child
					end
				end
				isFind = true
			end
		end
		
		if isFind == false then
			table.insert(self.activities, activity)
		end
	end
	self:refreshActivity()
end

function QActivity:updateactivityMonthFund( activity , isForce)
	local isFind = false
	for index,value in ipairs(self.activities) do
		if value.activityId == "a_monthfund" then  --是否本地配置活动
			if activity then
				self.activities[index] = activity
			else
				table.remove(self.activities, index)
			end
			isFind = true
			break
		end
	end
	if isFind == false and activity then
		table.insert(self.activities, activity)
	end
	self:refreshActivity(isForce)
end

function QActivity:refreshActivity( isForce)
	self:updateAchievesForList()
	self:dispatchEvent({name = QActivity.EVENT_UPDATE, data = self.activities, isForce = isForce})
end
--删除指定的活动
function QActivity:removeActivity(activityIds)
	if type(activityIds) ~= "table" then
		for index, activity in ipairs(self.activities) do
			if activity.activityId == activityIds then
				print("remove activity ", activityIds)
				table.remove(self.activities, index)
				break
			end
		end
	else
		if q.isEmpty(activityIds) then return end
		for _, activityId in ipairs(activityIds) do
			for index, activity in ipairs(self.activities) do
				if activity.activityId == activityId then
					table.remove(self.activities, index)
					break
				end
			end
		end
	end
	self:dispatchEvent({name = QActivity.EVENT_UPDATE, data = self.activities})
end

--设置半价抢购的活动进度
function QActivity:setHalfActivity(data)
	self.activityTargetRecordTotalStatus = data
end

--获取半价抢购的活动进度
function QActivity:getHalfActivity(id)
	if self.activityTargetRecordTotalStatus == nil then return 0 end
	for _,value in pairs(self.activityTargetRecordTotalStatus) do
		if value.key == id then
			return value.value
		end
	end
	return 0
end

--半价抢购的活动进度加1
function QActivity:addHalfActivity(id)
	if self.activityTargetRecordTotalStatus == nil then return 0 end
	for _,value in pairs(self.activityTargetRecordTotalStatus) do
		if value.key == id then
			value.value = value.value + 1
			break
		end
	end
	self:dispatchEvent({name = QActivity.EVENT_UPDATE, data = self.activities})
end

--设置其他类型的数据
function QActivity:setOtherData(type, data)
	self._activityOtherData[type] = data 
	self:dispatchEvent({name = QActivity.EVENT_OTHER_CHANGE})
end

--获取其他类型的数据
function QActivity:getOtherData(type)
	return self._activityOtherData[type]
end

--设置已经完成的活动
function QActivity:setCompleteDataById(activityId, targetId, count)
	if not activityId or not targetId then
		return
	end
	if count == nil then count = 1 end

	local data = self._progressData[activityId][targetId]
	local  target 
	for k, v in ipairs(self.activities) do
		if v.activityId == activityId then
			if v.targets then
				local isBreak = false
				for _, t in pairs(v.targets) do
					if targetId == t.activityTargetId then
						target = t
						isBreak = true
						break
					end
				end
				if isBreak then
					break
				end
			end
			
		end
	end
	if target then
		if not target.repeatCount then
			target.repeatCount = 1
		end
		if not data.awardCount then
			data.awardCount = 0
		end
		
		if target.repeatCount > data.awardCount then
			data.awardCount = data.awardCount + count
			if data.awardCount >= target.repeatCount then
				data.complete = true
			end
			self:shortData()

			self:dispatchEvent({name = QActivity.EVENT_COMPLETE_UPDATE, data = self.activities})
		end
	end
	
end

--检查该ID是否在活动期间内
function QActivity:checkIsActivityAward(activityId)
	for index,value in ipairs(self.activities) do
		if value.targets ~= nil and table.nums(value.targets) > 0 then
			if value.activityId == activityId then
				if value.permanent == true then
					return true
				end
				if q.serverTime() > ((value.award_end_at or 0)/1000) then
					self:shortData()
					self:dispatchEvent({name = QActivity.EVENT_UPDATE, data = self.activities})
					return false
				else
					return true
				end
			end
		end
	end
	return false
end

--检查该ID是否在活动期间内
function QActivity:checkIsActivity(activityId)
	for index,value in ipairs(self.activities) do
		if value.targets ~= nil and table.nums(value.targets) > 0 then
			if value.activityId == activityId then
				if value.permanent == true then
					return true
				end
				if q.serverTime() > ((value.end_at or 0)/1000) then
					return false
				else
					return true
				end
			end
		end
	end
end

--检查该ID是否已经完成
function QActivity:checkCompleteByTargetId(target)
	-- printTable(self.activities)
	-- print("--s-a--awwww11",activityId,targetId,self.activities[activityId])
	-- printTable(self.activities[activityId])
	local progressData = self._progressData[target.activityId][target.activityTargetId]
	if not target.repeatCount then
		target.repeatCount  = 1
	end
	if not progressData.awardCount then
		progressData.completeCount = 0
	end
	if progressData.awardCount >= target.repeatCount then
		progressData.complete = true
		return true
	end

	return false
end

-- 检测活动是否翻倍
function QActivity:getActivityMultipleYield(activityType)
	if not activityType then
		return 1
	end
	local multiple = 100
	for _, activity in ipairs(self.activities) do
		if activity.type == QActivity.TYPE_ACTIVITY_FOR_RATE and activity.targets and next(activity.targets) then
			local rateActivityType = activity.targets[1].type or 0
			if rateActivityType == activityType and activity.start_at and activity.end_at then
				local curTime = q.serverTime()*1000
				if activity.start_at <= curTime and curTime < activity.end_at then
					multiple = activity.value or 100
					break
				end
			end
		end
	end
	return multiple/100
end

function QActivity:getActivityDataByTagetId(typeName)
	local currentTime = q.serverTime()
	for _,activity in ipairs(self.activities) do
		--检查是否在活动期间内
		local isActivity = false 
		if activity.permanent == true then
			isActivity = true
		else
			local startTime = (activity.start_at or 0)/1000
			local endTime = (activity.end_at or 0)/1000
			if activity.start_at == nil and activity.end_at == nil then
				isActivity = true
			end
			if currentTime >= startTime and currentTime <= endTime then
				isActivity = true
			end
		end		
		if isActivity == true then
			for _,target in ipairs(activity.targets) do
				if target.type == typeName then
					return activity
				end
			end
		end
	end

	return nil
end
--[[
	更新进度数据
]]
function QActivity:updateLocalDataByType(typeName, value, operator)
	if operator == nil then operator = "+" end
	local currentTime = q.serverTime()
	for _,activity in ipairs(self.activities) do
		--检查是否在活动期间内
		local isActivity = false 
		if activity.permanent == true then
			isActivity = true
		else
			local startTime = (activity.start_at or 0)/1000
			local endTime = (activity.end_at or 0)/1000
			if activity.start_at == nil and activity.end_at == nil then
				isActivity = true
			end
			if currentTime >= startTime and currentTime <= endTime then
				isActivity = true
			end
		end
		if isActivity == true then
			for _,target in ipairs(activity.targets) do
				if target.type == typeName then
					local activityId = target.activityId
					local targetId = target.activityTargetId
					if self._progressData[activityId][targetId] == nil then
						self._progressData[activityId][targetId] = {}
					end
					local data = self._progressData[activityId][targetId]
					if type(value) == "number" then
						if data.progress == nil then
							data.progress = value
						else
							if operator == "+" then
								data.progress = data.progress + value
							elseif operator == "=" then
								data.progress = value
							end
						end
					elseif type(value) == "table" then
						if typeName == 711 or typeName == 712 or typeName == 713 or typeName == 714 then
							for k, v in pairs(value) do
								if tonumber(target.value2) == tonumber(k) and v > data.progress then
									data.progress = v
								end
							end
						elseif typeName == self.TYPE_ACTIVITY_TARGET_ITEM then
							for k, v in pairs(value) do
								if tonumber(target.value2) == tonumber(k) then
									if data.progress == nil then
										data.progress = tonumber(v)
									else
										if operator == "+" then
											data.progress = data.progress + tonumber(v)
										elseif operator == "=" then
											data.progress = tonumber(v)
										end
									end
								end
							end
						else
							for k, v in pairs(value) do
								if tonumber(target.value2) == tonumber(k) then
									data.progress = data.progress + v
								end
							end
						end
					end
				end
			end
		end
	end
	self:shortData()
	self:dispatchEvent({name = QActivity.EVENT_UPDATE, data = self.activities})
end

--记录充值类 活动记录
function QActivity:updateRechargeData( value,type,itemId,rechargeDataId)
	QLogFile:info(function ( ... )
            return string.format("updateRechargeData value: %d. #self._rechargeRecords %d", value, #self._rechargeRecords)
        end)
	self:updateRechargeProgressData(math.floor(value),type,itemId,rechargeDataId)

	--铸造活动更新
	local forgeUpdateFunc = function()
		local forgeActivity = remote.activityRounds:getForge()
		if forgeActivity and forgeActivity:getMyForgeInfo().activeState == 2 then
			forgeActivity:requestMyForge(function(data)
				self:refreshActivity()
			end)
		else
			self:refreshActivity()
		end
	end

	--魂师手札活动更新
	local soulLetterUpdateFunc = function()
		local soulLetterActivity = remote.activityRounds:getSoulLetter()
		if soulLetterActivity and (soulLetterActivity:getActivityInfo().type ~= 4 or soulLetterActivity:getActivityInfo().buyState ~= 2) then
			soulLetterActivity:requestActivityInfo(true, function(data)
				forgeUpdateFunc()
			end)
		else
			forgeUpdateFunc()
		end
	end

	--月基金状态
	remote.activityMonthFund:updateMonthFundStatus(value)
	remote.activityMonthFund:getActivityInfo(function()
		soulLetterUpdateFunc()
	end)

	print("type=rechargeDataId=",type,rechargeDataId)
	if type == 4 and itemId then --等级礼包充值成功
		remote.gradePackage:updateRechargeData(math.floor(value),itemId)
	elseif type == 5 then --每日礼包充值成功(和许瑞、陈昊伟确定，道具充值不激活) 
		remote.crystal:updateRechargeData(math.floor(value))
	elseif type == 7 then --嘉年华跟半月庆典特权激活本地更新
		local products = db:getRecharge()
		for _, product in ipairs(products) do
            if product.ID == rechargeDataId and product["recharge_buy_productid"] == "128_1"  then
                remote.user.calnivalPrizeIsActive = true --嘉年华充值是否激活 
                break
            elseif product.ID == rechargeDataId and product["recharge_buy_productid"] == "128_2" then
                remote.user.celebrationPrizeIsActive = true --半月庆典充值是否激活
                break
            end
        end

        self:dispatchEvent({name = QActivity.EVENT_128RECHARGE_UPDATE})
    elseif type == QActivity.RECHARGE_TYPE.NEW_SERVER_RECHARGE then 
    	local svr = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
    	if svr then
    		svr:newServerRechargeGetMainInfoRequest()
    	end
    elseif type == QActivity.RECHARGE_TYPE.CUSTOM_SHOP_RECHARGE then
    	print("订制商店直冲成功---")
    	local moduleProxy = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)
    	if moduleProxy then
    		moduleProxy:requestMyCustomInfo()
    	end
	end
end

--获取已经完成的数量
function QActivity:getActivityTargetStatusById(activityId,targetId)
	local data = self._progressData[activityId][targetId]
	return data.progress or 0
end

function QActivity:getActivityTargetProgressDataById(activityId,targetId)
	local data = self._progressData[activityId][targetId]
	return data or {}
end

--特殊处理每日充值活动
function QActivity:getDayChargeByAcitivityId(activityId)
	return self._dayRecharge[activityId]
end

--特殊处理每日充值活动
function QActivity:resetDayCharge()
	self._dayRecharge = {}
end

function QActivity:updateRechargeProgressData( rmb ,type, itemId ,rechargeDataId)
	local isOnlyLeiChong = false
	printInfo("~~~~~~ itemId == %s ~~~~~~", itemId)
	if itemId then 
		local config = db:getItemByID(itemId)
		if config and config.type == ITEM_CONFIG_TYPE.RECHARGE_LEICHONG then
			isOnlyLeiChong = true
		end
	end
	local changeType = 0
	for k,activity in pairs(self.activities) do
		for index,target in pairs(activity.targets) do
 			if target.type == 100 and type ~= 4 and type ~= 5 and 
 				type ~= QActivity.RECHARGE_TYPE.DIRECT_RECHARGE and type ~= QActivity.RECHARGE_TYPE.SEVEN_RECHARGE and not isOnlyLeiChong then
 				local data = self._progressData[target.activityId][target.activityTargetId] or {}
 				if rmb == target.value2 then
 					data.completeCount = (data.completeCount or 0) + 1
 				end
 			elseif target.type == 101 then
 				if target.activityId ~= "a2" or self:checkActivityIsInDays(0, QActivity.TIME2) then
	 				local data = self._progressData[target.activityId][target.activityTargetId] or {}
	 				data.progress = (data.progress or 0 )+ rmb
	 			end
 			elseif target.type == QActivity.ACTIVITY_TARGET_TYPE.FREE_RECHARGE_DALIY or target.type == QActivity.ACTIVITY_TARGET_TYPE.RECHARGE_PURCHASE then
				local rechargeConfig = remote.activity:getRechargeConfigByRechargeBuyProductId(target.value3)
				changeType = QActivity.EVENT_QIANSHITANGSAN_UPDATE
				if rechargeConfig and rechargeConfig.ID and rechargeDataId then
					if rechargeConfig.ID == rechargeDataId then
 						local data = self._progressData[target.activityId][target.activityTargetId] or {}
						data.completeCount = (data.completeCount or 0) + 1
						if data.completeCount > target.repeatCount then -- 做一个越界判断 若外围充值实际计数超过上限，服务端需要做边界检测
							data.completeCount = target.repeatCount
							
						end
					end
				end
 			end
		end
	end


	if changeType == QActivity.EVENT_QIANSHITANGSAN_UPDATE then
		print("name = QActivity.EVENT_QIANSHITANGSAN_UPDATE")
		self:dispatchEvent({name = QActivity.EVENT_QIANSHITANGSAN_UPDATE})
	end

end

--每日0点更新完成次数
function QActivity:updateDaliyData()
	for k,activity in pairs(self.activities) do
		for index,target in pairs(activity.targets) do
			if target.type == QActivity.TYPE_VERSION_CHANGE_LOGIN then
				target.haveNum = target.haveNum or 0
				target.value = target.value or 0
				target.haveNum = target.haveNum + 1
				if target.haveNum > target.value then
					target.haveNum = target.value
				end
 			end
		end
	end
end

--每日0点刷新任务本地缓存数据
function QActivity:resetDaliyData()
	for k,activity in pairs(self.activities) do
		for index,target in pairs(activity.targets) do
 			if target.type == QActivity.ACTIVITY_TARGET_TYPE.FREE_RECHARGE_DALIY or target.type == QActivity.ACTIVITY_TARGET_TYPE.FREE_GET_DALIY then
				local data = self._progressData[target.activityId][target.activityTargetId] or {}
				data.completeCount = 0
				data.awardCount = 0
				data.complete = false
 			end
		end
	end
	--渠道奖励每日0点刷新
	local newtable = {}
	for i,v in ipairs(self._channelAwardIds) do
		local config = self:getActivityTargetChannelConfigById(v)
		if config and config.refresh_type ~= QActivity.ACTIVITY_CHANNEL_REFRESH_TYPE.DALIY_REFRESH then -- 每日刷新的数据不保留
			table.insert(newtable , v)
		end
	end
	self._channelAwardIds = newtable

end

--获取平台活动的结束时间并返回是否在时间内	
function QActivity:getActivityChannelTimeDatById(channel_aty_id)
	local isInTime = false
	local  endTime = 0
	local config = self:getActivityTargetChannelConfigById(channel_aty_id)
	if config and config.month_activity_open_time and config.activity_continue_time_s then
		local curtime = q.serverTime()

        local beginDate = q.date("*t",curtime)
        beginDate.day = config.month_activity_open_time or 0
        beginDate.hour = 0
        beginDate.min = 0
        beginDate.sec = 0

        local beginTime = q.OSTime(beginDate)
        endTime = beginTime + tonumber(config.activity_continue_time_s or 0)
        if curtime >= beginTime and curtime < endTime then
        	isInTime = true
    	end
	end
	return isInTime , endTime
end

function QActivity:checkHaveChannelGameCenterAty()
	if FinalSDK.getChannelID() == "7" and self:checkGameCenterSDK(7) then
		return true
	elseif FinalSDK.getChannelID() == "8" and self:checkGameCenterSDK(8) then
		return true
	end

	return false
end


function QActivity:checkHaveYingyongbaoBafu()

	if remote.user.receivedCdk then return false , nil end
	local costNum = db:getConfigurationValue("yingyongbao_bafu_money") or 300
	local data = db:getVersionPostInfo()
	for _, value in pairs(data) do
		if value.is_yinyongbao == 1 then
			print(remote.user.newTotalRecharge)
			if remote.user.newTotalRecharge >= costNum 
				and value.channel 
				and tostring(value.channel) == FinalSDK.getChannelID() 
				then
				-- QPrintTable(value)
				return true , value
			end
		end
	end

	return false , nil
end


--检查是否满足游戏中心接入后的版本号
function QActivity:checkGameCenterSDK(channelId)
    local major = 9
    local minor = 9
    local revision = 9
    if channelId == 7 then
    	major = VIVO_GAMECENTER_ADAPTATION_VERSION.major
    	minor = VIVO_GAMECENTER_ADAPTATION_VERSION.minor
    	revision = VIVO_GAMECENTER_ADAPTATION_VERSION.revision    	
    elseif channelId == 8 then
    	major = OPPO_GAMECENTER_ADAPTATION_VERSION.major
    	minor = OPPO_GAMECENTER_ADAPTATION_VERSION.minor
    	revision = OPPO_GAMECENTER_ADAPTATION_VERSION.revision  
    end


    if app:isNativeLargerEqualThan(major, minor, revision)  then
  		return true
    end
	return false
end

function QActivity:checkGameCenterRedTip()
	local ids = {}
	if FinalSDK.getChannelID() == "7" and self:checkGameCenterSDK(7) then
		table.insert(ids ,QActivity.ACTIVITY_CHANNEL.GAME_CENTER_VIVO)
	elseif FinalSDK.getChannelID() == "8" and self:checkGameCenterSDK(8) then
		table.insert(ids ,QActivity.ACTIVITY_CHANNEL.GAME_CENTER_OPPO)
		local isCarnivalDay , endTime  =  remote.activity:getActivityChannelTimeDatById(QActivity.ACTIVITY_CHANNEL.CARNIVAL_DAY_OPPO)
		if isCarnivalDay then
			table.insert(ids ,QActivity.ACTIVITY_CHANNEL.CARNIVAL_DAY_OPPO)
		end
		if not self:checkChannelHasRealName(8) then
			table.insert(ids ,QActivity.ACTIVITY_CHANNEL.REAL_NAME_OPPO)
		end
	end

	for i,v in ipairs(ids) do
		local getten = remote.activity:checkGettenAwardByById(v)
		if not getten then 
			return true
		end
	end

	return false
end

--根据传入的id 判断该渠道是否实名制
function QActivity:checkChannelHasRealName(channelId)
	if channelId == 8 then
		return FinalSDK.getRealNameResult()
	end
	return true
end

function QActivity:getChannelGameCenterAtyName()
	if FinalSDK.getChannelID() == "7" then
		return "vivo特权"
	elseif FinalSDK.getChannelID() == "8"  then
		return "琥珀特权"
	end

	return "特权"
end


function QActivity:checkHaveWeeklyGameAty()
	return true
end


function QActivity:checkHaveWeeklyGameAtyRedTips()
	return true
end

----------------------------------------------------------------------------------------------------
---------------------------- 不依赖于 QActivity 中的数据 相关的方法 -------------------------------------
----------------------------------------------------------------------------------------------------
--[[
 *  活动类别
 *   1、充值类
 *      100 单笔充值类
 *      101 累计充值类
 *      102 每日充值类
 *   2、消耗类
 *      200 消耗钻石
 *      201 消耗金魂币
 *      202 其他道具消耗
 *   3、兑换类
 *      300 钻石兑换道具
 *      301 金魂币兑换道具
 *      302 道具兑换道具
 *   4、搜集类
 *      400 搜集一定的卡牌
 *      401 搜集一定的道具
 *   5、条件类
 *      500 战队等级条件
 *      501 vip等级条件
 *      502 登陆
 *      503 每日任务的完成数量
 *      504 点金手使用次数
 *      505 购买斗魂场次数
 *      506 购买体力次数
 *      507 购买普通抽将次数
 *      508 购买高级抽将次数
 *      509 拥有魂师的数量
 *      510 副本通关{1}章
 *      511 {0}个魂师突破到{1}
 *      512 {0}个魂师强化大师达{1}级
 *      513 斗魂场最高排名第{1}名 ：注意target value 设置1,value2 设置名次
 *      514 副本总星级达到{0}
 *      515 {0}件觉醒装备达到{1}级
 *      516 小队最高战力达到{0}
 *      517 拥有{0}个{1}星魂师
 *      518 全员战力值达到{0}
 *      519 激活魂师组合关系{0}个
 *      520 魂师大赛积分达到{0}
 *      521 购买基金人数达到{0}
 *      522 {0}个魂师的觉醒大师达到{1}级
 *      523 上阵魂师技能等级之和达到{0}级
 *      —— 2015-11-3 新增活动类型
 *      524 雷电王座关卡重置次数达到{0}次
 *      525 英灵商店购买次数达到{0}次
 *      526 英灵商店重置次数达到{0}次
 *      527 {0}个魂师的饰品突破品级到达{1}级
 *      528 {0}个魂师的饰品强化大师等级达到{1}级
 *      529 {0}个魂师的饰品觉醒等级达到{1}级
 *      530 要塞入侵排名达到{0}                                             // 未完成
 *      531 要塞入侵战斗了{0}次
 *      532 要塞入侵伤害达到{0}                                             // 未完成
 *      533 要塞入侵每日累计功勋达到{0}                                      // 未完成
 *      534 史诗副本通关到{0}                                               // 未完成
 *      535 荣誉之塔挑战次数{0}
 *      536 {0}个魂师的装备强化大师等级达到{1}
 *      537 {0}个魂师的装备觉醒等级达到{1}
 *      538 雷电王座历史最高星数达到{0}星
 *      539 要塞入侵征讨令购买次数达到{0}
 *      540 普通副本战斗胜利次数达到{0}次
 *      541 精英副本战斗胜利次数升级达到{0}次
 *      542 雷电王座战斗胜利次数达到{0}次
 *      543 斗魂场战斗胜利次数达到{0}次
 *      544 要塞入侵怪物击杀达到{0}个
 *      545 每日充值{0}元
 *      546 累计充值{0}元
 *      547 单笔充值{0}元
 *		548 太阳井战斗胜利次数达到了{0}次
 *      ////////////////////////////////////////
 *      549 百日活动登陆天数
 *      550 高级10连抽次数达到了{0}次
 *      551 豪华10连抽次数达到了{0}次
 *      552 魂师大赛战斗胜利次数达到了{0}次
 *      553 黑市刷新次数{0}：只计算使用钻石刷新的次数
 *      554 觉醒宝箱十连抽{0}：只计算十连的次数
 *      555 活动本累计胜利次数达到{0}：活动本累计胜利次数
 *      556 商城购买宝石宝箱{0}次
 *      557 暗器十连抽{0}次
 *      558 商城购买武魂真身宝箱{0}次
 *      559 商城购买晶石宝箱{0}次
 *      700 要塞入侵累计功勋
 *      703 发红包活动
 *      704 抢红包活动
 *      710 仙品宝箱10连抽次数 
 *      711 指定ss魂师神技升星数 
 *      712 指定ss暗器升星数 
 *      713 指定神器升星数 
 *		716 魂师派遣
 *		717 魂兽森林占领时间
 *		718 宗门副本战斗
 *   6、倍率性活动
 *      600 普通副本碎片掉落翻倍
 *      601 普通副本金魂币掉落翻倍
 *      602 精英副本碎片掉落翻倍
 *      603 精英副本金魂币掉落翻倍
 *      604 活动试炼进入次数翻倍
 *      605 活动试炼掉落翻倍
 *      606 斗魂场币翻倍
 *      607 雷电印记翻倍
 *      608 雷电王座宝箱产出翻倍
 *      609 太阳井币翻倍
 *      610 太阳井宝箱产出翻倍
 *      611 魂师大赛币翻倍
 *      612 魂师大赛宝箱产出翻倍
 *      613 酒馆高级召唤打折
 *      614 酒馆豪华召唤打折
 *   10、描述类
 *      1000 描述性活动
 *   11、充值回馈
 *      1101 充值回馈-宣传
 *      1102 充值回馈-领奖
 *   18、超级星期六活动
 *      705 累计登陆时间达到{0}秒
 *      706 周六登陆游戏
 *      707 周日登陆游戏
 *      708 斗魂场膜拜{0}次
 *      709 超级星期六大奖活动目标
]]

--注册处理函数
function QActivity:registerHandlerFun()
	self._handlerMap = {}
	self._handlerMap[100] =  handler(self, self.checkSingleRecharge) -- 100 单笔充值类
	self._handlerMap[102] =  handler(self, self.checkDayRecharge) -- 102 每日充值类

	self._handlerMap[400] = handler(self, self.checkCard) -- 400 搜集一定的卡牌 
	self._handlerMap[401] = handler(self, self.checkItemNum) -- 401 搜集一定的道具

	self._handlerMap[500] = handler(self, self.checkTeamLevel) -- 500 战队等级条件
	self._handlerMap[501] = handler(self, self.checkVip) -- 501 vip等级条件
	self._handlerMap[509] = handler(self, self.checkHeroCount) -- 509 拥有魂师的数量

	self._handlerMap[510] = handler(self, self.checkDungeonPass) -- 510 副本通关{0}章
	self._handlerMap[511] = handler(self, self.checkHeroBreakthroughCount) -- 511 {0}个魂师突破到{1}
	self._handlerMap[513] = handler(self, self.checkArenaTopRank) -- 513 斗魂场最高排名第{0}名
	self._handlerMap[514] = handler(self, self.checkInstanceTotalStar) -- 514 副本总星级达到{0}
	self._handlerMap[515] = handler(self, self.checkEquipmentEnchantCount) -- 515 {0}件觉醒装备达到{1}级
	self._handlerMap[516] = handler(self, self.checkTeamBattleForce) -- 516 小队最高战力达到{0}
	self._handlerMap[517] = handler(self, self.checkHeroGradeCount) -- 517 拥有{0}个{1}星魂师
	self._handlerMap[518] = handler(self, self.checkAllHeroBattleForce) -- 518 全员战力值达到{0}
	self._handlerMap[519] = handler(self, self.checkHeroCombinationCount) -- 519 激活魂师组合关系{0}个
	self._handlerMap[520] = handler(self, self.checkHonorScore) -- 520 魂师大赛积分达到{0}
	self._handlerMap[521] = handler(self, self.checkBuyFund) -- 521 购买基金人数达到{0}
	self._handlerMap[523] = handler(self, self.checkSkillLevel) -- 523 上阵魂师技能等级之和达到{0}级

	self._handlerMap[527] = handler(self, self.checkHeroAllJewelBreakthroughLevel) -- 527 {0}名魂师饰品突破等级达到{1}级
	self._handlerMap[528] = handler(self, self.checkHeroJewelMasterLevel) -- 528 {0}名魂师饰品大师达到{1}级
	self._handlerMap[529] = handler(self, self.checkHeroAllJewelEnchantLevel) -- 529 {0}名魂师饰品觉醒等级达到{1}级
	self._handlerMap[536] = handler(self, self.checkHeroEquipmentMasterLevel) -- 536 {0}名魂师装备大师等级达到{1}级
	self._handlerMap[537] = handler(self, self.checkHeroFourEquipmentEnchantLevel) -- 537 {0}名魂师4件装备觉醒星级达到{1}级

	self._handlerMap[538] = handler(self, self.checkThunderStarCount) -- 538 雷电王座星数{0}
	self._handlerMap[549] = handler(self, self.checkLoginCount) -- 549 百日登录

	self._handlerMap[719] = handler(self, self.checkVerChangeLogin) -- 719 版更登录

	--配置跳转链接
	self._linkMap = {}    --用来标记服务器传过来的target的跳转链接
	self._linkMap[540] = "12001"
	self._linkMap[541] = "13001"
	self._linkMap[524] = "34001"
	self._linkMap[538] = "34001"
	self._linkMap[542] = "34001"
	--竞技场
	self._linkMap[505] = "33001"
	self._linkMap[513] = "33001"
	self._linkMap[543] = "33001"
	--要塞入侵
	self._linkMap[530] = "37001"
	self._linkMap[531] = "37001"
	self._linkMap[532] = "37001"
	self._linkMap[533] = "37001"
	self._linkMap[539] = "37001"
	self._linkMap[544] = "37001"
	--太阳井
	self._linkMap[548] = "81002"
	--荣耀之塔
	self._linkMap[520] = "36001"
	self._linkMap[552] = "36001"
	self._linkMap[535] = "36001"
	--酒馆召唤
	self._linkMap[508] = "11001"
	self._linkMap[550] = "11001"
	self._linkMap[551] = "11001"
	--附魔宝箱
	self._linkMap[554] = "39001"
	--黑石刷新
	self._linkMap[553] = "81026"
	--购买宝石
	self._linkMap[556] = "81050"
	--暗器10连抽
	self._linkMap[557] = "52000"
	--购买武魂真身箱子
	self._linkMap[558] = "81049"
	--购买晶石箱子
	self._linkMap[559] = "81051"
	--晶石幻境
	-- self._linkMap[561] = "81046"
	--巨龙之战
	self._linkMap[562] = "81043"
	--公会副本
	self._linkMap[563] = "47001"
	--公会钓鱼
	self._linkMap[564] = "83003"
	--海商
	self._linkMap[565] = "71001"
	self._linkMap[566] = "71001"
	--风暴竞技场
	self._linkMap[567] = "81005"
	--熔火
	self._linkMap[569] = "61001"
	--组队竞技
	--self._linkMap[] = "83001"
	--宝石矿洞
	self._linkMap[571] = "48001"
	--搏击俱乐部
	self._linkMap[572] = "48002"
	--宗门红包
	self._linkMap[703] = "89004"
	self._linkMap[704] = "89003"
	--仙品10连抽
	self._linkMap[710] = "89007"
	--ss魂师神技升星
	self._linkMap[711] = "89013"
	--ss暗器升星
	self._linkMap[712] = "90022"
	--魂师派遣
	self._linkMap[716] = "90030"
	--魂兽森林占领次数
	self._linkMap[717] = "48001"
	--宗门副本
	self._linkMap[716] = "47001"
end

--获取该类别下的目标数量
function QActivity:getTypeNum(info)
	local fun = self._handlerMap[info.type]
	if fun ~= nil then
		return fun(info)
	else
		return self:getActivityTargetStatusById(info.activityId, info.activityTargetId)
	end
	return nil
end

--判断是否是需要跳转的活动
function QActivity:getLinkActivity(targetType)
	return self._linkMap[tonumber(targetType)]
end

-- 400 搜集一定的卡牌
function QActivity:checkCard(info)
	local id = info.value2
	if remote.herosUtil:getHeroByID(id) ~= nil then
		return 1
	end
	return 0 
end

-- 401 搜集一定的道具
function QActivity:checkItemNum(info)
	local id = info.value2
	local itemNum = remote.items:getItemsNumByID(id)
	return itemNum 
end

-- 500 战队等级条件
function QActivity:checkTeamLevel(info)
	return remote.user.level
end

-- 501 vip等级条件
function QActivity:checkVip(info)
	return QVIPUtil:VIPLevel()
end

-- 509 拥有魂师的数量
function QActivity:checkHeroCount(info)
	return table.nums(remote.herosUtil:getHaveHero())
end

-- 510 副本通关{0}章
function QActivity:checkDungeonPass(info)
	local instanceList = remote.instance:getInstancesById(info.value2)
	for _,dungeonInfo in pairs(instanceList) do
		if dungeonInfo.info == nil or dungeonInfo.info.lastPassAt == nil or dungeonInfo.info.lastPassAt == 0 then
			return 0
		end
	end
	return 1
end

-- 511 {0}个魂师突破到{1}
function QActivity:checkHeroBreakthroughCount(info)
	local count = 0
	local heros = remote.herosUtil:getHaveHero()
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getHeroByID(value)
	   		if (heroInfo.breakthrough or 0) >= info.value2 then
	   			count = count + 1
	   		end
	   	end
   	end
	return count
end

-- 513 斗魂场最高排名第{0}名
function QActivity:checkArenaTopRank(info)
	local target = 0
	local rank = remote.user:getPropForKey("arenaTopRank") or 0
	if rank > 0 and info.value2 >= rank then
		target = 1
	end
	return target
end

-- 514 副本总星级达到{0}
function QActivity:checkInstanceTotalStar(info)
	return remote.user:getPropForKey("c_allStarCount")
end

-- 515 {0}件觉醒装备达到{1}级
function QActivity:checkEquipmentEnchantCount(info)
	local heros = remote.herosUtil:getHaveHero()
	local count = 0
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getHeroByID(value)
	   		if heroInfo.equipments ~= nil then
		   		for _,equipment in pairs(heroInfo.equipments) do
		   			if (equipment.enchants or 0) >= info.value2 then
		   				count = count + 1
		   			end
		   		end
		   	end
   		end
   	end
   	return count
end

-- 516 小队最高战力达到{0}
function QActivity:checkTeamBattleForce(info)
	return remote.herosUtil:getMostHeroBattleForce()
end

-- 517 拥有{0}个{1}星魂师
function QActivity:checkHeroGradeCount(info)
	local count = 0
	local heros = remote.herosUtil:getHaveHero()
	for _,value in pairs(heros) do
	   	if value ~= "" then
			if (remote.herosUtil:getHeroByID(value).grade+1) >= info.value2 then
				count = count + 1
			end
		end
	end
	return count
end

-- 518 全员战力值达到{0}
function QActivity:checkAllHeroBattleForce(info)
	local force = 0 
	local heros = remote.herosUtil:getHaveHero()
	for _,value in pairs(heros) do
	   	if value ~= "" then
		   	force = force + remote.herosUtil:createHeroPropById(value):getBattleForce()
	    end
	end
	return force
end

-- 519 激活魂师组合关系{0}个
function QActivity:checkHeroCombinationCount(info)
	return 0
end

-- 520 拥有魂师的数量
function QActivity:checkHonorScore(info)
	return 0
end

-- 521 购买基金人数达到{0}
function QActivity:checkBuyFund(info)
	return remote.user.fundBuyCount or 0
end

-- 523 上阵魂师技能等级之和达到{0}级
function QActivity:checkSkillLevel(info)
	local heros = remote.herosUtil:getHaveHero()
	local count = 0
	for index,value in pairs(heros) do
	   	if value ~= "" then
		    local breakthroughConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByActorId(value)
	   		local heroInfo = remote.herosUtil:getHeroByID(value)

		    if breakthroughConfig ~= nil and heroInfo.slots ~= nil then
		        for _,value in pairs(breakthroughConfig) do
		            for _,slot in pairs(heroInfo.slots) do
		            	if value.skill_id_3 == slot.slotId then
			   				count = count + slot.slotLevel or 0
			   				break
			   			end
		   			end
		        end
		    end
		end
		if index >= 4 then
			break
		end
	end
	return count
end

-- 536 {0}名魂师装备大师等级达到{1}级
function QActivity:checkHeroEquipmentMasterLevel(info)
	local count = 0
	local heros = remote.herosUtil:getHaveHero()
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getUIHeroByID(value)
	   		if (heroInfo:getHeroEquipMasterLevel() or 0) >= info.value2 then
	   			count = count + 1
	   		end
	   	end
   	end
	return count
end

-- 528 {0}名魂师饰品大师达到{1}级
function QActivity:checkHeroJewelMasterLevel(info)
	local count = 0
	local heros = remote.herosUtil:getHaveHero()
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getUIHeroByID(value)
	   		if (heroInfo:getHeroJewelryMasterLevel() or 0) >= info.value2 then
	   			count = count + 1
	   		end
	   	end
   	end
	return count
end

-- 537 {0}名魂师4件装备觉醒星级达到{1}级
function QActivity:checkHeroFourEquipmentEnchantLevel(info)
	local equipPos = {EQUIPMENT_TYPE.WEAPON, EQUIPMENT_TYPE.BRACELET, EQUIPMENT_TYPE.CLOTHES, EQUIPMENT_TYPE.SHOES}
	local heros = remote.herosUtil:getHaveHero()
	local count = 0
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getUIHeroByID(value)
	   		local isAllEquipments = true
	   		for _, pos in ipairs(equipPos) do
	   			local equipment = heroInfo:getEquipmentInfoByPos(pos)
	   			if equipment ~= nil then
	   				local equipmentInfo = remote.herosUtil:getWearByItem(heroInfo:getHeroInfo().actorId, equipment.info.itemId)
	   				if equipmentInfo == nil or (equipmentInfo.enchants or 0) < info.value2 then
	   					isAllEquipments = false
	   				end
	   			else
	   				isAllEquipments = false
	   			end
	   		end
		   	if isAllEquipments == true then
		   		count = count + 1
		   	end
   		end
   	end
   	return count
end

-- 527 {0}名魂师饰品突破等级达到{1}级
function QActivity:checkHeroAllJewelBreakthroughLevel(info)
	local heros = remote.herosUtil:getHaveHero()
	local count = 0
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getUIHeroByID(value)
	   		local jewel1Info = heroInfo:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
	   		local jewel2Info = heroInfo:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
	   		if jewel1Info ~= nil 
	   			and jewel2Info ~= nil 
	   			and (jewel1Info.breakLevel or 0) >= info.value2
	   			and (jewel2Info.breakLevel or 0) >= info.value2 
	   			then
	   			count = count + 1
	   		end
   		end
   	end
   	return count
end

-- 529 {0}名魂师饰品觉醒等级达到{1}级
function QActivity:checkHeroAllJewelEnchantLevel(info)
	local heros = remote.herosUtil:getHaveHero()
	local count = 0
	for _,value in pairs(heros) do
	   	if value ~= "" then
	   		local heroInfo = remote.herosUtil:getUIHeroByID(value)
	   		local jewel1Info = heroInfo:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
	   		local jewel2Info = heroInfo:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2)
	   		if jewel1Info ~= nil 
	   			and jewel2Info ~= nil 
	   			and jewel1Info.info ~= nil
	   			and jewel2Info.info ~= nil
	   			then

	   			local equipmentInfo1 = remote.herosUtil:getWearByItem(heroInfo:getHeroInfo().actorId, jewel1Info.info.itemId)
	   			local equipmentInfo2 = remote.herosUtil:getWearByItem(heroInfo:getHeroInfo().actorId, jewel2Info.info.itemId)
	   			if equipmentInfo1 ~= nil
	   				and equipmentInfo2 ~= nil 
	   				and equipmentInfo1.enchants >= info.value2
	   				and equipmentInfo2.enchants >= info.value2
	   				then
	   				count = count + 1
	   			end

	   		end
   		end
   	end
   	return count
end

-- 538 雷电王座星数{0}
function QActivity:checkThunderStarCount(info)
	return remote.user:getPropForKey("thunderHistoryMaxStar")
end

 -- 549 百日登录
function QActivity:checkLoginCount(  )
	-- body
	local count = remote.user.loginDaysCount or 0
	return count
end

 -- 719 版更登录
 function QActivity:checkVerChangeLogin(target)
	local data = self._progressData[target.activityId][target.activityTargetId]
	local num = data.progress or 1
	num = target.haveNum or num
	-- 登录必定可以领奖所以至少为1
	if num < 1 then
		num = 1
	end
	return num
end

-- 100 单笔充值类
function QActivity:checkSingleRecharge( info )
	local data = self._progressData[info.activityId][info.activityTargetId] or {}	
	data.completeCount = data.completeCount or 0
	data.awardCount = data.awardCount  or 0
	if data.completeCount > data.awardCount then
		return 1
	else
		return 0
	end
end

-- --累计充值
-- function QActivity:checkMultipleRecharge( info )
-- 	-- body
-- 	local value = 0
-- 	for k, v in pairs(self._rechargeRecords) do
-- 		value = value + v.rmb
-- 	end
-- 	return self:getActivityTargetStatusById(info.activityId, info.activityTargetId) + value
-- end

 -- 102 每日充值类
function QActivity:checkDayRecharge(info)
	local activityId = info.activityId
	if self._dayRecharge[activityId] == nil then
		if (remote.user.todayRecharge or 0) < info.value2 then
			self._dayRecharge[activityId] = info.activityTargetId
			return info.value--(remote.user.todayRecharge or 0)
		end
	elseif self._dayRecharge[activityId] == info.activityTargetId then
		if (remote.user.todayRecharge or 0) >= info.value2 then
			if self._progressData[info.activityId][info.activityTargetId] ~= nil then
				self._progressData[info.activityId][info.activityTargetId].completeCount = 1
			end
			return info.value--(remote.user.todayRecharge or 0)
		end
	end
	return 0
end

 -- 705 周末累计在线时长
function QActivity:checkWeekendOnlineTime(  )
	-- body
	local count = remote.user.loginDaysCount or 0
	return count
end

 -- 708 周末膜拜次数
function QActivity:checkWeekendAreanWorshipNum(  )
	-- body
	local count = remote.user.loginDaysCount or 0
	return count
end

-----------------------------------------------------------------------

-- 返回活动列表 但去掉所有完成或不在活动时间内的活动
function QActivity:getActivityThemeListValid() 
	local themeList = {}
	for _, theme in ipairs(self._activityThemeList) do
		if self:checkIsAllThemeComplete(theme.id) then
			table.insert(themeList, theme)
		end
	end
	return themeList
end
--判断是否是 兑换类的活动
function QActivity:isExchangeActivity( targetType )
	-- body
	return math.floor(targetType/100) == 3
end
--判断是否是 充值类活动
function QActivity:isRechargeActivity( targetType )
	-- body
	return math.floor(targetType/100) == 1
end

--判断 是否支持 重复多次领取次数 
function QActivity:isActivitySupportMultiple( targetType,repeatCount )
	-- body
	if (targetType == 100 and repeatCount and repeatCount >= 1) or self:isExchangeActivity(targetType) then
		return true
	end
	return false
end

--特殊处理开服基金 没有购买 小红点显示
function QActivity:checkActivityFundCanBuy( typeName ,activityInfo)
	-- body
	if not typeName or not activityInfo then
		return
	end
	local needVip 
	local curVip = QVIPUtil:VIPLevel()
	local param = string.split(activityInfo.params, ",")
	if #param >= 1 then
		needVip = tonumber(param[1])
	end
	if needVip and curVip and curVip >= needVip and typeName == QActivity.TYPE_ACTIVITY_FOR_FUND and remote.user.fundStatus and remote.user.fundStatus~= 1 then
		return true
	end
	return false
end

--标记当前活动被点击
function QActivity:setActivityClicked( activityInfo )
	-- body
	if activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN or activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_FUND or 
		activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_FORCE or activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_CARD or 
		activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE then
		return 

	end
	-- local key = string.format("%s%d",activityInfo.activityId or "" , activityInfo.type or 0)
	app:getUserOperateRecord():setActivityClicked(activityInfo.activityId)
end
--标记当前活动被点击
function QActivity:isActivityClicked( activityInfo , isNotJudgeComplete )
	-- body
	local key = string.format("%s%d",activityInfo.activityId or "" , activityInfo.type or 0)
	--特殊处理 开服基金和开服竞赛
	if activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN_2  or 
		activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_SEVEN or activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_FUND or 
		activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_FORCE or activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_CARD or 
		activityInfo.type == QActivity.TYPE_ACTIVITY_FOR_LEVEL_RACE or activityInfo.type == QActivity.TYPE_CRYSTAL_SHOP then

		return true
	end

	if not isNotJudgeComplete then
		if activityInfo.isAllTargetsComplete then
			return true
		end
	end

	return app:getUserOperateRecord():isActivityClicked(activityInfo.activityId)
end

--调查问卷
function QActivity:_onNewQuestionnaireReceived(data)
	local response = data.sendActivityQuestionChangeResponse or {}
	
	if response.pushType == "ONLINE" then
		self:setQuestionnaire(response.activityQuestion)
	elseif response.pushType == "OFFLINE" then
		self:setQuestionnaire({})
	end

	self:dispatchEvent({name = QActivity.EVENT_RECIVED_QUESTIONNAIRE})
end

function QActivity:setQuestionnaire(data)
	self._questionnaireDict = data
end

function QActivity:getQuestionnaireInfo()
	return self._questionnaireDict
end

function QActivity:getActivityTargetConfigByTargetId(targetId)
	if targetId == nil then return {} end

	if self._activityTargetConfig == nil then
		self._activityTargetConfig = QStaticDatabase:sharedDatabase():getActivityTarget()
	end
	
	return self._activityTargetConfig[targetId] or {}
end

function QActivity:getRechargeConfigByRechargeId(rechargeId)
	local recharge = db:getRecharge()

	for i,v in ipairs(recharge) do
		if v.ID == rechargeId then
			return v
		end
	end
	return nil
end

function QActivity:getRechargeConfigByRechargeBuyProductId(rechargeBuyProductId)
	local recharge = db:getRecharge()
	local platform = (device.platform == "android" and 2 or 1)
	for i,v in ipairs(recharge) do
		if v.recharge_buy_productid == rechargeBuyProductId and platform == v.platform then
			return v
		end
	end
	return nil
end

function QActivity:getActivityTargetChannelConfigByChannelId(channelId)
   local  channelConfig =  db:getStaticByName("target_channel_activity")
    for _,value in pairs(channelConfig or {}) do
        if tonumber(value.channel_id) == tonumber(channelId)  then
            return value
        end
    end
    return nil
end

function QActivity:getActivityTargetChannelConfigById(id)
   local  channelConfig =  db:getStaticByName("target_channel_activity")
    for _,value in pairs(channelConfig or {}) do
        if tonumber(value.id) == tonumber(id)  then
            return value
        end
    end
    return nil
end

function QActivity:checkGettenAwardByById(id)
    for i,v in ipairs(self._channelAwardIds or {}) do
        if v == id then
            return true
        end
    end
    return false
end
--

function QActivity:_dispatchAll()
    local tbl = {}
    for _, name in pairs(self._dispatchList) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = true
        end
    end
    self._dispatchList = {}
end
--
function QActivity:responseHandler(data, success, fail, succeeded)
	--self._channelAwardIds
	if data.activityChannelResponse ~= nil then
		for i,v in ipairs(data.activityChannelResponse.getAwardList or {}) do
			if not self:checkGettenAwardByById(v) then
				table.insert(self._channelAwardIds , v)
			end
		end
		table.insert(self._dispatchList,QActivity.EVENT_CHANNEL_AWARD_INFO_UPDATE)
	end

    self:_dispatchAll()
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

--目标渠道活动信息  ActivityChannelResponse
function QActivity:activityChannelMainInfoRequest(success, fail)
    local request = {api = "ACTIVITY_TARGET_CHANNEL_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--领取奖励 ActivityChannelGetRewardRequest   ActivityChannelResponse
function QActivity:activityChannelGetRewardRequest(awardId,success, fail)
    local activityChannelGetRewardRequest = {awardId = awardId}
    local request = {api = "ACTIVITY_TARGET_CHANNEL_GET_REWARD", activityChannelGetRewardRequest = activityChannelGetRewardRequest }
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


-- 月卡奖励补领
function QActivity:obtainMonthCardSupplementRequest(success, fail)
    local request = {api = "SUPPLEMENT_MONTH_CARD_AWARD"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end



function QActivity:getHighTeaRewardConfigByLevel(level)
	local  configs = {}
   configs =  db:getStaticByName("hightea_reward")
    for _,value in pairs(configs or {}) do
        if tonumber(value.level) == tonumber(level)  then
            return value
        end
    end
    return nil
end


function QActivity:getHighTeaFoodConfigById(id)
	local  configs = {}
	configs =  db:getStaticByName("hightea_food")
    for _,value in pairs(configs or {}) do
        if tonumber(value.id) == tonumber(id)  then
            return value
        end
    end
    return nil
end

function QActivity:getHighTeaFoodConfigByItemId(itemId)
	local  configs = {}
	configs =  db:getStaticByName("hightea_food")
    for _,value in pairs(configs or {}) do
        if tonumber(value.item_id) == tonumber(itemId)  then
            return value
        end
    end
    return nil
end


function QActivity:getHighTeaRewardConfig()
	local  configs = {}
	configs =  db:getStaticByName("hightea_reward")
	return configs
end

function QActivity:getHighTeaChatConfigByTypeAndMood(type_ , mood_ ,expression)
	local  result = {}
	local  configs = {}
	configs =  db:getStaticByName("hightea_chat")
	for _,value in pairs(configs or {}) do
		local moodCheck = mood_ == nil and true or (mood_ == value.mood or value.mood  == 0 )
		local expressionCheck = expression == nil and true or expression == value.expression
        if tonumber(value.type) == tonumber(type_) and moodCheck and expressionCheck  then
            table.insert(result , value)
        end
    end
    return result
end

function QActivity:getHighTeaChatConfig()
	local  configs = {}
	configs =  db:getStaticByName("hightea_chat")
	return configs
end

function QActivity:getHighTeaFoodConfig()
	local  configs = {}
	configs =  db:getStaticByName("hightea_food")
	return configs
end


return QActivity