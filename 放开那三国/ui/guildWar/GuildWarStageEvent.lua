-- FileName: GuildWarStageEvent.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarStageEvent 跨服军团战常量定义


module("GuildWarStageEvent", package.seeall)

require "script/ui/guildWar/promotion/GuildWarPromotionData"

local _eventMap = nil
local _timeNode   = nil
--[[
	@des:初始化监听器
--]]
function initate()
	--require "script/ui/guildWar/GuildWarMainService"
	if _eventMap then
		return
	end
	_eventMap = {}
	GuildWarMainService.registerStageChangePush(guildWarStageChangeCallback)
	--检查时间阶段
	-- _timeNode = CCNode:create()
	-- CCDirector:sharedDirector():getRunningScene():addChild(_timeNode)
	-- schedule(_timeNode, updateTime, 1)
	open()
end

--[[
	@des:销毁方法
--]]
function destory()
	_eventMap = nil
	-- if _timeNode then
	-- 	_timeNode:removeFromParentAndCleanup(true)
	-- 	_timeNode = nil
	-- end
	close()
	GuildWarMainService.removeStageChangePush()
end

--[[
	@des:注册监听方法
--]]
function registerListener( p_callfunc )
	if not p_callfunc then
		return
	end
	_eventMap[p_callfunc] = p_callfunc
end

--[[
	@des:删除监听器
--]]
function removeListener( p_callfunc )
	_eventMap[p_callfunc] = nil
end


--[[
	@author: 	bzx
	@desc:				开启前端推送
	@return:	nil	
--]]
function open( ... )
	if isEnd() then
		return
	end
	_timeNode = CCNode:create()
	CCDirector:sharedDirector():getRunningScene():addChild(_timeNode)
	schedule(_timeNode, updateTime, 1)
end

--[[
	@author:	bzx
	@desc:				关闭前端推送
	@return:	nil
--]]
function close( ... )
	if tolua.cast(_timeNode, "CCNode") then
		_timeNode:removeFromParentAndCleanup(true)
	end
end

--[[
	@author:	bzx
	@desc:				前端推送是否结束
	@return:	bool
--]]
function isEnd( ... )
	local curRound     = GuildWarMainData.getRound()
	local curStatus    = GuildWarMainData.getStatus()
	if curRound == ADVANCED_2 and curStatus >= GuildWarDef.END then
		return true
	end
	return false
end

