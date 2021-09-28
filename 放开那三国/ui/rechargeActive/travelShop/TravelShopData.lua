-- Filename：	TravelShopData.lua
-- Author：		bzx
-- Date：		2015-9-6
-- Purpose：		云游商人数据

module ("TravelShopData", package.seeall)


local _travelShopInfo = {}
local _allRewardInfo = nil
local _lastScore = nil

function setTravelShopInfo( p_travelShopInfo)
	_travelShopInfo = p_travelShopInfo
	for i = 1, #_travelShopInfo.reward do
		local id = _travelShopInfo.reward[i]
		_travelShopInfo.reward[i] = nil
		_travelShopInfo.reward[tonumber(id)] = "1"
	end
	_lastScore = tonumber(_travelShopInfo.score)
end

function getTravelShopInfo( ... )
	return _travelShopInfo
end

-- 买商品
function handleBuyInfo(p_goodsId, p_num, p_dataRet)
	local curCount = tonumber(_travelShopInfo.buy[tostring(p_goodsId)] or 0)
	_travelShopInfo.buy[tostring(p_goodsId)] = curCount + p_num
	if p_dataRet ~= nil and p_dataRet ~= "0" then
		_travelShopInfo.finish_time = p_dataRet
		_travelShopInfo.topup = 0
		if not table.isEmpty(_travelShopInfo.payback) then
			_travelShopInfo.payback[tostring(table.count(_travelShopInfo.payback))] = "1"
		end
	end
end

-- 增加购买积分
function addScore( p_score )
	_travelShopInfo.score = tonumber(_travelShopInfo.score) + p_score
end

-- 活动开始时间
function getStartTime( ... )
	return tonumber(ActivityConfigUtil.getDataByKey("travelShop").start_time)
end

-- 活动结束时间
function getEndTime( ... )
	local endTime = tonumber(ActivityConfigUtil.getDataByKey("travelShop").end_time)
	-- 留一小时发奖励到奖励中心，如果不留后端拿不到配置
	return endTime - 3600
end

-- 活动是否开启
function isOpen( ... )
	if not ActivityConfigUtil.isActivityOpen("travelShop") then
		return false
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	return curTime < getEndTime()
end

-- 积分上限
function getScoreLimit( ... )
	return 100
end

-- 是否已经开启了充值优惠
function isOpenCzyh( ... )
	return getScore() >= getScoreLimit()
end

-- 得到当前积分
function getScore( ... )
	return tonumber(_travelShopInfo.score)
end

-- 领取充值返利
function handlePayback()
	_travelShopInfo.payback[tostring(table.count(_travelShopInfo.payback))] = "1"
end

--[[
	@desc:				得到商品的剩余购买次数
	@param:	p_id 		商品id
	@param:	p_config 	商品的配置信息
--]]
function getGoodsRemainBuyCount(p_id, p_config)
	local config = nil
	if p_config ~= nil then
		config = p_config
	else
		-- TODO
	end
	local boughtCount = _travelShopInfo.buy[tostring(p_config.id)] or 0
	local totalCount = tonumber(config.num)
	local remainCount = totalCount - boughtCount
	return remainCount
end

-- 得到普天同庆里的所有奖励信息
function getAllRewardInfo( ... )
	if _allRewardInfo ~= nil then
		return _allRewardInfo
	end
	_allRewardInfo = {}
	local rewardConfig = ActiveCache.getTravelShopConfig()[1]["all_reward"]
	local rewardInfos = parseField(rewardConfig, 2)
	for i = 1, #rewardInfos do
		local reward = {}
		local rewardInfo = rewardInfos[i]
		local items = ItemUtil.getServiceReward({{rewardInfo[2], rewardInfo[3], rewardInfo[4]}})
		reward.items = items
		reward.needBuyCount = rewardInfo[1]
		reward.id = rewardInfo[1]
		table.insert(_allRewardInfo, reward)
	end
	return _allRewardInfo
end

