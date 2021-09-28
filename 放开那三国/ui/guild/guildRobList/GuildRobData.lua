-- Filename：	GuildRobData.lua
-- Author：		bzx
-- Date：		2014-11-12
-- Purpose：		粮仓数据

module("GuildRobData", package.seeall)

require "db/DB_Rob_food"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/LiangCangMainLayer"


local _robList = {}
local _pushGuild = 1
local _curPageIndex = 1
local _searchKey 
local _myGuildRobInfo
local _createInfo
local _offline = "0"

-- 粮仓数据变化会推送
function handlePushGuildRobInfo( cbFlag, dictData, bRet )
	if dictData.err ~= "ok" then
		return
	end
	require "script/ui/guild/guildRobList/GuildRobListLayer"
	if _myGuildRobInfo.guildId == tonumber(dictData.ret.guildId) then
		_myGuildRobInfo = _myGuildRobInfo or {}
		local guildRobInfo = parseGuildInfo(dictData.ret, dictData.ret.guildId)
		_myGuildRobInfo.robId = guildRobInfo.robId

		if GuildDataCache.isInGuildFunc() == true then
			if GuildDataCache.getGuildFightBookNum() ~= guildRobInfo.fight_book then
				GuildDataCache.setGuildFightBookNum(guildRobInfo.fight_book)
				LiangCangMainLayer.refreshFightBookNum()
			end
		end

		for k, v in pairs(guildRobInfo) do
			_myGuildRobInfo[k] = v
		end
		print_t(_myGuildRobInfo)
		GuildRobListLayer.refreshRobSceneItem()
	end
	if GuildRobListLayer.isRunning() == true then
		local guildInfo = nil
		_robList.guildInfo = _robList.guildInfo or {}
		if _robList.guildInfo[tonumber(dictData.ret.guildId)] ~= nil then
			guildInfo = parseGuildInfo(dictData.ret, dictData.ret.guildId)
			_robList.guildInfo[guildInfo.guildId] = guildInfo
			GuildRobListLayer.refreshGranaryByGuildId(guildInfo.guildId)
		end
	end
end

-- 自己所在的军团是否有发起抢粮战
function isRobbing( ... )
	return _myGuildRobInfo ~= nil and _myGuildRobInfo.robId ~= 0 
end

-- 得到哪一页的数据
function getGuildRobAreaInfo(callback, pageIndex, searchKey)
	local handleGetGuildRobAreaInfo = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if searchKey ~= nil and table.isEmpty(dictData.ret.guildInfo) then
			if callback ~= nil then
				callback(dictData)
			end
			return
		end
		if searchKey == nil then
			_curPageIndex = pageIndex
		end
		setSearchKey(searchKey)
		_robList.inRob = dictData.ret.inRob
		_robList.areaNum = tonumber(dictData.ret.areaNum)
		_robList.guildInfo = {}
		for k, v in pairs(dictData.ret.guildInfo) do
			local guildInfo = parseGuildInfo(v, k)
			_robList.guildInfo[guildInfo.guildId] = guildInfo
		end
		if searchKey == nil then
			local myGuildRobInfo = getMyGuildRobInfo()
			if _curPageIndex == 1 then
				_robList.guildInfo[myGuildRobInfo.guildId] = myGuildRobInfo
			end
		end
		if callback ~= nil then
			callback(dictData)
		end
	end
	local args = Network.argsHandler(pageIndex, searchKey)
	RequestCenter.guildRobGetGuildRobAreaInfo(handleGetGuildRobAreaInfo, args)
end

