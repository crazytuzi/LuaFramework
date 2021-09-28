--TowerBook.lua
--爬塔副本

TowerBook = class(CopyBook)



function TowerBook:__init()
	self._callFriendMon = 0
	self._currCircle = 1
end

function TowerBook:setStartTime()
	self._startTime = os.time()
end

function TowerBook:getCallFriMonID()
	return self._callFriendMon
end

--援护好友镜像ID
function CopyBook:setCallFriMonID(id)
	self._callFriendMon = id
end

function TowerBook:setCurrCircle(circle)
	self._currCircle = circle
end

function TowerBook:getCurrCircle()
	return self._currCircle
end

function TowerBook:doReward(newTime)
	local playerID = self:getPlayerID()
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	local player = g_entityMgr:getPlayer(playerID)
	if not copyPlayer or not player then return end
	local itemMgr = player:getItemMgr()

	local proto = self:getPrototype()
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local rewardTab = proto:getRewardID()
	local rewardID = rewardTab[1]
	
	local ecode = 0
	local ret1, rewardData = rewardByDropID(player:getSerialID(), rewardID, 11,53)
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_COPYREWARD)
	buffer:pushBool(true)
	buffer:pushShort(newTime)
	local rewards = unserialize(rewardData)
	local tmpnt = table.size(rewards)
	buffer:pushChar(tmpnt)
	for _, info in pairs(rewards) do
		buffer:pushInt(info.itemID)
		buffer:pushInt(info.count)
	end
	g_engine:fireLuaEvent(playerID, buffer)]]
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
		table.insert(ret.info,prize)
	end
	fireProtoMessage(playerID, COPY_SC_COPYREWARD, 'CopyRewardProtocol', ret)

	copyPlayer:setUpdateCopyCnt(true)

	--g_CardPrizeMgr:addPrizeInfo(playerID,proto)
	--g_CardPrizeMgr:OpenCardPrizeWindow(playerID,proto:getCopyLayer(),proto:getCopyID())
end

function TowerBook:towerCopyFailed(roleID,copyID)
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_COPYTOWERRESULT)
	buffer:pushInt(roleID)
	buffer:pushShort(0)--表示成功标记
	g_engine:fireLuaEvent(roleID, buffer)]]
	local player = g_entityMgr:getPlayer(roleID)
	local proto = self:getPrototype()
	local ret = {}
	ret.roleId = roleID
	ret.result = 0
	fireProtoMessage(roleID, COPY_SC_COPYTOWERRESULT, 'CopyTowerResultProtocol', ret)

end

function TowerBook:givePrizeToPlayer(rewardID,roleID)
	local pCopyIDs = {}
	local data = {}
	local player = g_entityMgr:getPlayer(roleID)
	local rewardData = dropString(player:getSchool(), player:getSex(), rewardID)
	if #rewardData == 0 then
		print("-----给副本奖励取不到普通掉落")
	end
	for i=1, #rewardData do
		local tmpresult = rewardData[i]
		local tmpNum = data[tmpresult.itemID] or 0
		data[tmpresult.itemID] = tmpNum + tmpresult.count
	end
	local prizeLen = 0
	for k,v in pairs(data) do
		prizeLen = prizeLen + 1
	end
	self:rewardToPlayer(data,player)
	return data,prizeLen
end

function TowerBook:rewardToPlayer(rewards,player)
	local itemMgr = player:getItemMgr()
   	local offlineMgr = g_entityMgr:getOfflineMgr()
	for id,count in pairs(rewards or {}) do
		local needSolt = itemMgr:putNeedSlot(id, count)
		local freeSlotNum = itemMgr:getEmptySize()
		local itemMgr = player:getItemMgr()
		--如果物品格子数不够就发邮件
		if freeSlotNum < needSolt then
			local email = offlineMgr:createEamil()
			local emailConfigId = 52

			email:setDescId(emailConfigId)						
			email:insertProto(id, count, false, 0)
			offlineMgr:recvEamil(player:getSerialID(), email, 0)
		else
			itemMgr:addItem(1, id, count, true, errId, 0, 0)
		end
	end
end


function TowerBook:doGiveAllReward(roleID,copyID,newTime,oldTime)
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	local proto = self:getPrototype()
	if not proto then 
		print("no proto")
		return
	end	
	if copyPlayer and player then
		local ret = {}
		ret.roleId = roleID
		ret.result = 1
		ret.useTime = copyPlayer and copyPlayer:getRatingTime(copyID) or 0
		ret.info = {}
		local fastData = g_copyMgr:getFastestRecord(copyID, player:getSchool()) or {}
		if #fastData > 0 then
			ret.info.useTime = fastData[1]
			ret.info.name = fastData[3]
			ret.info.battle = fastData[4]
		else
			ret.info.useTime = 0
			ret.info.name = ""
			ret.info.battle = 0
		end
		ret.bestStar = copyPlayer:getRatingStar(copyID)
		ret.newTime = newTime
		local star = 0
		local startimelist = proto and proto:getRatingTime()
		if newTime<=startimelist[3] then star = 1 end
		if newTime<=startimelist[2] then star = 2 end
		if newTime<=startimelist[1] then star = 3 end
		ret.newStar = star
		local rewardTab = proto:getRewardID()
		local rewardID = rewardTab[1]
		local datas,len = self:givePrizeToPlayer(rewardID,roleID)
		ret.prizeNum = len
		ret.rewardInfo = {}
		for id,num in pairs(datas) do
			local rewardInfo = {}
			rewardInfo.rewardId = id
			rewardInfo.rewardCount = num
			table.insert(ret.rewardInfo,rewardInfo)
		end
		fireProtoMessage(roleID, COPY_SC_COPYTOWERRESULT, 'CopyTowerResultProtocol', ret)
		local star = 0
		local startimelist = proto:getRatingTime()
		if newTime<=startimelist[3] then star = 1 end
		if newTime<=startimelist[2] then star = 2 end
		if newTime<=startimelist[1] then star = 3 end
		g_tlogMgr:TlogTTTFlow(player,proto:getCopyLayer(),star,newTime,1,0)
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.tongtianStar, copyPlayer:calPlayerCopyStarCount())
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.tongtianLevel, proto:getCopyLayer())

	end
end

function TowerBook:clearBook()
	local currInstId = self:getCurrInsId()				--当前副本ID

	local roleID = self._playerID
	local player = g_entityMgr:getPlayer(self._playerID)		--单人副本记录的玩家ID
	local copyPlayer = g_copyMgr:getCopyPlayer(self._playerID)	--玩家的副本数据
	if copyPlayer and player and copyPlayer:getCurCopyInstID() == currInstId then
		--用完要清空
		g_copyMgr:dealExitCopy(player, copyPlayer)
	
		if table.size(copyPlayer:getProRewards()) ~= 0 then
			--告诉前端有奖励可领
			local ret = {}
   			fireProtoMessage(roleID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
			--g_copyMgr:doSendProReward(copyPlayer)
		end
		g_copySystem:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
	else
		print("TowerBook:clearBook, invalid _playerID")
		g_copyMgr:releaseCopy(currInstId, self:getPrototype():getCopyType())
	end
end



