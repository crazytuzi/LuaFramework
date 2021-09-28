--CopyManager.lua
--效果基类
require "system.copy.CopyConstant"
require "system.copy.CopyPrototype"
require "system.copy.CopyBook"
require "system.copy.SingleBook"
require "system.copy.GuardBook"
require "system.copy.TowerBook"
require "system.copy.TrivialBook"
require "system.copy.CopySystem"
require "system.copy.CopyPlayer"
require "system.copy.CopyTeam"
require "system.copy.MultiCopy"
require "system.copy.ArenaThreeBook"
require "system.copy.SingleGuardBook"

CopyManager = class(nil, Singleton, Timer)

function CopyManager:__init()
	self._singlePrototypes = {}	--单人副本原型数据
	self._towerPrototypes = {}	--爬塔副本原型
	self._guardPrototypes = {}	--守护副本原型
	self._singleCopy = {}	
	self._towerCopy = {}
	self._guardCopy = {}
	self._multiCopy = {}
	self._copyCounts = {}	--同类型副本数量 以副本ID来计数
	self._progressCopy = {}	--正在扫荡的副本 roleid = {copyID1, copyID2,....}
	self._fastestPlayer = {}	--最快通关记录:{[copyID]={[school]={time,roleSID,name,battlePower}}}
	self._syncFastestRecord = {}	--纪录数据变更
	self._playerCopyData = {}
	self._syncTime = os.time()
	self._offProRewards = {}	--离线玩家的扫荡奖励
	self._mCopyID = 0
	self._delCopyId = {}	--待删除的副本
	self._friendCallData = {}	--好友召唤离线玩家的缓存数据

	self._multiPrototypes = {}	--多人副本原型
	self._copyTeams = {}	--副本队伍,在copyid里面
	self._copyTeamsByID = {}	--副本队伍
	self._openMultiWins = {}	--打开多人面板的人
	self._teamIdx = 0

	self._synMemPosInfos = {}	--需要同步队友位置数据的玩家

	--新增屠龙传说剧情副本
	self._newsinglePrototypes = {}
	self._newsingleCopy = {}

	--新屠龙传说(31 Aug 2016),key word:singleInst
	self._singleInstsPrototypes = {}
	self._singleInstsProtoCopyIDs = {}

	--新增3v3竞技场副本
	self._arenaPrototypes = {}
	self._arenaCopy = {}


	gTimerMgr:regTimer(self, 1000, 1000)
	print("CopyManager Timer", self._timerID_)
	g_listHandler:addListener(self)
	self._toDeleteScenes = {}
	self._toMobMonsters = {}
	self._towercopyswitch = 1
	self._singlecopyswitch = 1
	self._progressTowerCopy = {} -- 通天塔的扫荡数据

	self._trivialPrototypes = {} -- 简单副本
	self._trivialCopy = {}

	self._singleGuardPrototypes = {} -- 单人守卫副本
	self._singleGuardCopy = {}
end

local getOpenWinData = function(roleID)
	--[[local nowTime = os.time()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	
	if copyPlayer then
		local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_OPENCOPYWINRET)
		local allCDData = copyPlayer:getCopyCDCount()
		local singleData = {}
		for mainID, count in pairs(allCDData) do
			--如果在新CD内则只清除CD数
			if copyPlayer:getLastEnterTime(mainID) ~= 0 and nowTime - copyPlayer:getLastEnterTime(mainID) >= ONE_DAY_SEC then
				copyPlayer:clearEnterCDCount(mainID)
			else
				local proto = g_copyMgr:getProto(mainID)
				if proto:getCopyType() == CopyType.SingleCopy then
					if proto:getAutoProgress() then
						singleData[mainID] = count
					end
				end
			end
		end
		buffer:pushShort(table.size(singleData))
		for mainID, count in pairs(singleData) do
			buffer:pushShort(mainID)
			buffer:pushChar(count)
		end

		local singleTab = copyPlayer:getAllRatingTime()
		local num = table.size(singleTab)
		buffer:pushShort(num)
		for id,rateTime in pairs(singleTab) do
			buffer:pushShort(id)
			buffer:pushShort(rateTime)
		end

		--爬塔以及守护副本特殊数据
		local proto = g_copyMgr:getProto(copyPlayer:getMaxTowerLayer())
		if proto then
			buffer:pushShort(proto:getCopyLayer())
		else
			buffer:pushShort(0)
		end
		buffer:pushShort(copyPlayer:getLastGuard())
		buffer:pushShort(copyPlayer:getMaxGuard())
		if nowTime - copyPlayer:getResetGuardTime() > ONE_DAY_SEC then
			copyPlayer:setResetGuardTime(nowTime, 0)
			buffer:pushChar(0)
		else
			buffer:pushChar(copyPlayer:getResetGuardNum())
		end
		if nowTime - copyPlayer:getLastTowerTime() >= ONE_DAY_SEC then
			copyPlayer:setTowerCnt(0, true)
			buffer:pushChar(0)
		else
			buffer:pushChar(copyPlayer:getTowerCnt())
		end
		local specData = copyPlayer:getGuardSpecReward() or {}
		buffer:pushShort(#specData)
		for i=1, #specData do
			local proto = g_copyMgr:getProto(specData[i])
			buffer:pushShort(proto:getCopyLayer())
		end
		--爬塔总次数
		buffer:pushShort(TOWER_ONEDAY_CDCOUNT)
		
		buffer:pushShort(TOWER_RESET_CDCOUNT)

		local towerInner = copyPlayer:getTowerInnerTime()
		if nowTime >= towerInner then
			if towerInner ~= 0 and not copyPlayer:getCanTower() then
				copyPlayer:setCanTower(true)
			end
			buffer:pushShort(0)
		else
			buffer:pushShort(towerInner-nowTime)
		end

		g_engine:fireLuaEvent(roleID, buffer)

		local prodata = g_copyMgr:getProgressingSingle(copyPlayer:getRole():getSerialID())
		if prodata and #prodata > 0 then
			local buffer1 = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_STARTPROGRESSRET)
			buffer1:pushShort(prodata[1][1])
			buffer1:pushShort(prodata[1][2] - nowTime + copyPlayer:getProgressSingleTime())
			g_engine:fireLuaEvent(copyPlayer:getRole():getID(), buffer1)
		end
	end]]
end

function CopyManager:addSynMemPosInfo(roleID)
	self._synMemPosInfos[roleID] = true
end

function CopyManager:removeSynMemPosInfo(roleID)
	self._synMemPosInfos[roleID] = nil
end

function CopyManager:inCopyTeam(roleID)
	local copyPlayer = self._playerCopyData[roleID]
	if copyPlayer then
		return copyPlayer:getCopyTeamID()>0 and true or false
	end
end

function CopyManager:addOpenMultiWin(roleID)
	self._openMultiWins[roleID] = true
end

function CopyManager:removeOpenMultiWin(roleID)
	self._openMultiWins[roleID] = nil
end

function CopyManager:getAllOpenMultiWin()
	return self._openMultiWins
end

--创建副本队伍
function CopyManager:createCopyTeam(playerID, copyID,team)
	--local copyTeam = CopyTeam(playerID, self._teamIdx+1)
	if team then
		--成功了才计数
		self._teamIdx = self._teamIdx + 1
		team:setCopyID(copyID)
		if not self._copyTeams[copyID] then self._copyTeams[copyID] = {} end
		self._copyTeams[copyID][self._teamIdx] = team:getTeamID()
		self._copyTeamsByID[self._teamIdx] = team:getTeamID()
		print("create team id is :",team:getTeamID(),self._teamIdx)
		--return copyTeam
	end
end

--切地图
function CopyManager:onSwitchScene(player, mapID)
	--[[local roleID = player:getID()
	local copyPlayer = self:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if copyPlayer and player then
		local copyTeamID = copyPlayer:getCopyTeamID()
		local copyTeam = self:getCopyTeam(copyTeamID)
		if copyTeam then
			g_TeamPublic:onLeaveTeam(player)
		end
	end]]
end

--具体到copyID
function CopyManager:getMultiCopyTeams(copyID)
	return self._copyTeams[copyID] or {}
end

--根据copyTeamID
function CopyManager:getCopyTeam(copyTeamID)
	return g_TeamPublic:getTeam(copyTeamID)
end

function CopyManager:getMultiProtos()
	return self._multiPrototypes
end

function CopyManager:getTowerProtos()
	return self._towerPrototypes
end

function CopyManager:disBandCopyTeam(copyTeamID)
	local copyTeam = self._copyTeamsByID[copyTeamID]
	if copyTeam then
		local copyID = copyTeam:getCopyID()
		if self._copyTeams[copyID] then
			self._copyTeams[copyID][copyTeamID] = nil 
		end 
		self._copyTeamsByID[copyTeamID] = nil
	end
end

function CopyManager:getAllFastRecord()
	return self._fastestPlayer
end

function CopyManager:getOffProRewards()
	return self._offProRewards
end

function CopyManager:doProgressAllTowerByIngot(player)
	if isIngotEnough(player, COPY_TOWER_PROGRESSALL) then
		--请求扣元宝
		local ret = g_tPayMgr:TPayScriptUseMoney(player, COPY_TOWER_PROGRESSALL, 10, "", 0, 0, "CopyManager.doYuanbaoProgressAll") 
		if ret ~= 0 then
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_SYSTEM_BUSY, 0)
			return 
		else
			return
		end
	else
		g_copySystem:fireMessage(COPY_CS_ENTERCOPY, player:getID(), EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
	end
end
function CopyManager.doYuanbaoProgressAll(roleSID, ret, money, itemId, itemCount, callBackContext)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return TPAY_FAILED end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr._playerCopyData[roleID]
	local nowTime = os.time()
	local school = player:getSchool()
	if g_copyMgr._progressTowerCopy and g_copyMgr._progressTowerCopy[roleSID] == nil then
		print("doProgressAllByYuanbao but no progressData!!!")
		return
	end
	local progressNow = g_copyMgr._progressTowerCopy[roleSID].nowProgressId
	local progressMax = g_copyMgr._progressTowerCopy[roleSID].allLen
	local pCopyIDs = {}
	local cID = progressNow+COPY_TOWER_FIRST-1
	local cIDMax = progressMax+COPY_TOWER_FIRST-1
	local bCheckProgress = false
	g_copyMgr._progressTowerCopy[roleSID] = nil
	while cID <= cIDMax do
		local copyID = cID
		local proto = g_copyMgr._towerPrototypes[copyID]
		if proto and proto:getAutoProgress() then
			local rateStar = copyPlayer:getRatingStar(copyID)
			if rateStar==0 then
				break
			end
			if not bCheckProgress then
				bCheckProgress = true
			end
			--copyPlayer:setTowerCopyProgress(copyPlayer:getTowerCopyProgress()+1)
			--progressNow = copyPlayer:getTowerCopyProgress()
			local data = {}
			local rewardTab = proto:getRewardID()
			local rewardData = dropString(player:getSchool(), player:getSex(), rewardTab[1])
			if #rewardData == 0 then
				print("-----一键扫荡取不到普通掉落")
			end

			for i=1, #rewardData do
				local tmpresult = rewardData[i]
				local tmpNum = 0
				if data[tmpresult.itemID] ~= nil then 
					tmpNum = data[tmpresult.itemID].num 
				end
				data[tmpresult.itemID] = {}
				data[tmpresult.itemID].num = tmpNum + tmpresult.count
				data[tmpresult.itemID].bind = tmpresult.bind
			end
			copyPlayer:addEnterCopyCount(copyID)
			if copyPlayer:getTowerCopyActivePrize()==0 then
				g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.TOWER)
				copyPlayer:setTowerCopyActivePrize(1)
			end
			pCopyIDs[copyID] = data
		end
		cID = cID+1
	end
	copyPlayer:setNowProgressCopyId(0,0,0)
	if table.size(pCopyIDs) > 0 then	
		for cid, re in pairs(pCopyIDs) do
			copyPlayer:addProReward(nowTime, cid, re)
		end
		--告诉前端有奖励可领
		local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_NOTIFYPROREWARD)
		g_engine:fireLuaEvent(roleID, buffer)
		g_copySystem:testdoGetTowerCopyData(roleSID)
	end
	if not bCheckProgress then
		g_taskServlet:sendErrMsg2Client(player:getID(), -88, 0)
	end
	copyPlayer:setUpdateCopyCnt(true)
	g_copySystem:testdoGetTowerCopyData(player:getSerialID())
	return TPAY_SUCESS
end
	

