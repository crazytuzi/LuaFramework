--ConvoyManager.lua
--/*-----------------------------------------------------------------
--* Module:  ConvoyManager.lua
--* Author:  YangXi
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class ConvoyManager
--* 通用护送
-------------------------------------------------------------------*/


CONVOY_CHECK_ROUND = 7

-- 护送状态
ConvoyState = 
{
	null = 1,				-- 无效
	start = 2,				-- 开始
	finish = 3,				-- 完成
	fail = 4,				-- 失败
}

-- 护送移动状态
ConvoyMoveState = 
{
	move = 1,		-- 移动
	stop = 2,		-- 停止
}

CONVOY_FAIL_TIME = 30 * 60

CONVOY_TARGET_MOVE_SPEED = 100

CONVOY_TARGET_STOP_FAIL_TIME = 300			-- 护送目标停止失败时间

PlayerConvoy = class()

function PlayerConvoy:__init(roleSID, configID, campID)
	self._roleSID = roleSID
	self._startTime = os.time()
	self._targetID = 0
	self._targetStep = 0
	self._state = ConvoyState.null				-- 护送状态
	self._moveState = ConvoyMoveState.stop		-- 护送目标移动状态
	self._configID = configID 					-- 护送配置id
	self._campID = campID						-- 阵营
	self._moveStamp = 0							-- 移动时间戳
end

-- 开始护送
function PlayerConvoy:start()
	local config = g_ConvoyMgr:getConfig(self._configID)
	if not config then
		return
	end

	local commonInfo = g_commonMgr._infosBySID[self._roleSID]
	if not commonInfo then
		return
	end

	if not commonInfo:getLoadDB() then
		return
	end

	if commonInfo:getConvoy() == 1 then
		return
	end

	target = g_entityFct:createMonster(config.q_monsterID)
	if not target then
		return
	end

	local player = g_entityMgr:getPlayerBySID(self._roleSID)
	if not player then
		return
	end

	target:setCampID(self._campID)
	target:setNameColor(NAME_COLOR_TYPE_BLUE)

	self._state = ConvoyState.start
	self._targetID = target:getID()
	g_sceneMgr:enterPublicScene(self._targetID, config.q_mapID, config.q_path[1].x, config.q_path[1].y, player:getCurrentLine())
	local scene = target:getScene()
	if scene then
		scene:addMonster(target)
	end
	self._targetStep = 1
	self:move(CONVOY_TARGET_MOVE_SPEED)

	commonInfo:setConvoy(1)

	player:setCampID(self._campID)

	local name = target:getName()
	target:setName(string.format("%s(%s)", name, player:getName()))

	local pos = target:getPosition()

	local retData = {
					x = pos.x,
					y = pos.y,
					targetID = self._targetID,
				}

	fireProtoMessage(player:getID(),CONVOY_SC_POSITION_RET,"ConvoyPositionRetProtocol",retData)

end

function PlayerConvoy:playerLoad()
	-- if self._moveState ~= ConvoyMoveState.move then
	-- 	return
	-- end

	-- local player = g_entityMgr:getPlayerBySID(self._roleSID)
	-- if not player then
	-- 	return
	-- end

	-- player:setCampID(self._campID)

	self._state = ConvoyState.fail
end

-- 护送目标移动
function PlayerConvoy:move(moveSpeed)
	local config = g_ConvoyMgr:getConfig(self._configID)
	if not config then
		return
	end

	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		self._moveState = ConvoyMoveState.move
		self._moveStamp = os.time()

		local pos = target:getPosition()
		local posStep = config.q_path[self._targetStep]
		if pos.x == posStep.x and pos.y == posStep.y then
			self._targetStep = self._targetStep + 1
		end

		posStep = config.q_path[self._targetStep]
		if not posStep then
			return
		end

		local dir, len = GetMoveDirAndLen(pos, posStep)
		if dir == nil then
			return
		end

		target:setMoveSpeed(moveSpeed)
		target:moveDir(dir, 0, len)
	end
end

