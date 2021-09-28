--GuardBook.lua
--守护副本

GuardBook = class(CopyBook)

function GuardBook:__init()
	self._currCircle = 1	--当前怪物刷新环数，第几波
	self._finishTime = 0	--此副本完成时间
	self._progressReward = {}	--格式：{time1 = {copyid1, copyid2}, time2 = {}}
	self._statueID = 0
	self._sumExp = 0	--累计经验
end

function GuardBook:setSumExp(xp)
	self._sumExp = xp
end

function GuardBook:getSumExp()
	return self._sumExp
end

function GuardBook:onCopyDone()
	
end

function GuardBook:setStatueID(id)
	self._statueID = id
end

function GuardBook:getStatueID()
	return self._statueID
end

function GuardBook:setStartTime()
	self._startTime = os.time()
end


function GuardBook:setFinishTime(ftime)
	self._finishTime = ftime
end

function GuardBook:getFinishTime()
	return self._finishTime
end

function GuardBook:setCurrCircle(circle)
	self._currCircle = circle
end

function GuardBook:getCurrCircle()
	return self._currCircle
end

--添加奖励
function GuardBook:doReward()
	return
	--[[local playerID = self:getPlayerID()
	local player = g_entityMgr:getPlayer(playerID)
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	if not player or not copyPlayer then return end
	local proto = self:getPrototype()
	local maxGuard = copyPlayer:getMaxGuardLayer()
	local maxProto = g_copyMgr:getProto(maxGuard)
	local maxLayer  = maxProto and maxProto:getCopyLayer() or 0
	--local rewardTab = proto:getRewardID()
	--local rewardID = rewardTab[1]
	local specRewardID = proto:getSpecReward()

	--如果没有打过则看是否有特殊奖励
	if specRewardID then
		--给特殊奖励
		copyPlayer:addGuardSpecReward(self:getCopyID())
	end]]
end

function GuardBook.GuardPricess(roleid,npcid,functionid)
	return
	--[[if tonumber(functionid)>=1 and tonumber(functionid)<=3 then
		local guardBook = GuardBook()
		guardBook:StartGuard(roleid,functionid)
	elseif tonumber(functionid)==4 then--重置
		g_copySystem:doResetGuardByNPC(roleid)
	elseif tonumber(functionid)==5 then
		local guardBook = GuardBook()
		guardBook:CheckCurStatus(roleid,npcid)
	elseif tonumber(functionid)==6 then
		local copyPlayer = g_copyMgr:getCopyPlayer(roleid)
		g_copyMgr:dealExitCopy(copyPlayer:getRole(), copyPlayer)
	elseif tonumber(functionid)==7 then
		local player = g_entityMgr:getPlayer(roleid)
		if not player or player:getHP() <= 0 then 
			return 
		end
		if g_CardPrizeMgr:checkHasPrize(roleid) then
			g_CardPrizeMgr:OpenCardPrizeWindow(roleid,0,0)
		else
			local option = {}
			option["text"] = "离开"
			option["type"] = 2
			option["value"] = '2'
			option["icon"] = 0
			option["param"] = 8
			local options = {option,}
			g_dialogServlet:fireDialog(roleid,10398,"我没有可以给你的奖励。",options)
		end
	elseif tonumber(functionid)==8 then
		local player = g_entityMgr:getPlayer(roleid)
		if not player or player:getHP() <= 0 then 
			return 
		end
		g_sceneMgr:enterPublicScene(roleid, 2100, 100, 64)
	end]]
end

function GuardBook:AfterDrawCard(roleid)
	return
	--g_sceneMgr:enterPublicScene(roleid, 2111, 18, 38)
end