--一键扫荡副本
function CopyManager:doProgressAll(player, pType)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local copyPlayer = self._playerCopyData[roleID]
	local nowTime = os.time()
	local school = player:getSchool()
	if pType == CopyType.SingleCopy then
		--直接完成所有的扫荡
		local harvst = true
		if player:getIngot() < COPY_SINGLE_PROGRESSALL then
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_MSG_PROGRESS_INGOT_NOT_ENOUGH, 1, {COPY_SINGLE_PROGRESSALL})
			return
		end

		local pCopyIDs = {}
		for copyID, proto in pairs(self._singlePrototypes) do
			if proto:getAutoProgress() then
				local ret, eCode = CopySystem:getInstance():canEnterCopy(copyPlayer, player, copyID)
				if not ret and eCode then
					if eCode == COPY_ERR_THIS_BOOK_IN_PRO then
						g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, eCode, 0)
						return
					end
				else
					local ratetime = copyPlayer:getRatingTime(copyID)
					if ratetime ~= 0 and ratetime <= proto:getRatingTime()[1] then	
						--满足直接完成的要求 直接完成
						if harvst then
							local data = {}
							local rewardTab = proto:getRewardID()
							local rewardData = dropString(player:getSchool(), player:getSex(), rewardTab[1])
							if #rewardData == 0 then
								print("-----一键扫荡取不到普通掉落")
							end

							for i=1, #rewardData do
								local tmpresult = rewardData[i]
								local tmpNum = 0
								if data[tmpresult.itemID] ~= nil then 
									tmpNum = data[tmpresult.itemID].num 
								end
								data[tmpresult.itemID] = {}
								data[tmpresult.itemID].num = tmpNum + tmpresult.count
								data[tmpresult.itemID].bind = tmpresult.bind
							end
							local rewardData1 = dropString(player:getSchool(), player:getSex(), proto:getShakeReward()[1])--怪物掉落
	
							if #rewardData1 == 0 then
								print("-----一键扫荡取不到怪物掉落")
							end
							--合并到一起
							for i=1, #rewardData1 do
								local tmpresult = rewardData1[i]
								local tmpNum = data[tmpresult.itemID] or 0
								data[tmpresult.itemID] = tmpNum + tmpresult.count
							end
							--计算CD
							copyPlayer:addEnterCopyCount(copyID)
							pCopyIDs[copyID] = data
						else	
							self._progressCopy[roleSID] = self._progressCopy[roleSID] or {}
							self._progressCopy[roleSID].data = self._progressCopy[roleSID].data or {}
							table.insert(self._progressCopy[roleSID].data, {copyID, ratetime})
							self._progressCopy[roleSID].school = player:getSchool()
							self._progressCopy[roleSID].sex = player:getSex()
							copyPlayer:addEnterCopyCount(copyID)
						end
					end
					--写日志
					--void writeCopyInfo(int nRoleSID, int nCopyType, int nCopyID, string copyName, int nCopyLevel, int nEndState, int nCopyGrade, int nFightType, int nStartTick);
					g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 2,os.time())
				end
			end
		end
		if harvst and table.size(pCopyIDs) > 0 then	
			for cid, re in pairs(pCopyIDs) do
				copyPlayer:addProReward(nowTime, cid, re)
			end
			--告诉前端有奖励可领
			local ret = {}
			fireProtoMessage(roleID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
			getOpenWinData(roleID)
		--全部计数完了才标记是否正在扫荡，不然canEnterCopy无法通过
		elseif table.size(self._progressCopy[roleSID] and self._progressCopy[roleSID].data or {}) > 0 then
			copyPlayer:setProgressSingleTime(os.time())
			table.sort(self._progressCopy[roleSID].data, function(a,b) return a[2]<b[2] end)  --按照扫荡时间从小到大排序
			self._progressCopy[roleSID].start = nowTime
			--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_STARTPROGRESSRET)
			buffer:pushShort(self._progressCopy[roleSID].data[1][1])
			buffer:pushShort(self._progressCopy[roleSID].data[1][2])
			g_engine:fireLuaEvent(roleID, buffer)]]
			local ret = {}
			ret.copyId = self._progressCopy[roleSID].data[1][1]
			ret.fastTime = self._progressCopy[roleSID].data[1][2]
			fireProtoMessage(roleID, COPY_SC_STARTPROGRESSRET, 'StartProgressRetProtocol', ret)
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_MSG_STARTPROGRESS, 0)
		else
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_NOCOPY_TORESET, 0)
			return
		end
		player:setIngot(player:getIngot() - COPY_SINGLE_PROGRESSALL)
	elseif pType == CopyType.GuardCopy then
		--TODO 守护副本扫荡
		--等于-1表示还没有打过守护副本
		if copyPlayer:getLastGuardLayer() == -1 then
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_GUARD_TOO_LOWER, 0)
			return
		end
		local maxProto = self:getProto(copyPlayer:getMaxGuardLayer())
		--所有配置副本的最后一关
		if copyPlayer:getLastGuardLayer() == 0 then
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_NEED_RESET_GUARD, 0)
		elseif maxProto:getNextCopy() == copyPlayer:getLastGuardLayer() then
			--守护副本已经在最后一层了
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_GUARD_TOO_LOWER, 0)
		elseif copyPlayer:getIsProgressGuard() then
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_THIS_BOOK_IN_PRO, 0) 
		else
			local tmpID = copyPlayer:getMaxGuardLayer()
			local lastID = copyPlayer:getLastGuardLayer()
			if lastID == 0 then lastID = copyPlayer:getFirstGuardID() end
			local data = {}
			local needMoney = 0
			local actnum = 0

			while(lastID <= tmpID and lastID > 0) do
				local tmpProto = self:getProto(lastID)
				local nowTime = os.time()

				lastID = tmpProto:getNextCopy()
				needMoney = needMoney + tmpProto:getMonValue()
				actnum = actnum+1
				local specRewardID = tmpProto:getSpecReward()
				if specRewardID then
					--给特殊奖励
					copyPlayer:addGuardSpecReward(tmpProto:getCopyID())
				end
			end
			if not isMoneyEnough(player, needMoney, 49) then
				g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_NO_ENOUGH_MONEY, 0) 
				return
			end
			copyPlayer:setProgressGuard(true)
			costMoney(player, needMoney, 49)
			for j=1, actnum do
				g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.GUARD)
			end
			
			--------------------------------------------------------
			--写扫荡日志
			local tmpID2 = copyPlayer:getMaxGuardLayer()
			local lastID2 = copyPlayer:getLastGuardLayer()
			if lastID2 == 0 then lastID2 = copyPlayer:getFirstGuardID() end
			while(lastID2 <= tmpID2 and lastID2 > 0) do
				local tmpProto = self:getProto(lastID2)
				--写日志
				--g_logManager:writeCopyInfo(player:getSerialID(), 3, tmpProto:getName(), 2, 2, 0)
				g_logManager:writeCopyInfo(player:getSerialID(), tmpProto:getCopyType(), lastID2,tmpProto:getName(),tmpProto:getCopyLayer(), 2, 0, 2,os.time())
				lastID2 = tmpProto:getNextCopy()
			end
			---------------------------------------------------------
	
			g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_MSG_DONEGUARD_PRO, 0) 
			copyPlayer:setLastGuardLayer(maxProto:getNextCopy())
			copyPlayer:setProgressGuard(false)
			getOpenWinData(roleID)
		end
	elseif pType == CopyType.TowerCopy then

		local progressNow = copyPlayer:getTowerCopyProgress()
		local copyID = progressNow+COPY_TOWER_FIRST-1
		local tellError = false
		local isAdded = false
		local firstProgress = COPY_TOWER_LAST
		local lastProgress = COPY_TOWER_FIRST
		local roleSID = player:getSerialID()
		self._progressTowerCopy[roleSID] = {}
		self._progressTowerCopy[roleSID].allProgressCopy = {}
		self._progressTowerCopy[roleSID].allLen = 0
		for i=copyID,COPY_TOWER_LAST do
			if self:CanProgressTowerCopy(player,copyPlayer,i,tellError) then
				if firstProgress > i then
					firstProgress = i
				end
				if lastProgress < i then
					lastProgress = i
				end
				self:addTowerProgressCopy(player,i,COPY_TOWER_PROGRESS_TIME,progressNow)
				isAdded = true
			end
		end
		if not isAdded then
			g_copySystem:fireMessage(0, player:getID(), EVENT_TASK_SETS, -88, 0)
			return
		end
		copyPlayer:setNowProgressCopyId(firstProgress,os.time(),COPY_TOWER_PROGRESS_TIME)
		copyPlayer:setTowerCopyProgress(lastProgress-COPY_TOWER_FIRST+2)
		copyPlayer:setUpdateCopyCnt(true)
		local ret = {}
		ret.copyType = CopyType.TowerCopy
		ret.copyId = firstProgress
		ret.leftTime = COPY_TOWER_PROGRESS_TIME
		fireProtoMessage(player:getID(),COPY_SC_START_PROGRESS_ONE ,"CopyTowerStartProgressOneProtocol",ret)
	
	end
end
function CopyManager:RandomGetCardPrize(prizelist)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local rnd = math.random(100)
	if not prizelist then return end
	local count = 0
	local rewardData = {}
	local ret = false
	for v,k in pairs(prizelist) do
		prize = v
		count = k+count
		if count >= rnd then
			return prize
		end
	end
end
function CopyManager:removeProgressCopy(roleSID, copyID)
	local prodata = self._progressCopy[roleSID]
	if prodata then
		for i=1, #prodata.data or {} do
			if prodata.data[i][1] == copyID then
				table.remove(prodata.data, i)
				break
			end
		end
		prodata.start = os.time()
	end
end

function CopyManager:removeRoleProgress(roleSID)
	self._progressCopy[roleSID] = nil
	self._offProRewards[roleSID] = nil
end

function CopyManager:addProgressCopy(player, copyID, needTime)
	local roleSID = player:getSerialID()
	self._progressCopy[roleSID] = self._progressCopy[roleSID] or {}
	self._progressCopy[roleSID].data = self._progressCopy[roleSID].data or {}
	table.insert(self._progressCopy[roleSID].data, {copyID, needTime})
	--self._progressCopy[roleSID].data[copyID] = needTime
	self._progressCopy[roleSID].start = os.time()
	self._progressCopy[roleSID].school = player:getSchool()
	self._progressCopy[roleSID].sex = player:getSex()
	if self._playerCopyData[player:getID()]:getProgressSingleTime() == 0 then
		--表明目前并没有副本在扫荡
		self._playerCopyData[player:getID()]:setProgressSingleTime(os.time())
	end
end



--是否正在扫荡某个单人副本
function CopyManager:isProgressingSingle(roleID, copyID)
	if self._progressCopy[roleID] and self._progressCopy[roleID].data then
		for i=1, #self._progressCopy[roleID].data do
			if self._progressCopy[roleID].data[i][1] == copyID then
				return true
			end
		end
		return false
	else	
		return false
	end
end

function CopyManager:getProgressingSingle(roleSID)
	if self._progressCopy[roleSID] and self._progressCopy[roleSID].data then
		return self._progressCopy[roleSID].data
	else	
		return nil
	end
end

--是否正在扫荡
--玩家ID， 扫荡副本类型
function CopyManager:isProgressing(roleID, pType)
	if pType == CopyType.SingleCopy then
		return table.size(self._progressCopy[roleID] and self._progressCopy[roleID].data or {}) > 0 and true or false
	end
end

--掉线暂停
function CopyManager:onPlayerInactive(player)
	local copyPlayer = self._playerCopyData[player:getID()]

	if copyPlayer then
		local roleSID = player:getSerialID()
		local data = copyPlayer:getCurrProReward()
		--保存未领取的守护扫荡奖励
		if data[2] then
			copyPlayer:addProReward(data[1], 0, data[2])
			copyPlayer:clearCurProReward()
		end
		local curInstId = copyPlayer:getCurCopyInstID()
		local curCopyID = copyPlayer:getCurrentCopyID()
		local proto = self:getProto(curCopyID)
		if proto and curInstId > 0 then
			local copyType = proto:getCopyType()
			if copyType~=CopyType.MultiCopy then
				--将当前的守护副本奖励添加到扫荡奖励列表
				--self:doGuardReward(copyPlayer)
				copyPlayer:clearGuardReward()
				self:dealExitCopy(player, copyPlayer)
				self:updateRoleCopy(player:getID())
			end
		end
		if self._progressTowerCopy[roleSID]~=nil then
			--self:stopProgressTowerCopy(player)
		end
		--[[local copyTeam = self:getCopyTeam(copyPlayer:getCopyTeamID())
		if copyTeam then
			copyTeam:removeCopyMem(player:getID())
			g_copySystem:getCopyTeamData(copyTeam)
		end]]
	end
end

