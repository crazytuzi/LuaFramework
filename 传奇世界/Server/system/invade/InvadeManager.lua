--InvadeManager.lua
--/*-----------------------------------------------------------------
 --* Module:  InvadeManager.lua
 --* Author:  Andy
 --* Modified: 2016年03月21日
 --* Purpose: Implementation of the class InvadeManager
 -------------------------------------------------------------------*/
require ("system.invade.InvadeConstant")
require ("system.invade.InvadeInfo")
require ("system.invade.InvadeServlet")

InvadeManager = class(nil, Singleton, Timer)

function InvadeManager:__init()
	self._openActivity = false	--活动是否开启
	self._monsterConfig = {}	--怪物配置
	self._invadeInfo = {}		--山贼入侵行会数据
	self._factionAreaUser = {}	--在行会据点的玩家
	self._deathTime = {}		--怪物死亡时间
	self._monsterInfo = {}		--行会据点的所有怪物
	self._userDropID = {}		--玩家获得奖励对应的掉落ID

	self._delayBuff = {}		--活动时间内进入行会据点延时加buff的玩家
	self._endTime = 0			--活动结束时间
	self._gmOpenTime = 0		--GM命令开启的时间
	self._deathCount = 0		--活动期间死亡的人数（Tlog日志）

	self:loadConfig()
	g_listHandler:addListener(self)

	gTimerMgr:regTimer(self, 1000, 3000)
	print("InvadeManager Timer", self._timerID_)
end

function InvadeManager:loadConfig()
	for _, record in pairs(require "data.InvadeDB" or {}) do
		local tmp = {}
		tmp.id = record.q_id
		tmp.type = record.q_type
		tmp.position = record.q_pos
		tmp.time = record.q_time
		tmp.num = record.q_num
		tmp.integral = record.q_integral
		self._monsterConfig[tmp.id] = tmp
	end
end

--活动开启
function InvadeManager:on(gmTime)
	self._openActivity = true
	self:sendErrMsg2Client(0, INVADE_ERR_ACTIVITY_OPEN, 0)
	for factionID, _ in pairs(self._invadeInfo) do
		self:initMonster(INVADE_MONSTER_TYPE.MONSTER1, factionID)
		self:initMonster(INVADE_MONSTER_TYPE.MONSTER2, factionID)
		g_factionMgr:notifyAllMemByEmail(factionID, FactionHD.INVADE)
	end
	for roleSID, _ in pairs(self._factionAreaUser) do
		self._factionAreaUser[roleSID] = self._openActivity
		local player = g_entityMgr:getPlayerBySID(roleSID)
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:addBuff(INVADE_BUFF_ID, 0)
		end
	end
	for _, invadeInfo in pairs(self._invadeInfo) do
		invadeInfo:setPushDataFlag(true)
	end
	if gmTime then
		self._gmOpenTime = gmTime
	end
end

