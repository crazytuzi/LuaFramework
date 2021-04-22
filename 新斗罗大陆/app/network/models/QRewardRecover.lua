--
-- Author: Kumo.Wang
-- Date: Sat Mar  5 18:30:36 2016
-- 福利追回

local QBaseModel = import("...models.QBaseModel")
local QRewardRecover = class("QRewardRecover", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QRewardRecover:ctor()
	QRewardRecover.super.ctor(self)
end

function QRewardRecover:init()
	self.isShowRedTips = true
	self.isAutoOpened = false -- 登入弹脸
	self.isSellOut = true -- 可付费购买的项目是否售罄

	self.payRewardTakenInfoTbl = {}
end

function QRewardRecover:disappear()
end

function QRewardRecover:loginEnd()

end

function QRewardRecover:setIsShowRedTips( boo )
	self.isShowRedTips = boo
end

function QRewardRecover:getIsShowRedTips()
	if self.isFreeRewardTaken == true and self:checkPayRewardSellOut() then
		self.isShowRedTips = false
	end
	-- print("[Kumo] QRewardRecover:getIsShowRedTips() ", self.isFreeRewardTaken, self.isSellOut)
	return self.isShowRedTips
end

function QRewardRecover:checkPayRewardSellOut()
	self:getTokenAwardList()
	return self.isSellOut
end

function QRewardRecover:savePlayerRecoverInfo( data )
	self.isFreeRewardTaken = data.isFreeRewardTaken
	if self.payRewardTakenInfo ~= data.payRewardTakenInfo then
		self.payRewardTakenInfo = data.payRewardTakenInfo
		self:_analysisPayRewardTakenInfo()
	end
	self.startAt = data.startAt
	self.endAt = data.endAt
	self.lastOpenAt = data.lastOpenAt
end

function QRewardRecover:saveDailyTeamLevel( level )
	self.dailyTeamLevel = level
	self:_analysisConfig()
end

function QRewardRecover:_analysisConfig()
	local rewardRecoverConfig = QStaticDatabase.sharedDatabase():getRewardRecover()
	-- QPrintTable(rewardRecoverConfig)

	local freeTbl = {}
	local tokenTbl = {}

	for _, config in pairs(rewardRecoverConfig) do
		for _, award in pairs(config) do
			-- print("[Kumo] ", award.level_min, self.dailyTeamLevel, award.level_max)
			if tonumber(award.level_min) <= tonumber(self.dailyTeamLevel) and tonumber(award.level_max) >= tonumber(self.dailyTeamLevel) then
				if tonumber(award.type) == 1 then
					-- free
					table.insert(freeTbl, award)
				else
					-- token
					table.insert(tokenTbl, award)
				end
			end
		end
	end

	table.sort(freeTbl, function( a, b ) return a.id < b.id end)
	self._freeAwardList = freeTbl
	-- QPrintTable(self._freeAwardList)
	table.sort(tokenTbl, function( a, b ) return a.id < b.id end)
	self._tokenAwardList = tokenTbl
	-- QPrintTable(self._tokenAwardList)
end

-- 根据item的id返回item的type
function QRewardRecover:getItemTypeById( itemId )
	local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( itemId )
	if not itemConfig then
		app.tip:floatTip("没有id["..itemId.."]的配置，请策划检查量表")
		return 1
	end
	return itemConfig.type
end

function QRewardRecover:getFreeAwardList()
	return self._freeAwardList
end

function QRewardRecover:getTokenAwardList( id )
	if id then
		for key, award in pairs(self._tokenAwardList) do
			if tonumber(award.id) == tonumber(id) then
				if self.payRewardTakenInfoTbl[tostring(award.id)] then
					if tonumber(self.payRewardTakenInfoTbl[tostring(award.id)]) == tonumber(award.buy_times) then
						local v = award
						table.remove(self._tokenAwardList, key)
						table.insert(self._tokenAwardList, v)
					end
				end
				return self._tokenAwardList
			end
		end
		return self._tokenAwardList
	else
		self.isSellOut = true
		local removeTbl = {}
		for key, award in pairs(self._tokenAwardList) do
			if self.payRewardTakenInfoTbl[tostring(award.id)] then
				if tonumber(self.payRewardTakenInfoTbl[tostring(award.id)]) == tonumber(award.buy_times) then
					local tbl = { key = key, award = award }
					table.insert(removeTbl, tbl)
				else
					-- 存在没有买光的项目
					self.isSellOut = false
				end
			else
				-- 存在没有买光的项目
				self.isSellOut = false
			end
		end
		table.sort(removeTbl, function( a, b )  
				return a.key > b.key
			end)
		-- QPrintTable(removeTbl)
		for _, value in pairs(removeTbl) do
			table.remove(self._tokenAwardList, value.key)
		end
		for _, value in pairs(removeTbl) do
			table.insert(self._tokenAwardList, value.award)
		end
		return self._tokenAwardList
	end
end

function QRewardRecover:getIsFreeRewardTaken()
	return self.isFreeRewardTaken
end

function QRewardRecover:getPayRewardTakenInfoTbl()
	return self.payRewardTakenInfoTbl
end

-- 格式：id^购买次数;id^购买次数;id^购买次数;  ----> tbl[id] = count
function QRewardRecover:_analysisPayRewardTakenInfo()
	self.payRewardTakenInfoTbl = {}
	if not self.payRewardTakenInfo or self.payRewardTakenInfo == "" then return end

	local tbl1 = string.split(self.payRewardTakenInfo, ";")
	-- QPrintTable(tbl1)
	for _, value in pairs(tbl1) do
		local tbl2 = string.split(value, "^")
		self.payRewardTakenInfoTbl[tbl2[1]] = tbl2[2]
	end
	-- QPrintTable(self.payRewardTakenInfoTbl)
end

function QRewardRecover:getStartAt()
	return self.startAt
end

function QRewardRecover:getEndAt()
	return self.endAt
end

function QRewardRecover:getLastOpenAt()
	return self.lastOpenAt
end

function QRewardRecover:isShowFuliIcon()
	if self.endAt and (q.serverTime() * 1000) < self.endAt then
		return true
	end

	return false
end

function QRewardRecover:setIsAutoOpened( boo )
	self.isAutoOpened = boo
end

function QRewardRecover:IsFirstOpen()
	if not self.isAutoOpened and self.lastOpenAt and self.startAt and self.lastOpenAt < self.startAt then
		return true
	end

	return false
end

function QRewardRecover:getStartToEndDate()
	local curStartTimeTbl = q.date("*t", self.lastOpenAt/1000)
	local curEndTimeTbl = q.date("*t", self.startAt/1000)
	-- print("#日期："..curStartTimeTbl.year.."/"..curStartTimeTbl.month.."/"..curStartTimeTbl.day.."#星期："..(curStartTimeTbl.wday - 1).."#时间："..curStartTimeTbl.hour..":"..curStartTimeTbl.min..":"..curStartTimeTbl.sec)
	local str = curStartTimeTbl.month.."月"..curStartTimeTbl.day.."日-"..curEndTimeTbl.month.."月"..curEndTimeTbl.day.."日"
	-- return "昨天"
	return str
end

-- 倒计时
function QRewardRecover:updateTime()
	local isOvertime = false
	local startTime = 0
	local endTime = self.endAt
	local nowTime = q.serverTime() * 1000
	local timeStr = ""
	local color = ccc3(255, 63, 0) -- 红色
	if nowTime >= endTime then
		isOvertime = true
	else
		local sec = (endTime - nowTime) / 1000
		if sec >= 30*60 then
			color = ccc3(255, 216, 44)
		else
			color = ccc3(255, 63, 0)
		end
		local h, m, s = self:_formatSecTime( sec )
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end

	return isOvertime, timeStr, color
end

-- 将秒为单位的数字转换成 00：00：00格式
function QRewardRecover:_formatSecTime( sec )
	local h = math.floor((sec/3600)%24)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)

	return h, m, s
