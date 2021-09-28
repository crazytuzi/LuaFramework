--MonAttackMgr.lua
--/*-----------------------------------------------------------------
--* Module:  MonAttackMgr.lua
--* Author:  liucheng
--* Modified: 2014年12月12日
--* Purpose: Implementation of the class MonAttackMgr 
-------------------------------------------------------------------*/

require ("system.monattack.MonAttackConstant")

MonAttackMgr = class(nil, Singleton, Timer)

function MonAttackMgr:__init()
	self._xtActive = 1 					--系统是否开启
	self._InActivity = false			--当前活动是否进行
	self._partOff = false 				--其它服务器是否已完成活动
	self._monsterInfos = {} 			--配置的怪物刷新ID 对应的刷怪中心点  刷怪半径
	self._monsterfresh = {} 			--配置的刷新信息

	self._mon = {} 						--所有精英怪 和 boss
	self._monBasicAllMonster = {} 		--所有刷新出来的基础怪的ID

	--{活动所在的地图，基础怪刷新间隔，基础怪每次最大刷新个数，配置的基础怪刷新信息条数，精英怪率刷新条件，精英怪每次刷新个数，boss刷新条件，boss每次刷新个数，boss名字}
	self._refresh = {mapID=2100, basicRCD=5, basicRNum=10, eliteTerms=500, eliteRNum=1, bossTerms=10, bossRNum=1, bossName=""}
	--{配置的基础怪刷新信息条数，配置的精英怪刷新信息条数}
	self._InfoNum = {basicInfoNum=0, eliteInfoNum=0, bossInfoNum=0}
	--{基础怪积分，精英怪积分，boss积分}
	self._jifen = {basicScore=10, eliteScore=300, bossScore=1000}
	--{基础怪某个刷新ID，基础怪静态ID,精英怪某个刷新ID，精英怪静态ID,boss某个刷新ID，boss静态ID}
	self._monModel = {basicRID=0, basicModel=0, eliteRID=0, eliteModel=0, bossRID=0, bossModel=0}
	--{当前基础怪数量，基础怪已经被杀数目，当前精英怪数目，精英怪被杀数目，精英怪总刷新数目，当前boss个数，boss已刷新总数}
	self._curMonState = {basicNum=0, basicKill=0, eliteNum=0, eliteKill=0, refreshElite=0, bossNum=0, refreshBoss=0}

	self._round = 0
	self._sinScoreInfo = {}
	self._sinReward = {}
	self._BossKillInfo = 0
	self._mulScoreInfo = {}
	self._mulReward = {}
	
	self._preEndInfo = {} 				--活动预结束
	self:loadMonAttackData()
	self:createAllBasicMonster()
	
	g_listHandler:addListener(self)
end

function MonAttackMgr:preEndNotice(preEndTick)
	self._preEndInfo = {}
	for i=1,5 do
		local endTick = {i, preEndTick-(6-i)*60, preEndTick-(6-i)*60 + 5}
		table.insert(self._preEndInfo, endTick)
	end
end

--类似跑马灯消息
function MonAttackMgr:sendBroad2Client(errId, paramCount, params)
	--fireProtoSysMessageBySid(mesID, roleSid, eventID, eCode, paramCnt, params)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = EVENT_PUSH_MESSAGE
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function MonAttackMgr:sendErrMsg2Client(roleId, event, errId, eventID, paramCount, params)
	fireProtoSysMessage(eventID, roleId, event, errId, paramCount, params)
end

--创建所有基础怪
function MonAttackMgr:createAllBasicMonster()
	for a=1,self._InfoNum.basicInfoNum do
		if not self._monBasicAllMonster[a] then
			self._monBasicAllMonster[a] = {}
		end
		self:refreshBasic(a, self._refresh.basicRNum)
	end
end

