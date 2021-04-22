local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActiviyGroupBuy = class("QActiviyGroupBuy",QActivityRoundsBaseChild)
local QStaticDatabase = import("..controllers.QStaticDatabase")


function QActiviyGroupBuy:ctor( ... )
	-- body
	QActiviyGroupBuy.super.ctor(self,...)
	self._goodsDiscountInfo = {}
	self._alreadyBuyInfo = {}
	self._scoreInfo = {}
	self._flag = 0
	self._goodsInfo = {}
end

function QActiviyGroupBuy:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE})
	self._goodsDiscountInfo = {}
	self._alreadyBuyInfo = {}
	self._scoreInfo = {}
	self._flag = 0
	self._goodsInfo = {}
end


function QActiviyGroupBuy:activityEndCallBack(  )
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE})
end

function QActiviyGroupBuy:handleOnLine( )
	-- body
	if self.isOpen then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE})
		self:requestGoodsDiscountInfo()
	end
end

function QActiviyGroupBuy:handleOffLine( )
	-- body
	self._goodsDiscountInfo = {}
	self._alreadyBuyInfo = {}
	self._scoreInfo = {}
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE})
end

function QActiviyGroupBuy:dispatchUpdateEvent(  )
	-- body
	local data = self:getData()
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE, data = data})
end


function QActiviyGroupBuy:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		self._goodsDiscountInfo = {}
		self._alreadyBuyInfo = {}
		self:dispatchUpdateEvent()
	end
end


function QActiviyGroupBuy:checkScoreRedTips(  )
	-- body
	local funcName = string.format("group_buying_%d", self.rowNum)
	local configs = QStaticDatabase:sharedDatabase():getScoreAwardsByLevel(funcName, remote.user.level)
    for k ,v in pairs(configs) do
        if not self:dailyRewardInfoIsGet(v.id) and (self._scoreInfo.groupBuyingScore or 0) >= v.condition then
			return true
		end
    end
    return false
end

function QActiviyGroupBuy:groupBuyInfoChange( )
	-- body
	self:requestGoodsDiscountInfo(function (  )
		self:dispatchUpdateEvent()
	end)
end

function QActiviyGroupBuy:checkRedTips( data )
	-- body
	if not self.isOpen then
		return false
	end
	if not data then 
		data = self:getData()
	end	
	if self:checkScoreRedTips() then
		return true
	end

	--有可以购买的
	local isHave = false
	for k ,v in pairs(data.goodsInfo) do
		if remote.user.level >= v.levelLimit and v.maxBuyCount - v.alreadyBuyCount > 0  then
			isHave = true
			break
		end
	end

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITYGROUPBUY) and isHave then
		return true
	end

	return false
end

