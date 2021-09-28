--FactionCopyBook.lua
--副本基类

FactionCopyBook = class(nil)

local prop = Property(FactionCopyBook)
prop:accessor("currInsId", 0)		--实例Id
prop:accessor("killBossRoleSID", 0)		--最后一击BOSS的玩家
prop:accessor("hasBoss", false)		--是否已经刷新BOSS
prop:accessor("bossDie", false)		--BOSS是否死亡
prop:accessor("starTime", 0)		--开始时间
---------------------------------------

function FactionCopyBook:__init(factionID, copyID)
	self._copyID = copyID
	self._factionID = factionID
	self._monster = nil
	self._startTime = os.time()
	self._joinPlayerInfo = {}

	--行会副本定时开启
	--local hasOver = false
	--local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	--local totalTime = tonumber(proto.totalTime) or FACTIONCOPY_TOTAL_TIME
	--self._outTimeStamp = self._startTime + totalTime + FACTIONCOPY_OUT_TIME
	self._outTimeStamp = self:getCopyCloseTime()
	self.hasOver = false

	self._notify = {}
	self._prizeNotify = {}
	self._scene = nil
	self._addTime = 0
end

function FactionCopyBook:__release()
	self._protoID = nil
	self._copyID = nil
	self._factionID = nil
	self._startTime = nil
	self._remainTime = nil
	self._notify = {}
	self._prizeNotify = {}
	self:_close()
	self._monster = nil
	self._scene = nil
	self._addTime = 0
end

function FactionCopyBook:getStartTime()
	return self._startTime
end

function FactionCopyBook:getPlayerID()
	return self._playerID
end

function FactionCopyBook:getFactionID()
	return self._factionID
end

function FactionCopyBook:getCopyID()
	return self._copyID
end

function FactionCopyBook:getAddTime()
	return self._addTime
end

function FactionCopyBook:doReward()
end

function FactionCopyBook:createBookScene()
	local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	local mapID = tonumber(proto.mapID)
	local scene = g_sceneMgr:createCopyScene(self:getCurrInsId(), mapID)
	if scene then
		scene:setManorWarID(mapID)	--虽然不是领地战，但是可以用下这个接口复活
		self._scene = scene
		return true
	else
		return false
	end
end

function FactionCopyBook:getPlayerInfo(roleSID)
	for _,info in pairs(self._joinPlayerInfo) do
		if roleSID == info.roleSID then
			return info
		end
	end
end

function FactionCopyBook:addPlayer(roleSID)
	if not self:getPlayerInfo(roleSID) then
		local player = g_entityMgr:getPlayerBySID(roleSID)
		local name = player:getName()
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if faction then
			local mem = faction:getMember(roleSID)
			if mem then
				table.insert(self._joinPlayerInfo, {roleSID = player:getSerialID(), name = name, hurt = 0, level = player:getLevel(), vipLevel = 0, job = player:getSchool(), factionPos = mem:getPosition()})
				return
			end
		end

		table.insert(self._joinPlayerInfo, {roleSID = player:getSerialID(), name = name, hurt = 0, level = player:getLevel(), vipLevel = 0, job = player:getSchool(), factionPos = 0})
	end
end