--显示所有基础怪
function MonAttackMgr:showAllBasicMonster()
	local scene = g_sceneMgr:getPublicScene(self._refresh.mapID)
	if scene then
		for i,v in pairs(self._monBasicAllMonster or {}) do
			if i and v then
				--self._monBasicAllMonster[mon:getID()] = {monster = mon, live = true, lx = _lx, rIndex = refreshIndex, xPos = mapX, yPos = mapY}
				if v.monster and v.xPos and v.yPos and v.lx and v.rIndex then
					local monDIDTmp = v.monster:getID()
					if g_sceneMgr:enterPublicScene(monDIDTmp, self._refresh.mapID, v.xPos, v.yPos, 1) then
						scene:addMonster(v.monster)
						--if not self._mon then
							--self._mon = {}
						--end
						--self._mon[monDIDTmp] = {monster = v.monster, live = true, lx = v.lx, rIndex = v.rIndex}
					else
						g_entityMgr:destoryEntity(monDIDTmp)
					end
				end
			end
		end
	end
end

--隐藏所有基础怪 并删除精英怪和boss
function MonAttackMgr:hideAllBasicMonster()
	local scene = g_sceneMgr:getPublicScene(self._refresh.mapID)
	if scene then
		for i,v in pairs(self._monBasicAllMonster or {}) do
			if i and v then
				if v.monster then
					local monTmp = v.monster
					scene:detachEntity(monTmp:getID())
				end
			end
		end
	end

	if self._mon then
		for id, v in pairs(self._mon) do
			if v.live then
				g_entityMgr:destoryEntity(id)
			end
		end
		self._mon = {}
	end
end

function MonAttackMgr:loadMonAttackData()
	local records = require "data.MonAttackDB"
	for _, data in pairs(records or {}) do
		if data.q_mapid then
			self._refresh.mapID = tonumber(data.q_mapid)
		end
		if data.q_id and data.q_point and data.q_type then
			self._monsterfresh[data.q_id] = data

			if 1==data.q_type then
				self._InfoNum.basicInfoNum = self._InfoNum.basicInfoNum + 1
				self._jifen.basicScore = tonumber(data.q_point)
				self._refresh.basicRCD = tonumber(data.q_CD)
				self._refresh.basicRNum = tonumber(data.q_PreCount)
				self._monModel.basicRID = tonumber(data.q_refreshID or 0)
			elseif 2==data.q_type then
				self._InfoNum.eliteInfoNum = self._InfoNum.eliteInfoNum + 1
				self._jifen.eliteScore = tonumber(data.q_point)
				self._refresh.eliteTerms = tonumber(data.q_num or 100)
				self._monModel.eliteRID = tonumber(data.q_refreshID or 0)
			elseif 3==data.q_type then
				self._InfoNum.bossInfoNum = self._InfoNum.bossInfoNum + 1
				self._jifen.bossScore = tonumber(data.q_point)
				self._refresh.bossTerms = tonumber(data.q_num or 500)
				self._monModel.bossRID = tonumber(data.q_refreshID or 0)
			else
			end
		end
	end
	self:loadMonsterInfo()
	self._sinReward = require "data.MonAttackSinReward"
	self._mulReward = require "data.MonAttackMulReward"
end

function MonAttackMgr:loadMonsterInfo()
	local records = require "data.MonsterInfoDB"
	for _, data in pairs(records or {}) do
		if data.q_id then
			self._monsterInfos[data.q_id] = data
		end
	end	
	self:loadMonModel()
end

function MonAttackMgr:loadMonModel()
	--查找boss名字
	local refreshID = self._monModel.basicRID					--self._monBasicModel[1]
	if refreshID > 0 then
