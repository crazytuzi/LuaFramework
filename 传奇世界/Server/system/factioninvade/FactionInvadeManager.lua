--FactionInvadeManager.lua
--/*-----------------------------------------------------------------
--* Module:  FactionInvadeManager.lua
--* Author:  Chu Zhihua
--* Modified: 2016年5月20日
--* Purpose: Implementation of the class FactionInvadeManager
-------------------------------------------------------------------*/

require ("system.factioninvade.FactionInvadeServlet")
require ("system.factioninvade.FactionInvadeConstant")

--行会入侵数据
FactionInvadeInfo = class()

local prop = Property(FactionInvadeInfo)
	prop:accessor("FactionID", 0)
	prop:accessor("BuffID", 0)

function FactionInvadeInfo:__init()
end

FactionInvadeManager = class(nil, Singleton, Timer)

function FactionInvadeManager:__init()
	self._factionInvadeInfos = {}	--静态ID
	self._factionInvadeRoles = {}	--行会中入侵玩家SID
	self._factionInvadeRecords = {}	--行会入侵记录
	g_listHandler:addListener(self)
end

--获能入侵的行会数据
function FactionInvadeManager:getInvadedFaction(rolesSID)
	print('FactionInvadeManager:getInvadedFaction')

	local player = g_entityMgr:getPlayerBySID(rolesSID)
	if not player then
		warning('not find player')
		return
	end

	--获取所有行会
	local allFactions = g_factionMgr:getAllFactions()
	if not allFactions then
		print('no faction ')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_NO_INVADE_FACTION, 0)
		return
	end

	local allFactionFires = g_factionAreaManager:getAllFactionAreaInfo()
	if  not allFactionFires  then
		print(' no faction open fire')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_NO_INVADE_FACTION, 0)
		return
	end

	print('get factions')
	--发送入侵行会数据
	local ret = {}
	ret.facInfos = {}
	for _, faction in pairs(allFactions) do
		local factionFireInfo = allFactionFires[faction:getFactionID()]
		if g_factionAreaManager:getFireState(faction:getFactionID()) == 3 then
			if faction:getFactionID() ~= player:getFactionID() then
				local tmpInfo = {}
				tmpInfo.facID = faction:getFactionID()
				tmpInfo.facName = faction:getName()
				tmpInfo.facLeaderName = faction:getLeaderName()
				tmpInfo.facLevel = faction:getLevel()
				tmpInfo.facBattle = faction:getTotalAbility()
				print('facID:'..tmpInfo.facID..' facName:'..tmpInfo.facName)
				table.insert(ret.facInfos, tmpInfo)
			end
		end
	end
	fireProtoMessage(player:getID(), FACTION_INVADE_SC_FACTION, 'FactionInvadeGetFactionRet', ret)
end