--BOSS刷新
function FactionCopyBook:freshBoss()
	if not self:getHasBoss() then
		local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
		local bossFreshTime = tonumber(proto.bossFreshTime) or FACTIONCOPY_BOSS_TIME
		--if (os.time() - self._startTime) > bossFreshTime then
		local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
		local monsterID = tonumber(proto.monsterID)
		local monsterFreshID = tonumber(proto.monsterFreshID)
		local mapX = 0
		local mapY = 0
		mapX,mapY = g_FactionCopyMgr:getMonsterInfoPos(monsterFreshID)
		local mon = g_entityMgr:getFactory():createMonster(monsterID)	
		local scene = g_sceneMgr:getCopyScene(self:getCurrInsId(), tonumber(proto.mapID))
		if mon and scene:addMonsterInfoByID(mon, monsterFreshID) then
			if scene:attachEntity(mon:getID(), mapX, mapY) then
				scene:addMonster(mon)
				self._monster = mon
				self:setHasBoss(true)
				mon:setOwnCopyID(self:getCurrInsId())
			end
		end
		
		--刷新小怪
		local qmonsters = proto.q_monster
		--print("FactionCopyBook:freshBoss qmonsters",qmonsters)
		if qmonsters then
			--qmonsters = '{' ..qmonsters .. '}'
			qmonsters = string.gsub(qmonsters, '%[', '%{')
			qmonsters = string.gsub(qmonsters, '%]', '%}')
			qmonsters = unserialize(qmonsters)
			if #qmonsters == 5 then
				local qmonid = qmonsters[1]
				local qmonnum = qmonsters[2]
				local qmonx = qmonsters[3]
				local qmony = qmonsters[4]
				local qmonrange = math.ceil(qmonsters[5]/2)
				local qmonrad = math.ceil(qmonrange/2)
				for i=1, qmonnum do
					local posx = qmonx + math.random(qmonrange) - qmonrad
					local posy = qmony + math.random(qmonrange) - qmonrad
					local mon = g_entityMgr:getFactory():createMonster(qmonid)
					if mon and scene:addCopyMonsterInfo(mon, qmonid) then
						if scene:attachEntity(mon:getID(), posx, posy) then
							scene:addMonster(mon)
						end
					end
				end
			end
		end
		
		--通知所有帮会成功BOSS刷新了
		local monster = g_configMgr:getMonster(tonumber(proto.monsterID))
		local monsterName = tostring(monster.name)
		local faction = g_factionMgr:getFaction(self._factionID)
		if faction then
			local allMems = faction:getAllMembers()
			for roleSID, mem in pairs(allMems) do
				local player = g_entityMgr:getPlayerBySID(roleSID)
				if player then
					fireProtoSysMessage(g_FactionCopyServlet:getCurEventID(), player:getID(), EVENT_FACTIONCOPY_SET, FACTIONCOPY_ERR_BOSS_HAS_FRESH, 1, {monsterName})
				end
			end
		end

		g_factionMgr:notifyAllMemByEmail(self._factionID, FactionHD.FACTION_BOSS_OPEN)

		--else
		--	--刷新BOSS时间通知
		--	self:notifyMessage(self._startTime + bossFreshTime - os.time())
		--end
	end
end

--刷新BOSS时间通知
function FactionCopyBook:notifyMessage(bossFreshLeftTime)
	local notifyindex = table.getn(self._notify) + 1
	local notifytime = FACTIONCOPY_NOTIFY_TIME[notifyindex]
	if notifytime ~= nil and notifytime >= bossFreshLeftTime then
		local message = string.format(apiEntry.getStrByKey("factioncopy_open_notify"),notifytime)
		--通知所有在线行会玩家活动即将开始
		local retBuff = g_ChatSystem:getComMsgBuffer(0, "", 0, message, Channel_ID_System, false, "", 0, 0, {})
		g_factionMgr:send2AllMem(self._factionID, retBuff)
		table.insert(self._notify,notifytime)
	end
end

--检查活动时间是否到了
function FactionCopyBook:checkTimeOver()
	local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	--local totalTime = tonumber(proto.totalTime) or FACTIONCOPY_TOTAL_TIME
	--if (os.time() - self._startTime) > totalTime and not self.hasOver then
	
	if(not self.hasOver and self._outTimeStamp > os.time() and (self._outTimeStamp - os.time()) <= FACTIONCOPY_OUT_TIME) then
		self:copyOver()

		--删除BOSS addMonster(mon)相对应
		if self._scene then
			self._scene:releaseAllMonsters()
		end
	end
end

--检查活动时间是否到了
function FactionCopyBook:checkOutTime()
	if os.time() > self._outTimeStamp then
		for _,info in pairs(self._joinPlayerInfo) do
			local roleSID = info.roleSID
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player and player:getCopyID() > 0 then
				g_FactionCopyMgr:sendOut(roleSID)
			end
		end
		g_FactionCopyMgr:finishCopy(self:getCurrInsId())
	end
end

--玩家复活
function FactionCopyBook:onPlayerRelive(player)
	if not self.hasOver and self._monster ~= nil then
		local pos = self._monster:getPosition()
		fireProtoSysMessage(g_FactionCopyServlet:getCurEventID(), player:getID(), EVENT_FACTIONCOPY_SET, FACTIONCOPY_ERR_PLAYER_RELIVE, 2, {pos.x, pos.y})
	end
