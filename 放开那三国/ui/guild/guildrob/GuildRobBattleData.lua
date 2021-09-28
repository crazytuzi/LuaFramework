-- FileName: GuildRobBattleData.lua
-- Author: lichenyang
-- Date: 14-1-8
-- Purpose: 扫荡界面
-- @module GuildRobBattleData

module("GuildRobBattleData",package.seeall)
require "script/model/user/UserModel"
require "script/ui/guild/GuildDataCache"

------------------------------[[ 模块常量 ]]------------------------------
local kPlayerBloodTag = 101
local kPlayerNameTag  = 102


------------------------------[[ 模块变量 ]]------------------------------
local _robBattleInfo = {}
local _battleReportInfo = {}
local _afterBattleInfo = {}
local _rankInfos = {}
local _createBattleInfo = {}
local _goBattleTime = 0 	--玩家从传送阵出阵时间


function init( ... )
	_robBattleInfo = {}
	_battleReportInfo = {}
	_afterBattleInfo = {}
	_rankInfos = {}
	_createBattleInfo = {}
	_goBattleTime = 0 	--玩家从传送阵出阵时间
end

function setRobBattleInfo( p_info )
	convertData(p_info)
	table.paste(_robBattleInfo, p_info)
	printTable("_robBattleInfo", _robBattleInfo)
end

function getRobBattleInfo( ... )
	return _robBattleInfo
end

function refreshBattleInfo( p_refreshInfo )
	convertData(p_refreshInfo)
	table.paste(_robBattleInfo, p_refreshInfo)

	printTable("refreshBattleInfo", _robBattleInfo)
	--更新队列的stopX
	--1.找出每个传送阵最顶端玩家的stopX，
	--2.把和最新stopX传送阵相同的玩家的stopX全部修改成最新的
	--第1步
	local stopTable = {}
	for k,v in pairs(_robBattleInfo.field.road) do
		if(v.stopX ~= nil and v.transferId ~= nil ) then
			if(tonumber(v.transferId) < 3) then
				--攻防
				stopTable[v.transferId] = stopTable[v.transferId] or 0
				stopTable[v.transferId] = (tonumber(stopTable[v.transferId]) < tonumber(v.stopX) and tonumber(v.stopX)) or stopTable[v.transferId]
			else
				--守方
				stopTable[v.transferId] = stopTable[v.transferId] or 0
				stopTable[v.transferId] = (tonumber(stopTable[v.transferId]) > tonumber(v.stopX) and tonumber(v.stopX)) or stopTable[v.transferId]			
			end
		end
	end
	--第2步
	for k,v in pairs(_robBattleInfo.field.road) do
		_robBattleInfo.field.road[k].stopX = stopTable[v.transferId]
	end

	--先标记为要清楚数据，延迟1秒后删除
	for k,v in pairs(_robBattleInfo.field.road) do
		--清除达阵玩家数据
		for touchKey,touchValue in pairs(_robBattleInfo.field.touchdown) do
			if _robBattleInfo.field.road[touchValue] ~= nil then
				_robBattleInfo.field.road[touchValue].exit = 1
			end
		end
		--清除掉线玩家数据
		for levelKey,levelValue in pairs(_robBattleInfo.field.leave) do
			if _robBattleInfo.field.road[levelValue] ~= nil then
				_robBattleInfo.field.road[levelValue].exit = 1
			end
		end
	end
	performCallfunc(function ( ... )
		--清楚数据
		_robBattleInfo.field = _robBattleInfo.field or {}
		_robBattleInfo.field.road = _robBattleInfo.field.road or {}
		for k,v in pairs(_robBattleInfo.field.road) do
			if(v.exit == 1) then
				_robBattleInfo.field.road[k] = nil
			end
			--清除达阵玩家数据
			for touchKey,touchValue in pairs(_robBattleInfo.field.touchdown) do
				_robBattleInfo.field.road[touchValue] = nil
			end
			--清除掉线玩家数据
			for levelKey,levelValue in pairs(_robBattleInfo.field.leave) do
				_robBattleInfo.field.road[levelValue] = nil
			end
		end
	end, 1)
end

