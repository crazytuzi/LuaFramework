--WorldBossManager.lua
--/*-----------------------------------------------------------------
--* Module:  WorldBossManager.lua
--* Author:  HE Ningxu 
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class WorldBossManager
-------------------------------------------------------------------*/

require ("system.worldboss.WorldBossServlet")
require ("system.worldboss.WorldBossReader")
require ("system.worldboss.WorldBossConstant")

WorldBossManager = class(nil, Singleton, Timer)

function WorldBossManager:__init()
	self._BossHurt = {}	
	self._hurtTime =os.time()
	
	self._BossRecordInfo = {} 				--世界boss的一些记录 弱化等使用

	loadWorldBossDB()
	self._bossMap = WorldBossTable 			--所有的boss信息  live=0 死亡，live=1 活着
	self._bossMapChange = WorldBossChange 	--[6052] = 6007 	[BOSS第二层静态ID] = boss第一层静态ID
	self._bossReliveInfo = {} 				--记录世界boss的存活情况并存数据库  live = 1 死亡，live = 2 活着
	self._bossDID = {} 						--[boss静态ID] = boss当前动态ID 第一层和第二层动态ID相同

	self._monID = {} 						--经过对self._bossMap排序之后  仅用于发送给客户端的数据
	self._count = 0 						--世界boss个数
	
	self._FieldBoss = FieldBossInfo			--记录野外boss击杀信息	20150703

	self:bossInit()
	self:initBossReliveInfo()

	self._BossAttack = {}   				--记录攻击过世界boss的玩家 用于成就记录
	self._achieveBossInfo = {} 				--当boss有两层 记录有哪些角色在第一层时已经达成成就

	self._ActivityName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.WORLD_BOSS)

	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 3000)
	print("WorldBossManager Timer ID: ", self._timerID_)
end

function loadBossRecordInfo()
	--[[local params = {
		{
			spName = "sp_loadbossinfo",
			dataBase = 1,
		}
	}
	LuaDBAccess.callDB(params, onLoadBossRecordInfo)]]
	g_entityDao:loadBossInfo()
end

function onLoadBossRecordInfo(modelId,mapId,event,evtTime,evtValue1)
	local index = string.format("%d:%d:%d", modelId,mapId,event)
	local info = {}
	info['evtValue1'] = evtValue1
	info['evtTime'] = evtTime
	g_WorldBossMgr._BossRecordInfo[index] = info
end

function WorldBossManager:initBossReliveInfo()
	for i,v in pairs(WorldBossTable or {}) do
		if v.monID and v.monID2 then
			if not self._bossReliveInfo[v.monID] then
				self._bossReliveInfo[v.monID] = {}				
			end
			self._bossReliveInfo[v.monID].type = 1 				--boss第一层
			self._bossReliveInfo[v.monID].live = 1 				--1代表死亡 2代表复活
			self._bossReliveInfo[v.monID].mapID = v.mapID 		--boss所在的地图
			self._bossReliveInfo[v.monID].preMID = 0 			--boss上一层的怪物ID
			self._bossReliveInfo[v.monID].nextMID = 0 			--boss下一层的怪物ID

			if v.monID ~= v.monID2 then
				self._bossReliveInfo[v.monID].nextMID = v.monID2

				if not self._bossReliveInfo[v.monID2] then
					self._bossReliveInfo[v.monID2] = {}					
				end
				self._bossReliveInfo[v.monID2].type = 2
				self._bossReliveInfo[v.monID2].live = 1
				self._bossReliveInfo[v.monID2].mapID = v.mapID
				self._bossReliveInfo[v.monID2].preMID = v.monID
				self._bossReliveInfo[v.monID2].nextMID = 0
			end
		end
	end
end

