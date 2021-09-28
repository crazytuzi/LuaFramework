--CopyPlayer.lua
--Íæ¼Ò¸±±¾Êý¾Ý

CopyPlayer = class()

local prop = Property(CopyPlayer)
prop:accessor("copyTeamID", 0)		--¶ÓÎéID

local function diffDay(ts1, ts2)
	if ts1 == 0 or ts2 == 0 then
		return true
	end
	local DAY_SEC = 24 * 3600
	if ts2 < ts1 then
		ts1, ts2 = ts2, ts1
	end
	if ts2 - ts1 > DAY_SEC then
		return true
	end
	
	local t1 = os.date("*t", ts1)
	local t2 = os.date("*t", ts2)
	t1.hour, t1.min, t1.sec = 0,0,0
	t2.hour, t2.min, t2.sec = 0,0,0

	ts1 = os.time(t1)
	ts2 = os.time(t2)
	return ts1 ~= ts2
end

function CopyPlayer:__init(roleId)
	self.role = roleId
	self.copyCounts = {}	--ÓÐCD¼ÆÊýµÄ¸±±¾¼ÆÊý
	self.lastEnterTimes = {}
	self.lastTowerTime = 0
	self.lastGuardTime = 0	
	self.successFlag = {}	--±£´æÍ¨¹ØÊ±¼ä£¬×î¿ìµÄÄÇ¸ö
	self._curCopyInstID = 0
	self._curCopyID = 0
	self.towerCnt = 0	--ÅÀËþ¼ÆÊý
	self.syncFlag = false	--Êý¾ÝÊÇ·ñÓÐ¸Ä±ä
	self.lastGuardLayer = -1	--ÊØ»¤¸±±¾ÉÏ´Î½áÊøµÄ²ãÊý,Ä¬ÈÏÎªµÚÒ»²ã,ÕâÊÇÉÏ´Î´òµ½ÕâÀï¾ÍÃ»ÓÐ¼ÌÐø´òÁËµÄ²ãÊý ¸±±¾ID -1±íÊ¾µÚÒ»²ã¶¼Ã»ÓÐÍ¨¹Ø¹ý£¬0±íÊ¾ÐèÒªÖØÖÃ
	self.maxTowerLayer = 0	--ÅÀËþ¸±±¾ÒÑ¾­´òµ½µÄ×î¸ß²ãÊý ¸±±¾ID
	self.maxGuardLayer = 0	--ÊØ»¤¸±±¾´òµ½µÄ×î¸ß²ãÊý£¬ÕâÒ»²ãÊÇÒÑ¾­Í¨¹ØµÄ
	self.guardSpecReward = {}	--ÊØ»¤¸±±¾Î´ÁìÈ¡ÌØÊâ½±Àø,ÀïÃæÊÇ¸±±¾Ô­ÐÍID
	self.guardReward = {}	--ÊØ»¤¸±±¾½±Àø
	self.inviteFriData = {}	--ºÃÓÑÑûÇë¼ÇÂ¼ {id=time}
	self.progressReward = {}	--É¨µ´½±Àø	{time = {copyID, result}}
	self.currProgressReward = {}	--µ±Ç°É¨µ´ÊØ»¤¸±±¾µÄ½±Àø£¬Èç¹ûÎ´ÁìÈ¡¾ÍÌí¼Óµ½É¨µ´½±ÀøÀï
	self.progressSingleTime = 0	--¿ªÊ¼É¨µ´µÄÊ±¼ä
	self.isProgressGuard = false	--ÊÇ·ñÕýÔÚÉ¨µ´ÊØ»¤¸±±¾
	self.resetGuardTime = 0	--ÖØÖÃÊØ»¤¸±±¾CDÊ±¼ä
	self.resetGuardNum = 0	--ÖØÖÃÊØ»¤¸±±¾CD´ÎÊý
	self.syncProFlag = false	--ÊÇ·ñ±£´æÉ¨µ´½±Àø±ê¼Ç
	self.donePlotNum = 0	--Íê³ÉµÄ¾çÇé¸±±¾ÊýÁ¿
	self.doneSingleNum = 0	--Íê³ÉµÄµ¥ÈË¸±±¾ÊýÁ¿
	self.preHP = 0	--½øÈë¸±±¾Ê±µÄÑªÁ¿¼ÇÂ¼
	self.preMP = 0	
	self.towerVipData = {}	--ÅÀËþVIPÊý¾Ý
	self.expVipTime = 0	--¾­Ñé¸±±¾VIP´ÎÊý¼ÇÂ¼Ê±¼ä
	self.expVipCnt = 0	--¾­Ñé¸±±¾VIP´ÎÊý¼ÇÂ¼´ÎÊý
	self.moneyVipTime = 0	--½ð±Ò¸±±¾VIP´ÎÊý¼ÇÂ¼Ê±¼ä
	self.moneyVipCnt = 0	--½ð±Ò¸±±¾VIP´ÎÊý¼ÇÂ¼´ÎÊý
	self.strenVipTime = 0	--Ç¿»¯ËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼Ê±¼ä
	self.strenVipCnt = 0	--Ç¿»¯ËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼´ÎÊý
	self.destVipTime = 0	--ÆÆ»µËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼Ê±¼ä
	self.destVipCnt = 0	--ÆÆ»µËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼´ÎÊý
	self.defVipTime = 0	--ÊØ»¤ËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼Ê±¼ä
	self.defVipCnt = 0	--ÊØ»¤ËéÆ¬¸±±¾VIP´ÎÊý¼ÇÂ¼´ÎÊý
	self.updateCopyCnt = false
	self.updateCopyFast = false
	self.dbdataload = false
	self.dbdataloadCnt = 0
	self.singleInnerTime = {}
	self.towerInnerTime = 0
	self.canTower = true

	self.multiGuardData = {}	--ÊØ»¤ÁúÂöÖ®Àà¸±±¾Êý¾Ý
	--self.multiGuardCnts = {}	--ÊØ»¤ÁúÂö´ÎÊý

	self.callFriendData = {}
	self.updateCopyStar = false
	self.successStar = {} --Í¨ÌìËþÍ¨¹ØÐÇÊý
	self.towerStarPrize = {}--Í¨ÌìËþÐÇÊý½±ÀøÁìÈ¡±ê¼Ç
	self.resetGuardTimeStamp = 0 --ÊØ»¤¸±±¾ÖØÖÃµÄÊ±¼ä´Á
	self.lastDeadTime = 0 --¶àÈË¸±±¾ÉÏ´ÎËÀÍöµÄÊ±¼ä
	self.totalDeadTimes = 0 --¶àÈË¸±±¾×Ü¹²ËÀÍö´ÎÊý
	self.towerCopyProgress = 1 -- Í¨ÌìËþ½ñÈÕ½ø¶È
	self.towerCopyResetTimeStamp = 0 --Í¨ÌìËþÖØÖÃÊ±¼ä
	self.towerCopyResetNum = 0--Í¨ÌìËþÒÑ¾­ÖØÖÃ´ÎÊý
	self.towerCopyActivePrize = 0--
	self.nowProgressTowerCopy = {}
	self.currentMultiCopyLevel = 1

	self.passedSingleInsts = {}
	self.singleInstsFlag = false

	self.dailySingleInstID = 0
	self.dailySingleInstPassed = false
	self.dailySingleInstTime = 0
end

