--FactionAreaFire.lua
--/*-----------------------------------------------------------------
--* Module:  FactionAreaFire.lua
--* Author:  Li Yuanhao
--* Modified: 2016年3月23日
--* Purpose: Implementation of the class FactionAreaFire
-------------------------------------------------------------------*/
FactionAreaFire = class(nil)

local prop = Property(FactionAreaFire)
prop:accessor("starTime", 0)		--开始时间
---------------------------------------
function FactionAreaFire:__init(factionID,starTime)
	prop(self, "starTime", starTime)
	self._upEXP 			= g_factionAreaManager._fireData.upEXP
	self._upEXPPer 			= g_factionAreaManager._fireData.upEXPPer
	self._factionID 		= factionID
	self._AddEXP 			= self._upEXP
	self._sumWoodCount		= 0
	self._time 				= FACTION_FIRE_DURATION + FACTION_FIRE_NOTIFY_TIME
	self._count 			= 0
	self._startTime 		= os.time() 		-- 开启时间记录
	self._state   			= FationFireState.prepareStart			-- 篝火状态
	self._updateExpTime 	= 0 			-- 更新经验时间
	self._updateStateTime 	= 0				-- 客户端状态时间

	self._tlogData = {		-- tlog数据
		players = {},	-- 篝火参与人数 
		totalExp = 0,		-- 全部经验
		invadeFaction = {},		-- 入侵行会数据
		}			
end

function FactionAreaFire:addBuffByFire(player)
	if player and self._state == FationFireState.start then 
		local buffmgr = player:getBuffMgr()
		buffmgr:addBuff(FACTION_FIRE_EXP,0)

		g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.GOU_HUO)

		self._tlogData.players[player:getSerialID()] = true
	end
end

function FactionAreaFire:delBuffByFire(player)
	-- body
	if player then 
		local buffmgr = player:getBuffMgr()
		buffmgr:delBuff(FACTION_FIRE_EXP)
	end
end

-- 获得篝火状态
function FactionAreaFire:getFireState()
	return self._state
end

-- 更新篝火状态
function FactionAreaFire:updateFire()
	local faction = g_factionMgr:getFaction(self._factionID)
	if not faction then
		return
	end
	
	local now = os.time()
	if self._state ~= FationFireState.start and now - self._startTime >= FACTION_FIRE_NOTIFY_TIME then
		self:openFire()
	elseif self._state == FationFireState.start and now - self._startTime < self._time 
	and now - self._updateExpTime >= FACTION_FIRE_SPACE_TIME then
		self._updateExpTime = now
		self:freshExp()
	elseif self._state ~= FationFireState.fireEnd and now - self._startTime >= self._time then
		self:closeFire()
	end

	if (self._state == FationFireState.prepareStart or self._state == FationFireState.start) and now - self._updateStateTime > 10 then
		self._updateStateTime = now
		g_factionAreaManager:sendAllMemberStatus(self._factionID)
	end
end

-- 预备开启
function FactionAreaFire:prepareOpenFire()
	local faction = g_factionMgr:getFaction(self._factionID)
	if not faction then
		return
	end

	local allMems = faction:getAllMembers()
	for roleSID, mem in pairs(allMems) do
		local mPlayer = g_entityMgr:getPlayerBySID(roleSID)
		if mPlayer then
			g_factionAreaServlet:sendErrMsg2Client(mPlayer:getID(), FACTIONAREA_FIRE_OPNE, 0,{})
		end
	end

	g_factionMgr:notifyAllMemByEmail(self._factionID, FactionHD.GOU_HUO)
end

-- 正式开启
function FactionAreaFire:openFire()
	local faction = g_factionMgr:getFaction(self._factionID)
	if not faction then
		return
	end

	self._state = FationFireState.start
	local curScenePlayer = g_factionAreaManager:getCurrentMapPlayer(self._factionID)
	for i = 1 ,#curScenePlayer do
		local roleID = curScenePlayer[i]
		local player = g_entityMgr:getPlayer(roleID)
		self:addBuffByFire(player)
	end
	g_factionAreaManager:sendAllMemberStatus(self._factionID)
	g_normalLimitMgr:sendErrMsg2Client(102,1,{faction:getName()})
end