--续线继续
function CopyManager:onActivePlayer(player)
	local roleID = player:getID()
	local copyPlayer = self._playerCopyData[roleID]
	if copyPlayer then
		local curInstId = copyPlayer:getCurCopyInstID()
		local curCopyID = copyPlayer:getCurrentCopyID()
		local proto = self:getProto(curCopyID)
		if proto and curInstId > 0 then
			local copyType = proto:getCopyType()
			local book = self:getCopyBookById(curInstId, copyType)
			if book then
				--book:resumeBook()
				--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_ENTERCOPY)
				buffer:pushShort(COPY_MSG_ENTERCOPY)
				buffer:pushInt(curCopyID)
				buffer:pushChar(book:getCurrCircle())]]

				local ret = {}
				ret.msgType = COPY_MSG_ENTERCOPY
				ret.copyId = curCopyID
				ret.curCircle = book:getCurrCircle()
				
				if book:getPrototype():getCopyType() == CopyType.MultiCopy then
					ret.remainTime = os.time() - book:getStartTime()
					fireProtoMessage(roleID, COPY_SC_ENTERCOPY, 'EnterCopyRetProtocol', ret)
					local statue = g_entityMgr:getMonster(book:getStatueID())
					local ret1 = {}
					if statue then
						ret1.statueHp = statue:getHP()
					else
						ret1.statueHp = 0
					end
					fireProtoMessage(roleID, COPY_SC_NOTIFYSTATUEHP, 'CopyNotifyStatueHpProtocol', ret1)

					local ret2 = {}
					ret2.copyType = book:getPrototype():getCopyType()
					ret2.curCircle = book:getCurrCircle()
					ret2.remainTime = os.time() - book:getStartTime()
					
					fireProtoMessage(roleID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret2)

					local ret3 = {}
					ret3.currCircle = book:getCurrentCircle()
					ret3.flushRoad1 = book:getRoad1()
					ret3.flushRoad2 = book:getRoad2()
					ret3.flushRoad3 = book:getRoad3()
					ret3.flushRoad4 = book:getRoad4()
					ret3.currentPrizeStage = copyPlayer:getMultiGuardCnt(proto:getCopyID())
					fireProtoMessage(roleID, COPY_SC_MULTICOPY_FLUSH_ROAD, 'MultiCopyFlushRoadProtocol', ret3)
					--g_copySystem:notifyMonsterNum(copyPlayer:getCopyTeamID(), 0,book)

					local ret4 = {}
					ret4.monsterSid = 0
					ret4.copyId = 0
					ret4.monsters = {}

					for _,v in pairs(book:getKilledMonsters()) do
						local info = {}
						info.monsterSid = v.mid
						info.monsterNum = v.num
						table.insert(ret4.monsters,info)
					end
					fireProtoMessage(roleID, COPY_SC_ONMONSTERKILL, 'CopyOnMonsterKillProtocol', ret4)
				else
					ret.remainTime = book:getRemainTime()
					fireProtoMessage(roleID, COPY_SC_ENTERCOPY, 'EnterCopyRetProtocol', ret)
				end




			end
		end
		--守护副本扫荡奖励
		local currProReward = copyPlayer:getCurrProReward()
		if #currProReward > 0 then
			copyPlayer:addProReward(currProReward[1], 0, currProReward[2])
			copyPlayer:clearCurProReward()
		end
		if table.size(copyPlayer:getProRewards()) ~= 0 then
		--告诉前端有奖励可领
			local ret = {}
			fireProtoMessage(roleID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
		end
		local roleSID = player:getSerialID() 
		if self._progressTowerCopy[roleSID]~=nil then
			local ret = {}
			ret.copyType = CopyType.TowerCopy
			local nowProgressId = self._progressTowerCopy[roleSID].nowProgressId
			local progressData = self._progressTowerCopy[roleSID].allProgressCopy[nowProgressId]
			if progressData then
				ret.copyId = progressData.copyId
				ret.leftTime = progressData.needTime - (os.time() - progressData.start)
				fireProtoMessage(player:getID(),COPY_SC_START_PROGRESS_ONE ,"CopyTowerStartProgressOneProtocol",ret)
			end
		end
	end
end

function CopyManager:onCallSp(player, tabName, datas)
	if tabName == "copy" then
		self:onLoadRoleCopy(player:getID(), datas)
	elseif tabName == "copyreward" then
		self:onLoadCopyReward(player:getID(), datas)
	end
end

function CopyManager.onLoadTowerData(roleSID,datas)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		print("onLoadTowerData, player is nil:", roleSID)
		return
	end
	local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
	if not copyPlayer then
		return
	end
	
	copyPlayer:onLoadTowerData(datas)
end

function CopyManager:onPlayerLoaded(player)
	local roleID = player:getID()
	local copyPlayer = self._playerCopyData[roleID]
	if not copyPlayer then
		copyPlayer = CopyPlayer(player:getID())
		self:addCopyPlayer(roleID, copyPlayer)
	end
	g_entityDao:loadRole(player:getSerialID(), "copy")	
	g_entityDao:loadRole(player:getSerialID(), "copyreward")
	g_entityDao:loadRole(player:getSerialID(), "rolecopytime")
	g_entityDao:loadRole(player:getSerialID(), "rolecopystar")
	g_entityDao:loadRole(player:getSerialID(), "copystarprize")
	g_entityDao:loadRole(player:getSerialID(), "rolesingleinsts")

	g_entityDao:loadTowerData(player:getSerialID())

	--好友援护数据
	if self._friendCallData[player:getSerialID()] then
		--援护CD
		for fid, t in pairs(self._friendCallData[player:getSerialID()][1]) do
			if os.time() - t < HELP_CD_TIME then
				copyPlayer:addFriInviteData(fid, t)
			end
		end
		--援护次数
		copyPlayer:setAllCallCD(self._friendCallData[player:getSerialID()][2])
	end
	self._friendCallData[player:getSerialID()] = nil

	local prodata = self._progressCopy[player:getSerialID()]
	if prodata then
		copyPlayer:setProgressSingleTime(prodata.start)
	end
	local roleSID = player:getSerialID()
	if self._progressTowerCopy[roleSID] then
		local ret = {}
		ret.copyType = CopyType.TowerCopy
		local nowProgressId = self._progressTowerCopy[roleSID].nowProgressId
		local progressData = self._progressTowerCopy[roleSID].allProgressCopy[nowProgressId]
		if progressData then
			ret.copyId = progressData.copyId
			ret.leftTime = progressData.needTime - (os.time() - progressData.start)
			fireProtoMessage(player:getID(),COPY_SC_START_PROGRESS_ONE ,"CopyTowerStartProgressOneProtocol",ret)
		end
	end
end

--切换world的通知
function CopyManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local copyPlayer = self._playerCopyData[roleID]
	if copyPlayer then
		copyPlayer:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function CopyManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_COPY_SETS then
		local roleID = player:getID()
		local copyPlayer = self._playerCopyData[roleID]
		if not copyPlayer then
			copyPlayer = CopyPlayer(player:getID())
			self:addCopyPlayer(roleID, copyPlayer)
		end
		copyPlayer:loadDBDataImpl(player, buff)
	end	
end

function CopyManager:dealExitCopy(player, copyPlayer,noRemoveMem)
	--副本队伍数据
	player:setCampID(0)
	local curInstId = copyPlayer:getCurCopyInstID()
	local copy = g_copyMgr:getCopyBookById(curInstId)
	
	
	local curCopyID = copyPlayer:getCurrentCopyID()
	local proto = g_copyMgr:getProto(curCopyID)
	if proto then
		local copyType = proto:getCopyType()
		if copy and copyType==CopyType.TowerCopy then
			local proto = g_copyMgr:getProto(copy._copyID)
			g_tlogMgr:TlogTTTFlow(player,proto:getCopyLayer(),0,copy:getTakeTime(),0,0)
		elseif copy and copyType==CopyType.MultiCopy then
			if copy:getCurrCircle()<proto:getMaxCircle() then
				g_TeamPublic:onLeaveTeam(player)
			end
		elseif 	copy and copyType==CopyType.ArenaThree then
			player:setPattern(copy:getOldPkMode())
		elseif copyType == CopyType.SingleGuard then
			player:setPattern(copy:getOldPkMode())
			player:setCampID(copy:setOldCampId())
		end
		local copyTeam = self:getCopyTeam(copyPlayer:getCopyTeamID())
		if proto and curInstId > 0 then
			if copy then 
				g_tlogMgr:TlogDRSWFlow(player,copyPlayer:getCurrentMultiCopyLevel(),copy:getCurrCircle(),0,0)
			end		
			copyPlayer:exitCopy()
			if not copyTeam then
				self:releaseCopy(curInstId, copyType)
			else
				local allCopyMems = copyTeam:getAllMember()
				local sid = player:getSerialID()
				local hasMemberInCopy = false
				for i=1, #allCopyMems do
					if allCopyMems[i]~=sid then
						local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
						local memCopyPlayer = self:getCopyPlayer(memPlayer:getID())
						if memPlayer:getCopyID()>0 then
							hasMemberInCopy = true
							break
						end
					end
				end
				if not hasMemberInCopy then
					copyTeam:setCopyID(0)
					copyTeam:setNeedBattle(0)
					copyTeam:setInCopy(false)
					self:releaseCopy(curInstId, copyType)
				end

			end
		end
	end
end

function CopyManager:onPlayerOffLine(player)
	--TODO 清除副本
	local copyPlayer = self._playerCopyData[player:getID()]
	if copyPlayer then
		local roleSID = player:getSerialID()			
		local data = copyPlayer:getCurrProReward()
		--保存未领取的守护扫荡奖励
		if data[2] then
			copyPlayer:addProReward(data[1], 0, data[2])
			copyPlayer:clearCurProReward()
		end
		--将当前的守护副本奖励添加到扫荡奖励列表
		--self:doGuardReward(copyPlayer)
		copyPlayer:clearGuardReward()
		g_CardPrizeMgr._prizeInfos[player:getID()] = nil

		self:dealExitCopy(player, copyPlayer)
		self:updateRoleCopy(player:getID())

		local invitedata = copyPlayer:getAllInviteData()
		for fid, t in pairs(invitedata) do
			if os.time() - t >= HELP_CD_TIME then
				invitedata[fid] = nil
			end
		end
		local allCallCD = copyPlayer:getAllCallCD()
		local nt = time.toedition("day")
		for fid, data in pairs(allCallCD) do
			if nt ~= data[1] then
				allCallCD[fid] = nil
			end
		end
		if self._progressTowerCopy[roleSID]~=nil then
			--self:stopProgressTowerCopy(player)
		end
		self._friendCallData[roleSID] = {invitedata, allCallCD}
		self._playerCopyData[player:getID()] = nil

	end
end

function CopyManager:onMonsterKill(monSID, roleID, monID)
	--[[local entity = g_entityMgr:getEntity(roleID)
	local playerID = roleID
	if entity:getType() == eClsTypeMonster then
		--宠物
		if entity:getHost() ~= 0 then
			playerID = entity:getHost()
		end
	end]]
	g_copySystem:onMonsterKill(monSID, roleID, monID)
end

--玩家死亡
function CopyManager:onPlayerDied(player, killerID)
	local copyPlayer = self._playerCopyData[player:getID()]
	if copyPlayer then
		local currInstId = copyPlayer:getCurCopyInstID()
		if currInstId > 0 then
			local copyBook = self:getCopyBookById(currInstId)
			if copyBook then
				local proto = copyBook:getPrototype()
				if proto then
					if proto:getReliveType() == 0 then
						--死亡立刻复活
						local relivePos = proto:getRelivePos()
						player:setHP(player:getMaxHP())
						player:setMP(player:getMaxMP())
						local pScene = copyBook:getScene(player:getMapID())
						if pScene then
							if proto:getCopyType() == CopyType.MultiCopy then
								local copyTeam = self:getCopyTeam(copyPlayer:getCopyTeamID())
								local allCopyMems = copyTeam:getAllMember()
								for i=1, #allCopyMems do
									if allCopyMems[i] == player:getSerialID() then
										pScene:attachEntity(player:getID(), relivePos[i][1], relivePos[i][2])
										local buffmgr = player:getBuffMgr()
										local eCode = 0
										buffmgr:addBuff(16, eCode)
										return
									end
								end
								pScene:attachEntity(player:getID(), relivePos[1][1], relivePos[1][2])
								print("----CopyManager:onPlayerDied err ", player:getSerialID(), proto:getCopyID(), toString(relivePos))
							else
								pScene:attachEntity(player:getID(), relivePos[1], relivePos[2])
							end
						end
					elseif proto:getReliveType() == 2 then
						--只能使用道具复活的副本记录死亡时间 30秒后判断是否失败
						copyBook:setDeadTime(os.time())
						if proto:getCopyType() == CopyType.MultiCopy then
							
							player:setReliveMapID(proto:getMapID())
							local index = math.random(1,4)
							player:setReliveX(proto:getRelivePos()[index][1])
							player:setReliveY(proto:getRelivePos()[index][2])
							player:specialDeadSinging(5*1000)
						end
					elseif proto:getReliveType() == 1 then
						--副本直接失败
						--todo 失败处理
						copyBook:copyFailed()
						--添加待回滚怪物的副本
						self:addRollBackCopy(currInstId)
						--print("CopyManager:onPlayerDied q_relive_=1.0 ", player:getSerialID(), currInstId, proto:getCopyID(),os.time())
					else
						print("no defined proto:getReliveType", player:getSerialID(), proto:getCopyID())
					end
				end
			end
		end
	end
end

function CopyManager:onMonsterHurt(monSID, roleID, hurt, monID)
	if monSID == 9002 then
		local statue = g_entityMgr:getMonster(monID)
		if statue then
			local copyInstId = statue:getOwnCopyID()
			local copy = g_copyMgr:getCopyBookById(copyInstId)
			if copy then
				local ret1 = {}
				ret1.statueHp = statue:getHP()
				local copyTeamID = copy:getPlayerID()
				local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
				if copyTeam then
					local allCopyMems = copyTeam:getAllMember()
					for i=1, #allCopyMems do
						fireProtoMessageBySid(allCopyMems[i], COPY_SC_NOTIFYSTATUEHP, 'CopyNotifyStatueHpProtocol', ret1)
					end
				else
					fireProtoMessage(copy:getPlayerID(), COPY_SC_NOTIFYSTATUEHP, 'CopyNotifyStatueHpProtocol', ret1)
				end
			end
		end
	else
		--[[local player = g_entityMgr:getPlayer(roleID)
		if player then
			local id = player:getID()
			local copyPlayer = g_copyMgr:getCopyPlayer(id)
			if copyPlayer then
				local currInstId = copyPlayer:getCurCopyInstID()
				local copy = g_copyMgr:getCopyBookById(currInstId)
				if copy and copy:getPrototype():getCopyType() == CopyType.MultiCopy then
					local copyTeamID = copy:getPlayerID()
					local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
					if copyTeam then
						copyTeam:addHurt(id, hurt)
					end
				end
			end
		end]]
	end
end

--获取最快纪录
function CopyManager:getFastestRecord(copyID, school)
	if self._fastestPlayer[copyID] then
		return self._fastestPlayer[copyID][school]
	else
		self._fastestPlayer[copyID] = {}
	end
end

function CopyManager:setFastestRecord(copyID, school, useTime, roleSID, name,rolePower)
	local retBuff = LuaEventManager:instance():getWorldEvent(COPY_SS_SETFASTTIME)
	retBuff:pushInt(copyID)
	retBuff:pushInt(school)
	retBuff:pushInt(useTime)
	retBuff:pushInt(roleSID)
	retBuff:pushString(name)
	retBuff:pushInt(rolePower)
	g_engine:fireWorldEvent(0, retBuff)
end

function CopyManager:setFastestRecord2(copyID, school, useTime, roleSID, name,rolePower)
	self._fastestPlayer[copyID] = self._fastestPlayer[copyID] or  {}
	self._fastestPlayer[copyID][school] = {useTime, roleSID, name,rolePower}
	
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	self._syncFastestRecord[copyID] = true
	local proto = self:getProto(copyID)
	if proto then
		--爬塔第一名成就计算 +1
		if proto:getCopyType() == CopyType.TowerCopy then
			g_achieveSer:setfastTower(roleSID, copyID)
			local num = 0
			for id, p in pairs(self._towerPrototypes) do
				local tmp1 = self._fastestPlayer[id]
				if tmp1 then
					local data = tmp1[school]
					if data then
						if data[2] == roleSID then
							num = num + 1
						end
					end
				end
			end
		elseif proto:getCopyType() == CopyType.SingleCopy then
			if proto:getAutoProgress() then
				g_achieveSer:setfastSingle(roleSID, copyID)
				local num = 0
				for id, p in pairs(self._singlePrototypes) do
					local tmp1 = self._fastestPlayer[id]
					if tmp1 then
						local data = tmp1[school]
						if data then
							if data[2] == roleSID then
								num = num + 1
							end
						end
					end
				end
			end
		end
	end
end

function CopyManager:addCopyPlayer(roleID, copyPlayer)
	self._playerCopyData[roleID] = copyPlayer
end

function CopyManager:getCopyPlayer(playerID)
	return self._playerCopyData[playerID]
end

--brief:申请teamID 优先从回收表取
function CopyManager:requestNewId()
	self._mCopyID = self._mCopyID + 1
	if self._mCopyID > 2000000000 then
		self._mCopyID = 1
	end
	return self._mCopyID
end

--创建副本
function CopyManager:createCopy(playerID, copyID)
	local proto = self:getProto(copyID)
	local copyType = proto:getCopyType()
	local newBook
	if copyType == CopyType.SingleCopy then
		newBook = SingleBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._singleCopy[newBook:getCurrInsId()] = newBook
	elseif copyType == CopyType.TowerCopy then
		newBook = TowerBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._towerCopy[newBook:getCurrInsId()] = newBook
	elseif copyType == CopyType.GuardCopy then
		newBook = GuardBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._guardCopy[newBook:getCurrInsId()] = newBook
	elseif copyType == CopyType.MultiCopy then
		newBook = MultiCopy(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._multiCopy[newBook:getCurrInsId()] = newBook
	elseif copyType == CopyType.NewSingleCopy then                      --新增屠龙传说剧情副本
		newBook = SingleBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._newsingleCopy[newBook:getCurrInsId()] = newBook
	elseif copyType == CopyType.TrivialCopy then
		newBook = TrivialBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._trivialCopy[newBook:getCurrInsId()] = newBook	
	elseif copyType == CopyType.ArenaThree then                      --新增3v3竞技场副本
		newBook = ArenaThreeBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._arenaCopy[newBook:getCurrInsId()] = newBook	
	elseif copyType == CopyType.SingleGuard then
		newBook = SingleGuardBook(playerID, copyID, proto)
		newBook:setCurrInsId(self:requestNewId())
		self._singleGuardCopy[newBook:getCurrInsId()] = newBook
	end
	print("===========creatcopy=="..newBook:getCurrInsId())

	local curCnt = self._copyCounts[copyID] or 0
	self._copyCounts[copyID] = curCnt + 1
	return newBook
end

function CopyManager:getCopyScene(copyInstID, mapID)
	local copyBook = self:getCopyBookById(copyInstID)
	if copyBook then
		return copyBook:getScene(mapID)
	end
end

--新增屠龙传说剧情副本
function CopyManager:getProto(copyBookID)
	return self._singlePrototypes[copyBookID] or self._towerPrototypes[copyBookID] or self._guardPrototypes[copyBookID] 
	or self._multiPrototypes[copyBookID] or self._newsinglePrototypes[copyBookID] or self._trivialPrototypes[copyBookID] 
	or self._arenaPrototypes[copyBookID] or self._singleGuardPrototypes[copyBookID]
end

function CopyManager:getGuardProto()
	return self._guardPrototypes
end

--新增屠龙传说剧情副本
function CopyManager:getTotalCopyCount()
	return table.size(self._singleCopy) + table.size(self._towerCopy) + table.size(self._guardCopy) 
	+ table.size(self._multiCopy) + table.size(self._newsingleCopy) + table.size(self._singleGuardCopy)
end

function CopyManager:getCopyCount(copyID)
	return self._copyCounts[copyID] or 0
end

--新增屠龙传说剧情副本
function CopyManager:getCopyBookById(copyInstId, copyType)
	if not copyType then
		return self._singleCopy[copyInstId] or self._towerCopy[copyInstId] or self._guardCopy[copyInstId] 
		or self._multiCopy[copyInstId] or self._newsingleCopy[copyInstId] or self._trivialCopy[copyInstId] 
		or self._arenaCopy[copyInstId] or self._singleGuardCopy[copyInstId]
	else
		if copyType == CopyType.SingleCopy then
			return self._singleCopy[copyInstId]
		elseif copyType == CopyType.TowerCopy then
			return self._towerCopy[copyInstId]
		elseif copyType == CopyType.GuardCopy then
			return self._guardCopy[copyInstId]
		elseif copyType == CopyType.MultiCopy then
			return self._multiCopy[copyInstId]
		elseif copyType == CopyType.NewSingleCopy then
			return self._newsingleCopy[copyInstId]
		elseif copyType == CopyType.TrivialCopy then
			return self._trivialCopy[copyInstId]
		elseif copyType == CopyType.ArenaThree then
			return self._arenaCopy[copyInstId]
		elseif copyType == CopyType.SingleGuard then
			return self._singleGuardCopy[copyInstId]
		end
	end
end

function CopyManager:roleBackMonster()
	for i=1, #self._delCopyId do
		local copy = self:getCopyBookById(self._delCopyId[i])
		if copy then
			copy:roleBackMonster() 
		end
	end
	self._delCopyId = {}
end

function CopyManager:addRollBackCopy(copyInstId)
	table.insert(self._delCopyId, copyInstId)
end

--新增屠龙传说剧情副本
function CopyManager:releaseCopy(copyInstId, copyType)
	print("CopyManager:releaseCopy",copyInstId,copyType)
	if copyType == CopyType.SingleCopy then
		self._singleCopy[copyInstId]:_close() 
		self._singleCopy[copyInstId] = nil
	elseif copyType == CopyType.TowerCopy then
		self._towerCopy[copyInstId]:_close()
		self._towerCopy[copyInstId] = nil
	elseif copyType == CopyType.GuardCopy then
		self._guardCopy[copyInstId]:_close()
		self._guardCopy[copyInstId] = nil
	elseif copyType == CopyType.MultiCopy then
		self._multiCopy[copyInstId]:_close()
		self._multiCopy[copyInstId] = nil
	elseif copyType == CopyType.NewSingleCopy then
		self._newsingleCopy[copyInstId]:_close() 
		self._newsingleCopy[copyInstId] = nil
	elseif copyType == CopyType.TrivialCopy then
		self._trivialCopy[copyInstId]:_close()
		self._trivialCopy[copyInstId] = nil
	elseif copyType == CopyType.ArenaThree then
		self._arenaCopy[copyInstId]:_close()
		self._arenaCopy[copyInstId] = nil
	elseif copyType == CopyType.SingleGuard then
		self._singleGuardCopy[copyInstId]:_close()
		self._singleGuardCopy[copyInstId] = nil
	end
end

--检验多人副本时间
function CopyManager:updateMultiCopyTime()
	local  nowTime = os.time()
	for instId, copyBook in pairs(self._multiCopy) do
		local copyTeam = self:getCopyTeam(copyBook:getPlayerID())
		if copyBook:getStatus() == CopyStatus.Active then
			if nowTime - copyBook:getStartTime() == 10 then
				--开始刷怪
				g_copySystem:flushMultiCopyMonster(copyTeam,copyBook, 1,1)
				copyBook:setCurRound(1)
				copyBook:setLastRoundTime(os.time())
			elseif (nowTime - copyBook:getStartTime()>10) and (nowTime - copyBook:getMonsClearTime()) >= 2 and copyBook:getCurRound()<3 and os.time()-copyBook:getLastRoundTime()>=10 then
				copyBook:setCurRound(copyBook:getCurRound()+1)
				g_copySystem:flushMultiCopyMonster(copyTeam,copyBook, copyBook:getCurrCircle(),copyBook:getCurRound())
				copyBook:setLastRoundTime(os.time())
				--g_copySystem:addFlushMonster(copyBook,1)
			elseif (nowTime - copyBook:getStartTime()>10) and copyBook:getMonsterNum() == 0 and (nowTime - copyBook:getMonsClearTime()) >= 2 and copyBook:getCurRound() >= 3 then
				copyBook:doReward()
				copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
				--刷新下一波怪物
				g_copySystem:flushMultiCopyMonster(copyTeam,copyBook, copyBook:getCurrCircle(),1)
				copyBook:setCurRound(1)
				copyBook:setLastRoundTime(os.time())
				copyBook:clearKilledMonster()
				local ret = {}
				ret.copyType = copyBook:getPrototype():getCopyType()
				ret.curCircle = copyBook:getCurrCircle()
				ret.remainTime = nowTime-copyBook:getStartTime()
				
				if copyTeam then
					local allCopyMems = copyTeam:getAllMember()
					for i=1, #allCopyMems do
						local tmpPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
						if tmpPlayer:getCopyID()>0 then
							fireProtoMessageBySid(allCopyMems[i], COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
						end
					end
				end
			end

		elseif (os.time() - copyBook:getEndTime()) > 30 then
			copyBook:clearBook()
		end
	end
end

--检验副本时间
function CopyManager:updateCopyTime()
	for instId, copyBook in pairs(self._singleCopy) do
		local playerID = copyBook:getPlayerID()
		local copyPlayer = self._playerCopyData[playerID]
		if copyPlayer then
			if copyBook:getStatus() == CopyStatus.Active then
				if copyBook:getRemainTime() <= 0 or (copyBook:getDeadTime() ~= 0 and os.time() - copyBook:getDeadTime() > 30) then
					--时间到了失败
					copyBook:copyFailed()
					self:addRollBackCopy(instId)
				elseif copyBook:getMonsterNum() == 0 and (os.time() - copyBook:getMonsClearTime()) >= 2 then
					copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
					--刷新下一波怪物
					g_copySystem:flushMonster(copyBook, copyBook:getCurrCircle())
					--通知客户端进行下一步
					local ret = {}
					ret.copyType = copyBook:getPrototype():getCopyType()
					ret.curCircle = copyBook:getCurrCircle()
					ret.remainTime = copyBook:getRemainTime()
					
					fireProtoMessage(playerID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
		
				end
			elseif (os.time() - copyBook:getEndTime()) > 30 then
				copyBook:clearBook()
			end
		end
	end
	--3v3竞技场
	for instId, copyBook in pairs(self._arenaCopy) do
		local playerID = copyBook:getPlayerID()
		local copyPlayer = self._playerCopyData[playerID]
		if copyPlayer then
			if copyBook:getStatus() == CopyStatus.Active then
				if copyBook:getRemainTime() <= 0  then
					--时间到了失败
					copyBook:copyFailed()
					self:addRollBackCopy(instId)
				elseif copyBook:getMonsterNum() > 0 and copyBook:getTakeTime() > 12 then
					copyBook:OnCopyLogicUpdate()
				elseif copyBook:getMonsterNum() <= 0 then
					--print("===========3v3 copy Success!")	
				end
			elseif (os.time() - copyBook:getEndTime()) > 30 then
				copyBook:clearBook()
			end
		end
	end
	for instId, copyBook in pairs(self._towerCopy) do
		local playerID = copyBook:getPlayerID()
		if copyBook:getStatus() == CopyStatus.Active then
			if copyBook:getRemainTime() <= 0 or (copyBook:getDeadTime() ~= 0 and os.time() - copyBook:getDeadTime() > 30) then
				--时间到了失败
				copyBook:copyFailed()
				self:addRollBackCopy(instId)
			elseif copyBook:getMonsterNum() == 0 and (os.time() - copyBook:getMonsClearTime()) >= 2 then
				copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
					--鍒锋柊涓嬩竴娉㈡€墿
				g_copySystem:flushMonster(copyBook, copyBook:getCurrCircle())
					--閫氱煡瀹㈡埛绔繘琛屼笅涓€姝?
				local ret = {}
				ret.copyType = copyBook:getPrototype():getCopyType()
				ret.curCircle = copyBook:getCurrCircle()
				ret.remainTime = copyBook:getRemainTime()
				
				fireProtoMessage(playerID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
			end
		elseif (os.time() - copyBook:getEndTime()) > 30 then
			copyBook:clearBook()
		end
	end
	for instId, copyBook in pairs(self._guardCopy) do
		local playerID = copyBook:getPlayerID()
		local copyPlayer = self._playerCopyData[playerID]
		if copyPlayer then
			if copyBook:getStatus() == CopyStatus.Active then
				--时间到了或者复活时间到了
				if copyBook:getRemainTime() <= 0 or (copyBook:getDeadTime() ~= 0 and os.time() - copyBook:getDeadTime() > 30) then
					copyBook:copyFailed()
					self:addRollBackCopy(instId)
					--奖励计算,添加到扫荡奖励列表
					--g_copyMgr:doGuardReward(copyPlayer)
					--用完要清空
					copyPlayer:clearGuardReward()
					if table.size(copyPlayer:getProRewards()) ~= 0 then
						--告诉前端有奖励可领
						local ret = {}
						fireProtoMessage(playerID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
					end
					--self:dealExitCopy(copyPlayer:getRole(), copyPlayer)
					--g_sceneMgr:enterPublicScene(copyPlayer:getID(), copyPlayer:getLastMapID(), copyPlayer:getLastPosX(), copyPlayer:getLastPosX())
				elseif copyBook:getMonsterNum() == 0 and (os.time() - copyBook:getMonsClearTime()) >= 2 then
					copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
					--刷新下一波怪物
					g_copySystem:flushMonster(copyBook, copyBook:getCurrCircle())
					--通知客户端进行下一步

					local ret = {}
					ret.copyType = copyBook:getPrototype():getCopyType()
					ret.curCircle = copyBook:getCurrCircle()
					ret.remainTime = copyBook:getRemainTime()
					
					fireProtoMessage(playerID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
				end
			--已经成功,判断是否可以进入下一个副本
			elseif copyBook:getStatus() == CopyStatus.Done  then
				local finishTime = copyBook:getFinishTime()
				if finishTime ~= 0 and os.time() - finishTime >= AUTO_NEXT_GUARD then
					copyBook:setFinishTime(0)
					if copyBook:getNextCopy() == 0 then
						--这边应该是弹出npc的对话框，让玩家能够传送到国王那里
						option = {}
						option["text"] = "觐见国王"
						option["type"] = 2
						option["value"] = 2
						option["icon"] = 0
						option["param"] = 6
						options = {option,}
						g_dialogServlet:fireDialog(playerID,10383,"恭喜勇士成功拯救公主！国王一直在等你，赶紧去找国王领取奖励吧！",options)
						copyPlayer.role:setLastMapID(2113)
						copyPlayer.role:setLastPosX(36)
						copyPlayer.role:setLastPosY(25)
						local proto = copyBook:getPrototype()
						g_CardPrizeMgr:addPrizeInfo(playerID,proto)
						local player = g_entityMgr:getPlayer(playerID)
						g_CardPrizeMgr:addGuardCopyLastLayer(playerID,proto:getNextCopy())
						--g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 1,os.time())
						
					else
						local player = copyPlayer:getRole()
						local proto = copyBook:getPrototype()
						g_CardPrizeMgr:addPrizeInfo(playerID,proto)
						g_CardPrizeMgr:OpenCardPrizeWindow(playerID,proto:getCopyLayer(),proto:getCopyID())	
						g_CardPrizeMgr:addGuardCopyLastLayer(playerID,proto:getNextCopy())
						--g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 1,os.time())
						--这边需要调用新的触发成就的接口
						
					end
				elseif copyBook:getRemainTime() <=0 then
					local player = g_entityMgr:getPlayer(playerID)
					self:dealExitCopy(playerID, copyPlayer)
					--g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 0, 0, 1,os.time())
				end
			end
		end
	end
	self:updateMultiCopyTime()
	self:updateNewSingleCopyTime()
	self:updateTrivialCopyTime()
	self:updateSingleGuardCopyTime()
end

function CopyManager:setPlayerLastGuard(roleID,copyLayer)
	local copyPlayer = self._playerCopyData[roleID]
	if copyPlayer then
		copyPlayer:setLastGuardLayer(copyLayer)
	end
end

--发送扫荡奖励给玩家
function CopyManager:doSendProReward(copyPlayer)
	copyPlayer:checkProReward()
	local proReward = copyPlayer:getProRewards()
	local ret = {}
	ret.rewardCount = table.size(proReward)
	ret.rewardList = {}
	for t, redata in pairs(proReward) do
		local pInfo = {}
		pInfo.rewardTime = t
		pInfo.rewardCount = table.size(redata)
		pInfo.rewardList = {}
		for k,data in pairs(redata) do
			local prizelist = {}
			prizelist.copyID = k
			prizelist.prizeNum = table.size(data)
			prizelist.info = {}
			for itemID, count in pairs(data) do
				local prize = {}
				prize.rewardId = itemID
				prize.rewardCount = count.num
				prize.bind = count.bind
				table.insert(prizelist.info,prize)
			end
			table.insert(pInfo.rewardList,prizelist)
		end
		table.insert(ret.rewardList,pInfo)
	end
	fireProtoMessage(copyPlayer:getRole():getID(), COPY_SC_GETPROREWARDLISTRET, 'GetProRewardListRetProtocol', ret)
end

--守护副本给奖励
function CopyManager:doGuardReward(copyPlayer)
	local rewards = copyPlayer:getGuardReward()
	local size = #rewards
	if size == 0 then return end
	local nowTime = os.time()
	local data = {}
	for i=1, size do
		local reward = rewards[i]
		for itemID, cnt in pairs(reward) do
			local tmpNum = data[itemID] or 0
			data[itemID] = tmpNum + cnt
		end
	end
	copyPlayer:addProReward(nowTime, 0, data)
end

function CopyManager:parseMultiProto()
	local multiData = require "data.MultiCopyDB"
	local multiCnt = #multiData
	for i=1, multiCnt do
		local tmp = {}
		local multiProto = multiData[i]
		tmp.copyID = tonumber(multiProto.CopyofID)
		tmp.name = multiProto.Copyname or "null"
		tmp.level = tonumber(multiProto.accesslevel) or 0
		tmp.period = tonumber(multiProto.q_zone_time) or 0
		tmp.cdCount = tonumber(multiProto.numberoftimes) or 0
		tmp.ratingTime = {multiProto.aping and tonumber(multiProto.aping) or 0, multiProto.bping and tonumber(multiProto.bping) or 0}
		tmp.relive = tonumber(multiProto.fh) ~= 1 and true or false
		tmp.reliveMat = tonumber(multiProto.q_reliveMat) == 1 and true or false
		tmp.autoProgress = false
		tmp.copyType = CopyType.MultiCopy
		tmp.copyLayer = 1
		tmp.nextCopy = 0
		tmp.maxCircle = tonumber(multiProto.shuaguai) or 1
		tmp.firstReward = unserialize(multiProto.reward)
		tmp.canTransmit = tonumber(multiProto.chuansong) == 0 and true or false
		tmp.rewardID = multiProto.tggd and tonumber(multiProto.tggd)
		tmp.shakeReward = multiProto.pjsss and unserialize("{"..multiProto.pjsss.."}")
		tmp.mapID = tonumber(multiProto.CopymapID)
		tmp.mainID = tmp.copyID
		tmp.monsters = table.join(unserialize('{' ..(tostring(multiProto.q_monster1) or "") .. '}'), unserialize('{' ..(tostring(multiProto.q_monster2) or "") .. '}'), unserialize('{' ..(tostring(multiProto.q_monster3) or "") .. '}'), 
				unserialize('{' ..(tostring(multiProto.q_monster4) or "") .. '}'), unserialize('{' ..(tostring(multiProto.q_monster5) or "") .. '}'), unserialize('{' ..(tostring(multiProto.q_monster6) or "") .. '}'))
		tmp.monsters1 = unserialize('{' ..(tostring(multiProto.q_monster1) or "") .. '}')
		tmp.monsters2 = unserialize('{' ..(tostring(multiProto.q_monster2) or "") .. '}')
		tmp.monsters3 = unserialize('{' ..(tostring(multiProto.q_monster3) or "") .. '}')
		tmp.monsters4 = unserialize('{' ..(tostring(multiProto.q_monster4) or "") .. '}')
		tmp.enterPos = unserialize('{' ..multiProto.Coordinate1 .. '}')
		tmp.relivePos = tmp.enterPos
		tmp.reliveType = tonumber(multiProto.fh)
		tmp.maxMemCnt = tonumber(multiProto.recommendednumber) or 1
		tmp.statuePos = unserialize(multiProto.statuecoordinate)
		tmp.statueHP = tonumber(multiProto.statuelife)

		if self._multiPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._multiPrototypes[tmp.copyID])
		else
			self._multiPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end
end

--新增屠龙传说剧情副本
function CopyManager:parseNewSingleProto()
	local newsingleData = require "data.NewSingleCopyDB"
	local newsingleCnt = #newsingleData
	for i=1, newsingleCnt do
		local tmp = {}
		local singleProto = newsingleData[i]
		tmp.copyID = singleProto.q_id
		tmp.name = singleProto.F1 or "null"
		tmp.level = tonumber(singleProto.q_limit_level) or 0
		tmp.period = singleProto.q_zone_time or 0                  
		tmp.cdCount = singleProto.qmri or 0
		tmp.ratingTime = {singleProto.aping and tonumber(singleProto.aping) or 0, singleProto.bping and tonumber(singleProto.bping) or 0, singleProto.cping and tonumber(singleProto.cping) or 0}
		tmp.relive = singleProto.q_relive ~= 1 and true or false
		tmp.reliveMat = singleProto.q_reliveMat == 1 and true or false
		tmp.relivePos = unserialize(singleProto.fuhwei)
		tmp.autoProgress = singleProto.fblei == 1 and true or false
		tmp.copyType = CopyType.NewSingleCopy
		tmp.copyLayer = singleProto.q_copyLayer or 1
		tmp.nextCopy = singleProto.q_nextCopy or 0
		tmp.maxCircle = singleProto.q_maxCircle or 1
		tmp.firstReward = singleProto.tjiang and tonumber(singleProto.tjiang) or nil
		tmp.canTransmit = singleProto.song == 0 and true or false
		tmp.rewardID = singleProto.q_reward and unserialize("{"..singleProto.q_reward.."}")
		tmp.passItem = unserialize(singleProto.q_needitem)
		tmp.specReward = singleProto.teshu and tonumber(singleProto.teshu) or nil
		tmp.shakeReward = singleProto.chouID and unserialize("{"..singleProto.chouID.."}")
		tmp.mapID = singleProto.q_map_id
		tmp.mainID = singleProto.q_mainID or tmp.copyID
		tmp.monsters = '{' ..singleProto.q_monster .. '}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.enterPos = unserialize('{' ..singleProto.q_enter_xy .. '}')
		tmp.reliveType = singleProto.q_relive_ and singleProto.q_relive_ or 1    
		tmp.relivePos = unserialize('{' ..singleProto.fuhwei .. '}')
		tmp.resetting = singleProto.resetting and unserialize('{' ..singleProto.resetting .. '}')
		tmp.innerCD = singleProto.fbcd and tonumber(singleProto.fbcd)*60 or 0
		--tmp.assistMonID = singleProto.assistMonID and tonumber(singleProto.assistMonID) or 0   --进入个人副本时的 协助Monster
		tmp.assistMon = singleProto.assistMon and unserialize('{' ..singleProto.assistMon .. '}') or nil    --进入个人副本时的 协助Monster
		tmp.firstReward = singleProto.q_firstreward and tonumber(singleProto.q_firstreward)

		local openTime = singleProto.opentime
		if openTime then
			openTime = string.gsub(openTime, "%p", {["["]="{",["]"]="}"})
			openTime = "{"..openTime.."}"
			local tmpopen = unserialize(openTime)
			tmp.openTime = {}
			for k,v in pairs(tmpopen) do
				tmp.openTime[v[1]] = v[2]
			end
		end

		if self._newsinglePrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._newsinglePrototypes[tmp.copyID])
		else
			self._newsinglePrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end
end
function CopyManager:parseSingleInstsProto()
	local instsList = require "data.instanceInfolist"
	local instsCount = #instsList
	for i=1, instsCount do
		local tmp = {}
		local instProto = instsList[i]
		tmp.id = instProto.q_id or 0
		tmp.copyID = instProto.q_ins_id or 0
		tmp.name = instProto.q_name or ""
		tmp.class = instProto.q_cla or 0
		tmp.index = instProto.q_cla_id or 0
		tmp.inDaily = instProto.q_eve or 0
		tmp.dailyInstID = instProto.q_eve_ra or 0
		tmp.simulate = instProto.q_com or 0
		tmp.level = instProto.q_lv or 0
		tmp.prevInsts = instProto.q_need and '{' ..instProto.q_need .. '}' or '{}'
		tmp.prevInsts = unserialize(tmp.prevInsts)
		tmp.mainTaskID = instProto.q_need2 or 0
		tmp.passReward = instProto.q_fr_id or 0
		tmp.dailyReward = instProto.q_er_id or 0
		tmp.unlock = instProto.q_unlock or 0
		tmp.randomLimitDay = q_lim or 0

		if self._singleInstsPrototypes[tmp.id] then
			table.deepCopy1(CopyPrototype(tmp), self._singleInstsPrototypes[tmp.id])
		else
			self._singleInstsPrototypes[tmp.id] = CopyPrototype(tmp)
		end
		self._singleInstsProtoCopyIDs[tmp.copyID] = tmp.id		
	end
end

function CopyManager:parseSingleGuardProto()
	local guardData = require "data.SingleGuardCopyDB"
	local count = #guardData
	for i=1, count do
		local tmp = {}
		local guardProto = guardData[i]
		tmp.copyID = tonumber(guardProto.CopyofID)
		tmp.name = guardProto.Copyname or "null"
		tmp.level = tonumber(guardProto.accesslevel) or 0
		tmp.period = tonumber(guardProto.q_zone_time) or 0
		tmp.cdCount = tonumber(guardProto.numberoftimes) or 0
		tmp.ratingTime = {guardProto.aping and tonumber(guardProto.aping) or 0, guardProto.bping and tonumber(guardProto.bping) or 0}
		tmp.relive = tonumber(guardProto.fh) ~= 1 and true or false
		tmp.reliveMat = tonumber(guardProto.q_reliveMat) == 1 and true or false
		tmp.autoProgress = false
		tmp.copyType = CopyType.SingleGuard
		tmp.copyLayer = 1
		tmp.nextCopy = 0
		tmp.maxCircle = tonumber(guardProto.shuaguai) or 1
		tmp.firstReward = unserialize(guardProto.reward)
		tmp.canTransmit = tonumber(guardProto.chuansong) == 0 and true or false
		tmp.rewardID = guardProto.tggd and tonumber(guardProto.tggd)
		tmp.shakeReward = guardProto.pjsss and unserialize("{"..guardProto.pjsss.."}")
		tmp.mapID = tonumber(guardProto.CopymapID)
		tmp.mainID = tmp.copyID
		tmp.monsters = table.join(unserialize('{' ..(tostring(guardProto.q_monster1) or "") .. '}'), unserialize('{' ..(tostring(guardProto.q_monster2) or "") .. '}'), unserialize('{' ..(tostring(guardProto.q_monster3) or "") .. '}'), 
				unserialize('{' ..(tostring(guardProto.q_monster4) or "") .. '}'), unserialize('{' ..(tostring(guardProto.q_monster5) or "") .. '}'), unserialize('{' ..(tostring(guardProto.q_monster6) or "") .. '}'))
		tmp.monsters1 = unserialize('{' ..(tostring(guardProto.q_monster1) or "") .. '}')
		tmp.monsters2 = unserialize('{' ..(tostring(guardProto.q_monster2) or "") .. '}')
		tmp.monsters3 = unserialize('{' ..(tostring(guardProto.q_monster3) or "") .. '}')
		tmp.monsters4 = unserialize('{' ..(tostring(guardProto.q_monster4) or "") .. '}')
		tmp.enterPos = unserialize(guardProto.Coordinate1)
		tmp.relivePos = tmp.enterPos
		tmp.reliveType = tonumber(guardProto.fh)
		tmp.maxMemCnt = tonumber(guardProto.recommendednumber) or 1
		tmp.statuePos = unserialize(guardProto.statuecoordinate)
		tmp.statueHP = tonumber(guardProto.statuelife)
		tmp.assistants = unserialize('{' ..(tostring(guardProto.q_friend) or "") .. '}')
		
		if self._singleGuardPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._singleGuardPrototypes[tmp.copyID])
		else
			self._singleGuardPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end


	end
end

function CopyManager:parsePrototype()
	local singleData = require "data.SingleCopyDB"
	local singleCnt = #singleData
	for i=1, singleCnt do
		local tmp = {}
		local singleProto = singleData[i]
		tmp.copyID = singleProto.q_id
		tmp.name = singleProto.F1 or "null"
		tmp.level = tonumber(singleProto.q_limit_level) or 0
		tmp.period = singleProto.q_zone_time or 0
		tmp.cdCount = singleProto.qmri or 0
		tmp.ratingTime = {singleProto.aping and tonumber(singleProto.aping) or 0, singleProto.bping and tonumber(singleProto.bping) or 0, singleProto.cping and tonumber(singleProto.cping) or 0}
		tmp.relive = singleProto.q_relive ~= 1 and true or false
		tmp.reliveMat = singleProto.q_reliveMat == 1 and true or false
		tmp.relivePos = unserialize(singleProto.fuhwei)
		tmp.autoProgress = singleProto.fblei == 1 and true or false
		tmp.copyType = CopyType.SingleCopy
		tmp.copyLayer = singleProto.q_copyLayer or 1
		tmp.nextCopy = singleProto.q_nextCopy or 0
		tmp.maxCircle = singleProto.q_maxCircle or 1
		tmp.firstReward = singleProto.tjiang and tonumber(singleProto.tjiang) or nil
		tmp.canTransmit = singleProto.song == 0 and true or false
		tmp.rewardID = singleProto.q_reward and unserialize("{"..singleProto.q_reward.."}")
		tmp.passItem = unserialize(singleProto.q_needitem)
		tmp.specReward = singleProto.teshu and tonumber(singleProto.teshu) or nil
		tmp.shakeReward = singleProto.chouID and unserialize("{"..singleProto.chouID.."}")
		tmp.mapID = singleProto.q_map_id
		tmp.mainID = singleProto.q_mainID or tmp.copyID
		tmp.monsters = '{' ..singleProto.q_monster .. '}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.enterPos = unserialize('{' ..singleProto.q_enter_xy .. '}')
		tmp.reliveType = singleProto.q_relive_
		tmp.relivePos = unserialize('{' ..singleProto.fuhwei .. '}')
		tmp.resetting = singleProto.resetting and unserialize('{' ..singleProto.resetting .. '}')
		tmp.innerCD = singleProto.fbcd and tonumber(singleProto.fbcd)*60 or 0

		local openTime = singleProto.opentime
		if openTime then
			openTime = string.gsub(openTime, "%p", {["["]="{",["]"]="}"})
			openTime = "{"..openTime.."}"
			local tmpopen = unserialize(openTime)
			tmp.openTime = {}
			for k,v in pairs(tmpopen) do
				tmp.openTime[v[1]] = v[2]
			end
		end
		if self._singlePrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._singlePrototypes[tmp.copyID])
		else
			self._singlePrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end

	local towerData = require "data.TowerCopyDB"
	local towerCnt = #towerData
	for i=1, towerCnt do
		local tmp = {}
		local towerProto = towerData[i]
		tmp.copyID = towerProto.q_id
		tmp.name = towerProto.fbm or ""
		tmp.level = tonumber(towerProto.q_limit_level) or 0
		tmp.period = towerProto.q_zone_time or 0
		tmp.cdCount = towerProto.qmri or 0
		tmp.ratingTime = {towerProto.aping and tonumber(towerProto.aping) or 0, towerProto.bping and tonumber(towerProto.bping) or 0, towerProto.cping and tonumber(towerProto.cping) or 0}
		tmp.relive = towerProto.q_relive ~= 1 and true or false
		tmp.reliveMat = towerProto.q_reliveMat == 1 and true or false
		tmp.relivePos = unserialize(towerProto.fuhwei)
		--tmp.autoProgress = towerProto.fblei == 1 and true or false
		tmp.autoProgress = true
		tmp.copyType = CopyType.TowerCopy
		tmp.copyLayer = towerProto.q_copyLayer or 1
		tmp.nextCopy = towerProto.q_nextCopy or 0
		tmp.maxCircle = towerProto.q_maxCircle or 1
		tmp.firstReward = towerProto.tjiang and tonumber(towerProto.tjiang) or nil
		tmp.canTransmit = towerProto.song == 0 and true or false
		tmp.rewardID = towerProto.q_reward and unserialize("{"..towerProto.q_reward.."}")
		tmp.passItem = unserialize(towerProto.q_needitem)
		tmp.specReward = towerProto.teshu and tonumber(towerProto.teshu) or nil
		tmp.shakeReward = towerProto.chouID and unserialize("{"..towerProto.chouID.."}")
		tmp.mapID = towerProto.q_map_id
		tmp.mainID = towerProto.q_mainID or tmp.copyID
		tmp.monsters = '{' ..towerProto.q_monster .. '}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.enterPos = unserialize('{' ..towerProto.q_enter_xy .. '}')
		tmp.reliveType = towerProto.q_relive
		tmp.relivePos = unserialize('{' ..towerProto.fuhwei .. '}')
		tmp.resetting = towerProto.resetting and unserialize('{' ..towerProto.resetting .. '}')
		tmp.innerCD = towerProto.fbcd and tonumber(towerProto.fbcd)*60 or 0
		--tmp.starTime = towerProto.startime and unserialize('{' ..towerProto.startime .. '}')
		tmp.starPrize = towerProto.starprize and unserialize(towerProto.starprize)
		tmp.cardprize = unserialize(towerProto.q_cardprize)
		tmp.firstReward = towerProto.q_firstreward and unserialize("{"..towerProto.q_firstreward.."}")


		if self._towerPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._towerPrototypes[tmp.copyID])
		else
			self._towerPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end

	local guardData = require "data.GuardCopyDB"
	local guardCnt = #guardData
	for i=1, guardCnt do
		local tmp = {}
		local guardProto = guardData[i]
		tmp.copyID = guardProto.q_id
		tmp.name = guardProto.q_name or ""
		tmp.level = tonumber(guardProto.q_limit_level) or 1
		tmp.period = guardProto.q_zone_time or 0
		tmp.cdCount = guardProto.qmri or 0
		tmp.ratingTime = {guardProto.aping and tonumber(guardProto.aping) or 0, guardProto.bping and tonumber(guardProto.bping) or 0, guardProto.cping and tonumber(guardProto.cping) or 0}
		tmp.relive = guardProto.q_relive ~= 1 and true or false
		tmp.reliveMat = guardProto.q_reliveMat == 1 and true or false
		tmp.relivePos = unserialize(guardProto.fuhwei)
		tmp.autoProgress = guardProto.fblei == 1 and true or false
		tmp.copyType = CopyType.GuardCopy
		tmp.copyLayer = guardProto.q_copyLayer or 1
		tmp.nextCopy = guardProto.q_nextCopy or 0
		tmp.maxCircle = guardProto.q_maxCircle or 1
		tmp.firstReward = guardProto.tjiang and tonumber(guardProto.tjiang) or nil
		tmp.canTransmit = guardProto.song == 0 and true or false
		tmp.rewardID = guardProto.q_reward and unserialize("{"..guardProto.q_reward.."}")
		tmp.passItem = unserialize(guardProto.q_needitem)
		tmp.specReward = guardProto.teshu and tonumber(guardProto.teshu) or nil
		tmp.shakeReward = guardProto.chouID and unserialize("{"..guardProto.chouID.."}")
		tmp.mapID = guardProto.q_map_id
		tmp.mainID = guardProto.q_mainID or tmp.copyID
		tmp.monType = guardProto.xhl
		tmp.monValue = guardProto.xhjb
		tmp.monsters = '{' ..guardProto.q_monster .. '}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.enterPos = unserialize('{' ..guardProto.q_enter_xy .. '}')
		tmp.reliveType = guardProto.q_relive_ or 1
		tmp.relivePos = unserialize('{' ..guardProto.fuhwei .. '}')
		tmp.statuePos = unserialize('{' ..guardProto.dxzb .. '}')
		tmp.statueHP = guardProto.qsm
		tmp.resetting = guardProto.resetting and unserialize('{' ..guardProto.resetting .. '}')
		tmp.cardprize = unserialize(guardProto.q_cardprize)

	--	self._guardPrototypes[tmp.copyID] = CopyPrototype(tmp)
		if self._guardPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._guardPrototypes[tmp.copyID])
		else
			self._guardPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
		
	end
