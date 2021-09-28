-- FileName: MyGuildWarInfoData.lua 
-- Author: bzx
-- Date: 15-1-16 
-- Purpose:  战斗信息数据

module("MyGuildWarInfoData", package.seeall)

UpdateStatus = {
	auditionAllow			= 1,			-- 跨服赛赛开始前3分钟之前
	auditionLimit			= 2,			-- 跨服赛3分钟之内
	auditionFighting		= 3,			-- 跨服赛进行中
	advancedAllow			= 4,			-- 本轮晋级赛结束到下一轮晋级赛开始前3分钟之间
	advancedLimit			= 5,			-- 本轮晋级赛开始前3分钟之内
	advancedNotEndAllow  	= 6, 			-- 本轮晋级赛后端第5小组已经FightEnd，但是没有到本轮结束时间
	groupAllow				= 7,			-- 本小组赛后端FightEnd的时刻到下一小组开始前3分钟之间（不包括第一小组）
	groupLimit				= 8,			-- 本小组赛开始前3分钟之内（不包括第一小组）
	groupFighting			= 9				-- 每小组赛进行中
}

local _fighterInfoArray = {}
local _fighterInfoMap = {}
local _mustEnterFightMap = {}


--[[
	@desc:									处理军团成员信息
	@param:		table	p_fightInfoArray	
	{
		{
			uid:							用户Id
			uname:							用户名称
			level:							用户等级
			fight_force:					用户战斗力
			contr_num:						用户贡献值
			state							状态 0未出战|1已出战
		}
		{
			...
		}
	}
	@return:	nil
--]]
function setFighterInfoArray( p_fightInfoArray )
	_fighterInfoArray = p_fightInfoArray
	sortFighterInfo()
	initFighterMap()
	initMustEnterFightMap()
end

--[[
	@desc:				对军团成员信息进行排序
	@return:	nil
--]]
function sortFighterInfo()
	local comparer = function ( p_fighterInfo1, p_fighterInfo2 )
		local value1 = 0
		local value2 = 0
		local fightForceValue = 2
		local uidValue = 1
		local enterFightValue = 10
		-- 战斗力
		if tonumber(p_fighterInfo1.fight_force) < tonumber(p_fighterInfo2.fight_force) then
			value1 = value1 + fightForceValue
		elseif tonumber(p_fighterInfo1.fight_force) > tonumber(p_fighterInfo2.fight_force) then
			value2 = value2 + fightForceValue
		end
		if tonumber(p_fighterInfo1.uid) < tonumber(p_fighterInfo2.uid) then
			value1 = value1 + uidValue
		else
			value2 = value2 + uidValue
		end
		-- 是否出场
		if p_fighterInfo1.state == "1" then
			value1 = value1 + enterFightValue
		end
		if p_fighterInfo2.state == "1" then
			value2 = value2 + enterFightValue
		end
		return value1 > value2
	end
	table.sort(_fighterInfoArray, comparer)
	print("_fighterInfoArray======")
	print_t(_fighterInfoArray)
end

--[[
	@desc:						得到更新战斗力的剩余CD时间
	@return:		number
--]]
function getUpdateFormationRemainCDAndCost( ... )
	local lastUpdateTime = GuildWarMainData.getLastUpateFmtTime()
	if lastUpdateTime == 0 then
		return 0, 0
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	local _, timeConfig = getUpdateStatus(lastUpdateTime)
	local cd = timeConfig[1]
	local reminCD = lastUpdateTime + cd - curTime
	local cost = math.ceil(reminCD / 60) * tonumber(ActivityConfig.ConfigCache.guildwar.data[1].refreshFightCdCost)
	cost = cost < 0 and 0 or cost
	return reminCD, cost
end