--ÇÐ»»worldµÄÍ¨Öª
function CopyPlayer:switchWorld(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_COPY_SETS)
	--¾ßÌåÊý¾Ý¸úÔÚºóÃæ
	luaBuf:pushString(serialize(self.copyCounts))
	luaBuf:pushString(serialize(self.lastEnterTimes))
	luaBuf:pushInt(self.lastTowerTime)
	luaBuf:pushInt(self.lastGuardTime)
	luaBuf:pushString(serialize(self.successFlag))
	luaBuf:pushInt(self._curCopyInstID)
	luaBuf:pushInt(self._curCopyID)
	luaBuf:pushInt(self.towerCnt)
	luaBuf:pushInt(self.lastGuardLayer)
	luaBuf:pushInt(self.maxTowerLayer)
	luaBuf:pushInt(self.maxGuardLayer)
	luaBuf:pushString(serialize(self.guardSpecReward))
	luaBuf:pushString(serialize(self.guardReward))
	luaBuf:pushString(serialize(self.inviteFriData))
	luaBuf:pushString(serialize(self.progressReward))
	luaBuf:pushString(serialize(self.currProgressReward))
	luaBuf:pushInt(self.progressSingleTime)
	luaBuf:pushBool(self.isProgressGuard)
	luaBuf:pushInt(self.resetGuardTime)
	luaBuf:pushInt(self.resetGuardNum) 
	luaBuf:pushBool(self.syncProFlag)
	luaBuf:pushInt(self.donePlotNum)
	luaBuf:pushInt(self.doneSingleNum)
	luaBuf:pushString(serialize(self.towerVipData))
	luaBuf:pushBool(self.updateCopyCnt)
	luaBuf:pushBool(self.updateCopyFast)
	luaBuf:pushBool(self.dbdataload)
	luaBuf:pushInt(self.dbdataloadCnt)
	luaBuf:pushString(serialize(self.singleInnerTime))
	luaBuf:pushInt(self.towerInnerTime)
	luaBuf:pushBool(self.canTower)
	luaBuf:pushString(serialize(self.multiGuardData))
	luaBuf:pushString(serialize(self.callFriendData))
	luaBuf:pushBool(self.updateCopyStar)
	luaBuf:pushString(serialize(self.successStar))
	luaBuf:pushString(serialize(self.towerStarPrize))
	luaBuf:pushInt(self.resetGuardTimeStamp)
	luaBuf:pushInt(self.towerCopyProgress)
	luaBuf:pushInt(self.towerCopyResetTimeStamp)
	luaBuf:pushInt(self.towerCopyResetNum)
	luaBuf:pushInt(self.towerCopyActivePrize)
	luaBuf:pushInt(self.currentMultiCopyLevel)
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

function CopyPlayer:loadDBDataImpl(player, luaBuf)
	if luaBuf:size() > 0 then
		self.copyCounts = unserialize(luaBuf:popString())
		self.lastEnterTimes = unserialize(luaBuf:popString())
		self.lastTowerTime = luaBuf:popInt()
		self.lastGuardTime = luaBuf:popInt()
		self.successFlag = unserialize(luaBuf:popString())
		self._curCopyInstID = luaBuf:popInt()
		self._curCopyID = luaBuf:popInt()
		self.towerCnt = luaBuf:popInt()
		self.lastGuardLayer = luaBuf:popInt()
		self.maxTowerLayer = luaBuf:popInt()
		self.maxGuardLayer = luaBuf:popInt()
		self.guardSpecReward = unserialize(luaBuf:popString())
		self.guardReward = unserialize(luaBuf:popString())
		self.inviteFriData = unserialize(luaBuf:popString())
		self.progressReward = unserialize(luaBuf:popString())
		self.currProgressReward = unserialize(luaBuf:popString())
		self.progressSingleTime = luaBuf:popInt()
		self.isProgressGuard = luaBuf:popBool()
		self.resetGuardTime = luaBuf:popInt()
		self.resetGuardNum = luaBuf:popInt()
		self.syncProFlag = luaBuf:popBool()
		self.donePlotNum = luaBuf:popInt()
		self.doneSingleNum = luaBuf:popInt()
		self.towerVipData = unserialize(luaBuf:popString())
		self.updateCopyCnt = luaBuf:popBool()
		self.updateCopyFast = luaBuf:popBool()
		self.dbdataload = luaBuf:popBool()
		self.dbdataloadCnt = luaBuf:popInt()
		self.singleInnerTime = unserialize(luaBuf:popString())
		self.towerInnerTime = luaBuf:popInt()
		self.canTower = luaBuf:popBool()
		self.multiGuardData = unserialize(luaBuf:popString())
		
		self.callFriendData = unserialize(luaBuf:popString())
		self.updateCopyStar = luaBuf:popBool()
		self.successStar = unserialize(luaBuf:popString())
		self.towerStarPrize = unserialize(luaBuf:popString())
		self.resetGuardTimeStamp = luaBuf:popInt()
		self.towerCopyProgress = luaBuf:popInt()
		self.towerCopyResetTimeStamp = luaBuf:popInt()
		self.towerCopyResetNum = luaBuf:popInt()
		self.towerCopyActivePrize = luaBuf:popInt()
		self.currentMultiCopyLevel = luaBuf:popInt()
	end
end

--ËùÓÐ¶àÈË±¾Êý¾Ý
function CopyPlayer:getAllMultiGuardData()
	return self.multiGuardData
end

--¶àÈË±¾CD
function CopyPlayer:getMultiGuardCnt(copyID)
	return self.multiGuardData[copyID] and self.multiGuardData[copyID].cnt or 0
end

--¶àÈË±¾Ê±¼ä
function CopyPlayer:getMultiGuardTime(copyID)
	return self.multiGuardData[copyID] and self.multiGuardData[copyID].t or 0
end

--¶àÈË±¾¼ÆÊý
function CopyPlayer:addMultiGuardCnt(copyID,curCircle)
	self.multiGuardData[copyID] = self.multiGuardData[copyID] or {}
	self.multiGuardData[copyID].cnt = curCircle
	self.updateCopyCnt = true
end

function CopyPlayer:resetMultiGuardCnt(copyID)
	local ot = self.multiGuardData[copyID] and self.multiGuardData[copyID].t or 0
	local nt = time.toedition("day")
	if not self.multiGuardData[copyID] then self.multiGuardData[copyID] = {} end
	self.multiGuardData[copyID].t = nt
	self.multiGuardData[copyID].cnt = 0
	self.updateCopyCnt = true
end

function CopyPlayer:getAllInnerTime()
	return self.singleInnerTime
end

function CopyPlayer:setSingleInnerTime(copyID, t)
	self.singleInnerTime[copyID] = t
	self.updateCopyCnt = true
end

--²ÄÁÏ¸±±¾ÄÚÖÃCD
function CopyPlayer:getSingleInnerTime(copyID)
	return self.singleInnerTime[copyID] or 0
end

--ÅÀËþÄÚÖÃCD
function CopyPlayer:addTowerInnerTime(t)
	local nt = os.time()
	if t >= 0 then
		self.canTower =false
	end
	if self.towerInnerTime == 0 or nt >= self.towerInnerTime then
		self.towerInnerTime = nt+t
	else
		self.towerInnerTime = self.towerInnerTime + t
		if self.towerInnerTime - nt >= 0 then
			self.canTower = false
		end
	end
	self.syncFlag = true
end

function CopyPlayer:setCanTower(flag)
	self.canTower = flag
	self.syncFlag = true
end

function CopyPlayer:getTowerInnerTime()
	return self.towerInnerTime
end

function CopyPlayer:getCanTower()
	return self.canTower
end

function CopyPlayer:addDBataloadCnt()
	self.dbdataloadCnt = self.dbdataloadCnt + 1
end

function CopyPlayer:getDBataloadCnt()
	return self.dbdataloadCnt
end

function CopyPlayer:getDBdataload()
	return self.dbdataload
end

function CopyPlayer:setDBdataload(flag)
	self.dbdataload = flag
end

function CopyPlayer:setUpdateCopyFast(flag)
	self.updateCopyFast = flag
end