function QActiviyGroupBuy:getData( )
	local goodsInfo = self._goodsInfo or {}
	local goodsLen = table.nums(goodsInfo)
	local temp 
	local data = {}
	data.goodsInfo = {}
	for k, v in ipairs(goodsInfo) do
		temp = {}
		local discountArr = string.split(v.discount or "", ";")
		local numPlayerArr = string.split(v.num_player or "", ";")
		local index = 0

		--根据购买人数 找到相应折扣
		local totalBuyCount = 0
		if self._goodsDiscountInfo[v.goodsId] then
			totalBuyCount = self._goodsDiscountInfo[v.goodsId].totalBuyCount
		
			if totalBuyCount >= tonumber(numPlayerArr[#numPlayerArr]) then
				index = #numPlayerArr
			else
				for i, buyNum in ipairs(numPlayerArr) do
					if totalBuyCount < tonumber(buyNum) then
						index = i - 1
						break
					end
				end
			end
		end

		if index <= 1 then
			index = 1
		end
		temp.curDiscount = tonumber(discountArr[index] or 100)

		temp.id = v.item
		temp.goodsID = v.goodsId
		temp.count = v.num
		temp.price = v.price
		temp.maxBuyCount = v.time
		temp.levelLimit = v.level_limit
		temp.buyNumArr = numPlayerArr
		temp.discountArr = discountArr
		temp.totalBuyCount = totalBuyCount

		local alreadyBuyCount = self._alreadyBuyInfo[v.goodsId] or 0
		temp.alreadyBuyCount = alreadyBuyCount
		table.insert(data.goodsInfo, temp)
	end
	data.curScore = self._scoreInfo.groupBuyingScore or 0
	data.endAt = self.endAt or 0
	data.showEndAt = self.showEndAt or 0
	return data
end


function QActiviyGroupBuy:dailyRewardInfoIsGet( id )
	-- body
	for k, v in pairs(self._scoreInfo.awardedScoreIds or {}) do
		if id == v then
			return true
		end
	end
	return false
end

function QActiviyGroupBuy:getDailyScore(  )
	-- body
	return self._scoreInfo.groupBuyingScore or 0
end


function QActiviyGroupBuy:requestGoodsDiscountInfo(success, fail)
	-- body
	local request = {api = "GROUP_BUYING_GET_GOODS_DISCOUNT_INFO", groupBuyingGetGoodsDiscountInfoRequest ={flag = self._flag or 0}}
	app:getClient():requestPackageHandler("GROUP_BUYING_GET_GOODS_DISCOUNT_INFO", request, function (data)
		-- body
		if data.groupBuyingGetGoodsDiscountInfoResponse then
			if data.groupBuyingGetGoodsDiscountInfoResponse.discounts then
				for k , v in pairs(data.groupBuyingGetGoodsDiscountInfoResponse.discounts) do
					self._goodsDiscountInfo[v.goodsId] = v
				end
			end
			if data.groupBuyingGetGoodsDiscountInfoResponse.flag then
				self._flag = data.groupBuyingGetGoodsDiscountInfoResponse.flag
			end
			if data.groupBuyingGetGoodsDiscountInfoResponse.groupBuyingInfoList then
				self._goodsInfo = data.groupBuyingGetGoodsDiscountInfoResponse.groupBuyingInfoList
			end
		end

		if success then
			success()
		end
	end, fail)
end


function QActiviyGroupBuy:requestUserBuyInfo( success, fail)
	-- body
	local request = {api = "GROUP_BUYING_GET_MY_GOODS_INFO"}
	app:getClient():requestPackageHandler("GROUP_BUYING_GET_MY_GOODS_INFO", request, function (data)
		-- body
		if data.groupBuyingGetMyGoodsInfoResponse then
			if data.groupBuyingGetMyGoodsInfoResponse.boughtGoods then

				self._alreadyBuyInfo = data.groupBuyingGetMyGoodsInfoResponse.boughtGoods
				self._alreadyBuyInfo = {}
				for k , v in pairs(data.groupBuyingGetMyGoodsInfoResponse.boughtGoods) do
					if self._alreadyBuyInfo[v.goodsId] then
						self._alreadyBuyInfo[v.goodsId] = self._alreadyBuyInfo[v.goodsId] + v.todayBuyCount
					else
						self._alreadyBuyInfo[v.goodsId] = v.todayBuyCount
					end
				end
			end

			if data.groupBuyingGetMyGoodsInfoResponse.myGroupBuying then
				self._scoreInfo = data.groupBuyingGetMyGoodsInfoResponse.myGroupBuying
			end
		end
		if success then
			success()
		end
	end, fail)
end



function QActiviyGroupBuy:getActivityInfoWhenLogin(success, fail)
	-- body
	return self:requestUserBuyInfo( success, fail)
end


function QActiviyGroupBuy:buyGoods( goodsId, discount, success, fail )
	-- body
	local groupBuyingBuyGoodsRequest = {goodsId = goodsId, discount = discount}
	local request = {api = "GROUP_BUYING_BUY_GOODS",groupBuyingBuyGoodsRequest = groupBuyingBuyGoodsRequest}
	app:getClient():requestPackageHandler("GROUP_BUYING_BUY_GOODS", request, function ( data )
		-- body
		if self._alreadyBuyInfo[goodsId] then
			self._alreadyBuyInfo[goodsId] = self._alreadyBuyInfo[goodsId] + 1
		else
			self._alreadyBuyInfo[goodsId] = 1
		end

		if data.groupBuyingBuyGoodsResponse and data.groupBuyingBuyGoodsResponse.myGroupBuying then
			self._scoreInfo.groupBuyingScore = data.groupBuyingBuyGoodsResponse.myGroupBuying.groupBuyingScore
		end

		if self._goodsDiscountInfo[goodsId] then
			self._goodsDiscountInfo[goodsId].totalBuyCount = self._goodsDiscountInfo[goodsId].totalBuyCount + 1
		else
			self._goodsDiscountInfo[goodsId] = {}
			self._goodsDiscountInfo[goodsId].totalBuyCount = 1
			self._goodsDiscountInfo[goodsId].goodsId = goodsId
		end
		
		if success then
			success(data)
		end
		self:dispatchUpdateEvent()

	end,function ( data )
		-- body
		if data.error == "GROUP_BUYING_BUY_DISCOUNT_CHANGED" then
			self:requestGoodsDiscountInfo(function (  )
				self:dispatchUpdateEvent()
			end)
		end
	end)

end

function QActiviyGroupBuy:getScoreAwards( awardIndex ,success, fail)
	-- body
	local groupBuyingGetScoreAwardRequest = {awardIds = awardIndex}
	local request = {api = "GROUP_BUYING_GET_SCORE_AWARD",groupBuyingGetScoreAwardRequest = groupBuyingGetScoreAwardRequest}
	app:getClient():requestPackageHandler("GROUP_BUYING_GET_SCORE_AWARD", request, function ( data )
		-- body
		if not self._scoreInfo.awardedScoreIds then
			self._scoreInfo.awardedScoreIds = {}
		end

		for k, v in pairs(awardIndex) do
			table.insert(self._scoreInfo.awardedScoreIds, v)
		end
		if success then
			success(data)
		end
		self:dispatchUpdateEvent()
	end)

end


return QActiviyGroupBuy