-- GroupBuyData.lua

require("app.cfg.group_buy_award_info")

local storage       = require("app.storage.storage")
local GroupBuyConst = require("app.const.GroupBuyConst")

local table = table
local ipairs = ipairs

local GroupBuyData = class("GroupBuyData")

function GroupBuyData:ctor()
	self._serverBuyCount   = 0  -- 当前全服购买次数
	self._score            = 0  -- 积分
	self._backGold 		   = 0  -- 活动结束返还的元宝
	self._configInfo       = {} -- 配置信息
	self._timeConfigInfo   = {} -- 活动时间信息
	self._itemBuyTimesInfo = {} -- 购买次数信息
	self._endInfo          = {} -- 活动结束信息
	self._normalRankInfo   = {} -- 普通排行榜信息
	self._normalRankList   = {} -- 普通排行榜列表
	self._luxuryRankInfo   = {} -- 豪华排行榜信息
	self._luxuryRankList   = {} -- 豪华排行榜列表
	self._awardInfo        = {} -- 奖励列表
	self._dailyAwardIds    = {} -- 每日已经领取的id列表

	self:_loadConfigInfoFromFile()
end

function GroupBuyData:_loadConfigInfoFromFile()
	local info = storage.load(storage.path(GroupBuyConst.CONFIG_FILE_NAME))
	if info then
		self._configInfo = info
	end
end

function GroupBuyData:saveConfigInfoToFile()
	-- 这些数据信息量很大，so缓存一份到本地，用一个md5字符串来验证是否需要更新
	storage.save(storage.path(GroupBuyConst.CONFIG_FILE_NAME), self._configInfo)
end

function GroupBuyData:getConfigMd5()
	return self._configInfo.md5
end

function GroupBuyData:updateConfigInfoFromServer(info)
	if type(info) ~= "table" then return end
	self._configInfo = info
	self:saveConfigInfoToFile()
end

function GroupBuyData:getAwardEndTime()
	return self._timeConfigInfo.award_end_time
end

function GroupBuyData:getEndTime()
	return self._timeConfigInfo.end_time
end

function GroupBuyData:getGoodsItems()
	local list = {}
	for i, v in ipairs(self._configInfo.items or {}) do
		if v.level <= G_Me.userData.level and v.vip_level <= G_Me.userData.vip then
			table.insert(list, v)
		end
	end

	table.sort(list, function(a, b) return a.id < b.id end)
	return list
end

function GroupBuyData:setTimeConfig(info)
	if type(info) ~= "table" then return end
	self._timeConfigInfo = info
end

function GroupBuyData:getTimeConfig()
	return self._timeConfigInfo
end

function GroupBuyData:getGoodsItemById(id)
	if type(id) ~= "number" then return end
	local items = self:getGoodsItems()
	for i, v in ipairs(items) do
		if v.id == id then
			return v
		end
	end
end

function GroupBuyData:getTimeStatusType()
	local nowTime = G_ServerTime:getTime()
	local startTime = self._timeConfigInfo.start_time
	local rawardTime = self._timeConfigInfo.end_time
	local endTime = self._timeConfigInfo.award_end_time

	if startTime and endTime and rawardTime then
		if nowTime >= startTime and nowTime < rawardTime then 
			return GroupBuyConst.TIME_STATUS_TYPE.RUNNING
		elseif nowTime >= rawardTime and nowTime < endTime then
			return GroupBuyConst.TIME_STATUS_TYPE.REWARD
		elseif nowTime >= endTime then
			return GroupBuyConst.TIME_STATUS_TYPE.END
		else
			return GroupBuyConst.TIME_STATUS_TYPE.UN_OPEN
		end
	end
	return GroupBuyConst.TIME_STATUS_TYPE.UN_OPEN
end

function GroupBuyData:isOpen()
	if GlobalFunc.table_is_empty(self._configInfo) then return false end
	local nowTimeType = self:getTimeStatusType()
	return nowTimeType == GroupBuyConst.TIME_STATUS_TYPE.RUNNING or nowTimeType == GroupBuyConst.TIME_STATUS_TYPE.REWARD
end

function GroupBuyData:setScore(score)
	if type(score) ~= "number" then return end
	self._score = score
end

function GroupBuyData:getScore()
	return self._score
end

function GroupBuyData:getCoupon()
	return G_Me.userData.coupon
end

function GroupBuyData:setBackGold(gold)
	if type(gold) ~= "number" then return end
	self._backGold = gold
end

function GroupBuyData:getBackGold()
	return self._backGold
end

function GroupBuyData:setItemBuyTimesInfos(info)
	if type(info) ~= "table" then return end
	self._itemBuyTimesInfo = info
end

function GroupBuyData:getItemBuyTimesInfo()
	return self._itemBuyTimesInfo
end

function GroupBuyData:getItemBuyTimesInfoById(id)
	if type(id) ~= "number" then return end
	local infos = self:getItemBuyTimesInfo()
	for i, v in ipairs(infos) do
		if v.id == id then return v end
	end
end

function GroupBuyData:addItemBuyTimeInfo(info)
	if type(info) ~= "table" then return end
	table.insert(self._itemBuyTimesInfo, info)
end