function CopyPlayer:getUpdateCopyFast()
	return self.updateCopyFast
end

function CopyPlayer:setUpdateCopyCnt(flag)
	self.updateCopyCnt = flag
end

function CopyPlayer:getUpdateCopyCnt()
	return self.updateCopyCnt
end

function CopyPlayer:setUpdateCopyStar(flag)
	self.updateCopyStar = flag
end

function CopyPlayer:getUpdateCopyStar()
	return self.updateCopyStar
end

local castIngot = function(player, ingot)
	local old = player:getIngot()
	if old >= ingot then
		player:setIngot(old-ingot)
		g_PayRecord:Record(player:getID(), -ingot, CURRENCY_INGOT, 17)
		--³äÖµ³É¾Í
		g_achieveSer:costIngot(player:getSerialID(), ingot)
		return true
	else
		return false
	end	
end

function CopyPlayer:getTowerVipData()
	return self.towerVipData
end

function CopyPlayer:getExpVipTime()
	return self.expVipTime
end

function CopyPlayer:getExpVipCnt()
	return self.expVipCnt
end

function CopyPlayer:getMoneyVipTime()
	return self.moneyVipTime
end

function CopyPlayer:getMoneyVipCnt()
	return self.moneyVipCnt
end

function CopyPlayer:getStrenVipTime()
	return self.strenVipTime
end

function CopyPlayer:getStrenVipCnt()
	return self.strenVipCnt
end

function CopyPlayer:getDestVipTime()
	return self.destVipTime
end

function CopyPlayer:getDestVipCnt()
	return self.destVipCnt
end

function CopyPlayer:getDefVipTime()
	return self.defVipTime
end

function CopyPlayer:getDefVipCnt()
	return self.defVipCnt
end

--false±íÊ¾½ñÌì´ÎÊýÒÑ¾­ÓÃÍêÁË
function CopyPlayer:setTowerVip(needIngot, copyID, flag)
	if flag then
		--ÐÂCDÖØÖÃ¼ÆÊý
		self.towerVipData = nil
		self.updateCopyCnt = true
		return true
	else
		local ot = self.towerVipData and self.towerVipData[1] or 0 	--oldtime
		local oc = self.towerVipData and self.towerVipData[2] or 0	--oldcnt
		local nt = getNormalUpdateTime(ot)
		if nt ~= ot then
			self.updateCopyCnt = true
			local ingot = needIngot
			if type(needIngot) == "table" then
				ingot = needIngot[1]
			else
				print("-----CopyPlayer:setTowerVip",toString(ingot))
			end
			if castIngot(self:getRole(), ingot) then
				self.towerVipData = {nt, 1}
					--self.copyCounts[copyID] = self.copyCounts[copyID] - 1
				self:subTowerCnt()
				return true
			else
				self.towerVipData = {nt, 0}
				return false, COPY_ERR_NOT_ENOUGH_INGOT
			end
		else
			if TOWER_RESET_CDCOUNT > oc then
				local ingot = needIngot[oc+1]
				if castIngot(self:getRole(), ingot) then
					self.towerVipData = {nt, oc+1}
					--self:clearEnterCDCount(copyID)
					--self.copyCounts[copyID] = self.copyCounts[copyID] - 1
					self:subTowerCnt()
					self.updateCopyCnt = true
					return true
				else
					return false, COPY_ERR_NOT_ENOUGH_INGOT
				end
			else 
				return false, COPY_ERR_VIPRESET_FAILED
			end
		end
	end
end


function CopyPlayer:getLastGuard()
	if self.lastGuardLayer == -1 then
		return 0
	elseif self.lastGuardLayer == 0 then
		local maxProto = g_copyMgr:getProto(self.maxGuardLayer)
		return maxProto and maxProto:getCopyLayer() or 0
	else
		local proto = g_copyMgr:getProto(self.lastGuardLayer)
		return (proto and (proto:getCopyLayer()-1)) or 0
	end
end

function CopyPlayer:getMaxGuard()
	local maxProto = g_copyMgr:getProto(self.maxGuardLayer)
	if maxProto then
		return maxProto:getCopyLayer()
	else
		return self.maxGuardLayer
	end
end

function CopyPlayer:getAllInviteData()
	return self.inviteFriData
end

function CopyPlayer:getInviteData(roleSID)
	return self.inviteFriData[roleSID] or 0
end

function CopyPlayer:addFriInviteData(friSID, t, flag)
	if not flag then
		local nt = time.toedition("day")
		if self.callFriendData[friSID] then
			local oct = self.callFriendData[friSID][1]
			if nt == oct then
				self.callFriendData[friSID][2] = self.callFriendData[friSID][2] + 1
			else
				self.callFriendData[friSID] = {nt, 1}
			end
		else
			self.callFriendData[friSID] = {nt, 1}
		end
	end
	self.inviteFriData[friSID] = t
end

function CopyPlayer:getFriInviteCnt(friSID)
	if not self.callFriendData[friSID] then
		return 0
	else
		if self.callFriendData[friSID][1] == time.toedition("day") then
			return self.callFriendData[friSID][2]
		else
			return 0
		end
	end
end

function CopyPlayer:getAllCallCD()
	return self.callFriendData
end

function CopyPlayer:setAllCallCD(data)
	self.callFriendData = data
end

function CopyPlayer:getLastTowerTime()
	return self.lastTowerTime
end

--ÖØÖÃÊØ»¤CD
function CopyPlayer:clearGuardCDCount(t)
	self.resetGuardTime = t
	self.resetGuardNum = 0
	self.syncFlag = true
end

function CopyPlayer:setResetGuardNum(num)
	if self.resetGuardNum ~= num then
		self.resetGuardNum = num
		self.syncFlag = true
	end
end

function CopyPlayer:getResetGuardNum()
	return self.resetGuardNum 
end

function CopyPlayer:setResetGuardTime(nowTime, cnt)
	--ÅÐ¶ÏÊÇ·ñÊÇÐÂCD
	if nowTime - self.resetGuardTime > ONE_DAY_SEC then
		if cnt then
			self.resetGuardNum = cnt
			self.resetGuardTime = 0
		else
			self.resetGuardNum = 1
			local nowDate = os.date("*t",nowTime)
			local difTime = 0
			if nowDate.hour < UPDATE_COPY_TIME then
				difTime = -ONE_DAY_SEC
			end
			nowDate.hour = UPDATE_COPY_TIME
			nowDate.min = 0
			nowDate.sec = 0
			self.resetGuardTime = os.time(nowDate) + difTime
		end
	else
		local cdCnt = self.resetGuardNum or 0
		self.resetGuardNum = cdCnt + 1	
	end
	self.syncFlag = true
end

function CopyPlayer:getResetGuardTime()
	return self.resetGuardTime
end

function CopyPlayer:addCurrProReward(t, data)
	self.currProgressReward = {t, data}
end

function CopyPlayer:getCurrProReward()
	return self.currProgressReward
end

function CopyPlayer:clearCurProReward()
	self.currProgressReward = {}
end

--Ð£ÑéÉ¨µ´½±ÀøÊÇ·ñµ½ÆÚ
function CopyPlayer:checkProReward()
	local nowTime = os.time()
	for t, redata in pairs(self.progressReward) do
		if nowTime - t >= TEN_DAY_SEC then
			self.progressReward[t] = nil
		end
	end
end

function CopyPlayer:getProRewards()
	return self.progressReward
end

function CopyPlayer:setProRewards(data)
	self.progressReward = data
end

function CopyPlayer:clearProRewards()
	self.progressReward = {}
	self.syncProFlag = true
end

