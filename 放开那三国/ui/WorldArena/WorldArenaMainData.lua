-- FileName: WorldArenaMainData.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决数据
--[[TODO List]]

module("WorldArenaMainData", package.seeall)
require "script/utils/TimeUtil"
require "script/model/utils/ActivityConfigUtil"

local _worldArenaInfo 				= nil 	-- 巅峰对决数据

local _skipData 					= 0 	-- 是否跳过战斗 0不跳过，1跳过

--[[
	@des 	: 设置巅峰对决数据
	@param 	: 
	@return :
--]]
function setWorldArenaInfo( p_info )
	_worldArenaInfo = p_info
end

--[[
	@des 	: 得到巅峰对决数据
	@param 	: 
	@return :
--]]
function getWorldArenaInfo( ... )
	return _worldArenaInfo 
end

--[[
	@des 	: 更新巅峰对决数据
	@param 	: 
	@return :
--]]
function updateWorldArenaInfo( p_info )
	if( table.isEmpty(p_info) )then
		return
	end
	-- 更新信息
	_worldArenaInfo.extra = p_info
end

--[[
	@des 	: 报名开始时间
	@param 	: 
	@return : num
--]]
function getSignUpStartTime( ... )
	return tonumber(_worldArenaInfo.signup_bgn_time)
end

--[[
	@des 	: 报名结束时间
	@param 	: 
	@return : num
--]]
function getSignUpEndTime( ... )
	return tonumber(_worldArenaInfo.signup_end_time)
end

--[[
	@des 	: 攻打开始时间
	@param 	: 
	@return : num
--]]
function getAttackStartTime( ... )
	return tonumber(_worldArenaInfo.attack_bgn_time)
end

--[[
	@des 	: 攻打结束时间
	@param 	: 
	@return : num
--]]
function getAttackEndTime( ... )
	return tonumber(_worldArenaInfo.attack_end_time)
end

--[[
	@des 	: 活动结束时间
	@param 	: 
	@return : num
--]]
function getWorldArenaEndTime( ... )
	return tonumber(_worldArenaInfo.period_end_time)
end

--[[
	@des 	: 得到我的报名时间 0是没报名
	@param 	: 
	@return : num
--]]
function getMySignUpTime( ... )
	return tonumber(_worldArenaInfo.signup_time)
end

--[[
	@des 	: 设置我的报名时间
	@param 	: 
	@return : 
--]]
function setMySignUpTime( p_time )
	_worldArenaInfo.signup_time = p_time
end

--[[
	@des 	: 得到上次更新战斗力时间
	@param 	: 
	@return : num
--]]
function getlastUpdateFightForceTime( ... )
	local retData = 0 
	if( not table.isEmpty(_worldArenaInfo.extra) )then
		retData = tonumber(_worldArenaInfo.extra.update_fmt_time)
	end
	return retData
end

--[[
	@des 	: 设置上次更新战斗力时间
	@param 	: 
	@return : 
--]]
function setlastUpdateFightForceTime( p_time )
	if( not table.isEmpty(_worldArenaInfo.extra) )then
		_worldArenaInfo.extra.update_fmt_time = p_time
	else
		_worldArenaInfo.extra = {}
		_worldArenaInfo.extra.update_fmt_time = p_time
	end
end

--[[
	@des 	: 得到活动是否开启
	@param 	: 
	@return : true or false
--]]
function getworldArenaIsOpen( ... )
	local retData = false
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local startTime = getSignUpStartTime()
	if( tonumber(_worldArenaInfo.team_id) > 0 and curTime >= startTime )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到活动配置
	@param 	: 
	@return : 
--]]
function getworldArenaConfig( ... )
	local configData = ActivityConfigUtil.getDataByKey("worldarena").data[1]
	return configData
end

--[[
	@des 	: 得到报名需要的等级
	@param 	: 
	@return : num
--]]
function getworldArenaNeedLv( ... )
	local configData = getworldArenaConfig()
	return tonumber(configData.level)
end

--[[
	@des 	: 得到更新战斗力的cd
	@param 	: 
	@return : num
--]]
function getUpdateFightForceCD( ... )
	local configData = getworldArenaConfig()
	return tonumber(configData.update_tiem)
