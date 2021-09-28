--ManorWarMgr.lua

require ("system.manorwar.ManorWarConstant")
require ("system.manorwar.ManorWarPrototype")
require ("system.manorwar.ManorWarServlet")
 
local MTRewardDB = require "data.MTRewardDB"

ManorWarMgr = class(nil, Singleton)

function ManorWarMgr:__init()
	self._manorProtos = {}--配置
	self._openTimeProtos = {}--所有的开启配置
	self._actingManor = {}	--当前正在进行的战役列表
	self._uniqueManorInfo = {}	--领地信息 {}
	self._statueID = 0	--雕像动态ID
	self._enterTime = {}	--记录进入时间写日志
	self._notifyFlag = {}	--开启前的提示FLAG
	self._rewardInfo = {stamp = 0, roleInfo = {}}	--领地战每日奖励信息
	g_listHandler:addListener(self)
end

function ManorWarMgr:initManorInfo()
	local allConfigs = require ("data.ManorWarDB")	
	for i=1, #allConfigs do
		allConfigs[i].bannerPos = unserialize("{" .. allConfigs[i].bannerPos .. "}")
		if allConfigs[i].salary then
			allConfigs[i].salary = unserialize("{" .. allConfigs[i].salary .. "}")
		end

		allConfigs[i].winDrop = allConfigs[i].winDrop
		allConfigs[i].loseDrop = allConfigs[i].loseDrop

		self._openTimeProtos[tonumber(allConfigs[i].manorID)] = {openTime = allConfigs[i].openTime, openDayLimit = tonumber(allConfigs[i].openDayLimit)} 	--用来保存所有开启时间
		local scene = g_sceneMgr:getPublicScene(allConfigs[i].mapID)
		if scene then
			local manorId = tonumber(allConfigs[i].manorID)
			self._actingManor[manorId] = 0
			self._manorProtos[manorId] = ManorWarPrototype(allConfigs[i])

			self._uniqueManorInfo[manorId] = {roles = {}, logRoles = {}, manorBeginTime=0, bannerOwner=0, bannerTime=0, bannerID=0,occupyTime=0, factionID=0,
				 facName = "", preOpenTime=0, over = false, totalOpenCnt=0, official = {0,0,0}, openNotice1=false, openNotice2=false, openNotice3=false, openNotice4=false,openNotice5=false, bannerPosX=0, bannerPosY=0}
			--初始化旗帜
			local banner = g_entityMgr:getFactory():createMonster(MANOR_MON_ID)
			if banner then
				self._uniqueManorInfo[manorId].bannerID = banner:getID()
				self._uniqueManorInfo[manorId].bannerPosX = allConfigs[i].bannerPos[1]
				self._uniqueManorInfo[manorId].bannerPosY = allConfigs[i].bannerPos[2]
				g_sceneMgr:enterPublicScene(banner:getID(), allConfigs[i].mapID, allConfigs[i].bannerPos[1], allConfigs[i].bannerPos[2], 1)
				banner:setStrPropValue(ROLE_STATUS_NAME, "")
			end
		end
	end
end

--正方形判断
function ManorWarMgr:isNearArea(x1, y1, x2, y2, radius)
	if x1 == 0 or y1 == 0 or radius == 0 then
		return false
	end
	
	local dist = math.abs(x1 - x2) + math.abs(y1 - y2)
	return dist <= radius
end

function ManorWarMgr:modifyManorFacData(factionID, name)
	local manors = self:getManorInfoByFaction(factionID)
	--领地数据处理
	if table.size(manors) > 0 then
		for manorID, manorInfo in pairs(manors) do
			manorInfo.facName = name
			self:castDB(manorID)
		end
	end
end

