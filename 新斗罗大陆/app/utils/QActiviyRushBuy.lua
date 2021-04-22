local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActiviyRushBuy = class("QActiviyRushBuy",QActivityRoundsBaseChild)
local QStaticDatabase = import("..controllers.QStaticDatabase")


function QActiviyRushBuy:ctor( ... )
	-- body
	QActiviyRushBuy.super.ctor(self,...)
	self._buyInfo = {}
	self._goodInfo = {}
	self._recordTips = {}

	self._isClickedActivity = false
	self._openAwardTips = false
	self._isAllItemClicked = true

	self._activityConfigList = {}    --活动量表配置
end


function QActiviyRushBuy:initRushbuyTips(  )
	-- body
	remote.redTips:createTipsNode("QUIPageMainMenu_RushBuyTips")
	remote.redTips:createTipsNode("QUIDialogActivityRushBuy_DailyTips", "QUIPageMainMenu_RushBuyTips")
	remote.redTips:createTipsNode("QUIDialogActivityRushBuy_LuckyTips", "QUIPageMainMenu_RushBuyTips")
	remote.redTips:createTipsNode("QUIDialogActivityRushBuy_RoundIdTips", "QUIPageMainMenu_RushBuyTips")
	-- 初始化红点状
	remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_DailyTips", not self._isClickedActivity)
	remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_LuckyTips", self._openAwardTips)
	remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_RoundIdTips", not self._isAllItemClicked)
end

function QActiviyRushBuy:clickedActivity(tureOfFalse)
	-- body
	if self._isClickedActivity ~= tureOfFalse then
		remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_DailyTips", not tureOfFalse)
	end

	self._isClickedActivity = tureOfFalse
end

function QActiviyRushBuy:openAward(tureOfFalse)
	-- body
	if self._openAwardTips ~= tureOfFalse then
		remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_LuckyTips", tureOfFalse)
	end
	self._openAwardTips = tureOfFalse
end

function QActiviyRushBuy:setAllItemClicked(tureOfFalse)
	-- bod
	if self._isAllItemClicked ~= tureOfFalse then
		remote.redTips:setTipsStateByName("QUIDialogActivityRushBuy_RoundIdTips", not tureOfFalse)
	end
	self._isAllItemClicked = tureOfFalse
end


function QActiviyRushBuy:getRecordRedTips( issue )
	-- body
	return self._recordTips[issue]
end




function QActiviyRushBuy:getGoodInfo( )
	-- body
	return self._goodInfo or {}
end

function QActiviyRushBuy:getBuyInfo( )
	-- body
	return self._buyInfo or {}
end

function QActiviyRushBuy:updateBuyInfo(data)
	-- body
	if not data then
		return
	end 

	for k, v in pairs(self._buyInfo) do
		if v.roundId == data.roundId then
			self._buyInfo[k] = data
		end
	end
end

function QActiviyRushBuy:getActivityConfigByRound(roundId)
	if roundId == nil then return {} end

	if q.isEmpty(self._activityConfigList) then
		local config = QStaticDatabase:sharedDatabase():getStaticByName("lucky_treasure")

		self._activityConfigDict = clone(config)
	end

	return self._activityConfigDict[tostring(roundId)]
end

function QActiviyRushBuy:getRoundConfigByNumber(number)
	if number == nil then return {} end

	local configList = self:getActivityConfigByRound(self.rowNum, number)
	for _, value in ipairs(configList) do
		if value.number == number then
			return value
		end
	end

	return {}
end

function QActiviyRushBuy:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
	self._buyInfo = {}
	self._goodInfo = {}	
	self._recordTips = {}
end

function QActiviyRushBuy:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
	self:setAllItemClicked(true)
end

function QActiviyRushBuy:handleOnLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
	self:clickedActivity(false)
end

function QActiviyRushBuy:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
	self._buyInfo = {}
	self._goodInfo = {}	
	self._recordTips = {}
end

function QActiviyRushBuy:dispatchUpdateEvent(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE, data = data})
end



function QActiviyRushBuy:requestGoodsInfo( success, fail)
	-- body
	local request = {api = "RUSH_BUY_GET_GOODS_INFO", rushBuyGetGoodsInfoRequest = {rushBuyId = self.activityId}}
	app:getClient():requestPackageHandler("RUSH_BUY_GET_GOODS_INFO", request, function (data)
		-- body
		if data.rushBuyGetGoodsInfoResponse and data.rushBuyGetGoodsInfoResponse.goodsInfos then
			self._goodInfo = data.rushBuyGetGoodsInfoResponse.goodsInfos
		end
		if success then
			success(data)
		end
	end, fail)
end

function QActiviyRushBuy:requestBuyInfos( success, fail)
	-- body
	local request = {api = "RUSH_BUY_GET_BUY_INFO", rushBuyGetBuyInfoRequest = {rushBuyId = self.activityId}}
	app:getClient():requestPackageHandler("RUSH_BUY_GET_BUY_INFO", request, function (data)
		-- body
		if data.rushBuyGetBuyInfoResponse and data.rushBuyGetBuyInfoResponse.buyInfos then
			self._buyInfo = data.rushBuyGetBuyInfoResponse.buyInfos
		end
		if success then
			success(data)
		end
	end, fail)
