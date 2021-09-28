--DigMineSimulation.lua
--/*-----------------------------------------------------------------
--* Module:  DigMineSimulation.lua
--* Author:  Andy
--* Modified: 2016年09月01日
--* Purpose: 模拟挖矿
-------------------------------------------------------------------*/

DigMineSimulation = class(nil, Singleton, Timer)

function DigMineSimulation:__init()
	self._roleConfig = {}		--模拟玩家配置
	self._speakConfig = {}		--怪头顶文字配置
	self._userInfo = {}			--玩家数据
	self._mineUser = {}			--在副本挖矿的玩家
	self._quitScene = {}		--待退出场景的怪物ID

	self:loadConfig()
	g_listHandler:addListener(self)

	gTimerMgr:regTimer(self, 3000, 3000)
	print("DigMineSimulation TimeID:",self._timerID_)
end

function DigMineSimulation:loadConfig()
	for _, config in pairs(require "data.SimulationRoleCopyDB") do
		local tmp = {}
		tmp.id = config.q_id
		tmp.copyID = config.q_copy_id
		tmp.monsterID = config.q_mon_id
		tmp.name = config.q_name or ""
		tmp.level = config.q_level or 0
		tmp.sex = config.q_sex or 1
		tmp.school = math.mod(tmp.monsterID, 1000)
		tmp.hp = config.q_hp or 0
		tmp.x = config.q_x or 0
		tmp.y = config.q_y or 0
		tmp.minAt = config.q_attack_min or 0
		tmp.maxAt = config.q_attack_max or 0
		tmp.minDt = config.q_sc_attack_min or 0
		tmp.maxDt = config.q_sc_attack_max or 0
		tmp.minMt = config.q_magic_attack_min or 0
		tmp.maxMt = config.q_magic_attack_max or 0
		tmp.minDf = config.q_defense_min or 0
		tmp.maxDf = config.q_defense_max or 0
		tmp.minMf = config.q_magic_defence_min or 0
		tmp.maxMf = config.q_magic_defence_max or 0
		tmp.hit = config.q_hit or 0
		tmp.dodge = config.q_dodge or 0
		tmp.digMine = (config.q_dig_mine or 0) == 1
		tmp.probability = config.q_probability
		self._roleConfig[tmp.id] = tmp
	end
	for _, config in pairs(require "data.CopyWord") do
		local tmp = {}
		tmp.id = config.q_id
		tmp.eventID = config.q_event
		tmp.probability = config.q_probability
		tmp.word = loadstring("return " .. (config.q_word or '{}'))()
		self._speakConfig[tmp.id] = tmp
	end
end