--能否参加中州战，判断条件是
function ManorWarMgr:canJoinZhongZhou(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	
	if not player then
		return false
	end

	if player:getFactionID() <= 0 then
		return false
	end

	for manorID, manorInfo in pairs(self._uniqueManorInfo) do
		if manorInfo.factionID == player:getFactionID() then
			return true
		end
	end

	return false
end

--加载奖励公共数据
function ManorWarMgr:onLoadRewardData(data)
	if data then
		if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
			self._rewardInfo = unserialize(data)
		end
	else
		self._rewardInfo = {stamp = 0, roleInfo = {}}	--领地战每日奖励信息
	end
end


--判断是否可以领取领地战奖励
function ManorWarMgr:canpickMonorReward(roleSID, manorID)
	local timeStamp = time.toedition("day")
    if not (tonumber(timeStamp) == self._rewardInfo.stamp) then
	    --过期的时间戳要刷新
		self._rewardInfo.stamp = tonumber(time.toedition("day"))
		self._rewardInfo.roleInfo = {}
    end

	if self._rewardInfo.roleInfo[roleSID] then
		if table.contains(self._rewardInfo.roleInfo[roleSID], manorID) then
			return false
		end
	end
	return true
end

--领取领地战奖励 
function ManorWarMgr:pickMonorReward(dbId, manorID)
	local proto = self._manorProtos[manorID]
	local manorInfo = g_manorWarMgr:getManorInfo(manorID)
	
	if not proto or not manorInfo then
		return
	end

	local allReward = proto:getdailyReward()
	if not allReward then
		return false
	end

	local player = g_entityMgr:getPlayerBySID(dbId)

	if not player then
		return
	end

	local factionID = player:getFactionID()

	if factionID <= 0 then
		ManorWarServlet.getInstance():sendErrMsg2Client(player:getID(), MANOR_ERR_NO_FACTION2, 0)
		return
	end

	if table.contains(self._rewardInfo.roleInfo[dbId], manorID) then
		ManorWarServlet.getInstance():sendErrMsg2Client(player:getID(), MANOR_ERR_REWARD_HAS_GIVE, 0)
		return
	end

	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		return
	end
	
	if not self._rewardInfo.roleInfo[dbId] then
		self._rewardInfo.roleInfo[dbId] = {}
	end
	table.insert(self._rewardInfo.roleInfo[dbId], manorID)
	updateCommonData(COMMON_DATA_ID_MANOR_REWARD, self._rewardInfo)

	local reward = allReward
	local logsource = 74
	if manorID == MANOR_MAINCITYWAR then
		logsource = 75
		local pos = 3
		if dbId == faction:getLeaderID() then
			pos = 1
		elseif dbId == faction:getAssLeaderID() then
			pos = 2
		end
		reward = allReward[pos]
	else
		reward = allReward[1]
	end

	rewardByDropID(dbId, reward, 35, logsource)
	ManorWarServlet.getInstance():sendErrMsg2Client(player:getID(), MANOR_ERR_GET_SALARY_SUC, 0)

	--领取奖励成功，通知客户端
	local ret = {}
	ret.manorID = manorID
	fireProtoMessage(player:getID(), MANORWAR_SC_PICKREWARD_RET, 'PickManorRewardRetProtocol', ret)
end

function ManorWarMgr:broadMsg(errId, paramCount, params)	
	local ret = {}
	ret.eventId = EVENT_MANORWAR_SETS
	ret.eCode = errId
	ret.mesId = 0
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function ManorWarMgr:writeManorInfo(dbId, manorId)
	local proto = self._manorProtos[manorId]
	if not proto then
		return
	end
	
	local player = g_entityMgr:getPlayerBySID(dbId)

	if not player then
		return
	end

	local playerFaction = player:getFactionID()
	local pos = player:getPosition()
	local posX = pos.x
	local posY = pos.y
	local manorInfo = self:getManorInfo(manorId)
	if not manorInfo then
		return
	end

	
	local proto = self:getManorProto(manorId)
	local centerPos = proto:getBannerPos()
	local isNear = self:isNearArea(posX, posY, centerPos[1], centerPos[2], proto:getStandardRange())
	
	local ret = {}
	local owner = g_entityMgr:getPlayerBySID(manorInfo.bannerOwner)
	ret.siAid = false
	ret.bannerOwner = false
	if owner then
		--同帮保护 反之抢夺
		ret.siAid = playerFaction == owner:getFactionID()
		ret.bannerOwner = true
		ret.owner = owner:getName()
		ret.facName = owner:getFactionName()
		ret.bannerTime = os.time() - manorInfo.bannerTime
	end

	
	ret.manorID = manorId
	ret.isOver = manorInfo.over
	ret.beginTime = os.time() - manorInfo.manorBeginTime
	ret.isNear = isNear

	fireProtoMessage(player:getID(), MANORWAR_SC_SIMPLEWARINFORET, 'SimpleWarInfoRetProtocol', ret)
end

--夺旗后数据处理
function ManorWarMgr:changeBannerState(player, manorProto)
	local manorId = manorProto:getManorID()
	local manorInfo = self._uniqueManorInfo[manorId]
	
	manorInfo.bannerOwner = player:getSerialID()
	manorInfo.bannerTime = os.time()
	manorInfo.bannerPosX = player:getPosition().x
	manorInfo.bannerPosY = player:getPosition().y

	--同步夺旗数据
	local ret = {}
	ret.factionID = player:getFactionID()
	ret.manorID = manorId
	ret.facName = manorInfo.facName
	
	for roleSID, _ in pairs(manorInfo.roles) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			fireProtoMessage(player:getID(), MANORWAR_SC_NOTIFYOCCUPYFACTION, 'NotifyOccupyFactionProtocol', ret)
		end
	end
end

function ManorWarMgr:getManorInfoByFaction(factionID)
	local manors = {}
	for manorID, manorInfo in pairs(self._uniqueManorInfo) do
		if manorInfo.factionID == factionID then
			manors[manorID] = manorInfo
		end
	end
	return manors
end

--解散帮会处理
function ManorWarMgr:disbandFaction(factionID)
	local manors = self:getManorInfoByFaction(factionID)
	--领地数据处理
	if table.size(manors) > 0 then
		for manorID, manorInfo in pairs(manors) do
			manorInfo.occupyTime = 0
			manorInfo.factionID = 0
			manorInfo.facName = ""
			manorInfo.tmpOccupyTime = 0
			manorInfo.official = {0,0,0}
			self:castDB(manorID)
			
			if manorID == MANOR_MAINCITYWAR then
				--通知中州王刷新
				local ret = {}
				boardProtoMessage(MANORWAR_SC_GET_LEADERINFO_RET, 'ManorGetLeaderInfoRetProtocol', ret)
			end
		end
	end
end

function ManorWarMgr:isManorActing2(manorId)
	if manorId and manorId <= 0 then
		return false
	end
	
	if manorId then
		local openTime = self._openTimeProtos[manorId].openTime
		local openDayLimit = self._openTimeProtos[manorId].openDayLimit or 0

		if openTime then
			if onSall(openTime, os.time()) then
				return true
			end
		end
	else
		for k, openTimeTb in pairs(self._openTimeProtos or {}) do
			local openTime = openTimeTb.openTime
			local openDayLimit = openTimeTb.openDayLimit or 0
			if onSall(openTime, os.time()) then
				return true
			end
		end
	end
	return false
end

function ManorWarMgr:isManorActing(manorId)
	if manorId and manorId <= 0 then
		return false
	end

	if not self._manorProtos[manorId] then
		return false
	end
	
	if manorId then
		if self._actingManor[manorId] > 0 then
			return true
		end
	else
		for k,v in pairs(self._actingManor) do
			if v > 0 then
				return true
			end
		end
	end
	return false
end

function ManorWarMgr:getManorProto(manorID)
	return self._manorProtos[manorID]
end

function ManorWarMgr:getZhongzhouOpenTime()
	local manorProto = g_manorWarMgr:getManorProto(MANOR_MAINCITYWAR)
	local isActive = self:isManorActing(MANOR_MAINCITYWAR)
	if manorProto then 
		return isActive, manorProto:getOpenTime(), self:getOpenDayNum(MANOR_MAINCITYWAR)
	end
end

function ManorWarMgr:getManorOpenTime()
	local manorProto = g_manorWarMgr:getManorProto(2)
	local isActive = self:isManorActing(2)
	if manorProto then 
		return isActive, manorProto:getOpenTime(), self:getOpenDayNum(2)
	end
end

--领地信息
function ManorWarMgr:getManorInfo(manorID)
	return self._uniqueManorInfo[manorID]
end

--获取领地占领帮会ID
function ManorWarMgr:getManorFacId(manorID)
	local manorInfo = self._uniqueManorInfo[manorID]
	if manorInfo then
		return manorInfo.factionID or 0
	end
	return 0
end

--获取领地占领帮会ID
function ManorWarMgr:getZhongzhouFacId()
	local manorInfo = self._uniqueManorInfo[MANOR_MAINCITYWAR]
	if manorInfo then
		return manorInfo.factionID or 0
	end
	return 0
end

--获取行会的领地ID
function ManorWarMgr:getFacManorID()
	local tFacManorID = {}
	for i,v in pairs(self._uniqueManorInfo) do
		tFacManorID[v.factionID] = i
	end
	return tFacManorID
end


function ManorWarMgr:getOwnFaction(dbId)
	local player = g_entityMgr:getPlayerBySID(dbId)
	if not player then
		return
	end
	
	local ret = {}
	ret.ownFactionInfo = {}
	for manorID, manorInfo in pairs(self._uniqueManorInfo) do
		local info = {}
		info.manorID = manorID
		info.facId = manorInfo.factionID
		table.insert(ret.ownFactionInfo, info)
	end
	fireProtoMessage(player:getID(), MANORWAR_SC_GETOWNFACTIONRET, 'GetOwnFactionRetProtocol', ret)
end

function ManorWarMgr:upDateOwnFaction(manorID, factionID)
	local ret = {}
	ret.ownFactionInfo = {}
	local info = {}
	info.manorID = manorID
	info.facId = factionID
	table.insert(ret.ownFactionInfo, info)
	boardProtoMessage(MANORWAR_SC_GETOWNFACTIONRET, 'GetOwnFactionRetProtocol', ret)
end

--获取所有领地奖励信息
function ManorWarMgr:getAllRewardInfo(dbId, manorID)
	local player = g_entityMgr:getPlayerBySID(dbId)
	if not player then
		return
	end
	
	local palyerFactionID = player:getFactionID()

	local manorInfo = self:getManorInfo(manorID)
	local manorProto = self:getManorProto(manorID)
	if manorProto and manorInfo then
		local manorFactionID = manorInfo.factionID
		local isOpen = self:isManorActing(manorID)
		local remainDay = self:getOpenDayNum(manorID)
		
		local ret = {}
		ret.manorID = manorID
		ret.isOpen = isOpen
		ret.remainDay = remainDay
		ret.curTime = os.time()
		ret.hasFaction = false
		local faction = g_factionMgr:getFaction(manorFactionID)
		if faction then
			ret.hasFaction = true
			ret.facName = faction:getName()
			ret.leaderName = faction:getLeaderName()
			
			--帮主
			local leader = faction:getMember(faction:getLeaderID())
			ret.sex = leader:getSex()
			ret.school = leader:getSchool()
			
			local player = g_entityMgr:getPlayerBySID(faction:getLeaderID())
			if player then
				local itemMgr = player:getItemMgr()
				leader:setWeapon(itemMgr:getWeaponID())
				leader:setUpperBody(itemMgr:getClothID())
				leader:setWingID(player:getCurWingID())
				leader:update2DB(manorFactionID)
			end
			ret.weapon = leader:getWeapon()
			ret.cloth = leader:getUpperBody()
			ret.wing = leader:getWingID()	

			--副帮主名字
			local assLeaderID = faction:getAssLeaderID()
			local assleader = faction:getMember(assLeaderID)
			local assleaderName = ""
			if assleader then
				assleaderName = assleader:getName()
			end
			ret.assleaderName = assleaderName
		end

		local canReward = false
						
		if faction and palyerFactionID > 0 and palyerFactionID == manorFactionID then
			if g_manorWarMgr:canpickMonorReward(dbId, manorID) then
				canReward = true
			end
		end

		ret.canReward = canReward
		local manorFacId = {}
		for manorID, manorInfo in pairs(self._uniqueManorInfo) do
			if manorInfo.factionID > 0 then
				manorFacId[manorID] = manorInfo.factionID
			end
		end
		
		local zzFacId = {}
		for manorID,facId in pairs(manorFacId) do
			local info = {}
			info.manorID = manorID
			local faction = g_factionMgr:getFaction(facId)
			info.facId = facId
			if faction then
				info.facName = faction:getName()
				info.leaderName = faction:getLeaderName()
			end
			table.insert(zzFacId, info)
		end
		ret.zzFacId = zzFacId
		fireProtoMessage(player:getID(), MANORWAR_SC_GETALLREWARDINFO_RET, 'GetAllRewardInfoRetProtocol', ret)
	end
end

function ManorWarMgr:clearManorData(player)
	local scene = player:getScene()
	local manorId = self:getManorIdByPlayer(player)
	local roleSID = player:getSerialID()

	if manorId > 0 then
		local proto = self:getManorProto(manorId)
		local manorInfo = self:getManorInfo(manorId)
		if manorInfo and manorInfo.bannerOwner == player:getSerialID() then
			local banner = g_entityMgr:getMonster(manorInfo.bannerID)
			if banner then
				--旗帜归位
				local scene = g_sceneMgr:getPublicScene(proto:getMapID())
				if scene then
					g_sceneMgr:enterPublicScene(manorInfo.bannerID, proto:getMapID(), proto:getBannerPos()[1], proto:getBannerPos()[2], 1)
					manorInfo.bannerPosX = proto:getBannerPos()[1]
					manorInfo.bannerPosY = proto:getBannerPos()[2]
				end
			end

			manorInfo.bannerOwner = 0
			player:notifyProp(PLAYER_BANNER, "0")
			local buffmgr = player:getBuffMgr()
			buffmgr:delBuff(MANOR_BANNER_BUFFID)
			self:notifyOccupyFaction(manorId)
		end
	end
end

function ManorWarMgr:onActivePlayer(player)
	local manorId = self:getManorIdByPlayer(player)
	if player:getFactionID() > 0 and manorId > 0 then
		local proto = self:getManorProto(manorId)
		if self:isManorActing(manorId) then
			self:notifyOccupyFaction(manorId, player:getID())
		end
	end
end

function ManorWarMgr:onPlayerLoaded(player)
	local manorId = self:getManorIdByPlayer(player)
	if player:getFactionID() > 0 and manorId > 0 then
		if self:isManorActing(manorId) then
			self:notifyOccupyFaction(manorId, player:getID())
		end
	end

	for manorID,openTime in pairs(self._openTimeProtos) do
		if self:isManorActing(manorID) then
			self:notifyAllMainState(manorID, true, player:getID())
		end
	end
end

function ManorWarMgr:onPlayerInactive(player)
	local roleID = player:getID()
	local manorId = self:getManorIdByPlayer(player)

	if manorId > 0 then
		self:sendOut(player:getID())
	end
end

function ManorWarMgr:setEnterTime(roleSID)	--记录进入领地战时间，用来记日志
	self._enterTime[roleSID] = os.time()
end

function ManorWarMgr:sendOut(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local mamorProto
	for k, proto in pairs(self._manorProtos or {}) do
		if proto:getMapID() == player:getMapID() then
			mamorProto = proto
		end
	end

	if not mamorProto then
		return
	end
	
	local outPos = mamorProto:getDiePos()

	local mapID = outPos and outPos[1] or 1100
	local x = outPos and outPos[2] or 21
	local y = outPos and outPos[3] or 100

	self:clearManorData(player)
	local scene = g_sceneMgr:getPublicScene(mapID)
	if g_sceneMgr:posValidate(mapID, x, y) then
		g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
	else
		--如果地图有问题就走出生点
		g_sceneMgr:enterPublicScene(roleID, 1100, 21, 100)
	end

	--写流水日志
	if self._enterTime[player:getSerialID()] then
		local stayTime = os.time() - self._enterTime[player:getSerialID()]
		if mamorProto:getManorID() == MANOR_MAINCITYWAR then
			g_tlogMgr:TlogZZZBFlow(player, 0, 0, stayTime)
		else
			local factionID = player:getFactionID()
			local faction = g_factionMgr:getFaction(factionID)
			if faction then
				g_tlogMgr:TlogLDZDFlow(player, mamorProto:getMapID(), stayTime, factionID, faction:getName(), faction:getLevel())
			end
		end
		self._enterTime[player:getSerialID()] = nil
	end
end

function ManorWarMgr:onPlayerOffLine(player)
	local roleID = player:getID()
	local manorId = self:getManorIdByPlayer(player)

	if manorId > 0 then
		self:sendOut(player:getID())
	end
end

function ManorWarMgr:getManorIdByPlayer(player)
	local manorId = 0

	if player then
		local roleMapID = player:getMapID()

		for k, proto in pairs(self._manorProtos or {}) do
			if proto:getMapID() == roleMapID then
				manorId = k
			end
		end
	end

	return manorId
end

--玩家死亡
function ManorWarMgr:onPlayerDied(player, killerID)
	local scene = player:getScene()
	local roleID = player:getID()

	if player:getFactionID() > 0 and scene  then
		local manorId = scene:getManorWarID()
		local actingManor = self._manorProtos[manorId]
		if self:isManorActing(manorId) and actingManor then
			local manorInfo = self:getManorInfo(manorId)
			if manorInfo.bannerOwner == player:getSerialID() then
				local banner = g_entityMgr:getMonster(manorInfo.bannerID)
				if banner then
					--旗帜归位
					local scene = g_sceneMgr:getPublicScene(actingManor:getMapID())
					if scene then
						g_sceneMgr:enterPublicScene(manorInfo.bannerID, actingManor:getMapID(), actingManor:getBannerPos()[1], actingManor:getBannerPos()[2], 1)
					end
					manorInfo.bannerPosX = actingManor:getBannerPos()[1]
					manorInfo.bannerPosY = actingManor:getBannerPos()[2]
				end
				manorInfo.bannerOwner = 0
				player:notifyProp(PLAYER_BANNER, "0")
				local buffmgr = player:getBuffMgr()
				buffmgr:delBuff(MANOR_BANNER_BUFFID)
				self:notifyOccupyFaction(manorId)
			end
		end
	end
end

--普通经验奖励
function ManorWarMgr:updateExpReward()
	local actingManor = self._manorProtos[MANOR_MAINCITYWAR]
	local manorInfo = self:getManorInfo(MANOR_MAINCITYWAR)

	if actingManor and manorInfo then
		local nt = os.time()
		for k, v in pairs(manorInfo.roles) do
			local player = g_entityMgr:getPlayerBySID(k) 
			if player and player:getHP() > 0 then 
				if player:getMapID() == actingManor:getMapID() then
					local pos = player:getPosition()
					local centerPos = actingManor:getBannerPos()

					local isNear = self:isNearArea(pos.x, pos.y, centerPos[1], centerPos[2], actingManor:getStandardRange())
					local oldXp = player:getXP()
					if isNear then
						local perTickXp = MTRewardDB[player:getLevel()].gjpd
						--近端
						--player:setXP(oldXp + perTickXp)
						--Tlog[PlayerExpFlow]
						addExpToPlayer(player,perTickXp,74)

						local ret = {}
						ret.type = 0
						ret.value = perTickXp
						fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', ret)
					else
						local perTickXp = MTRewardDB[player:getLevel()].djpd
						--远端
						--player:setXP(oldXp + perTickXp)
						--Tlog[PlayerExpFlow]
						addExpToPlayer(player,perTickXp,74)

						local ret = {}
						ret.type = 0
						ret.value = perTickXp
						fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', ret)
					end
				end
			end
		end
	end
end

--夺旗信息
function ManorWarMgr:updateBannerTime(manorId)
	local actingManor = self._manorProtos[manorId]
	local manorInfo = self:getManorInfo(manorId)
	if actingManor and manorInfo then
		if not manorInfo.over then
			local player = g_entityMgr:getPlayerBySID(manorInfo.bannerOwner)
			if player then
				local dif = os.time() - manorInfo.bannerTime
				--占领成功
				if dif >= actingManor:getWinPeriod() then
					local factionID = player:getFactionID()
					local faction = g_factionMgr:getFaction(factionID)

					if not faction then	
						return
					end

					leader = faction:getMember(faction:getLeaderID())
					local facName = faction:getName()
					local sortMems = faction:getSortMembers()
					local official = {sortMems[1][1] and sortMems[1][1]:getRoleSID() or 0, sortMems[2][1] and sortMems[2][1]:getRoleSID() or 0, sortMems[3][1] and sortMems[3][1]:getRoleSID() or 0}
					
					manorInfo.occupyTime = os.time()
					manorInfo.factionID = player:getFactionID()
					manorInfo.facName = facName
					manorInfo.official = official
					manorInfo.over = true
					self:castDB(manorId)
					local banner = g_entityMgr:getMonster(manorInfo.bannerID)
					banner:setStrPropValue(ROLE_STATUS_NAME, manorInfo.facName)
					g_sceneMgr:enterPublicScene(manorInfo.bannerID, player:getMapID(), actingManor:getBannerPos()[1], actingManor:getBannerPos()[2], 1)
					manorInfo.bannerPosX = actingManor:getBannerPos()[1]
					manorInfo.bannerPosY = actingManor:getBannerPos()[2]
					local buffmgr = player:getBuffMgr()
					buffmgr:delBuff(MANOR_BANNER_BUFFID)
					player:notifyProp(PLAYER_BANNER, "0")
					if manorId == MANOR_MAINCITYWAR then
						self:freshStatus(player:getSerialID())
					end
					g_manorWarMgr:broadMsg(MANOR_BANNER_OVER, 2, {facName, actingManor:getName()})
					self:notifyOccupyFaction(manorId)
				end
			end
		end
	end
end

function ManorWarMgr:notifyOccupyFaction(manorId, roleID)
	local manorInfo = self:getManorInfo(manorId)

	if not manorInfo then
		return
	end
	--同步夺旗数据
	local ret = {}
	ret.factionID = manorInfo.factionID
	ret.manorID = manorId
	ret.facName = manorInfo.facName

	if roleID then
		fireProtoMessage(roleID, MANORWAR_SC_NOTIFYOCCUPYFACTION, 'NotifyOccupyFactionProtocol', ret)
	else
		for roleSID, _ in pairs(manorInfo.roles) do
			local tmpplayer = g_entityMgr:getPlayerBySID(roleSID) 
			if tmpplayer then
				fireProtoMessage(tmpplayer:getID(), MANORWAR_SC_NOTIFYOCCUPYFACTION, 'NotifyOccupyFactionProtocol', ret)
			end
		end
	end
end

--通知所有人王城战开启状态
function ManorWarMgr:notifyAllMainState(manorID, isOpen, roleID)
	local ret = {}
	ret.manorID = manorID
	ret.isOpen = isOpen
	

	if roleID then
		fireProtoMessage(roleID, MANORWAR_SC_NOTIFYALL, 'ManorNotifyAllProtocol', ret)
	else
		boardProtoMessage(MANORWAR_SC_NOTIFYALL, 'ManorNotifyAllProtocol', ret)
	end
end 

--胜利会长奖励
function ManorWarMgr:doWinLeaderReward(manorID, fctId)
	local proto = self._manorProtos[manorID]
	if not proto then
		return
	end

	if manorID ~= MANOR_MAINCITYWAR then
		return
	end
	
	local faction = g_factionMgr:getFaction(fctId)
	if faction then	
		leader = faction:getMember(faction:getLeaderID())
		if leader then
			local dropId = proto:getLeaderReward()
			g_entityMgr:dropItemToEmail2(faction:getLeaderID(), dropId, leader:getSex(), leader:getSchool(), 27, 70)

			g_RedBagMgr:winnerManorWar(faction:getLeaderID(), leader:getName())
		end
	end
end

function ManorWarMgr:openManor(manorID)
	local manorInfo = self:getManorInfo(manorID)
	local proto = self:getManorProto(manorID)

	local nt = os.time()

	--print("open",manorID)
	self._actingManor[manorID] = 1
	self:notifyAllMainState(manorID, true)
	local scene = g_sceneMgr:getPublicScene(proto:getMapID())
	manorInfo.preOpenTime = nt
	manorInfo.factionID = 0
	manorInfo.facName = ""
	local banner = g_entityMgr:getMonster(manorInfo.bannerID)
	if banner then
		banner:setStrPropValue(ROLE_STATUS_NAME, "")
	end

	manorInfo.totalOpenCnt = manorInfo.totalOpenCnt + 1
	manorInfo.manorBeginTime = os.time()
	scene:setManorWarID(manorID)
	if manorID == MANOR_MAINCITYWAR then
		g_normalLimitMgr:sendErrMsg2Client(MANOR_OPEN_ZHONGZHOU_NOTICE, 0, {})
	else
		g_normalLimitMgr:sendErrMsg2Client(MANOR_OPEN_NOTICE, 0, {})
	end
	

	--旗帜归属同步
	manorInfo.bannerPosX = proto:getBannerPos()[1]
	manorInfo.bannerPosY = proto:getBannerPos()[2]
	manorInfo.over = false

	--同步夺旗数据
	local ret = {}
	ret.factionID = manorInfo.factionID
	ret.manorID = manorID
	ret.facName = manorInfo.facName

	local curScenePlayer = scene:getEntities(0, proto:getBannerPos()[1], proto:getBannerPos()[2], 500, eClsTypePlayer, 0) or {}
	for i=1, #curScenePlayer do
		local tmpplayer = g_entityMgr:getPlayer(curScenePlayer[i])
		if tmpplayer and tmpplayer:getFactionID() > 0 then
			manorInfo.roles[tmpplayer:getSerialID()] = 0
			manorInfo.logRoles[tmpplayer:getSerialID()] = tmpplayer:getFaction()
			fireProtoMessage(curScenePlayer[i], MANORWAR_SC_NOTIFYOCCUPYFACTION, 'NotifyOccupyFactionProtocol', ret)
			if tmpplayer:getLevel() >= 35 then
				tmpplayer:setPattern(2)
			end
		end
	end
	self:castDB(manorID)
end

function ManorWarMgr:closeManor(manorID)
	local manorInfo = self:getManorInfo(manorID)
	local player = g_entityMgr:getPlayerBySID(manorInfo.bannerOwner)
	local factionID = 0
	if player then
		factionID = player:getFactionID()
	else
		factionID = manorInfo.factionID
	end

	local facName = ""
	local leaderID = 0
	local sex = 1
	local school = 1
	local name = ""
	local official = {}

	local faction = g_factionMgr:getFaction(factionID)
	if faction then	
		facName = faction:getName()
		leaderID = faction:getLeaderID()
		leader = faction:getMember(faction:getLeaderID())
		if leader then
			sex = leader:getSex()
			school = leader:getSchool()
			name = faction:getLeaderName()
		end

		local sortMems = faction:getSortMembers()
		official = {sortMems[1][1] and sortMems[1][1]:getRoleSID() or 0, sortMems[2][1] and sortMems[2][1]:getRoleSID() or 0, sortMems[3][1] and sortMems[3][1]:getRoleSID() or 0}
	end


	local proto = self._manorProtos[manorID]
	local nt = os.time()

	self:notifyAllMainState(manorID, false)
	local scene = g_sceneMgr:getPublicScene(proto:getMapID())
	local winReward = proto:getWinDrop()
	local loseReward = proto:getLoseDrop()

	manorInfo.bannerPosX = proto:getBannerPos()[1]
	manorInfo.bannerPosY = proto:getBannerPos()[2]
	self._actingManor[manorID] = 0


	local player = g_entityMgr:getPlayerBySID(manorInfo.bannerOwner)
	if player then
		if player:getFactionID() ~= manorInfo.factionID then
			--所有权变更
			if manorID == MANOR_MAINCITYWAR then
				self:freshStatus(player:getSerialID())
			end
		end
		
		manorInfo.occupyTime = os.time()
		manorInfo.factionID = player:getFactionID()
		manorInfo.facName = facName
		manorInfo.official = official
		self:castDB(manorID)
		
		local buffmgr = player:getBuffMgr()
		buffmgr:delBuff(MANOR_BANNER_BUFFID)
		player:notifyProp(PLAYER_BANNER, "0")
	end

	if manorInfo.factionID then
		local faction = g_factionMgr:getFaction(manorInfo.factionID)
		if faction then
			local members = faction:getAllMembers()
			if members then
				for roleSID, _ in pairs(members) do
					local player = g_entityMgr:getPlayerBySID(roleSID)
					if player then
						if manorID ~= MANOR_MAINCITYWAR then
							g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.winManorWar, 1)
						else
							g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.winZhongzhouWar, 1)
						end
					end
				end
			end
		end
	end
	
	g_adoreMgr:clearZhongAdoreData()
	self:doWinLeaderReward(manorID, manorInfo.factionID)

	--俸禄时间清空
	manorInfo.bannerOwner = 0	
	manorInfo.bannerTime = 0

	--占领信息广播
	if manorInfo.factionID > 0 then
		self:broadMsg(MANOR_OFF_OCCUPY_NOTICE, 3, {proto:getName(), facName, proto:getName()})
		g_factionMgr:addNewBigEvent(FACTION_EVENT_MANOR_WIN, {facName, proto:getName()})
		self:upDateOwnFaction(manorID, manorInfo.factionID)
	else
		self:broadMsg(MANOR_OFF_NOTICE, 2, {proto:getName(), proto:getName()})
	end
	--旗帜归位
	local banner = g_entityMgr:getMonster(manorInfo.bannerID)
	if banner then
		if not banner:getScene() then
			banner:setStrPropValue(ROLE_STATUS_NAME, facName)
			g_sceneMgr:enterPublicScene(banner:getID(), proto:getMapID(), proto:getBannerPos()[1], proto:getBannerPos()[2], 1)
		end
	end

	scene:setManorWarID(0)

	local ret = {}
	ret.manorID = manorID
	for rid, _ in pairs(manorInfo.roles) do
		local tmpplayer = g_entityMgr:getPlayerBySID(rid)
		if tmpplayer then
			fireProtoMessage(tmpplayer:getID(), MANORWAR_SC_ENDMANORWAR, 'EndManorWarProtocol', ret)
		end	
	end

	local winFacId = manorInfo.factionID

	--胜利失败奖励
	if self:isMainCityWar(manorID) then
		local joinZhongzhouFacId = {}
		for manorID, man in pairs(self._uniqueManorInfo) do
			if manorID ~= MANOR_MAINCITYWAR and man.factionID > 0 then
				if not table.contains(joinZhongzhouFacId,man.factionID) then
					table.insert(joinZhongzhouFacId, man.factionID)
				end
			end
		end
		
		for _,facId in pairs(joinZhongzhouFacId) do
			local faction = g_factionMgr:getFaction(facId)
			local allMems = faction:getAllMembers() or {}
			if winFacId == facId then
				for roleSID, mem in pairs(allMems) do
					g_entityMgr:dropItemToEmail2(roleSID, winReward, mem:getSex(), mem:getSchool(), 39, 70)
				end
			else
				for roleSID, mem in pairs(allMems) do
					g_entityMgr:dropItemToEmail2(roleSID, loseReward, mem:getSex(), mem:getSchool(), 40, 72)
				end
			end
		end
	end

	manorInfo.roles = {}
	manorInfo.manorBeginTime = 0
	manorInfo.openNotice1 = 0
	manorInfo.openNotice2 = 0
	manorInfo.openNotice3 = 0
	manorInfo.openNotice4 = 0
	manorInfo.openNotice5 = 0
	self._notifyFlag = {}	--开启前的提示FLAG
	self:writeLog(manorID)