function WorldBossManager:updateBossRecordInfo(monster, evtId, evtValue1)
	local nowTime = os.time()
	local nowDate = os.date("*t",nowTime)
	local evtDate = string.format("%d-%d-%d %d:%d:%d",
		nowDate.year,nowDate.month,nowDate.day,
		nowDate.hour,nowDate.min,nowDate.sec)
	local index = string.format("%d:%d:%d", monster:getSerialID(),monster:getMapID(),evtId)
	local info = {}
	info['evtValue1'] = evtValue1
	info['evtTime'] = evtDate
	self._BossRecordInfo[index] = info
	--[[local params =
	{
		{
		ModelId = monster:getSerialID(),
		MapId  = monster:getMapID(),
		Event  = evtId,
		EvtTime = evtDate,
		EvtValue1 = evtValue1,
		dataBase = 1,
		spName = "sp_updatebossinfo",
		sort="ModelId,MapId,Event,EvtTime,EvtValue1",
		}
	}]]		
	--local operationID = apiEntry.exeSP(params, true)
	g_entityDao:updateBossInfo(monster:getSerialID(),monster:getMapID(),evtId,evtDate,evtValue1)
end

function strtime2time(strtime)
	local nowTime = os.time()
	local nowDate = os.date("*t",nowTime)
	v = string.split1(strtime, ' ')
	v1 = string.split1(v[1], '-')
	v2 = string.split1(v[2], ':')
	year = tonumber(v1[1])
	month = tonumber(v1[2])
	day = tonumber(v1[3])
	hour = tonumber(v2[1])
	_min = tonumber(v2[2])
	sec = tonumber(v2[3])
	local t = {}
	t.year = year
	t.month = month
	t.day = day
	t.hour = hour
	t.min = _min
	t.sec = sec
	t.isdst = nowDate.isdst
	return t
end

function WorldBossManager.IncRuoHuaCount(ID)
	local monster = g_entityMgr:getMonster(ID)
	if monster then
		local count = 0
		local index = string.format("%d:%d:%d", monster:getSerialID(),monster:getMapID(),3)
		if g_WorldBossMgr._BossRecordInfo[index] then
			count = g_WorldBossMgr._BossRecordInfo[index]['evtValue1']
		end
		g_WorldBossMgr:updateBossRecordInfo(monster, 3, count + 1)
	end
	return 0
end

function WorldBossManager.GetZengQiangCount(ID)
	local monster = g_entityMgr:getMonster(ID)
	if monster then
		local index = string.format("%d:%d:%d", monster:getSerialID(),monster:getMapID(),2)
		if not g_WorldBossMgr._BossRecordInfo[index] then
			return 0
		end
		--local _lastTime = strtime2time(g_WorldBossMgr._BossRecordInfo[index]['evtTime'])
		--local lastTime = os.time(_lastTime)
		--local nowTime = os.time()
		--if nowTime > lastTime and nowTime - lastTime <= 24 * 3600 then
			return g_WorldBossMgr._BossRecordInfo[index]['evtValue1']
		--end
		--return -1
	end
	return 0
end

function WorldBossManager.GetRuoHuaCount(ID)
	local monster = g_entityMgr:getMonster(ID)
	if monster then
		local index = string.format("%d:%d:%d", monster:getSerialID(),monster:getMapID(),3)
		if not g_WorldBossMgr._BossRecordInfo[index] then
			return 0
		end
		--local _lastTime = strtime2time(g_WorldBossMgr._BossRecordInfo[index]['evtTime'])
		--local lastTime = os.time(_lastTime)
		--local nowTime = os.time()
		--if nowTime > lastTime and nowTime - lastTime <= 24 * 3600 then
			return g_WorldBossMgr._BossRecordInfo[index]['evtValue1']
		--end
		--return -1
	end
	return 0
end

function WorldBossManager:hotUpdate()
	loadWorldBossDB()
	self._count = 0
	self._bossMap = WorldBossTable
	self._FieldBoss = FieldBossInfo
	self:bossInit()
end

function sortBossHurt(a, b)
	return a.hurt > b.hurt
end

function sortBossLv(a, b)

	if a.lv < b.lv then
		return a.lv < b.lv
	elseif a.lv == b.lv then
		return a.monID<b.monID 
	else
	end

	--if a.lv == b.lv then
		--return a.monID<b.monID
	--else
		return a.lv < b.lv
	--end
	--return a.lv < b.lv and a.monID<b.monID
end