function DigMineSimulation:getSpeakWord(eventID)
	local word = ""
	for _, config in pairs(self._speakConfig) do
		if config.eventID == eventID then
			if config.probability >= math.random(1, 100) and #config.word > 0 then
				word = config.word[math.random(1, #config.word)]
			end
			break
		end
	end
	return word
end

function DigMineSimulation:getRoleConfig(id)
	return self._roleConfig[id]
end

function DigMineSimulation:getRoleConfigByCopyID(copyID)
	local result = {}
	for _, config in pairs(self._roleConfig) do
		if config.copyID == copyID then
			table.insert(result, config)
		end
	end
	return result
end

--创建矿堆
function DigMineSimulation:createMine(roleID, sceneID)
	local playerInfo = self:getPlayerInfo(roleID)
	local scene = self:getScene(sceneID)
	if scene then
		for _, config in pairs(self:getRoleConfigByCopyID(0)) do
			local monsterID = config.monsterID 		--DIGMINE_MONSTER_MINE_ID[math.random(1, 3)]
			local monster = g_entityFct:createMonster(monsterID)
			if monster then
				playerInfo:addMonster(monster:getID(), true)
				playerInfo:addMine(monster:getID())
				scene:attachEntity(monster:getID(), config.x, config.y)
			end
		end
	end
end

--创建模拟玩家
function DigMineSimulation:createSimulationPlayer(role, sceneID)
	local scene = self:getScene(sceneID)
	if role and scene then
		local monsterID = role.monsterID
		local monster = g_entityFct:createMonster(monsterID)
		if monster then
			monster:setHP(role.hp)
			monster:setMaxHP(role.hp)
			monster:setMaxMP(10000)
			monster:setMP(10000)
			monster:setName(role.name)
			monster:setMinDT(role.minDt)
			monster:setMaxDT(role.maxDt)
			monster:setMinAT(role.minAt)
			monster:setMaxAT(role.maxAt)
			monster:setMinMT(role.minMt)
			monster:setMaxMT(role.maxMt)
			monster:setLevel(role.level)
			monster:setMinDF(role.minDf)
			monster:setMaxDF(role.maxDf)
			monster:setMinMF(role.minMf)
			monster:setMaxMF(role.maxMf)
			monster:setHit(role.hit)
			monster:setDodge(role.dodge)
			monster:setMoveSpeed(170)
			monster:setSchool(role.id)		--school字段特殊处理，传配置ID给客户端
			monster:setCampID(1)			--此属性代替头顶物品个数
			monster:setViewRange(60)
			local skillMgr = monster:getSkillMgr()
			if skillMgr then
				local level, school, skillID = role.level, role.school, 0
				if level >= 10 and level <= 15 then
					if school == 1 then
						skillID = 1031
					elseif school == 2 then
						skillID = 2031
					elseif school == 3 then
						skillID = 3033
					end
				elseif level >= 20 and level <= 45 then
					if school == 1 then
						skillID = 1034
					elseif school == 2 then
						skillID = 2032
					elseif school == 3 then
						skillID = 3033
					end
				elseif level >= 50 and level <= 60 then
					if school == 1 then
						skillID = 1036
					elseif school == 2 then
						skillID = 2038
					elseif school == 3 then
						skillID = 3040
					end
				end
				if skillID > 0 then
					skillMgr:learnSkill(skillID, 0)
					monster:setCurSkillId(skillID)
				end
			end
			monster:changeAIRule(7000)
			scene:attachEntity(monster:getID(), role.x, role.y)
			scene:addMonster(monster, false)
		end
		return monster
	end
end

function DigMineSimulation:getScene(sceneID)
	return g_sceneMgr:getById(sceneID)
end

function DigMineSimulation.pickUp(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local roleID = player:getID()
		local playerInfo = g_digMineSimulation:getPlayerInfo(roleID)
		if playerInfo:getProgress() < DIGMINE_SIMULATION_NUM then
			playerInfo:setProgress(playerInfo:getProgress() + 1)
			playerInfo:syncStatus()
		end
	end
end

function DigMineSimulation:onActivePlayer(player)
	local roleID = player:getID()
	if self:inTheCopy(roleID) then
		local playerInfo = self:getPlayerInfo(roleID)
		playerInfo:syncStatus()
	end
end

function DigMineSimulation:onPlayerOffLine(player)
	self:quitCopy(player:getID())
end

function DigMineSimulation:onMonsterHurt(monsterSID, roleID, hurt, monsterID)
	if not self:inTheCopy(roleID) then
		return
	end
	local playerInfo = self:getPlayerInfo(roleID)
	playerInfo:attack(monsterID)
end

function DigMineSimulation:onMonsterKill(monsterSID, roleID, monsterID, mapID)
	if mapID == DIGMINE_SIMULATION_MAP_ID and self:inTheCopy(roleID) then
		local playerInfo = self:getPlayerInfo(roleID)
		playerInfo:killSimulation(monsterID)
		self._quitScene[monsterID] = os.time()
	end
end

function DigMineSimulation:update()
	local now = os.time()
	for roleID, mineID in pairs(self._mineUser) do
		local player = g_entityMgr:getPlayer(roleID)
		if player and player:hasEffectState(DIGMINE_INMINE) then
			local playerInfo = self:getPlayerInfo(roleID)
			local updateTime = playerInfo:getUpdateTime()
			if (mineID == DIGMINE_MONSTER_MINE_ID[1] and now - updateTime > 3) or (mineID == DIGMINE_MONSTER_MINE_ID[2] and now - updateTime > 6)
				or (mineID == DIGMINE_MONSTER_MINE_ID[3] and now - updateTime > 12) then
				playerInfo:setProgress(playerInfo:getProgress() + 1)
				playerInfo:setUpdateTime(now)
				playerInfo:ramdonAttack()
				playerInfo:syncStatus()
			end
			if playerInfo:getProgress() >= DIGMINE_SIMULATION_NUM then
				self:releaseMineUser(roleID)
			end
		else
			self:releaseMineUser(roleID)
		end
	end
	for roleID, playerInfo in pairs(self._userInfo) do
		local useTime = now - playerInfo:getStartTime()
		if useTime >= 20 and useTime <= 40 then
			playerInfo:attackPlayer()
		end
		if useTime >=2 and useTime <= 10 then
			playerInfo:mineUserSpeak()
		end
		if useTime > DIGMINE_SIMULATION_DEL_TIME then
			self:quitCopy(roleID)
		end
		playerInfo:checkAttack()
	end
	for monsterID, t in pairs(self._quitScene) do
		if now - t > 3 then
			local monster = g_entityMgr:getMonster(monsterID)
			if monster then
				monster:quitScene()
			end
			self._quitScene[monsterID] = nil
		end
	end
end

--进入副本
function DigMineSimulation:enterCopy(roleID, copyID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	local x, y = DIGMINE_ENTER_POSITION.x, DIGMINE_ENTER_POSITION.y
	if not g_sceneMgr:posValidate(DIGMINE_SIMULATION_MAP_ID, x, y) or player:getMapID() == DIGMINE_SIMULATION_MAP_ID then
		return
	end
	local position = player:getPosition()
	player:setLastMapID(player:getMapID())
	player:setLastPosX(position.x)
	player:setLastPosY(position.y)
	if self:inTheCopy(roleID) then
		self:quitCopy(roleID)
	end
	local playerInfo = self:getPlayerInfo(roleID)
	local scene = g_sceneMgr:createCopyScene(g_copyMgr:requestNewId(), DIGMINE_SIMULATION_MAP_ID)
	local sceneID = scene:getID()
	playerInfo:setSceneID(sceneID)
	playerInfo:setCopyID(copyID)
	playerInfo:setPattern(player:getPattern())
	playerInfo:setPreHP(player:getHP())
	player:setHP(player:getMaxHP())
	player:setCopyID(copyID)
	player:setPattern(3)
	self:createMine(roleID, sceneID)
	for _, role in pairs(self:getRoleConfigByCopyID(copyID)) do
		if role then
			if role.digMine then
				local monster = self:createSimulationPlayer(role, sceneID)
				if monster then
					monster:setCampID(2)
					local buffmgr = monster:getBuffMgr()
					if buffmgr then
						buffmgr:addBuff(DIGMINE_BUFFID, 0)
					end
					local monsterID = monster:getID()
					playerInfo:setMineMaster(monsterID, role.x, role.y)
					playerInfo:addMonster(monsterID, false)
					playerInfo:addSimulation(monsterID, role.probability)
				end
			else
				playerInfo:setProbability(role.probability)
				playerInfo:addAttack(role.id)
			end
		end
	end
	local scene = self:getScene(sceneID)
	if scene then
		local oldPetID = player:getPetID()
		if oldPetID > 0 then
			g_entityMgr:destoryEntity(oldPetID)
		end
		scene:attachEntity(roleID, x, y)
	end
	playerInfo:syncStatus()
end

function DigMineSimulation:quitCopy(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player and player:getMapID() == DIGMINE_SIMULATION_MAP_ID then
		g_sceneMgr:enterPublicScene(roleID, player:getLastMapID(), player:getLastPosX(), player:getLastPosX(), 1)
		local playerInfo = self:getPlayerInfo(roleID)
		player:setHP(playerInfo:getPreHP())
		player:setCopyID(0)
		player:setPattern(playerInfo:getPattern())
		playerInfo:cleanCopy()
	end
	self._userInfo[roleID] = nil
	self._mineUser[roleID] = nil
end

function DigMineSimulation:finishCopy(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo:getProgress() >= DIGMINE_SIMULATION_NUM then
		local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
		if copyPlayer then
			g_copyMgr:onFinishSingleInst(copyPlayer, playerInfo:getCopyID())
		end
	end
end

function DigMineSimulation:getPlayerInfo(roleID)
	if not self._userInfo[roleID] then
		self._userInfo[roleID] = DigMineSimulationInfo(roleID)
	end
	return self._userInfo[roleID]
end

--是否在副本中
function DigMineSimulation:inTheCopy(roleID)
	if self._userInfo[roleID] then
		return true
	end
	return false
end

--开始挖矿
function DigMineSimulation:startDigMine(roleID, mineID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo:canDig(mineID) then
		local monster = g_entityMgr:getMonster(mineID)
		if monster then
			self._mineUser[roleID] = tonumber(monster:getSerialID())
			playerInfo:setUpdateTime(os.time())
			return true
		end
	end
	return false
end

function DigMineSimulation:releaseMineUser(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if player and player:hasEffectState(DIGMINE_INMINE) then
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:delBuff(DIGMINE_BUFFID)
		end
	end
	self._mineUser[roleID] = nil
end

function DigMineSimulation.getInstance()
	return DigMineSimulation()
end

g_digMineSimulation = DigMineSimulation.getInstance()


----------------------------------------------------------------------------------------------


DigMineSimulationInfo = class()

local prop = Property(DigMineSimulationInfo)
prop:accessor("roleID")
prop:accessor("startTime")		--开始时间
prop:accessor("sceneID", 0)		--场景ID
prop:accessor("copyID", 0)		--副本ID
prop:accessor("progress", 0)	--任务进度
prop:accessor("mineID", 0)		--允许挖的矿堆
prop:accessor("updateTime", 0)	--上次结算时间
prop:accessor("probability", 0)	--外来攻击玩家的人物模型触发概率
prop:accessor("preHP", 0)		--进副本前血量
prop:accessor("pattern", 0)		--玩家原来的攻击模式

function DigMineSimulationInfo:__init(roleID)
	self._monsters = {}			--所有刷出来的怪物ID
	self._simulation = {}		--挖矿中的人物模型触发攻击玩家的概率
	self._attack = {}			--外来攻击玩家的人物模型模型索引
	self._mineMaster = {}		--矿的归属
	prop(self, "roleID", roleID)
	prop(self, "startTime", os.time())
end

function DigMineSimulationInfo:addMonster(monsterID, digMine)
	self._monsters[monsterID] = digMine
end

function DigMineSimulationInfo:addSimulation(monsterID, probability)
	self._simulation[monsterID] = {probability = probability, speak = false}
end

function DigMineSimulationInfo:addAttack(id)
	table.insert(self._attack, id)
end

function DigMineSimulationInfo:addMine(mineID)
	self._mineMaster[mineID] = 0
end

--设置矿堆模型归属
function DigMineSimulationInfo:setMineMaster(monsterID, x, y)
	for k, v in pairs(self._mineMaster) do
		local monster = g_entityMgr:getMonster(k)
		if self._mineMaster[k] == 0 and monster then
			local position = monster:getPosition()
			local x, y = position.x - x, position.y - y
			if x * x + y * y <= 8 then
				self._mineMaster[k] = monsterID
				break
			end
		end
	end
end

function DigMineSimulationInfo:canDig(mineID)
	if self._mineMaster[mineID] and self._mineMaster[mineID] == 0 then
		return true
	end
	return false
end

function DigMineSimulationInfo:releaseMine(monsterID)
	for k, v in pairs(self._mineMaster) do
		if v == monsterID then
			self._mineMaster[k] = 0
			break
		end
	end
end

--击杀模型
function DigMineSimulationInfo:killSimulation(monsterID)
	local monster = g_entityMgr:getMonster(monsterID)
	if monster then
		if monster:getCampID() > 0 then
			monster:dropItem(DIGMINE_MINE_ID, monster:getCampID(), true)
		end
		local word = g_digMineSimulation:getSpeakWord(4)
		if #word > 0 then
			monster:MonsterSpeak(word)
		end
	end
	if self._simulation[monsterID] then
		self._simulation[monsterID] = nil
		self:releaseMine(monsterID)
	end
end

--随机模型停止挖矿攻击玩家
function DigMineSimulationInfo:ramdonAttack()
	for monsterID, info in pairs(self._simulation) do
		if info.probability >= math.random(1, 100) then
			self:attack(monsterID)
		end
	end
end

--挖矿模型攻击玩家
function DigMineSimulationInfo:attack(monsterID)
	if self._simulation[monsterID] then
		local monster = g_entityMgr:getMonster(monsterID)
		if monster then
			monster:foreceAttack(self:getRoleID())
			local word = g_digMineSimulation:getSpeakWord(2)
			if #word > 0 then
				monster:MonsterSpeak(word)
			end
		end
		self._simulation[monsterID] = nil
		self:releaseMine(monsterID)
	end
end

--挖矿模型说话
function DigMineSimulationInfo:mineUserSpeak()
	for monsterID, info in pairs(self._simulation) do
		if not info.speak then
			info.speak = true
			local monster = g_entityMgr:getMonster(monsterID)
			if monster then
				local word = g_digMineSimulation:getSpeakWord(1)
				if #word > 0 then
					monster:MonsterSpeak(word)
				end
			end
			break
		end
	end
end

--外来模型过来攻击玩家
function DigMineSimulationInfo:attackPlayer()
	local probability = self:getProbability()
	if probability > 0 and probability >= math.random(1, 100) then
		local speak = true
		for _, id in pairs(self._attack) do
			local role = g_digMineSimulation:getRoleConfig(id)
			if role then
				local monster = g_digMineSimulation:createSimulationPlayer(role, self:getSceneID())
				if monster then
					self:addMonster(monster:getID(), false)
					monster:foreceAttack(self:getRoleID())
					if speak then
						speak = false
						local word = g_digMineSimulation:getSpeakWord(3)
						if #word > 0 then
							monster:MonsterSpeak(word)
						end
					end
				end
			end
		end
		self:setProbability(0)
		self._attack = {}
	end
end

--检测怪物模型攻击玩家
function DigMineSimulationInfo:checkAttack()
	for monsterID, digMine in pairs(self._monsters) do
		if not digMine and not self._simulation[monsterID] then
			local monster = g_entityMgr:getMonster(monsterID)
			if monster and monster:getHP() > 0 and monster:getTargetID() == 0 then
				monster:foreceAttack(self:getRoleID())
			end
		end
	end
end

function DigMineSimulationInfo:cleanCopy()
	for monsterID, _ in pairs(self._monsters) do
		g_entityMgr:destoryEntity(monsterID)
	end
	local sceneID = self:getSceneID()
	local scene = g_digMineSimulation:getScene(sceneID)
	if scene then
		g_copyMgr:addToDeleteList(scene, sceneID)
	end
end

function DigMineSimulationInfo:syncStatus()
	local ret = {}
	ret.totalProgress = DIGMINE_SIMULATION_NUM
	ret.progress = self:getProgress()
	ret.mineCount = ret.progress
	ret.timeout = math.max(self:getStartTime() + DIGMINE_SIMULATION_TIME - os.time(), 0)
print(serialize(ret))
	fireProtoMessage(self:getRoleID(), DIGMINE_SC_SIMULATION_SYNC, "DigMineSimulationSync", ret)
end