end

--更新时间更新
function ManorWarMgr:updateOpenTime(manorID)
	local nt = os.time()
	if not self:isManorActing(manorID) then
		local manorInfo = self:getManorInfo(manorID)
		local proto = self:getManorProto(manorID)
		if manorInfo then
			--开启前提示
			if onSall(proto:getOpenNotice1(), nt) then
				if not self._notifyFlag[1]  then
					self._notifyFlag[1] = nt
					if manorID == MANOR_MAINCITYWAR then
						g_normalLimitMgr:sendErrMsg2Client(MANOR_START_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {10})
					else
						g_normalLimitMgr:sendErrMsg2Client(MANOR_START_REMAIN_TIME_NOTIFY, 1, {10})
					end
				else
					if not self._notifyFlag[2] then
						if nt - self._notifyFlag[1] > 5*60 then
							self._notifyFlag[2] = nt
							if manorID == MANOR_MAINCITYWAR then
								g_normalLimitMgr:sendErrMsg2Client(MANOR_START_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {5})
							else
								g_normalLimitMgr:sendErrMsg2Client(MANOR_START_REMAIN_TIME_NOTIFY, 1, {5})
							end
						end
					else
						if not self._notifyFlag[3] then
							if nt - self._notifyFlag[2] > 4*60 then
								self._notifyFlag[3] = nt
								if manorID == MANOR_MAINCITYWAR then
									g_normalLimitMgr:sendErrMsg2Client(MANOR_START_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {1})
								else
									g_normalLimitMgr:sendErrMsg2Client(MANOR_START_REMAIN_TIME_NOTIFY, 1, {1})
								end
							end
						end
					end
				end
			end

			if onSall(proto:getOpenTime(), nt) then
				self:openManor(manorID)
			end
		end
	else
		local proto = self._manorProtos[manorID]
		local manorInfo = self:getManorInfo(manorID)
		if manorInfo then
			--结束处理
			if manorInfo.manorBeginTime > 0 and nt-manorInfo.manorBeginTime >= MANOR_TOTAL_TIME then
				self:closeManor(manorID)
			end

			--剩余时间提醒
			if not manorInfo.openNotice3 and (nt-manorInfo.manorBeginTime >= 55*60) then
				manorInfo.openNotice3 = true
				if manorID == MANOR_MAINCITYWAR then
					g_normalLimitMgr:sendErrMsg2Client(MANOR_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {5})
				else
					g_normalLimitMgr:sendErrMsg2Client(MANOR_REMAIN_TIME_NOTIFY, 1, {5})
				end
			end

			if not manorInfo.openNotice4 and (nt-manorInfo.manorBeginTime >= 57*60) then
				manorInfo.openNotice4 = true
				if manorID == MANOR_MAINCITYWAR then
					g_normalLimitMgr:sendErrMsg2Client(MANOR_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {3})
				else
					g_normalLimitMgr:sendErrMsg2Client(MANOR_REMAIN_TIME_NOTIFY, 1, {3})
				end
			end

			if not manorInfo.openNotice5 and (nt-manorInfo.manorBeginTime >= 59*60) then
				manorInfo.openNotice5 = true
				if manorID == MANOR_MAINCITYWAR then
					g_normalLimitMgr:sendErrMsg2Client(MANOR_ZHONGZHOU_REMAIN_TIME_NOTIFY, 1, {1})
				else
					g_normalLimitMgr:sendErrMsg2Client(MANOR_REMAIN_TIME_NOTIFY, 1, {1})
				end
			end
		end			
	end
