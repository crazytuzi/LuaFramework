--迷仙阵事件
require ("base.base")
require ("base.common")
require ("base.class")

--迷仙阵事件类型 配置
g_mazeEventCfg = {}
g_mazeEventMgr = {}

--读取迷仙阵事件配置文件
function LoadMazeEventCfg()
	g_mazeEventCfg = {}
	package.loaded["data.fanxianfront"]=nil
	local mazeEventData = require "data.fanxianfront"
	--local mazeEventData = mazeEventCfgData
	local mazeEventCnt = #mazeEventData
	local totalProb = 0
	for i=1, mazeEventCnt do
		local tmp = {}
		local mazeEventProto = mazeEventData[i]
		tmp.eventID = mazeEventProto.q_id
		tmp.mapID = mazeEventProto.q_map_id
		tmp.enterPos = unserialize('{' ..mazeEventProto.q_enter_xy .. '}')
		if not mazeEventProto.q_monster then
			mazeEventProto.q_monster = ""
		end
		tmp.monsters = '{' ..mazeEventProto.q_monster .. '}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.maxCircle = mazeEventProto.q_maxCircle or 0
		tmp.totalTime = mazeEventProto.q_time or 0
		if not mazeEventProto.q_reward then
			mazeEventProto.q_reward = ""
		end
		tmp.rewardID = '{' ..mazeEventProto.q_reward .. '}'
		tmp.rewardID = string.gsub(tmp.rewardID, '%[', '%{')
		tmp.rewardID = string.gsub(tmp.rewardID, '%]', '%}')
		tmp.rewardID = unserialize(tmp.rewardID)
		
		if mazeEventProto.q_prob then
			totalProb = mazeEventProto.q_prob + totalProb
			tmp.prob = totalProb
		else
			tmp.prob = 0
		end

		--print("LoadMazeEventCfg ", tmp.eventID, tmp.prob, serialize(tmp.rewardID))
		g_mazeEventCfg[tmp.eventID] = tmp
	end
end

local getMazeEventTotaltime = function(eventType)
	local mazeEventCfg = g_mazeEventCfg[eventType]
	if mazeEventCfg then
		return mazeEventCfg.totalTime 
	end
end

local getMazeEventMaxCircle = function(eventType)
	local mazeEventCfg = g_mazeEventCfg[eventType]
	if mazeEventCfg then
		return mazeEventCfg.maxCircle 
	end
end

--迷仙阵刷怪
local MonsterRandomPos = 
{
	{-1,0},  {-1,1},  {0,1},   {1,1},   {1,0},   {1,-1},   {0,-1},  {-1,-1}, 
	{-2,0},  {-2,1},  {-2,2},  {-1,2},  {0,2},   {1,2},    {2,2},   {2,1},  {2,0}, {2,-1},  {2,-2},  {1,-2},  {0,-2},  {-1,-2},  {-2,-2},  {-2,-1},
	{-3,0},  {-3,1},  {-3,2},  {-3,3},  {-2,3},  {-1,3},   {0,3},   {1,3},  {2,3},  {3,3},   {3,2},   {3,1},   {3,0},   {3,-1},   {3,-2},    {3,-3},
	{2,-3},  {1,-3},  {0,-3},  {-1,-3}, {-2,-3}, {-3,-3},  {-3,-2}, {-3,-1}
}

