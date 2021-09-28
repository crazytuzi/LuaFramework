-- Filename: OlympicData.lua
-- Author: lichenyang
-- Date: 2014-07-14
-- Purpose: 擂台争霸数据层



module("OlympicData",package.seeall)

require "db/DB_Challenge"

------------------------------[[ 常量 ]]----------------------------------------

kPreOlympicStag = 0 --比赛前阶段
kRegisterStage  = 1 --预选赛阶段
kGroupStage     = 2 --分组阶段
kSixteenStage   = 3 --16强赛
kEightStage     = 4 --8强赛
kFourStage      = 5 --4强赛
kTwoStage       = 6 --半决赛
kOneStage       = 7 --决赛
kAfterStage     = 8 --比赛后阶段 持续时间比较长
-------------------------------32强 begin zhangqiang------------------------------
local kRankFinal32 = 32
local kRankFinal16 = 16
local kRankFinal8  = 8
local kRankFinal4  = 4

local _currentGroupId = nil		--当前组id A组:1 B组:2 C组:3 D组:4
local _currentGroupAllParticipantTable = nil
local _olympicIndexTableWithoutEnemy = nil
-------------------------------32强  end ---------------------———————————---------

local _olympicInfo = {}
local _isWait = false

--所有战报信息 added by Zhang Zihang
local _fightReportInfo = {}

function setInfo( p_info )
	_olympicInfo = p_info
	if(_olympicInfo.rank_list == nil) then
		_olympicInfo.rank_list = {}
	end
end

function getInfo( ... )
	return _olympicInfo
end


--[[
	@des : 得到当前阶段状态码
	@ret : int
	const PRE_OLYMPIC = 0;//比赛前阶段
    const PRELIMINARY_MATCH = 1;//预选赛阶段
    const OLYMPIC_GROUP = 2;    //分组阶段
    const SIXTEEN_FINAL = 3;//16强赛
    const EIGHTH_FINAL = 4;//8强赛
    const QUARTER_FINAL = 5;//4强赛
    const SEMI_FINAL = 6;//半决赛
    const FINAL_MATCH = 7;//决赛
    const AFTER_OLYMPIC = 8;//比赛后阶段 持续时间比较长
--]]
function getStage( ... )
	return tonumber(_olympicInfo.stage)
end

function setStage( p_state )
	_olympicInfo.stage = tonumber(p_state)
end


--[[
	@des ： 设置当前状态为等待报名开始状态，此时当前时间会大于预选赛开始时间，此状态会持续 大概15秒左右
--]]
function setWaitRegisterStatus( p_isWait )
	_isWait = true
end


--[[
	@des : 当前阶段的结束时间
--]]
function getStageNowEndTime()
	print("now time:",BTUtil:getSvrTimeInterval())

	local stageIndex = getStage()
	local preEndTime = 0
	local registerEndTime = 0 
	if(_olympicInfo.timeConf) then
		preEndTime = tonumber(_olympicInfo.timeConf.signStartTime) 
		registerEndTime = tonumber(_olympicInfo.timeConf.signStartTime) + tonumber(_olympicInfo.timeConf.signDuration)
	end

	local retTime = 0
	
	if(preEndTime < BTUtil:getSvrTimeInterval() and stageIndex == kPreOlympicStag and _isWait ~= true) then
		--如果今天没开擂台争霸，则擂台争霸开始报名时间返回的是明天的报名时间，所以 要加一天时间
		preEndTime = preEndTime + 86400
		registerEndTime = registerEndTime + 86400
	end
	if(stageIndex == kPreOlympicStag) then
		retTime = preEndTime
	elseif(stageIndex >= kRegisterStage and stageIndex <= kGroupStage) then
		retTime = registerEndTime
	else
		local gapTime = 0
		for i=3,stageIndex-1 do
			gapTime = (_olympicInfo.timeConf.fighGap[tostring(i)] or 0) + gapTime
		end

		retTime = registerEndTime  + tonumber(_olympicInfo.timeConf.signFightGap) + gapTime --- tonumber(_olympicInfo.timeConf.fighGap["3"])
	end
	printTable("timconf", _olympicInfo.timeConf)
	print("registerEndTime", registerEndTime ,"fighGap", tonumber(_olympicInfo.timeConf.fighGap))
	print("now Stage end time:", stageIndex, retTime, BTUtil:getSvrTimeInterval(),retTime - BTUtil:getSvrTimeInterval())
	return retTime