function convertData( p_dataInfo )
	p_dataInfo.field.road = p_dataInfo.field.road or {}
	
	-- --将数组类型的road 替换成id 	
	for i=1,#p_dataInfo.field.road do
		local v = p_dataInfo.field.road[i]
		local id = v.id
		p_dataInfo.field.road[id] = {}
		for k,v in pairs(v) do
			p_dataInfo.field.road[id][k] = v
		end
		p_dataInfo.field.road[i] = nil
	end

	-- 将touchdown的数组类型替换成id
	p_dataInfo.field.touchdown = p_dataInfo.field.touchdown or {}
	for i=1,#p_dataInfo.field.touchdown do
		local v = p_dataInfo.field.touchdown[i]
		p_dataInfo.field.touchdown[i] = v.id
	end
	-- 转换level数据
	p_dataInfo.field.leave = p_dataInfo.field.leave or {}
	for i=1,#p_dataInfo.field.leave do
		local v = p_dataInfo.field.leave[i]
		p_dataInfo.field.leave[i] = v.id
	end
end


--[[
	@des:	得到攻防军团信息
--]]
function getAttackerGuildInfo( ... )
	-- local testInfo = {
	-- 		guildName 	= "攻防军团",					--军团名称
	-- 		inBattle	= "10",						--当前军团参战人数
	-- 		guildNum	= "80",						--军团总人数
	-- 		robGrain	= "20",						--可抢粮草
	-- 		grain		= "10",						--获得粮草
	-- 		merit		= "20",						--获得功勋
	-- }
	-- return testInfo

	local attackerInfo = {}
	attackerInfo.guildName 	= _robBattleInfo.attacker.guildName or 0
	attackerInfo.guildNum 	= _robBattleInfo.attacker.totalMemberCount or 0	
	attackerInfo.inBattle 	= _robBattleInfo.attacker.memberCount or 0
	attackerInfo.grain 		= _robBattleInfo.user.extra.info.userGrainNum or 0		--获得粮草
	attackerInfo.merit 		= _robBattleInfo.user.extra.info.meritNum or 0		--获得功勋
	return  attackerInfo
end

--[[
	@des:	得到守方军团信息
--]]
function getDefenderGuildInfo( ... )
	-- local testInfo = {
	-- 		guildName 	= "守方军团",				--胜者id
	-- 		inBattle	= "10",					--败者id 
	-- 		guildNum	= "80",					--胜者名字
	-- 		robGrain	= "20",					--败者名字
	-- 		grain		= "10",					--胜利者连胜次数
	-- 		merit		= "20",					--失败者在此次失败之前的连胜次数
	-- }
	-- return testInfo
	local defenderInfo = {}
	defenderInfo.guildName 	= _robBattleInfo.defender.guildName or 0			--军团名称
	defenderInfo.inBattle 	= _robBattleInfo.defender.memberCount or 0			--当前军团参战人数
	defenderInfo.guildNum 	= _robBattleInfo.defender.totalMemberCount or 0		--军团总人数
	defenderInfo.robGrain 	= tonumber(_robBattleInfo.defender.robLimit) - tonumber(_robBattleInfo.attacker.robGrain)				--可抢粮草
	defenderInfo.grain 		= _robBattleInfo.user.extra.info.userGrainNum or 0		--获得粮草
	defenderInfo.merit 		= _robBattleInfo.user.extra.info.meritNum or 0			--获得功勋
	return  defenderInfo
end

--[[
	@des：增加功勋
--]]
function addUserMerit( p_merit )
	local merit = p_merit or 0
	_robBattleInfo.user.extra.info.meritNum = tonumber(_robBattleInfo.user.extra.info.meritNum) + tonumber(merit)
	GuildDataCache.addMyselfMeritNum(merit)
end

--[[
	@des：增加功勋
--]]
function addUserGrain( p_grain )
	local grain = p_grain or 0
	_robBattleInfo.user.extra.info.userGrainNum = tonumber(_robBattleInfo.user.extra.info.userGrainNum) + tonumber(grain)
	GuildDataCache.addMyselfGrainNum(grain)
end

--[[
	@des: 增加用户军团粮草
--]]
function addGuildGrain( p_grain )
	local grain = p_grain or 0
	_robBattleInfo.user.extra.info.guildGrainNum = tonumber(_robBattleInfo.user.extra.info.guildGrainNum) + tonumber(grain)
	GuildDataCache.addGuildGrainNum(grain)
