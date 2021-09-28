-- FileName: GuildWarMainData.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarMainData 跨服军团战接口模块

module("GuildWarMainData", package.seeall)

require "script/model/utils/ActivityConfig"
require "script/ui/guildWar/GuildWarDef"
require "script/ui/guildWar/GuildWarUtil"
require "script/ui/guildWar/GuildWarStageEvent"
local _userGuildWarInfo = {}		-- 跨服赛基本数据
local _myTeamInfo = {}				-- 服务器列表信息
local _timeConfigs = {}				-- 时间配置解析信息表
--[[
	@des:初始化军团赛相关配置
--]]
function initate()
	if not table.isEmpty(_timeConfigs) then
		return
	end
	--时间总配置
	local promotedtime = ActivityConfig.ConfigCache.guildwar.data[1].promotedtime
	local activityOpenTime = ActivityConfig.ConfigCache.guildwar.start_time
	--得到配置时间
	local configTime = GuildWarUtil.convertConfigTime(promotedtime, activityOpenTime)
	--转化为各阶段时间戳
	_timeConfigs[GuildWarDef.INVALID] = {}
	_timeConfigs[GuildWarDef.INVALID].start_time = tonumber(activityOpenTime)
	_timeConfigs[GuildWarDef.INVALID].end_time   = configTime[1][1]
	_timeConfigs[GuildWarDef.INVALID].start_des  = "INVALID" .. ":" .. TimeUtil.getTimeFormatYMDHMS(tonumber(activityOpenTime)) 
	_timeConfigs[GuildWarDef.INVALID].end_des    = "INVALID" .. ":" .. TimeUtil.getTimeFormatYMDHMS(configTime[1][1]) 
	local stages = { 
		[GuildWarDef.SIGNUP]      = "SIGNUP",
		[GuildWarDef.AUDITION]    = "AUDITION",
		[GuildWarDef.ADVANCED_16] = "ADVANCED_16",
		[GuildWarDef.ADVANCED_8]  = "ADVANCED_8",
		[GuildWarDef.ADVANCED_4]  = "ADVANCED_4",
		[GuildWarDef.ADVANCED_2]  = "ADVANCED_2",
	}

	for k,v in pairs(stages) do
		_timeConfigs[k] = {}
		_timeConfigs[k].start_time = configTime[k][1] 
		_timeConfigs[k].end_time   = configTime[k][2]
		_timeConfigs[k].start_des  = v .. ":" .. TimeUtil.getTimeFormatYMDHMS(configTime[k][1]) 
		_timeConfigs[k].end_des    = v .. ":" .. TimeUtil.getTimeFormatYMDHMS(configTime[k][2]) 
	end

	printTable("_timeConfigs", _timeConfigs)
	print("\n")
	print("group time", getGroupTime())
	-- test bzx
	print_t(ActivityConfig.ConfigCache.guildwar.data[1])
end

--[[
	@des:显示小红点
--]]
function isShowRedTip()
	if ActivityConfigUtil.isActivityOpen("guildwar") == false then
		return false
	end
	--玩家有没有军团
	if GuildDataCache.getMineSigleGuildId() <= 0 then
		return false
	end
	--军团等级大于报名要求等级
	local guildNeedLevel = GuildWarMainData.getNeedSignGuildLevel()
	if GuildDataCache.getGuildHallLevel() < guildNeedLevel then
		return false
	end

	--有分组信息
	local isOk = getIsOk()
	if not isOk then
		return false
	end

	require "script/ui/guildWar/GuildWarMainLayer"
	if GuildWarMainLayer.getIsEneter() then
		return false
	else
		local time = TimeUtil.getSvrTimeByOffset()
		local bTime = getStartTime(GuildWarDef.SIGNUP)
		local eTime = getEndTime(GuildWarDef.SIGNUP)
		if time > bTime and time < eTime then
			if not isSignUp() then
				return true
			end
		end
		return false
	end
end

--[[
	@des:是不是在同一个分组中
--]]
function getIsOk( ... )
	if not _userGuildWarInfo then
		return
	end
	if _userGuildWarInfo.ret == "ok" then
		return true
	else
		return false
	end