-- 发起抢粮
--  *
--  * @param int p_defenseGuildId 		被抢夺的军团ID
--  *
--  * @return string
--  * 'defense_too_much'				被抢夺的次数太多啦
--  * 'attack_too_much'    				抢夺的次数太多啦
--  * 'lack_fight_book'					缺少战书
--  * 'fighting'						两个军团有一个正在和别的军团干架
--  * 'ok'								可以开打
function guildRobCreate(guildId, callback)
	local handleGuildRobCreate = function ( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		_myGuildRobInfo.robId = tonumber(dictData.ret.robId or 0)
		_myGuildRobInfo.attackerCount = dictData.ret.attackerCount
		_myGuildRobInfo.defenderCount = dictData.ret.defenderCount
		if callback ~= nil then
			callback(dictData.ret)
		end
	end
	local args = Network.argsHandler(guildId)
	RequestCenter.guildRobCreate(handleGuildRobCreate, args)
end

function handleGetGuildRobInfo( cbFlag, dictData, bRet )
	if dictData.err ~= "ok" then
		return
	end
	_myGuildRobInfo = _myGuildRobInfo or {}
	local guildRobInfo = parseGuildInfo(dictData.ret, dictData.ret.guildId)
	for k, v in pairs(guildRobInfo) do
		_myGuildRobInfo[k] = v
	end
	-- if _myGuildRobInfo.robId ~= 0 then
	-- 	LiangCangMainLayer.refreshFightBookNum()
	-- end
end

--[[
	guildId 		军团id
	name 			军团名称
	grain 			可抢粮食
	barn_level 		粮仓等级
	robId 			战场Id
	attackerCount 	抢粮军团总人数
	defenderCount	被抢军团总人数
]]
function getMyGuildRobInfo( ... )
	return _myGuildRobInfo
end

-- 得到自已军团的robId
function getMyGuildRobId( ... )
	return tonumber(_myGuildRobInfo.robId)
end

-- 离开抢粮仓界面
function leavelGuildRobArea(callback)
	local handleLeavelGuildRobArea = function( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		if callback ~= nil then
			callback()
		end
	end
	RequestCenter.guildRobLeaveGuildRobArea(handleLeavelGuildRobArea)
	--handleLeavelGuildRobArea(nil, {err = "ok"})
end

-- 获取离线设置信息
function getInfo( callback )
	local handleGetInfo = function( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		_offline = dictData.ret
		if callback ~= nil then
			callback()
		end
	end
	RequestCenter.guildRobGetInfo(handleGetInfo)
end

-- 离线设置
function offline( callback, ret)
	local handleOffline = function( cbFlag, dictData, bRet )
		if dictData.err ~= "ok" then
			return
		end
		_offline = dictData.ret
		if callback ~= nil then
			callback()
		end
	end
	local args = Network.argsHandler(ret)
	RequestCenter.guildRobOffline(handleOffline, args)
end

function getOffline( ... )
	return _offline
end

function parseGuildInfo(guildInfo, guildId)
	local newGuildInfo = {}
	newGuildInfo.name = guildInfo.name or "nil"
	newGuildInfo.grain = tonumber(guildInfo.grain or 0)
	newGuildInfo.barn_level = tonumber(guildInfo.barn_level or 0)
	-- newGuildInfo.state = guildInfo.state
	newGuildInfo.guildId = tonumber(guildId or 0)
	newGuildInfo.robId = tonumber(guildInfo.robId or 0)
	newGuildInfo.shelterTime = tonumber(guildInfo.shelterTime or 0)
 	newGuildInfo.cdTime = tonumber(guildInfo.cdTime or 0)
 	newGuildInfo.fight_book = tonumber(guildInfo.fight_book or 0)
	return newGuildInfo
end

function getRobList()
	return _robList
end

function getGranaryInfoByGuildId(guildId)
	return _robList.guildInfo[tonumber(guildId)]
end

function getGranaryIndexByGuildId( guildId )
	local granaryIndex = 1
	if guildId ~= _myGuildRobInfo.guildId then
		if _robList.guildInfo[_myGuildRobInfo.guildId] ~= nil then
			granaryIndex = 2
		end
		for k, v in pairs(_robList.guildInfo) do
			if k == guildId then
				break
			end
			if k ~= _myGuildRobInfo.guildId then
				granaryIndex = granaryIndex + 1
			end
		end
	end
	return granaryIndex
end

function getCurPageIndex( ... )
	return _curPageIndex
end


--[[
	@desc 	得到抢粮时间段的配置信息
	@return {
				{
					week 			星期（星期日为0）
					beginTime 		开始的时间 例:10:45:00点104500
					endTime    		结束的时间 例:10:45:00点104500
				}
				{ 
					... 
				}
			}
--]]
function getGuildRobTimeConfig( ... )
	local timeConfig = {}
	local timeConfigTemp = UserModel.getTimeConfig("guildrob")
	for i = 1, 7 do
		local dayTimeInfo = timeConfigTemp[tostring(i)]
		if dayTimeInfo ~= nil then
			local timeInfo = {}
			timeInfo.week = i == 7 and 0 or i
			timeInfo.beginTime = tonumber(dayTimeInfo[1])
			timeInfo.endTime = tonumber(dayTimeInfo[2])
			table.insert(timeConfig, timeInfo)
		end
	end
	local comparator = function (timeInfo1, timeInfo2 )
		return timeInfo1.week < timeInfo2.week
	end
	table.sort(timeConfig, comparator)
	return timeConfig
end

--[[
	@desc 	得到抢粮时间段的配置信息，这里返回的是时间戳
	@return {
				{
					week 			星期（星期日为0）
					beginTime 		开始的时间 时间戳
					endTime    		结束的时间 时间戳
				}
				{
					...
				}
			}
--]]

function getGuildRobSvrTimeInfo()
	local timeConfig = table.hcopy(getGuildRobTimeConfig(), {})
	local curTime = TimeUtil.getSvrTimeByOffset()
	local curWeek = tonumber(os.date("%w",curTime))
	for i=1, #timeConfig do
		local timeInfo = timeConfig[i]
		local dayDelta = 0
		if curWeek < timeInfo.week then
			dayDelta = timeInfo.week - curWeek
		elseif curWeek > timeInfo.week then
			dayDelta = timeInfo.week + 7 - curWeek
		end
		local dayTime = dayDelta * 86400
		timeInfo.beginTime = TimeUtil.getSvrIntervalByTime(timeInfo.beginTime) + dayTime
		timeInfo.endTime = TimeUtil.getSvrIntervalByTime(timeInfo.endTime) + dayTime
	end
	return timeConfig
end

--[[
	@desc 	得到与UI相关的抢粮时间段配置信息，这里返回的是时间戳
	@return {
				isNextWeek		是否是下周
				week 			星期（星期日为0）
				beginTime 		开始的时间 时间戳
				endTime    		结束的时间 时间戳
				remainTime 		抢粮开始倒计时
				endRemainTime	抢粮结束倒计时
			}
--]]
function getTimeInfo( ... )
	local svrTimeInfo = getGuildRobSvrTimeInfo()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local curWeek = tonumber(os.date("%w",curTime))
	local timeInfo = {}
	timeInfo.curTime = curTime
	for i=1, #svrTimeInfo do
		local dayTimeInfo = svrTimeInfo[i]
		timeInfo.isNextWeek = false
		local configIndex = i
		if curTime >= dayTimeInfo.endTime or curWeek > dayTimeInfo.week then
			configIndex = i + 1
			if configIndex > #svrTimeInfo then
				configIndex = 1
				timeInfo.isNextWeek = true
			end
		end
		if curWeek <= dayTimeInfo.week or timeInfo.isNextWeek == true then
			timeInfo.week = svrTimeInfo[configIndex].week
			timeInfo.beginTime = svrTimeInfo[configIndex].beginTime
			timeInfo.endTime = svrTimeInfo[configIndex].endTime
			break
		end
	end
	timeInfo.remainTime = timeInfo.beginTime - curTime
	timeInfo.endRemainTime = timeInfo.endTime - curTime
	return timeInfo
end

function setSearchKey(searchKey)
	_searchKey = searchKey
end

function getSearchKey( ... )
	return _searchKey
end

function robBegin( ... )
	_robList.inRob = "1"
end

function isAllRobbing( ... )
	local timeInfo = getGuildRobSvrTimeInfo()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local allIsRobbing = false
	for i = 1, #timeInfo do
		local timeInfoTemp = timeInfo[i]
		if timeInfoTemp.beginTime < curTime and curTime < timeInfoTemp.endTime then
			allIsRobbing = true
			break
		end
	end
	return allIsRobbing
end

function robEnd( ... )
	_robList.inRob = "0"
end

-------------------------------------------------- 抢夺粮草信息数据 -----------------------------------------------
-- add by licong

local _robEnemyList = {} -- 抢粮列表数据

--[[
	@des 	:设置抢夺粮草信息
	@param 	:p_robEnemyList 抢夺粮草信息列表
	@return :
--]]
function setRobEnemyList(p_robEnemyList)
	_robEnemyList = p_robEnemyList
end

--[[
	@des 	:得到抢夺粮草信息
	@param 	:
	@return :
--]]
function getRobEnemyList()
	return _robEnemyList
end

--[[
	@des 	:根据被抢时间戳得到抢夺粮草信息对应的信息
	@param 	:p_robTime
	@return :
--]]
function getRobEnemyInfoByRobTime( p_robTime )
	local retData = {}
	if( not table.isEmpty(_robEnemyList) )then
		for k,v in pairs(_robEnemyList) do
			if( tonumber(v.rob_time) == tonumber(p_robTime) )then
				retData = v
				break
			end
		end
	end
	return retData
end