function WorldBossManager:bossInit()
	local t = os.time()
	for id, info in pairs(self._bossMap) do
		if onSall(info.refresh, t) == true then
			self._bossMap[id].live = 1
			self._bossMap[id].nextFresh = ""
			self._bossMap[id].activeTick = 0
		else
			self._bossMap[id].live = 0
			local nextFresh,activeTick = self:GetBossFreshTime()
			self._bossMap[id].nextFresh = nextFresh
			self._bossMap[id].activeTick = activeTick
		end
	end

	self:updateCurBossInfo()
end

function WorldBossManager:updateCurBossInfo()
	self._monID = {}
	self._count = 0
	for id, v in pairs(self._bossMap) do
		if v.refresh ~= "A" then
			self._count = self._count + 1
			self._monID[self._count] = {monID = id, lv = v.lv, live = v.live, nextFresh = v.nextFresh, activeTick = v.activeTick}
		end
	end
	table.sort(self._monID, sortBossLv)
end

function WorldBossManager.relive(monID, _ID)
print("WorldBossManager.relive 01", monID, _ID)
	if g_WorldBossMgr._bossMap[monID] then
		g_WorldBossMgr._bossDID[monID] = _ID

		g_WorldBossMgr._bossMap[monID].live = 1
		g_WorldBossMgr._bossMap[monID].nextFresh = ""
		g_WorldBossMgr._bossMap[monID].activeTick = 0
		g_WorldBossMgr:updateCurBossInfo()	

		if g_WorldBossMgr._bossReliveInfo[monID] then
			g_WorldBossMgr._bossReliveInfo[monID].live = 2
			--复活第二层
			if 1==g_WorldBossMgr._bossReliveInfo[monID].type then
			 	if g_WorldBossMgr._bossReliveInfo[monID].nextMID>0 then
			 		local nextMID = g_WorldBossMgr._bossReliveInfo[monID].nextMID
			 		if g_WorldBossMgr._bossReliveInfo[nextMID] then
			 			g_WorldBossMgr._bossReliveInfo[nextMID].live = 2
			 		end
			 	end
			end

			--if g_spaceID==0 or g_spaceID==1 then
				--boss死亡写入数据库
				local bossReliveInfoTmp = {}
				for i,v in pairs(g_WorldBossMgr._bossReliveInfo or {}) do
					bossReliveInfoTmp[i] = v.live
				end
				updateCommonData(COMMON_DATA_ID_WORLDBOSS,bossReliveInfoTmp)
			--end
		end
	end
end

--怪物被杀伤消息
function WorldBossManager:onMonsterHurt(monID, roleID, hurt, monDID)
	--if self._bossMapChange[monID] then
		--monID = self._bossMapChange[monID]
	--end

	--通过动态ID查看是否是世界boss
	local firstMonSID = monID
	if self._bossMapChange[monID] then 
		firstMonSID = self._bossMapChange[monID]
	end
	if not self._bossDID[firstMonSID] then return end
	if monDID ~= self._bossDID[firstMonSID] then return end

	--判断boss是否有两层
	local bossMulti = 0 			--0表示只有一层 1表示两层中的第一层 2表示两层中的第二层
	for i,v in pairs(self._bossMapChange or {}) do
		if v==monID then
			bossMulti = 1
		elseif i==monID then
			bossMulti = 2
		else
		end
	end

	if self._bossMap[monID] or self._bossMapChange[monID] then
		if not self._BossHurt then 
			self._BossHurt = {}
		end

		local player = g_entityMgr:getPlayer(roleID)
		if player then
			local roleSID = player:getSerialID()			
			local monster = g_entityMgr:getMonster(monDID)
			if not self._BossHurt[monID] or (monster:getHP() == monster:getMaxHP() - hurt) then		
				self._BossHurt[monID] = {}
			end

			if self._BossHurt[monID][roleSID] == nil then
				self._BossHurt[monID][roleSID] = {hurt, player:getName(), player:getMapID(), os.time(),hurt}
				g_ActivityMgr:joinWorldBoss(roleID, monID)
				
			else
				self._BossHurt[monID][roleSID][1] = self._BossHurt[monID][roleSID][1] + hurt
				if self._BossHurt[monID][roleSID][5] < hurt then
					self._BossHurt[monID][roleSID][5] = hurt
				end
			end
			self:HurtRank(monID, false, monster:getMapID())				--20150818
		end

		if not self._BossAttack then
			self._BossAttack = {}
		end

		if not self._BossAttack[monID] then
			self._BossAttack[monID] = {}
		end

		if player then
			local roleSID = player:getSerialID()
			--如果是boss第二层  判断第一层时是否已经加过成就
			if firstMonSID~=monID then
				if table.contains(self._achieveBossInfo[firstMonSID],roleSID) then
					return
				end
			end

			if not self._BossAttack[monID][roleSID] then
				self._BossAttack[monID][roleSID] = 1
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.hurtlWorldBoss, 1, monID)
				--活跃度标记
				g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.WORLD_BOSS)

				if 1==bossMulti then
					if not self._achieveBossInfo then
						self._achieveBossInfo = {}
					end

					if not self._achieveBossInfo[firstMonSID] then
						self._achieveBossInfo[firstMonSID] = {}
					end
					table.insert(self._achieveBossInfo[firstMonSID],roleSID)
				end
			end
		end
	end	