end

--[[
	@des:得到军团赛时间配置
	@ret:
	timeconfig ={
		[round] =>{
			start_time,
			end_time,
			des,
		}
	}
--]]
function getTimeConfig()
	return _timeConfigs
end

--[[
	@des:得到军团信息
--]]
function getUserGuildWarInfo()
	return _userGuildWarInfo
end

--[[
	@des:重置军团赛信息
--]]
function setUserGuildWarInfo( p_info )
	_userGuildWarInfo = p_info
	printTable("setUserGuildWarInfo", p_info)
end

--[[
	@des:得到当前round
--]]
function getRound()
	return tonumber(_userGuildWarInfo.round)
end

--[[
	@des:设置当前round
--]]
function setRound( p_round )
	_userGuildWarInfo.round = p_round
end

--[[
	@des:得到当前Status
--]]
function getStatus()
	return tonumber(_userGuildWarInfo.status)
end

--[[
	@des:设置当前Status
--]]
function setStatus( p_status )
	_userGuildWarInfo.status = p_status
end

--[[
	@des:得到当前SubRound
--]]
function getSubRound()
	return tonumber(_userGuildWarInfo.sub_round)
end

--[[
	@des:设置当前SubRound
--]]
function setSubRound( p_subRound )
	_userGuildWarInfo.sub_round = p_subRound
end

--[[
	@des:得到当前SubRound
--]]
function getSubStatus()
	return tonumber(_userGuildWarInfo.sub_status)
end

--[[
	@des:设置当前SubRound
--]]
function setSubStatus( p_subStatus )
	_userGuildWarInfo.sub_status = p_subStatus
end

--[[
	@des:得到阶段的开始时间
	@parm :
--]]
function getStartTime( p_round, p_subRound )
	if p_round > GuildWarDef.ADVANCED_2 then
		p_round = GuildWarDef.ADVANCED_2
	end
	printTable("_timeConfigs", _timeConfigs)
	print("p_round", p_round)
	local startTime = _timeConfigs[p_round].start_time
	if p_round == GuildWarDef.INVALID 
		or p_round == GuildWarDef.SIGNUP
		or p_round == GuildWarDef.AUDITION then
			return startTime
	else
		if p_subRound ~= nil then
			startTime = startTime + (p_subRound - 1)*getGroupTime()
		end
		return startTime
	end
	return startTime
end

--[[
	@des:得到阶段结束时间
--]]
function getEndTime( p_round, p_subRound )
	if p_round > GuildWarDef.ADVANCED_2 then
		p_round = GuildWarDef.ADVANCED_2
	end
	local endTime = _timeConfigs[p_round].end_time
	local startTime = _timeConfigs[p_round].start_time
	if p_round == GuildWarDef.INVALID 
		or p_round == GuildWarDef.SIGNUP
		or p_round == GuildWarDef.AUDITION then
			return endTime
	else
		if p_subRound ~= nil then
			endTime = startTime + p_subRound*getGroupTime()
			return endTime
		end
	end
	return endTime
end

--[[
	@des:比赛是否结束
--]]
function isGameOver()
	if getRound() == GuildWarDef.ADVANCED_2 
		and getStatus() >= GuildWarDef.DONE then
			return true
	else
		return false
	end
end

--[[
	@des:得到最大连胜次数
--]]
function getMaxWinNum()
	return tonumber(_userGuildWarInfo.buy_max_win_num) 
end

--[[
	@des:设置最大连胜次数
--]]
function setMaxWinNum( p_num )
	_userGuildWarInfo.buy_max_win_num = p_num
end

--[[
	@des:增加最大连胜次数
--]]
function addMaxWinNum( p_num )
	_userGuildWarInfo.buy_max_win_num = tonumber(_userGuildWarInfo.buy_max_win_num) + tonumber(p_num)
end

--[[
	@des:得到上次更新战斗力的时间
--]]
function getLastUpateFmtTime()
	return tonumber(_userGuildWarInfo.update_fmt_time) 
end