--Ìí¼ÓÊØ»¤¸±±¾¿ÉÒÔÀëÏßµÄÊý¾Ý
--t Ê±¼ä  copyID ¸±±¾ID data ½±ÀøÊý¾Ý
function CopyPlayer:addProReward(t, copyID, data)
	self.progressReward[t] = self.progressReward[t] or {}
	if self.progressReward[t][copyID] then
		for itemID, cnt in pairs(data) do
			self.progressReward[t][copyID][itemID] = (self.progressReward[t][copyID][itemID] or 0) + cnt
		end
	else
		self.progressReward[t][copyID] = data 
	end
	self.syncProFlag = true
end

--É¾³ýÊØ»¤¸±±¾¿ÉÒÔÀëÏßµÄÊý¾Ý
--t Ê±¼ä  copyID ¸±±¾ID data ½±ÀøÊý¾Ý
function CopyPlayer:delProReward(t)
	self.progressReward[t] = nil
end

function CopyPlayer:addGuardSpecReward(specReward)
	table.insert(self.guardSpecReward, specReward)
	self.syncFlag = true
end

function CopyPlayer:getGuardSpecReward()
	return self.guardSpecReward or {}
end

function CopyPlayer:clearGuardReward()
	self.guardReward = {}
end

--ÁÙÊ±ÊØ»¤¸±±¾½±Àø
function CopyPlayer:getGuardReward()
	return self.guardReward
end

function CopyPlayer:addGuardReward(reward)
	table.insert(self.guardReward, reward)
end

function CopyPlayer:getTowelLastEnterTime()
	local lastTime = 0
	for k,v in pairs(self.lastEnterTimes) do
		local proto = g_copyMgr:getProto(k)
		if proto then
			if proto:getCopyType() == CopyType.TowerCopy then
				if v > lastTime then
					lastTime = v
				end
			end
		end
	end
	return lastTime
end

function CopyPlayer:getCopyCDCount()
	return self.copyCounts
end

function CopyPlayer:getIsProgressGuard()
	return self.isProgressGuard
end

function CopyPlayer:setProgressGuard(flag)
	self.isProgressGuard = flag
end

function CopyPlayer:getProgressSingleTime()
	return self.progressSingleTime
end

function CopyPlayer:setProgressSingleTime(flag)
	self.progressSingleTime = flag
end

--½±Àø×Ö·û´®
function CopyPlayer:getProRewardStr()
	local totalStr = {}
	if table.size(self.progressReward) == 0 then
		return totalStr
	else
		local j=0
		local str = ""
		local nt = os.time()
		for t, data in pairs(self.progressReward) do
			if nt - t < TEN_DAY_SEC then
				local tmpstr = ""
				tmpstr = tmpstr .. t .. "&" .. table.size(data)
				for copyID, data2 in pairs(data) do
					tmpstr = tmpstr .. "&" .. copyID .. "&" .. table.size(data2)
					for itemID, count in pairs(data2) do
						tmpstr = tmpstr.."&"..tostring(itemID).."&"..tostring(count)
					end
				end
				--´óÓÚ1000¸ö×Ö·ûÁËÒª·Ö¿ª
				if string.len(str) + string.len(tmpstr) >= 900 then
					table.insert(totalStr, j .. "&" .. str)
					str = tmpstr .. "&"
					j = 1
				else
					str = str .. tmpstr .. "&"
					j = j+1
				end
			end
		end
		table.insert(totalStr, j .. "&" .. str)
		return totalStr
	end
end

function CopyPlayer:readProRewardStr(str)
	local dataTab = {}
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
	end
	local tcnt = tonumber(dataTab[1])
	local tmpCnt = 1
	local rewardData = {}

	for i=1, tcnt do
		local t = tonumber(dataTab[tmpCnt+1])
		local rcnt = tonumber(dataTab[tmpCnt+2])
		tmpCnt = tmpCnt+2
		self.progressReward[t] = {}
		for j=1, rcnt do
			local copyID = tonumber(dataTab[tmpCnt+1])
			local itemcnt = tonumber(dataTab[tmpCnt+2])
			tmpCnt = tmpCnt + 2
			local tmpData = {}
			for k=1, itemcnt do
				local itemID = tonumber(dataTab[tmpCnt + 1])
				local itemCnt = tonumber(dataTab[tmpCnt + 2])
				tmpData[itemID] = itemCnt
				tmpCnt = tmpCnt + 2
			end
			self.progressReward[t][copyID] = tmpData
		end
	end
end

function CopyPlayer:getSyncStr()
	local str = tostring(self.towerCnt).."&"..tostring(self.lastTowerTime).."&"..tostring(self.maxTowerLayer).."&"..tostring(self.lastGuardLayer).."&"..
	tostring(self.maxGuardLayer).."&"..self.resetGuardTime.."&"..self.resetGuardNum
	
	str = str.."&"..tostring(#self.guardSpecReward)
	--ÊØ»¤ÌØÊâ¹Ø¿¨½±Àø
	for i=1, #self.guardSpecReward do
		str = str.."&"..tostring(self.guardSpecReward[i])
	end
	str = str .. "&" .. tostring(self.towerInnerTime) .. "&" .. tostring(self.canTower and 1 or 0)
	return str
end

function CopyPlayer:readStr(str)
	local dataTab = {}
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
	end
	self.towerCnt = tonumber(dataTab[1])
	self.lastTowerTime = tonumber(dataTab[2])
	self.maxTowerLayer = tonumber(dataTab[3])
	self.lastGuardLayer = tonumber(dataTab[4])
	self.maxGuardLayer = tonumber(dataTab[5])
	self.resetGuardTime = tonumber(dataTab[6])
	self.resetGuardNum = tonumber(dataTab[7])
	local specNum = tonumber(dataTab[8])
	local tmpCnt = 9
	for i=1, specNum do
		local specCopyID = tonumber(dataTab[tmpCnt])
		table.insert(self.guardSpecReward, specCopyID)
		tmpCnt = tmpCnt + 1
	end
	self.towerInnerTime = dataTab[tmpCnt] and tonumber(dataTab[tmpCnt]) or 0
	local tmp = dataTab[tmpCnt+1]
	if tmp then
		self.canTower = tonumber(tmp)==1 and true or false
	end
end

function CopyPlayer:getTowerData()
	str = ""
	str = str .. self.towerCopyProgress
	str = str .. "&" ..self.towerCopyResetTimeStamp
	str = str .. "&" ..self.towerCopyResetNum
	str = str .. "&" ..self.towerCopyActivePrize
	str = str .. "&" ..self.currentMultiCopyLevel
	local player = self:getRole()
	--print(">>>>>>>>%%%%%%%%% SaveTowerProgresstoDB:",self.towerCopyProgress,player:getSerialID())
	return str
end


function  CopyPlayer:onLoadTowerData( str )
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!onLoadTowerData loop!!!!>>>>"..str)
			break
		end
	end
	self.towerCopyProgress = toNumber(dataTab[1])
	local player = self:getRole()
	--print(">>>>>>>>%%%%%%%%% GetTowerProgressFromDB:",self.towerCopyProgress,player:getSerialID())
	local tmpCnt = 1
	self.towerCopyResetTimeStamp = toNumber(dataTab[tmpCnt+1])
	tmpCnt = tmpCnt + 1
	self.towerCopyResetNum = toNumber(dataTab[tmpCnt+1])
	tmpCnt = tmpCnt + 1
	self.towerCopyActivePrize = toNumber(dataTab[tmpCnt+1])
	tmpCnt = tmpCnt + 1
	self.currentMultiCopyLevel = toNumber(dataTab[tmpCnt+1])
	if self.currentMultiCopyLevel==0 then
		self.currentMultiCopyLevel = 1
	end
end

function CopyPlayer:getMultiGuardTimeStr()
	local str = tostring(table.size(self.multiGuardData))
	for k,v in pairs(self.multiGuardData) do
		str = str .. "&" .. k .."&" .. v.cnt .."&" .. v.t
	end
	return str
end

function CopyPlayer:readMultiGuardTimeStr(str)
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!readMultiGuardTimeStr loop!!!!>>>>"..str)
			break
		end
	end
	local cnt = tonumber(dataTab[1])
	if cnt>1000 then
		cnt = 1000
		print(">>>>>>>>readMultiGuardTimeStr cnt reach 1000>>>"..str.."["..cnt.."]")
	end
	local tmpCnt = 2
	local tmpTable = "{"
	for i=1, cnt do
		local copyid = toNumber(dataTab[tmpCnt])
		tmpCnt = tmpCnt+1
		local c = toNumber(dataTab[tmpCnt])
		tmpCnt = tmpCnt+1
		local t = toNumber(dataTab[tmpCnt])
		tmpCnt = tmpCnt+1
		self.multiGuardData[copyid] = {t=t,cnt=c}
		
	end
end


function CopyPlayer:getCopyTimeStr()
	local tmp = {}
	local nt = os.time()
	for k,v in pairs(self.lastEnterTimes) do
		if nt - v <= ONE_DAY_SEC then
			tmp[k] = v
		end
	end
	local str = tostring(table.size(tmp))
	for k,v in pairs(tmp) do
		str = str .. "&" .. k .. "&" .. v .. "&" .. self.copyCounts[k]
	end
	local towerVipTime = self.towerVipData and self.towerVipData[1] or 0
	local towerVipCnt = self.towerVipData and self.towerVipData[2] or 0
	str = str .. "&" .. towerVipTime .. "&" .. towerVipCnt
	str = str .. "&" ..self.resetGuardTimeStamp
	
	return str
end

--¼ÓÔØCDºÍÊ±¼ä»¹ÓÐVIPÊý¾Ý
function CopyPlayer:readCopyTimeStr(str)
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!readCopyTimeStr loop!!!!>>>>"..str)
			break
		end
	end
	local cnt = tonumber(dataTab[1])
	if cnt>1000 then
		cnt = 1000
		print(">>>>>>>>readCopyTimeStr cnt reach 1000>>>"..str.."["..cnt.."]")
	end
	local tmpCnt = 1
	for i=1, cnt do
		--self.lastEnterTimes[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+2])
		local oldtime = toNumber(dataTab[tmpCnt+2])
		local retime = oldtime
		local t=os.date("*t",oldtime)
		if oldtime > 0 and (t["hour"] ~= UPDATE_COPY_TIME) then
			t.hour = UPDATE_COPY_TIME
			t.min = 0
			t.sec = 0
			retime = os.time(t)
		end
		self.lastEnterTimes[toNumber(dataTab[tmpCnt+1])] = retime
		--self.lastEnterTimes[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+2])
		self.copyCounts[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+3])
		tmpCnt = tmpCnt + 3
	end
	self.towerVipData = {toNumber(dataTab[tmpCnt+1]), toNumber(dataTab[tmpCnt+2])}
	tmpCnt = tmpCnt + 2
	self.resetGuardTimeStamp = toNumber(dataTab[tmpCnt+1])
