--CopyBook.lua
--副本基类

CopyBook = class(nil)

local prop = Property(CopyBook)
prop:accessor("currInsId", 0)		--实例Id
prop:reader("prototype")		--副本的原型对象
prop:accessor("playerID")		--玩家ID
---------------------------------------
--副本原型数据接口
---------------------------------------
local proto = Prototype(CopyBook, prop, CopyBook.getPrototype, false)
proto:reader("copyID", -1)		--原型id
proto:reader("name")			--名字
proto:reader("level")			--等级限制
proto:reader("maxCount", -1)	--数量上限
proto:reader("period", -1)		--销毁时限(period > 0表示限时副本)
proto:reader("CDCount", 1)		--冷却周期可进入副本次数
proto:reader("actions")			--事件流
proto:reader("ratingTime")		--评级时间
proto:reader("rewardID")			--通关奖励
proto:reader("relive")		--能否复活
proto:reader("reliveMat")	--能够使用道具复活
proto:reader("autoProgress")	--能否扫荡
proto:reader("nextCopy")
proto:reader("maxCircle")	--一共有几个阶段



function CopyBook:__init(playerid, copyID,prototype)
	self.prototype = prototype
	self._copyID = copyID
	self._playerID = playerid 	--如果是多人本这里表示副本队伍ID
	self._status = CopyStatus.Active
	self._scenes = {}
	self._startTime = os.time()
	self._remainTime = 0
	self._monsterNum = 0	--副本中怪物数量
	self._deadTime = 0	--玩家死亡的时间，用来计算用道具复活的时间，时间到了没复活则直接失败
	self._monsClearTime	= 0 --打完一波怪物的时间
	self._endTime = 0
	self._killedMonster = {}
	self._oldPkMode = 0
	self._oldCampId = 0
end

function CopyBook:__release()
	self._copyID = nil
	self._playerID = nil
	self._status = nil
	self._scenes = nil
	self._startTime = nil
	self._monsterNum = nil
	self._remainTime = nil
	self.prototype = nil
end

function CopyBook:getKilledMonsters()
	return self._killedMonster
end

function CopyBook:addKilledMonster(monsterid)
	local find = false
	if self._killedMonster==nil then
		self._killedMonster = {}
	end
	for _,info in pairs(self._killedMonster) do
		if info.mid==monsterid then
			info.num = info.num + 1
			find = true
			break 
		end
	end
	if find == false then
		info = {}
		info.mid = monsterid
		info.num = 1
		table.insert(self._killedMonster,info)
	end
end

function CopyBook:clearKilledMonster()
	self._killedMonster = nil
end

function CopyBook:setMonsClearTime(t)
	self._monsClearTime = t
end

function CopyBook:getOldPkMode()
	return self._oldPkMode
end

function CopyBook:setOldPkMode(t)
	self._oldPkMode = t
end

function CopyBook:getOldCampId()
	return self._oldCampId
end

function CopyBook:setOldCampId(t)
	self._oldCampId = t
end

function CopyBook:getMonsClearTime()
	return self._monsClearTime
end

function CopyBook:setDeadTime(t)
	self._deadTime = t
end

function CopyBook:getDeadTime()
	return self._deadTime
end

--增加好友镜像怪物
function CopyBook:addCallFriMon(friMon)
	self:setCallFriMonID(friMon:getID())
	local enterPos = self:getPrototype():getEnterPos()
	return g_sceneMgr:enterCopyBookScene(self:getCurrInsId(), friMon:getID(), self:getPrototype():getMapID(), enterPos[1] + 2, enterPos[2] + 2)
end

--援护好友镜像ID
function CopyBook:getCallFriMonID()
	return 0
end

--援护好友镜像ID 爬塔实现
function CopyBook:setCallFriMonID(id)
	
end

--雕像ID
function CopyBook:getStatueID()
	return 0
end

--设置雕像ID  只有守护副本才实现
function CopyBook:setStatueID(id)

end

function CopyBook:getMonsterNum()
	return self._monsterNum
end

function CopyBook:changeMonsterNum(val)
	self._monsterNum = (self._monsterNum + val) > 0 and (self._monsterNum + val) or 0
end

function CopyBook:setMonsterNum(val)
	-- body
	self._monsterNum = val
end

function CopyBook:pauseBook()
	self._remainTime = self:getRemainTime()