end


--[[
	@des: 设置用户出阵时间
--]]
function setUserGoBattleTime( p_time )
	_goBattleTime = tonumber(p_time)
end

--[[
	@des: 得到玩家从传送阵出阵时间
--]]
function getUserGoBattleTime( p_time )
	return tonumber(_goBattleTime)
end

--[[
	@des: 得到战斗持续时间
--]]
function getPastTime( ... )
	-- return 500
	return  tonumber(_robBattleInfo.field.endTime) - TimeUtil.getSvrTimeByOffset(0)
end

--[[
	@des: 得到准备时间
--]]
function getReadyTime( ... )
	local time = tonumber(_robBattleInfo.readyDuration) - tonumber(_robBattleInfo.field.pastTime) 
	if time < 0 then
		time = 0
	end
	return  time
end

--[[
	@des :得到传送阵中玩家数量
--]]
function getTranferPlayerNum( p_tranferId )
	return tonumber(_robBattleInfo.field.transfer[p_tranferId])
end

--[[
	@des : 得到后端路线逻辑长度
--]]
function getServerRoadLength( p_roadId )
	local roadLength = _robBattleInfo.field.roadLength[tonumber(p_roadId)]
	return tonumber(roadLength)
end


--[[
	@des: 判断玩家是不是攻击者军团
--]]
function isUserAttackerGuild( p_guild )
	local guild = p_guild or tonumber(_robBattleInfo.user.guildId)

	if(guild == tonumber(_robBattleInfo.attacker.guildId)) then
		return true
	else
		return false
	end
end

--[[
	@des：得到我方军团id
--]]
function getMyGuildId( ... )
	return tonumber(_robBattleInfo.user.guildId)
end



function setCanJoinTime( p_time )
	_robBattleInfo.user.canJoinTime = p_time
end

function getCanJoinTime( ... )
	-- body
	_robBattleInfo.user.canJoinTime = _robBattleInfo.user.canJoinTime or 0
	_robBattleInfo.user.readyTime = _robBattleInfo.user.readyTime or 0

	return math.max(tonumber(_robBattleInfo.user.canJoinTime), tonumber(_robBattleInfo.user.readyTime))
end

function setQuitReadyTime( p_time )
	_robBattleInfo.user.readyTime = p_time
end

function getQuitReadyTime( ... )
	_robBattleInfo.user.readyTime = _robBattleInfo.user.readyTime or 0
	return tonumber(_robBattleInfo.user.readyTime)
end

function getReadState( p_roadState )
	local roadState = _robBattleInfo.field.roadState or 1
	return tonumber(roadState)
end

--[[
	@des:  判断用户是不是在路上
--]]
function isUserInRoad( ... )
	local userUid = UserModel.getUserUid()
	for k,v in pairs(_robBattleInfo.field.road) do
		if tonumber(v.id) == userUid then
			return true
		end
	end
	return false
end


--[[
	@des: 判断用户是否在蹲点粮仓
--]]
function isUserInSpec( ... )
	local userUid = UserModel.getUserUid()
	for k,v in pairs(_robBattleInfo.field.spec.userInfo) do
		if tonumber(k) == userUid then
			return true
		end
	end
	return false
end

--[[
	@des: 得到在路上的玩家信息
--]]
function getRoadPlayerInfo( p_playerId )
	for k,v in pairs(_robBattleInfo.field.road) do
		if tonumber(k) == tonumber(p_playerId) then
			return v
		end
	end
	return nil
end


-------------------------------------[[ 战报相关 ]]--------------------------------------------

function addReportInfo( p_battleInfo )
	--增加战报数据
	table.insert(_battleReportInfo,p_battleInfo)
	--清除战败玩家在场数据
	local loserId = p_battleInfo.loserId
	local winnerId = p_battleInfo.winnerId
	performCallfunc(function ( ... )
		clearPlayInfoById(loserId)
		if p_battleInfo.winnerOut == "true" then
			clearPlayInfoById(winnerId)
		end
	end, 0.5)
	printTable("addReportInfo", _robBattleInfo)
end

function clearPlayInfoById( p_playerId )
	for i=1,3 do
		for k,v in pairs(_robBattleInfo.field.road) do		
			if(tonumber(v.id) == tonumber(p_playerId)) then
				_robBattleInfo.field.road[tostring(k)] = nil
				print("addReportInfo clear lose player id =",k )
				break
			end
		end
	end