end
--[[
	@des : 得到上届冠军信息
--]]
function getChampionInfo( ... )
	return _olympicInfo.last_champion
end


--[[
	@des : 得到跨服赛开启时间 eg. 11:30
--]]
function getStartTimeDes( ... )
	local openTime = TimeUtil.getIntervalByTime(123000) + BossData.getBossTimeOffset()
	if(_olympicInfo ~= nil and _olympicInfo.timeConf ~=nil and _olympicInfo.timeConf.signStartTime ~= nil) then
		openTime = _olympicInfo.timeConf.signStartTime
	end
	local timeT = os.date("*t",openTime)
	return string.format("%02d:%02d",timeT.hour,timeT.min)
end


--[[
	@des : 得到擂台赛开始时间的时间戳
--]]
function getOlympicOpenTime( ... )
	require "script/ui/boss/BossData"
	local openTime = TimeUtil.getIntervalByTime(123000) + BossData.getBossTimeOffset()
	if(_olympicInfo ~= nil and _olympicInfo.timeConf ~=nil and _olympicInfo.timeConf.signStartTime ~= nil) then
		openTime = _olympicInfo.timeConf.signStartTime
	end
	return tonumber(openTime)
end


--[[
	@des : 得到上次剩余cd 时间
--]]
function getLastChallengeCD( ... )
	_olympicInfo.challenge_cd = _olympicInfo.challenge_cd  or 0
	return tonumber(_olympicInfo.challenge_cd) - BTUtil:getSvrTimeInterval()
end



--[[
	@des : 通过报名位置得到已报名玩家的信息
	@parm: p_signPos
	@ret : _olympicInfo.rank_list
--]]
function getUserInfoBySignPos( p_signPos )
	if(_olympicInfo.rank_list == nil) then
		return nil
	end
	for k,v in pairs(_olympicInfo.rank_list) do
		if(tonumber(v.sign_up_index) == p_signPos) then
			return v
		end
	end
	return nil
end

--[[
	@des : 通过报名位置得到已报名玩家的信息
	@parm: p_olympicIndex
	@ret : _olympicInfo.rank_list
--]]
function getUserInfoByOlympicIndex( p_olympicIndex )
	if(_olympicInfo.rank_list == nil) then
		_olympicInfo.rank_list = {}
	end

	for k,v in pairs(_olympicInfo.rank_list) do
		if(tonumber(v.olympic_index) == tonumber(p_olympicIndex)) then
			return v
		end
	end

	return nil
end

--[[
	@des 	: 刷新玩家信息
	@parm 	: 玩家信息
--]]
function updateUserInfo( p_userInfo )
	if _olympicInfo.rank_list == nil then 
		_olympicInfo.rank_list = {}
	end
	_olympicInfo.rank_list[p_userInfo.uid] = p_userInfo
	
end

--[[
	@des	:得到报名玩家数量
	@return :int 玩家数量
--]]
function getUserCount( ... )
	local countNum = 0
	for k,v in pairs(_olympicInfo.rank_list) do
		countNum = countNum + 1
	end
	return countNum
end

--[[
	@des : 判断当前玩家是否已经报名
--]]
function isUserRegister( p_uid )
	for k,v in pairs(_olympicInfo.rank_list) do
		if(tonumber(v.uid) == tonumber(p_uid)) then
			return true
		end
	end
	return false
end

---------------------------——————————————----32强 begin zhangqiang----------------————————————————--------------
--[[
	@des :	初始化
--]]
function olympic32DataInit( ... )
	_currentGroupId = nil
	_currentGroupAllParticipantTable = nil
	_olympicIndexTableWithoutEnemy = nil
end

