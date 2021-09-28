--VirtualEscort.lua
--/*-----------------------------------------------------------------
--* Module:  VirtualEscort.lua
--* Author:  YangXi
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class VirtualEscort
--* 虚拟运镖
-------------------------------------------------------------------*/


VirtualEscortConfig = 
{
	guardCount = 3,
	mapID = 5003,
	APos = {49, 180},
	aPos = {53, 200},
	BPos = {88, 192},
	bPos = {78, 176},
	-- step = {{29,160}, {33,164}, {37,168}, {41,172}, {45,176}, {49,180}, {53, 184}, {57, 188}, {61, 192}, {69, 192}, {72, 192}, {80, 192}, {88, 192}, {98, 192}},
	step = {{53, 184}, {57, 188}, {61, 192}, {67, 192}, {72, 192}, {76, 192}, {80, 192}, {84, 192}, {88, 192}, {98, 192}},

	duringTime = 300,
}


VirtualEscortManager = class(nil, Singleton,Timer)

function VirtualEscortManager:__init()
	self._playerData = {}	-- 玩家数据
	self._config = {}		-- 配置
	self._monster = {}		-- 怪物记录

	local datas = require "data.VirtualEscort"
	for _, data in pairs(datas) do
		local config = {}
		config.q_id = data.q_id
		config.q_baiguID = data.q_baiguID
		config.q_guardID = data.q_guardID
		config.q_escortID = data.q_escortID
		config.q_aMonster = unserialize(data.q_aMonster)
		config.q_AMonster = unserialize(data.q_AMonster)
		config.q_bMonster = unserialize(data.q_bMonster)
		config.q_BMonster = unserialize(data.q_BMonster)

		config.q_ai1Monster = {}
		local tmp = unserialize(data.q_ai1Monster)
		for _, monsterID in pairs(tmp) do
			config.q_ai1Monster[monsterID] = true
		end

		config.q_ai2Monster = {}
		tmp = unserialize(data.q_ai2Monster)
		for _, monsterID in pairs(tmp) do
			config.q_ai2Monster[monsterID] = true
		end
		
		self._config[config.q_id] = config
	end
	
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
end

-- 玩家下线
function VirtualEscortManager:onPlayerOffLine(player)
	if not player then
		return
	end

	local roleSID = player:getSerialID()
	self:close(roleSID)
end

