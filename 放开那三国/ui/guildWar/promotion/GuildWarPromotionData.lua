-- FileName: GuildWarPromotionData.lua 
-- Author: bzx
-- Date: 15-1-19 
-- Purpose:  跨服军团战16强的数据

module("GuildWarPromotionData", package.seeall)

--require "script/ui/guildWar/GuildWarMainData"


local _guildWarInfo 				= {}
local _guildWarInfoTrapezium		= {}

--[[
	@desc:									设置军团晋级信息
	@param:		table p_guildWarInfo		军团的晋级信息
	@return:	nil
--]]
function setGuildWarInfo( p_guildWarInfo )
	_guildWarInfo = {}
	for k, v in pairs(p_guildWarInfo) do
		_guildWarInfo[tonumber(v.pos)] = v
	end
	initGuildWarInfoTrapezium(p_guildWarInfo)
end

--[[
	@desc:				初始化整个比赛的晋级信息
	@return:	nil
--]]
function initGuildWarInfoTrapezium( p_guildWarInfo )
	_guildWarInfoTrapezium = {}
	local round = GuildWarMainData.getRound()
	local status = GuildWarMainData.getStatus()
	local curRank = getCurRank()
	print("curRank=====", curRank)
	for index, guildInfo in pairs(p_guildWarInfo) do
		local rank = tonumber(guildInfo.final_rank)
		while rank <= 16 do
			local data = {}
			data.guildInfo = guildInfo
			data.guildStatus = nil
			print(guildInfo.final_rank, rank)
			if tonumber(guildInfo.final_rank) < rank then
				-- 晋级
				data.guildStatus = GuildWarDef.kGuildWin
			elseif tonumber(guildInfo.final_rank) > rank * 0.5 and rank > curRank then
				-- 淘汰
				data.guildStatus = GuildWarDef.kGuildFail
			else
				-- 初始
				data.guildStatus = GuildWarDef.kGuildInitial
			end
			_guildWarInfoTrapezium[rank] = _guildWarInfoTrapezium[rank] or {}
			local rankIndex = getRankIndex(rank, tonumber(guildInfo.pos))
			_guildWarInfoTrapezium[rank][rankIndex] = data
			rank = rank * 2
		end
	end
	print("_guildWarInfoTrapezium====")
	print_t(_guildWarInfoTrapezium)
end

--[[
	@desc:							得到整个比赛的晋级信息
	@return:	table		
	{
		[16] = {
			[1] = {
				guildInfo 		-- 后端传来的每个军团的信息
				guildStatus  	-- 军团比赛状态（晋级，淘汰，比赛中）
			}
		},
		[8] = {
			
		},
		[4] = {
	
		},
		[2] = {
	
		},
		[1] = {

		}
	}
--]]
function getGuildWarInfoTrapezium()
	return _guildWarInfoTrapezium
end


--[[
	@desc:						自己军团的敌对军团在当前轮是否轮空
	@return: 		bool
--]]
function myEnemyIsEmpty()
	local myGuildWarInfo = getMyGuildWarInfo()
	if myGuildWarInfo == nil then
		return true
	end
	local curRank = getCurRank()
	local rankIndex = getRankIndex(curRank, tonumber(myGuildWarInfo.pos))
	local enemyRankIndex = nil
	if math.mod(rankIndex, 2) == 0 then
		enemyRankIndex = rankIndex - 1
	else
		enemyRankIndex = rankIndex + 1
	end
	if not _guildWarInfoTrapezium[curRank] then
		return true
	end
	if not _guildWarInfoTrapezium[curRank][enemyRankIndex] then
		return true
	end
	return false
end

--[[
	@desc:							得到军团在指定轮次信息
	@param:		number 	p_rank 		
	@param:		number 	p_index 	军团在指定轮次中的index
	@return:	table	
--]]
function getGuildTrapeziumInfo( p_rank, p_index )
	if _guildWarInfoTrapezium[p_rank] ~= nil then
		return _guildWarInfoTrapezium[p_rank][p_index]
	end
end

--[[
	@desc:							得到军团信息
	@param:		number p_position  	军团在位置
	@return:	table
--]]
function getGuildWarInfoByPosition( p_position )
	return _guildWarInfo[p_position]
end