end

function CopyManager:parseTrivialProto()
	local trivialCopyDB = require "data.TrivialCopyDB"
	local trivialCount = #trivialCopyDB
	for i=1, trivialCount do
		local tmp = {}
		tmp.copyType = CopyType.TrivialCopy
		local trivialProto = trivialCopyDB[i]
		tmp.copyID = trivialProto.q_id
		tmp.name = trivialProto.name or "null"
		tmp.level = tonumber(trivialProto.q_limit_level) or 0
		tmp.mapID = trivialProto.q_map_id or 0
		tmp.monsters = trivialProto.q_monster and '{' ..trivialProto.q_monster .. '}' or '{}'
		tmp.monsters = string.gsub(tmp.monsters, '%[', '%{')
		tmp.monsters = string.gsub(tmp.monsters, '%]', '%}')
		tmp.monsters = unserialize(tmp.monsters)
		tmp.enterPos = trivialProto.q_enter_xy and unserialize('{' ..trivialProto.q_enter_xy .. '}') or '{}'
		if self._trivialPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._trivialPrototypes[tmp.copyID])
		else
			self._trivialPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end
end


function CopyManager:parseArenaCopyProto()
	-- body
	local arenaDb = require "data.NewArenaCopyDB"
	local arenaDbCount = #arenaDb
	for i=1, arenaDbCount do
		local tmp = {}
		tmp.copyType = CopyType.ArenaThree
		local arenaProto = arenaDb[i]
		tmp.copyID = arenaProto.q_id
		tmp.level = 1
		tmp.name = arenaProto.q_name or "null"
		tmp.mapID = arenaProto.q_map_id
		--tmp.q_enter_xy = unserialize(arenaProto.q_player_pos)
		if arenaProto.q_player_pos then
			tmp.enterPos = unserialize(arenaProto.q_player_pos)
		else
			tmp.enterPos = "{}"
		end
		tmp.period = arenaProto.q_time or 60
		tmp.reliveType = 1
		tmp.maxCircle = 1

		tmp.q_friend_pos = unserialize(arenaProto.q_friend_pos)
		tmp.q_friend_go = unserialize(arenaProto.q_friend_go)
		tmp.q_enemy_pos = unserialize(arenaProto.q_enemy_pos)
		tmp.q_monsterid_min_max = unserialize(arenaProto.q_monsterid)
		tmp.q_switch_time = unserialize(arenaProto.q_swh_t)
		tmp.q_attackpayler_time = unserialize(arenaProto.q_atk_t)
		tmp.q_cancel_attck_player_time = arenaProto.q_canc_t

		if self._arenaPrototypes[tmp.copyID] then
			table.deepCopy1(CopyPrototype(tmp), self._arenaPrototypes[tmp.copyID])
		else
			self._arenaPrototypes[tmp.copyID] = CopyPrototype(tmp)
		end
	end