end

function getReportInfo( ... )
	-- local testInfo = {
	-- 	{
	-- 		winnerId 	= 11,						--胜者id
	-- 		loserId		= 22,						--败者id 
	-- 		winnerName	= "李四"	,					--胜者名字
	-- 		loserName	= "老葱头",					--败者名字
	-- 		winStreak	= 10,						--胜利者连胜次数
	-- 		loseStreak	= 20,						--失败者在此次失败之前的连胜次数
	-- 		brid		= 29444,					--战报id
	-- 	},
	-- 	{
	-- 		winnerId 	= 11,						--胜者id
	-- 		loserId		= 22,						--败者id 
	-- 		winnerName	= "王八"	,					--胜者名字
	-- 		loserName	= "老葱头",					--败者名字
	-- 		winStreak	= 10,						--胜利者连胜次数
	-- 		loseStreak	= 20,						--失败者在此次失败之前的连胜次数
	-- 		brid		= 29444,					--战报id
	-- 	},
	-- }
	-- return testInfo
	return _battleReportInfo
end

function setAfterBattleInfo( p_info )
	_afterBattleInfo = p_info
end
--------------------------------[[ 排行榜相关 ]]---------------------------------
function getAfterBattleInfo( ... )
-- [7]push.guildrob.reckon				战斗结束后的玩家结算数据
-- {
-- 	rank
-- 	kill
-- 	userGrain
-- 	guildGrain
-- 	merit
-- }
	-- local testInfo = {
	-- 	rank 	= 11,							--胜者id
	-- 	kill		= 22,						--败者id 
	-- 	userGrain	= "李四"	,					--胜者名字
	-- 	guildGrain	= "老葱头",					--败者名字
	-- 	merit	= 10,							--功勋值
	-- 	duration = 600,
	-- }
	-- return testInfo
	return _afterBattleInfo
end

function setRankInfo( p_rankInfo )
	_rankInfos = p_rankInfo
end

function getRankInfo( ... )
	local uid = tostring(UserModel.getUserUid())
	local rankArray = {}
	rankArray.myInfo = _rankInfos[tostring(uid)]
	for k,v in pairs(_rankInfos) do
		table.insert(rankArray, v)
	end
	printTable("rankArray", rankArray)
	table.sort( rankArray, function ( p1, p2 )
		return tonumber(p1.killNum) > tonumber(p2.killNum)
	end )
	rankArray.myInfo = _rankInfos[uid]
	return rankArray
end

---------------------------------[[ 蹲点粮仓信息处理 ]]-----------------------------------
function getSpecBronInfo( )
	local specInfo = {}
	for k,v in pairs(_robBattleInfo.field.spec.userInfo) do
		specInfo[tonumber(v.specId) + 1] = v
		specInfo[tonumber(v.specId) + 1].id = k
	end
	return specInfo
end

function setSpecBronInfo( p_info )
	table.paste(_robBattleInfo.field.spec, p_info)
	--清除退出玩家
	local outSpecId = _robBattleInfo.field.spec.outSpecId
	if outSpecId ~=nil then
		for k,v in pairs(_robBattleInfo.field.spec.userInfo) do
			if tonumber(v.specId) == tonumber(outSpecId) then
				_robBattleInfo.field.spec.userInfo[k] = nil
				break
			end
		end
		_robBattleInfo.field.spec.outSpecId = nil
	end
	--更新玩家的cd
	if _robBattleInfo.field.spec.joinCd ~= nil then
		setCanJoinTime(_robBattleInfo.field.spec.joinCd)
		_robBattleInfo.field.spec.joinCd = nil
	end
	--增加守护奖励
	if _robBattleInfo.field.spec.reward ~= nil then
		local rewardInfo = _robBattleInfo.field.spec.reward
		--增加用户粮草
		GuildRobBattleData.addUserGrain(rewardInfo.userGrain)
		--增加用户功勋
		GuildRobBattleData.addUserMerit(rewardInfo.merit)
		--增加军团粮草
		GuildRobBattleData.addGuildGrain(rewardInfo.guildGrain)
		--用户获得的军团贡献
		GuildDataCache.addGuildDonate(rewardInfo.contr)
	end
	printTable("setSpecBronInfo", _robBattleInfo.field.spec)
	--清楚奖励
	 _robBattleInfo.field.spec.reward = nil