--[[
	@desc:								当前能否更新
	@param:		number 	p_time 			时刻
	@retur:    	string  		
--]]
--function canUpdate( p_time )
function getUpdateStatus( p_time )
	p_time = p_time or TimeUtil.getSvrTimeByOffset(1)
	local timeConfig = parseField(ActivityConfig.ConfigCache.guildwar.data[1].cdtimefresh, 2)
	local curRound = GuildWarMainData.getRound()
	local curStatus = GuildWarMainData.getStatus()
	local curSubRound = GuildWarMainData.getSubRound()
	local curSubStatus = GuildWarMainData.getSubStatus()
	if curRound < GuildWarDef.AUDITION then
		if p_time + timeConfig[1][2] < GuildWarMainData.getStartTime(GuildWarDef.AUDITION) then
			return UpdateStatus.auditionAllow, timeConfig[1]
		else
			return UpdateStatus.auditionLimit, timeConfig[1]
		end
	elseif curRound == GuildWarDef.AUDITION and curStatus < GuildWarDef.END then
		return UpdateStatus.auditionFighting, timeConfig[1]
	else 
		if (curStatus == GuildWarDef.END and curRound == GuildWarDef.AUDITION)
		 or (curSubRound == GuildWarDef.GROUP_NUM and curSubStatus == GuildWarDef.FIGHTEND) then
		 	if p_time < GuildWarMainData.getEndTime(curRound) then
		 		return UpdateStatus.advancedNotEndAllow, timeConfig[2]
		 	elseif p_time + timeConfig[2][2] < GuildWarMainData.getStartTime(curRound + 1) then
				return UpdateStatus.advancedAllow, timeConfig[2]
			else
				return UpdateStatus.advancedLimit, timeConfig[2]
			end
		else
			if curSubStatus == GuildWarDef.FIGHTEND then
			 	if p_time + timeConfig[3][2] < GuildWarMainData.getStartTime(curRound, curSubRound + 1) then
					return UpdateStatus.groupAllow, timeConfig[3]
				else
					return UpdateStatus.groupLimit, timeConfig[3]
				end
			end
			return UpdateStatus.groupFighting, timeConfig[3]
		end
	end
end


--[[
	@desc:							得到更新时间的配置信息
	@param:		number	p_time 
	@return:  	table
--]]
function getUpdateFormationConfigByTime( p_time )
	local timeConfig = parseField(ActivityConfig.ConfigCache.guildwar.data[1].cdtimefresh, 2)
	local configIndex = nil
	if p_time < GuildWarMainData.getStartTime(GuildWarDef.AUDITION) then
		configIndex = 1
	elseif not isWholeFighting(p_time) then
		configIndex = 2
	else
		configIndex = 3
	end
	return timeConfig[configIndex]
end

--[[
	@desc:							是否在每轮的比赛中
	@param:		number    p_time   	时刻
	@return:	bool 		
--]]
function isWholeFighting( p_time )
	local rounds = {GuildWarDef.ADVANCED_16, GuildWarDef.ADVANCED_8, GuildWarDef.ADVANCED_4, GuildWarDef.ADVANCED_2}
	for i = 1, #rounds do
		local round = rounds[i]
		if p_time > GuildWarMainData.getStartTime(round) and p_time < GuildWarMainData.getEndTime(round, 5) then
			return true
		end
	end
	return false
end

--[[
	@desc:							是否在比赛中(小组与海选)
	@param:  	number p_time 		时刻
	@return		bool
--]]
function isFighting( p_time )
	-- 海选
	if p_time > GuildWarMainData.getStartTime(GuildWarDef.AUDITION) and p_time < GuildWarMainData.getEndTime(GuildWarDef.AUDITION) then
		return true
	end
	-- 小组与小组
	local rounds = {GuildWarDef.ADVANCED_16, GuildWarDef.ADVANCED_8, GuildWarDef.ADVANCED_4, GuildWarDef.ADVANCED_2}
	for i = 1, #rounds do
		local round = rounds[i]
		for j = 1, 5 do
			if p_time > GuildWarMainData.getStartTime(round, j) and p_time < GuildWarMainData.getEndTime(round, j) then
				return true
			end
		end
	end
	return false
end

--[[
	@desc:					初始化必须出战的人员
	@return:	nil
--]]
function initMustEnterFightMap()
	local fighterInfoArrayTemp = table.hcopy(_fighterInfoArray, {})
	local comparer = function ( p_fighterInfo1, p_fighterInfo2 )
		local value1 = 0
		local value2 = 0
		local fightForceValue = 2
		local uidValue = 1
		local enterFightValue = 5
		local leaderValue = 10
		-- 战斗力高的靠前
		if tonumber(p_fighterInfo1.fight_force) > tonumber(p_fighterInfo2.fight_force) then
			value1 = value1 + fightForceValue
		elseif tonumber(p_fighterInfo1.fight_force) < tonumber(p_fighterInfo2.fight_force) then
			value2 = value2 + fightForceValue
		end
		-- uid大的靠前
		if tonumber(p_fighterInfo1.uid) > tonumber(p_fighterInfo2.uid) then
			value1 = value1 + uidValue
		else
			value2 = value2 + uidValue
		end
		-- 出场的靠前
		if p_fighterInfo1.state == "1" then
			value1 = value1 + enterFightValue
		end
		if p_fighterInfo2.state == "1" then
			value2 = value2 + enterFightValue
		end
		-- 军团长靠前
		if p_fighterInfo1.member_type == "1" then
			value1 = value1 + leaderValue
		end
		if p_fighterInfo2.member_type == "1" then
			value2 = value2 + leaderValue
		end
		return value1 > value2
	end
	table.sort(fighterInfoArrayTemp, comparer)
	_mustEnterFightMap = {}
	for i = 1, 16 do
		local fighterInfo = fighterInfoArrayTemp[i]
		_mustEnterFightMap[fighterInfo.uid] = _fighterInfoMap[fighterInfo.uid]
	end