end

--监听怪物被杀死消息	
function WorldBossManager:onMonsterKill(monsterId, roleID, monDID, mapId)
	--通过动态ID查看是否是世界boss
	local firstMonSID = monsterId
	if self._bossMapChange[monsterId] then 
		firstMonSID = self._bossMapChange[monsterId]
	end
	if not self._bossDID[firstMonSID] then return end
	if monDID ~= self._bossDID[firstMonSID] then return end
	
	local monster = g_entityMgr:getMonster(monDID)
	if self._bossMap[monsterId] or self._bossMapChange[monsterId] then
		if self._BossHurt and self._BossHurt[monsterId] then
			if monster then
				a = monster:getMaxHP() / 10000
				sum = 0
				for roleSID, info in pairs(self._BossHurt[monsterId]) do
					sum = sum + info[5] / a
				end
				local count = 0
				local index = string.format("%d:%d:%d", monster:getSerialID(),monster:getMapID(),2)
				if g_WorldBossMgr._BossRecordInfo[index] then
					count = g_WorldBossMgr._BossRecordInfo[index]['evtValue1']
				end
				if true or sum >= 30 then
					self:updateBossRecordInfo(monster, 2, count + 1)
				else
					self:updateBossRecordInfo(monster, 2, count + 0)
				end
			end
		end

		local player = g_entityMgr:getPlayer(roleID)
		if player then
			if self._FieldBoss[monsterId] then
				self._FieldBoss[monsterId].KillTime = os.time()
			end
			
			local winner = self:HurtRank(monsterId, true, mapId)
			--if winner > 0 then monster:setOwnerID(winner) end

			--是否第二层也被杀死
			local bSecondKill = true
			for i,v in pairs(self._bossMapChange or {}) do
				if v==monsterId then
					bSecondKill = false
					break
				end
			end

			self._BossHurt[monsterId] = nil
			if bSecondKill then
				--发红包调整到这里 firstMonSID
				local bossInfoTmp = WorldBossTable[firstMonSID]
				local boosName = WorldBossTable[firstMonSID].name or ""
				if bossInfoTmp then
					local bossLevel = bossInfoTmp.lv or 0
					if monster then
						local ownerID = monster:getOwnerID()
						local ownerplayer = g_entityMgr:getPlayer(ownerID)
						if ownerplayer then
							g_RedBagMgr:worldBossKill(ownerplayer, bossLevel, boosName)
						end
					end
				end				
				--g_RedBagMgr:Create(player, REDBAG_SPECIAL)

				local realMonID = monsterId
				if self._bossMapChange[monsterId] then
					realMonID = self._bossMapChange[monsterId]
				end
				self._bossMap[realMonID].live = 0
				local nextFresh,activeTick = self:GetBossFreshTime()
				self._bossMap[realMonID].nextFresh = nextFresh
				self._bossMap[realMonID].activeTick = activeTick
				self:updateCurBossInfo()

				--逆魔的第一层做特殊处理  因为第一层会自己死亡
				if WORLD_BOSS_NIMO == monsterId then
					self._bossReliveInfo[realMonID].live = 1
				end
			end
			
			g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.killWorldBoss, 1, monsterId)
			self:checkAchieve(player:getSerialID(), monsterId, monDID)
		end	

		if self._BossAttack[monsterId] then
			self._BossAttack[monsterId] = nil
		end

		if firstMonSID ~= monsterId then
			--第二层死亡时应该清除第一层已达到过成就的角色ID信息
			self._achieveBossInfo[firstMonSID] = nil
		end

		if self._bossReliveInfo[monsterId] then
			self._bossReliveInfo[monsterId].live = 1
			--if g_spaceID==0 or g_spaceID==1 then
				--boss死亡写入数据库
				local bossReliveInfoTmp = {}
				for i,v in pairs(self._bossReliveInfo or {}) do
					bossReliveInfoTmp[i] = v.live
				end
				updateCommonData(COMMON_DATA_ID_WORLDBOSS,bossReliveInfoTmp)
			--end
		end
	end