end


function ManorWarMgr:writeLog(manorID)
	local proto = self._manorProtos[manorID]
	local manorInfo = self:getManorInfo(manorID)
	local nt = os.time()

	if manorInfo then
		local manorType = 1
		if manorID == MANOR_MAINCITYWAR then
			manorType = 2
		end
		for roleSID,factionID in pairs(manorInfo.logRoles) do
			g_logManager:writeHegemony(roleSID, factionID, manorType, manorID, manorInfo.factionID)
		end
	end
	manorInfo.logRoles = {}
end

--更新夺旗人坐标
function ManorWarMgr:updateBannerPos(manorId)
	local actingManor = self._manorProtos[manorId]
	if actingManor then
		local manorInfo = self._uniqueManorInfo[manorId]
		local owner = g_entityMgr:getPlayerBySID(manorInfo.bannerOwner)
		local bannerPos = actingManor:getBannerPos()
		if owner then 
			bannerPos = {owner:getPosition().x, owner:getPosition().y}
		end

		local ret = {}
		ret.manorID = manorId
		ret.posX = bannerPos[1]
		ret.posy = bannerPos[2]
		
		for rid, cnt in pairs(manorInfo.roles) do
			local player = g_entityMgr:getPlayerBySID(rid)
			if player then
				fireProtoMessage(player:getID(), MANORWAR_SC_BANNERPOS, 'BannerPosProtocol', ret)
			end
		end
		manorInfo.bannerPosX = bannerPos[1]
		manorInfo.bannerPosY = bannerPos[2]
	end