end

function CopyBook:resumeBook()
	self._startTime = os.time() + self._remainTime - self:getPeriod()
end

--@brief:获取限时副本的剩余时间
--@note:只限于限时副本
function CopyBook:getRemainTime()
	return self._startTime - os.time() + self:getPeriod()
end

function CopyBook:getStartTime()
	return self._startTime
end

function CopyBook:getPlayerID()
	return self._playerID
end

function CopyBook:setStatus(state)
	self._status = state
end

function CopyBook:getStatus()
	return self._status
end

function CopyBook:setCurrCircle(circle)
end

function CopyBook:getCurrCircle()
end

function CopyBook:setFinishTime(ftime)
end

function CopyBook:getFinishTime()
end

function CopyBook:setEndTime(ftime)
	self._endTime = ftime
end

function CopyBook:getEndTime()
	return self._endTime
end

function CopyBook:getTakeTime()
	return os.time() - self._startTime
end

function CopyBook:onFinishCopy(copyPlayer)
	self._status = CopyStatus.Done
	self._endTime = os.time()   
	local copyType = self:getPrototype():getCopyType()
	local player = nil
	if copyType ~= CopyType.MultiCopy then
		player = g_entityMgr:getPlayer(self._playerID)
		if not player then return end
	end

	local singleInstID = g_copyMgr:getSingleInstIDByCopyID(self._copyID)
	--print(player:getSerialID(), "onFinishCopy:", self._copyID, "singleInstID:" ,singleInstID)
	local singleInstProto = g_copyMgr:getSingleInstProto(singleInstID)
	if singleInstProto then
		copyPlayer:onFinishSingleInst(singleInstID)
	end
	local proto = g_copyMgr:getProto(self._copyID)
	
	if copyType == CopyType.MultiCopy then
		local copyTeam = g_copyMgr:getCopyTeam(self._playerID)
		local allCopyMems = copyTeam:getOnLineMems()
		local allsid = {}
		for i=1, #allCopyMems do
			local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
			local memCopyPlayer = g_copyMgr:getCopyPlayer(memPlayer:getID())
			if memPlayer then
				g_logManager:writeCopyInfo(memPlayer:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 1,self:getStartTime())
				g_ActivityMgr:sevenFestivalChange(memPlayer:getID(), ACTIVITY_ACT.GUARD, 1)
				g_achieveSer:achieveNotify(memPlayer:getSerialID(), AchieveNotifyType.doneGuards, 1)
				g_normalMgr:activeness(memPlayer:getID(),ACTIVENESS_TYPE.GUARD)
				g_achieveSer:achieveNotify(memPlayer:getSerialID(), AchieveNotifyType.doneCopy, 1,self._copyID)
			end
			table.insert(allsid,allCopyMems[i])
			g_tlogMgr:TlogDRSWFlow(player,memCopyPlayer:getCurrentMultiCopyLevel(),self:getCurrCircle(),0,1)
			local ret = {}
			ret.copyResult = 1
			fireProtoMessage(memPlayer:getID(), COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)
		end
		if #allCopyMems==1 then
			local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[1])
			g_achieveSer:achieveNotify(memPlayer:getSerialID(), AchieveNotifyType.doneGuardsSingle, 1)
		else
			for i=1, #allCopyMems do
				local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
				g_masterMgr:finishMasterTask(MASTER_TASK_ID.GUARD, memPlayer:getSerialID(),allsid)
			end
		end	
	else
		g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 1,self:getStartTime())
	end

	if copyType == CopyType.NewSingleCopy then
		g_tlogMgr:TlogTLCSFlow(player, self:getTakeTime(), 1, proto:getCopyID())
		--g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.TULONG, 1)
		g_normalMgr:activeness(player:getID(),ACTIVENESS_TYPE.TULONG)
	elseif copyType == CopyType.TowerCopy then
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.TOWER, proto:getCopyLayer())
		g_normalMgr:activeness(player:getID(),ACTIVENESS_TYPE.TOWER)
	end
	if copyType ~= CopyType.MultiCopy then
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.doneCopy, 1,self._copyID)
	end

	return singleInstProto
end

function CopyBook:doReward()
end

function CopyBook:OnCopyInit( player )
end

function CopyBook:OnCopyLogicUpdate()
end