--monsters 格式：{{1, {{}, {}, {},}, id, x, y}, {}, {}}
local MazeflushMonster = function(player, mazeEvent, scene, currCircle)
	if not scene then
		return false
	end

	local mazeEventCfg = g_mazeEventCfg[mazeEvent]
	if not mazeEventCfg or #mazeEventCfg.monsters == 0 then
		return false
	end
	
	local level = player:getLevel()

	local cfgCircle = #mazeEventCfg.monsters
	local monCircle = currCircle % cfgCircle
	if monCircle == 0 then
		monCircle = cfgCircle
	end

	local monInfo = mazeEventCfg.monsters[monCircle]
	
	print(serialize(monInfo))
	local mondata = monInfo[2]
	local monNum = monInfo[3]
	local position = {x = monInfo[4], y = monInfo[5]}
	local monId = 0
	if type(mondata) == "table" then
		for i=1, #mondata do
			if level >= mondata[i][1] and level <= mondata[i][2] then
				monId = mondata[i][3]
				break
			end
		end
	else
		monId = mondata
	end

	print("MazeflushMonster",currCircle,cfgCircle,monCircle,monId,monNum)
	local monposnum = #MonsterRandomPos
	--是否是固定刷新点配置
	local fixedPos = (monInfo[6] and #monInfo[6] > 0) or false

	for j=1, monNum do
		local x, y = 0, 0
		--随机一个可刷怪点
		if fixedPos == false then
			local monnum = 0
			for loop = 1, monposnum do
				local randomindex = math.random(1, monposnum)
				if scene:isBlock(position.x+MonsterRandomPos[randomindex][1], position.y+MonsterRandomPos[randomindex][2]) == false then
					monnum = randomindex
					break
				end
			end

			if monnum ~= 0 then
				x = position.x+MonsterRandomPos[monnum][1]
				y = position.y+MonsterRandomPos[monnum][2]
			else
				break
			end
		--固定一个可刷怪点
		else
			local monposes = monInfo[6]
			local monnum = j % #monposes
			if monnum == 0 then
				monnum = #monposes
			end

			x = monposes[monnum][1]
			y = monposes[monnum][2]
		end
		
		--刷怪
		local mon = g_entityMgr:getFactory():createMonster(monId)
		if mon and scene then
			if scene:attachEntity(mon:getID(), x, y) then
				scene:addMonster(mon)
			end
		end
	end
	return true
end

--迷仙阵给奖励
local MazeRewardByValue = function(player, mazeEvent, value)
	local mazeEventCfg = g_mazeEventCfg[mazeEvent]
	if not mazeEventCfg or not mazeEventCfg.rewardID then
		print("MazeRewardByValue 1")
		return false
	end
	
	if #mazeEventCfg.rewardID == 0 then
		print("MazeRewardByValue 2")
		return false
	end
	
	local rewardIDSize = #mazeEventCfg.rewardID
	local levelRewards = nil
	if value and rewardIDSize > 1 then
		for i=1, rewardIDSize do
			if value >= mazeEventCfg.rewardID[i][1] and value <= mazeEventCfg.rewardID[i][2] then
				levelRewards = mazeEventCfg.rewardID[i][3]
				break
			end
		end

		if not levelRewards then
			levelRewards = mazeEventCfg.rewardID[rewardIDSize][3]
		end
	else
		levelRewards = mazeEventCfg.rewardID
	end
	
	if not levelRewards or type(levelRewards) ~= 'table' then
		print("MazeRewardByValue levelRewards is nil or not table")
		return false
	end

	--根据等级给不同的奖励
	local level = player:getLevel()
	local rewardID = 0
	for i=1, #levelRewards do
		if level >= levelRewards[i][1] and level <= levelRewards[i][2] then
			rewardID = levelRewards[i][3]
			break
		end
	end
	
	if rewardID == 0 then
		rewardID = levelRewards[#levelRewards][3]
	end

	print('MazeRewardByValue', mazeEvent, serialize(mazeEventCfg.rewardID), value, level, rewardID)

	local prizeret, rewardData = rewardByDropID(player:getSerialID(), rewardID, MazeEmailID, MazeSource)
	if not rewardData then return false end
	
	local ret = {}
	local rewards = unserialize(rewardData)
	ret.info = {}
	for _, info in pairs(rewards) do
		local prize = {}
		prize.rewardId = info.itemID
		prize.rewardCount = info.count
		prize.bind = info.bind
		prize.strength = info.strength
		table.insert(ret.info,prize)
	end
	fireProtoMessage(player:getID(), MAZENODE_SC_REWARD_NOTIFY, 'MazeNodeRewardNotify', ret)
	return true
end

local MazeRewardByIndex = function(player, mazeEvent, index)
	local mazeEventCfg = g_mazeEventCfg[mazeEvent]
	if not mazeEventCfg or not mazeEventCfg.rewardID then
		return false
	end
	
	if #mazeEventCfg.rewardID == 0 then
		return false
	end
	
	local rewardID = 0
	if index and index > 0 and index <= (#mazeEventCfg.rewardID) then
		rewardID = mazeEventCfg.rewardID[index]
	else
		rewardID = mazeEventCfg.rewardID[math.random(1, #mazeEventCfg.rewardID)]
	end
	print('MazeRewardByIndex', mazeEvent, serialize(mazeEventCfg.rewardID), index, rewardID)
	local prizeret, rewardData = rewardByDropID(player:getSerialID(), rewardID, MazeEmailID, MazeSource)
	if not rewardData then return false end
	
	local ret = {}
	local rewards = unserialize(rewardData)
	ret.info = {}
	for _, info in pairs(rewards) do
		local prize = {}
		prize.rewardId = info.itemID
		prize.rewardCount = info.count
		prize.bind = info.bind
		prize.strength = info.strength
		table.insert(ret.info,prize)
	end
	fireProtoMessage(player:getID(), MAZENODE_SC_REWARD_NOTIFY, 'MazeNodeRewardNotify', ret)
	return true
end

MazeEventBase = class(nil)

function MazeEventBase:__init()
end

function MazeEventBase:__release()
end

--进入事件
function MazeEventBase:onEnter(player, mazeNode)
	--[[local eventState = mazeNode:getEventState()
	if eventState ~= MazeEventState.Complete then
		mazeNode:setEventState(MazeEventState.Complete)
	end
	]]--
	return true
end

--开启事件
function MazeEventBase:onStart(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	if eventState == MazeEventState.Inactive then
		mazeNode:setEventState(MazeEventState.Active)
		ret = true
	end
	return ret
end

--领奖事件
function MazeEventBase:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	if eventState == MazeEventState.Active then
		--根据不同的事件领取不同的奖励
		mazeNode:setEventState(MazeEventState.Complete)
		ret = true
	end
	return ret
end

--退出事件
function MazeEventBase:onExit(player, mazeNode)
	return true
end

---------------------------------------------------------------------------------------未上锁的宝箱--------------------------------------------------------------------------------------------------------
MazeEventNoLockedBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.NoLockedBox] = MazeEventNoLockedBox

--进入事件
function MazeEventNoLockedBox:onEnter(player, mazeNode)
	return MazeEventBase:onStart(player, mazeNode)
end

--领奖事件
function MazeEventNoLockedBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventNoLockedBox:onPrize ', eventState)
	if eventState == MazeEventState.Active then
		--发奖
		if MazeRewardByValue(player, MazeEventType.NoLockedBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return ret
end

---------------------------------------------------------------------------------------上锁的宝箱--------------------------------------------------------------------------------------------------------
MazeEventLockedBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.LockedBox] = MazeEventLockedBox

--进入事件 开始答题
function MazeEventLockedBox:onEnter(player, mazeNode)
	return MazeEventBase:onStart(player, mazeNode)
end

--领奖事件
function MazeEventLockedBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventLockedBox:onPrize ', eventState)
	if eventState == MazeEventState.Active then
		--发奖
		if MazeRewardByValue(player, MazeEventType.LockedBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return ret
end

---------------------------------------------------------------------------------------被封印的宝箱--------------------------------------------------------------------------------------------------------
MazeEventSealedBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.SealedBox] = MazeEventSealedBox

--进入事件 开始刷怪
function MazeEventSealedBox:onEnter(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventSealedBox:onEnter ', eventState)
	if eventState == MazeEventState.Inactive then
		--刷怪
		if MazeflushMonster(player, MazeEventType.SealedBox, mazeNode:getScene(), 1) then
			print('MazeEventSealedBox:MazeflushMonster ')
			mazeNode:setEventState(MazeEventState.Active)
			ret = true
			fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -4 , 0, {})
		end
	end
	return ret
end

--领奖事件
function MazeEventSealedBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	local scene = mazeNode:getScene()
	print('MazeEventSealedBox:onPrize ', eventState)
	if eventState == MazeEventState.Active and scene and scene:getLiveMonsterCount() == 0 then
		--发奖
		if MazeRewardByValue(player, MazeEventType.SealedBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	elseif eventState == MazeEventState.Active then
		fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -7 , 0, {})
	end
	return ret
end

---------------------------------------------------------------------------------------被诅咒的宝箱--------------------------------------------------------------------------------------------------------
MazeEventCursedBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.CursedBox] = MazeEventCursedBox

--开启事件 开始刷怪
function MazeEventCursedBox:onStart(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventCursedBox:onStart ', eventState)
	if eventState == MazeEventState.Inactive then
		--刷怪
		if MazeflushMonster(player, MazeEventType.CursedBox, mazeNode:getScene(), 1) then
			print('MazeEventCursedBox:MazeflushMonster ')
			mazeNode:setKV("needMonsterKilled", "1")
			mazeNode:setKV("curCircle", "1")
			mazeNode:setEventState(MazeEventState.Active)
			ret = true
			--注册回调
			local time = getMazeEventTotaltime(MazeEventType.CursedBox)
			if time and time > 0 then
				local ret = {}
				ret.param =  time
				fireProtoMessage(player:getID(), MAZENODE_SC_COUTDOWN_NOTIFY, 'MazeNodeCountDownNotify', ret)
				g_mazeMgr:mazeOnTimeCallback(player, time*1000)
			end
			fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -4 , 0, {})
		end
	end
	return ret
end

--杀怪事件 记录杀怪的数量
function MazeEventCursedBox:onMonsterKilled(player, monster, mazeNode)
	local eventState = mazeNode:getEventState()
	if eventState ~= MazeEventState.Active then
		return false
	end

	local scene = mazeNode:getScene()
	local killCount = 1
	local strkillCount = mazeNode:getKV("killCount")
	if strkillCount ~= "" then
		killCount = tonumber(strkillCount) + 1
	end

	mazeNode:setKV("killCount", tostring(killCount))
	
	local curCircle = 1
	local strcurCircle = mazeNode:getKV("curCircle")
	if strcurCircle ~= "" then
		curCircle = tonumber(strcurCircle)
	end

	local ret = {}
	ret.param =  killCount
	fireProtoMessage(player:getID(), MAZENODE_SC_KILLCOUNT_NOTIFY, 'MazeNodeKillCountNotify', ret)

	if scene:getLiveMonsterCount() == 0 then
		local maxCircle = getMazeEventMaxCircle(MazeEventType.CursedBox)
		if maxCircle and maxCircle > 1 and curCircle < maxCircle and MazeflushMonster(player, MazeEventType.CursedBox, scene, curCircle + 1) then
			mazeNode:setKV("curCircle", tostring(curCircle + 1))
		else
			--根据杀怪的数量 发奖
			if MazeRewardByValue(player, MazeEventType.CursedBox, killCount) then
				mazeNode:setKV("needMonsterKilled", "0")
				mazeNode:setEventState(MazeEventState.Complete)
				g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
			end
		end
	end

	return true
end

--定时回调事件
function MazeEventCursedBox:onTimeCallback(player, mazeNode)
	--清怪
	local scene = mazeNode:getScene()
	if scene then
		scene:releaseAllMonsters()
	end

	--发奖
	local eventState = mazeNode:getEventState()
	print('MazeEventCursedBox:onTimeCallback ', eventState)
	if eventState == MazeEventState.Active then
		--根据杀怪的数量 发奖
		local killCount = 0
		local strkillCount = mazeNode:getKV("killCount")
		if strkillCount ~= "" then
			killCount = tonumber(strkillCount)
		end
		
		print('MazeEventCursedBox:onTimeCallback1 ', eventState, mazeNode:getKV("curCircle"), killCount)
		if MazeRewardByValue(player, MazeEventType.CursedBox, killCount) then
			mazeNode:setKV("needMonsterKilled", "0")
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return ret
end

---------------------------------------------------------------------------------------调皮的小鬼--------------------------------------------------------------------------------------------------------
MazeEventNaughtyBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.NaughtyBox] = MazeEventNaughtyBox

--进入事件 开始抽奖
function MazeEventNaughtyBox:onEnter(player, mazeNode)
	return MazeEventBase:onStart(player, mazeNode)
end

--[[
--开启事件 打开九宫格
function MazeEventNaughtyBox:onStart(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventNaughtyBox:onStart ', eventState)
	if eventState == MazeEventState.Inactive then
		--通知客户端 打开九宫格 把奖励发给客户端
		local prizeIndex = math.random(1, 9)
		mazeNode:setKV("prizeIndex", tostring(prizeIndex))
		local ret = {}
		ret.param =  prizeIndex
		print('MazeEventNaughtyBox:onStart open the box', prizeIndex)
		fireProtoMessage(player:getID(), MAZENODE_SC_REWARDINDEX_NOTIFY, 'MazeNodeRewardIndexNotify', ret)
		mazeNode:setEventState(MazeEventState.Active)
		ret = true
	end
	return ret
end
]]--

--领奖事件
function MazeEventNaughtyBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventNaughtyBox:onPrize ', eventState)
	if eventState == MazeEventState.Active then
		--发奖
		if MazeRewardByValue(player, MazeEventType.NaughtyBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
		ret = true
	end
	return ret
end

---------------------------------------------------------------------------------------无聊的树妖--------------------------------------------------------------------------------------------------------
MazeEventBoredBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.BoredBox] = MazeEventBoredBox

--开启事件 开始刷怪
function MazeEventBoredBox:onStart(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventBoredBox:onStart ', eventState)
	if eventState == MazeEventState.Inactive then
		--刷怪
		if MazeflushMonster(player, MazeEventType.BoredBox, mazeNode:getScene(), 1) then
			print('MazeEventBoredBox:MazeflushMonster ')
			mazeNode:setKV("needMonsterHurted", "1")
			mazeNode:setEventState(MazeEventState.Active)
			ret = true
			--注册回调
			local time = getMazeEventTotaltime(MazeEventType.CursedBox)
			if time and time > 0 then
				local ret = {}
				ret.param =  time
				fireProtoMessage(player:getID(), MAZENODE_SC_COUTDOWN_NOTIFY, 'MazeNodeCountDownNotify', ret)
				g_mazeMgr:mazeOnTimeCallback(player, time*1000)
			end
			fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -4 , 0, {})
		end
	end
	return ret
end

--伤害事件 记录造成的伤害数值
function MazeEventBoredBox:onMonsterHurted(player, monster, value, mazeNode)
	local eventState = mazeNode:getEventState()
	if eventState ~= MazeEventState.Active then
		return false
	end

	local hurtValue = value
	local strhurtValue = mazeNode:getKV("hurtValue")
	if strhurtValue ~= "" then
		hurtValue = tonumber(strhurtValue) + value
	end

	mazeNode:setKV("hurtValue", tostring(hurtValue))
	local ret = {}
	ret.param =  hurtValue
	fireProtoMessage(player:getID(), MAZENODE_SC_HURTCOUNT_NOTIFY, 'MazeNodeHurtCountNotify', ret)
	return true
end

--定时回调事件
function MazeEventBoredBox:onTimeCallback(player, mazeNode)
	--清怪
	local scene = mazeNode:getScene()
	if scene then
		scene:releaseAllMonsters()
	end
	
	--发奖
	local eventState = mazeNode:getEventState()
	--造成的伤害数值 发奖
	print('MazeEventBoredBox:onTimeCallback ', eventState)
	if eventState == MazeEventState.Active then
		--造成的伤害数值 发奖
		local hurtValue = 0
		local strhurtValue = mazeNode:getKV("hurtValue")
		if strhurtValue ~= "" then
			hurtValue = tonumber(strhurtValue)
		end

		print('MazeEventBoredBox:onTimeCallback1 ', eventState, hurtValue)
		if MazeRewardByValue(player, MazeEventType.BoredBox, hurtValue) then
			mazeNode:setKV("needMonsterHurted", "0")
			mazeNode:setEventState(MazeEventState.Complete)
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return true
end

---------------------------------------------------------------------------------------迷失的信使--------------------------------------------------------------------------------------------------------
MazeEventLosedBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.LosedBox] = MazeEventLosedBox

--开启事件 开始刷BOSS
function MazeEventLosedBox:onStart(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventLosedBox:onStart ', eventState)
	if eventState == MazeEventState.Inactive then
		--刷怪
		if MazeflushMonster(player, MazeEventType.LosedBox, mazeNode:getScene(), 1) then
			print('MazeEventLosedBox:MazeflushMonster ')
			mazeNode:setKV("needMonsterKilled", "1")
			mazeNode:setEventState(MazeEventState.Active)
			ret = true
			fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -4 , 0, {})
		end
	end
	return ret
end

--杀怪事件
function MazeEventLosedBox:onMonsterKilled(player, monster, mazeNode)
	local eventState = mazeNode:getEventState()
	if eventState == MazeEventState.Active then
		mazeNode:setKV("needMonsterKilled", "1")
		mazeNode:setEventState(MazeEventState.Complete)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
	end
	return true
end

---------------------------------------------------------------------------------------小首领的宝箱--------------------------------------------------------------------------------------------------------
MazeEventLittleBossBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.LittleBossBox] = MazeEventLittleBossBox

--进入事件
function MazeEventLittleBossBox:onEnter(player, mazeNode)
	return MazeEventBase:onStart(player, mazeNode)
end

--领奖事件
function MazeEventLittleBossBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventLittleBossBox:onPrize ', eventState)
	if eventState == MazeEventState.Active then
		--发小奖
		if MazeRewardByValue(player, MazeEventType.LittleBossBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return ret
end

---------------------------------------------------------------------------------------首领的宝箱--------------------------------------------------------------------------------------------------------
MazeEventBossBox = class(MazeEventBase)
--注册
g_mazeEventMgr[MazeEventType.BossBox] = MazeEventBossBox

--进入事件
function MazeEventBossBox:onEnter(player, mazeNode)
	return MazeEventBase:onStart(player, mazeNode)
end

--领奖事件
function MazeEventBossBox:onPrize(player, mazeNode)
	local ret = false
	local eventState = mazeNode:getEventState()
	print('MazeEventBossBox:onPrize ', eventState)
	if eventState == MazeEventState.Active then
		--发大奖
		if MazeRewardByValue(player, MazeEventType.BossBox) then
			mazeNode:setEventState(MazeEventState.Complete)
			ret = true
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.MIXIANZHEN, 1)
		end
	end
	return ret
end