end


--加载副本数据
function CopyManager:loadCopyData()
	g_entityDao:loadCopyData()
end

--获取今天完成某一副本次数  任务用
function CopyManager:getCopyDoneCnt(roleID)
	local copyPlayer = self:getCopyPlayer(roleID)
	if copyPlayer then
		local allCnt = copyPlayer:getCopyCDCount()
		local num = 0
		for k,v in pairs(allCnt) do
			num = num + v
		end
		return num
	end
end

--获取进入副本前的位置
function CopyManager.getPubSceneInfo(playerID)
	local copyPlayer = CopyManager.getInstance():getCopyPlayer(playerID)
	if not copyPlayer then
		return ""
	end
	return copyPlayer:getPubSceneInfoStr()
end

function CopyManager.canRelive(copyID,roleID)
	local copyBook = CopyManager.getInstance():getCopyBookById(copyID)
	if copyBook then
		if copyBook:getPrototype():getCopyType()==CopyType.MultiCopy then
			local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
			if copyPlayer then
				if copyPlayer:getTotalDeadTimes()>=COPY_MULTI_RELIVE_TIME then 
					g_copySystem:fireMessage(0, roleID, EVENT_COPY_SETS, COPY_ERR_CANNOT_RELIVE, 0)
					return false
				else
					return true
				end
			else
				return false
			end
		else
			return true
		end
	else
		return true
	end