--[[
	@des :	将服务器中比赛位置映射到32强UI位置(即第几组中第几头像位置)
	@param :	p_olympicIndex 服务器中的比赛位置(0开始)
	@ret :	小组id:  	1:A组 2:B组 3:C组 4:D组
			UI中头像位置索引:	1   2   3   4
							  9   11  10 
							5   6   7   8
--]]
function convertToUIIndex(p_olympicIndex)
	--local groupId = math.ceil(p_olympicIndex/8) 注：比赛位置7和8都会被判到1组，但8其实是2组
	local groupId = math.floor(p_olympicIndex/8)+1
	--在32强中的头像位置索引
	--键：p_olympicIndex%8，值：UI中头像位置索引
	local mapTable = {
						[0] = 2, [1] = 1, [2] = 5, [3] = 6, [4] = 7, [5] = 8, [6] = 4, [7] = 3,
					 }
	local tempIndex = p_olympicIndex%8
	local headIconIndexTable = {mapTable[tempIndex]}
	--在8强和4强中的头像位置索引(回顾中还涉及2强和冠军)
	print("convertToUIIndex",p_olympicIndex)
	print_t(_olympicInfo.rank_list)
	local tempInfoTable = getUserInfoByOlympicIndex(p_olympicIndex)
	if tonumber(tempInfoTable.final_rank) <= kRankFinal8 then
		if tempIndex <=3 then
			table.insert(headIconIndexTable, 9)
		else
			table.insert(headIconIndexTable, 10)
		end

		if tonumber(tempInfoTable.final_rank) <= kRankFinal4 then
			table.insert(headIconIndexTable, 11)
		end
	end
	return groupId, headIconIndexTable
end

--[[
	@des :	根据小组id更新当前小组id和当前小组所有参赛成员信息
	@param:	p_groupId 小组id: 1:A组 2:B组 3:C组 4:D组
	@ret :	
--]]
function updateCurrentGroupAllParticipantInfo(p_groupId)
	if _currentGroupId == p_groupId and _currentGroupAllParticipantTable ~= nil then
		return
	end

	local maxOlympicIndex = p_groupId*8
	local minOlympicIndex = maxOlympicIndex - 8
	local tempTable = nil
	local currentGroupAllParticipantTable = {}
	for i = minOlympicIndex,maxOlympicIndex-1 do
		tempTable = getUserInfoByOlympicIndex(i)
		if tempTable then
			table.insert(currentGroupAllParticipantTable, tempTable)
		end
	end
	_currentGroupAllParticipantTable = currentGroupAllParticipantTable
	_currentGroupId = p_groupId
end

--[[
	@des :	获得当前小组所有参赛成员信息
--]]
function getCurrentGroupAllParticipantTable()
	return _currentGroupAllParticipantTable
end

--[[
	@des :	设置当前小组id
--]]
function setCurrentGroupId(p_groupId)
	updateCurrentGroupAllParticipantInfo(p_groupId)
end

--[[
	@des :	根据所给的小组id判断是否为当前小组
--]]
function isCurrentGroup(p_groupId)
	return p_groupId == _currentGroupId
end