print("MonAttackMgr:loadMonModel 01",refreshID)		
		local model = tonumber(self._monsterInfos[refreshID].q_monster_model or 0)
		if model > 0 then
			self._monModel.basicModel = model
		end
	end

	refreshID = self._monModel.eliteRID
	if refreshID > 0 then
		local model = tonumber(self._monsterInfos[refreshID].q_monster_model or 0)
		if model > 0 then
			self._monModel.eliteModel = model
		end
	end

	refreshID = self._monModel.bossRID
	if refreshID > 0 then
		local bossModel = tonumber(self._monsterInfos[refreshID].q_monster_model or 0)
		if bossModel>0 then
			self._monModel.bossModel = bossModel

			local Datas = require "data.MonsterDB"
			for _, record in pairs(Datas or {}) do
				if bossModel == tonumber(record.q_id) then
					self._refresh.bossName = record.q_name or ""
					break
				end
			end
		end
	end
end

function MonAttackMgr:getMonsterInfoPos(id)
	local info = self._monsterInfos[id]
	if info then
		return info.q_center_x,info.q_center_y
	end
	return 0,0
end

function MonAttackMgr:refreshBasic(index, num)
	if num > 0 and index>0 then
		if not self._monBasicAllMonster[index] then
			self._monBasicAllMonster[index] = {}
		end

		--local total = self._InfoNum.basicInfoNum
		for i = 1, num do
			--local id = math.random(total)
			local r_id = self._monsterfresh[index].q_refreshID
			local r_range = self._monsterfresh[index].q_bj
			local curMonID = self:refreshMon(r_id, 1, r_range, index, 0) 		--记录基础怪的刷新点
			if curMonID>0 then
				table.insert(self._monBasicAllMonster[index], curMonID)
			end
			--self._curMonState.basicNum = self._curMonState.basicNum + 1
		end
	end
end

function MonAttackMgr:refreshElite(num)
	if num > 0 and self._curMonState.refreshBoss < 1 then
		local total = self._InfoNum.eliteInfoNum
		for i = 1, num do
			local id = math.random(total) + self._InfoNum.basicInfoNum
			local r_id = self._monsterfresh[id].q_refreshID
			local r_range = self._monsterfresh[id].q_bj
			self:refreshMon(r_id, 2, r_range, 0, 1)
		end
	end
end

function MonAttackMgr:refreshBoss(num)
	if num > 0 and self._curMonState.refreshBoss < 1 then
		for i = 1, num do
			local total = self._InfoNum.bossInfoNum
			local id = math.random(total) + self._InfoNum.basicInfoNum + self._InfoNum.eliteInfoNum
			local r_id = self._monsterfresh[id].q_refreshID
			local r_range = self._monsterfresh[id].q_bj
			self:refreshMon(r_id, 3, r_range, 0, 1)
		end
	end
end

function MonAttackMgr:refreshMon(r_id, _lx, refreshRange, refreshIndex, addToScene)
	local mapX, mapY = self:getMonsterInfoPos(r_id)
	mapX = mapX + math.random(refreshRange) - math.ceil(refreshRange/2)
	mapY = mapY + math.random(refreshRange) - math.ceil(refreshRange/2)

	local scene = g_sceneMgr:getPublicScene(self._refresh.mapID)
	if scene and self._monsterInfos[r_id] then
		local monsterID = self._monsterInfos[r_id].q_monster_model
		local mon = g_entityFct:createMonster(monsterID)
		if mon and scene:addMonsterInfoByID(mon, r_id) then
			if addToScene > 0 then
				if g_sceneMgr:enterPublicScene(mon:getID(), self._refresh.mapID, mapX, mapY, 1) then
					scene:addMonster(mon)
					if not self._mon then
						self._mon = {}
					end
					self._mon[mon:getID()] = {monster = mon, live = true, lx = _lx, rIndex = refreshIndex}

					if _lx == 3 then					
						self:sendBroad2Client(MONATTACK_REFRESH_BOSS, 3, {self._refresh.bossName,mapX,mapY})
						g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,MONATTACK_REFRESH_BOSS,3,{self._refresh.bossName,mapX,mapY})
					end
					return mon:getID()
				else
					g_entityMgr:destoryEntity(mon:getID())
				end
			else
				if not self._monBasicAllMonster then
					self._monBasicAllMonster = {}
				end
				self._monBasicAllMonster[mon:getID()] = {monster = mon, live = true, lx = _lx, rIndex = refreshIndex, xPos = mapX, yPos = mapY}
			end
		else
			if mon then
				g_entityMgr:destoryEntity(mon:getID())
			end
		end
	end	
	return 0