function CopyBook:OnMonsterDead(monSID, roleID, monID)
end

function CopyBook:createBookScene(mapID)
	local scene = g_sceneMgr:createCopyScene(self:getCurrInsId(), mapID)
	if scene then
		print("==========createBookScene========"..mapID)
		local mapID = scene:getMapID()
		self._scenes[mapID] = scene:getID()
		return true
	else
		print("==========createBookScene Fail========"..mapID)
		return false
	end
end

function CopyBook:getScene(mapID)
	local sceneid = self._scenes[mapID]
	local scene  = g_sceneMgr:getById(sceneid) 
	if scene then 
		return scene 
	else 
		print("CopyBook:getScene scene is nil!",mapID,toString(sceneid))
		return nil 
	end
end

function CopyBook:getAllScene()
	return self._scenes
end

function CopyBook:addScene(mapID, sceneid)
	self._scenes[mapID] = sceneid
end

--副本关闭场景
function CopyBook:_close()
	if self:getStatueID() > 0 then
		--删除雕像
		g_entityMgr:destoryEntity(self:getStatueID())
	end
	if self:getCallFriMonID() > 0 then
		--删除好友援护镜像怪物
		g_entityMgr:destoryEntity(self:getCallFriMonID())
	end
	for mapID, sceneid in pairs(self._scenes) do
		if sceneid then
			local scene = g_sceneMgr:getById(sceneid)
			if scene then
				self:roleBackMonster()
				--g_sceneMgr:releaseScene(scene, self:getCurrInsId())
				g_copyMgr:addToDeleteList(scene,self:getCurrInsId())
			else
				print("CopyBook:close scene empty!!",mapID)
			end
		end
	end
end

--副本失败回滚删除所有的怪物
function CopyBook:roleBackMonster()
	for mapID, sceneid in pairs(self._scenes) do
		if sceneid then
			local scene = g_sceneMgr:getById(sceneid)
			if scene then
				scene:releaseAllMonsters()
			else
				print("CopyBook:roleBackMonster scene empty!!",mapID)
			end
		end
	end
end

--副本失败处理
function CopyBook:copyFailed()
	self:setStatus(CopyStatus.Failed)
	self._endTime = os.time()                --记录副本的结束时间
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_COPYREWARD)
	buffer:pushBool(false)]]
	local ret = {}
	ret.copyResult = 0
	if self:getPrototype():getCopyType() == CopyType.MultiCopy then
		local copyTeam = g_copyMgr:getCopyTeam(self._playerID)
		if copyTeam then
			local allCopyMems = copyTeam:getOnLineMems()
			for i=1, #allCopyMems do
				local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
				local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
				g_tlogMgr:TlogDRSWFlow(player,copyPlayer:getCurrentMultiCopyLevel(),self:getCurrCircle(),0,0)
				fireProtoMessage(player:getID(), COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)
			end
		end
	else
		fireProtoMessage(self._playerID, COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)
	end

	--写日志
	local copyType = self:getPrototype():getCopyType()
	if copyType == CopyType.MultiCopy then
		local copyTeam = g_copyMgr:getCopyTeam(self._playerID)
		if copyTeam then
			g_copySystem:writeMultiCopyRec(copyTeam, self, 0)
		end
	else
		local player = g_entityMgr:getPlayer(self._playerID)
		if player then
			local proto = g_copyMgr:getProto(self._copyID)
			g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 0, 0, 1,self:getStartTime())

			if copyType == CopyType.NewSingleCopy then
				g_tlogMgr:TlogTLCSFlow(player, self:getTakeTime(), 0, proto:getCopyID())
			elseif copyType == CopyType.TowerCopy then
				g_tlogMgr:TlogTTTFlow(player,proto:getCopyLayer(),0,self:getTakeTime(),0,0)
			end
		end
		if copyType == CopyType.NewSingleCopy then
			g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.tulongFail, 1)
		end
	end
end

function CopyBook:getLastFlushRoad()
end

function CopyBook:setLastFlushRoad(road,road2)
end

function CopyBook:setStartTime()
end

function CopyBook:addPosMon(monID)
end

function CopyBook:removePosMon(monID)
end

function CopyBook:getAllPosMon()
end

function CopyBook:setSumExp(xp)
end

function CopyBook:getSumExp()
end