--[[
	@des :	用于判断无对手的参赛者直接晋级，在指定比赛阶段一开始判断上一阶段晋级前指定的比赛位置是否存在对手
			如：8强阶段一开始需要判断在16强阶段晋级前指定比赛位置是否存在对手，若无对手直接晋级16强
	@ret :	0: 不在前一阶段晋级前排名中(即p_stage-1阶段)，无对手
			1: 在前一阶段晋级前排名中，无对手
			2: 在前一阶段晋级前排名中，有对手
			3: 不在比赛阶段，无对手
			4: 在16强阶段，无需判断排名32强时有无对手，刚进入8强阶段才做该判断，若无对手直接晋级到16强
--]]
function getEnermyStatus(p_olympicIndex, p_stage)
	p_stage = tonumber(p_stage)
	p_olympicIndex = tonumber(p_olympicIndex)

	--每小队人数
	local participantNumEachTeam = nil
	--前一阶段晋级前排名限制
	local finalRankBeforeCurrentStage = nil
	if p_stage <= 2 then
		--不在比赛阶段时不需要判断有无对手
		return 3
	elseif p_stage == 3 then
		--在16强阶段，无需判断排名32强时有无对手，刚进入8强阶段才做该判断，若无对手直接晋级到16强
		return 4
	elseif p_stage == 4 then	--8强
		participantNumEachTeam = 2 
		finalRankBeforeCurrentStage = 32
	elseif p_stage == 5 then --4强
		participantNumEachTeam = 4
		finalRankBeforeCurrentStage = 16
	elseif p_stage == 6 then --半决赛
		participantNumEachTeam = 8
		finalRankBeforeCurrentStage = 8
	elseif p_stage == 7 then --决赛
		participantNumEachTeam = 16
		finalRankBeforeCurrentStage = 4
	elseif p_stage == 8 then
		participantNumEachTeam = 32
		finalRankBeforeCurrentStage = 2
	else
		local errorStr = "in function \"getEnermyStatus\", run with wrong olympic stage (0 <= stage <＝8), stage is %d now!"
		error(string.format(errorStr,p_stage))
	end

	--参数中的比赛位置所在的小队的编号(0开始)
	local teamId = math.floor(p_olympicIndex/participantNumEachTeam)

	--参数中的比赛位置所在小队的比赛位置范围[minOlympicIndex, maxOlympicIndex)
	local minOlympicIndex = teamId*participantNumEachTeam
	local maxOlympicIndex = minOlympicIndex+participantNumEachTeam

	local countParticipantNum = 0
	for k,v in pairs(_olympicInfo.rank_list) do
		--剔除不是同一小队的参赛者
		if tonumber(v.olympic_index) >= minOlympicIndex and tonumber(v.olympic_index) < maxOlympicIndex then
			--获取排名小于等于前一阶段晋级前排名的参赛者(在战报推送中获胜方已晋级)
			if tonumber(v.final_rank) <= finalRankBeforeCurrentStage then
				print("getEnermyStatus", finalRankBeforeCurrentStage, p_stage, v.uname, v.final_rank)
				countParticipantNum = countParticipantNum + 1
			else
				if tonumber(v.olympic_index) == p_olympicIndex then
					return 0
				end
			end
		end
	end

	assert(countParticipantNum == 1 or countParticipantNum == 2)
	
	if countParticipantNum == 1 then
		return 1
	else
		return 2
	end
end

--[[
	@des :	根据比赛阶段更新上一阶段晋级前没有比赛对手的参赛者信息，直接晋级
--]]
function updateUserInfoByOlympicStage(p_stage)
	p_stage = tonumber(p_stage)
	_olympicIndexTableWithoutEnemy = {}
	--在比赛阶段时更新本地排名
	if(_olympicInfo.rank_list == nil) then
		_olympicInfo.rank_list = {}
	end
	for k,v in pairs(_olympicInfo.rank_list) do
		if getEnermyStatus(v.olympic_index,p_stage) == 1 then
			_olympicInfo.rank_list[k].final_rank = v.final_rank / 2
			table.insert(_olympicIndexTableWithoutEnemy,v.olympic_index)
		end
	end
end

--[[
	des :	获取无对手直接晋级得所有比赛位置
--]]
function getOlympicIndexTableWithoutEnemy( ... )
	return _olympicIndexTableWithoutEnemy
end

--[[
	@desc :	根据用户id获得比赛位置
	@ret :	用户的比赛位置（均不小于0，返回-1时表示该用户不在比赛中）
--]]
function getOlympicIndexByUid(p_uid)
	p_uid = tonumber(p_uid)
	local olympicIndex = -1
	for k,v in pairs(_olympicInfo.rank_list) do
		if tonumber(v.uid) == p_uid then
			olympicIndex = tonumber(v.olympic_index)
			return olympicIndex	
		end
	end
	return olympicIndex
end
---------------------------————————————————————————----32强  end --------------------——————————————----------=======
--[[
	@des : 收到战报信息的时候更新玩家信息
--]]
function updateUserInfoByBattleInfo( p_battleInfo )
	local winUid = nil
	if(string.upper(p_battleInfo.result) == "F" or string.upper(p_battleInfo.result) == "E") then
		winUid = tonumber(p_battleInfo.defender)
	else
		winUid = tonumber(p_battleInfo.attacker)
	end

	for k,v in pairs(_olympicInfo.rank_list) do
		if(tonumber(v.uid) == winUid) then
			print("updateUserInfoByBattleInfo",tonumber(v.uid))
			_olympicInfo.rank_list[k].final_rank = tonumber(v.final_rank)/2
		end
	end