end

function CopyPlayer:getCopyFastStr()
	local str = tostring(table.size(self.successFlag))
	for k,v in pairs(self.successFlag) do
		str = str .. "&" .. k .. "&" .. v
	end
	return str
end



--¼ÓÔØ×î¿ì¼ÍÂ¼
function CopyPlayer:readCopyFastStr(str)
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!readCopyFastStr loop!!!!>>>>"..str)
			break
		end
	end
	local cnt = tonumber(dataTab[1])
	if cnt > 1000 then
		cnt = 1000
		print(">>>>>>>>readCopyFastStr cnt reach 1000>>>"..str.."["..cnt.."]")
	end
	local tmpCnt = 1
	for i=1, cnt do
		self.successFlag[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+2])
		tmpCnt = tmpCnt + 2
	end

	--Íê³ÉµÄµ¥ÈËºÍ¾çÇé¸±±¾ÊýÁ¿
	for id, _ in pairs(self.successFlag) do
		local proto = g_copyMgr:getProto(id)
		if proto then
			if proto:getCopyType() == CopyType.SingleCopy then
				self.doneSingleNum = self.doneSingleNum + 1
				if proto:getAutoProgress() then
					self.donePlotNum = self.donePlotNum + 1
				end
			elseif proto:getCopyType() == CopyType.NewSingleCopy then
				self.doneSingleNum = self.doneSingleNum + 1
				self.donePlotNum = self.donePlotNum + 1
			end
		end
	end
end

function CopyPlayer:getCopyStarStr()
	local str = tostring(table.size(self.successStar))
	for k,v in pairs(self.successStar) do
		str = str .. "&" .. k .. "&" .. v
	end
	return str
end

function CopyPlayer:readCopyStarStr(str)
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!readCopyStarStr loop!!!!>>>>"..str)
			break
		end
	end
	local cnt = tonumber(dataTab[1])
	if cnt > 1000 then
		cnt = 1000
		print(">>>>>>>>readCopyStarStr cnt reach 1000>>>"..str.."["..cnt.."]")
	end
	local tmpCnt = 1
	for i=1, cnt do
		self.successStar[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+2])
		tmpCnt = tmpCnt + 2
	end
end

function CopyPlayer:calPlayerCopyStarCount()
	local count = 0
	for k,v in pairs(self.successStar) do
		count = count + v
	end
	return count
end

function CopyPlayer:getCopyStarPrizeStr()
	local str = tostring(table.size(self.towerStarPrize))
	for k,v in pairs(self.towerStarPrize) do
		str = str .. "&" .. k .. "&" .. v
	end
	return str
end

function CopyPlayer:readCopyStarPrizeStr(str)
	local dataTab = {}
	local count = 0
	for w in string.gmatch(str, "[%&]-([^%&]+)") do
		table.insert(dataTab, w)
		count = count + 1
		if count>1000 then
			print(">>>>>>>>!!!!readCopyStarPrizeStr loop!!!!>>>>"..str)
			break
		end
	end
	local cnt = tonumber(dataTab[1])
	if cnt > 1000 then
		cnt = 1000
		print(">>>>>>>>readCopyStarPrizeStr cnt reach 1000>>>"..str.."["..cnt.."]")
	end
	local tmpCnt = 1
	for i=1, cnt do
		self.towerStarPrize[toNumber(dataTab[tmpCnt+1])] = toNumber(dataTab[tmpCnt+2])
		tmpCnt = tmpCnt + 2
	end
end


function CopyPlayer:getMaxGuardLayer()
	return self.maxGuardLayer
end

function CopyPlayer:setMaxGuardLayer(maxLayer)
	self.maxGuardLayer = maxLayer
	self.syncFlag = true
end

function CopyPlayer:getRole()
	return g_entityMgr:getPlayer(self.role)
end

function CopyPlayer:getSerialID()
	local player = self:getRole()
	if player then
		return player:getSerialID()
	end
	return 0
end

function CopyPlayer:setLastGuardLayer(layer)
	if self.lastGuardLayer ~= layer then
		self.lastGuardLayer = layer
		self.syncFlag = true
	end
end

function CopyPlayer:getFirstGuardID()
	local level = self:getRole():getLevel()

	if level <= 50 then
		return COPY_GUARD_STARTID_1
	end

	if level <= 60 then
		return COPY_GUARD_STARTID_2
	end

	if level <= 100 then
		return COPY_GUARD_STARTID_3
	end

	return 4000
end


function CopyPlayer:getLastGuardLayer()
	return self.lastGuardLayer
end

--ÊØ»¤¸±±¾ÉÏ´Î½øÈëÊ±¼ä
function CopyPlayer:getLastGuardTime()
	return self.lastGuardTime
end