end

--[[
	@desc:									是否必须出场
	@param:			string 		p_uid		军团成员uid
	@return:		bool        			true表示必须出场，false表示不是必须出场
--]]
function isMustEnterFight( p_uid )
	return _mustEnterFightMap[p_uid] ~= nil
end

--[[
	@desc:		得到军团所有成员的战斗信息（数组结构）
	@return:	table 	_fighterInfoArray
--]]
function getFighterInfoArray( ... )
	return _fighterInfoArray
end

--[[
	@desc:					得到军团出战人数的限制
	@return:	number
--]]
function getEnterFightMaxCount( ... )
	return tonumber(ActivityConfig.ConfigCache.guildwar.data[1].eachHeroNum)
end

--[[
	@desc:					得到军团当前的出战人数
	@return:		number
--]]
function getEnterFighterCount( ... )
	local count = 0
	for i = 1, #_fighterInfoArray do
		local fighterInfo = _fighterInfoArray[i]
		if fighterInfo.state == "1" then
			count = count + 1
		end
	end
	return count
end

--[[
	@desc:					得到自己的出战顺序
	@return:		number
--]]
function getMyFightOrder( ... )
	local myUid = UserModel.getUserUid()
	for i = 1, #_fighterInfoArray do
		local fighterInfo = _fighterInfoArray[i]
		if fighterInfo.uid == tostring(myUid) and fighterInfo.state == "1" then
			return i
		end
	end
	return 0
end

--[[
	@desc:					得到自己地军团成员信息
	@return:	table
--]]
function getMyFighterInfo( ... )
	local myUid = UserModel.getUserUid()
	return _fighterInfoMap[tostring(myUid)]
end


--[[
	@desc:									根据fighterArray初始化map结构,key为军团成员uid
	@return: 		nil 				
--]]
function initFighterMap()
	_fighterInfoMap = {}
	for i = 1, #_fighterInfoArray do
		local fighterInfo = _fighterInfoArray[i]
		_fighterInfoMap[fighterInfo.uid] = fighterInfo
	end
end

--[[
	@desc:								报名后是否可以查看战斗信息
	@return:	bool
--]]
function couldLookAfterSignup( ... )
	local signupTime = GuildWarMainData.getSignUpTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	if curTime < signupTime + GuildWarDef.SIGNUP_CD_TIME then
		return false
	end
	return true
end
--[[
	@desc:								根据uid得到军团成员的战斗信息
	@param:		string 		p_uid 		军团成员的uid
	@return:	table					军团成员的战斗信息
--]]
function getFighterInfoByUid( p_uid )
	return _fighterInfoMap[tostring(p_uid)]
end

--[[
	@desc:							是否在调整上下场的时间段内
	@return:		bool
--]]
function couldModifyEnter( ... )
	local curRound = GuildWarMainData.getRound()
    local curStatus = GuildWarMainData.getStatus()
    if not GuildWarPromotionData.isEnd() then
    	if curRound <= GuildWarDef.AUDITION or curStatus == GuildWarDef.END then
    		return true
    	end
    end
    return false
end

--[[
	@desc:							根据下标得到军团成员的战斗信息
	@param:		number	p_index 	军团成员战斗信息的下标
	@return:	table 				军团成员的战斗信息
--]]
function getFighterInfoByIndex( p_index )
	return _fighterInfoArray[p_index]
end

--[[
	@desc:							设置军团成员（上场，下场)
	@param:		string	p_status 	"1"=>上场，"0"=>下场
	@param:		string 	p_uid		军团成员的uid
	@return:	nil
--]]
function setFighterStatus(p_status, p_uid)
	local fighterInfo = getFighterInfoByUid(p_uid)
	fighterInfo.state = p_status
	sortFighterInfo()
	initMustEnterFightMap()
end

--[[
	@desc:										更新用户阵型信息
	@param:		string 	p_fight_force			我的最新战斗力
	@return:	nil
--]]
function updateMyFightForce(p_fight_force)
	local myFightInfo = getFighterInfoByUid(tostring(UserModel.getUserUid()))
	myFightInfo.fight_force = tostring(p_fight_force)
	sortFighterInfo()
	initMustEnterFightMap()
end

--[[
	@desc:						清除更新cd时间
	@param:		table	p_data	{}
	@return: 	nil
--]]
function clearUpdateFormationCD()

end