end


--[[
	@des : 根据挑战数据刷新玩家信息
--]]
function updateChallengeBattleInfo( p_challengeInfo )
	for k,v in pairs(p_challengeInfo) do
		if(string.upper(v.result) ~= "F" and string.upper(v.result) ~= "E") then
			local signIndex = _olympicInfo.rank_list[v.defender].sign_up_index
			_olympicInfo.rank_list[v.defender] = nil
			_olympicInfo.rank_list[v.attacker] = v.userInfo[v.attacker]
			_olympicInfo.rank_list[v.attacker].sign_up_index = signIndex
		end
	end
	printTable("updateChallengeBattleInfo", _olympicInfo.rank_list)
end


--[[
	@des : 添加战报信息
--]]
function addBattleInfo( p_battleInfos )
	if(_olympicInfo.fight_info == nil) then
		_olympicInfo.fight_info = {}
	end

	for k,v in pairs(p_battleInfos) do
		if(_olympicInfo.fight_info == nil) then
			_olympicInfo.fight_info= {}
		end
		if(_olympicInfo.fight_info[tostring(getStage())] == nil) then
			_olympicInfo.fight_info[tostring(getStage())]= {}
		end
		if(_olympicInfo.fight_info[tostring(getStage())]["atkres"] == nil) then
			_olympicInfo.fight_info[tostring(getStage())]["atkres"]= {}
		end
		table.insert(_olympicInfo.fight_info[tostring(getStage())]["atkres"], v)
	end
	printTable("addBattleInfo _olympicInfo", _olympicInfo)
end


--[[
	@des : 通过推送战报信息获得玩家信息
--]]
function getUserInfoByBattleInfo( p_battleInfo )
	printTable("getUserInfoByBattleInfo p_battleInfo", p_battleInfo)

	local winUid = nil
	if(p_battleInfo.result == "F" or p_battleInfo.result == "E") then
		winUid = tonumber(p_battleInfo.defender)
	else
		winUid = tonumber(p_battleInfo.attacker)
	end
	for k,v in pairs(_olympicInfo.rank_list) do
		if(tonumber(v.uid) == winUid) then
			return v
		end
	end
	return nil
end

--[[
	@des : 得到玩家信息
--]]
function getUserInfoByUid( p_uid )
	if(_olympicInfo.rank_list == nil) then
		error("_olympicInfo.rank_list is nil")
		return nil
	end
	if(_olympicInfo.rank_list[tostring(p_uid)]) then
		return _olympicInfo.rank_list[tostring(p_uid)]
	else
		error("not find user info by uid:" .. p_uid)
	end
end


--[[
	@des 	: 通过两个比赛位置返回，这连个位置玩家的战报。
	@param 	: int p_olympicPosA 玩家A的比赛位置
	@param 	: int p_olympicPosB 玩家B的比赛位置
	@ret    : int 战报id 为nil 则还没有战报
			  int 胜利玩家的位置
--]]
function getReportIdByOlympicPos( p_olympicPosA, p_olympicPosB)
	local uidA = tonumber(getUserInfoByOlympicIndex(p_olympicPosA).uid)
	local uidB = tonumber(getUserInfoByOlympicIndex(p_olympicPosB).uid)

	for k,v in pairs(_olympicInfo.fight_info) do
		for k2,v2 in pairs(v.atkres) do
			if(tonumber(uidA) == tonumber(v2.attacker) and tonumber(uidB) == tonumber(v2.defender) or
			   tonumber(uidA) == tonumber(v2.defender) and tonumber(uidB) == tonumber(v2.attacker)) then
				local winUid = nil
				local winPos = nil
				if(string.upper(v2.result) == "F" or string.upper(v2.result) == "E" ) then
					winUid = tonumber(v2.defender)
				else
					winUid = tonumber(v2.attacker)
				end
				if(winUid == uidA) then
					winPos = p_olympicPosA
				else
					winPos = p_olympicPosB
				end
				return tonumber(v2.brid), winPos
			end
		end
	end
	printTable("_olympicInfo fight_info", _olympicInfo.fight_info)
	error(p_olympicPosA.. " and " ..p_olympicPosB .. "don't find report")
	return nil