end

--使用道具复活清空死亡时间
function CopyManager.doRelive(copyID,roleID)
	local copyBook = CopyManager.getInstance():getCopyBookById(copyID)
	if copyBook then
		copyBook:setDeadTime(0)
		if copyBook:getPrototype():getCopyType()==CopyType.MultiCopy then
			local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
			if copyPlayer then
				copyPlayer:setTotalDeadTimes(copyPlayer:getTotalDeadTimes()+1)
			end
		end
	end

	--tlog复活流水
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		g_tlogMgr:TlogReliveFlow(player, 3)
	end
end

--是否可以道具复活
function CopyManager.getReliveType(copyID)
	local copyBook = CopyManager.getInstance():getCopyBookById(copyID)
	if copyBook then
		local proto = copyBook:getPrototype()
		return proto and proto:getReliveType()
	end
	return
end

function CopyManager.onLoadRoleCopyTime(roleSID, index, data)
	if string.len(data) > 0 then
		local self = g_copyMgr	
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local copyPlayer = self:getCopyPlayer(player:getID())
			if copyPlayer then
				if index == 1 then
					--CD时间以及数据
					copyPlayer:readCopyTimeStr(data)
				elseif index ==2 then
					--通关时间数据
					copyPlayer:readCopyFastStr(data)
				elseif index == 3 then
					copyPlayer:readMultiGuardTimeStr(data)
				end
			end
		end
	end
end

function CopyManager.onLoadRoleCopyTime1(roleID)
	local self = g_copyMgr	
	local copyPlayer = self:getCopyPlayer(roleID)
	if copyPlayer then
		copyPlayer:addDBataloadCnt()
		if copyPlayer:getDBataloadCnt() == 3 then
			copyPlayer:setDBdataload(true)
		end
	end
end

function CopyManager.onLoadRoleCopyStar(roleSID,  data)
	if string.len(data) > 0 then
		local self = g_copyMgr	
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local copyPlayer = self:getCopyPlayer(player:getID())
			if copyPlayer then
				copyPlayer:readCopyStarStr(data)
			end
		end
	end
end

function CopyManager.onLoadRoleCopyStarPrize(roleSID,type,data)
	if string.len(data) > 0 then
		local self = g_copyMgr	
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local copyPlayer = self:getCopyPlayer(player:getID())
			if copyPlayer then
				copyPlayer:readCopyStarPrizeStr(data)
			end
		end
	end
end

--加载玩家扫荡奖励数据
function CopyManager.onLoadCopyReward(playerID, idx, str)
	local self = g_copyMgr
	local player = g_entityMgr:getPlayer(playerID)
	if not player then print("CopyManager.onLoadCopyReward err") return end
	local copyPlayer = self:getCopyPlayer(playerID)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player:getID())
		self:addCopyPlayer(playerID, copyPlayer)
	end
	if string.len(str) > 1 then	
		if idx > 0 then
			copyPlayer:readProRewardStr(str)
			if idx == 5 then
				copyPlayer:setSyncProFlag(true)
			end
		end
	end
end

function CopyManager.onLoadCopyReward1(playerID)
	local self = g_copyMgr
	local player = g_entityMgr:getPlayer(playerID)
	if not player then print("CopyManager.onLoadCopyReward1 err") return end
	local copyPlayer = self:getCopyPlayer(playerID)
	if copyPlayer then
		copyPlayer:addDBataloadCnt()
		if copyPlayer:getDBataloadCnt() == 3 then
			copyPlayer:setDBdataload(true)
		end
		local proReward = self._offProRewards[player:getSerialID()]
		if proReward then
			--如果有离线的扫荡奖励则添加
			for t, data in pairs(proReward) do
				for copyID, reward in pairs(data) do
					copyPlayer:addProReward(t, copyID, reward)
				end
			end
			--清空
			self._offProRewards[player:getSerialID()] = nil
		end
		--[[if table.size(copyPlayer:getProRewards())> 0 then
			local ret = {}
			fireProtoMessage(playerID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
		end]]
	end
end

function CopyManager.onLoadRoleSingleInsts(roleSID, data)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		print("CopyManager.onLoadRoleSingleInsts err") 
		return
	end
	local playerID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player:getID())
		g_copyMgr:addCopyPlayer(playerID, copyPlayer)
	end
	copyPlayer:loadSingleInstsData(data)