end

function MonAttackMgr:onMonsterHurt(monID, roleID, hurt, monDID)
	if not self._InActivity or self._xtActive <= 0 then
		return
	end

	--怪物种类不是此系统刷的
	if monsterId ~= self._monModel.basicModel and monsterId ~= self._monModel.eliteModel and monsterId ~= self._monModel.bossModel then
		return
	end

	local player = g_entityMgr:getPlayer(roleID)
	if not player or not self._mon[monDID] then
		return
	end
	local RoleSID = player:getSerialID()

	if not self._sinScoreInfo then
		self._sinScoreInfo = {}
	end

	if not self._sinScoreInfo[RoleSID] then
		local tick = os.time()
		self._sinScoreInfo[RoleSID] = {}
		self._sinScoreInfo[RoleSID].score = 0
		self._sinScoreInfo[RoleSID].name = player:getName()
		self._sinScoreInfo[RoleSID].beginTick = tick
		self._sinScoreInfo[RoleSID].updateTick = tick

		self._sinScoreInfo[RoleSID].appID = player:getGameAppID()
		self._sinScoreInfo[RoleSID].platID = player:getPlatID()
		self._sinScoreInfo[RoleSID].openID = player:getOpenid()
		self._sinScoreInfo[RoleSID].level = player:getLevel()
		g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.MON_ATTACK)
	end
end

function MonAttackMgr:onMonsterKill(monsterId, roleID, monDID)
	if not self._InActivity or self._xtActive <= 0 then
		return
	end

	--怪物种类不是此系统刷的
	if monsterId ~= self._monModel.basicModel and monsterId ~= self._monModel.eliteModel and monsterId ~= self._monModel.bossModel then
		return
	end

	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local RoleSID = player:getSerialID()
	
	local monType = 0
	if monsterId == self._monModel.basicModel then
		monType = 1
		if not self._monBasicAllMonster[monDID] then return end
	elseif monsterId == self._monModel.eliteModel then
		monType = 2
		if not self._mon[monDID] then return end
		self._mon[monDID].live = false
	elseif monsterId == self._monModel.bossModel then
		monType = 3
		if not self._mon[monDID] then return end
		self._mon[monDID].live = false
	else
	end

	local monScore = 0
	if 1 == monType then
		self._curMonState.basicKill = self._curMonState.basicKill + 1
		monScore = self._jifen.basicScore
		--self._curMonState.basicNum = self._curMonState.basicNum - 1

		--每杀500个普通怪物刷一个精英怪
		if self._curMonState.basicKill >= (self._curMonState.refreshElite + 1) * self._refresh.eliteTerms then
			self:refreshElite(1)
			self._curMonState.refreshElite = self._curMonState.refreshElite + 1
		end
		g_achieveSer:achieveNotify(RoleSID, AchieveNotifyType.killAttackCity1, 1)

		--先记录杀死的基础怪  在定时器里从 self._monBasicAllMonster 删除
	elseif 2 == monType then
		self._curMonState.eliteKill = self._curMonState.eliteKill + 1
		monScore = self._jifen.eliteScore

		--杀10个精英怪之后刷出一个boss  boss只刷新一个
		if self._curMonState.eliteKill >= self._refresh.bossTerms and self._curMonState.refreshBoss < 1 then
			self:refreshBoss(1)
			self._curMonState.refreshBoss = 1
		end
		g_achieveSer:achieveNotify(RoleSID, AchieveNotifyType.killAttackCity2, 1)
	elseif 3 == monType then
		self._curMonState.refreshBoss = 2
		self._BossKillInfo = 1
		monScore = self._jifen.bossScore
		g_achieveSer:achieveNotify(RoleSID, AchieveNotifyType.killAttackCity3, 1)
	else	
	end
	
	local tick = os.time()
	if self._sinScoreInfo[RoleSID] then
		self._sinScoreInfo[RoleSID].score = self._sinScoreInfo[RoleSID].score + monScore
		self._sinScoreInfo[RoleSID].updateTick = tick
	else
		self._sinScoreInfo[RoleSID] = {}
		self._sinScoreInfo[RoleSID].score = monScore
		self._sinScoreInfo[RoleSID].name = player:getName()
		self._sinScoreInfo[RoleSID].beginTick = tick
		self._sinScoreInfo[RoleSID].updateTick = tick

		self._sinScoreInfo[RoleSID].appID = player:getGameAppID()
		self._sinScoreInfo[RoleSID].platID = player:getPlatID()
		self._sinScoreInfo[RoleSID].openID = player:getOpenid()
		self._sinScoreInfo[RoleSID].level = player:getLevel()
		g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.MON_ATTACK)
	end

	if monScore == self._jifen.bossScore then
		if not self._partOff then
			self:updateBossKillInfo()
		end
	end