end

--BOSS死亡处理
function FactionCopyBook:bossKilled(roleSID)
	self:setKillBossRoleSID(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	self._monster:setOwnerID(player:getID())
	self:freshRank()	--BOSS死的时候应该立即更新一次排名
	self:setBossDie(true)
	if not self.hasOver then
		self:copyOver()
	end
	self._outTimeStamp = os.time() + FACTIONCOPY_OUT_TIME
	
	--local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	--local totalTime = tonumber(proto.totalTime) or FACTIONCOPY_TOTAL_TIME
	--self._addTime = totalTime - (os.time() - self:getStartTime())

	local faction = g_factionMgr:getFaction(self._factionID)
	if faction then
		local allMems = faction:getAllMembers()
		for roleSID, mem in pairs(allMems) do
			local mPlayer = g_entityMgr:getPlayerBySID(roleSID)
			if mPlayer then
				fireProtoSysMessage(g_FactionCopyServlet:getCurEventID(), mPlayer:getID(), EVENT_FACTIONCOPY_SET, FACTIONCOPY_ERR_LAST_HIT, 1, {player:getName()})
			end
		end
	end
end

--副本结束处理
function FactionCopyBook:copyOver()
	self:dealReard()
	self.hasOver = true
	--通知还在地图里的人活动结束了，1分钟后就传送出去
	for _,info in pairs(self._joinPlayerInfo) do
		local roleSID = info.roleSID
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player and player:getCopyID() > 0 then
			fireProtoSysMessage(g_FactionCopyServlet:getCurEventID(), player:getID(), EVENT_FACTIONCOPY_SET, FACTIONCOPY_ERR_COPY_OVER_TIP, 1, {60})
		end
	end

	--通知行会的所有玩家活动结束
	local faction = g_factionMgr:getFaction(self._factionID)
	if faction then
		local allMems = faction:getAllMembers()
		for roleSID, mem in pairs(allMems) do
			local mPlayer = g_entityMgr:getPlayerBySID(roleSID)
			if mPlayer then
				fireProtoSysMessage(g_FactionCopyServlet:getCurEventID(), mPlayer:getID(), EVENT_FACTIONCOPY_SET, FACTIONCOPY_ERR_COPY_OVER_ALL, 0)
			end
		end
	end
	
	for _,info in pairs(self._joinPlayerInfo) do
		local ret = {}
		ret.outTime = FACTIONCOPY_OUT_TIME

		local roleSID = info.roleSID
		--通知发奖
		if table.contains(self._prizeNotify, roleSID) then
			ret.prize = 1
		else
			ret.prize = 0
		end

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player and player:getCopyID() > 0 then
			fireProtoMessage(player:getID(), FACTIONCOPY_SC_OVER, "FactionCopyOver", ret)
		end
	end

	--tlog行会BOSS流水
	local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	if faction and proto then
		local killTime = 0
		if self:getBossDie() then
			killTime = os.time() - self._startTime
		end
		local maxHp = 0
		local name = ''
		if self._monster then
			maxHp = self._monster:getMaxHP()
			name = self._monster:getName()
		end
		local enterCount, attackCount = self:getTlogCounts()
		g_tlogMgr:TlogFactionBossFlow(self._startTime, 1, tonumber(proto.monsterID), name, tonumber(proto.mapID), maxHp, self._factionID, faction:getName(), faction:getLevel(), killTime, table.size(faction:getAllMembers()), 
			enterCount, attackCount)
	end
end

--获取进入人数 和 击杀人数
function FactionCopyBook:getTlogCounts()
	local enterCount = 0
	local attackCount = 0
	for _,info in pairs(self._joinPlayerInfo) do
		enterCount = enterCount + 1
		if info.hurt > 0 then
			attackCount = attackCount + 1
		end
	end
	return enterCount, attackCount
end

--奖励处理
function FactionCopyBook:dealReard()
	local proto = g_LuaFactionCopyDAO:getProto(self._copyID)
	local joinReward = tonumber(proto.joinReward)
	local rankReward = unserialize(proto.rankReward)
	local lastKillReward = tonumber(proto.lastKillReward)
	
	--先排名
	--local sortBossHurt = a.hurt > b.hurt
	table.sort(self._joinPlayerInfo, sortBossHurt)

	for rank,info in pairs(self._joinPlayerInfo) do
		local roleSID = info.roleSID
		--处理排名奖励
		local dropId = 0
		dropId = rankReward[rank]
		if dropId and dropId > 0 then
			g_entityMgr:dropItemToEmail(roleSID, dropId, FACTIONCOPY_REWARD_EMAIL_COFIG2,107, 0, true, tostring(rank))
			
			--通知奖励发放
			table.insert(self._prizeNotify,roleSID)
		end
	end
--[[
	--最后一击奖励
	if self:getKillBossRoleSID() > 0 then
		g_entityMgr:dropItemToEmail(self:getKillBossRoleSID(), lastKillReward, FACTIONCOPY_REWARD_EMAIL_COFIG3, 0, true)
	end
	]]
end

--BOSS伤害处理
function FactionCopyBook:bossHurted(roleSID, hurt)
	local info = self:getPlayerInfo(roleSID)

	if not info then
		return
	end

	info.hurt = info.hurt + hurt

	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.hurtFactionBoss)