end

--玩家不在线加载战斗力相关数据返回
function CopyManager.loadOtherData(roleID, targetSID, fristr)
	local friendInfo = unserialize(fristr)
	if friendInfo and friendInfo.sch then
		local friMonId = 7000 + friendInfo.sch
		friMon = g_entityFct:createMonster(friMonId)
		local skills = {[1] = {1004, 1006}, [2] = {2002, 2006}, [3] = {3002, 3004}}
		if friMon then
			friMon:setMP(10000)
			friMon:setMaxMP(10000)
			friMon:setHP(friendInfo.hp)
			friMon:setMaxHP(friendInfo.hp)
			friMon:setLevel(friendInfo.lvl)
			friMon:setName(friendInfo.name)
			friMon:setMinAT(friendInfo.minAt)
			friMon:setMaxAT(friendInfo.maxAt)
			friMon:setMinMT(friendInfo.minMt)
			friMon:setMaxMT(friendInfo.maxMt)
			friMon:setMinDT(friendInfo.minDt)
			friMon:setMaxDT(friendInfo.maxDt)
			friMon:setMinDF(friendInfo.minDf)
			friMon:setMaxDF(friendInfo.maxDf)
			friMon:setMinMF(friendInfo.minMf)
			friMon:setMaxMF(friendInfo.maxMf)
			friMon:setDodge(friendInfo.dodge)
			friMon:setHit(friendInfo.hit)
			friMon:setHost(roleID)
			friMon:setMoveSpeed(170)
			local skillMgr = friMon:getSkillMgr()
			for i, skillId in pairs(skills[friendInfo.sch] or {}) do
				local err = 0
				skillMgr:learnSkill(skillId, err)
			end
		end		
		--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_CALLFRIENDRET)
		buffer:pushInt(friMon:getID())
		buffer:pushInt(friMon:getSerialID())
		buffer:pushString(friendInfo.name)
		buffer:pushInt(friendInfo.weapon or 0)
		buffer:pushInt(friendInfo.cloth or 0)
		buffer:pushInt(friendInfo.ride or 0)
		buffer:pushInt(friendInfo.wing or 0)
		buffer:pushInt(friendInfo.woman or 0)
		buffer:pushChar(friendInfo.sch)
		buffer:pushInt(friendInfo.hp)
		buffer:pushChar(friendInfo.sex)
		g_engine:fireLuaEvent(roleID, buffer)]]
		local ret = {}
		if friMon then
			ret.friendId = friMon:getID()
			ret.friendSid = friMon:getSerialID()
			ret.friendName = friendInfo.name
			ret.friendWeapon = friendInfo.weapon or 0
			ret.friendCloth = friendInfo.cloth or 0
			ret.friendRide = friendInfo.ride or 0
			ret.friendWoman = friendInfo.woman or 0
			ret.friendWing = friendInfo.wing or 0
			ret.friendSchool = friendInfo.sch
			ret.friendHp = friendInfo.hp
			ret.friendSex = friendInfo.sex
			fireProtoMessage(roleID, COPY_SC_CALLFRIENDRET, 'CallFriendRetProtocol', ret)
		end

		local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
		local copyBook = g_copyMgr:getCopyBookById(copyPlayer:getCurCopyInstID())
		if copyBook and copyPlayer then
			friMon:setHost(roleID)
			copyPlayer:addFriInviteData(targetSID, os.time())
			copyBook:addCallFriMon(friMon)
			local scene = friMon:getScene()
			scene:addMonster(friMon)
		end
	end
end

function CopyManager.onSyncActiveCopyID(playerID)
	local self = CopyManager.getInstance()
	local copyPlayer = self:getCopyPlayer(playerID)
	if not copyPlayer then return end
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPYE_SC_SYNC_ACTIVE_COPYID)
	buffer:pushInt(copyPlayer:getCurrentCopyID())
	g_engine:fireLuaEvent(roleID, buffer)]]
	local ret = {}
	ret.curCopyId = copyPlayer:getCurrentCopyID()
	fireProtoMessage(roleID, COPYE_SC_SYNC_ACTIVE_COPYID, 'SyncActiveCopyIdProtocol', ret)
end

--同步玩家副本数据到数据库
function CopyManager:updateRoleCopy(playerID)
	local copyPlayer = self._playerCopyData[playerID]
	if not copyPlayer then return end
	if not copyPlayer:getRole() then return end
	if not copyPlayer:getDBdataload() then return end
	--有数据变更才同步存储
	if copyPlayer:getSyncFlag() then
		local str = copyPlayer:getSyncStr()
		g_entityDao:updateRole(copyPlayer:getRole():getSerialID(), str, "copy")
		copyPlayer:setSyncFlag(false)
	end
	if copyPlayer:getUpdateCopyCnt() then
		g_entityDao:updateCopyCnt(copyPlayer:getRole():getSerialID(), 1, copyPlayer:getCopyTimeStr())
		g_entityDao:updateCopyCnt(copyPlayer:getRole():getSerialID(),3,copyPlayer:getMultiGuardTimeStr())
		copyPlayer:setUpdateCopyCnt(false)

		g_entityDao:updateTowerData(copyPlayer:getRole():getSerialID(),copyPlayer:getTowerData())
	end
	if copyPlayer:getUpdateCopyFast() then
		g_entityDao:updateCopyCnt(copyPlayer:getRole():getSerialID(), 2, copyPlayer:getCopyFastStr())
		copyPlayer:setUpdateCopyFast(false)
	end
	if copyPlayer:getUpdateCopyStar() then
		g_entityDao:updateCopyStar(copyPlayer:getRole():getSerialID(),copyPlayer:getCopyStarStr())
		g_entityDao:updateCopyStarPrize(copyPlayer:getRole():getSerialID(),1,copyPlayer:getCopyStarPrizeStr())
		copyPlayer:setUpdateCopyStar(false)
	end

	if copyPlayer:getSyncProFlag() then
		local rewardStrTab = copyPlayer:getProRewardStr()
		for i=1, 4 do
			g_entityDao:updateCopyReward(copyPlayer:getRole():getSerialID(), i, rewardStrTab[i] or "")
		end
	end

	if copyPlayer:getSingleInstsFlag() then
		g_entityDao:updateSingleInsts(copyPlayer:getRole():getSerialID(), copyPlayer:getSingleInstsStr())
		copyPlayer:setSingleInstsFlag(false)
	end
end

--加载副本数据
function CopyManager:onLoadRoleCopy(playerID, str)
	local player = g_entityMgr:getPlayer(playerID)
	if not player then print("CopyManager.onLoadRoleCopy err") return end
	local copyPlayer = self:getCopyPlayer(playerID)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player:getID())
		self:addCopyPlayer(playerID, copyPlayer)
	end
	copyPlayer:addDBataloadCnt()
	if copyPlayer:getDBataloadCnt() == 3 then
		copyPlayer:setDBdataload(true)
	end
	if str == "" then return end
	copyPlayer:readStr(str)
end

function CopyManager:CanProgressTowerCopy(player,copyPlayer,copyID,tellError)
	if not player or not copyPlayer then return false end
	local proto = self._towerPrototypes[copyID]
	if proto and proto:getAutoProgress() then
		local ret, eCode = CopySystem:getInstance():canEnterCopy(copyPlayer, player, copyID)
		if not ret and eCode then
			if eCode == COPY_ERR_THIS_BOOK_IN_PRO then
				if tellError then
					g_copySystem:fireMessage(0, player:getID(), EVENT_COPY_SETS, COPY_ERR_THIS_BOOK_IN_PRO, 0)
				end
				return false
			end
		else
			local rateStar = copyPlayer:getRatingStar(copyID)
			if rateStar==0 then
				if tellError then
					g_copySystem:fireMessage(0, player:getID(), EVENT_TASK_SETS, -88, 0)
				end
				return false
			end
		end
		local protoMax = g_copyMgr:getProto(copyPlayer:getMaxTowerLayer())
		if protoMax then
			if copyID-COPY_TOWER_FIRST+1>protoMax:getCopyLayer() then
				if tellError then
					g_copySystem:fireMessage(0, player:getID(), EVENT_TASK_SETS, -88, 0)
				end
				return false
			end
		else
			if tellError then
				g_copySystem:fireMessage(0, player:getID(), EVENT_TASK_SETS, -88, 0)
			end
			return false
		end
		return true
	else
		if tellError then
			g_copySystem:fireMessage(0, player:getID(), EVENT_TASK_SETS, -88, 0)
		end
		return false
	end
end