end


--[[
	@des : 得到报名花费的银币数量
--]]
function getJoinCostSilver()
	require "db/DB_Challenge"
	require "script/model/user/UserModel"
	local challengeInfo = DB_Challenge.getDataById(1)
	return tonumber(challengeInfo.joinCostBelly) * UserModel.getHeroLevel()
end

--[[
	@des : 得到挑战花费的银币数量
--]]
function getChallengeCostSilver()
	require "db/DB_Challenge"
	require "script/model/user/UserModel"
	local challengeInfo = DB_Challenge.getDataById(1)
	return tonumber(challengeInfo.challengeCost) * UserModel.getHeroLevel()
end


--[[
	@des: 挑战CD时间	
--]]
function getChallengeCDTime( ... )
	require "db/DB_Challenge"
	local challengeInfo = DB_Challenge.getDataById(1)
	return tonumber(challengeInfo.cdTime)
end

--[[
	@des: 根据冷却时间算出清除冷却时间要花费的金币
--]]
function getClearChallgeCDCostByTime( p_cdTime )
	require "db/DB_Challenge"
	local challengeInfo = DB_Challenge.getDataById(1)
	return math.ceil(tonumber(p_cdTime)/10) * tonumber(challengeInfo.clearCDCostGold)
end


--[[
	@des :助威花费游戏
--]]
function getCheerCostSilver( ... )
	require "db/DB_Challenge"
	require "script/model/user/UserModel"
	local challengeInfo = DB_Challenge.getDataById(1)
	return tonumber(challengeInfo.cheerCostBelly) * UserModel.getHeroLevel()
end

--[[
	@des 	:得到四强信息
	@param 	:
	@return :四强信息
	@return :两强信息
	@return :冠军信息
--]]
function getFinalFourInfo()
	--_olympicInfo.rank_list 结构
	-- rank_list:array       报名的32个玩家的信息
    -- [
    --     uid=>array
    --     [
    --         sign_up_index:int    报名位置
    --         olympic_index:int    比赛位置
    --         final_rank:int        排名
    --         uid:int
    --         uname:int
    --         dress:array
    --         htid:int
    --     ]
    -- ]
    local finalFourTable = {
    						[1] = {},
    						[2] = {},
    						[3] = {},
    						[4] = {},
    					   }
    local finalTwoTable = {
    						[1] = {},
    						[2] = {},
						  }
	local finalOneTable = {
							[1] = {},
						  }

	print("选手信息")
	print_t(_olympicInfo.rank_list)

	--是否有冠军
	local haveFinalTwo = false
	--是否有亚军
	local haveFinalOne = false
    
    if not table.isEmpty(_olympicInfo.rank_list) then
		for k,v in pairs(_olympicInfo.rank_list) do
			--冠军信息
			if tonumber(v.final_rank) == 1 then
				haveFinalOne = true
				haveFinalTwo = true
				finalOneTable[1] = v
				finalTwoTable[math.floor(v.olympic_index/16) + 1] = v
				finalFourTable[math.floor(v.olympic_index/8) + 1] = v
			end
			--两强信息
			if tonumber(v.final_rank) == 2 then
				haveFinalTwo = true
				finalTwoTable[math.floor(v.olympic_index/16) + 1] = v
				finalFourTable[math.floor(v.olympic_index/8) + 1] = v
			end
			--四强信息
			if tonumber(v.final_rank) == 4 then
				finalFourTable[math.floor(v.olympic_index/8) + 1] = v
			end
		end
	end

	return finalFourTable,finalTwoTable,finalOneTable,haveFinalTwo,haveFinalOne
end

--[[
	@des 	:得到冠军信息
	@param 	:
	@return :冠军信息
--]]
function getWinnerInfo()
	--冠军table
	local winnerTable = {}

	if not table.isEmpty(_olympicInfo.rank_list) then
		for k,v in pairs(_olympicInfo.rank_list) do
			if tonumber(v.final_rank) == 1 then
				winnerTable = v
				break
			end
		end
	end

	return winnerTable
end