end

function MonAttackMgr:on()
	if self._xtActive <= 0 then return end
	
	local scene = g_sceneMgr:getPublicScene(self._refresh.mapID)
	if scene then
		self._InActivity = true
		self._round = 0
		gTimerMgr:regTimer(self, 0, 1000)
	end

	--刷新基础怪
	self:showAllBasicMonster()
end

function MonAttackMgr:off()
	--全服跑马灯
	self:sendBroad2Client(MONATTACK_END_MSG_ID, 0, {})
	if self._InActivity then
		self._InActivity = false
		gTimerMgr:unregTimer(self)

		local actName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.MON_ATTACK)
		for i, v in pairs(self._sinScoreInfo or {}) do
			local beginTick = os.time()
			if self._sinScoreInfo then				
				if self._sinScoreInfo[i] then
					beginTick = self._sinScoreInfo[i].beginTick or beginTick

					--增加新日志
					local info = self._sinScoreInfo[i]
					g_tlogMgr:TlogGWGCFlow(info.appID, info.platID, info.openID, info.level, info.score)
				end
			end
		end

		self:hideAllBasicMonster()
		self:Reward()

		--发送一条消息消失积分面板
		self:sendRank(false)
		self:ClearMonAttackInfo()
	end
end

function scoresort(a,b)
	if a and b then
		if a.score ~= b.score then
			return a.score > b.score
		else
			if a.tick ~= b.tick then
				return a.tick < b.tick
			else
				return a.SID < b.SID
			end
		end
	end
end