function CopyManager:updateTowerProgressBook()
	for roleSID,totalData in pairs(self._progressTowerCopy) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		local copyPlayer = nil
		local roleID = 0
		if player then
			roleID = player:getID()
			copyPlayer = self:getCopyPlayer(roleID)
		end
		if totalData and totalData.nowProgressId then
			local index = totalData.nowProgressId+COPY_TOWER_FIRST-1
			local allData = totalData.allProgressCopy
			local allLen = totalData.allLen
			if allData and allData[index] then
				local startTime = allData[index].start
				if allData[index].copyId > 0 then
					local nowTime = os.time()
					local school = allData[index].school
					local copyID = allData[index].copyId
					local t = allData[index].needTime
					--print("now process tower:",index,allData[index].copyId)
					if nowTime - startTime >= t then
						--print("finish progress tower!!!!")
						local proto = self:getProto(copyID)
						if proto then
							local data = {}
							local rewardTab = proto:getRewardID()
							local rewardData = dropString(school, allData[index].sex, rewardTab[1])
							if #rewardData == 0 then
								print("-----一键扫荡取不到普通掉落")
							end

							for i=1, #rewardData do
								local tmpresult = rewardData[i]
								local tmpNum = 0
								if data[tmpresult.itemID] ~= nil then 
									tmpNum = data[tmpresult.itemID].num 
								end
								data[tmpresult.itemID] = {}
								data[tmpresult.itemID].num = tmpNum + tmpresult.count
								data[tmpresult.itemID].bind = tmpresult.bind
							end
							--如果在线添加到扫荡奖励列表
							if copyPlayer then
								copyPlayer:addProReward(nowTime, copyID, data)
								
							else
								--不在线添加到离线列表
								self._offProRewards[roleSID] = self._offProRewards[roleSID] or {}
								self._offProRewards[roleSID][nowTime] = {[copyID] = data}
							end
							local ret = {}
							ret.copyType = CopyType.TowerCopy
							ret.copyId = copyID
							ret.rewardInfo = {}
							for k,v in pairs(data) do
								local info = {}
								info.rewardId = k
								info.rewardCount = v.num
								table.insert(ret.rewardInfo,info)
							end
							if copyPlayer and player then
								g_ActivityMgr:sevenFestivalChange(roleID, ACTIVITY_ACT.TOWER, copyPlayer:getTowerCopyProgress())
								--copyPlayer:setTowerCopyProgress(copyPlayer:getTowerCopyProgress()+1)
								copyPlayer:setNowProgressCopyId(0,0,0)
								fireProtoMessage(roleID,COPY_SC_FINISH_PROGRESS_ONE,"CopyTowerFinishProgressOneProtocol",ret)
								copyPlayer:setUpdateCopyCnt(true)
								g_normalMgr:activeness(roleID,ACTIVENESS_TYPE.TOWER)
							end
							self._progressTowerCopy[roleSID].allProgressCopy[index] = nil
							self._progressTowerCopy[roleSID].nowProgressId = self._progressTowerCopy[roleSID].nowProgressId+1
							--print("finish tower!!!now progressId:",self._progressTowerCopy[roleSID].nowProgressId)
							if self._progressTowerCopy[roleSID].nowProgressId > allLen then
								self._progressTowerCopy[roleSID] = nil
								if player then	
									local ret = {}
									fireProtoMessage(player:getID(), COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
								end
							else
								local ret2 = {}
								ret2.copyType = CopyType.TowerCopy
								ret2.copyId = allData[index+1].copyId
								ret2.leftTime = COPY_TOWER_PROGRESS_TIME
								fireProtoMessage(roleID,COPY_SC_START_PROGRESS_ONE ,"CopyTowerStartProgressOneProtocol",ret2)
								self._progressTowerCopy[roleSID].allProgressCopy[index+1].start = os.time()
								if copyPlayer then
									copyPlayer:setNowProgressCopyId(allData[index+1].copyId,os.time(),COPY_TOWER_PROGRESS_TIME)
								end
								
							end
						end
					end
				end
			end
		end
	end
end


function CopyManager:addTowerProgressCopy(player,copyID,needTime,startprogressIndex)
	local roleSID = player:getSerialID()
	self._progressTowerCopy[roleSID].nowProgressId = startprogressIndex
	--print("start tower!!!now progressId:",self._progressTowerCopy[roleSID].nowProgressId,copyID)
	self._progressTowerCopy[roleSID].allLen = self._progressTowerCopy[roleSID].allLen + 1
	progressData = {}
	progressData.copyId = copyID
	progressData.needTime = needTime
	progressData.start = os.time()
	progressData.school = player:getSchool()
	progressData.sex = player:getSex()
	self._progressTowerCopy[roleSID].allProgressCopy[copyID] = progressData
	--table.insert(self._progressTowerCopy[roleSID].allProgressCopy,progressData)
	self._playerCopyData[player:getID()]:setNowProgressCopyId(copyID,os.time(),needTime)

	
end

function CopyManager:stopProgressTowerCopy(player)
	local data = self._progressTowerCopy[player:getSerialID()]
	if not data then
		print("CopyManager:stopProgressTowerCopy error")
		return
	end
	local copyPlayer = self:getCopyPlayer(player:getID())
	--告诉前端有奖励可领
	if copyPlayer then
		copyPlayer:setNowProgressCopyId(0,0,0)
		copyPlayer:setTowerCopyProgress(self._progressTowerCopy[player:getSerialID()].nowProgressId)
		--print("stop progress now id:",self._progressTowerCopy[player:getSerialID()].nowProgressId)
	end
	local ret = {}
	if table.size(copyPlayer:getProRewards())> 0 then
		local ret = {}
		fireProtoMessage(player:getID(), COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
	end

	self._progressTowerCopy[player:getSerialID()] = nil
	g_copySystem:testdoGetTowerCopyData(player:getSerialID())
end



--更新扫荡数据
function CopyManager:updateProgressBook()
	for roleSID, totalData in pairs(self._progressCopy) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		local copyPlayer = nil
		if player then
			local roleID = player:getID()
			copyPlayer = self:getCopyPlayer(roleID)
		end
			
		local startTime = totalData.start
		local data = totalData.data
		if table.size(data) > 0 then
			local nowTime = os.time()
			local school = totalData.school
			local copyID = data[1][1]
			local t = data[1][2]
			if nowTime - startTime >= t then
				--重置开始
				totalData.start = nowTime
				local school = totalData.school
				local sex = totalData.sex
				if copyPlayer then 
					copyPlayer:setProgressSingleTime(nowTime) 
					school = player:getSchool()
					sex = player:getSex()
				end
				table.remove(data, 1)
				local proto = self:getProto(copyID)
				if proto then
					local rewardTab = proto:getRewardID()
					local rewardData = {}
					local rewardData1 = dropString(school, sex, rewardTab[1])
					if #rewardData1 == 0 then
						print("-----扫荡取不到普通掉落")
					end
					for i=1, #rewardData1 do
						local tmpresult = rewardData[i]
						local tmpNum = data[tmpresult.itemID].num or 0
						data[tmpresult.itemID] = ｛｝
						data[tmpresult.itemID].num = tmpNum + tmpresult.count
						data[tmpresult.itemID].bind = tmpresult.bind
					end
					--如果在线添加到扫荡奖励列表
					if copyPlayer then
						copyPlayer:addProReward(nowTime, copyID, rewardData)
						--告诉前端有奖励可领
						local ret = {}
						fireProtoMessage(player:getID(), COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
					else
						--不在线添加到离线列表
						self._offProRewards[roleSID] = self._offProRewards[roleSID] or {}
						self._offProRewards[roleSID][nowTime] = {[copyID] = rewardData}
					end
				end

				if table.size(data) == 0 then
					--全部扫荡结束
					if copyPlayer then
						copyPlayer:setProgressSingleTime(0) 
						getOpenWinData(player:getID())
					else
						--存数据库
						local str = tostring(table.size(self._offProRewards[roleSID]))
						for t1, data1 in pairs(self._offProRewards[roleSID]) do
							str = str .. "&" .. tostring(t1) .. "&" .. table.size(data1)
							for cpid, re in pairs(data1) do
								str = str .. "&" .. cpid .. "&" .. table.size(re)
								for itemID, count in pairs(re) do
									str = str .. "&" .. tostring(itemID) .. "&" .. tostring(count)
								end
							end
						end		
						g_entityDao:update3params(roleSID, 5, str, 410, "_roleID", "_idx", "_data")
					end
					self._progressCopy[roleSID] = nil
					self._offProRewards[roleSID] = nil
				elseif player then
					getOpenWinData(player:getID())
					local ret = {}
					ret.copyId = data[1][1]
					ret.fastTime = data[1][2]
					fireProtoMessage(player:getID(), COPY_SC_STARTPROGRESSRET, 'StartProgressRetProtocol', ret)
				end
			end
		end
	end
end

function CopyManager:updatePosition()
	for roleID, _ in pairs(self._synMemPosInfos) do
		local copyPlayer = self._playerCopyData[roleID]
		if copyPlayer then
			if copyPlayer:getCopyTeamID() > 0 and copyPlayer:getCurrentCopyID() > 0 then
				local copyTeam = self:getCopyTeam(copyPlayer:getCopyTeamID())
				local allCopyMems = copyTeam:getAllMember()
				local data = {}
				for i=1, #allCopyMems do
					local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
					if roleID ~= player:getID() then
						local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
						local pos = memPlayer:getPosition()
						table.insert(data, {pos.x, pos.y, id, memPlayer:getName()})
					end
				end
				if #data > 0 then
					local ret = {}
					ret.bTag = true
					ret.num = #data
					ret.infos = {}
					for i=1, #data do
						local info = {}
						info.posX = data[i][1]
						info.posY = data[i][2]
						info.mapId = data[i][3]
						info.name = data[i][4]
						table.insert(ret.infos,info)
					end
					fireProtoMessage(roleID, TEAM_SC_GETTEAMPOSINFO , 'TeamGetTeamPosInfoProtocol', ret)
				end
			else
				self._synMemPosInfos[roleID] = nil	
			end
		else
			self._synMemPosInfos[roleID] = nil
		end
	end
end

function CopyManager:update()
	--self:flushMonsterByTimer()
	self:updateCopyTime()
	self:updateProgressBook()
	self:updateTowerProgressBook()
	self:deleteSceneOnTimer()
	if os.time() - self._syncTime > 300 then
		for roleID, copyPlayer in pairs(self._playerCopyData) do
			self:updateRoleCopy(roleID)
		end
		self._syncTime = os.time()
	end

	self:roleBackMonster()
	self:updatePosition()
	
	
end

----------------GM CMD----------------------
--设置最后打的守护副本层数 
--layer是层数不是副本ID

function CopyManager:setLastGuardLayer(roleID, layer)
	local copyPlayer = self:getCopyPlayer(roleID)
	if copyPlayer then
		local maxGuardLayer = copyPlayer:getMaxGuard()
		for k, v in pairs(self._guardPrototypes) do
			if v:getCopyLayer() == layer then
				if layer > maxGuardLayer then
					copyPlayer:setMaxGuardLayer(k)
				end
				copyPlayer:setLastGuardLayer(k)
				return 
			end
		end
	end
end
----------------GM CMD----------------------

function CopyManager.getInstance()
	return CopyManager()
end



function CopyManager:updateNewSingleCopyTime()
	for instId, copyBook in pairs(self._newsingleCopy) do
		local playerID = copyBook:getPlayerID()
		local copyPlayer = self._playerCopyData[playerID]
		if copyPlayer then
			--print("updateNewSingleCopyTime",copyBook:getCopyID(),copyBook:getStatus(),copyBook:getCurrCircle(),copyBook:getMonsterNum())
			if copyBook:getStatus() == CopyStatus.Active then
				if copyBook:getRemainTime() <= 0 or (copyBook:getDeadTime() ~= 0 and os.time() - copyBook:getDeadTime() > 30) then
					copyBook:copyFailed()
					self:addRollBackCopy(instId)
				elseif copyBook:getMonsterNum() == 0 and (os.time() - copyBook:getMonsClearTime()) >= 2 then
					copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
					g_copySystem:flushMonster(copyBook, copyBook:getCurrCircle())
					local ret = {}
					ret.copyType = copyBook:getPrototype():getCopyType()
					ret.curCircle = copyBook:getCurrCircle()
					ret.remainTime = copyBook:getRemainTime()
					fireProtoMessage(playerID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
				--通天塔副本结束
				elseif copyBook:getBossID() then
					local boss = g_entityMgr:getMonster(copyBook:getBossID())
					if boss then
						if copyBook:getCopyEndTime() and (os.time() - copyBook:getCopyEndTime()) >= 6 then
							g_copySystem:onMonsterKill(boss:getModelID(), playerID, boss:getID())
						elseif not copyBook:getCopyEndTime() then
							if boss:getBuffMgr():isExist(325) then
								copyBook:setCopyEndTime(os.time())
								--通知客户端
								--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_SINGLECOPYBOSS)
								buffer:pushInt(boss:getID())
								g_engine:fireLuaEvent(playerID, buffer)]]
								local ret = {}
								ret.bossid = boss:getID()
								fireProtoMessage(playerID, COPY_SC_SINGLECOPYBOSS, 'CopySingleCopyBossProtocol', ret)
							end
						end
					end
				end
			--玩家客户端未发送退出副本请求时
			elseif (os.time() - copyBook:getEndTime()) > NEWSINGLECOPY_OUT_TIME then
				copyBook:clearBook()
			end
		end
	end
end

function CopyManager:updateTrivialCopyTime()
	--[[
	for instId, copyBook in pairs(self._trivialCopy) do
		local playerID = copyBook:getPlayerID()
		local copyPlayer = self._playerCopyData[playerID]
		if copyPlayer and (os.time() - copyBook:getStartTime()) > TRIVIALCOPY_OUT_TIME then
			copyBook:clearBook()
		end
	end
	--]]
end

function CopyManager:updateSingleGuardCopyTime()
	local nowTime = os.time()
	for instId, copyBook in pairs(self._singleGuardCopy) do
		local copyPlayer = self._playerCopyData[copyBook:getPlayerID()]
		local player = g_entityMgr:getPlayer(copyBook:getPlayerID())
		if copyPlayer and player then
			if copyBook:getStatus() == CopyStatus.Active then
				if nowTime - copyBook:getStartTime() == 10 then
					--开始刷怪
					g_copySystem:flushSingleGuardCopyMonster(player,copyBook, 1, 1, player:getID()+1)
					copyBook:setCurRound(1)
					copyBook:setLastRoundTime(os.time())
				elseif (nowTime - copyBook:getStartTime()>10) and (nowTime - copyBook:getMonsClearTime()) >= 2 
					and copyBook:getCurRound()<3 and os.time()-copyBook:getLastRoundTime()>=10 then
					copyBook:setCurRound(copyBook:getCurRound()+1)
					g_copySystem:flushSingleGuardCopyMonster(player,copyBook, copyBook:getCurrCircle(),copyBook:getCurRound(), player:getID()+1)
					copyBook:setLastRoundTime(os.time())
				elseif (nowTime - copyBook:getStartTime()>10) and copyBook:getMonsterNum() == 0 
					and (nowTime - copyBook:getMonsClearTime()) >= 2 
					and copyBook:getCurRound() >= 3 then
					copyBook:setCurrCircle(copyBook:getCurrCircle() + 1)
					--刷新下一波怪物
					g_copySystem:flushSingleGuardCopyMonster(player,copyBook, copyBook:getCurrCircle(),1, player:getID()+1)
					copyBook:setCurRound(1)
					copyBook:setLastRoundTime(os.time())
					copyBook:clearKilledMonster()
					local ret = {}
					ret.copyType = copyBook:getPrototype():getCopyType()
					ret.curCircle = copyBook:getCurrCircle()
					ret.remainTime = nowTime-copyBook:getStartTime()
					
					fireProtoMessage(player, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
				end
			elseif (os.time() - copyBook:getEndTime()) > 10 then
				copyBook:clearBook()
			end
		end
	end
end

function CopyManager:CalTowerBookFinishedCopyCount(roleID)
	local finishedCount = 0
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local allTowerProto = g_copyMgr:getTowerProtos()
	if copyPlayer then
		for copyID, proto in pairs(allTowerProto) do
			local star = copyPlayer:getRatingStar(copyID)
			if star > 0 then
				finishedCount=finishedCount+1
			end
		end
	end
	return finishedCount
end

function CopyManager:CalTowerBookFastestCopyCount(roleID)
	local finishedCount = 0
	local allTowerProto = g_copyMgr:getTowerProtos()
	local player = g_entityMgr:getPlayer(roleID)
	for copyID, proto in pairs(allTowerProto) do
		local fastData = g_copyMgr:getFastestRecord(copyID, player:getSchool()) or {}
		if #fastData > 0 then
			if fastData[3] == player:getName() then
				finishedCount = finishedCount + 1
			end
		end
	end
	
	return finishedCount
end

function CopyManager:GetFinishNewSingleCopyCount(roleID)
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then 
		return copyPlayer:getDonePlotNum()
	else
		return 0
	end
end

function  CopyManager:getCurMaxStarCounts(roleID)
	local finishedCount = 0
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local allTowerProto = g_copyMgr:getTowerProtos()
	if copyPlayer then
		for copyID, proto in pairs(allTowerProto) do
			local star = copyPlayer:getRatingStar(copyID)
			if star > 0 then
				finishedCount=finishedCount+star
			end
		end
	end
	return finishedCount
end

function CopyManager:addToDeleteList(scene,copyInsId)
	self._toDeleteScenes[scene] = copyInsId
end

function CopyManager:deleteSceneOnTimer()
	for i,v in pairs(self._toDeleteScenes) do
		g_sceneMgr:releaseScene(i, v)
	end
	self._toDeleteScenes = {}
end

function CopyManager:setTowerCopySwitch(value)
	self._towercopyswitch = value
end
function CopyManager:setSingleCopySwitch(value)
	self._singlecopyswitch = value
end

function CopyManager:getTowerCopySwitch()
	return self._towercopyswitch
end
function CopyManager:getSingleCopySwitch()
	return self._singlecopyswitch
end

function CopyManager:addPrizeToList(rewardID,roleID,copyID)
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
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	copyPlayer:addEnterCopyCount(copyID)
	pCopyIDs[copyID] = data
	local nowTime = os.time()
	if table.size(pCopyIDs) > 0 then	
		for cid, re in pairs(pCopyIDs) do
			copyPlayer:addProReward(nowTime, cid, re)
		end
		--告诉前端有奖励可领
		--local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_NOTIFYPROREWARD)
		--g_engine:fireLuaEvent(roleID, buffer)
	end
	return data,prizeLen
end

function CopyManager:canAttendMultiCopy(player,teamTarget)
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		local copyLevel = 1
		if teamTarget == 5 then
			copyLevel = 1
		elseif teamTarget == 6 then
			copyLevel = 2
		elseif teamTarget == 7 then
			copyLevel = 3
		else
			return 4
		end
		if level < 34 then
			return 1
		elseif copyPlayer and copyPlayer:getCurCopyInstID()>0 then
			return 2
		elseif copyPlayer and copyPlayer:getCurrentMultiCopyLevel()<copyLevel then
			return 3
		else
			return 0
		end
	else
		return 4
	end
end

function CopyManager:onFinishSingleInst(copyPlayer, instID)
	if copyPlayer then
		copyPlayer:onFinishSingleInst(instID)
	end
end

function CopyManager:getSingleInstProto(instID)
	if instID then
		return self._singleInstsPrototypes[instID]
	else
		return nil
	end
end

function CopyManager:getSingleInstIDByCopyID(copyID)
	return self._singleInstsProtoCopyIDs[copyID]
end

function CopyManager:onFreshDay()
	print("CopyManager:onFreshDay")
	for id, copyPlayer in pairs(self._playerCopyData) do
		if copyPlayer then
			copyPlayer:resetDailyInst()
		end
	end
end

g_copyMgr = CopyManager.getInstance()

g_copyMgr:parsePrototype()
g_copyMgr:parseMultiProto()
g_copyMgr:parseNewSingleProto()
g_copyMgr:parseTrivialProto()
g_copyMgr:parseSingleInstsProto()g_copyMgr:parseTrivialProto()
g_copyMgr:parseArenaCopyProto()
g_copyMgr:parseSingleGuardProto()