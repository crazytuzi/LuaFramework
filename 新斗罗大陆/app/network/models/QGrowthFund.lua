--
-- Kumo.Wang
-- 新成长基金（包装成活动的普通功能）
-- 

local QBaseModel = import("...models.QBaseModel")
local QGrowthFund = class("QGrowthFund", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

local QUIWidgetActivityGrowthFund = import("...ui.widgets.QUIWidgetActivityGrowthFund")

QGrowthFund.ACTIVITY_ID = "QGROWTHFUND.ACTIVITY_ID"

QGrowthFund.TYPE_FUND = 2
QGrowthFund.TYPE_WELFARE = 1

QGrowthFund.STATE_AWARD_HALF = 3 -- 领了一部分
QGrowthFund.STATE_COMPLETE = 2 -- 未领奖
QGrowthFund.STATE_NONE = 1 -- 未完成
QGrowthFund.STATE_DONE = 0 -- 领完

QGrowthFund.AWARD_TYPE_FREE = 1 -- 成长基金免费奖励
QGrowthFund.AWARD_TYPE_FUND = 2 -- 成长基金特权奖励
QGrowthFund.AWARD_TYPE_WELFARE = 3 -- 全民福利奖励

QGrowthFund.EVENT_UPDATE = "QGROWTHFUND.EVENT_UPDATE"

function QGrowthFund:ctor()
	QGrowthFund.super.ctor(self)
end

function QGrowthFund:init()
	self._dispatchTbl = {}

	self._fundListData = {}
	self._welfareListData = {}
	self._awardDoneIds = {} 
	self._configDic = {}
	self._stateDoneIdsDic = {} -- 已经完成的id

	self._isNeedRefresh = true
	self._gotTokenNum = 0 -- 已经领取的返利钻石
	self._willTokenNum = 0 -- 还未领取的返利钻石
end

function QGrowthFund:loginEnd()
    self:_loadActivity()
    remote.activity:registerDataProxy(self.ACTIVITY_ID, self)
    
    app:getClient():buyFundCountRequest(function()
    	self:growthFundMainInfoRequest(function()
	    	remote.activity:dispatchEvent({name = remote.activity.EVENT_CHANGE})
	    end)
    end)
end

function QGrowthFund:disappear()
    -- remote.activity:unregisterDataProxy(self.ACTIVITY_ID)
end

--------------数据储存.KUMOFLAG.--------------

-- 获取购买基金的要求
function QGrowthFund:getBuyFundCondition()
	if self._needVip and self._payMoney then
		return self._needVip, self._payMoney
	end

	local value = db:getConfigurationValue("BUY_GROWTH_FUND_CONDITION")
	local param = string.split(value, ";")
	if #param == 2 then
		self._needVip = tonumber(param[1])
		self._payMoney = tonumber(param[2])
	end

	return self._needVip, self._payMoney
end

-- 获取特权基金的钻石领取情况
function QGrowthFund:getFundTokenInfo()
	return self._gotTokenNum, self._willTokenNum
end

--------------對外工具.KUMOFLAG.--------------

--实现活动的代理方法
function QGrowthFund:getWidget(activityInfo)
    local widget
    if activityInfo.activityId == self.ACTIVITY_ID then
        widget = QUIWidgetActivityGrowthFund.new()
    end
    return widget
end

function QGrowthFund:getBtnTips(activityInfo)
    if activityInfo.activityId == self.ACTIVITY_ID then
		return self:checkRedTips()
    end
    return false
end

function QGrowthFund:checkRedTips()
	if self:checkFundRedTips() then
		return true
	end

	if self:checkWelfareRedTips() then
		return true
	end

	return false
end

function QGrowthFund:checkFundRedTips()
	local configs = self:getFundListData(true)
	for _, config in ipairs(configs) do
		local state = self:getStateById(config.id)
		if state == self.STATE_COMPLETE or (state == self.STATE_AWARD_HALF and remote.user.fundStatus == 1) then
			return true
		end
	end
	return false
end

function QGrowthFund:checkWelfareRedTips()
	local configs = self:getWelfareListData(true)
	for _, config in ipairs(configs) do
		local state = self:getStateById(config.id)
		if state == self.STATE_COMPLETE or (state == self.STATE_AWARD_HALF and remote.user.fundStatus == 1) then
			return true
		end
	end
	return false
end

-- 获取基金奖励列表
function QGrowthFund:getFundListData(notSort)
	if q.isEmpty(self._fundListData) then
		local configs = db:getStaticByName("activity_growth_fund")
		for _, config in pairs(configs) do
			if config.type == self.TYPE_FUND then
				table.insert(self._fundListData, config)
			end
		end
	end

	if not notSort then
		table.sort(self._fundListData, function (a, b)
			local stateA = self:getStateById(a.id)
			local stateB = self:getStateById(b.id)
			if stateA ~= stateB then
				return stateA > stateB
			else
				return a.id < b.id
			end
		end)
	end
	return self._fundListData
end

-- 获取福利奖励列表
function QGrowthFund:getWelfareListData(notSort)
	if q.isEmpty(self._welfareListData) then
		local configs = db:getStaticByName("activity_growth_fund")
		for _, config in pairs(configs) do
			if config.type == self.TYPE_WELFARE then
				table.insert(self._welfareListData, config)
			end
		end
	end

	if not notSort then
		table.sort(self._welfareListData, function (a, b)
			local stateA = self:getStateById(a.id)
			local stateB = self:getStateById(b.id)
			if stateA ~= stateB then
				return stateA > stateB
			else
				return a.id < b.id
			end
		end)
	end
	return self._welfareListData
end

function QGrowthFund:getConfigById( id )
	if self._configDic[tostring(id)] then
		return self._configDic[tostring(id)]
	end

	local configs = db:getStaticByName("activity_growth_fund")
	for _, config in pairs(configs) do
		self._configDic[tostring(config.id)] = config
	end

	return self._configDic[tostring(id)]
end

-- 获取列表内容的状态
function QGrowthFund:getStateById( id )
	local isGotFundAward = false -- 是否领取了特权奖励

	if self._stateDoneIdsDic[tostring(id)] then
		isGotFundAward = true
		return self.STATE_DONE, isGotFundAward
	end

	local state = self.STATE_NONE
	local config = self:getConfigById(id)
	if config then
		if config.type == self.TYPE_FUND then
			if (self._awardDoneIds[self.AWARD_TYPE_FREE] and self._awardDoneIds[self.AWARD_TYPE_FREE][tostring(id)]) 
				and (self._awardDoneIds[self.AWARD_TYPE_FUND] and self._awardDoneIds[self.AWARD_TYPE_FUND][tostring(id)]) then
				state = self.STATE_DONE
				isGotFundAward = true
			elseif self._awardDoneIds[self.AWARD_TYPE_FREE] and self._awardDoneIds[self.AWARD_TYPE_FREE][tostring(id)] then
				state = self.STATE_AWARD_HALF
			elseif remote.user.level >= tonumber(config.value) then
				state = self.STATE_COMPLETE
				if self._awardDoneIds[self.AWARD_TYPE_FUND] and self._awardDoneIds[self.AWARD_TYPE_FUND][tostring(id)] then
					-- 免费未领取，特权已经领取的情况（只有新老数据交汇的时候才会发生）
					isGotFundAward = true
				end
			end
		else
			if self._awardDoneIds[self.AWARD_TYPE_WELFARE] and self._awardDoneIds[self.AWARD_TYPE_WELFARE][tostring(id)] then
				state = self.STATE_DONE
			elseif (remote.user.fundBuyCount or 0) >= tonumber(config.value) then
				state = self.STATE_COMPLETE
			end
		end
	end

	if state == self.STATE_DONE then
		self._stateDoneIdsDic[tostring(id)] = true
	end

	return state, isGotFundAward
end

--------------数据处理.KUMOFLAG.--------------

function QGrowthFund:responseHandler( response, successFunc, failFunc )
	-- QPrintTable( response )
	if response.error == "NO_ERROR" then
		if response.openServerFundRewardResponse then
			self:_updateAwardDoneIds(response.openServerFundRewardResponse)
		end

		if response.api == "FUND_AWARD_GET_AWARD" then
			table.insert(self._dispatchTbl, {name = QGrowthFund.EVENT_UPDATE})
		end
	end

	if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

function QGrowthFund:pushHandler( data )
    -- QPrintTable(data)
end

--[[
	//新版开服开服基金（免费先与付费线）
	FUND_AWARD_GET_MAIN_INFO                          =10137;     //获取开服基金免费线和付费线领奖记录  OpenServerFundRewardResponse
	FUND_AWARD_GET_AWARD                              =10138;     //领取奖励 OpenServerFundRewardRequest   OpenServerFundRewardResponse
]]

function QGrowthFund:growthFundMainInfoRequest(success, fail, status)
    local request = { api = "FUND_AWARD_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("FUND_AWARD_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--optional int32 awardId = 1; //要领取的奖励的量表id（后端自己判断是领取免费还是付费奖励）
function QGrowthFund:growthFundGetAwardRequest(awardId, success, fail, status)
	local openServerFundRewardRequest = {awardId = awardId}
    local request = { api = "FUND_AWARD_GET_AWARD", openServerFundRewardRequest = openServerFundRewardRequest}
    app:getClient():requestPackageHandler("FUND_AWARD_GET_AWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具--------------

function QGrowthFund:_dispatchAll()
	if q.isEmpty(self._dispatchTbl) then return end

	local tbl = {}
	local tblKey = ""
	for _, eventTbl in pairs(self._dispatchTbl) do
		tblKey = eventTbl.name
		local eventInfo = {}
		if eventTbl.param then
    		for key, value in pairs(eventTbl.param) do
    			tblKey = tblKey .. key
    			eventInfo[key] = value
    		end
    	end
        if not tbl[tblKey] then
			eventInfo.name = eventTbl.name
            self:dispatchEvent(eventInfo)
            tbl[tblKey] = true
        end
    end
	self._dispatchTbl = {}
end

-- 加入到活動數據裡，包装成活动
function QGrowthFund:_loadActivity()
    local activities = {}
    table.insert(activities, {
        activityId = self.ACTIVITY_ID, 
        type = remote.activity.TYPE_PSEUDO_ACTIVITY,
        title = "成长基金",
        permanent = true,
        subject = remote.activity.THEME_ACTIVITY_NONE,
       	})
    remote.activity:setData(activities)
end

function QGrowthFund:_updateAwardDoneIds(data)
	if data.freeAwardIds then
		if not self._awardDoneIds[self.AWARD_TYPE_FREE] then
			self._awardDoneIds[self.AWARD_TYPE_FREE] = {}
		end
		for _, id in ipairs(data.freeAwardIds) do
			self._awardDoneIds[self.AWARD_TYPE_FREE][tostring(id)] = true
		end
	end

	if data.rechargeAwardIds then
		if not self._awardDoneIds[self.AWARD_TYPE_FUND] then
			self._awardDoneIds[self.AWARD_TYPE_FUND] = {}
		end
		for _, id in ipairs(data.rechargeAwardIds) do
			if not self._awardDoneIds[self.AWARD_TYPE_FUND][tostring(id)] then
				self._isNeedRefresh = true
			end
			self._awardDoneIds[self.AWARD_TYPE_FUND][tostring(id)] = true
		end
	end

	if data.buyCountAwardIds then
		if not self._awardDoneIds[self.AWARD_TYPE_WELFARE] then
			self._awardDoneIds[self.AWARD_TYPE_WELFARE] = {}
		end
		for _, id in ipairs(data.buyCountAwardIds) do
			self._awardDoneIds[self.AWARD_TYPE_WELFARE][tostring(id)] = true
		end
	end

	if self._isNeedRefresh then
		self:_calculateGotAwardToken()
	end
end

function QGrowthFund:_calculateGotAwardToken()
	local listData = self:getFundListData(true)
	self._gotTokenNum = 0
	self._willTokenNum = 0
	for _, value in pairs(listData) do
		if value.awards_2 then
			local items = string.split(value.awards_2, ";") 
			local count = #items
			for i=1,count,1 do
	            local obj = string.split(items[i], "^")
	            if #obj == 2 then
	            	if remote.items:getItemType(obj[1]) == ITEM_TYPE.TOKEN_MONEY then
						if self._awardDoneIds[self.AWARD_TYPE_FUND] and self._awardDoneIds[self.AWARD_TYPE_FUND][tostring(value.id)] then
	            			self._gotTokenNum = self._gotTokenNum + tonumber(obj[2])
	            		else
	            			self._willTokenNum = self._willTokenNum + tonumber(obj[2])
	            		end
	            	end
	            end
			end
		end
	end

	self._isNeedRefresh = false
end

return QGrowthFund