end


--------------------------------[[ 加速相关 ]]--------------------------------------------
--[[
	@des:得到加速消耗金币数
--]]
function getSpeedCost( ... )
	-- body
	require "db/DB_Rob_food"
	local goldNum = DB_Rob_food.getDataById("1").SpeedCost
	return tonumber(goldNum)
end
--[[
	@des:设置当前加速值
--]]
function setSpeedNum( p_num )
	_robBattleInfo.user.speed_num = p_num
end

--[[
	@des: 得到当前加速值
--]]
function getSpeedNum( ... )
	_robBattleInfo.user.speed_num = _robBattleInfo.user.speed_num or 0
	return tonumber(_robBattleInfo.user.speed_num)
end

--[[
	@des:得到清除cd花费
--]]
function getRemoveCDCost( ... )
	require "db/DB_Rob_food"
	local baseNums = string.split(DB_Rob_food.getDataById("1").CooldownCost, ",")
	local removeNum = _robBattleInfo.user.extra.info.removeCdNum or 1
	removeNum = removeNum + 1
	local costGold = 0
	for i,v in ipairs(baseNums) do
		local configs = string.split(v, "|")
		if tonumber(removeNum) <= tonumber(configs[1]) then
			costGold = tonumber(configs[2])
			break
		end
	end
	return costGold
end

--[[
	@des:增加清除cd 次数
--]]
function addRemoveCDNum( p_num )
	local num = p_num or 0
	_robBattleInfo.user.extra.info.removeCdNum = _robBattleInfo.user.extra.info.removeCdNum or 0
	_robBattleInfo.user.extra.info.removeCdNum = tonumber(_robBattleInfo.user.extra.info.removeCdNum) + num
end

--------------------------[[ 士气相关 ]]------------------------
--[[
	@des: 得当当前士气值
--]]
function getMorale( ... )
	return tonumber(_robBattleInfo.attacker.morale)
end

--[[
	@des: 得到士气值上限
--]]
function getMaxMoral( ... )
	require "db/DB_Rob_food"
	local maxMoral = DB_Rob_food.getDataById(1).InitialRage
	return tonumber(maxMoral)
end

--[[
	des:防守方到达对面降低怒气
--]]
function getReduceRage( ... )
	require "db/DB_Rob_food"
	local rage = DB_Rob_food.getDataById(1).ReduceRage
	return tonumber(rage)
end

--[[
	des:防守方到达对面降低怒气
--]]
function getReduceTime( ... )
	require "db/DB_Rob_food"
	local time = DB_Rob_food.getDataById(1).ReduceTime
	return tonumber(time)
end

--[[
	@des:得到进入战场功勋值
--]]
function getJoinMerit( ... )
	require "db/DB_Rob_food"
	local arrivedin = DB_Rob_food.getDataById(1).arrivedin
	return tonumber(arrivedin)
end

--[[
	@des:得到守方达阵功勋奖励
--]]
function getDefenderTouchdownMerit( ... )
	require "db/DB_Rob_food"
	local DefenseComeReward = DB_Rob_food.getDataById(1).DefenseComeReward
	local merit = string.split(DefenseComeReward, "|")[2]
	return tonumber(merit)
end

--[[
	@des: 得到参战强制冷却时间
--]]
function getCooldownTime( ... )
	require "db/DB_Rob_food"
	local cooldown = DB_Rob_food.getDataById(1).Cooldown
	return tonumber(cooldown)
end

--[[
	@des: 得到战斗持续时间
--]]
function getBattleTime( ... )
	require "db/DB_Rob_food"
	local battletime = DB_Rob_food.getDataById(1).battletime
	return tonumber(battletime)
end

--[[
	@des: 自动参战vip 等级限制
--]]
function getAotuBattleVipLevel( ... )
	local autoNum = 999999
	require  "db/DB_Vip"
	for i=1,999999 do
		local vipInfo = DB_Vip.getDataById(i)
		if vipInfo.activityFree == 1 then
			autoNum = vipInfo.level
			break
		end
	end
	return autoNum
end