--[[
	@des 	:得到助威的玩家uid
	@param 	:
	@return :玩家uid
--]]
function getCheerUid()
	print("已助威id",_olympicInfo.cheer_uid)
	return tonumber(_olympicInfo.cheer_uid)
end

--[[
	@des 	:增加助威数目
	@param 	:玩家uid
	@return :
--]]
function addPlayerCheerNum(p_uid)
	print("_________________加助威num")
	print("备注为玩家id",p_uid)
	print("原助威num",_olympicInfo.rank_list[tostring(p_uid)].be_cheer_num)
	if _olympicInfo.rank_list[tostring(p_uid)].be_cheer_num ~= nil then
		_olympicInfo.rank_list[tostring(p_uid)].be_cheer_num = tonumber(_olympicInfo.rank_list[tostring(p_uid)].be_cheer_num) + 1
	else
		_olympicInfo.rank_list[tostring(p_uid)].be_cheer_num = 1
	end
end

--[[
	@des 	:得到玩家助威数目
	@param 	:玩家uid
	@return :玩家的助威数目
--]]
function getPlayerCheerNum(p_uid)
	print("——————————————————————————————得到助威num")
	print("已助威num",_olympicInfo.rank_list[tostring(p_uid)].be_cheer_num)
	return _olympicInfo.rank_list[tostring(p_uid)].be_cheer_num
end

--[[
	@des 	:得到玩家olympic_index
	@param 	:玩家uid
	@return :返回玩家olympic_index
--]]
function getPlayerIndex(p_uid)
	return tonumber(_olympicInfo.rank_list[tostring(p_uid)].olympic_index)
end

--[[
	@des 	:设置所有战报信息
	@param 	:后端得到的战报
	@return :
--]]
function setBattleReportInfo(p_reportInfo)
	_fightReportInfo = p_reportInfo
	print("所有战报")
	print_t(_fightReportInfo)
end

--[[
	@des 	:得到所有战报的数量
	@param 	:
	@return :所有战报的数量
--]]
-- function getAllReportNum()
-- 	local reportNum = 0
-- 	for k,v in pairs(_fightReportInfo.fight_info) do
-- 		reportNum = tonumber(table.count(v.atkres)) + reportNum
-- 	end

-- 	return reportNum
-- end

--[[
	@des 	:得到所有战报的信息
	@param 	:
	@return :所有战报的信息
	@return :个人战报信息
	@return :所有战报数量
	@return :个人战报数量
--]]
function getAllReportInfo()
	local allReportTable = {}
	local personalTable = {}
	local afterCopyTable = {}
	table.hcopy(_fightReportInfo.fight_info,afterCopyTable)
	print("硬拷贝")
	print_t(afterCopyTable)
	for i = 7,1,-1 do
		print("现在的i")
		print_t(afterCopyTable[tostring(i)])
		if afterCopyTable[tostring(i)] ~= nil then
			for k,v in pairs(afterCopyTable[tostring(i)].atkres) do
				print("v的值")
				print_t(v)
				if i == 1 then
					v.logType = GetLocalizeStringBy("zzh_1046")
				elseif i == 3 then
					v.logType = GetLocalizeStringBy("zzh_1047")
				elseif i == 4 then
					v.logType = GetLocalizeStringBy("zzh_1048")
				elseif i == 5 then
					v.logType = GetLocalizeStringBy("zzh_1049")
				elseif i == 6 then
					v.logType = GetLocalizeStringBy("zzh_1050")
				elseif i == 7 then
					v.logType = GetLocalizeStringBy("zzh_1051")
				end
				table.insert(allReportTable,v)
				print("加入后的全站报table")
				print_t(allReportTable)
				if (tonumber(v.attacker) == UserModel.getUserUid()) or (tonumber(v.defender) == UserModel.getUserUid()) then
					table.insert(personalTable,v)
				end
			end
		end
	end

	return allReportTable,personalTable
end

--[[
	@des 	:得到参战人员信息
	@param 	:玩家uid
	@return :参战人员信息
--]]
function getBattlePlayerInfo(p_uid)
	print("用户信息",_fightReportInfo.rank_list[tonumber(p_uid)])
	print_t(_fightReportInfo.rank_list)
	return _fightReportInfo.rank_list[tostring(p_uid)]
end