end

function ManorWarMgr:onThreeSecond()
	for manorId,isOpen in pairs(self._actingManor) do
		self:updateOpenTime(manorId)
		if isOpen > 0 then
			self:updateBannerTime(manorId)
			self:updateBannerPos(manorId)
		end
	end 
	self:updateExpReward()
end


function ManorWarMgr.onLoadManorInfo(str)
	local self = g_manorWarMgr
	local tb = {}

	for w in string.gmatch(str, "[% ]-([^% ]+)") do
		table.insert(tb, w)
	end
	if #tb > 0 then
		local manorID = tb[1] + 0
		local server = tb[2] + 0
		local tarServerID = math.mod(server, 10) + 1
		local proto = self._manorProtos[manorID]
		if proto then
			local manorInfo = self._uniqueManorInfo[manorID]
			if manorInfo then
				manorInfo.occupyTime = tb[3] + 0
				manorInfo.factionID = tb[4] + 0
				manorInfo.official = unserialize(tb[7])
				manorInfo.facName = tb[8]
				local banner = g_entityMgr:getMonster(manorInfo.bannerID)
				if banner then
					banner:setStrPropValue(ROLE_STATUS_NAME, manorInfo.facName)
				end
			end			
		end
	end
end


function ManorWarMgr:GmSetManorFac(manorID, facName)
	local faction = g_factionMgr:getFactionByName(facName)
	if not faction then
		return
	end

	manorID = tonumber(manorID) 
	local manorInfo = self._uniqueManorInfo[manorID]

	if not manorInfo then
		return
	end

	manorInfo.facName = facName
	manorInfo.factionID = faction:getFactionID()
	self:castDB(manorID)