function CopyPlayer:setLastGuardTime(t)
	if t - self.lastGuardTime < ONE_DAY_SEC then return end
	local nowTime = t
	local nowDate = os.date("*t",nowTime)
	local difTime = 0
	if nowDate.hour < UPDATE_COPY_TIME then
		difTime = -ONE_DAY_SEC
	end
	nowDate.hour = UPDATE_COPY_TIME
	nowDate.min = 0
	nowDate.sec = 0
	if self.lastGuardTime ~= os.time(nowDate) + difTime then
		self.lastGuardTime = os.time(nowDate) + difTime
		self.syncFlag = true
	end
end

function CopyPlayer:setTowerCnt(cnt, flag)
	local nowTime = os.time()
	--ÅÐ¶ÏÊÇ·ñÊÇÐÂCD
	if nowTime - self.lastTowerTime > ONE_DAY_SEC then
		if flag then 
			self.towerCnt = 0
		else
			self.towerCnt = 1
		end
		local nowDate = os.date("*t",nowTime)
		local difTime = 0
		if nowDate.hour < UPDATE_COPY_TIME then
			difTime = -ONE_DAY_SEC
		end
		nowDate.hour = UPDATE_COPY_TIME
		nowDate.min = 0
		nowDate.sec = 0
		self.lastTowerTime = os.time(nowDate) +difTime
	else
		local cdCnt = self.towerCnt or 0
		self.towerCnt = cdCnt + 1	
	end
	self.syncFlag = true
end

function CopyPlayer:subTowerCnt()
	if self.towerCnt > 0 then
		self.towerCnt = self.towerCnt - 1
	else
		self.towerCnt = 0
	end
end

function CopyPlayer:getTowerCnt()
	return self.towerCnt
end

--»ñÈ¡¸±±¾ÒÑÍê³É´ÎÊý
function CopyPlayer:getEnterCopyCount(copyID)
	return self.copyCounts[copyID] or 0
end

--»ñÈ¡µ¥ÈËÒÔ¼°ÅÀËþ¸±±¾ÉÏ´Î½øÈëÊ±¼ä
function CopyPlayer:getLastEnterTime(copyID)
	return self.lastEnterTimes[copyID] or 0
end

--»ñµÃÆÀ¼¶Ê±¼ä
function CopyPlayer:getRatingTime(copyID)
	return self.successFlag[copyID] or 0
end

--»ñµÃËùÓÐÆÀ¼¶Ê±¼ä
function CopyPlayer:getAllRatingTime()
	return self.successFlag or {}
end

function CopyPlayer:setRatingTime(copyID, expendTime, oldTime)
	self.successFlag[copyID] = expendTime
	self.updateCopyFast = true
	local proto = g_copyMgr:getProto(copyID)
	if oldTime == 0 and proto then
		if proto:getCopyType() == CopyType.SingleCopy then
			self.doneSingleNum = self.doneSingleNum + 1
			if proto:getAutoProgress() then
				--¾çÇé¸±±¾³É¾Í
				self.donePlotNum = self.donePlotNum + 1
				--ÍÀÁú´«Ëµ
			end
		elseif proto:getCopyType() == CopyType.NewSingleCopy then
			self.doneSingleNum = self.doneSingleNum + 1
			self.donePlotNum = self.donePlotNum + 1
		end
	end
	self.syncFlag = true
end

function CopyPlayer:getRatingStar(copyID)
	return self.successStar[copyID] or 0
end

function CopyPlayer:setRatingStar(copyID,newStar)
	self.successStar[copyID] = newStar
	self.updateCopyStar = true	
	self.syncFlag = true
	local finishedCount = 0
	local allTowerProto = g_copyMgr:getTowerProtos()
	for copyID, proto in pairs(allTowerProto) do
		local star = self:getRatingStar(copyID)
		if star > 0 then
			finishedCount=finishedCount+1
		end
	end
end

function CopyPlayer:getCopyStarPrize(starNum)
	return self.towerStarPrize[starNum] or 0
end

function CopyPlayer:setCopyStarPrize(starNum)
	self.towerStarPrize[starNum] = 1
	self.updateCopyStar = true	
	self.syncFlag = true
end

function CopyPlayer:getDonePlotNum()
	return self.donePlotNum
end

function CopyPlayer:getDoneSingleNum()
	return self.doneSingleNum
end


function CopyPlayer:getMaxTowerLayer()
	return self.maxTowerLayer
end

function CopyPlayer:setMaxTowerLayer(layer)
	if self.maxTowerLayer ~= layer then
		self.maxTowerLayer = layer
		self.syncFlag = true
	end
end

function CopyPlayer:getResetGuardTimeStamp()
	return self.resetGuardTimeStamp
end

function CopyPlayer:setResetGuardTimeStamp(stamp)
	self.resetGuardTimeStamp = stamp
	self:setUpdateCopyCnt(true)
end

--½øÈë¸±±¾
function CopyPlayer:enterCopy(copyInstId, copyID, enterPos)
	print("enter copy")
	local player = self:getRole()
	if player then
		local proto = g_copyMgr:getProto(copyID)
		player:setCopyID(copyInstId)
		local preMapID = player:getMapID()
		local publicPos = player:getPosition()
		print("ready to enter copy scene",player:getSerialID())
		if g_sceneMgr:enterCopyBookScene(copyInstId, player:getID(), proto:getMapID(), enterPos[1], enterPos[2]) then
			print("do enter copy scene",player:getSerialID())
			--Íæ¼Ò³É¹¦½øÈë¸±±¾µØÍ¼
			self._curCopyInstID = copyInstId
			self._curCopyID = copyID
			player:setLastMapID(preMapID)
			player:setLastPosX(publicPos.x)
			player:setLastPosY(publicPos.y)
			self.preHP = player:getHP()
			player:setHP(player:getMaxHP())
			self.lastDeadTime = 0 --¶àÈË¸±±¾ÉÏ´ÎËÀÍöµÄÊ±¼ä
			self.totalDeadTimes = 0 --¶àÈË¸±±¾×Ü¹²ËÀÍö´ÎÊý
			return true
		else
			player:setCopyID(0)
			return false
		end
	else
		return false
	end
end

function CopyPlayer:exitCopy()
	local player = self:getRole()
	if player then
		g_entityMgr:destoryEntity(player:getPetID())
		self._curCopyID = 0
		self._curCopyInstID = 0
		player:setCopyID(0)
		self:setCopyTeamID(0)
		player:setHP(self.preHP)	--»Ö¸´ÑªÁ¿
		local lastPosX = player:getLastPosX()
		local lastPosY = player:getLastPosY()
		local pScene = g_sceneMgr:getPublicScene(player:getLastMapID())
		if not pScene then
			lastPosX = 21
			lastPosY = 100
			pScene = g_sceneMgr:getPublicScene(1100)
			print("********exit copy not find map***********",lastPosX,lastPosY,player:getLastMapID())	
		end
		print("CopyPlayer:exitCopy")
		g_sceneMgr:enterPublicScene(player:getID(), self:getRole():getLastMapID(), lastPosX, lastPosY)
		return true
	else
		return false
	end
end


--ÖØÖÃµ¥ÈËÒÔ¼°ÅÀËþ¸±±¾CD¼ÆÊý
function CopyPlayer:clearEnterCDCount(copyID)
	if self.copyCounts[copyID] and self.copyCounts[copyID] ~= 0 then
		self.copyCounts[copyID] = nil
		self.lastEnterTimes[copyID] = 0 --getNormalUpdateTime(self.lastEnterTimes[copyID] or 0)
		self.updateCopyCnt = true
	end
end

--ÖØÖÃÅÀËþCD
function CopyPlayer:clearTowerCDCount()
	if self.towerCnt ~= 0 then
		self.towerCnt = 0
		self.syncFlag = true
	end
