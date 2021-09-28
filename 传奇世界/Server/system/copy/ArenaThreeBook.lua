--ArenaThreeBook.lua
--3v3竞技场



ArenaThreeBook = class(CopyBook)

function ArenaThreeBook:__init()
	self._currCircle = 1		--当前怪物刷新环数，第几波

	self._friendMonster={}  
	self._enemyMonster={}

	self._playerSchool = 0

	self._friendMonsterList = {}
	self._enemyMonsterList = {}

	self._next_converge_time = 0  --下次集火开始时间
	self._covverge_end_time = 0  --本次集火结束时间

	self._converge_flag = false

	self.q_arena_monster_ai = {{211,212,213},{221,222,223},{231,232,233}}

	self.q_school_skill = {{1008,1006,1005,1010,1003,1009},{2004,2005,2007,2011,2002,2010},{3006,3007,3008,3004,3009,3002,3011,3003}}

	self.q_hasMove = false
end

function ArenaThreeBook:setStartTime()
	self._startTime = os.time()
end

function ArenaThreeBook:setCurrCircle(circle)
	self._currCircle = circle
end

function ArenaThreeBook:getCurrCircle()
	return self._currCircle
end

--副本创建时执行的逻辑
function ArenaThreeBook:OnCopyInit( player )
	local playerID = self:getPlayerID()
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	local player = g_entityMgr:getPlayer(playerID)
	if not copyPlayer or not player then return end
	local proto = self:getPrototype()
	proto = proto:getData()
	if not proto then return end

	--创建敌方怪物
	for i=1,#proto.q_enemy_pos do
		local monster = self:FlushArenaMonster(proto.q_enemy_pos[i],2)
		if monster then
			self._enemyMonster[monster:getID()] = {}
			self._enemyMonster[monster:getID()]["school"] = monster:getSchool()
			self._enemyMonster[monster:getID()]["s_time"] = 0
			table.insert(self._enemyMonsterList,monster:getID())
			monster:setViewRange(60)
			monster:SetTempId(player:getID())
			monster:setLevel(70)
			--monster:setCampID(10)
		end	
	end

	--创建已方怪物
	for i=1,#proto.q_friend_pos do
		local monster = self:FlushArenaMonster(proto.q_friend_pos[i],1)
		if monster then
			self._friendMonster[monster:getID()] = {}
			self._friendMonster[monster:getID()]["school"] = monster:getSchool()
			self._friendMonster[monster:getID()]["s_time"] = 0
			self._friendMonster[monster:getID()]["move_pos"] = proto.q_friend_go[i]
			table.insert(self._friendMonsterList,monster:getID())
			monster:setViewRange(60)
			monster:SetTempId(player:getID())
			monster:setLevel(70)
			--monster:setCampID(player:getID())

			local word = g_digMineSimulation:getSpeakWord(8)
			if #word > 0 then
				monster:MonsterSpeak(word)
			end
		end	
	end


	--玩家
	self._playerSchool = player:getSchool()

	self._next_converge_time = os.time() + math.random(proto.q_attackpayler_time[1],proto.q_attackpayler_time[2]) + 10;
	self._covverge_end_time = 0

	self:changeMonsterNum(#proto.q_enemy_pos)

	self:setOldPkMode(player:getPattern())
	self:setOldCampId(player:getCampID())
	player:setPattern(1)
	player:setCampID(1)

	local petID = player:getPetID()
	local pet = g_entityMgr:getMonster(petID)
	if pet then
		pet:setCampID(1)
	end

end



--运行时执行逻辑
function ArenaThreeBook:OnCopyLogicUpdate()
	local playerID = self:getPlayerID()
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	local player = g_entityMgr:getPlayer(playerID)
	if not copyPlayer or not player then return end

	local proto = self:getPrototype():getData()
	if not proto then return end
	--开始时已方移动位置
	if self.q_hasMove == false then
		self.q_hasMove = true

		for key, val in pairs(self._friendMonster or {}) do
			local monster = g_entityMgr:getMonster(key)
			if monster then 
				monster:change2NullAI()
				monster:MoveTo(val["move_pos"][1],val["move_pos"][2],"ArenaThreeBook")
				print("======monster",key,val["move_pos"][1],val["move_pos"][2])
			end
		end
	end

	if self:getTakeTime() < 16 then
		return
	end	
	--怪物定时切换目标
	for key, val in pairs(self._enemyMonster or {}) do
		if val.s_time < os.time() then
			self:EnemySwitchTarget(key)
		end	
	end

	for key, val in pairs(self._friendMonster or {}) do
		if val.s_time < os.time() then
			self:FriendSwitchTarget(key)
		end	
	end

	--怪物定时集火玩家
	if self._next_converge_time < os.time() then
		self:EnemyConverge()
	end	

	--取消集火
	if self._covverge_end_time < os.time() then
		self:CancelConverge()
	end	
end

function ArenaThreeBook:OnMonsterDead(monSID, roleID, monID)
	--是否敌方怪物
	--if roleID ~= self:getPlayerID() then return end

	--print("============monstet dead"..monSID.."==="..monID)

	for i=1,#self._friendMonsterList do
		if self._friendMonsterList[i] == monID then
			table.remove(self._friendMonsterList,i)
			self._friendMonster[monID] = nil
			self:EnemySwitchTarget(roleID)
			break
		end
	end

	for i=1,#self._enemyMonsterList do
		if self._enemyMonsterList[i] == monID then
			table.remove(self._enemyMonsterList,i)
			self._enemyMonster[monID] = nil
			self:FriendSwitchTarget(roleID)

			local monster = g_entityMgr:getMonster(monID)
			if monster then 
				local word = g_digMineSimulation:getSpeakWord(11)
				if #word > 0 then
					monster:MonsterSpeak(word)
				end
			end	
			break
		end
	end



	--print("============monstet dead",#self._enemyMonsterList)

	if #self._enemyMonsterList < 1 then 
		--副本结束
		--print("===================monstet dead end"..monSID.."==="..monID)
		self:setMonsterNum(0)
	end 
end

function ArenaThreeBook:EnemySwitchTarget(monsterId)
	-- body
	local proto = self:getPrototype()
	proto = proto:getData()
	if not proto then return end
	
	if not self._enemyMonster[monsterId] then return end

	--集火状态不切换目标
	if self._converge_flag == true then return end

	self._enemyMonster[monsterId].s_time = os.time() + math.random(proto.q_switch_time[1],proto.q_switch_time[2])

	local targetid = 0
	if #self._friendMonsterList < 1 then 
		targetid = self:getPlayerID()
	else
		local rand_num = math.random(1,10)
		if rand_num > 5 then
			targetid = self:getPlayerID()
		else
			local randIndex = math.random(1,#self._friendMonsterList)
			targetid = self._friendMonsterList[randIndex]
		end	
	end

	if targetid == 0 then return end

	local monster = g_entityMgr:getMonster(monsterId)
	local aiRuleId = 0
	if targetid == self:getPlayerID() then
		aiRuleId = self.q_arena_monster_ai[monster:getSchool()][self._playerSchool]
	else
		local target = g_entityMgr:getMonster(monsterId)
		if target then
			aiRuleId = self.q_arena_monster_ai[monster:getSchool()][target:getSchool()]
		end
	end	

	if aiRuleId then
		--print("=========airule==Enemy"..aiRuleId)
		monster:changeAIRule(aiRuleId)
		monster:foreceAttack(targetid)
		local word = g_digMineSimulation:getSpeakWord(9)
		if #word > 0 then
			monster:MonsterSpeak(word)
		end
	end	
end

function ArenaThreeBook:FriendSwitchTarget(monsterId)
	-- body
	local proto = self:getPrototype()
	proto = proto:getData()
	if not proto then return end

	local monster = g_entityMgr:getMonster(monsterId)	
	if not monster then return end

	if not self._friendMonster[monsterId] then return end
	self._friendMonster[monsterId].s_time = os.time() + math.random(proto.q_switch_time[1],proto.q_switch_time[2])

	if #self._enemyMonsterList < 1 then return end

	local randIndex = math.random(1,#self._enemyMonsterList)
	local targetId = self._enemyMonsterList[randIndex]

	local target = g_entityMgr:getMonster(targetId)	
	if not target then return end

	local aiRuleId = self.q_arena_monster_ai[monster:getSchool()][target:getSchool()]

	print("=========airule==Friend"..aiRuleId)
	monster:changeAIRule(aiRuleId)
	monster:foreceAttack(targetId)
end

function ArenaThreeBook:EnemyConverge()
	-- body
	local proto = self:getPrototype()
	proto = proto:getData()
	if not proto then return end

	self._converge_flag = true
	self._next_converge_time = os.time() + math.random(proto.q_attackpayler_time[1],proto.q_attackpayler_time[2]);
	self._covverge_end_time = os.time() + proto.q_cancel_attck_player_time

	for key, val in pairs(self._enemyMonster or {}) do
		local monster = g_entityMgr:getMonster(key)
		if monster then 
			local aiRuleId = self.q_arena_monster_ai[monster:getSchool()][self._playerSchool]
			if aiRuleId then
				monster:changeAIRule(aiRuleId)
				monster:foreceAttack(self:getPlayerID())
				local word = g_digMineSimulation:getSpeakWord(10)
				if #word > 0 then
					monster:MonsterSpeak(word)
				end
			end	
		end
	end
end

function ArenaThreeBook:CancelConverge()
	-- body
	self._converge_flag = false
	self._covverge_end_time = 0
end

function ArenaThreeBook:FlushArenaMonster(posxy,campid)
	local proto = self:getPrototype()
	if not proto then return end

	local mapID = proto:getMapID()
	local scene = self:getScene(mapID)
	if not scene then
		return
	end	

	local monMinMax = proto:getData().q_monsterid_min_max
	local monId = math.random(monMinMax[1],monMinMax[2])
	--[[local monId = 74001
	if campid == 2 then
		monId = 74002
	end]]--	

	local pMonInfoID = 8010

	local mon = g_entityMgr:getFactory():createMonster(monId)
	--if mon and scene:addCopyMonsterInfo(mon, pMonInfoID) then
	if mon then
		mon:setCampID(campid)
		--if scene:attachEntity(mon:getID(), position.x+MonsterPos[monnum-1], position.y+MonsterPos[monnum]) then
		if scene:attachEntity(mon:getID(), posxy[1], posxy[2]) then
			scene:addMonster(mon)
			--添加副本怪物计数
			self:changeMonsterNum(1)
			self:addPosMon(mon:getID())	
			mon:setOwnCopyID(self:getCurrInsId())
			self:learnSkill(mon)
			return mon
		end
	end
end


function ArenaThreeBook:learnSkill(monster)
	-- body
	local skillMgr = monster:getSkillMgr()
	if not skillMgr then
		return
	end

	local err = 0

	local skill_list = self.q_school_skill[monster:getSchool()]

	for i=1,#skill_list do
		skillMgr:learnSkill(skill_list[i], err)
	end	
end

function ArenaThreeBook:doReward(newTime)
	return
end

--3v3竞技场副本资源回收
--1 T人 更新个人副本数据
--2 清怪
--3 清地图
function ArenaThreeBook:clearBook()
	local currInstId = self:getCurrInsId()				--当前副本ID
	print(string.format("ArenaThreeBook:clearBook %d[%d:%d]",self._playerID,self._copyID,currInstId))

	local roleID = self._playerID
	local player = g_entityMgr:getPlayer(self._playerID)		--单人副本记录的玩家ID
	local copyPlayer = g_copyMgr:getCopyPlayer(self._playerID)	--玩家的副本数据

	if copyPlayer and player then
		--用完要清空
		copyPlayer:clearGuardReward()
		g_copyMgr:dealExitCopy(player, copyPlayer)

		g_copySystem:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
	else
		print("ArenaThreeBook:clearBook, invalid _playerID")
		g_copyMgr:releaseCopy(currInstId, self:getPrototype():getCopyType())
	end

	player:setPattern(self._oldPkMode)
	player:setCampID(self._oldCampId)
end

--副本同步怪物数量
function ArenaThreeBook:notifyMonsterNum(monSID)
	local ret = {}
	ret.monsterSid = monSID
	ret.copyId = self:getPrototype():getCopyID()
	fireProtoMessage(self._playerID, COPY_SC_ONMONSTERKILL, 'CopyOnMonsterKillProtocol', ret)

end
