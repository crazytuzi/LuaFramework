-- Filename: WorldCarnivalData.lua
-- Author: bzx
-- Date: 2014-08-27
-- Purpose: 跨服嘉年华数据层

module("WorldCarnivalData", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalConstant"

local _curRound
local _curStatus
local _curSubRound
local _curSubStatus
local _carnivalInfo
local _reportInfo
local _fighters

-- 设置当前大轮
function setCurRound(p_round)
	_curRound = p_round
end

-- 得到当前是哪一个大轮
function getCurRound( ... )
	return _curRound
end

-- 设置当前大轮的状态
function setCurStatus(p_status)
	_curStatus = p_status
end

-- 得到当前大轮的状态
function getCurStatus( ... )
	return _curStatus
end

-- 设置当前是第几小轮
function setCurSubRound(p_subRound)
	_curSubRound = p_subRound
end

-- 得到当前是第几小轮
function getCurSubRound( ... )
	return _curSubRound
end

-- 设置当前小轮的状态
function setCurSubStatus(p_subStatus)
	_curSubStatus = p_subStatus
end

-- 得到当前小轮的状态
function getCurSubStatus( ... )
	return _curSubStatus
end

--[[
	@desc:	设置嘉年华数据
--]]
function setCarnivalInfo(p_cannivalInfo )
	_carnivalInfo = p_cannivalInfo
	_curRound = tonumber(_carnivalInfo.round)
	if _curRound == 0 then
		_curStatus = WorldCarnivalConstant.STATUS_DONE
		_curSubRound = 0
		_curSubStatus = WorldCarnivalConstant.STATUS_DONE
	else
		_curStatus = tonumber(_carnivalInfo.status)
		_curSubRound = tonumber(_carnivalInfo.sub_round)
		_curSubStatus = tonumber(_carnivalInfo.sub_status)
	end
	initFighters()
end

--[[
	@desc:		初始化英雄数据
--]]
function initFighters( ... )
	_fighters = {}
	for pos, fighter in pairs(_carnivalInfo.fighters) do
		fighter.pos = pos
		local rank = WorldCarnivalConstant.RANK_4TO2
		local rankPosition = tonumber(pos)
		repeat
			_fighters[rank] = _fighters[rank] or {}
			_fighters[rank][rankPosition] = fighter
			rank = rank * 0.5
			rankPosition = math.ceil(rankPosition * 0.5)
		until rank < tonumber(fighter.rank)
	end
end

--[[
	@desc:	 			某一个位置的英雄晋级
	@param:		p_pos  	位置
--]]
function heroPromotion(p_pos )
	local fighterInfo = _carnivalInfo.fighters[tostring(p_pos)]
	fighterInfo.rank = tonumber(fighterInfo.rank) / 2
	initFighters()
end

-- 得到英雄的当前比赛状态
function getHeroStatusByRank(p_rank, p_position )
	local rankFighters = _fighters[p_rank]
	if rankFighters == nil then
		return WorldCarnivalConstant.STATUS_WAITING
	end
	local fighter1 = rankFighters[p_position]
	if fighter1 == nil then
		return WorldCarnivalConstant.STATUS_WAITING
	end
	local fighter2 = nil
	if math.mod(p_position, 2) == 0 then
		fighter2 = rankFighters[p_position - 1]
	else
		fighter2 = rankFighters[p_position + 1]
	end
	if fighter2 == nil then
		return WorldCarnivalConstant.STATUS_WAITING
	end
	local heroStatus = WorldCarnivalConstant.STATUS_WAITING
	if tonumber(fighter1.rank) > tonumber(fighter2.rank) then
		heroStatus = WorldCarnivalConstant.STATUS_LOSING
	elseif tonumber(fighter1.rank) < tonumber(fighter2.rank) then
		heroStatus = WorldCarnivalConstant.STATUS_WIN
	else
		heroStatus = WorldCarnivalConstant.STATUS_WAITING
	end
	return heroStatus
end

--[[
	@desc: 		是否有战报
	@param: 	p_round 	round
--]]
function isHaveBattleReport(p_round)
	if p_round > _curRound or (p_round == _curRound and _curSubRound == 1 and _curSubStatus < WorldCarnivalConstant.STATUS_DONE) then
		return false
	end
	return true
end

-- 通过rank得到round
function getRoundByRank(p_rank, p_fightIndex)
	local roundData = {
		[WorldCarnivalConstant.RANK_4TO2] = {
			WorldCarnivalConstant.ROUND_1,
			WorldCarnivalConstant.ROUND_2,
		},
		[WorldCarnivalConstant.RANK_2TO1] = {
			WorldCarnivalConstant.ROUND_3
		}
	}
	return roundData[p_rank][p_fightIndex]
end

-- 得到以rank为key的所有英雄比赛数据
function getFighters( ... )
	return _fighters
end

-- 通过位置得到英雄的比赛信息
function getFighterInfoByPos(p_pos)
	return _carnivalInfo.fighters[tostring(p_pos)]
end

-- 初始化战报数据
function initReportInfo(p_reportInfo, p_round)
	local leftFighter = nil
	local rightFighter = nil
	-- 根据round算出谁与谁比赛
	if p_round == WorldCarnivalConstant.ROUND_1 then
		leftFighter = _fighters[WorldCarnivalConstant.RANK_4TO2][1]
		rightFighter = _fighters[WorldCarnivalConstant.RANK_4TO2][2]
	elseif p_round == WorldCarnivalConstant.ROUND_2 then
		leftFighter = _fighters[WorldCarnivalConstant.RANK_4TO2][3]
		rightFighter = _fighters[WorldCarnivalConstant.RANK_4TO2][4]
	elseif p_round == WorldCarnivalConstant.ROUND_3 then
		leftFighter = _fighters[WorldCarnivalConstant.RANK_2TO1][1]
		rightFighter = _fighters[WorldCarnivalConstant.RANK_2TO1][2]
	end
	_reportInfo = {}
	_reportInfo.leftFighter = leftFighter
	_reportInfo.rightFighter = rightFighter
	local reportInfos = {}
	local reportCount = table.count(p_reportInfo)
	for i = 1, reportCount do
		table.insert(reportInfos, p_reportInfo[tostring(i)])
	end
	_reportInfo.result = reportInfos

	-- 是否已经分胜负
	local isEnd = false
	if p_round < _curRound or (p_round == _curRound and _curStatus == WorldCarnivalConstant.STATUS_DONE)then
		isEnd = true
	end
	_reportInfo.isEnd = isEnd
	-- 如果已经分胜负，算出比分
	if isEnd then
		local leftScore = 0
		local rightScore = 0
		for i=1, #reportInfos do
			local recordInfo = reportInfos[i]
			if recordInfo.result == "1" then
				if leftFighter.pos == recordInfo.attacker_pos then
					leftScore = leftScore + 1
				else
					rightScore = rightScore + 1
				end
			else
			end
		end
		_reportInfo.leftScore = leftScore
		_reportInfo.rightScore = rightScore
	end
end

-- 得到战报信息
function getReportInfo( ... )
	return _reportInfo
end

-- 得到当前rank
function getCurRank( ... )
	local curRank = WorldCarnivalConstant.RANK_4TO2
	if _curRound == 1 and _curStatus == WorldCarnivalConstant.STATUS_DONE then
		curRank = WorldCarnivalConstant.RANK_2TO1
	elseif _curRound == 3 and _curStatus == WorldCarnivalConstant.STATUS_DONE then
		curRank = WorldCarnivalConstant.RANK_1
	end
	return curRank
end

-- 是否已经结束，决出冠军算结束
function isEnd( ... )
	return _curRound == WorldCarnivalConstant.ROUND_3 and _curStatus == WorldCarnivalConstant.STATUS_DONE
end

-- 得到下一个小轮的开始时间 
function getNextSubRoundStartTime( ... )
	if isEnd() then
		return nil
	end
	return tonumber(_carnivalInfo.next_fight_time)
end

-- 设置下一个小轮的开始时间
function setNextSubRoundStartTime( p_startTime )
	_carnivalInfo.next_fight_time = p_startTime
end

--[[
	@desc:		是否是参赛者
--]]
function isFighter( ... )
	local serverId = tonumber(UserModel.getServerId())
	local pid = tonumber(UserModel.getPid())
	local carnivalConfig = ActiveCache.getWorldcarnivalConfig()[1]
	local fighterConfig = carnivalConfig.fighter
	local fighterDatas = parseField(fighterConfig, 2)
	for i = 1, #fighterDatas do
		local fighterData = fighterDatas[i]
		if fighterData[2] == serverId and fighterData[3] == pid and fighterData[5] == 1 then
			return true
		end
	end
	return false
end

--[[
	@desc:	 是否是观赛者
--]]
function isWatcher( ... )
	local serverId = tonumber(UserModel.getServerId())
	local pid = tonumber(UserModel.getPid())
	local carnivalConfig = ActiveCache.getWorldcarnivalConfig()[1]
	local watcherConfig = carnivalConfig.watcher
	local watcherDatas = parseField(watcherConfig, 2)
	for i = 1, #watcherDatas do
		local watcherData = watcherDatas[i]
		if watcherData[1] == serverId and watcherData[2] == pid and watcherData[4] == 1 then
			return true
		end
	end
	return false
end

--[[
	@desc:		是否显示入口
--]]
function isShowEnterButton( ... )
	return ActivityConfigUtil.isActivityOpen("worldcarnival") and (isFighter() or isWatcher())
end