--进入行会驻地
function  FactionInvadeManager:enterFactionArea(rolesSID, factionID)
	print('FactionInvadeManager:enterFactionArea->:'..factionID)
	local player = g_entityMgr:getPlayerBySID(rolesSID)
	if not player then
		warning('not find player')
		return
	end

	--判断距离
	if not  isNearPos(player, 2100, 125, 125) then
		return
	end

	local myFacID = player:getFactionID()
	if myFacID <= 0 then
		print('player not join faction')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_NO_JOIN_FACTION, 0)
		return
	end

	if myFacID == factionID then
		print('factionID == player:getFactionID')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_SAME_FACTION, 0)
		return
	end

	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		print('not find faction')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_NO_FACTION, 0)
		return
	end

	local  myFaction = g_factionMgr:getFaction(myFacID)
	if not myFaction then
		print('not find myFaction data')
		return
	end

	--行会篝火是否已经开启了
	local allFactionFires = g_factionAreaManager:getAllFactionAreaInfo()
	if not allFactionFires[factionID] then
		print('faction not open factionFire')
		g_factionInvadeServlet:sendErrMsg2Client(player:getID(), FACTION_INVADE_FIRE_CLOSE, 0)
		return
	end

	--进入行会驻地
	local retEnter = g_factionMgr:enterFactionArea(rolesSID, 31, 42, factionID)
	if retEnter then
		local info = FactionInvadeInfo()
		info:setFactionID(factionID)
		--加buffer
		local lvl = myFaction:getLevel() - faction:getLevel()
		if lvl > 0 then
			print('myfaction level >= join faction level')
			local buffMgr = player:getBuffMgr()
			if not buffMgr then
				warning('get player buffMgr failed')
				return
			end
			local eCode = 0
			buffMgr:addBuff(FACTION_INVADE_WEAK_BUFF[lvl], eCode)
			print('addBuff: '..FACTION_INVADE_WEAK_BUFF[lvl])
			info:setBuffID(FACTION_INVADE_WEAK_BUFF[lvl])
		else
			print('myFaction lvl <= invadeFaction')
			info:setBuffID(nil)
		end
		self._factionInvadeInfos[rolesSID] = info
		if not self._factionInvadeRoles[factionID] then
			self._factionInvadeRoles[factionID] = {}
		end
		table.insert(self._factionInvadeRoles[factionID], rolesSID)
		--广播通知
		local myFacName = myFaction:getName()
		local allMems = faction:getAllMembers()
		for k,v in pairs(allMems) do
			--print('send to rolesid = ', v:getRoleSID(), myFacName)
			g_factionInvadeServlet:sendErrMsg2Client2(v:getRoleSID(), FACTION_INVADE_BROADCAST_MSG, 1, {myFacName})
		end

		g_factionAreaManager:invadeFactionEnter(rolesSID, factionID)

		local invadeInfo = self._factionInvadeRecords[myFacID]
		local needRecord = false
		if not invadeInfo then
			local tmp = {}
			table.insert(tmp, factionID)
			self._factionInvadeRecords[myFacID] = tmp
			needRecord = true
		else
			if not table.contains(self._factionInvadeRecords[myFacID], factionID) then
				table.insert(self._factionInvadeRecords[myFacID], factionID)
				needRecord = true
			end
		end

		if needRecord then
			--记录
			--print('needrecord!!!->',myFacID, factionID)
			g_factionMgr:addNewBigEvent(FACTION_EVENT_INVADE, {myFacName, faction:getName()})
		end
	end
end

--退出
function FactionInvadeManager:outFactionArea(rolesSID, factionID)
	print('FactionInvadeManager:outFactionArea')
	local player = g_entityMgr:getPlayerBySID(rolesSID)
	if not player then
		warning('not find player')
		return
	end

	local info = self._factionInvadeInfos[rolesSID]
	if not info then
		warning('not find factioninvade info')
		return
	end

	if info:getFactionID() ~= factionID then
		print('factionID is err')
		return
	end

	local BuffID = info:getBuffID()
	if BuffID then
		local buffMgr = player:getBuffMgr()
		if not buffMgr then
			warning('get player buffMgr failed')
			return
		end
		local eCode = 0
		buffMgr:delBuff(BuffID)
		print('clear buff: '..BuffID)
	end
	self._factionInvadeInfos[rolesSID] = nil
	if self._factionInvadeRoles then
		for k,v in pairs(self._factionInvadeRoles[factionID]) do
			if v == rolesSID then
				self._factionInvadeRoles[factionID][v] = nil
				break
			end
		end
	end

	player:setPattern(ePattern_Normal)
end