end

-- awardStr : consortia_money^730; consortia_money; 23^73; 23
function QRewardRecover:getItemBoxParaMetet( awardStr )
	local idOrType = ""
	local count = 0
	local itemType = -1

	local s, e = string.find(awardStr, "%^")
    if s then
        local a = string.sub(awardStr, 1, s - 1)
        local b = string.sub(awardStr, e + 1)
        idOrType = a
        count = tonumber(b)
    else
        idOrType = awardStr
        count = 0
    end
    local n = tonumber(idOrType)
    if n then
        -- 数字， item
       	itemType = self:getItemTypeById( idOrType )
   	 	if itemType == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
            return idOrType, ITEM_TYPE.GEMSTONE_PIECE, count
        elseif itemType == ITEM_CONFIG_TYPE.GEMSTONE then
        	return idOrType, ITEM_TYPE.GEMSTONE, count
        else
        	return idOrType, ITEM_TYPE.ITEM, count
        end
    end
    -- 字母，resource
    return nil, idOrType, count
end

--[[
	PLAYER_RECOVER_GET_REWARD                   = 9210;                     //福利追回领取奖励 PlayerRecoverGetRewardRequest, 返回PlayerRecoverGetRewardResponse
]]

-- 福利追回领取奖励 PlayerRecoverGetRewardRequest, 返回PlayerRecoverGetRewardResponse
--[[
	enum RewardType {
        FREE_TYPE = 1;
        PAY_TYPE = 2;
    }
]]
-- optional RewardType rewardType = 1;                           // 奖励类型
-- optional int32 rewardId = 2;                                  // 奖励ID
-- optional int32 count = 3;                                     // 奖励购买数
function QRewardRecover:playerRecoverGetRewardRequest(rewardType, rewardId, success, fail, status)
	local playerRecoverGetRewardRequest = { rewardType = rewardType, rewardId = rewardId }
    local request = { api = "PLAYER_RECOVER_GET_REWARD", playerRecoverGetRewardRequest = playerRecoverGetRewardRequest }
    app:getClient():requestPackageHandler("PLAYER_RECOVER_GET_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QRewardRecover:responseHandler( response, successFunc, failFunc )
	-- QPrintTable( response )
	if successFunc then 
        successFunc(response) 
        -- self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    -- self:_dispatchAll()
end

return QRewardRecover