--[[
	@des:定时器
--]]
function updateTime(p_isFirst)
	local curRound     = GuildWarMainData.getRound()
	local curStatus    = GuildWarMainData.getStatus()
	local curSubRound  = GuildWarMainData.getSubRound()
	local curSubStatus = GuildWarMainData.getSubStatus()
	local curTime = BTUtil:getSvrTimeInterval()
	local round = curRound
	local status = curStatus
	local subRound = curSubRound
	local subStatus = curSubStatus
	if curRound == GuildWarDef.INVALID then
		if curTime >= GuildWarMainData.getStartTime(GuildWarDef.SIGNUP) then
			round = GuildWarDef.SIGNUP
			status = GuildWarDef.WAIT_TIME_END
		end
	elseif curStatus == GuildWarDef.DONE or curRound == GuildWarDef.SIGNUP then
		if curTime >= GuildWarMainData.getEndTime(curRound) then
			status = GuildWarDef.END
		end
	end
	if not p_isFirst and status == GuildWarDef.END and curStatus ~= GuildWarDef.END then
		-- 清除上一轮的助威信息
		GuildWarMainData.setCheerGuild(0, 0)
		if not GuildWarPromotionData.myEnemyIsEmpty() then
			GuildWarMainData.setMaxWinNum(0)
			GuildWarPromotionUtil.refreshAddWinCountItem()
		end
	end

	if status == GuildWarDef.END and curRound < GuildWarDef.ADVANCED_2 then
		if curTime >= GuildWarMainData.getStartTime(curRound + 1) then
			round = curRound + 1
			status = GuildWarDef.FIGHTING
			if round >= GuildWarDef.ADVANCED_16 and round <= GuildWarDef.ADVANCED_2 then
				subRound = 1
				subStatus = GuildWarDef.FIGHTING
			end
		end
	end
	if round >= GuildWarDef.ADVANCED_16 and round <= GuildWarDef.ADVANCED_2 then
		if status == GuildWarDef.FIGHTING then
			if curSubStatus == GuildWarDef.FIGHTEND then
				if curSubRound < GuildWarDef.GROUP_NUM and curTime >= GuildWarMainData.getStartTime(curRound, curSubRound + 1) then
					subRound = curSubRound + 1
					subStatus = GuildWarDef.FIGHTING
				end
			end
		end
	end
	if curRound ~= round or curStatus ~= status or curSubRound ~= subRound or curSubStatus ~= subStatus then
		GuildWarMainData.setRound(round)
		GuildWarMainData.setStatus(status)
		GuildWarMainData.setSubRound(subRound)
		GuildWarMainData.setSubStatus(subStatus)
		if not p_isFirst then
			execute()
		end
	end
	if isEnd() then
		close()
	end
	--[[
	local currTime = BTUtil:getSvrTimeInterval() + GuildWarDef.OFFSET_TIME
	local timeconfigs = GuildWarMainData.getTimeConfig()
	--阶段开始通知
	for k,v in pairs(timeconfigs) do
		if currTime > v.start_time and currTime < v.end_time then
			--round发生了改变
			if k ~= GuildWarMainData.getRound() then
				--修改当前round
				GuildWarMainData.setRound(k)
				--修改当前status
				GuildWarMainData.setStatus(GuildWarDef.FIGHTING)
				--修改当前sub_round
				GuildWarMainData.setSubRound(1)
				--修改当前sub_status
				GuildWarMainData.setSubStatus(GuildWarDef.FIGHTING)
				--调用监听时间
				execute()
			end
			--round没变，subRound变了
			local subRound = getSubRoundByTime(currTime - v.start_time)
			print("GuildWarMainData.getStatus()", GuildWarMainData.getStatus())
			if k == GuildWarMainData.getRound() 
				and subRound ~= GuildWarMainData.getSubRound()
				and GuildWarMainData.getStatus() < GuildWarDef.DONE then
					--修改当前sub_round
					GuildWarMainData.setSubRound(subRound)
					--修改当前status
					GuildWarMainData.setSubStatus(GuildWarDef.FIGHTING)
					--调用监听时间
					execute()
			end
		end
		if k == GuildWarMainData.getRound() 
			and currTime > v.end_time
			and GuildWarMainData.getStatus() < GuildWarDef.END then
				GuildWarMainData.setStatus(GuildWarDef.END)
				--调用监听时间
				execute()
		end
	end
	--]]
end

--[[
	@des:根据当前round经过的时间计算出当前的subRound
	@parm:根据当前round经过的时间
	@ret: sub_round
--]]
function getSubRoundByTime( p_time )
	local groupTime = GuildWarMainData.getGroupTime()
	local subRound = math.floor(p_time/groupTime) + 1
	if subRound>= GuildWarDef.GROUP_NUM then
		subRound = 5
	end
	return subRound
end

--[[
	@des: 执行注册回调
--]]
function execute()
	print("GuildWarStageEvent execute")
	print(GuildWarMainData.getRound(),  GuildWarMainData.getStatus(), GuildWarMainData.getSubRound(), GuildWarMainData.getSubStatus())
	local keys = {}
	for k,v in pairs(_eventMap) do
		table.insert(keys, k)
	end
	for i=1, #keys do
		local key = keys[i]
		local v = _eventMap[key]
		if v ~= nil then
			v(GuildWarMainData.getRound(),  GuildWarMainData.getStatus(), GuildWarMainData.getSubRound(), GuildWarMainData.getSubStatus())
		end
	end
end

--[[
	@des:推送监听接口
	@parm:	
--]]
function guildWarStageChangeCallback( p_round, p_status, p_subRound, p_subStatus)
	GuildWarMainData.setRound(p_round)
	GuildWarMainData.setStatus(p_status)
	GuildWarMainData.setSubRound(p_subRound)
	GuildWarMainData.setSubStatus(p_subStatus)

	execute()
end