--活动关闭
function InvadeManager:off()
	self._openActivity = false
	self._gmOpenTime = 0
	self._deathTime = {}
	local joinUserCount = 0
	self:sendErrMsg2Client(0, INVADE_ERR_ACTIVITY_CLOSE, 0)
	for monsterID, _ in pairs(self._monsterInfo) do
		g_entityMgr:destoryEntity(monsterID)
		self:removeMonsterInfo(monsterID)
	end
	for roleSID, _ in pairs(self._factionAreaUser) do
		self._factionAreaUser[roleSID] = self._openActivity
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local buffmgr = player:getBuffMgr()
			if buffmgr then
				buffmgr:delBuff(INVADE_BUFF_ID)
			end
		end
	end
	--发放奖励
	for factionID, invadeInfo in pairs(self._invadeInfo) do
		local totalIntegral = invadeInfo:getTotalIntegral()
		local dropID = self:getDropID(totalIntegral)
		if dropID and dropID ~= 0 then
			local joinUser = invadeInfo:getJoinUser()
			for i = 1, #joinUser do
				joinUserCount = joinUserCount + 1
				local roleSID = joinUser[i]
				local player = g_entityMgr:getPlayerBySID(roleSID)
				if player then
					local roleID = player:getID()
					self:setUserDropID(roleID, dropID)
					g_commonMgr:setInvadeDropID(roleID, dropID)
				else
					local reward = self:getRewardByDropID(dropID)
					if table.size(reward) > 0 then
						local offlineMgr = g_entityMgr:getOfflineMgr()
						local email = offlineMgr:createEamil()
						email:setDescId(INVADE_EMAIL_ID)
						for _, item in pairs(reward) do
							if item.bind == 0 then
								item.bind = false
							end
							email:insertProto(item.itemID, item.count, item.bind, item.strength)
						end
						offlineMgr:recvEamil(roleSID, email, 205, 0)
					end
				end
			end
		end
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			local count1, count2, count3, count4 = invadeInfo:getMonsterNum1(), invadeInfo:getMonsterNum2(), invadeInfo:getMonsterNum3(), invadeInfo:getMonsterNum4()
			g_tlogMgr:TlogSZRQFlow(factionID, faction:getName(), (count1 + count2 + count3 + count4), totalIntegral, count1, count2, count3, count4, joinUserCount, self._deathCount)
		end
		invadeInfo:setPushDataFlag(true)
		invadeInfo:pushAllUserData()
		invadeInfo:setTotalIntegral(0)
		invadeInfo:setMonsterNum1(0)
		invadeInfo:setMonsterNum2(0)
		invadeInfo:setMonsterNum3(0)
		invadeInfo:setMonsterNum4(0)
		invadeInfo:setHasMonster3(false)
		invadeInfo:setNumMonster4(0)
	end
	self._deathCount = 0
end

function InvadeManager:onMonsterKill(monSID, roleID, monId, mapID)
	if mapID == FACTION_AREA_MAP_ID then
		local monster = g_entityMgr:getMonster(monId)
		if monster then
			self:removeMonsterInfo(monId)
			local factionID = monster:getOwnCopyID()
			if factionID <= 0 then return end
			self:addDeathTime(factionID, monSID)
			local invadeInfo = self:getInvadeInfo(factionID)
			local player = g_entityMgr:getPlayer(roleID)
			if invadeInfo and player then
				if player:getFactionID() == factionID then
					invadeInfo:addJoinUser(player:getSerialID())
				end
				local monsterConfig = self:getMonsterConfig(monSID)
				if monsterConfig then
					local monsterType = monsterConfig.type
					if monsterType == INVADE_MONSTER_TYPE.MONSTER1 then
						invadeInfo:setMonsterNum1(invadeInfo:getMonsterNum1() + 1)
					elseif monsterType == INVADE_MONSTER_TYPE.MONSTER2 then
						invadeInfo:setMonsterNum2(invadeInfo:getMonsterNum2() + 1)
					elseif monsterType == INVADE_MONSTER_TYPE.MONSTER3 then
						invadeInfo:setMonsterNum3(invadeInfo:getMonsterNum3() + 1)
					elseif monsterType == INVADE_MONSTER_TYPE.MONSTER4 then
						invadeInfo:setMonsterNum4(invadeInfo:getMonsterNum4() + 1)
					end
					local integral = monsterConfig.integral or 0
					if integral > 0 and player:getFactionID() == factionID and not player:hasEffectState(EXIT_FACTION_SPECIAL) then
						invadeInfo:setTotalIntegral(invadeInfo:getTotalIntegral() + integral)
						invadeInfo:setPushDataFlag(true)
					end
					local abs = self:getMonsterAbs(factionID)
					if not invadeInfo:getHasMonster3() and abs >= INVADE_REFRESH_MONSTER3 then
						invadeInfo:setHasMonster3(true)
						invadeInfo:sendErrMsg2JoinUser(INVADE_ERR_REFRESH_MONSTER3)
						self:initMonster(INVADE_MONSTER_TYPE.MONSTER3, factionID)
					end
					local monsterCount = math.floor((invadeInfo:getMonsterNum1() + invadeInfo:getMonsterNum2()) / INVADE_REFRESH_MONSTER4)
					if invadeInfo:getNumMonster4() < monsterCount then
						invadeInfo:setNumMonster4(invadeInfo:getNumMonster4() + 1)
						invadeInfo:sendErrMsg2JoinUser(INVADE_ERR_REFRESH_MONSTER4)
						self:initMonster(INVADE_MONSTER_TYPE.MONSTER4, factionID)
					end
				end
			end
		end
	end