end

function WorldBossManager:HurtRank(monID, dead, mapId)
	local winner = 0
	if os.time() - self._hurtTime >= WORLD_BOSS_REFRESH or dead then
		self._hurtTime = os.time()		

		--更新排名		
		local winnerName = ""
		local hurt_table = self._BossHurt[monID]
		if hurt_table then
			local isReward = dead

			local realMonID = monID
			if self._bossMapChange[monID] then
				realMonID = self._bossMapChange[monID]
			end

			if self._bossMap[realMonID].refresh == 'A' then
				isReward = false
			end

			local key_table = {}
			for id, v in pairs(hurt_table) do
				table.insert(key_table, {roleSID = id, hurt = v[1], name = v[2], map = v[3], beginHurt = v[4]})
			end
			table.sort(key_table, sortBossHurt)
			--推送排名			
			local size = table.getn(key_table)
			for rank = 1, size do
				local hurtInfo = key_table[rank]
				if hurtInfo.beginHurt<=0 then
					hurtInfo.beginHurt = os.time()-60
				end

				local recordSize = size > 5 and 5 or size
				local player = g_entityMgr:getPlayerBySID(hurtInfo.roleSID)
				if player then					
					local roleID = player:getID()
					--[[
					if player:getMapID() == mapId then
						local buffer = LuaEventManager:instance():getLuaRPCEvent(WORLDBOSS_SC_REWARD)
						buffer:pushInt(monID)
						buffer:pushBool(dead)
						buffer:pushInt(recordSize)
						for rk = 1, recordSize do
							buffer:pushString(key_table[rk].name)
							buffer:pushInt(key_table[rk].hurt)
						end
						buffer:pushInt(rank)
						buffer:pushInt(hurtInfo.hurt)
						g_engine:fireLuaEvent(roleID, buffer)
					end
					]]
					if isReward then
						--活跃度标记
						g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.WORLD_BOSS)
						g_taskMgr:NotifyListener(player, "onKillWorldBoss")



						local rewardCount = self._bossMap[realMonID].count < size and self._bossMap[realMonID].count or size
						if rank == 1 then
							winner = roleID 
							winnerName = hurtInfo.name							

							--boss被某人击杀 显示到系统频道面板
							if WorldBossTable[monID] then
								if WorldBossTable[monID].monID == WorldBossTable[monID].monID2 then
									--boss只有一层
									--g_RedBagMgr:Create(player, REDBAG_SPECIAL)
									

									local boosName = WorldBossTable[monID].name or ""
									if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
										g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,62,2,{boosName,""}) --winnerName
									end
								end
							end

							if self._bossMapChange[monID] then
								--boss第二层
								--g_RedBagMgr:Create(player, REDBAG_SPECIAL)

								local realMonID = self._bossMapChange[monID]
								local boosName = WorldBossTable[realMonID].name or ""
								if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
									g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,62,2,{boosName,""}) --winnerName
								end
							end
						end
					end	
				end
			end	
		end
	end
	return winner
