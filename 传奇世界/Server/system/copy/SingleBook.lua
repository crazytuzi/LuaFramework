--SingleBook.lua
--单人副本

SingleBook = class(CopyBook)

function SingleBook:__init()
	self._currCircle = 1		--当前怪物刷新环数，第几波
end

function SingleBook:setStartTime()
	self._startTime = os.time()
end

function SingleBook:setCurrCircle(circle)
	self._currCircle = circle
end

function SingleBook:getCurrCircle()
	return self._currCircle
end

--设置副本BOSS ID
function SingleBook:setBossID(bossID)
	self._bossID = bossID
end

--获取副本BOSS ID
function SingleBook:getBossID()
	return self._bossID
end

--设置副本结束时间
function SingleBook:setCopyEndTime(time)
	self._copyEndTime = time
end

--获取副本结束时间
function SingleBook:getCopyEndTime()
	return self._copyEndTime
end

--单人副本奖励
function SingleBook:doReward1(newTime)
	local playerID = self:getPlayerID()
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	local player = g_entityMgr:getPlayer(playerID)
	if not copyPlayer or not player then return end
	local proto = self:getPrototype()
	local itemMgr = player:getItemMgr()
	local first = proto:getFirstReward()
	local rewardTab = proto:getRewardID()
	local curCopyID = proto:getCopyID()
	local ratetime = copyPlayer:getRatingTime(curCopyID)
	local offlineMgr = g_entityMgr:getOfflineMgr()

	local prizeTime = g_ActivityMgr:finishCopy(playerID, proto:getCopyID())
	if first ~= nil and ratetime == 0 then
		--给第一次通关奖励
		--g_entityMgr:dropItemToEmail(player:getSerialID(), first, 1, 108, false, proto:getName())
		--CopySystem:getInstance():fireMessage(0,playerID, EVENT_COPY_SETS, COPY_MSG_FIRST_REWARD, 1, proto:getName())
		--print("SingleBook:doReward1 first reward",first)
		for i = 1, prizeTime do
			rewardByDropID(player:getSerialID(), first, 1, 108)
		end
	end
	local rewardID = 0
	rewardID = rewardTab[1]

	--local ratingTab = proto:getRatingTime()
	--print("SingleBook:doReward1",newTime,ratingTab[1])
	--if newTime <= ratingTab[1] then
	--	rewardID = rewardTab[1]
	--elseif newTime <= ratingTab[2] then
	--	rewardID = rewardTab[2]
	--else
	--	rewardID = rewardTab[3]
	--end

	local ecode = 0
	local ret1 = false
	local rewardData = ""
	for i = 1, prizeTime do
		local prizeret1, prizerewardData = rewardByDropID(player:getSerialID(), rewardID, 11,108)
		rewardData = prizerewardData
	end
	
	local ret = {}
	ret.copyResult = 1
	ret.copyUseTime = newTime
	local rewards = unserialize(rewardData)
	ret.rewardCount = table.size(rewards)
	ret.info = {}
	for _, info in pairs(rewards) do
		local prize = {}
		prize.rewardId = info.itemID
		prize.rewardCount = info.count
		prize.bind = info.bind
		prize.strength = info.strength
		table.insert(ret.info,prize)
	end
	fireProtoMessage(playerID, COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)
end

function SingleBook:doReward(newTime)
	if self:getAutoProgress() then
		self:doReward1(newTime)
	else
		self:doReward1(newTime)
	end
end

--单人副本资源回收
--1 T人 更新个人副本数据
--2 清怪
--3 清地图
function SingleBook:clearBook()
	local currInstId = self:getCurrInsId()				--当前副本ID
	print(string.format("SingleBook:clearBook %d[%d:%d]",self._playerID,self._copyID,currInstId))

	local roleID = self._playerID
	local player = g_entityMgr:getPlayer(self._playerID)		--单人副本记录的玩家ID
	local copyPlayer = g_copyMgr:getCopyPlayer(self._playerID)	--玩家的副本数据
	if copyPlayer and player and copyPlayer:getCurCopyInstID() == currInstId then
		--用完要清空
		copyPlayer:clearGuardReward()
		g_copyMgr:dealExitCopy(player, copyPlayer)
	
		if table.size(copyPlayer:getProRewards()) ~= 0 then
			--告诉前端有奖励可领
			--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_NOTIFYPROREWARD)
			g_engine:fireLuaEvent(roleID, buffer)]]
			local ret = {}
			fireProtoMessage(roleID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
			--g_copyMgr:doSendProReward(copyPlayer)
		end
		g_copySystem:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
	else
		print("SingleBook:clearBook, invalid _playerID")
		g_copyMgr:releaseCopy(currInstId, self:getPrototype():getCopyType())
	end
end

--副本同步怪物数量
function SingleBook:notifyMonsterNum(monSID)
	local ret = {}
	ret.monsterSid = monSID
	ret.copyId = self:getPrototype():getCopyID()
	fireProtoMessage(self._playerID, COPY_SC_ONMONSTERKILL, 'CopyOnMonsterKillProtocol', ret)

end