--[[
    @desc:	 			得到最近的已经出结果的轮次
    @return:	number
--]]
function getCurRank()
	local curRound = GuildWarMainData.getRound()
	local curStatus = GuildWarMainData.getStatus()
	local curRank = nil
	if curRound == GuildWarDef.ADVANCED_2 and curStatus >= GuildWarDef.FIGHTEND then
		curRank = 1
	elseif curRound >= GuildWarDef.ADVANCED_2
		or curRound == GuildWarDef.ADVANCED_4 and curStatus >= GuildWarDef.FIGHTEND then
		curRank = 2
	elseif curRound >= GuildWarDef.ADVANCED_4 
		or curRound == GuildWarDef.ADVANCED_8 and curStatus >= GuildWarDef.FIGHTEND then
		curRank = 4
	elseif curRound >= GuildWarDef.ADVANCED_8 
		or curRound == GuildWarDef.ADVANCED_16 and curStatus >= GuildWarDef.FIGHTEND then
		curRank = 8
	elseif curRound >= GuildWarDef.ADVANCED_16
		or curRound == GuildWarDef.AUDITION and curStatus >= GuildWarDef.FIGHTEND then
		curRank = 16
	else
		curRank = 0
	end
	return curRank
end

--[[
	@desc:						判断自已所在的军团是否已经被淘汰
	@return:	bool          
--]]
function myGuildIsEliminated( ... )
	local myGuildWarInfo = getMyGuildWarInfo()
	print(roundIsEnd(GuildWarDef.AUDITION))
	print_t(myGuildWarInfo)
	print(getCurRank())
	if roundIsEnd(GuildWarDef.AUDITION) and (myGuildWarInfo == nil or tonumber(myGuildWarInfo.final_rank) > getCurRank()) then
		return true
	end
	return false
end

--[[
	@desc:						自己的军团是否已经从海选晋级
	@return:	bool
--]]
function myGuildIsPromoted( ... )
	local myGuildWarInfo = getMyGuildWarInfo()
	if myGuildWarInfo ~= nil then
		return true
	end
	return false
end
 
--[[
	@desc:							指定的round是否已经结束
	@param:		number	p_round
	@return:	bool
--]]
function roundIsEnd( p_round )
	local curRound = GuildWarMainData.getRound()
	local curStatus = GuildWarMainData.getStatus()
	if p_round == curRound and curStatus == GuildWarDef.END
		or p_round < curRound then
		return true
	end
	return false
end

--[[
	@desc:						得到自己的军团信息
	@return:	table
--]]
function getMyGuildWarInfo( ... )
	return getGuildWarInfo(GuildWarMainData.getMyServerId(), GuildDataCache.getMineSigleGuildId())
end

--[[
	@desc:									得到军团信息
	@param:		string 	p_guildServerId  	军团所在服务器的id
	@param:		string	p_guildId 			军团id
	@return:	table
--]]
function getGuildWarInfo( p_guildServerId, p_guildId )
	for index, guildInfo in pairs(_guildWarInfo) do
		if guildInfo.guild_server_id == tostring(p_guildServerId) and guildInfo.guild_id == tostring(p_guildId) then
			return guildInfo
		end
	end
end



--[[
	@desc:							根据rank得到这个rank开始比赛时的round
	@param:			number 	p_rank 	指定的排名
	@return:		number
--]]
function getRoundByRank( p_rank )
	print("getRoundByRank====", p_rank)
	local rankRounds = {}
	rankRounds[2] = GuildWarDef.ADVANCED_2
	rankRounds[4] = GuildWarDef.ADVANCED_4
	rankRounds[8] = GuildWarDef.ADVANCED_8
	rankRounds[16] = GuildWarDef.ADVANCED_16
	local rankRound = rankRounds[p_rank]
	return rankRound
end


--[[
	@desc:					得到当前购买连胜消耗的金币数量
	@return:	number
--]]
function getBuyMaxWinNumCost( ... )
	local addCount = GuildWarMainData.getMaxWinNum()
    local costInfo = parseField(ActivityConfig.ConfigCache.guildwar.data[1].WinCost, 1)
    return costInfo[addCount + 1]
end

--[[
	@desc:								得到玩家在指定rank中的index
	@param:		number 		p_rank		指定的排名
	@param:		number		p_serverPos	后端比赛位置
	@return:	number
--]]
function getRankIndex( p_rank,  p_serverPos)
	local rankIndex = math.ceil(p_serverPos / (16 / p_rank))
	return rankIndex
end

--[[
	@desc:				是否所有的战斗已经结束
	@return:	bool   
--]]
function isEnd( ... )
	local round = GuildWarMainData.getRound()
    local status = GuildWarMainData.getStatus()
    if round == GuildWarDef.ADVANCED_2 and status == GuildWarDef.END then
        return true
    end
    return false
end

