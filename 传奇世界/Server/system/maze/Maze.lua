require ("system.maze.MazeConstant")
require ("system.maze.MazeEvent")
require ("system.dialog.DialogFactory")

local factory = DialogFactory.getInstance()
--迷仙阵 逻辑
function GetMazeEvent(mazeNode)
	local eventType = mazeNode:getEventType()
	local mazeEvent = g_mazeEventMgr[eventType]
	--print('GetMazeEvent',eventType)
	if not mazeEvent then
		--print('GetMazeEvent not find the event',eventType)
		mazeEvent = MazeEventBase
	end
	return mazeEvent
end

--扣物品
function MazeItemCheck(player, EnterOrReset)
	local itemMgr = player:getItemMgr()
	if itemMgr and MazeKeyItemID > 0 then
		local bagCnt = itemMgr:getItemCount(MazeKeyItemID, Item_BagIndex_Bag)
		if bagCnt >= MazeKeyItemCount then
			local errId = 0
			local deleteRet = itemMgr:destoryItem(MazeKeyItemID, MazeKeyItemCount, errId)
			if not deleteRet then return false end
			g_logManager:writePropChange(player:getSerialID(), 2 ,MazeSource, MazeKeyItemID, 0, MazeKeyItemCount, 0)
			if EnterOrReset == true then
				g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.MIXIANZHEN)
			end
			return true
		else
			if EnterOrReset == true then
				fireProtoSysMessage(0, player:getID(), EVENT_MAZE_SETS, -5 , 0, {})
			end
			return false
		end
	end
	return false
end

--进入迷仙阵房间
--触发事件 进地图 扣物品
function EnterMazeNode(player, mazeNode, needItem)
	local player = tolua.cast(player, "Player")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")
	local ret = true

	--扣道具
	print('EnterMazeNode', 1)
	if needItem == true then
		ret = MazeItemCheck(player, true)
	end

	--扣道具成功 进地图
	if ret == true then
		--进地图
		local eventType = mazeNode:getEventType()
		local eventInfo = g_mazeEventCfg[eventType]
		local scene = mazeNode:getScene()
		print('EnterMazeNode', 2)
		if eventInfo and scene then
			print('EnterMazeNode', 3)
			local petID = player:getPetID()
			if petID > 0 then
				ret = scene:attachEntity(petID, eventInfo.enterPos[1], eventInfo.enterPos[2])
			end
			ret = scene:attachEntity(player:getID(), eventInfo.enterPos[1], eventInfo.enterPos[2])
		else
			ret = false
		end
	end
	
	print('EnterMazeNode', ret)

	--进地图成功
	if ret == true then
		--触发进入事件
		local mazeEvent = GetMazeEvent(mazeNode)
		if mazeEvent.onEnter then
			mazeEvent:onEnter(player, mazeNode)
		end
	end
	return ret
end

--进入迷仙阵
--检查进入条件 设置退出地图
function EnterMaze(player, maze)
	local player = tolua.cast(player, "Player")
	local ret = true
	
	--判断是否在NPC周围
	if not factory:canTalk(player, MazeEnterNPC) then
		return false
	end

	--副本中不让进
	if player:getCopyID() > 0 then
		return false
	end

	--设置退出地图
	local preMapID = player:getMapID()
	local publicPos = player:getPosition()
	player:setLastMapID(preMapID)
	player:setLastPosX(publicPos.x)
	player:setLastPosY(publicPos.y)

	return ret
end

--重置迷仙阵
--检查重置条件
function ResetMaze(player, maze)
	local player = tolua.cast(player, "Player")

	--判断是否在NPC周围
	if not factory:canTalk(player, MazeEnterNPC) then
		return false
	end

	return MazeItemCheck(player)
end

--退出迷仙阵
--退出到指定地图
function ExitMaze(player, maze)
	local player = tolua.cast(player, "Player")
	local ret = true

	local roleID = player:getID()
	local mapID = player:getLastMapID()
	local x = player:getLastPosX()
	local y = player:getLastPosY()
	if g_sceneMgr:posValidate(mapID, x, y) then
		ret = g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
	else
		--如果地图有问题就走出生点
		ret = g_sceneMgr:enterPublicScene(roleID, 1100, 21, 100)
	end
	return ret
end

--设置迷仙阵脚本配置
function InitMaze(mazeMgr)
	local ret = true
	
	g_mazeMgr = tolua.cast(mazeMgr, "MazeMgr")

	--设置事件
	g_mazeMgr:setEventCount(table.size(MazeEventType))
	g_mazeMgr:setPrizeCount(2)
	g_mazeMgr:setNeedLv(MazeNeedLv)

	LoadMazeEventCfg()
	--设置地图
	for eventType, eventInfo in pairs(g_mazeEventCfg) do
		print("InitMaze", eventType, eventInfo.mapID, eventInfo.prob)
		g_mazeMgr:addMap(eventType, eventInfo.mapID, eventInfo.prob)
	end

	return ret
end

--房间游戏相关
--房间游戏开启
function MazeNodeGameStart(player, mazeNode)
	local player = tolua.cast(player, "Player")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")
	
	local ret = true

	--触发开启事件
	local mazeEvent = GetMazeEvent(mazeNode)
	if mazeEvent.onStart then
		ret = mazeEvent:onStart(player, mazeNode)
	end
	return ret
end

--房间游戏领奖
function MazeNodeGamePrize(player, mazeNode)
	local player = tolua.cast(player, "Player")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")
	
	local ret = true

	--触发领奖事件
	local mazeEvent = GetMazeEvent(mazeNode)
	if mazeEvent.onPrize then
		ret = mazeEvent:onPrize(player, mazeNode)
	end
	return ret
end

--房间杀怪事件
function MazeNodeMonsterKilled(player, monster, mazeNode)
	local player = tolua.cast(player, "Player")
	local monster = tolua.cast(monster, "Monster")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")

	local ret = true

	--触发杀怪事件
	local mazeEvent = GetMazeEvent(mazeNode)
	if mazeEvent.onMonsterKilled then
		ret = mazeEvent:onMonsterKilled(player, monster, mazeNode)
	end
	return ret
end

--房间伤害事件
function MazeNodeMonsterHurted(player, monster, value, mazeNode)
	local player = tolua.cast(player, "Player")
	local monster = tolua.cast(monster, "Monster")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")

	local ret = true

	--触发怪物伤害事件
	local mazeEvent = GetMazeEvent(mazeNode)
	if mazeEvent.onMonsterHurted then
		ret = mazeEvent:onMonsterHurted(player, monster, value, mazeNode)
	end
	return ret
end

--房间定时回调事件
function MazeNodeOnTimeCallback(player, mazeNode)
	local player = tolua.cast(player, "Player")
	local mazeNode = tolua.cast(mazeNode, "MazeNode")

	local ret = true

	--触发定时回调事件
	local mazeEvent = GetMazeEvent(mazeNode)
	if mazeEvent.onTimeCallback then
		ret = mazeEvent:onTimeCallback(player, mazeNode)
	end
	return ret
end