end

--掉落跑马灯
function WorldBossManager.Boardcast(name, id, itemID, monster)
	local nameTmp = g_ActivityMgr:getItemName(itemID)
	g_normalLimitMgr:sendErrMsg2Client(36, 3, {name, monster, nameTmp})
end

function WorldBossManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(WorldBossServlet.getInstance():getCurEventID(), roleId, EVENT_WORLDBOSS_SETS, errId, paramCount, params)
end

--获取野外boss信息表	20150703
function WorldBossManager:GetFieldBossInfo()
	if self._FieldBoss then
		return self._FieldBoss
	else
		return nil
	end
end

function WorldBossManager:GetBossFreshTime()
	local Dhours = tonumber(os.date("%H"))
	local Dminute = tonumber(os.date("%M"))
	local Dsecond = tonumber(os.date("%S"))

	local activeTick = 0
	local freshTime = 0

	local DBRefTime = WorldBossDBRefTime
	if #DBRefTime >= 5 then
		if Dhours >= DBRefTime[5].hour + 1 then 
			activeTick = self:GetNextDayTick(Dhours, Dminute, Dsecond)
			Dhours = 0		
		end
		if Dhours == DBRefTime[5].hour and Dminute > DBRefTime[5].min then
			activeTick = self:GetNextDayTick(Dhours, Dminute, Dsecond)
			Dhours = 0
		end
		if Dhours == DBRefTime[5].hour and Dminute == DBRefTime[5].min and Dsecond > DBRefTime[5].sec then 
			activeTick = self:GetNextDayTick(Dhours, Dminute, Dsecond)
			Dhours = 0
		end

		for i,v in ipairs(DBRefTime or {}) do
			if v.hour then
				if Dhours <= v.hour then
					freshTime = tostring(v.showT)
					if (Dhours == v.hour and Dminute > v.min) or (Dhours == v.hour and Dminute == v.min and Dsecond > v.sec) then
						local nextTmp = DBRefTime[i+1]
						if not nextTmp then nextTmp = DBRefTime[1] end
						freshTime = nextTmp.showT
					end
					break
				end
			end
		end
	end
	return freshTime, activeTick
end

function WorldBossManager:GetNextDayTick(hour, minute, second)
	local hourSpan = 23 - hour
	local minuterSpan = 59 - minute
	local secondSpan = 60 - second

	local nextDayTick = tonumber(os.time()) + hourSpan*3600 + minuterSpan*60 + secondSpan
	return nextDayTick
end

function WorldBossManager:onloadWorldBossRelive(data)
	self:initBossReliveInfo()

	local dataTmp = unserialize(data)
	for i,v in pairs(dataTmp or {}) do
		if dataTmp[i]>1 then
			if self._bossReliveInfo[i] then
				self._bossReliveInfo[i].live = 2
			end
		end
	end

	--通知复活世界boss
	--if g_spaceID==0 or g_spaceID==1 then
		for i,v in pairs(self._bossReliveInfo or {}) do
			if 1==v.type then
				local nextMID = v.nextMID
				local nextLive = 0
				if self._bossReliveInfo[nextMID] then
					nextLive = self._bossReliveInfo[nextMID].live or 1
				end
				if v.live>1 or nextLive>1 then
print("WorldBossManager:onloadWorldBossRelive 01", v.mapID, i)
					Monster:ReliveBoss(v.mapID,i)
				end
			end
		end
	--end
end

--GM刷新世界boss
function WorldBossManager:GMReliveWorldBoss(bossID)
	print("relive boss start...")
	if bossID == 0 then
		for i,v in pairs(self._bossReliveInfo or {}) do
			if 1==v.type then
				Monster:ReliveBoss(v.mapID,i)
				print("relive boss mapID, id", v.mapID, i)
			end
		end
	else
		local boss = self._bossReliveInfo[bossID]
		if bossID then
			print("refresh bossID", bossID)
			Monster:ReliveBoss(boss.mapID,bossID)
		end
	end