--[[
	@des ：得到所有战报信息
--]]
function getAllBattleReportInfo( ... )
	local battleInfos = {}
	for k,v in pairs(_olympicInfo.fight_info) do
		if(v.atkres) then
			for k2,v2 in pairs(v.atkres) do
				table.insert(battleInfos, v2)
			end
		end
	end
	return battleInfos
end

--[[
	@des 	:得到奖池金额
	@param 	:
	@return :奖池金额
--]]
function getSilverPoolNum()
	return tonumber(_olympicInfo.silver_pool)
end

--[[
	@des 	:得到奖池分成比例
	@param 	:连胜次数
	@return :冠军分成比例
	@return :终结者分成比例
	@return :助威者分成比例
--]]
function getAwardPoolRatio(p_comboTimes)
	--如果有上届冠军
	if tonumber(p_comboTimes) > 0 then
		--得到连胜次数
		local winnerCombo = tonumber(p_comboTimes)
		local killCombo = tonumber(p_comboTimes)
		local cheerCombo = tonumber(p_comboTimes)

		--挑战数据信息
		local challengeData = DB_Challenge.getDataById(1)

		--处理表结构
		local winnerTable = string.split(challengeData.champion,",")
		local killerTable = string.split(challengeData.Terminator,",")
		local cheerTable = string.split(challengeData.other,",")

		if tonumber(p_comboTimes) > #winnerTable then
			winnerCombo = #winnerTable
		end

		if tonumber(p_comboTimes) > #killerTable then
			killCombo = #killerTable
		end

		if tonumber(p_comboTimes) > #cheerTable then
			cheerCombo = #cheerTable
		end

		--返回相应位置上的比例
		return tonumber(winnerTable[winnerCombo])/10000,tonumber(killerTable[killCombo])/10000,tonumber(cheerTable[cheerCombo])/10000
	end
	--如果没有冠军
	if tonumber(p_comboTimes) == 0 then
		return 0,0,0
	end
end

--[[
	@des 	:得到上届冠军uid
	@param 	:
	@return :上届冠军uid(如果没有冠军，返回0)
--]]
function lastChampionUid()
	--初始化不是一个冠军
	local returnUid = 0
	--如果上届有冠军
	local lastInfo = getChampionInfo()
	if tonumber(lastInfo.uid) ~= 0 then
		returnUid = tonumber(getChampionInfo().uid)
	end

	return returnUid
end

--[[
	@des 	:得到连胜次数
	@param 	:
	@return :连胜次数
--]]
function getComboTimes()
	local comboTimes = 1
	local lastInfo = getChampionInfo()
	if tonumber(lastInfo.uid) ~= 0 then
		comboTimes = tonumber(getChampionInfo().win_cont)
	end

	return comboTimes
end

--[[
	@des 	:返回减少的战斗力
	@param 	:连胜次数
	@return :减少的战斗力
--]]
function getReduceFightValue(p_comboTime)
	local comboTimes = tonumber(p_comboTime)

	if comboTimes == 0 then
		return 0
	end

	local challengeData = DB_Challenge.getDataById(1)
	local reduceTable = string.split(challengeData.reduceEffective,",")

	if tonumber(p_comboTime) > #reduceTable then
		comboTimes = #reduceTable
	end

	return tonumber(reduceTable[comboTimes])/100
end

--[[
	@des 	:增加奖池金额
	@param 	:增加的奖池金额
	@return :
--]]
function addSilverPoolNum(p_addPoolNum)
	_olympicInfo.silver_pool = tonumber(_olympicInfo.silver_pool) + tonumber(p_addPoolNum)
end

--[[
	@des 	:充值奖池数额
	@param 	:新的奖池数额
	@return :
--]]
function setSilverPoolNum(p_newPoolNum)
	_olympicInfo.silver_pool = tonumber(p_newPoolNum)
end

--[[
	@des 	:增加连胜次数
	@param 	:
	@return :
--]]
function addComboTimes()
	--创建新冠军
	local championInfo = getWinnerInfo()
	if tonumber(championInfo.uid) == lastChampionUid() then
		_olympicInfo.last_champion.win_cont = tonumber(_olympicInfo.last_champion.win_cont) + 1
	end
end