function GroupBuyData:setMainDataFromServer(info)
	if type(info) ~= "table" then return end
	self:setScore(info.score)
	self:setItemBuyTimesInfos(info.item_datas)
end

function GroupBuyData:updateItemBuyTimesInfoById(info)
	if type(info) ~= "table" then return end
	local targetInfo = self:getItemBuyTimesInfoById(info.id)
	if targetInfo then
		targetInfo.self_count = info.self_count or 0
		targetInfo.server_count = info.server_count or 0
	else
		self:addItemBuyTimeInfo(info)
	end
end

function GroupBuyData:setEndInfo(info)
	if type(info) ~= "table" then return end
	self._endInfo = info
end

function GroupBuyData:getEndInfo()
	return self._endInfo
end

function GroupBuyData:setServerBuyCount(count)
	if type(count) ~= "number" then return end
	self._serverBuyCount = count
end

function GroupBuyData:getServerBuyCount()
	return self._serverBuyCount
end

function GroupBuyData:setDailyAwardIds(ids)
	if type(ids) ~= "table" then 
		self._dailyAwardIds = {}
		assert("GroupBuyData:setDailyAwardIds param .ids. is not a table")
	end
	self._dailyAwardIds = ids
end

function GroupBuyData:getDailyAwardIds()
	return self._dailyAwardIds
end

function GroupBuyData:isDailyAwardAlreadyGet(id)
	if type(id) ~= "number" then return end
	for i, v in ipairs(self._dailyAwardIds) do 
		if v == id then return true end
	end
	return false
end

function GroupBuyData:setSelfNormalRankInfo(info)
	if type(info) ~= "table" then return end
	self._normalRankInfo = info
end

function GroupBuyData:getSelfNormalRankInfo()
	return self._normalRankInfo
end

function GroupBuyData:setSelfLuxuryRankInfo(info)
	if type(info) ~= "table" then return end
	self._luxuryRankInfo = info
end

function GroupBuyData:getSelfLuxuryRankInfo()
	return self._luxuryRankInfo
end

function GroupBuyData:addNormalRank(info)
	if type(info) ~= "table" then return end
	table.insert(self._normalRankList, info)
end

function GroupBuyData:getNormalRankList()
	return self._normalRankList
end

function GroupBuyData:addLuxuryRank(info)
	if type(info) ~= "table" then return end
	table.insert(self._luxuryRankList, info)
end

function GroupBuyData:getLuxuryRankList()
	return self._luxuryRankList
end

function GroupBuyData:clearAllRankList()
	self._normalRankInfo = {}
	self._luxuryRankList = {}
end

function GroupBuyData:getAwardData()
	local list = {}
	for i = 1, group_buy_award_info.getLength() do
		local v = group_buy_award_info.indexOf(i)
		if v.task_type == GroupBuyConst.DAILY_AWARD_TYPE.BACKGOLD then
			local gold = self:getBackGold()
			if gold > 0 then
				v["type_1"] = G_Goods.TYPE_GOLD
				v["size_1"] = gold
				table.insert(list, v)
			end
		else
			table.insert(list, v)
		end
	end
	return list
end

function GroupBuyData:isCanReward()
	if GlobalFunc.table_is_empty(self._configInfo) then return false end
	local awardList = self:getAwardData()
	for i, v in ipairs(awardList) do
		local progress = 0
		if v.task_type == GroupBuyConst.DAILY_AWARD_TYPE.SELF then
			progress = self:getScore()
		elseif v.task_type == GroupBuyConst.DAILY_AWARD_TYPE.ALL then
			progress = self:getServerBuyCount()
		end
		if not self:isDailyAwardAlreadyGet(v.id) and progress >= v.condition then
			return true
		end

		if v.task_type == GroupBuyConst.DAILY_AWARD_TYPE.BACKGOLD then
			local gold = self:getBackGold()
			if gold > 0 and not self:isDailyAwardAlreadyGet(v.id) then
				return true
			end
		end
	end

	return false
end

-- 是否满足功能使用条件
function GroupBuyData:isMeetConditionsOfUse()
	local timeInfo = self:getTimeConfig() or {}
	local level = timeInfo.level or 0
	local vip = timeInfo.vip_level or 0
	if level > G_Me.userData.level then
		return false
	elseif vip > G_Me.userData.vip then
		return false
	end
	return self:isOpen()
end

----------------------------- 协议解析 --------------------------------
function GroupBuyData:disposeRankBuffer(db)
	if db.type == GroupBuyConst.RANK_AWARD_TYPE.NORMAL then
   		local info = {self_rank_id = db.self_rank_id, handred_score = db.handred_score}
   		self._data:setSelfNormalRankInfo(info)
   		for i,v in ipairs(db.gb_user) do
   			if v.id and v.id ~= 0 then
   				self:addNormalRank(v)
   			end
   		end
   	elseif db.type == GroupBuyConst.RANK_AWARD_TYPE.LUXURY then
   		local info = {self_rank_id = db.self_rank_id, handred_score = db.handred_score}
   		self._data:setSelfLuxuryRankInfo(info)
   		for i,v in ipairs(db.gb_user) do
   			if v.id and v.id ~= 0 then
   				self:addLuxuryRank(v)
   			end
   		end
   	end
end

return GroupBuyData