-- 是否有充值返利可领取
function canReceiveCzyhReward( ... )
	return _travelShopInfo.payback[tostring(table.count(_travelShopInfo.payback))] == "0"
end

-- 得到充值优惠剩余时间
function getCzyhRemainTime( ... )
	local startTime = tonumber(_travelShopInfo.finish_time)
	if startTime <= 0 then
		return 0
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	local czyhCd = tonumber(ActiveCache.getTravelShopConfig()[1]["recharge_time"])
	local remainTime = czyhCd - (curTime - startTime)
	if remainTime < 0 then
		remainTime = 0
	end
	if remainTime == 0 then
		resetScoreProgress()
		local rechargeRewardConfig = ActiveCache.getTravelShopConfig()[1]["recharge_reward"]
		local rechargeRewardInfos = parseField(rechargeRewardConfig, 2)
		_travelShopInfo.payback[tostring(table.count(_travelShopInfo.payback))] = "1"
	end
	return remainTime
end

-- 重置积分进度
function resetScoreProgress( ... )
	_travelShopInfo.finish_time = 0
	_travelShopInfo.score = 0
	_travelShopInfo.topup = 0
end

-- 得到当前充值的金币数量
function getCurBuyGoldCount( ... )
	return tonumber(_travelShopInfo.topup or 0) 
end

-- 当前充值优惠的信息
function getCurCzyhRewardInfo( ... )
	local rechargeRewardConfig = ActiveCache.getTravelShopConfig()[1]["recharge_reward"]
	local rechargeRewardInfos = parseField(rechargeRewardConfig, 2)
	local rechargeRewardIndex = nil
	local curCount = table.count(_travelShopInfo.payback)
	local total = #rechargeRewardInfos
	if curCount > total then
		rechargeRewardIndex = total
	else
		if _travelShopInfo.payback[tostring(curCount)] == "1" then
			rechargeRewardIndex = curCount + 1
		else
			rechargeRewardIndex = curCount
		end
		if rechargeRewardIndex <= 0 then
			rechargeRewardIndex = 1
		elseif rechargeRewardIndex > total then
			rechargeRewardIndex = total
		end
	end
	return rechargeRewardInfos[rechargeRewardIndex]
end

-- 得到在当天会用到的配置
function getCurTravelShopConfig( ... )
	local curTravelShopConfig = {}
	local travelShopConfig = ActiveCache.getTravelShopConfig()
	local travelShopData = ActivityConfigUtil.getDataByKey("travelShop")
	local startTime = tonumber(travelShopData.start_time)
	local startDate = os.date("*t", startTime)
	startDate.hour = 0
	startDate.min = 0
	startDate.sec = 0
	local startZeroTime = os.time(startDate)
	local curTime = TimeUtil.getSvrTimeByOffset()
	local dayCount = math.ceil((curTime - startZeroTime) / 86400)
	for i = 1, #travelShopConfig do
		local days = parseField(travelShopConfig[i].day, 1)
		for j = 1, #days do
			if days[j] == dayCount then
				table.insert(curTravelShopConfig, travelShopConfig[i])
				break
			end
		end
	end
	return curTravelShopConfig
end

--[[
	@desc:			领取了普天同庆里的奖励
	@param: p_id 	奖励id
--]]
function handleRewardInfo( p_id )
	_travelShopInfo.reward[p_id] = "1"
end

--[[
	@desc:				普天同庆里的奖励是否已经领取
	@param: 	p_id 	奖励id
--]]
function rewardIsReceived( p_id )
	return _travelShopInfo.reward[p_id] == "1"
end

--[[
	@desc:				普天同庆是否有可领取的
--]]
function canReceive( ... )
	if not TravelShopData.isOpen() then
		return false
	end
	local allRewardInfo = getAllRewardInfo()
	for i = 1, #allRewardInfo do
		local rewardInfo = allRewardInfo[i]
		if rewardInfo.needBuyCount <= tonumber(_travelShopInfo.sum) and not rewardIsReceived(rewardInfo.id) then
			return true
		end
	end
	return false
end