end

--重置世界boss衰弱机制
function WorldBossManager:resetWordBossWeak()
	for monID, info in pairs(self._bossMap) do
		--print("monID, info:", monID, info)
		local monDID = self._bossDID[monID]
		if monDID then
			local monster = g_entityMgr:getMonster(monDID)
			if monster then
				self:updateBossRecordInfo(monster, 2, 0)
				self:updateBossRecordInfo(monster, 3, 0)
				local data = g_configMgr:getMonster(tonumber(monID))
				if data then
					monster:resetMonsterData(data)
				end
			end
		end
	end
end

function WorldBossManager:getWorldBossOwner(monsterDID)
	local isWorldBoss = false
	local ownerName = ""
	local ownerSID = 0

	for i,v in pairs(self._bossDID or {}) do
		if v==monsterDID then
			isWorldBoss = true
			break
		end
	end

	if isWorldBoss then
		local monster = g_entityMgr:getMonster(monsterDID)
		if monster then
			local ownerID = monster:getOwnerID()
			local ownerplayer = g_entityMgr:getPlayer(ownerID)
			if ownerplayer then
				ownerName = ownerplayer:getName()
				ownerSID = ownerplayer:getSerialID()
			end			
		end
	end
	return isWorldBoss,ownerSID,ownerName
end

--广播世界boss归属者
function WorldBossManager:update()
	for i,v in pairs(self._bossDID or {}) do
		local realMonID = i
		if self._bossMapChange[i] then
			realMonID = self._bossMapChange[i]
		end
		
		local broadBossOwner = false
		local ownerID = 0
		local bossMapID = 0
		if self._bossMap[realMonID] then
			if self._bossMap[realMonID].live>0 then
				bossMapID = self._bossMap[realMonID].mapID
				local monster = g_entityMgr:getMonster(v)
				if monster then
					if monster:getHP()<monster:getMaxHP() then
						broadBossOwner = true
						ownerID = monster:getOwnerID()
					end
				end
			end
		end

		local ownerName = ""
		local ownerSID = 0
		if broadBossOwner then
			local ownerplayer = g_entityMgr:getPlayer(ownerID)
			if ownerplayer then
				ownerName = ownerplayer:getName()
				ownerSID = ownerplayer:getSerialID()
			end
 
			local ret = {}
			ret.ownerSID = ownerSID
			ret.ownerName = ownerName
			local worldScene = g_sceneMgr:getPublicScene(bossMapID)
			if worldScene then
				boardSceneProtoMessage(worldScene:getID(), WORLDBOSS_SC_OWNERID, "WorldBossOwnerRetProtocol", ret)
			end
		end
	end 
end

function WorldBossManager:checkAchieve(roleSID, monSID, monDID)
	if 6001 == monSID then
		--击杀狂暴尸霸
		local monster = g_entityMgr:getMonster(monDID)
		if monster then
			if monster:getIsAngry() then
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.killKuangbaoShiba, 1)
			end
		end
	elseif 6003 == monSID then
		--不击杀召唤小怪，直接击杀逆魔
		local monster = g_entityMgr:getMonster(monDID)
		if monster then
			local totalSummon = monster:getSummonTotalNum()
			local curSummon = monster:getSummonReliveNum()
			if totalSummon == curSummon then
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.zhanShou, 1)
			end
		end
	elseif 6006 == monSID then
		--关键一击 通天教主
		g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.oneShotTongtian, 1)
	elseif 6007 == monSID then
		--关键一击 阿修罗
		g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.oneShotAxiuluo, 1)
	else
	end
end

function WorldBossManager:isBossAllKill()
	for i,v in pairs(self._bossMap or {}) do
		if v and v.live then
			if v.live > 0 then
				return false
			end
		end
	end
	return true
end	

function WorldBossManager:getWorldBossLiveInfo()
	return self._monID or {}
end

function WorldBossManager:getWorldBossCount()
	return self._count or 0
end

function WorldBossManager.getInstance()
	return WorldBossManager()
end

g_WorldBossMgr = WorldBossManager.getInstance()