end

--[[
	@des 	: 得到最后10分钟挑战的cd
	@param 	: 
	@return : num
--]]
function getFightCDLastTen( ... )
	local configData = getworldArenaConfig()
	local retNum = 0
	if( configData.cd_time )then
		retNum = tonumber(configData.cd_time)+1
	end
	return retNum
end

--[[
	@des 	: 得到上次主动挑战的时间
	@param 	: 
	@return : num
--]]
function getLastAttackTime( ... )
	return tonumber(_worldArenaInfo.extra.last_attack_time) 
end

--[[
	@des 	: 得到是否在最后10分钟
	@param 	: 
	@return : ture or false
--]]
function getIsInLastTen()
	local retData = false
	if( TimeUtil.getSvrTimeByOffset(0) >= tonumber(_worldArenaInfo.attack_end_time)- tonumber(_worldArenaInfo.cd_duration_before_end) and
		TimeUtil.getSvrTimeByOffset(0) < tonumber(_worldArenaInfo.attack_end_time) )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到购买挑战最大次数
	@param 	: 
	@return : num
--]]
function getBuyAtkMaxNum()
	local configData = getworldArenaConfig()
	local costStr = string.split(configData.buy_num, ",")
	local temp = string.split(costStr[#costStr], "|")
	local retData = tonumber(temp[1])
	return retData
end

--[[
	@des 	: 得到购买挑战次数花费
	@param 	: p_num 购买次数
	@return : num
--]]
function getBuyAtkNumCost( p_num )
	local configData = getworldArenaConfig()
	local haveBuyNum = getHaveBuyAtkNum()
	local costStr = string.split(configData.buy_num, ",")

	local retData = 0
	for i=1,p_num do
		local nextNum = haveBuyNum + i
		for i=1,#costStr do
			local temp = string.split(costStr[i], "|")
			if( nextNum <= tonumber(temp[1]) )then
				retData = retData + tonumber(temp[2])
				break
			end
		end
	end

	return retData
end

--[[
	@des 	: 得到剩余挑战次数
	@param 	: 
	@return : num
--]]
function getAtkNum( ... )
	return tonumber(_worldArenaInfo.extra.atk_num) or 0
end

--[[
	@des 	: 设置剩余挑战次数
	@param 	: 
	@return : 
--]]
function setAtkNum( p_num )
	_worldArenaInfo.extra.atk_num = p_num
end

--[[
	@des 	: 得到已购买挑战次数
	@param 	: 
	@return : num
--]]
function getHaveBuyAtkNum( ... )
	return tonumber(_worldArenaInfo.extra.buy_atk_num) or 0
end

--[[
	@des 	: 设置已购买挑战次数
	@param 	: 
	@return : num
--]]
function setHaveBuyAtkNum( p_num )
	_worldArenaInfo.extra.buy_atk_num = p_num
end

--[[
	@des 	: 得到银币重置下次花费
	@param 	: p_num 
	@return : num
--]]
function getNextResetCostBySilver()
	local configData = getworldArenaConfig()
	local costStr = string.split(configData.silver_recover, ",")
	local curNum = getHaveResetNumBySilver()
	local nextNum = curNum + 1
	local retData = 0
	for i=1,#costStr do
		local temp = string.split(costStr[i], "|")
		if( nextNum <= tonumber(temp[1]) )then
			retData = tonumber(temp[2])
			break
		end
	end
	return retData
end

--[[
	@des 	: 得到银币重置最大次数
	@param 	:  
	@return : num
--]]
function getMaxResetNumBySilver()
	local configData = getworldArenaConfig()
	local costStr = string.split(configData.silver_recover, ",")
	local temp = string.split(costStr[#costStr], "|")
	local retData = tonumber(temp[1])
	return retData
end

--[[
	@des 	: 得到银币已重置次数
	@param 	: 
	@return : num
--]]
function getHaveResetNumBySilver( ... )
	return tonumber(_worldArenaInfo.extra.silver_reset_num)
end

--[[
	@des 	: 设置银币已重置次数
	@param 	: 
	@return : 
--]]
function setHaveResetNumBySilver( p_num )
	_worldArenaInfo.extra.silver_reset_num = p_num
end

--[[
	@des 	: 得到金币重置下次花费
	@param 	: p_num 
	@return : num
--]]
function getNextResetCostByGold()
	local configData = getworldArenaConfig()
	local costStr = string.split(configData.gold_recover, ",")
	local curNum = getHaveResetNumByGold()
	local nextNum = curNum + 1
	local retData = 0
	for i=1,#costStr do
		local temp = string.split(costStr[i], "|")
		if( nextNum <= tonumber(temp[1]) )then
			retData = tonumber(temp[2])
			break
		end
	end
	return retData
end

--[[
	@des 	: 得到金币已重置次数
	@param 	: 
	@return : num
--]]
function getHaveResetNumByGold( ... )
	return tonumber(_worldArenaInfo.extra.gold_reset_num)
end

--[[
	@des 	: 设置金币已重置次数
	@param 	: 
	@return : 
--]]
function setHaveResetNumByGold( p_num )
	_worldArenaInfo.extra.gold_reset_num = p_num
end

--[[
	@des 	: 得到攻击跳过数据
	@param 	: 
	@return : num
--]]
function getSkipData( ... )
	return _skipData
end

--[[
	@des 	: 设置攻击跳过数据
	@param 	: 0不跳过 1是跳过
	@return : 
--]]
function setSkipData( p_num )
	_skipData = p_num
end


--[[
	@des 	: 得到我的击杀数
	@param 	: 
	@return : num
--]]
function getMyKillNum( ... )
	return tonumber(_worldArenaInfo.extra.kill_num) 
end

--[[
	@des 	: 得到我的当前连杀数
	@param 	: 
	@return : num
--]]
function getMyCurContiNum( ... )
	return tonumber(_worldArenaInfo.extra.cur_conti_num) 
end

--[[
	@des 	: 得到我的最大连杀数
	@param 	: 
	@return : num
--]]
function getMyMaxContiNum( ... )
	return tonumber(_worldArenaInfo.extra.max_conti_num)
end

--[[
	@des 	: 得到四个人的信息
	@param 	: 
	@return :
--]]
function getPlayer()
	if( table.isEmpty(_worldArenaInfo.extra) )then
		return {}
	end

	local retData = {}
	local myInfo = nil
	local tempInfo = {}
	local playerInfo = _worldArenaInfo.extra.player
	for k,v in pairs(playerInfo) do
		v.rank = tonumber(k)
		if(tonumber(v.self) == 1)then
			myInfo = v
		else
			table.insert(tempInfo,v)
		end
	end

	-- 排名从大到小
	local sortCallFun = function ( data1, data2 )
		return data1.rank < data2.rank
	end
	table.sort( tempInfo, sortCallFun )

	for i=1,#tempInfo do
		tempInfo[i].index = i
		table.insert(retData,tempInfo[i])
	end
	myInfo.index = 4
	table.insert(retData,myInfo)

	return retData
end

--[[
	@des 	: 得到是否显示下部分界面
	@param 	: 
	@return : true or false
--]]
function getIsShowBottomUI()
	local retData = false

	-- 开始打期间显示 
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkStartTime = WorldArenaMainData.getAttackStartTime()
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime >= atkStartTime  and curTime < atkEndTime)then
		retData = true
	end

	-- 报名玩家显示
	local mySignUpTime = getMySignUpTime()
	if(mySignUpTime <= 0)then
		retData = false
	end

	return retData
end

--[[
	@des 	: 得到挑战胜利将
	@param 	: p_winReward 后端返回胜利奖
	@return : 
--]]
function getRewardData( p_reward )
	local temp = {}
	for k,v in pairs(p_reward) do
		local tab = {}
		tab.type = v[1]
		tab.tid  = v[2]
		tab.num  = v[3]
		table.insert(temp,tab)
	end

	local retData = ItemUtil.getItemsDataByStr(nil,temp)

	return retData
end

--[[
	@des 	: 得到我自己的pid
	@param 	: 
	@return : 
--]]
function getMyPid()
	local pid = UserModel.getPid()
	-- print("getMyPid",pid)
	return tonumber(pid)
end

--[[
	@des 	: 得到我自己的serverId
	@param 	: 
	@return : 
--]]
function getMyServerId()
	local serverId = UserModel.getServerId()
	-- print("getMyServerId",serverId)
	return tonumber(serverId)
end


--[[
	@des 	: 得到是否显示入口按钮
	@param 	: 
	@return : 
--]]
function isShowBtn()
	local isShow = false
	-- 活动开没开
	local isOpen = ActivityConfigUtil.isActivityOpen("worldarena")

	if( isOpen and not table.isEmpty(_worldArenaInfo) and 
		tonumber(_worldArenaInfo.team_id) > 0 and
		TimeUtil.getSvrTimeByOffset(0) >= tonumber(_worldArenaInfo.signup_bgn_time) and
		TimeUtil.getSvrTimeByOffset(0) < tonumber(_worldArenaInfo.period_end_time) ) then 
		-- 活动开了，有分组，到报名时间了
		isShow = true
	end
	return isShow
end


--[[
	@des 	: 加奖励
	@param 	: 
	@return : 
--]]
function addRewardData( p_reward )
	for k,v in pairs(p_reward) do
		local rewardData = getRewardData(v)
		ItemUtil.addRewardByTable( rewardData )
	end
end

--[[
	@des 	: 报名时间内，若该玩家满足报名条件，且他未报名时，则该玩家每次登录时，主界面的“跨服争霸赛”按钮会有红点提示，当玩家点击进入并返回主界面后，此红点提示消失，玩家再次上线后可看到此红点提示。
	@param 	: 
	@return : 
--]]
local isIn = nil
function isShowSigupRedTip()
	local isShow = false
	-- 活动开没开
	local isOpen = ActivityConfigUtil.isActivityOpen("worldarena")
	if( isOpen and not table.isEmpty(_worldArenaInfo) and 
		tonumber(_worldArenaInfo.team_id) > 0  and
		TimeUtil.getSvrTimeByOffset(0) >= tonumber(_worldArenaInfo.signup_bgn_time) and
		TimeUtil.getSvrTimeByOffset(0) < tonumber(_worldArenaInfo.signup_end_time) 
		and tonumber(_worldArenaInfo.signup_time) <= 0 and isIn == nil ) then
		-- 活动开了,有分组,在报名时间内,没有报名,没有进入巅峰对决界面,级别够参加
		local needLv = WorldArenaMainData.getworldArenaNeedLv()
		if( needLv <= UserModel.getHeroLevel() )then
			isShow = true
		end
	end
	return isShow
end

--[[
	@des 	: 是否进入主界面
	@param 	: 
	@return : 
--]]
function setIsIn( p_isIn )
	isIn = p_isIn
end


--[[
	@des 	: 免费次数小红点
	@param 	: 
	@return : 
--]]
function isShowFreeNumRedTip()
	local isShow = false
	local isOpen = ActivityConfigUtil.isActivityOpen("worldarena")
	if( isOpen and not table.isEmpty(_worldArenaInfo) and 
		tonumber(_worldArenaInfo.team_id) > 0 and tonumber(_worldArenaInfo.room_id) > 0 and
		TimeUtil.getSvrTimeByOffset(0) >= tonumber(_worldArenaInfo.attack_bgn_time) and
		TimeUtil.getSvrTimeByOffset(0) < tonumber(_worldArenaInfo.attack_end_time) 
		and tonumber(_worldArenaInfo.signup_time) > 0 and isIn == nil ) then
		-- 活动开了,有分组,在攻击时间内,有报名,没有进入巅峰对决界面,有免费挑战次数
		local haveBuyNum = getHaveBuyAtkNum()
		local subNum = getAtkNum()
		if( subNum-haveBuyNum > 0 )then
			isShow = true
		end
	end
	return isShow
end

--[[
	@des 	: 主界面按钮小红点
	@param 	: 
	@return : 
--]]
function isShowRedTip()
	local isShow = false
	-- 报名小红点
	local isShowSigup = isShowSigupRedTip()
	local isShowFree = isShowFreeNumRedTip()
	if( isShowSigup or isShowFree )then
		isShow = true
	end
	return isShow
end