end

function ManorWarMgr:castDB(manorID)
	local proto = self._manorProtos[manorID]
	if proto then
		local manorInfo = self._uniqueManorInfo[manorID]

		if manorInfo then
			local serverID = g_frame:getWorldId()
			local preOpenTime = manorInfo and manorInfo.preOpenTime
			local totalOpenCnt = manorInfo and manorInfo.totalOpenCnt
			local retBuff = LuaEventManager:instance():getLuaRPCEvent(DIGMINE_SS_UPDATE)
			retBuff:pushInt(manorID)
			retBuff:pushInt(serverID)
			retBuff:pushInt(manorInfo.occupyTime)
			retBuff:pushInt(manorInfo.factionID)
			retBuff:pushInt(preOpenTime)
			retBuff:pushInt(totalOpenCnt)
			retBuff:pushString(serialize(manorInfo.official))
			retBuff:pushString(manorInfo.facName)
			g_entityDao:updateManorWar(retBuff)
		end		
	end
end

--是否是王城争霸战
function ManorWarMgr:isMainCityWar(manorID)
	if MANOR_MAINCITYWAR == manorID then
		return true
	end
	return false
end

--判断当天是否开过领地战
function ManorWarMgr:hasOpeCurDay(manorID)
	local manorInfo = self._uniqueManorInfo[manorID]

	if dayBetween(os.time(), manorInfo.preOpenTime) == 0 then
		return true
	end
	return false