function MonAttackMgr:sendRank(inActivity)
	if inActivity then
		local sinScoreTmp = {}
		--table.sort(self._UserActList[UID][tab], function(a, b) return a[6] < b[6] end)
		
		for i,v in pairs(self._sinScoreInfo or {}) do
			if i ~= "" then 			--i>0
				if v.score and v.score>0 then
					local Tmp = {SID=i, score=v.score or 0, tick=v.updateTick or 0, name=v.name}
					table.insert(sinScoreTmp,Tmp)
				end
			end						
		end
		table.sort(sinScoreTmp,scoresort)

		--找出前十排名
		local topTenTmp = {}
		local maxTop = 0
		if #sinScoreTmp<10 then
			maxTop = #sinScoreTmp
			for a=1,#sinScoreTmp do
				local Tmp = {curRank=a, SID=sinScoreTmp[a].SID or 0, score=sinScoreTmp[a].score or 0, name=sinScoreTmp[a].name}
				table.insert(topTenTmp,Tmp)
			end
		else
			maxTop = 10
			for a=1,10 do
				local Tmp = {curRank=a, SID=sinScoreTmp[a].SID or 0, score=sinScoreTmp[a].score or 0, name=sinScoreTmp[a].name}
				table.insert(topTenTmp,Tmp)
			end
		end

		--推送前十名的排名
		for m,n in pairs(sinScoreTmp) do
			local playerTmp = g_entityMgr:getPlayerBySID(n.SID)
			if playerTmp then
				--限制地图
				if self._refresh.mapID == playerTmp:getMapID() then				
					local retData = {}
					retData.myScore = n.score or 0
					retData.myRank = m
					retData.RankNum = maxTop
					retData.scoreRankInfo = {}
					
					for j,k in pairs(topTenTmp) do
						local rankInfoTmp = {}
						rankInfoTmp.Score = k.score or 0
						rankInfoTmp.name = k.name
						table.insert(retData.scoreRankInfo,rankInfoTmp)
					end
					fireProtoMessage(playerTmp:getID(),LITTERFUN_SC_MONATTACK_RANK,"MonattackRankProtocol",retData)	
--print("MonAttackMgr:sendRank 01", playerTmp:getSerialID(), retData.myScore, retData.myRank)
				end
			end	
		end
	else
		for i,v in pairs(self._sinScoreInfo or {}) do
			if i ~= "" then
				local playerTmp = g_entityMgr:getPlayerBySID(i)
				if playerTmp then
					--限制地图
					if self._refresh.mapID == playerTmp:getMapID() then
						local retData = {}
						retData.myScore = 0
						retData.myRank = 0
						retData.RankNum = 0
						retData.scoreRankInfo = {}
						fireProtoMessage(playerTmp:getID(),LITTERFUN_SC_MONATTACK_RANK,"MonattackRankProtocol",retData)	
--print("MonAttackMgr:sendRank 02", playerTmp:getSerialID(), retData.myScore, retData.myRank)
					end
				end
			end
		end
	end
end

function MonAttackMgr:update()	
	if self._InActivity and self._xtActive > 0 then
--[[		
		if 0==self._round%self._refresh.basicRCD then
			if self._curMonState.refreshBoss < 1 then 			--boss刷新之后不刷新小怪
				--刷新基础怪
				for a=1,self._InfoNum.basicInfoNum do
					if not self._monBasicAllMonster[a] then
						self._monBasicAllMonster[a] = {}
					end

					local count = 0
					local curPointMonNum = table.getn(self._monBasicAllMonster[a])
					if curPointMonNum < self._refresh.basicRNum then
						count = self._refresh.basicRNum - curPointMonNum
					end

					if count>0 then
						self:refreshBasic(a, count)
					end
				end
			end

			if self._round>0 then
				self:sendRank()
			end
		end
]]		
		self._round = self._round + 1
		if 0 == self._round % 5 then
			self:sendRank(true)
		end

		--判断预结束
		local curTick = os.time()
		for i,v in pairs(self._preEndInfo or {}) do
			if v[1] and v[2] and v[3] then
				if curTick>v[2] and curTick<v[3] then
					local actName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.MON_ATTACK)
					self:sendBroad2Client(90,2,{actName,6-v[1]})
					g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,90,2,{actName,6-v[1]})
					table.remove(self._preEndInfo,i)
					break
				end
			end			
		end
	end
end