end

--进入行会据点
function InvadeManager:enterFactionArea(roleSID)
	self._factionAreaUser[roleSID] = self._openActivity
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local roleID = player:getID()
	if self._openActivity then
		self._delayBuff[roleSID] = os.time()
	end
	local factionID = player:getFactionID()
	if factionID <= 0 then return end
	local invadeInfo = self:getInvadeInfo(factionID)
	if invadeInfo then
		invadeInfo:addAreaUser(roleSID)
		invadeInfo:setPushDataFlag(true)
	end
end

--离开行会据点
function InvadeManager:outFactionArea(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if self._factionAreaUser[roleSID] then
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:delBuff(INVADE_BUFF_ID)
		end
	end
	self._factionAreaUser[roleSID] = nil
	local factionID = player:getFactionID()
	if factionID <= 0 then return end
	local invadeInfo = self:getInvadeInfo(factionID)
	if invadeInfo then
		invadeInfo:removeAreaUser(roleSID)
	end
end

--玩家上线
function InvadeManager:onPlayerLoaded(player)
	local mapID = player:getMapID()
	if mapID ~= FACTION_AREA_MAP_ID and self._factionAreaUser[roleSID] then
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:delBuff(INVADE_BUFF_ID)
		end
	end
end

function InvadeManager:onPlayerDied(player, killerID)
	if self._openActivity then
		self._deathCount = self._deathCount + 1
	end
end

--玩家复活
function InvadeManager:onPlayerRelive(player)
	local mapID = player:getMapID()
	if mapID == FACTION_AREA_MAP_ID and self._openActivity then
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:addBuff(INVADE_BUFF_ID, 0)
		end
	end
end

--切换场景
function InvadeManager:onSwitchScene(player, mapID)
	local roleSID = player:getSerialID()
	if mapID ~= FACTION_AREA_MAP_ID and self._factionAreaUser[roleSID] then
		local buffmgr = player:getBuffMgr()
		if buffmgr then
			buffmgr:delBuff(INVADE_BUFF_ID)
		end
		self._factionAreaUser[roleSID] = nil
	end
end

--退出行会
function InvadeManager:quitFaction(factionID, roleSID)
	local invadeInfo = self:getInvadeInfo(factionID)
	if invadeInfo then
		invadeInfo:removeJoinUser(roleSID)
		invadeInfo:removeAreaUser(roleSID)
	end
end

--创建山贼入侵行会数据
function InvadeManager:createInvade(factionID)
	self._invadeInfo[factionID] = InvadeInfo(factionID)
	if self._openActivity then
		self:initMonster(INVADE_MONSTER_TYPE.MONSTER1, factionID)
		self:initMonster(INVADE_MONSTER_TYPE.MONSTER2, factionID)
	end
end

--创建初始的怪物
function InvadeManager:initMonster(type, factionID)
	local configID = self:getConfigIDByType(type)
	if configID then
		local monsterConfig = self:getMonsterConfig(configID)
		if monsterConfig then
			local monsterID = monsterConfig.id
			for i = 1, monsterConfig.num do
				self:refreshMonster(monsterID, factionID)
			end
		end
	end
end

--刷新怪物
function InvadeManager:refreshMonster(monsterID, factionID)
	local x, y = self:getPosition(monsterID)
	local invadeInfo = self:getInvadeInfo(factionID)
	if (x == -1 and y == -1) or not invadeInfo then
		return
	end
	local monster = g_entityMgr:getFactory():createMonster(monsterID)	
	local scene = g_sceneMgr:getFacAreaScene(factionID)
	if monster and scene then
		monster:freshenByPos(scene, x, y, 5)
		monster:setOwnCopyID(factionID)
		scene:addMonster(monster)
		self:addMonsterInfo(monster:getID())
		monster:changeAIRule(0)
	end
end

--随机怪物配置出生坐标
function InvadeManager:getPosition(monsterID)
	local monsterConfig = self:getMonsterConfig(monsterID)
	local positions = unserialize(monsterConfig.position)
	local size = table.size(positions)
	local random = math.random(1, size)
	local position = positions[random]
	if position then
		return position[1], position[2]
	end
	return -1, -1
end

function InvadeManager:getMonsterConfig(monsterId)
	return self._monsterConfig[monsterId]
end

function InvadeManager:getConfigIDByType(monsterType)
	for configID, monsterConfig in pairs(self._monsterConfig) do
		if monsterConfig.type == monsterType then
			return configID
		end
	end
end

function InvadeManager:getRefreshTime(monsterId)
	local monsterConfig = self:getMonsterConfig(monsterId)
	if monsterConfig then
		return monsterConfig.time
	end
	return 0
end

function InvadeManager:addMonsterInfo(monsterID)
	self._monsterInfo[monsterID] = true
end

function InvadeManager:removeMonsterInfo(monsterID)
	self._monsterInfo[monsterID] = nil
end

function InvadeManager:getInvadeInfo(factionID)
	return self._invadeInfo[factionID]
end

function InvadeManager:addDeathTime(factionID, monsterId)
	if self:getRefreshTime(monsterId) <= 0 then
		return
	end
	if not self._deathTime[factionID] then
		self._deathTime[factionID] = {}
		for id, _ in pairs(self._monsterConfig) do
			self._deathTime[factionID][id] = {}
		end
	end
	local now = os.time()
	if not self._deathTime[factionID][monsterId][now] then
		self._deathTime[factionID][monsterId][now] = 1
	else
		--同一时刻多个怪被击杀
		self._deathTime[factionID][monsterId][now] = self._deathTime[factionID][monsterId][now] + 1
	end
end

function InvadeManager:removeDeathTime(factionID, monsterId, time)
	if self._deathTime[factionID][monsterId] then
		self._deathTime[factionID][monsterId][time] = nil
	end
end

function InvadeManager:update()
	local now = os.time()
	for roleSID, t in pairs(self._delayBuff) do
		if now - t > 5 then
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player then
				local buffmgr = player:getBuffMgr()
				if buffmgr then
					buffmgr:addBuff(INVADE_BUFF_ID, 0)
				end
			end
			self._delayBuff[roleSID] = nil
		end
	end
	for factionID, factionDeathTime in pairs(self._deathTime) do
		for monsterId, deathTime in pairs(factionDeathTime or {}) do
			for time, num in pairs(deathTime or {}) do
				local monsterConfig = self:getMonsterConfig(monsterId)
				local freshTime = monsterConfig.time
				local monsterType = monsterConfig.type
				if freshTime >= 0 then
					local abs = 0
					if monsterType == INVADE_MONSTER_TYPE.MONSTER3 then
						abs = self:getMonsterAbs(factionID)
					end
					if now - time >= freshTime and ((monsterType == INVADE_MONSTER_TYPE.MONSTER1 or monsterType == INVADE_MONSTER_TYPE.MONSTER2) or
					monsterType == INVADE_MONSTER_TYPE.MONSTER3 and abs >= INVADE_REFRESH_MONSTER3) then
						if monsterType == INVADE_MONSTER_TYPE.MONSTER3 then
							local invadeInfo = self:getInvadeInfo(factionID)
							if invadeInfo then
								invadeInfo:sendErrMsg2JoinUser(INVADE_ERR_REFRESH_MONSTER3)
							end
						end
						for i = 1, num do
							self:refreshMonster(monsterId, factionID)
						end
						self:removeDeathTime(factionID, monsterId, time)
					end
				else
					self:removeDeathTime(factionID, monsterId, time)
				end
			end
		end
	end
	if self._openActivity then
		for _, invadeInfo in pairs(self._invadeInfo) do
			invadeInfo:pushAllUserData()
		end
	end
end

--获取某行会据点被击杀的响马贼跟纵火贼的差值
function InvadeManager:getMonsterAbs(factionID)
	local invadeInfo = self:getInvadeInfo(factionID)
	if invadeInfo then
		return math.abs(invadeInfo:getMonsterNum1() - invadeInfo:getMonsterNum2())
	end
	return 0
end

function InvadeManager:canJoin(player)
	local factionID = player:getFactionID()
	if factionID > 0 then
		local faction = g_factionMgr:getFaction(factionID)
		if faction then
			return faction:getLevel() >= FACTION_AREA_NEED_LEVEL
		end
	end
	return false
end

function InvadeManager:setEndTime(time)
	self._endTime = time
end

--获取剩余时间
function InvadeManager:getSurplusTime()
	if self._openActivity then
		if self._gmOpenTime > 0 then
			return math.max(self._gmOpenTime + 3600 - os.time(), 0)
		else
			return math.max(self._endTime - os.time(), 0)
		end
	else
		return 0
	end
end

--根据积分获取此积分对应的掉落ID
function InvadeManager:getDropID(integral)
	local finalIntegral = 0
	for point, _ in pairs(INVADE_INTEGRAL) do
		if point <= integral and point > finalIntegral then
			finalIntegral = point
		end
	end
	return INVADE_INTEGRAL[finalIntegral] or 0
end

--获取下一个奖励分数
function InvadeManager:getNextIntegral(integral)
	local integrals = {}
	for point, _ in pairs(INVADE_INTEGRAL) do
		table.insert(integrals, point)
	end
	table.sort(integrals)
	for i = 1, #integrals do
		if integrals[i] > integral or i == #integrals then
			return integrals[i]
		end
	end
end

function InvadeManager:getRewardByDropID(dropID)
	local dropItem, reward = dropString(0, 0, dropID), {}
	for _, item in pairs(dropItem) do
		local tmp = {
			itemID = item.itemID,
			count = item.count,
			bind = item.bind,
			strength = item.strength,
		}
		table.insert(reward, tmp)
	end
	return reward
end

--玩家是否有山贼入侵奖励
function InvadeManager.invadeState(roleID)
	local state = 1 	--活动进行中
	if not g_InvadeMgr._openActivity then
		local dropID = g_InvadeMgr:getUserDropID(roleID)
		if dropID and dropID ~= 0 then
			state = 2 	--有奖励可领取
		else
			state = 3 	--无奖励可领取
		end
	end
	fireProtoMessage(roleID, INVADE_SC_HAS_REWARD, "InvadeHasReward", {state = state})
end

function InvadeManager:setUserDropID(roleID, dropID)
	self._userDropID[roleID] = dropID
end

function InvadeManager:getUserDropID(roleID)
	return self._userDropID[roleID] or 0
end

function InvadeManager:loadDBData(roleID, dropID)
	self:setUserDropID(roleID, dropID)
end

function InvadeManager:sendErrMsg2Client(roleID, errId, paramCount, params)
	if roleID == 0 then
		local ret = {}
		ret.eventId = EVENT_INVADE_SETS
		ret.eCode = errId
		ret.mesId = 0
		ret.param = {}
		paramCount = paramCount or 0
		for i=1, paramCount do
			table.insert(ret.param, params[i] and tostring(params[i]) or "")
		end
		boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	else
		fireProtoSysMessage(0, roleID, EVENT_INVADE_SETS, errId, paramCount, params)
	end
end

function InvadeManager.getInstance()
	return InvadeManager()
end

g_InvadeMgr = InvadeManager.getInstance()