end

--刷新伤害排名
function FactionCopyBook:freshRank()
	table.sort(self._joinPlayerInfo, sortBossHurt)

	local notifyrole = {}
	local size = table.size(self._joinPlayerInfo)
	for rank = 1, size do
		local playerInfo = self._joinPlayerInfo[rank]
		local player = g_entityMgr:getPlayerBySID(playerInfo.roleSID)
		if player and player:getCopyID() > 0 then					
			local roleID = player:getID()
			local ret = {}
			ret.rank = rank
			ret.hurt = playerInfo.hurt
			fireProtoMessage(roleID, FACTIONCOPY_SC_FRESH_RANK, "FactionCopyFreshRank", ret)
			table.insert(notifyrole,roleID)
		end
	end
	
	for i=1, #notifyrole do
		self:getAllRank(notifyrole[i],true)
	end
end

--获取全部排行
function FactionCopyBook:getAllRank(roleID, sorted)
	if sorted ~= true then
		table.sort(self._joinPlayerInfo, sortBossHurt)
	end

	local size = table.size(self._joinPlayerInfo)
	local recordSize = size > FACTIONCOPY_RANK_NUM and FACTIONCOPY_RANK_NUM or size
	local player = g_entityMgr:getPlayer(roleID)
	if player then					
		local roleID = player:getID()
		local ret = {}
		ret.infos = {}
		for rk = 1, recordSize do
			local rankinfo = {}
			rankinfo.name = self._joinPlayerInfo[rk].name
			rankinfo.lv = self._joinPlayerInfo[rk].level
			rankinfo.viplv = self._joinPlayerInfo[rk].vipLevel
			rankinfo.job = self._joinPlayerInfo[rk].job
			rankinfo.position = self._joinPlayerInfo[rk].factionPos
			rankinfo.hurt = self._joinPlayerInfo[rk].hurt
			table.insert(ret.infos, rankinfo)
		end
		fireProtoMessage(roleID, FACTIONCOPY_SC_GET_ALL_RANK_RET, "FactionCopyAllRankRet", ret)
	end
end

--副本关闭场景
function FactionCopyBook:_close()
	if self._scene then
		self._scene:releaseAllMonsters()
		g_sceneMgr:releaseScene(self._scene, self:getCurrInsId())
	end
end

--处理定时事件
function FactionCopyBook:dealTimeEvent()
	self:freshRank()
	self:freshBoss()
	self:checkTimeOver()
	self:checkOutTime()
end

-----------------------------------------------------------------行会副本定时开启------------------------------------------------------------
--副本开启时 获取副本关闭时间
function FactionCopyBook:getCopyCloseTime()
	local now = os.time()
	local now_date = os.date("*t", now)
 	local sectime = os.time({year=now_date.year, month=now_date.month, day=now_date.day, hour=FACTIONCOPY_CLOSE_HOUR})
	if sectime < now then
		sectime = sectime + FACTIONCOPY_OPEN_NEXTDAY
	end

	--print('FactionCopyBook:getCopyCloseTime',now_date.year,now_date.month,now_date.day,now_date.hour,now_date.min,now_date.sec,sectime,now)
	return sectime
end