end

--获取开启还差多少天
function ManorWarMgr:getOpenDayNum(manorID)
	local proto = self:getManorProto(manorID)

	if not proto then
		return 200
	end
	local manorInfo = self._uniqueManorInfo[manorID]
	local remainDay = 200
	local remainDelay = 0
	
	--print("ManorWarMgr:getOpenDayNum", manorInfo.totalOpenCnt)
	if manorInfo.totalOpenCnt == 0 then
		local hasGoneDay = dayBetween(g_frame:getStartTick(), os.time())
		remainDelay = proto:getForceOpen() - hasGoneDay - 1
	end

	local weekDayTb = proto:getWeekDay()
	local nowWeekDayNum = tonumber(os.date("%w",os.time())) --今天是星期几

	if remainDelay > 0 then
		nowWeekDayNum = tonumber(os.date("%w",os.time() + remainDelay*24*60*60))
	end

	if nowWeekDayNum == 0 then
		nowWeekDayNum = 7
	end

	local minWeekDay = 7
	local maxWeekDay = 1
	local getNextDay = false
	for _,day in pairs(weekDayTb) do
		if day == 0 then
			day = 7
		end

		if day < minWeekDay then
			minWeekDay = day
		end
		if day > maxWeekDay then
			maxWeekDay = day
		end

		if nowWeekDayNum == day and manorInfo.totalOpenCnt == 0 and remainDelay == 0 then
			getNextDay = true
		end
	end

	if getNextDay or self:hasOpeCurDay(manorID) then
		nowWeekDayNum = nowWeekDayNum + 1
	end


	if nowWeekDayNum > maxWeekDay then
		remainDay = (7 - nowWeekDayNum) + minWeekDay
	elseif nowWeekDayNum < maxWeekDay then
		for _,day in ipairs(weekDayTb) do
			if day == 0 then
				day = 7
			end

			if day == nowWeekDayNum then
				remainDay = 0
				break
			end

			if day > nowWeekDayNum then
				remainDay = day - nowWeekDayNum
				break
			end
		end
	else
		remainDay = 0
	end
	
	if getNextDay or self:hasOpeCurDay(manorID) then
		remainDay = remainDay + 1
	end

	if remainDelay > 0 then
		remainDay = remainDay + remainDelay
	end
	
	--print("ManorWarMgr:getOpenDayNum", minWeekDay,maxWeekDay,remainDay)
	return remainDay
end

function ManorWarMgr:freshStatus(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local faction = g_factionMgr:getFaction(player:getFactionID())

	local sex = 1
	local school = 1
	local name = ""
	if faction then
		local leader = faction:getMember(faction:getLeaderID())
		if leader then
			sex = leader:getSex()
			school = leader:getSchool()
			name = faction:getLeaderName()
		end 
	end

	local ret = {}
	ret.sex = sex
	ret.school = school
	ret.name = name
	fireProtoMessage(player:getID(), MANORWAR_SC_GET_LEADERINFO_RET, 'ManorGetLeaderInfoRetProtocol', ret)
end

function ManorWarMgr.getInstance()
	return ManorWarMgr()
end

g_manorWarMgr = ManorWarMgr.getInstance()
g_manorWarMgr:initManorInfo()