-- 进入运镖场景
function VirtualEscortManager:enter(roleSID, copyID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	if self._playerData[roleSID] then
		return
	end

	if not self._config[copyID] then
		return
	end

	local now = os.time()

	local config = self._config[copyID]

	local copyInsID = g_copyMgr:requestNewId()
	local scene = g_sceneMgr:createCopyScene(copyInsID, VirtualEscortConfig.mapID)
	if not scene then
		return
	end

	player:setCopyID(copyInsID)
	local preMapID = player:getMapID()
	local publicPos = player:getPosition()

	self._playerData[roleSID] = {roleSID = roleSID, copyInsID = copyInsID, scene = scene, copyID = copyID}
	local playerData = self._playerData[roleSID]

	if not g_sceneMgr:enterCopyBookScene(copyInsID, player:getID(), VirtualEscortConfig.mapID, VirtualEscortConfig.APos[1] - 5, VirtualEscortConfig.APos[2]) then
		g_sceneMgr:releaseScene(scene, copyInsID)
		self._playerData[roleSID] = nil
		player:setCopyID(0)
		return
	end

	player:setLastMapID(preMapID)
	player:setLastPosX(publicPos.x)
	player:setLastPosY(publicPos.y)

	player:setPattern(1)

	player:setCampID(1)

	local petID = player:getPetID()
	local pet = g_entityMgr:getMonster(petID)
	if pet then
		pet:setCampID(1)
	end

	local escrot = g_entityFct:createMonster(config.q_escortID)
	if not escrot then
		return
	end

	local maxHp = escrot:getMaxHP() * 4
	escrot:setMaxHP(maxHp)
	escrot:setHP(maxHp)

	playerData.escortID = escrot:getID()
	escrot:setCampID(1)
	--escrot:setHost(player:getID())

	if not scene:attachEntity(escrot:getID(), VirtualEscortConfig.APos[1], VirtualEscortConfig.APos[2]) then
		return
	end
	scene:addMonster(escrot)
	self._monster[escrot:getID()] = roleSID

	local monsters = {}

	local baigu = g_entityFct:createMonster(config.q_baiguID)
	if not baigu then
		return
	end
	playerData.baiguID = baigu:getID()
	baigu:setCampID(1)
	
	playerData.guards = {}
	table.insert(monsters, baigu)
	playerData.guards[baigu:getID()] = true

	playerData.guardID = {}
	for i = 1, VirtualEscortConfig.guardCount do
		local guard = g_entityFct:createMonster(config.q_guardID)
		if not guard then
			return
		end
		table.insert(playerData.guardID, guard:getID())
		table.insert(monsters, guard)
		playerData.guards[guard:getID()] = true

		guard:setCampID(1)
		--guard:setHost(player:getID())
	end

	playerData.monsterTalk = {}

	playerData.AMonsterID = {}
	playerData.monsters = {}
	for _, monsterID in ipairs(config.q_AMonster) do
		local monster = g_entityFct:createMonster(monsterID)
		if not monster then
			return
		end
		table.insert(monsters, monster)
		playerData.monsters[monster:getID()] = true
		playerData.AMonsterID[monster:getID()] = true

		monster:setCampID(2)

		playerData.monsterTalk[monster:getID()] = now + 2 + math.random(1, 3)
	end

	playerData.monsterTalk[playerData.baiguID] = now + 2 + math.random(1, 3)

	playerData.BMonsterID = {}

	for _, monster in pairs(monsters) do
		if not scene:attachEntity(monster:getID(), math.random(VirtualEscortConfig.APos[1] + 2, VirtualEscortConfig.APos[1] + 8), math.random(VirtualEscortConfig.APos[2], VirtualEscortConfig.APos[2] + 6)) then
			return
		end

		self:learnSkill(monster)

		scene:addMonster(monster)
		self._monster[monster:getID()] = roleSID
	end

	playerData.ATime = now			-- A点刷怪时间

	playerData.attackTarget = {}
	playerData.aMonsterFlag = false
	playerData.bMonsterFlag = false
	playerData.BMonsterFlag = false

	playerData.step = 0			-- 移动步骤点
	playerData.moveEntity = {}		-- 移动的实体
	table.insert(playerData.moveEntity, playerData.escortID)
	for _, guardID in ipairs(playerData.guardID) do
		table.insert(playerData.moveEntity, guardID)
	end
	table.insert(playerData.moveEntity, playerData.baiguID)

	--baigu:setHost(player:getID())

	playerData.startTime = now

	playerData.isEnd = false
end

function VirtualEscortManager:update()
	for _, playerData in pairs(self._playerData) do
		self:updateCopy(playerData)
	end
end

function VirtualEscortManager:updateCopy(playerData)
	local now = os.time()

	if playerData.isEnd then
		if now - playerData.startTime > VirtualEscortConfig.duringTime + 60 then
			self:close(playerData.roleSID)
		end
		return
	end

	
	if not playerData.scene then
		return
	end

	local config = self._config[playerData.copyID]
	if not config then
		return
	end

	if now - playerData.startTime > VirtualEscortConfig.duringTime then
		self:copyEnd(playerData, false)
		return
	end

	for monsterID, talkTime in pairs(playerData.monsterTalk) do
		if now >= talkTime then
			local monster = g_entityMgr:getMonster(monsterID)
			if monster then
				if monsterID == playerData.baiguID then
					local word = g_digMineSimulation:getSpeakWord(5)
					if #word > 0 then
						monster:MonsterSpeak(word)
					end
				else
					local word = g_digMineSimulation:getSpeakWord(6)
					if #word > 0 then
						monster:MonsterSpeak(word)
					end
				end
			end

			playerData.monsterTalk[monsterID] = nil
		end
	end

	if not playerData.aMonsterFlag and (os.time() - playerData.ATime > 15 or table.size(playerData.AMonsterID) == 0) then
		self:burnMonster(playerData, VirtualEscortConfig.aPos, config.q_aMonster, nil, 2, 12)
		playerData.aMonsterFlag = true
	end

	if not playerData.bMonsterFlag and playerData.BTime and (os.time() - playerData.BTime > 15 or table.size(playerData.BMonsterID) == 0) then
		self:burnMonster(playerData, VirtualEscortConfig.bPos, config.q_bMonster, nil, 6, 8)
		playerData.bMonsterFlag = true
	end

	local monsters = {}
	for monsterID, _ in pairs(playerData.monsters) do
		table.insert(monsters, monsterID)
	end

	local guards = {}
	for guardID, _ in pairs(playerData.guards) do
		table.insert(guards, guardID)
	end 
	table.insert(guards, playerData.escortID)

	if #monsters > 0 then
		for guardID, _ in pairs(playerData.guards) do
			local gurad = g_entityMgr:getMonster(guardID)
			if gurad then
				if gurad:getTargetID() == 0 then
					local targeID = monsters[math.random(1, #monsters)]
					playerData.attackTarget[guardID] = targeID
					gurad:foreceAttack(targeID)
				end
			end
		end

		for monsterID, _ in pairs(playerData.monsters) do
			local monster = g_entityMgr:getMonster(monsterID)
			if monster then
				if monster:getTargetID() == 0 and not monster:isMove() then
					if config.q_ai1Monster[monster:getModelID()] then
						playerData.attackTarget[monsterID] = playerData.escortID
						monster:foreceAttack(playerData.escortID)
					elseif config.q_ai2Monster[monster:getModelID()] then
						local targetId = guards[math.random(1, #guards)]
						playerData.attackTarget[monsterID] = targetId
						monster:foreceAttack(targetId)
					end
				end
			end
		end
	else
		self:checkMove(playerData.roleSID)
	end
end

-- 刷怪
function VirtualEscortManager:burnMonster(playerData, pos, monsterIDs, monsterList, dir, len)
	if playerData.isEnd then
		return
	end

	if not playerData.scene then
		return
	end

	local config = self._config[playerData.copyID]
	if not config then
		return
	end

	local now = os.time()

	for _, monsterID in ipairs(monsterIDs) do
		local monster = g_entityFct:createMonster(monsterID)
		if not monster then
			return
		end

		self:learnSkill(monster)
		
		monster:setCampID(2)

		playerData.monsters[monster:getID()] = true
		if monsterList then
			monsterList[monster:getID()] = true
		end

		if not playerData.scene:attachEntity(monster:getID(), math.random(pos[1] - 3, pos[1] + 3), math.random(pos[2] - 3, pos[2] + 3)) then
			return
		end
		playerData.scene:addMonster(monster)

		self._monster[monster:getID()] = playerData.roleSID

		if dir then
			monster:moveDir(dir, 0, len)
		end

		playerData.monsterTalk[monster:getID()] = now + 2 + math.random(1, 3)
	end

	local baigu = g_entityMgr:getMonster(playerData.baiguID)
	if baigu then
		playerData.monsterTalk[baigu:getID()] = now + 2 + math.random(1, 3)
	end

	--[[
	local guards = {}
	for guardID, _ in pairs(playerData.guards) do
		table.insert(guards, guardID)
	end 
	table.insert(guards, playerData.escortID)

	
	for monsterID, _ in pairs(playerData.monsters) do
		local monster = g_entityMgr:getMonster(monsterID)
		if monster then
			if monster:getTargetID() == 0 then
				if config.q_ai1Monster[monster:getModelID()] then
					playerData.attackTarget[monsterID] = playerData.escortID
					monster:foreceAttack(playerData.escortID)
				elseif config.q_ai2Monster[monster:getModelID()] then
					local targetId = guards[math.random(1, #guards)]
					playerData.attackTarget[monsterID] = targetId
					monster:foreceAttack(targetId)
				end
			end
		end
	end
	]]
end

-- 怪物死亡
function VirtualEscortManager:onMonsterKill(monSID, roleID, monID, mapID)
	local roleSID = self._monster[monID]
	if not roleSID then
		return
	end

	local playerData = self._playerData[roleSID]
	if not playerData then
		return
	end

	if playerData.isEnd then
		return
	end

	local config = self._config[playerData.copyID]
	if not config then
		return
	end

	if playerData.monsters[monID] then
		local monster = g_entityMgr:getMonster(monID)
		if monster then
			local word = g_digMineSimulation:getSpeakWord(7)
			if #word > 0 then
				monster:MonsterSpeak(word)
			end
		end
	end

	self._monster[monID] = nil
	playerData.AMonsterID[monID] = nil
	playerData.BMonsterID[monID] = nil

	playerData.guards[monID] = nil
	playerData.monsters[monID] = nil

	local monsters = {}
	for monsterID, _ in pairs(playerData.monsters) do
		table.insert(monsters, monsterID)
	end

	local guards = {}
	for guardID, _ in pairs(playerData.guards) do
		table.insert(guards, guardID)
	end 
	table.insert(guards, playerData.escortID)

	if monID == playerData.escortID then
		self:copyEnd(playerData, false)
	else
		for monsterID, targetID in pairs(playerData.attackTarget) do
			if targetID == monID then
				playerData.attackTarget[monsterID] = nil
				local monster = g_entityMgr:getMonster(monsterID)
				if monster then
					if playerData.guards[monsterID] and #monsters > 0 then
						local targeID = monsters[math.random(1, #monsters)]
						playerData.attackTarget[monsterID] = targeID
						monster:setTargetID(targeID)
					end

					if playerData.monsters[monsterID] and #guards > 0 then
						local targeID = guards[math.random(1, #guards)]
						playerData.attackTarget[monsterID] = targeID
						monster:setTargetID(targeID)
					end
				end
			end
		end
	end

	if #monsters == 0 then
		for guardID, _ in pairs(playerData.guards) do
			local monster = g_entityMgr:getMonster(guardID)
			if monster then
				monster:foreceAttack(0)
			end
		end 
	end
end

-- 检查移动
function VirtualEscortManager:checkMove(roleSID)
	local playerData = self._playerData[roleSID]
	if not playerData then
		return
	end

	if playerData.isEnd then
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	if table.size(playerData.monsters) > 0 then
		return
	end

	local config = self._config[playerData.copyID]
	if not config then
		return
	end

	local flag = true

	--[[
	for i, monsterID in ipairs(playerData.moveEntity) do
		local monster = g_entityMgr:getMonster(monsterID)
		if monster  then
			local pos = monster:getPosition()
			local tmp = VirtualEscortConfig.step[playerData.step]
			if tmp then
				local posStep = {x = tmp[1] + (i - 1), y = tmp[2] + (i - 1)}
				if not (pos.x == posStep.x and pos.y == posStep.y) then
					flag = false
				end
			end
		end
	end
	]]

	local monster = g_entityMgr:getMonster(playerData.moveEntity[1])
	if monster  then
		local pos = monster:getPosition()
		local tmp = VirtualEscortConfig.step[playerData.step]
		if tmp then
			local posStep = {x = tmp[1], y = tmp[2]}
			if not (pos.x == posStep.x and pos.y == posStep.y) then
				flag = false
			end
		end
	end

	for i, monsterID in ipairs(playerData.moveEntity) do
		local monster = g_entityMgr:getMonster(monsterID)

		if monster and not monster:isMove() then
			local pos = monster:getPosition()
			local tmp = VirtualEscortConfig.step[playerData.step]
			if tmp then
				local posStep = {x = tmp[1] + i - 1, y = tmp[2] + i - 1}
				if not (pos.x == posStep.x and pos.y == posStep.y) then
					local dir, len = GetMoveDirAndLen(pos, posStep)
					if dir == nil then
						return
					end

					monster:moveDir(dir, 0, len)
				end
			end
		end
	end

	if playerData.step == 0 or (flag and playerData.step < #VirtualEscortConfig.step) then
		playerData.step = playerData.step + 1

		if playerData.step == 6 and not playerData.BMonsterFlag then
			playerData.BTime = os.time()
			self:burnMonster(playerData, VirtualEscortConfig.BPos, config.q_BMonster, playerData.BMonsterID, 4, 8)
			playerData.BMonsterFlag = true
		end
	elseif flag and playerData.step == #VirtualEscortConfig.step then
		local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
		if copyPlayer then
			copyPlayer:onFinishSingleInst(playerData.copyID)
		end

		self:copyEnd(playerData, true)
	end
end

-- 停止移动
function VirtualEscortManager:onMonsterStop(monID)
	local roleSID = self._monster[monID]
	if not roleSID then
		return
	end

	local playerData = self._playerData[roleSID]
	if not playerData then
		return
	end

	if playerData.isEnd then
		return
	end

	local config = self._config[playerData.copyID]
	if not config then
		return
	end

	for _, monsterID in ipairs(playerData.moveEntity) do
		if monsterID == monID then
			self:checkMove(roleSID)
		end
	end
end

-- 关闭
function VirtualEscortManager:close(roleSID)
	local playerData = self._playerData[roleSID]
	if not playerData then
		return
	end

	local player = g_entityMgr:getPlayerBySID(playerData.roleSID)
	if not player then
		return
	end

	player:setHP(player:getMaxHP())

	local mapID = player:getLastMapID()
	local x = player:getLastPosX()
	local y = player:getLastPosY()
	if g_sceneMgr:posValidate(mapID, x, y) then
		g_sceneMgr:enterPublicScene(player:getID(), mapID, x, y)
		player:setCopyID(0)
	else
		--如果地图有问题就走出生点
		g_sceneMgr:enterPublicScene(player:getID(), 1100, 21, 100)
		player:setCopyID(0)
	end

	player:setCampID(0)

	local petID = player:getPetID()
	local pet = g_entityMgr:getMonster(petID)
	if pet then
		pet:setCampID(0)
	end

	playerData.scene:releaseAllMonsters()
	g_sceneMgr:releaseScene(playerData.scene, playerData.copyInsID)
	self._playerData[roleSID] = nil
end

-- 获得剩余时间
function VirtualEscortManager:getLeftTime(roleSID)
	local playerData = self._playerData[roleSID]
	if not playerData then
		return
	end

	if playerData.isEnd then
		return
	end

	local player = g_entityMgr:getPlayerBySID(playerData.roleSID)
	if not player then
		return
	end

	local ret = {}
	ret.leftTime = VirtualEscortConfig.duringTime - (os.time() - playerData.startTime)
	if ret.leftTime < 0 then
		ret.leftTime = 0
	end

	fireProtoMessage(player:getID(), COMMON_SC_VITURALESCROTTIMERET, "VitrualEscrotTimeRetProtocol", ret)
end

function VirtualEscortManager:learnSkill(mosnter)
	local skillMgr = mosnter:getSkillMgr()
	if not skillMgr then
		return
	end

	local err = 0

	local level = mosnter:getLevel()
	if level >= 10 and level <= 15 then
		if mosnter:getSchool() == 1 then
			skillMgr:learnSkill(1031, err)
		elseif mosnter:getSchool() == 2 then
			skillMgr:learnSkill(2031, err)
		elseif mosnter:getSchool() == 3 then
			skillMgr:learnSkill(3033, err)
		end
	elseif level >= 20 and level <= 45 then
		if mosnter:getSchool() == 1 then
			skillMgr:learnSkill(1034, err)
		elseif mosnter:getSchool() == 2 then
			skillMgr:learnSkill(2032, err)
		elseif mosnter:getSchool() == 3 then
			skillMgr:learnSkill(3033, err)
		end
	elseif  level >= 50 and level <= 60 then
		if mosnter:getSchool() == 1 then
			skillMgr:learnSkill(1036, err)
		elseif mosnter:getSchool() == 2 then
			skillMgr:learnSkill(2038, err)
		elseif mosnter:getSchool() == 3 then
			skillMgr:learnSkill(3040, err)
		end
	end
end

function VirtualEscortManager:calculatePos(step, index)

end

function VirtualEscortManager:copyEnd(playerData, success)
	if not playerData.scene then
		return
	end

	playerData.isEnd = true

	if success then
		playerData.scene:releaseAllMonsters()
	end

	local player = g_entityMgr:getPlayerBySID(playerData.roleSID)
	if not player then
		return
	end

	local ret = {}
	ret.result = success

	fireProtoMessage(player:getID(), COMMON_SC_VITURALESCROTRESULT, "VitrualEscrotResultProtocol", ret)
end

-- 玩家死亡
function VirtualEscortManager:onPlayerDied(player, killerID)
	if player == nil then
		return
	end

	local playerData = self._playerData[player:getSerialID()]
	if not playerData then
		return
	end

	self:copyEnd(playerData, false)
end

--玩家掉线
function VirtualEscortManager:onPlayerInactive(player)
	if player == nil then
		return
	end

	local playerData = self._playerData[player:getSerialID()]
	if not playerData then
		return
	end

	self:close(player:getSerialID())
end

g_VirtualEscorMgr = VirtualEscortManager()