--[[
	@des:设置上次更新战斗力的时间
--]]
function setLastUpateFmtTime( p_time )
	_userGuildWarInfo.update_fmt_time = p_time 
end

--[[
	@des:得到上次助威时间
--]]
function getCheerRound()
	return tonumber(_userGuildWarInfo.cheer_time) 
end

--[[
	@des:得到上次助威时间
--]]
function setCheerRound( p_round )
	_userGuildWarInfo.cheer_round = p_round 
end

--[[
	@des:得到助威军团信息
	@ret: guildId, guildServerId
--]]
function getCheerGuild()
	return tonumber(_userGuildWarInfo.cheer_guild_id), tonumber(_userGuildWarInfo.cheer_guild_server_id)
end

--[[
	@des:得到助威军团信息
	@parm: guildId, guildServerId
--]]
function setCheerGuild( p_guildId, p_servertId )
	_userGuildWarInfo.cheer_guild_id = p_guildId
	_userGuildWarInfo.cheer_guild_server_id = p_servertId
end

--[[
	@des:判断当前阶段是否已经助威过
	@ret: bool true 已经助威 false 尚未助威
--]]
function isCheered()
	local curRound = getRound()
	if getCheerRound() ~= curRound then
		return false
	else
		return true
	end
end

--[[
	@des:得到膜拜时间
	@ret:worshi_time
--]]
function getLastWorshipTime()
	return tonumber(_userGuildWarInfo.worship_time)
end

--[[
	@des:设置膜拜时间
	@parm:worshi_time
--]]
function setLastWorshipTime( p_time )
	_userGuildWarInfo.worship_time = p_time
end

--[[
	@des:得到报名时间
--]]
function getSignUpTime()
	return tonumber(_userGuildWarInfo.sign_time) or 0
end

--[[
	@des:设置报名时间
--]]
function setSignUpTime( p_time )
	_userGuildWarInfo.sign_time = p_time
end

--[[
	@des:自己所在军团是否报名
	@ret true 已报名, false 未报名
--]]
function isSignUp()
	if getSignUpTime() == 0 then
		return false
	else
		return true
	end
end

--[[
	@des: 得到报名军团数量
--]]
function getSignCuildCont()
	return tonumber(_userGuildWarInfo.sign_up_count)
end

--[[
	@des:得到当前是第一届跨服赛
--]]
function getSession()
	return tonumber(_userGuildWarInfo.session) - 1
end

--[[
	@des:得到服务器列表信息
--]]
function getMyTeamInfo()
	local serverInfo = {}
	for k,v in pairs(_myTeamInfo) do
		local value = {}
		value.name = v
		value.key  = tonumber(k)
		table.insert(serverInfo, value)
	end
	table.sort( serverInfo, function ( h1, h2 )
		return h1.key < h2.key
	end )
	printTable("serverInfo", serverInfo)
	return serverInfo
end

--[[
	@des:设置服务器列表信息
--]]
function setMyTeamInfo( p_info )
	_myTeamInfo = p_info
end

--[[
	@des:得到自己所在服务的id
--]]
function getMyServerId( ... )
	return _userGuildWarInfo.server_id or "nil"
end

--[[
	@des : 得到自己的服务器描述
--]]
function getMyServerName()
	local myServerId = getMyServerId()
	local serverName = _myTeamInfo[myServerId]
	return serverName or "nil"
end

--[[
	@des:得到报名军团的限制等级
--]]
function getNeedSignGuildLevel()
	local needLv = ActivityConfig.ConfigCache.guildwar.data[1].needLv
	return tonumber(needLv)
end

--[[
	@des:得到每组小组赛到下一轮小组赛的间隔时间
--]]
function getGroupTime()
	local battlegrouptime = ActivityConfig.ConfigCache.guildwar.data[1].battlegrouptime
	return tonumber(battlegrouptime)
end

--[[
	@des:报名军团人数限制
--]]
function getSignNeedMemberNum()
	local neednumbers = ActivityConfig.ConfigCache.guildwar.data[1].neednumbers
	return tonumber(neednumbers)
end
