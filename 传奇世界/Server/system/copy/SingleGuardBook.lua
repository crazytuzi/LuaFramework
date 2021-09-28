--SingleGuardBook.lua
--单人守护副本

SingleGuardBook = class(CopyBook)

function SingleGuardBook:__init()
	self._currCircle = 1	--当前怪物刷新环数，第几波
	self._finishTime = 0	--此副本完成时间
	self._startTime = 0	--开始时间，n秒后才开始刷怪的
	self._statueID = 0
	self._monterID = {}	--怪物ID集合,小地图显示用
	self._curRound = 1 --当前刷怪的轮数，目前最大3轮
	self._lastRoundTime = 0 --记录上轮刷怪时间
	self._lastFlushRoad = {0,0,0,0}
	self._currentCircle = 0
	self._road1 = 0
	self._road2 = 0
	self._road3 = 0
	self._road4 = 0
end

function SingleGuardBook:getCurrentCircle()
	return self._currentCircle
end

function  SingleGuardBook:setCurrentCircle(circle)
	self._currentCircle = circle
end

function SingleGuardBook:getRoad1()
	return self._road1
end

function SingleGuardBook:setRoad1(rd)
	self._road1 = rd
end

function SingleGuardBook:getRoad2()
	return self._road2
end

function SingleGuardBook:setRoad2(rd)
	self._road2 = rd
end

function SingleGuardBook:getRoad3()
	return self._road3
end

function SingleGuardBook:setRoad3(rd)
	self._road3 = rd
end

function SingleGuardBook:getRoad4()
	return self._road4
end

function SingleGuardBook:setRoad4(rd)
	self._road4 = rd
end

function SingleGuardBook:getLastRoundTime()
	return self._lastRoundTime
end

function SingleGuardBook:setLastRoundTime(time)
	self._lastRoundTime = time
end

function SingleGuardBook:addPosMon(monID)
	self._monterID[monID] = true
end

function SingleGuardBook:removePosMon(monID)
	self._monterID[monID] = nil
end

function SingleGuardBook:getAllPosMon()
	return self._monterID
end

function SingleGuardBook:setStartTime()
	self._startTime = os.time()
end

function SingleGuardBook:getStartTime()
	return self._startTime
end

function SingleGuardBook:onCopyDone()
	
end

function SingleGuardBook:setStatueID(id)
	self._statueID = id
end

function SingleGuardBook:getStatueID()
	return self._statueID
end

function SingleGuardBook:setFinishTime(ftime)
	self._finishTime = ftime
end

function SingleGuardBook:getFinishTime()
	return self._finishTime
end

function SingleGuardBook:setCurrCircle(circle)
	self._currCircle = circle
end

function SingleGuardBook:getCurrCircle()
	return self._currCircle
end

function SingleGuardBook:getCurRound()
	return self._curRound
end

function SingleGuardBook:setCurRound(round)
	self._curRound = round
end

function SingleGuardBook:getLastFlushRoad()
	return self._lastFlushRoad
end

function SingleGuardBook:setLastFlushRoad(road1,road2,road3,road4)
	self._lastFlushRoad[1] = road1
	self._lastFlushRoad[2] = road2
	self._lastFlushRoad[3] = road3
	self._lastFlushRoad[4] = road4
end

--添加奖励
function SingleGuardBook:doReward()
end

function SingleGuardBook:clearBook()
	local currInstId = self:getCurrInsId()				--当前副本ID
	local copyTeamID = self:getPlayerID()
	local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
	if copyTeam then
		local allCopyMems = copyTeam:getAllMember()

		for i=1, #allCopyMems do
			local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
			local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())	--玩家的副本数据
			if copyPlayer then
				if  player and copyPlayer:getCurCopyInstID() == currInstId then
					local roleID =	player:getID()
					g_copyMgr:dealExitCopy(player, copyPlayer,true)
					g_copySystem:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
				end
			end
		end
	else
		local player = g_entityMgr:getPlayer(self:getPlayerID())
		local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())	--玩家的副本数据
		if copyPlayer and copyPlayer:getCurCopyInstID() == currInstId then
			g_copyMgr:dealExitCopy(player, copyPlayer,true)
			g_copySystem:fireMessage(COPY_CS_EXITCOPY, player:getID(), EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
		end
	end
end

--副本同步怪物数量
function SingleGuardBook:notifyMonsterNum(monSID)
	print("=====================notifyMonsterNum:", monSID)
	local ret = {}
	ret.monsterSid = monSID
	ret.copyId = 0
	ret.monsters = {}

	for _,v in pairs(self:getKilledMonsters()) do
		local info = {}
		info.monsterSid = v.mid
		info.monsterNum = v.num
		table.insert(ret.monsters,info)
	end
	fireProtoMessage(self:getPlayerID(), COPY_SC_ONMONSTERKILL, 'CopyOnMonsterKillProtocol', ret)
end

function SingleGuardBook:OnCopyInit(player)
	print("=============================OnCopyInit")
	local proto = self:getPrototype()
	if proto then
		self:setOldPkMode(player:getPattern())
		self:setOldCampId(player:getCampID())
		player:setPattern(ePattern_Team)
		local assistants = proto:getData().assistants
		for _, monsterData in pairs(assistants) do	
			print("----SingleGuardBook:OnCopyInit call assistMon", monsterData[1])
			local scene = player:getScene()
			local pos = player:getPosition()
			local monster = g_entityFct:createMonster(monsterData[1])
			if monster and scene then
				if scene:attachEntity(monster:getID(), monsterData[2], monsterData[3]) then
					monster:setCampID(player:getID())
					scene:addMonster(monster)
				else
					print("----SingleGuardBook:OnCopyInit call assistMon attachEntity failed", monster and monster:getSerialID())
					g_entityMgr:destoryEntity(monster:getID())
				end
			end
		end
	end

end