end

--Ôö¼ÓCD´ÎÊý
function CopyPlayer:addEnterCopyCount(mainID)
	local nowTime = os.time()
	--ÅÐ¶ÏÊÇ·ñÊÇÐÂCD
	if nowTime - (self.lastEnterTimes[mainID] or 0) > ONE_DAY_SEC then
		self.copyCounts[mainID] = 1
		self.lastEnterTimes[mainID]  = getNormalUpdateTime(self.lastEnterTimes[copyID] or 0)
	else
		local cdCnt = self.copyCounts[mainID] or 0
		self.copyCounts[mainID] = cdCnt + 1	
	end
	self.updateCopyCnt = true
end

--»ñÈ¡µ±Ç°¸±±¾ÊµÀýID
function CopyPlayer:getCurCopyInstID()
	return self._curCopyInstID
end

function CopyPlayer:getCurrentCopyID()
	return self._curCopyID
end

function CopyPlayer:setCurrentCopyID(id)
	self._curCopyID = id
end

function CopyPlayer:getLastDeadTime()
	return self.lastDeadTime
end

function CopyPlayer:setLastDeadTime(time)
	self.lastDeadTime = time
end

function CopyPlayer:getTotalDeadTimes()
	return self.totalDeadTimes
end

function CopyPlayer:setTotalDeadTimes(times)
	self.totalDeadTimes = times
end

function CopyPlayer:GMClear()
	self.copyCounts = {}
	self.lastEnterTimes = {}
	self.towerCnt = 0
	self.resetGuardTime = 0	
	self.resetGuardNum = 0	
	self.inviteFriData = {}	
	--self.maxTowerLayer = 0
	self.lastTowerTime = 0
	self.multiGuardData = {}
end

function CopyPlayer:setSyncFlag(flag)
	self.syncFlag = flag
end

function CopyPlayer:getSyncFlag()
	return self.syncFlag
end

function CopyPlayer:getSyncProFlag()
	return self.syncProFlag
end

function CopyPlayer:setSyncProFlag(flag)
	self.syncProFlag = flag
end

function CopyPlayer:GMClearGuard()
	self.resetGuardTime = 0	
	self.resetGuardNum = 0	
end

function CopyPlayer:getTowerCopyProgress()
	return self.towerCopyProgress
end

function CopyPlayer:setTowerCopyProgress(progress)
	self.towerCopyProgress = progress
end

function CopyPlayer:getTowerCopyResetTimeStamp()
	return self.towerCopyResetTimeStamp
end

function CopyPlayer:setTowerCopyResetTimeStamp(time)
	self.towerCopyResetTimeStamp = time
end

function CopyPlayer:getTowerCopyResetNum()
	return self.towerCopyResetNum
end

function CopyPlayer:setTowerCopyResetNum(num)
	self.towerCopyResetNum = num
end

function CopyPlayer:getTowerCopyActivePrize()
	return self.towerCopyActivePrize
end

function CopyPlayer:setTowerCopyActivePrize(num)
	self.towerCopyActivePrize = num
end

function CopyPlayer:checkResetTower()
	local towerStamp = self:getTowerCopyResetTimeStamp()
	local timeStamp = time.toedition("day")
	if towerStamp ~= timeStamp then
		self:setTowerCopyResetTimeStamp(timeStamp)
		self:setTowerCopyResetNum(0)
		self:setTowerCopyActivePrize(0)
	end
end

function CopyPlayer:getNowProgressCopyId()
	return self.nowProgressTowerCopy
end

function CopyPlayer:setNowProgressCopyId(copyId,startTime,duraTime)
	self.nowProgressTowerCopy.copyId = copyId
	self.nowProgressTowerCopy.startTime = startTime
	self.nowProgressTowerCopy.duraTime = duraTime
end


function CopyPlayer:getCurrentMultiCopyLevel()
	return self.currentMultiCopyLevel
end

function CopyPlayer:setCurrentMultiCopyLevel(level)
	self.currentMultiCopyLevel = level
end

function CopyPlayer:getSingleInstsFlag()
	return self.singleInstsFlag
end

function CopyPlayer:setSingleInstsFlag(flag)
	self.singleInstsFlag = flag
end

function CopyPlayer:isPassedSingleInst(instID)
	return self.passedSingleInsts[instID]
end

function CopyPlayer:isDailySingleInst(instID)
	return self.dailySingleInstID == instID and not self.dailySingleInstPassed
end

function CopyPlayer:onFinishSingleInst(instID, byTask)
	print(self:getSerialID(), " onFinishSingleInst:", instID, byTask)
	if self:isDailySingleInst(instID) then
		self:onFinishDailyInst()
	elseif not self:isPassedSingleInst(instID) then
		self:onFirstFinishInst(instID)
	else
		print(self:getSerialID().." fisish passed SingleInst:"..instID)
	end

	local instProto = g_copyMgr:getSingleInstProto(instID)
	if instProto then
		g_taskMgr:NotifyListener(self:getRole(), "onEnterPreBookSuc", instProto:getData().copyID)
		if not byTask then
			print(self:getSerialID(), " activeness TULONG")
			g_normalMgr:activeness(self.role, ACTIVENESS_TYPE.TULONG)
		end
	end

	local ret = {new_inst = instID,}
	fireProtoMessage(self.role, COPY_SC_SINGLEINST_INCDATA, 'SingleInstIncDataProtocol', ret)
end

function CopyPlayer:onFinishDailyInst()
	local instProto = g_copyMgr:getSingleInstProto(self.dailySingleInstID)
	if not instProto then
		print(self:getSerialID(), " finish nonexistent dailyInst:", self.dailySingleInstID)
		return
	end
	print(self:getSerialID().." finish dailyInst:", self.dailySingleInstID)
	self.passedSingleInsts[self.dailySingleInstID] = os.time()
	self.dailySingleInstPassed = true
	self:setSingleInstsFlag(true)
	self:onFinishAward(instProto:getData().dailyReward)
	g_ActivityMgr:sevenFestivalChange(self.role, ACTIVITY_ACT.TULONG, 1)
end
function CopyPlayer:onFirstFinishInst(instID)
	local instProto = g_copyMgr:getSingleInstProto(instID)
	if not instProto then
		print(self:getSerialID(), " first finish nonexistent singleInst:",instID)
		return
	end
	print(self:getSerialID()," finish singleInst:", instID, " for the 1st time!")
	if instProto:getData().unlock ~= 0 then
		print("unlock singleInst:", instProto:getData().unlock)
		self.passedSingleInsts[instProto:getData().unlock] = 0
	end
	self.passedSingleInsts[instID] = 0
	self:setSingleInstsFlag(true)
	self:onFinishAward(instProto:getData().passReward)
end

function CopyPlayer:onFinishAward(reward)
	local ret, data = rewardByDropID(self:getRole():getSerialID(), reward, 11, 53)
	print(self:getSerialID()," onFinishAward:", reward, "ret:",ret, "data:", data)
end

function CopyPlayer:getSingleInstsStr()
	print("====getSingleInstsStr for ", self:getSerialID())
	local data = {}
	data.dailyInstID = self.dailySingleInstID
	data.dailyInstPassed = self.dailySingleInstPassed
	data.dailyInstTime = self.dailySingleInstTime
	data.passedInsts = {}
	local debug_str = "passed insts  "
	for k,v in pairs(self.passedSingleInsts) do
		local inst = {instID = k, randomTime = v,}
		table.insert(data.passedInsts, inst)
		debug_str = debug_str .. k .. ':' .. v, ' '
	end
	print(debug_str)
	return protobuf.encode("SingleInstsDataProtocol", data)
