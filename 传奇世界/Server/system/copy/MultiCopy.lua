--MultiCopy.lua
--守护副本

MultiCopy = class(CopyBook)

function MultiCopy:__init()
	self._currCircle = 1	--当前怪物刷新环数，第几波
	self._finishTime = 0	--此副本完成时间
	self._startTime = 0	--开始时间，10秒后才开始刷怪的
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

function MultiCopy:getCurrentCircle()
	return self._currentCircle
end

function  MultiCopy:setCurrentCircle(circle)
	self._currentCircle = circle
end

function MultiCopy:getRoad1()
	return self._road1
end

function MultiCopy:setRoad1(rd)
	self._road1 = rd
end

function MultiCopy:getRoad2()
	return self._road2
end

function MultiCopy:setRoad2(rd)
	self._road2 = rd
end

function MultiCopy:getRoad3()
	return self._road3
end

function MultiCopy:setRoad3(rd)
	self._road3 = rd
end

function MultiCopy:getRoad4()
	return self._road4
end

function MultiCopy:setRoad4(rd)
	self._road4 = rd
end


function MultiCopy:getLastRoundTime()
	return self._lastRoundTime
end

function MultiCopy:setLastRoundTime(time)
	self._lastRoundTime = time
end

function MultiCopy:addPosMon(monID)
	self._monterID[monID] = true
end

function MultiCopy:removePosMon(monID)
	self._monterID[monID] = nil
end

function MultiCopy:getAllPosMon()
	return self._monterID
end

function MultiCopy:setStartTime()
	self._startTime = os.time()
end

function MultiCopy:getStartTime()
	return self._startTime
end

function MultiCopy:onCopyDone()
	
end

function MultiCopy:setStatueID(id)
	self._statueID = id
end

function MultiCopy:getStatueID()
	return self._statueID
end

function MultiCopy:setFinishTime(ftime)
	self._finishTime = ftime
end

function MultiCopy:getFinishTime()
	return self._finishTime
end

function MultiCopy:setCurrCircle(circle)
	self._currCircle = circle
end

function MultiCopy:getCurrCircle()
	return self._currCircle
end

function MultiCopy:getCurRound()
	return self._curRound
end

function MultiCopy:setCurRound(round)
	self._curRound = round
end

function MultiCopy:getLastFlushRoad()
	return self._lastFlushRoad
end

function MultiCopy:setLastFlushRoad(road1,road2,road3,road4)
	self._lastFlushRoad[1] = road1
	self._lastFlushRoad[2] = road2
	self._lastFlushRoad[3] = road3
	self._lastFlushRoad[4] = road4
end

--添加奖励
function MultiCopy:doReward()
	local copyTeamID = self:getPlayerID()
	local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
	if not copyTeam then
		return 
	end
	local nowTime = os.time()
	local proto = self:getPrototype()
	local allCopyMems = copyTeam:getAllMember()
	local allsid = {}
	
	for i=1, #allCopyMems do
		local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
		local memCopyPlayer = g_copyMgr:getCopyPlayer(player:getID())
		if memCopyPlayer and player then
			local itemMgr = player:getItemMgr()
			local roleSID = player:getSerialID()
			local roleID = player:getID()
			local ret = {}
			ret.copyResult = 2
			ret.copyUseTime = nowTime - self._startTime
			local currCircle = self:getCurrCircle()
			if memCopyPlayer:getMultiGuardCnt(proto:getCopyID()) < currCircle and player:getMapID() == 5104 then
				local currentGuardCnt = memCopyPlayer:getMultiGuardCnt(proto:getCopyID())
				memCopyPlayer:addMultiGuardCnt(self:getCopyID(),self:getCurrCircle())
				local ret1,rewardData = rewardByDropID(roleSID, proto:getFirstReward()[currCircle], 59,19)
				local rewards = unserialize(rewardData)
				ret.rewardCount = table.size(rewards)
				ret.info = {}
				for _, info in pairs(rewards) do
					local prize = {}
					prize.rewardId = info.itemID
					prize.rewardCount = info.count
					table.insert(ret.info,prize)
				end
			end
			fireProtoMessageBySid(allCopyMems[i], COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)
			

			if memCopyPlayer:getCurrentMultiCopyLevel()<=proto.data.copyID and self:getCurrCircle()==proto:getMaxCircle() then
				memCopyPlayer:setCurrentMultiCopyLevel(proto.data.copyID+1)
				memCopyPlayer:setUpdateCopyCnt(true)
				local ret = {}
				ret.currentLv = memCopyPlayer:getCurrentMultiCopyLevel()
				fireProtoMessage(roleID,COPY_SC_MULTICOPY_UPLV,"MultiCopyUpLvProtocol",ret)
			end
			g_copySystem:writeMultiCopyRec(copyTeam, self, 2)
		end
	end
end

function MultiCopy:clearBook()
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
	end
end