end


function QActiviyRushBuy:requestBuyNums( issue, nums, success, fail )
	-- body
	local request = {api = "RUSH_BUY_BUY_GOODS", rushBuyBuyGoodsRequest = {rushBuyId = self.activityId, issue = issue, buyCount = nums}}
	app:getClient():requestPackageHandler("RUSH_BUY_BUY_GOODS", request, function (data)
		-- body
		if data.rushBuyBuyGoodsResponse then
			if data.rushBuyBuyGoodsResponse.buyInfo then
				self:updateBuyInfo(data.rushBuyBuyGoodsResponse.buyInfo)
				remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
			end
			if data.rushBuyBuyGoodsResponse.luckyNums then
				local arrs = string.split(data.rushBuyBuyGoodsResponse.luckyNums, ";") or {}
				local temp = {}
				for k, v in pairs(arrs) do
					local num = tonumber(v)
					if num then
						table.insert(temp,num)
					end
				end
				self._recordTips[issue] = true
				remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_RECORD_CHANGE})

				if success then
					success(temp)
				end
			end
		end
	end, function( data )
		-- body
		if data.error == "RUSH_BUY_GOODS_NOT_ENOUGH" then
			self:requestBuyInfos(function ( ... )
				-- body
				remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
			end)
		end

		if fail then
			fail(data)
		end
	end)
end

function QActiviyRushBuy:requestMyNum( issue, success, fail )
	-- body
	local request = {api = "RUSH_BUY_GET_MY_LUCKY_NUMS", rushBuyGetMyLuckyNumsRequest = {rushBuyId = self.activityId, issue = issue}}
	app:getClient():requestPackageHandler("RUSH_BUY_GET_MY_LUCKY_NUMS", request, function (data)
		-- body
		if data.rushBuyGetMyLuckyNumsResponse then
			if data.rushBuyGetMyLuckyNumsResponse.luckyNums then
				local arrs = string.split(data.rushBuyGetMyLuckyNumsResponse.luckyNums, ";") or {}
				local temp = {}
				for k, v in pairs(arrs) do
					local num = tonumber(v)
					if num then
						table.insert(temp, num)
					end
					table.sort( temp, function ( x,y )
						-- body
						return x < y
					end )
				end
				self._recordTips[issue] = nil
				remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_RECORD_CHANGE})
				if success then
					success(temp)
				end
			end
		end
	end, fail)
end

function QActiviyRushBuy:requestMyLogs( issue, success, fail )
	-- body
	local request = {api = "RUSH_BUY_GET_BUY_LOG", rushBuyGetBuyLogRequest = {rushBuyId = self.activityId, issue = issue}}
	app:getClient():requestPackageHandler("RUSH_BUY_GET_BUY_LOG", request, function (data)
		-- body
		local temp = {}
		if data.rushBuyGetBuyLogResponse then
			if data.rushBuyGetBuyLogResponse.pbRushBuyBuyLog then
				temp = data.rushBuyGetBuyLogResponse.pbRushBuyBuyLog 
			end
		end
		if success then
			success(temp)
		end
	end, fail)
end


function QActiviyRushBuy:requestLuckyPerson( success, fail )
	-- body
	self:openAward(false)
	local request = {api = "RUSH_BUY_GET_LUCKY_USERS", rushBuyGetLuckyUsersRequest = {rushBuyId = self.activityId}}

	app:getClient():requestPackageHandler("RUSH_BUY_GET_LUCKY_USERS", request, function (data)
		-- body
		local temp = {}
		if data.rushBuyGetLuckyUsersResponse then
			if data.rushBuyGetLuckyUsersResponse.luckyUserInfos then
				temp = data.rushBuyGetLuckyUsersResponse.luckyUserInfos
			end
			table.sort( temp, function ( x,y )
				-- body
				if x.fighter.name == remote.user.nickName and y.fighter.name == remote.user.nickName then
					return x.luckyAt > y.luckyAt
				elseif x.fighter.name == remote.user.nickName then
					return true
				elseif y.fighter.name == remote.user.nickName then
					return false
				else
					return x.luckyAt > y.luckyAt
				end		
			end )


		end
		if success then
			success(data.rushBuyGetLuckyUsersResponse.luckyUserInfos)
		end
	end, fail)
end

function QActiviyRushBuy:requestLuckyPersonIssue( issue, success, fail )
	-- body
	local request = {api = "RUSH_BUY_GET_GOODS_LUCKY_USERS", rushBuyGetGoodsLuckyUsersRequest = {rushBuyId = self.activityId, issue = issue}}
	app:getClient():requestPackageHandler("RUSH_BUY_GET_GOODS_LUCKY_USERS", request, function (data)
		-- body
		local temp = {}
		if data.rushBuyGetGoodsLuckyUsersResponse then
			if data.rushBuyGetGoodsLuckyUsersResponse.luckyUserInfos then
				temp = data.rushBuyGetGoodsLuckyUsersResponse.luckyUserInfos
			end
		end
		if success then
			success(data.rushBuyGetGoodsLuckyUsersResponse.luckyUserInfos)
		end
	end, fail)
end


return QActiviyRushBuy