end
function CopyPlayer:loadSingleInstsData(buff)
	print("====loadSingleInstsData for ", self:getSerialID())
	if #buff > 0 then
		local data,err = protobuf.decode("SingleInstsDataProtocol", buff)
		if data == false then
			print(self:getSerialID()," loading singleInst data error:",  err)
			return
		end
		self.dailySingleInstID = data.dailyInstID
		self.dailySingleInstPassed = data.dailyInstPassed
		self.dailySingleInstTime = data.dailyInstTime
		for _,v in pairs(data.passedInsts) do
			self.passedSingleInsts[v.instID] = v.randomTime
		end
	end

	local curTime = os.time()
	if diffDay(curTime, self.dailySingleInstTime) then
		self:resetDailyInst()
	end
end

function CopyPlayer:resetDailyInst()
	print("Diffday! Reset daily singleInst for ", self:getSerialID())
	if self.dailySingleInstID > 0 then
		self.passedSingleInsts[self.dailySingleInstID] = 0
	end
	self.dailySingleInstID = 0
	self.dailySingleInstPassed = false	
end

function CopyPlayer:sendSingleInstData()
	--print("====sendSingleInstData for ", self:getRole():getSerialID())
	local ret = {passed_insts = {},}
	for k,_ in pairs(self.passedSingleInsts) do
		table.insert(ret.passed_insts, k)
	end
	ret.daily_inst = self.dailySingleInstID
	ret.daily_passed = self.dailySingleInstPassed
	fireProtoMessage(self.role, COPY_SC_SINGLEINSTANCE_DATA, 'SingleInstanceDataRetProtocol', ret)
end

function CopyPlayer:canOpenDailySingleInst()
	--special case:if instances including (15,24,10,20) were passed, return true
	return self:isPassedSingleInst(10) and self:isPassedSingleInst(15) and self:isPassedSingleInst(20) and self:isPassedSingleInst(24)
end

function CopyPlayer:randomDailySingleInst()
	if not self:canOpenDailySingleInst() then
		return self:sendErrToClient(COPY_ERR_SINGLEINST_DAILY_UNQUALIFIED)
	end
	if self.dailySingleInstPassed then
		return self:sendErrToClient(COPY_ERR_SINGLEINST_DAILY_PASSED)
	end

	if self.dailySingleInstID == 0 then
		return self:randomDailySingleInstImpl()
	end
	local curTime = os.time()
	if diffDay(curTime, self.dailySingleInstTime) then
		return self:randomDailySingleInstImpl()
	end

	return self:sendErrToClient(COPY_ERR_SINGLEINST_DAILY_EXISTS)
end

function CopyPlayer:randomDailySingleInstImpl()
	print("====randomDailySingleInstImpl for ", self:getSerialID())
	local rollList = {}
	local classList = {}
	local curTime = os.time()
	local count = 0
	for k,v in pairs(self.passedSingleInsts) do
		local instProto = g_copyMgr:getSingleInstProto(k)
		if instProto and instProto:getData().inDaily then
			local class = instProto:getData().class
			local oldData = rollList[class]
			if not oldData or oldData:getData().index < instProto:getData().index then
				if curTime - v >= instProto:getData().randomLimitDay * ONE_DAY_SEC then
					rollList[class] = instProto
					classList[#classList+1] = class
				end
			end
		end
	end

	local rollClass = classList[math.random(1, #classList)]
	local rollInst = rollList[rollClass]
	if rollInst then
		local realInstID = rollInst:getData().dailyInstID > 0 and rollInst:getData().dailyInstID or rollInst:getData().id
		self.passedSingleInsts[rollInst:getData().id] = curTime
		self.dailySingleInstID = realInstID
		self.dailySingleInstPassed = false
		self.dailySingleInstTime = curTime
		self:setSingleInstsFlag(true)
		local ret = {new_daily = realInstID,}
		print(self:getSerialID(), " get new random daily singleInst:", realInstID)
		return fireProtoMessage(self.role, COPY_SC_SINGLEINST_INCDATA, 'SingleInstIncDataProtocol', ret)
	end
	self:sendErrToClient(COPY_ERR_SINGLEINST_DAILY_UNAVAILABLE)
end

function CopyPlayer:reqFinishSingleInst(instID)
	local curCopyID = self:getCurrentCopyID()
	local curInstID = g_copyMgr:getSingleInstIDByCopyID(curCopyID)
	if instID ~= curInstID then
		print(self:getSerialID(), "reqFinishSingleInst, instID:", instID, "curInstID:", curInstID)
		return self:sendErrToClient(COPY_ERR_SINGLEINST_INVALID_INST)
	end

	if curCopyID == 6007 or curCopyID == 6008 then
		self._curCopyID = 0
	end

	local instProto = g_copyMgr:getSingleInstProto(curInstID)
	if not instProto then
		return self:sendErrToClient(COPY_ERR_SINGLEINST_INVALID_INST)
	end

	if instProto:getData().simulate ~= 1 then
		return self:sendErrToClient(COPY_ERR_SINGLEINST_INVALID_INST)
	end

	local taskID = instProto:getData().mainTaskID
	if taskID > 0 then	--related to main task
		local status = g_taskMgr:getMainTaskState(self:getRole():getID(), taskID)
		print("maintask:", taskID, " status:", status)
		if status == TaskStatus.Active then
			return self:onFinishSingleInst(instID, true)
		end
	end
	self:onFinishSingleInst(instID)
end

function CopyPlayer:canEnterSingleInst(player, instID, checkTask)
	local instProto = g_copyMgr:getSingleInstProto(instID)
	if not instProto then
		return false, COPY_ERR_SINGLEINST_INVALID_INST
	end
	if self.passedSingleInsts[instID] then
		return true, instProto
	end

	for _,v in pairs(instProto:getData().prevInsts) do
		if not self.passedSingleInsts[v] then
			return false, COPY_ERR_SINGLEINST_LACK_PREV_INST
		end
	end

	if checkTask then
		local taskID = instProto:getData().mainTaskID
		if taskID > 0 then	--related to main task
			local status = g_taskMgr:getMainTaskState(player:getID(), taskID)
			print("maintask:", taskID, " status:", status)
			if status == TaskStatus.Finished or status == TaskStatus.Done or status == TaskStatus.Active then
				return true, instProto
			else
				local taskProto = g_LuaTaskDAO:getPrototype(taskID)
				local name = taskProto.q_name and taskProto.q_name or "null"
				return false, COPY_ERR_SINGLEINST_NEED_MAINTASK, {name}
			end
		end
	end

	if player:getLevel() < instProto:getData().level then
		return false, COPY_ERR_SINGLEINST_LEVEL_TOOLOW, {instProto:getData().level}
	end
	
	return true, instProto
end

function CopyPlayer:sendErrToClient(errCode, params)
	print(self:getSerialID(), " sendErrToClient: ", errCode)
	if params and type(params) == "table" then
		g_copySystem:fireMessage(0, self.role, EVENT_COPY_SETS, errCode, #params, params)
	else
		g_copySystem:fireMessage(0, self.role, EVENT_COPY_SETS, errCode, 0)
	end
end

function CopyPlayer:removePassedSingleInst(instID)
	self.passedSingleInsts[instID] = nil
	self:setSingleInstsFlag(true)
end

function CopyPlayer:printSingleInstData()
	print("==================printSingleInstData==================")
	print("passed insts:")
	for k,v in pairs(self.passedSingleInsts) do
		print(k,v)
	end
	print("save flag:",self.singleInstsFlag)
	print("dailyID:", self.dailySingleInstID, "passed:", self.dailySingleInstPassed, "dailyTime:", self.dailySingleInstTime)
	print("=======================================================")
end

function CopyPlayer:passAllSingleInsts()
	for k,v in pairs(g_copyMgr._singleInstsPrototypes) do
		self:onFinishSingleInst(v:getData().id)
	end
end