-- 护送目标移动完成
function PlayerConvoy:stopMove()
	local config = g_ConvoyMgr:getConfig(self._configID)
	if not config then
		return
	end

	local target = g_entityMgr:getMonster(self._targetID)
	if target then
		self._moveState = ConvoyMoveState.stop

		local pos = target:getPosition()
		local posStep = config.q_path[#(config.q_path)]

		if pos.x == posStep.x and pos.y == posStep.y then
			self._state = ConvoyState.finish
		else
			self:checkMove()
		end
	end
end

-- 检查移动
function PlayerConvoy:checkMove()
	local config = g_ConvoyMgr:getConfig(self._configID)
	if not config then
		return
	end

	if self._moveState == ConvoyMoveState.stop then
		local target = g_entityMgr:getMonster(self._targetID)
		local player = g_entityMgr:getPlayerBySID(self._roleSID)

		if target and player then
			local pos = target:getPosition()
			local scene = target:getScene()

			if scene and pos then
				local curScenePlayer = scene:getEntities(0, pos.x, pos.y, CONVOY_CHECK_ROUND, eClsTypePlayer, 0) or {}
				for i = 1, #curScenePlayer do
					local roleID = curScenePlayer[i]
					local playerTmp = g_entityMgr:getPlayer(roleID)
					if playerTmp and playerTmp:getSerialID() == self._roleSID then
						self:move(CONVOY_TARGET_MOVE_SPEED)
					end
				end
			end
		end
	end
end

-- 护送更新
function PlayerConvoy:update()
	local now = os.time()

	if self._state == ConvoyState.start then
		if now - self._moveStamp > CONVOY_TARGET_STOP_FAIL_TIME then
			self._state = ConvoyState.fail
		elseif now - self._startTime > CONVOY_FAIL_TIME then
			self._state = ConvoyState.fail
		else
			self:checkMove()
		end
	end
end

function PlayerConvoy:finish()
	if self:getState() == ConvoyState.finish or self:getState() == ConvoyState.fail then
		if self._targetID ~= 0 then
			local target = g_entityMgr:getMonster(self:getTargetID())
			if target then
				g_entityMgr:destoryEntity(self:getTargetID())
				self._targetID = 0
			end
		end

		local player = g_entityMgr:getPlayerBySID(self._roleSID)
		if player then
			local commonInfo = g_commonMgr._infosBySID[self._roleSID]
			if commonInfo and commonInfo:getLoadDB() then
				commonInfo:setConvoy(0)
			end

			if self:getState() == ConvoyState.finish then
				g_taskMgr:NotifyListener(player, "onEscortSucc")
			end

			if self:getState() == ConvoyState.fail then
				g_taskMgr:NotifyListener(player, "onEscortFail")
			end

			player:setCampID(0)
		end
	end
end

-- 护送目标被杀
function PlayerConvoy:onKill()
	self._state = ConvoyState.fail
	self._targetID = 0
end

-- 切换场景
function PlayerConvoy:onSwitch()
	self._state = ConvoyState.fail
end

-- 获得护送状态
function PlayerConvoy:getState()
	return self._state
end

-- 获得护送目标id
function PlayerConvoy:getTargetID()
	return self._targetID
end

ConvoyManager = class(nil, Singleton,Timer)

function ConvoyManager:__init()
	self._playerConvoys = {}				-- 玩家护送数据
	self._targetIDRoleSIDMap = {}			-- 护送目标和玩家sid的映射
	self._campID = 0
	self._convoyConfig = {}

	local datas = require "data.ConvoyDB"
	for _, data in pairs(datas) do
		_, data.q_path = pcall(loadstring("return" .. (data.q_path or "{}")))
		self._convoyConfig[data.q_id] = data
	end

	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
end

function ConvoyManager:getConfig(id)
	return self._convoyConfig[id]
end

-- 开始护送
function ConvoyManager:startConvoy(roleSID, id)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	if self._playerConvoys[roleSID] then
		return
	end

	self._campID = self._campID + 1
	if self._campID > 10000000 then
		self._campID = 1
	end

	local playerConvoy = PlayerConvoy(roleSID, id, self._campID)
	
	playerConvoy:start()
	if playerConvoy:getState() ~= ConvoyState.start then
		return
	end

	self._playerConvoys[roleSID] = playerConvoy
	self._targetIDRoleSIDMap[playerConvoy:getTargetID()] = roleSID
	
	return true
end

-- 定时器更新
function ConvoyManager:update()
	local deletelist = {}

	for roleSID, playerConvoy in pairs(self._playerConvoys) do
		playerConvoy:update()

		if playerConvoy:getState() == ConvoyState.finish or playerConvoy:getState() == ConvoyState.fail then
			table.insert(deletelist, roleSID)
		end
	end

	for i = 1, #deletelist do
		local playerConvoy = self._playerConvoys[deletelist[i]]
		if playerConvoy then
			local targetID = playerConvoy:getTargetID()
			self._targetIDRoleSIDMap[targetID] = nil
			playerConvoy:finish()
		end
		
		self._playerConvoys[deletelist[i]] = nil
	end
end

-- 怪物停止移动
function ConvoyManager:onMonsterStop(monID)
	local roleSID = self._targetIDRoleSIDMap[monID]
	if not roleSID then
		return
	end

	local playerConvoy = self._playerConvoys[roleSID]
	if not playerConvoy then
		return
	end

	playerConvoy:stopMove()
end

-- 怪物被杀
function ConvoyManager:onMonsterKill(monSID, roleID, monID, mapID)
	local roleSID = self._targetIDRoleSIDMap[monID]
	if not roleSID then
		return
	end

	local playerConvoy = self._playerConvoys[roleSID]
	if not playerConvoy then
		return
	end

	playerConvoy:onKill()
	self._targetIDRoleSIDMap[monID] = nil
end

-- 玩家登陆
function ConvoyManager:onPlayerLoaded(player)
	if player then
		local playerConvoy = self._playerConvoys[player:getSerialID()]
		if not playerConvoy then
			local commonInfo = g_commonMgr._infosBySID[player:getSerialID()]
			if commonInfo then
				if commonInfo:getConvoy() == 1 then
					commonInfo:setConvoy(0)
					g_taskMgr:NotifyListener(player, "onEscortFail")
				end
			end
		else
			playerConvoy:playerLoad()
		end
	end
end

-- 玩家护送
function ConvoyManager:getPlayerConvoy(roleSID)
	return self._playerConvoys[roleSID]
end

-- 玩家切换场景
function ConvoyManager:onSwitchScene(player, mapID)
	if player then
		local playerConvoy = self._playerConvoys[player:getSerialID()]
		if playerConvoy then
			playerConvoy:onSwitch()
		end
	end
end

g_ConvoyMgr = ConvoyManager()