function MonAttackMgr:Reward()
	local ecode = 0
	--个人奖励
	if #self._sinReward > 3 then
		for i, v in pairs(self._sinScoreInfo or {}) do
			local getReward = false
			local dropID = 0
			if v.score then
				local score = v.score or 0
				if score >= tonumber(self._sinReward[4].q_point) then
					getReward = true
					--g_entityMgr:dropItemToEmail(i, tonumber(self._sinReward[4].q_type1), 28, 103, ecode)				
					dropID = tonumber(self._sinReward[4].q_type1)
				elseif score >= tonumber(self._sinReward[3].q_point) then
					getReward = true
					--g_entityMgr:dropItemToEmail(i, tonumber(self._sinReward[3].q_type1), 28, 103, ecode)
					dropID = tonumber(self._sinReward[3].q_type1)
				elseif score >= tonumber(self._sinReward[2].q_point) then
					getReward = true
					--g_entityMgr:dropItemToEmail(i, tonumber(self._sinReward[2].q_type1), 28, 103, ecode)
					dropID = tonumber(self._sinReward[2].q_type1)
				elseif score >= tonumber(self._sinReward[1].q_point) then
					getReward = true
					--g_entityMgr:dropItemToEmail(i, tonumber(self._sinReward[1].q_type1), 28, 103, ecode)
					dropID = tonumber(self._sinReward[1].q_type1)
				else
				end
			end
			
			if getReward then
				local offlineMgr = g_entityMgr:getOfflineMgr()
				local email = offlineMgr:createEamil()
				email:setDescId(28)

				local dropRetString = g_entityMgr:getDropString(0,0,dropID)
				--{{itemID=555555,count=50,bind=0,strength=0,slot=0},}
				local dropRet = unserialize(dropRetString) or {}
				for m,n in pairs(dropRet) do
					if n.itemID and n.count then
						local itemID = n.itemID
						local itemNum = n.count
						local bind = true 		--n.bind or 1
						if n.bind<=0 then bind = false end						
						email:insertProto(itemID, itemNum, bind)
					end
				end
				offlineMgr:recvEamil(i, email, 103, 0)

				--邮件提示个人奖励发送
				local ret = {}
				ret.eventId = EVENT_LITTERFUN_SETS
				ret.eCode = 21
				ret.mesId = EVENT_LITTERFUN_SETS
				local actName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.MON_ATTACK)
				ret.param = {tostring(actName) or ""}
				fireProtoMessageBySid(i, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
			end
		end
	end

--[[
	--服务器奖励
	if self._BossKillInfo > 0 then
		local RewardNum = tonumber(self._mulReward.q_num1 or 50000)
		for i,v in pairs(self._sinScoreInfo or {}) do
			g_entityMgr:dropItemToEmail(i, tonumber(self._mulReward[1].q_type1), 29, 104, ecode)
			
			--邮件提示服务器奖励发送
			local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
			retBuff:pushShort(15300)
			retBuff:pushShort(22)
			retBuff:pushShort(15300) --XunBaoServlet.getInstance():getCurEventID()
			retBuff:pushChar(1)
			retBuff:pushString(tostring(self._ActivityName) or "")
			g_engine:fireSerialEvent(i, retBuff)
			--self:sendErrMsg2Client(playerTmp:getID(),15300,22,15300,1,{self._ActivityName})
		end
	end
]]	
end

function MonAttackMgr:ClearMonAttackInfo()
	self._InActivity = false			--当前活动是否进行
	self._partOff = false				--其它服务器是否已完成活动
	self._mon = {}
	self._curMonState = {basicNum=0, basicKill=0, eliteNum=0, eliteKill=0, refreshElite=0, bossNum=0, refreshBoss=0}
	
	self._round = 0
	self._sinScoreInfo = {}
	self._BossKillInfo = 0
	self._mulScoreInfo = {}
end

function MonAttackMgr:updateBossKillInfo(spaceID)
	if self._InActivity and self._xtActive > 0 then
		self._BossKillInfo = 1
		self._partOff = true
		self:sendRank(true)
		local actName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.MON_ATTACK)
		g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,64,1,{actName})

		self:off()
	end
end

function MonAttackMgr:setxtActive(value)
	self._xtActive = tonumber(value)
end

function MonAttackMgr.getInstance()
	return MonAttackMgr()
end

g_MonAttackMgr = MonAttackMgr.getInstance()