function FactionAreaFire:closeFire()
	local faction = g_factionMgr:getFaction(self._factionID)
	if not faction then
		return
	end

	self._state = FationFireState.fireEnd

	local allMems = faction:getAllMembers()
	for roleSID, mem in pairs(allMems) do
		local mPlayer = g_entityMgr:getPlayerBySID(roleSID)
		if mPlayer then
			g_factionAreaServlet:sendErrMsg2Client(mPlayer:getID(), FACTIONAREA_FIRE_CLOSE, 0)
		end
	end
	local curScenePlayer = g_factionAreaManager:getCurrentMapPlayer(self._factionID)
	for i=1, #curScenePlayer do
		local roleID = curScenePlayer[i]
		local player = g_entityMgr:getPlayer(roleID)
		self:delBuffByFire(player)
	end
	self._AddEXP = self._upEXP

	g_factionAreaManager:sendAllMemberStatus(self._factionID)


	if table.size(self._tlogData.invadeFaction) == 0 then
		g_tlogMgr:TlogFactionGHFlow(self._factionID, faction:getName(), faction:getLevel(), table.size(self._tlogData.players), self._sumWoodCount, 0, "", 0, 0, self._tlogData.totalExp)
	else
		for factionID, factionData in pairs(self._tlogData.invadeFaction) do
			local invadeFaction = g_factionMgr:getFaction(factionID)
			if invadeFaction then
				g_tlogMgr:TlogFactionGHFlow(self._factionID, faction:getName(), faction:getLevel(), table.size(self._tlogData.players), 
					self._sumWoodCount, factionID, invadeFaction:getName(), invadeFaction:getLevel(), table.size(factionData.players), self._tlogData.totalExp)
			end
		end
	end
end

function FactionAreaFire:freshExp()
	if self._count == 0 then 
		
		self._count = 1
	end

	local curScenePlayer = g_factionAreaManager:getCurrentMapPlayer(self._factionID)
	for i = 1, #curScenePlayer  do
		local roleID = curScenePlayer[i]
		local player = g_entityMgr:getPlayer(roleID)
		if player and player:getFactionID() == self._factionID then 
			local curXP = player:getXP()
			--Tlog[PlayerExpFlow]
			addExpToPlayer(player,self._AddEXP,206)
			local retData = {}
			retData.type = 0
			retData.value = self._AddEXP
			fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', retData)

			self._tlogData.totalExp = self._tlogData.totalExp + self._AddEXP
		end
	end
end

function FactionAreaFire:addWood(player)
	if not player then 
		return
	end
 
	local faction = g_factionMgr:getFaction(self._factionID)
	if not faction then
		return
	end
	
	local mem = faction:getMember(player:getSerialID())
	if not mem then
		return
	end
	if player:hasEffectState(EXIT_FACTION_SPECIAL) then
		return false, FACERR_HAS_EXIT_BUFF
	end
	if mem:getContribution() < FACTION_FIRE_WOOD_CONTRIBUTION  then 
		g_factionAreaServlet:sendErrMsg2Client(player:getID(),FACTIONAREA_CONTRIBUTE_NOT_ENOUGTH,0,{})
		return
	end
	local count = mem:getFireNum()
	if count > 0 then 
		mem:setContribution(mem:getContribution() - FACTION_FIRE_WOOD_CONTRIBUTION)
		self._AddEXP = self._AddEXP + self._upEXPPer
		mem:setFireNum(count - 1)
		self._sumWoodCount = self._sumWoodCount + 1
		g_factionAreaServlet:sendErrMsg2Client(player:getID(),FACTIONAREA_ADD_SUCCESS,0,{})
		g_factionAreaManager:sendAllMemberStatus(self._factionID)

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.factionFire, 1)
	end
end

-- 获得预备开启剩余时间
function FactionAreaFire:getPrepareStartLeftTime()
	local now = os.time()
	local leftTime = FACTION_FIRE_NOTIFY_TIME - (now - self._startTime)
	if leftTime < 0 then
		leftTime = 0
	end

	return leftTime
end

-- 获得篝火剩余时间
function FactionAreaFire:getLeftTime()
	local now = os.time()
	local leftTime = self._time - (now - self._startTime)
	if leftTime < 0 then
		leftTime = 0
	end

	return leftTime
end

-- 入侵
function FactionAreaFire:invadeFactionEnter(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local invadeFactionID = player:getFactionID()
	local invadeFaction = g_factionMgr:getFaction(invadeFactionID)
	if not invadeFaction then
		return
	end

	if not self._tlogData.invadeFaction[invadeFactionID] then
		self._tlogData.invadeFaction[invadeFactionID] = {players = {}}
	end

	self._tlogData.invadeFaction[invadeFactionID].players[player:getSerialID()] = true
end