--清理当前行会的所有入侵玩家
function FactionInvadeManager:clearAllInvadeRole(factionID)
	print('FactionInvadeManager:clearAllInvadeRole facID='..factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		print('not find faction')
		return
	end

	local players = self._factionInvadeRoles[factionID] or {}
	for k,v in pairs(players) do
		g_factionMgr:outFactionArea(v)
		players[k] = nil
	end
end

--行会升级刷新入侵玩家buff
function FactionInvadeManager:updateBuff(factionID)
	print('FactionInvadeManager:updateBuff')
	--行会数据不存在
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		print('not find faction, factionID:'..factionID)
		return
	end

	local lvl = faction:getLevel()

	--被入侵的行会升级，刷新入侵该行会的玩家buff
	local players = self._factionInvadeRoles[factionID]
	print('this faction invade num: '..table.size(players))
	if players then
		for _, rolesSID in pairs(players) do
			local info = self._factionInvadeInfos[rolesSID]
			if info then
				local buffID = info:getBuffID()
				local player = g_entityMgr:getPlayerBySID(rolesSID)
				if player then
					local myFacID = player:getFactionID()
					local myFaction = g_factionMgr:getFaction(myFacID)
					if myFaction then
						--清理buffer
						local buffMgr = player:getBuffMgr()
						if not buffMgr then
							warning('get player buffMgr failed')
							return
						end
						local eCode = 0
						if buffID then							
							buffMgr:delBuff(buffID)
							print('clear buff: '..buffID)
							info:setBuffID(nil)
						end

						--加新buff
						local myFacLvl = myFaction:getLevel()
						if myFacLvl > lvl then
							eCode = 0
							buffMgr:addBuff(FACTION_INVADE_WEAK_BUFF[myFacLvl-lvl], eCode)
							print('add new buff:'..FACTION_INVADE_WEAK_BUFF[myFacLvl-lvl])
							info:setBuffID(FACTION_INVADE_WEAK_BUFF[myFacLvl-lvl])
						end
					end				
				end
			end
		end
	end

	--刷新该行会成员的buff
	local allMem = faction:getAllMembers()
	if allMem then
		for rolesSID, v in pairs(allMem) do
			if v then
				local info1 = self._factionInvadeInfos[rolesSID]
				if info1 then
					local invadeFacID = info1:getFactionID()
					local buffID = info1:getBuffID()
					local player = g_entityMgr:getPlayerBySID(rolesSID)
					if player then
						local invadeFaction = g_factionMgr:getFaction(invadeFacID)
						if invadeFaction then
							local facLvl = invadeFaction:getLevel()
							--清理buffer
							local buffMgr = player:getBuffMgr()
							if not buffMgr then
								warning('get player buffMgr failed')
								return
							end
							local eCode = 0
							if buffID then
								buffMgr:delBuff(buffID)
								print('clear buff: '..buffID)
								info1:setBuffID(nil)
							end
							if lvl > facLvl then
								--加新buff
								eCode = 0
								buffMgr:addBuff(FACTION_INVADE_WEAK_BUFF[lvl-facLvl], eCode)
								print('add new buff:'..FACTION_INVADE_WEAK_BUFF[lvl-facLvl])
								info1:setBuffID(FACTION_INVADE_WEAK_BUFF[lvl-facLvl])
							end
						end
					end
				end
			end
		end
	end
end

--取得当前入侵行会信息
function FactionInvadeManager:getCurFactionInfo(rolesSID)
	print('FactionInvadeManager:getCurFactionInfo')
	local player = g_entityMgr:getPlayerBySID(rolesSID)
	if not player then
		warning('not find player')
		return
	end

	local facID = player:getAreaFactionID()
	local faction = g_factionMgr:getFaction(facID)
	if not faction then
		warning('not find faction')
		return
	end

	local ret = {}
	ret.facID = facID
	ret.facName= faction:getName()
	print(string.format('cur invade facID:%d, facName:%s', facID, ret.facName))

	fireProtoMessage(player:getID(), FACTION_INVADE_SC_GET_CUR_FACTION_INFO, 'FactionInvadeCurFactionInfoRet', ret)

end

function FactionInvadeManager:onSwitchScene(player, mapID)
	print('FactionInvadeManager:onSwitchScene() ', mapID)
	if not player then
		warning('not find player ')
		return
	end
	local info = self._factionInvadeInfos[player:getSerialID()]
	if info then
		self:outFactionArea(player:getSerialID(), info:getFactionID())
	end
end

function FactionInvadeManager:onFreshDay()
	local randomVal = math.random(1, 180)
	gTimerMgr:regTimer(self, randomVal*1000, 0)
end

function FactionInvadeManager:update()
	self._factionInvadeRecords = {}
end


function FactionInvadeManager.getInstance()
	return FactionInvadeManager()
end

g_factionInvadeMgr = FactionInvadeManager.getInstance()