function GuardBook:StartGuard(roleid,functionid)
	return
	--[[local copyPlayer = g_copyMgr:getCopyPlayer(roleid)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player)
		g_copyMgr:addCopyPlayer(roleid, copyPlayer)
	end
	if functionid==4 then
		g_copySystem:doResetGuardByNPC(roleid)
		self:CheckCurStatus(roleid)
	else
		local lastGuardLayer = copyPlayer:getLastGuardLayer()
		if lastGuardLayer == 0 then 
			if functionid == 1 then g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_1,0) 
			elseif functionid == 2 then g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_2,0) 
			elseif functionid == 3 then g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_3,0) end
		else
			if functionid == 1 then 
				if lastGuardLayer>=COPY_GUARD_STARTID_1 and lastGuardLayer<COPY_GUARD_STARTID_2 then
					g_copySystem:doEnterCopyByNPC(roleid,lastGuardLayer,0)
				else
					g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_1,0)
				end
			elseif functionid == 2 then 
				if lastGuardLayer>=COPY_GUARD_STARTID_2 and lastGuardLayer<COPY_GUARD_STARTID_3 then
					g_copySystem:doEnterCopyByNPC(roleid,lastGuardLayer,0)
				else
					g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_2,0)
				end
			elseif functionid == 3 then 
				if lastGuardLayer>=COPY_GUARD_STARTID_3 then
					g_copySystem:doEnterCopyByNPC(roleid,lastGuardLayer,0)
				else
					g_copySystem:doEnterCopyByNPC(roleid,COPY_GUARD_STARTID_3,0)
				end
			end
		end
	end]]
end

function GuardBook:CheckCurStatus(roleid)
	return
	--[[local copyPlayer = g_copyMgr:getCopyPlayer(roleid)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player)
		g_copyMgr:addCopyPlayer(roleid, copyPlayer)
	end
	local curLayer = copyPlayer:getLastGuardLayer()
	local level = 0
	local count = 0
	if curLayer==-1 then 
		level = 0
	elseif curLayer>=COPY_GUARD_STARTID_1 and curLayer<COPY_GUARD_STARTID_2 then
		level = 1
		count = curLayer%COPY_GUARD_STARTID_1
	elseif curLayer>=COPY_GUARD_STARTID_2 and curLayer<COPY_GUARD_STARTID_3 then
		level = 2
		count = curLayer%COPY_GUARD_STARTID_2
	elseif curLayer>=COPY_GUARD_STARTID_3 then
		level = 3
		count = curLayer%COPY_GUARD_STARTID_3
	elseif curLayer==0 then
		level = 4
	end

	local resetnum = copyPlayer:getResetGuardNum()
	local totalNum = 1-resetnum

	local stamp = copyPlayer:getResetGuardTimeStamp()
	local timeStamp = time.toedition("day")
	if stamp ~= timeStamp then
		copyPlayer:setResetGuardNum(0)
		totalNum = 1
		copyPlayer:setResetGuardTimeStamp(timeStamp)
	end

	local towerStamp = copyPlayer:getTowerCopyResetTimeStamp()
	if towerStamp ~= timeStamp then
		copyPlayer:setTowerCopyResetTimeStamp(timeStamp)
		copyPlayer:setTowerCopyResetNum(0)
		copyPlayer:setTowerCopyProgress(1)
	end

	local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_GETGUARDDATA_RET)
    buffer:pushInt(roleid)
    buffer:pushShort(level)
    buffer:pushShort(count)
    buffer:pushShort(totalNum)
    g_engine:fireLuaEvent(roleid, buffer)


	--[[local text1 = ""
	if curLayer==-1 then 
		text1 = "今日已通关：尚未通关\n"
	elseif curLayer>=COPY_GUARD_STARTID_1 and curLayer<COPY_GUARD_STARTID_2 then
		text1 = "今日已通关：普通难度第"..curLayer%COPY_GUARD_STARTID_1.."关\n"
	elseif curLayer>=COPY_GUARD_STARTID_2 and curLayer<COPY_GUARD_STARTID_3 then
		text1 = "今日已通关：中等难度第"..curLayer%COPY_GUARD_STARTID_2.."关\n"
	elseif curLayer>=COPY_GUARD_STARTID_3 then
		text1 = "今日已通关：高级难度第"..curLayer%COPY_GUARD_STARTID_3.."关\n"
	elseif curLayer==0 then
		text1 = "恭喜您已经成功救出公主！\n"
	end
	
	local text2 = ""
	local resetnum = copyPlayer:getResetGuardNum()
	local totalNum = vipCnt+1-resetnum
	text2 = "您当前可重置次数为："..totalNum.."次"

	local text = text1..text2

	local mainText = "恶魔城共有三种难度，初级难度39-50级、中级难度51-60级、高级难度61-71级，达到对应等级才可选择对应难度，每天只能选择一种难度进行挑战！\n\n"
	text = mainText..text

	option = {}
	option["text"] = "好的"
	option["type"] = 4
	option["value"] = 0
	option["icon"] = 0
	option["param"] = 0
	options = {option,}
	g_dialogServlet:fireDialog(roleid,npcid,text,options)
	--]]
end