--FactionManager.lua
--帮会管理类

require ("system.faction.FactionConstant")
require ("system.faction.Faction")
require ("system.faction.FactionServlet")
require ("system.faction.FactionMember")
require ("system.faction.LuaFactionDAO")

--行会外交
require ("system.faction.FactionSocial")

--行会公共任务
require ("system.faction.FactionTask")

--行会运镖
require ("system.faction.FactionDart")

FactionManager = class(nil, Singleton, Timer)

function FactionManager:__init()
	self.m_allFactions = {} --所有帮会
	self.m_allFactionsByName = {} --名字对应帮会
	self._applyInfo = {}	--申请列表
	self._factionRank = {}	--帮会排名
	self._rankTime = 0
	g_listHandler:addListener(self)
	self._lastID = 0
	self._updateTime = 0
	self._addStatueRd = {}	--雕像捐献记录
	self._createFacTmpData = {}	--创建帮会临时数据
	self._offRemoveBuff = {}	--离线退会BUFF
	self._enterOtherArea = {}  --进入别的帮会领地记录
	self._bigEventRd = {}		 --军机事件记录
	gTimerMgr:regTimer(self, 5000, 5000)

	--行会外交
	self._allFactionSocials = {}		--所有行会外交信息
	self._allFactionSocialsDetail = {}	--具体行会的详细外交信息
	self._maxFactionID = g_worldID*10000 --最大的行会编号
	g_entityDao:loadMaxFactionID()

	--行会公共任务
	self._allFactionTasks = {}			--所有行会公共任务信息
	self._allFinishFactionTasks = {}		--所有已经完成的行会公共任务信息


	--行会运镖
	self._factionDart = nil              --{factionID = FactionDart}

	--实时语音
	self._factinonVoice = {}
end

function FactionManager:addNewBigEvent(eCode, params)
	local nowTime = os.time()
	if #self._bigEventRd >= FACTION_EVENT_MAX_COUNT then 
		table.remove(self._bigEventRd, 1)
	end
	table.insert(self._bigEventRd, {nowTime, eCode, params})
	updateCommonData(COMMON_DATA_ID_FACTION_EVENT, self._bigEventRd)
end

function FactionManager:getEventRd(dbid)
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		print("FactionManager:getEventRd Palyer Not Exist,dbid:"..tostring(dbid));
		return
	end

	local faction = g_factionMgr:getFaction(player:getFactionID())
	if not faction then
		return
	end

	local ret = {}
	ret.records = {}

	for _, record in ipairs(self._bigEventRd) do
		local recordinfo = {}
		recordinfo.time = record[1]
		recordinfo.id = record[2]
		recordinfo.params = {}
		for j=1, #record[3] do
			table.insert(recordinfo.params,record[3][j])
		end
		table.insert(ret.records,recordinfo)
	end
	fireProtoMessageBySid(dbid, FACTION_SC_GET_EVENT_RD_RET, "FactionGetEventRdRet", ret)
end

--加载军机处数据
function FactionManager:onloadFactionEvent(data)
	if data then
		self._bigEventRd = unserialize(data)
	end
end

function FactionManager:setMaxFactionID(factionid)
	if factionid>0 then 
		self._maxFactionID = factionid
	end
end

function FactionManager:getNewFactionID()
	self._maxFactionID = self._maxFactionID+1
	return self._maxFactionID
end

function FactionManager:onloadRemoveBuff(data)
	if data then
		self._offRemoveBuff = unserialize(data)
	end
end

function FactionManager:setFacTmpData(dbid, memBuffStr, cType, serverId, facName)
	self._createFacTmpData[dbid] = {memBuffStr=memBuffStr, cType=cType, serverId=serverId, facName = facName}
end

function FactionManager:clearFacTmpData(dbid)
	self._createFacTmpData[dbid] = nil
end

function FactionManager:getFacTmpData(dbid)
	return self._createFacTmpData[dbid]
end

--添加申请数据
function FactionManager:addApply(roleSID, factionID)
	self._applyInfo[roleSID] = self._applyInfo[roleSID] or {}
	local applies = self._applyInfo[roleSID]
	table.insert(applies, factionID, os.time())
end

--获取玩家的帮会申请列表
function FactionManager:getApplyInfo(roleID)
	return  self._applyInfo[roleID] or {}
end

--玩家有帮会以后清除所有申请记录
function FactionManager:deleteRoleApply(roleID)
	for facID, _ in pairs(self._applyInfo[roleID] or {}) do
		local fac = self:getFaction(facID)
		if fac then
			fac:removeApplyRole(roleID)
		end
	end

	self._applyInfo[roleID] = nil
end

--删除申请数据
function FactionManager:removeApply(roleSID, factionID)
	local applies = self._applyInfo[roleSID]
	if applies then
		applies[factionID] = nil
	end
end

function FactionManager:addFaction(faction,create)
	self.m_allFactions[faction:getFactionID()] = faction
	self.m_allFactionsByName[faction:getName()] = faction
	--排名
	faction:setRank(#self._factionRank + 1)	--排名滞后
	table.insert(self._factionRank, faction)

	--创建帮会驻点
	local scene = g_sceneMgr:createFacAreaScene(faction:getFactionID())
	g_InvadeMgr:createInvade(faction:getFactionID())

	--行会公共任务
	local factionTaskInfo = g_factionMgr:_getFactionTaskInfo(faction)
	if create == true then
		factionTaskInfo:reFreshTask()
	end
end

--otherFacID:玩家进入别的行会领地的行会ID
function FactionManager:enterFactionArea(roleSID, mapX, mapY, otherFacID)
	print(" FactionManager:enterFactionArea:"..mapX..","..mapY)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return false
	end

	--判断距离
	if not  isNearPos(player, 2100, 125, 125) then
		return
	end

	local faction = g_factionMgr:getFaction(player:getFactionID())

	if not faction then
		return false
	end

	--进自己的注定需要行会等级3级以上
	if not otherFacID then
		if faction:getLevel() < FACTION_AREA_NEED_LEVEL then
			FactionServlet.getInstance():sendErrMsg2Client(player:getID(), FACTION_PRAY_LEVEL_NOT_IN_AREA, 1, {FACTION_AREA_NEED_LEVEL})
			return false
		end
	end

	local factionID = 0
	if otherFacID then
		if otherFacID == player:getFactionID() then
			return false
		end
		factionID = otherFacID
	else
		g_InvadeMgr:enterFactionArea(roleSID)
		factionID = player:getFactionID()
		g_factionAreaManager:enterFactionArea(roleSID)
	end
	
	if factionID <= 0 then
		return false
	end
	
	if player:hasEffectState(EXIT_FACTION_SPECIAL) then
		FactionServlet.getInstance():sendErrMsg2Client(player:getID(), FACTION_PRAY_CAN_NOT_IN_AREA, 0)
		return false
	end
	
	local preMapID = player:getMapID()
	local publicPos = player:getPosition()

	if g_sceneMgr:enterFacAreaScene(factionID, player:getID(), mapX, mapY) then
		--玩家成功进入副本地图
		player:setLastMapID(preMapID)
		player:setLastPosX(publicPos.x)
		player:setLastPosY(publicPos.y)
		if otherFacID then
			self._enterOtherArea[roleSID] = otherFacID
		end
		player:setAreaFactionID(factionID)
		player:setPattern(ePattern_Faction)
		return true
	else
		return false
	end
end

function FactionManager:outFactionArea(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return false
	end

	
	--判断是否为进入别的行会领地
	if not self._enterOtherArea[roleSID] then
		g_InvadeMgr:outFactionArea(roleSID)		
	end

	--不在帮会据点
	if player:getMapID() ~= FACTION_AREA_MAP_ID then
		return false
	end

	local roleID = player:getID()
	local mapID = player:getLastMapID()
	local x = player:getLastPosX()
	local y = player:getLastPosY()
	if g_sceneMgr:posValidate(mapID, x, y) then
		g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
		player:setAreaFactionID(0)
	else
		--如果地图有问题就走出生点
		g_sceneMgr:enterPublicScene(roleID, 1100, 21, 100)
	end

	if self._enterOtherArea[roleSID] then
		g_factionInvadeMgr:outFactionArea(roleSID, self._enterOtherArea[roleSID])
		self._enterOtherArea[roleSID] = nil
	end
end

--玩家掉线
function FactionManager:onPlayerInactive(player)
	if player:getMapID() == FACTION_AREA_MAP_ID then
		self:outFactionArea(player:getSerialID())
	end
end

--获取所有的帮会
function FactionManager:getAllFactions()
	return self.m_allFactions or {}
end

function FactionManager:getFaction(factionID)
	if self.m_allFactions[factionID] then
		return self.m_allFactions[factionID]
	end
end

function FactionManager:getFactionByName(name)
	if self.m_allFactionsByName[name] then
		return self.m_allFactionsByName[name]
	end
end

function FactionManager:send2AllMem(factionID, buffer, isLeader)
	local faction = self:getFaction(factionID)

	if not faction then
		return
	end
	
	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		if v:getActiveState() then
			if isLeader then 
				if v:hasDroit(FACTION_DROIT.TakeInMember) then
					table.insert(allMem, v:getRoleSID())
				end
			else
				table.insert(allMem, v:getRoleSID())
			end
		end
	end

	g_frame:sendMsgToPeerGroupBySid(allMem, buffer)
end

function FactionManager:sendProtoMsg2AllMem(factionID, eventId, protoName, protoData, isLeader)
	local faction = self:getFaction(factionID)

	if not faction then
		return
	end
	
	local buffer = g_buffMgr:getLuaRPCEvent(eventId)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	if pb_str then
		buffer:pushPbc(pb_str, #pb_str)
		local st, err = protobuf.decode(protoName, pb_str)
		if not st then
			print('sendProtoMsg2AllMem decode error '..tostring(err))
			return
		end
		print("sendProtoMsg2AllMem",protoName,#pb_str)
	else
		print("FactionManager:sendProtoMsg2AllMem encode error! context: ", errorCode, factionID, eventId, protoName, toString(protoData))
		return
	end

	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		if v:getActiveState() then
			if isLeader then 
				if v:hasDroit(FACTION_DROIT.TakeInMember) then
					table.insert(allMem, v:getRoleSID())
				end
			else
				table.insert(allMem, v:getRoleSID())
			end
		end
	end

	g_frame:sendMsgToPeerGroupBySid(allMem, buffer)
end

--刷新界面
function FactionManager:freshUI(factionID, outRoleSID)
	local ret = {}
	ret.roleSID = outRoleSID or 0
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_FRESHUI, "FactionFreshUI", ret)
end

--创建帮会
--bForce强制创建帮会
function FactionManager:createFaction(player, facName, cType, hGate)
	print("FactionManager:createFaction name="..facName)
	local factionID = player:getFactionID()
	if factionID <= 0 then
		local f = string.find(facName, ' ') or string.find(facName, '&')
		if f then return false, FACERR_ILLEGAL_NAME end
		--判断等级
		if player:getLevel() < CREATE_FACTION_LEVEL then
			return false, FACERR_NEED_LEVEL
		end
		--判断名字长度
		--UTF-8汉字占3个字节
		local ansi = string.len(string.gsub(facName, "[\128-\254]+",""))
		local total = string.len(facName)

		if (ansi+(total-ansi)/3) > FACTION_NAME_LENTH then
		--if string.len(facName) > FACTION_NAME_LENTH then
			return false, FACERR_FACNAMETOOLONG
		end
		
		--判断模式
		if cType == CREATE_MODE.HornCreate then
			local itemMgr = player:getItemMgr()
			local horn = itemMgr:findItemByItemID(CREATE_HORNID)
			if not horn then
				return false, FACERR_NO_HORN
			end
			--有号角还要金币
			if not isMoneyEnough(player, CREATE_FACTION_MONEY) then
				return false, FACERR_NO_ENOUGH_MONEY
			end
		elseif cType == CREATE_MODE.MoneyCreate then
			if player:getIngot() < CREATE_FACTION_INGOT then
				return false, FACERR_NO_ENOUGH_INGOT
			end
		end
		
		local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_CREATEFACTION)
		retBuff:pushString(player:getSerialID())
		retBuff:pushInt(hGate)
		retBuff:pushInt(cType)
		retBuff:pushString(facName)
		retBuff:pushInt(player:getLevel())
		retBuff:pushString(player:getName())
		retBuff:pushInt(player:getSchool())
		retBuff:pushInt(player:getSex())
		retBuff:pushInt(player:getbattle())
		local itemMgr = player:getItemMgr()
		retBuff:pushInt(itemMgr:getWeaponID())
		retBuff:pushInt(itemMgr:getClothID())
		retBuff:pushInt(player:getCurWingID())
		g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, retBuff)

		return true, faction
	else
		return false, FACERR_HAS_FACTION
	end
end



--创建帮会返回
function FactionManager.onCreateFactionRet(roleSID, factionID, facName, leaderName)
	local tmpData = g_factionMgr:getFacTmpData(roleSID)
	local memStr = tmpData.memBuffStr
	local serverId = tmpData.serverId
	local cType = tmpData.cType

	local faction = Faction(roleSID)
	faction:setFactionID(factionID)
	faction:setName(facName)
	faction:setLeaderName(leaderName)
	faction:setCreateTime(os.time())
	local timeStamp = time.toedition("day")
	faction:setUpdateTime(timeStamp)
	faction:setCommandId(roleSID)

	local member = FactionMember(roleSID, 0)
	member:readString(memStr)
	member:setActiveState(0)
	faction:addFactionMember(member)
	faction:setLevel(1)

	FactionManager.getInstance():addFaction(faction,true)

	local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_CREATEFACTION2)
	retBuff:pushString(roleSID)
	retBuff:pushInt(factionID)
	retBuff:pushString(faction:getName())
	retBuff:pushInt(faction:getRank())
	retBuff:pushInt(cType)
	--Tlog[GuildFlow]
	retBuff:pushChar(faction:getLevel())
	retBuff:pushChar(faction:getAllMemberCnt())

	g_engine:fireWorldEvent(serverId, retBuff)

	g_factionMgr:clearFacTmpData(roleSID)

	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.createFaction, 1)
end

--创建帮会返回2
function FactionManager.onCreateFactionRet2(roleSID, factionID, serverId, cType)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_CREATEFACTION2)
		retBuff:pushString(roleSID)
		retBuff:pushInt(factionID)
		retBuff:pushString(faction:getName())
		retBuff:pushInt(faction:getRank())
		retBuff:pushInt(cType)
		--Tlog[GuildFlow]
		retBuff:pushChar(faction:getLevel())
		retBuff:pushChar(faction:getAllMemberCnt())

		g_engine:fireWorldEvent(serverId, retBuff)
	end
end

--加载帮会数据
function FactionManager.loadFaction(factionID, buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	local faction = Faction(roleSID)
	faction:setFactionID(factionID)
	faction:readString(luabuf)
	faction:setTotalAbility(0)	--战斗力
	FactionManager.getInstance():addFaction(faction)
end

--加载一个帮会的所有帮会成员
function FactionManager.loadFactionMember(factionID, memsStr, roleID)
	local faction = FactionManager.getInstance():getFaction(factionID)
	if not faction then return end 

	local member = FactionMember(roleID, 0)
	--local luabuf = tolua.cast(memsStr, "LuaMsgBuffer")
	member:readString(memsStr)
	member:setFactionID(factionID)
		
	local memPlayer = g_entityMgr:getPlayerBySID(member:getRoleSID())
	if memPlayer then
		memPlayer:setFactionID(factionID)
		member:setAbility(memPlayer:getbattle())
		member:setLevel(memPlayer:getLevel())
		member:setName(memPlayer:getName())
	end
	if member:getRoleSID() == faction:getLeaderID() and member:getPosition() ~= FACTION_POSITION.Leader then
		member:setPosition(FACTION_POSITION.Leader)
		faction:addUpdateMem(member:getRoleSID())
	end
	if member:getPosition() == FACTION_POSITION.AssociateLeader then
		faction:setAssLeaderID(member:getRoleSID())
		faction:setFactionSyn(true)
	end
	faction:addFactionMember(member, true)
end

--加载帮会日志
function FactionManager.loadFactionMsg()
	--到这里的时候，帮会所有数据都加载好了
	if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
		g_entityDao:loadShaWar()						--加载沙巴克数据
	end

	if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
		g_RankMgr._rank[RANK_TYPR.RANK_FACTION] = {}
		g_entityDao:loadRankData(RANK_TYPR.RANK_FACTION)
	end

	--先删掉帮会日志加载，至诚后面修改
end

--行会升级
function FactionManager:upFactionLevel(factionID)
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		print("怎么没有帮会", factionID)
		return
	end

	--达到最大等级了
	if faction:getLevel() >= g_luaFactionDAO:getMaxLevel() then
		print("FactionManager:upFactionLevel reach max level,err")
		return
	end

	local nextLevel = faction:getLevel() + 1
	faction:setLevel(nextLevel)
	faction:setBannerLvl(nextLevel)
	faction:setFactionSyn(true)

	
	local allFacMem = faction:getAllMembers()
	for k,mem in pairs(allFacMem) do
		g_normalMgr:factionLevelChange(mem:getRoleSID(), nextLevel)
	end
	
	--通知所有帮众
	local ret = {}
	ret.curLevel = faction:getLevel()
	ret.upType = FACTION_UPLEVEL
	ret.facXp = faction:getXp()
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_UPLEVEL_RET, "UpLevelFactionRet", ret)


	local allret = {}
	allret.eventId = EVENT_FACTION_SETS
	allret.eCode = FACTION_UPLEVEL
	allret.mesId = FACTION_CS_UPLEVEL
	allret.param = {}
	table.insert(allret.param, tostring(faction:getLevel()))
	g_factionMgr:sendProtoMsg2AllMem(factionID, FRAME_SC_MESSAGE, "FrameScMessageProtocol", allret)

	faction:addMsgRecord(FACTION_UPLEVEL, {tostring(faction:getLevel())}, {})
	g_factionMgr:addNewBigEvent(FACTION_EVENT_UP_FACTION, {faction:getName(), faction:getLevel()})

	--刷新行会入侵buff
	g_factionInvadeMgr:updateBuff(factionID)
end


function FactionManager:update()
	self:updateFactionRank()
	--更新帮会申请列表
	self:updateApplyInfo()
	self:updateCircleData()
	self:sysnAllData()

	--行会外交 状态更新
	for socialID, social in pairs(self._allFactionSocials) do
		social:update()
	end

	--行会公共任务 刷新
	for _, factionTask in pairs(self._allFactionTasks) do
		factionTask:update()
	end

	--离线离会BUFF
	local curTime = os.time()
	for sid, removeTime in pairs(self._offRemoveBuff) do
		if curTime - removeTime > 86400 then
			self._offRemoveBuff[sid] = nil
		end
	end
	--行会镖车
	local facDart = self._factionDart
	if facDart then 
		facDart:notify()
	end
end

--更新帮会申请列表
function FactionManager:updateApplyInfo()
	local nowTime = os.time()
	for roleSID, info in pairs(self._applyInfo) do
		for facID,aTime in pairs(info or {}) do
			if nowTime - aTime >= ONEDAY_SECOND then
				info[facID] = nil
				local faction = self:getFaction(facID)
				if faction then
					faction:removeApplyRole(roleSID)
					faction:setFactionSyn(true)
					--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE) 
					retBuff:pushShort(EVENT_FACTION_SETS)
					retBuff:pushShort(FACERR_APPLY_OUT_TIME)
					retBuff:pushShort(0)
					retBuff:pushChar(1)
					retBuff:pushString(faction:getName())
					g_engine:fireSerialEvent(roleSID, retBuff)
					]]--
					fireProtoSysMessageBySid(0, roleSID, EVENT_FACTION_SETS, FACERR_APPLY_OUT_TIME, 1, {faction:getName()})
				end
			end	
		end
	end
end

--更新周期数据
function FactionManager:updateCircleData()
	local nowTime = os.time()
	for facID, faction in pairs(self.m_allFactions) do
		local oldTime = faction:getUpdateTime()
		local timeStamp = time.toedition("day")
		if oldTime ~= timeStamp then
			--更新每日贡献
			local allMem = faction:getAllMembers()
			for sid, mem in pairs(allMem) do
				mem:setFireNum(FACTION_ADD_FIRE_TIMES)
				faction:addUpdateMem(sid)
				
			end
			--更新日志
			local msgRecords = faction:getMsgRecord()
			local size = #msgRecords
			local weekSec = ONEDAY_SECOND*7 
			--从后往前判断
			while size>0 do
				if nowTime - msgRecords[size][1] >= weekSec then
					--删除前size个记录
					for i=1, size do
						table.remove(msgRecords, 1)
					end
					faction:setRecordSyn(true)
					break
				else
					size = size-1
				end
			end

			faction:setUpdateTime(timeStamp)
		end
	end
end

--外部修改帮会数据接口
function FactionManager:modifyFacData(factionID, name, leaderID, level, bannerLevel, storeLevel, money)
	local faction = self:getFaction(factionID)

	if faction then
		if name and name ~= "" then
			faction:setName(name)
		end

		if leaderID and leaderID ~= 0 then
			faction:setLeaderID(leaderID)
		end

		if level and level ~= 0 then
			faction:setLevel(level)
		end

		if bannerLevel and bannerLevel ~= 0 then
			faction:setBannerLvl(bannerLevel)
		end

		if storeLevel and storeLevel ~= 0 then
			faction:setStoreLvl(1)
		end

		if money and money ~= 0 then
			faction:setMoney(money)
		end
		faction:setFactionSyn(true)
	end

	g_manorWarMgr:modifyManorFacData(factionID, name)
end
function FactionManager:delUniqueFacName(facID, facName)
	print("delUniqueFacName, facID=" .. facID..", name="..facName)
	local luabuf = g_buffMgr:getLuaEvent(NAME_WN_DELETE_NONPLAYER)
	luabuf:pushInt(NAME_TYPE_FACTION)
	luabuf:pushInt(facID)
	luabuf:pushString(facName)
	g_engine:fireSessionEvent(luabuf)
end
--解散帮会
function FactionManager:disbandFaction(faction)
	--print("解散帮会", debug.traceback())
	local factionID = faction:getFactionID()
	
	self:outFactionArea(faction:getLeaderID())
	--领地数据处理
	g_manorWarMgr:disbandFaction(factionID)
	--沙巴克处理
	g_shaWarMgr:disbandFaction(faction)

	--删除行会据点
	g_sceneMgr:deleteFacAreaScene(factionID)

	self.m_allFactions[factionID] = nil
	self.m_allFactionsByName[faction:getName()] = nil
	--[[local luaBuf = LuaEventManager:instance():getExchangeLuaBuffer()
	luaBuf:pushBool(false)
	luaBuf:pushInt(SPDEF_DELETEFACTION)	--更新沙巴克数据的存储过程ID
	luaBuf:pushString("_world")
	luaBuf:pushInt(g_frame:getWorldId())
	luaBuf:pushString("_factionID")
	luaBuf:pushInt(factionID)
	g_entityDao:callSpForLua(SPDEF_DELETEFACTION, luaBuf)]]
	self:delUniqueFacName(factionID, faction:getName())
	g_entityDao:deleteFaction(g_frame:getWorldId(),factionID)

	for i=1, #(self._factionRank or {}) do
		if self._factionRank[i]:getFactionID() == factionID then
			table.remove(self._factionRank, i)
			break
		end
	end
	
	--行会外交 删除行会外交
	for socialID, social in pairs(self._allFactionSocials) do
		if social:getAFactionID() == factionID or social:getBFactionID() == factionID then
			self._allFactionSocials[socialID] = nil
		end 
	end

	--行会外交详细信息更新
	self:disbandFactionSocialDetailInfo(factionID)

	--行会公共任务 删除行会公共任务
	local faciontTaskInfo = self._allFactionTasks[factionID]
	self._allFactionTasks[factionID] = nil
	if faciontTaskInfo then
		release(faciontTaskInfo)
	end
	
	--行会副本
	g_FactionCopyMgr:disbandFaction(factionID)

	g_RankMgr:onFactionDelete(factionID)

	os.remove("../ServerLog/Faction/"..tostring(factionID)..".txt")
end

function FactionManager.addContribution(roleSID, num)
	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		return
	end
	
	local facId = player:getFactionID() or 0 

	if facId <= 0 then
		return
	end

	local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_ADDCONTRIBUTION)
	retBuff:pushString(roleSID)
	retBuff:pushInt(facId)
	retBuff:pushInt(num)
	g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, retBuff)
end

function FactionManager:freshFactionBattle(factionID)
	local faction = self:getFaction(factionID)
	if not faction then
		return
	end

	local allMems = faction:getAllMembers()
	local totalBattle = 0
	for roleSID, mem in pairs(allMems) do
		totalBattle = totalBattle + mem:getAbility()
	end
	faction:setTotalAbility(totalBattle)
	faction:notifyFacRank()
end

--添加离会BUFF
function FactionManager:addExitBuff(player)
	local buffmgr = player:getBuffMgr()
	local eCode = 0
	if buffmgr:isExist(EXIT_FACTION_BUFFID) then
		buffmgr:delBuff(EXIT_FACTION_BUFFID)
	end
	local buff, eCode = buffmgr:addBuff(EXIT_FACTION_BUFFID, eCode)
end

--掉线登陆
function FactionManager:onActivePlayer(player)
	--暂时不转移到行会逻辑服务器处理 单GS
	if player:getFactionID() > 0 then
		local dbid = player:getSerialID()
		local factionID = player:getFactionID()
		self:synFactionPlayerUnionInfo(dbid, factionID)
		self:synFactionPlayerHostilityInfo(dbid, factionID)
	end
end

--玩家上线
--状态必须大于等于eEntityNormal才能添加帮会数据
function FactionManager:onPlayerLoaded(player)
	local roleSID = player:getSerialID()
	local removeTime = self._offRemoveBuff[roleSID] or 0
	if removeTime > 0 then
		--如果超过24小时就不处理了
		if os.time() - removeTime <= 86400 then
			self:addExitBuff(player)
		end
		self._offRemoveBuff[roleSID] = nil
		updateCommonData(COMMON_DATA_ID_OFFLINE_REMOVEFAC_BUFF, self._offRemoveBuff)
	end

	local factionID = player:getFactionID()
	--if factionID <= 0 then
	--	return
	--end

	--print('FactionManager:onPlayerLoaded',player:getSerialID(),player:getFactionID(),player:getFactionName())

	--切换到数据服处理
	local retBuff = LuaEventManager:instance():getWorldEvent(FACTION_SS_LOAD_PLAYER)
	retBuff:pushString(player:getSerialID())
	retBuff:pushInt(player:getLevel())
	retBuff:pushString(player:getName())
	retBuff:pushInt(factionID)
	g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, retBuff)
end

function FactionManager:onPlayerDelete(roleSID)
	local faction = nil
	for facID, fac in pairs(self.m_allFactions) do
		if fac:hasMember(roleSID) then
			faction = fac
		end
	end

	if not faction then
		return
	end

	local myMem = faction:getMember(roleSID)
	--帮会成员大于1，帮主不能退出帮会
	if myMem:getPosition() == FACTION_POSITION.Leader then
		if faction:getAllMemberCnt() > 1 then
			--找个继承人
			local nextLeaderID = faction:getAssLeaderID()
			if nextLeaderID <= 0 then
				local allMems = faction:getAllMembers()
				local maxBattle = 0
				for memSID, mem in pairs(allMems) do
					if mem:getPosition() ~= FACTION_POSITION.Leader and mem:getAbility() > maxBattle then
						nextLeaderID = memSID
						maxBattle = mem:getAbility()
					end
				end
			end

			--这个人当会长
			self:updateLeader(faction:getFactionID(), nextLeaderID)
		else
			g_factionMgr:disbandFaction(faction)
			return
		end
	end
	if myMem:getPosition() == FACTION_POSITION.AssociateLeader then
		faction:setAssLeaderID(0)
		faction:setFactionSyn(true)
	end

	faction:removeMember(roleSID)
	g_entityDao:updateFactionMember(roleSID,faction:getFactionID(),"", 0)
end

function FactionManager:updateLeader(factionID, leaderID)
	local faction = self:getFaction(factionID)
	if not faction then
		return
	end

	if factionID == g_shaWarMgr:getShaFactionId() then
		local oldLeader = g_entityMgr:getPlayerBySID(faction:getLeaderID())
		if oldLeader then
			local buffmgr = oldLeader:getBuffMgr()
			buffmgr:delBuff(SHAWAR_LEADER_BUFF)
			--强制下马
			g_rideMgr:offRide(oldLeader:getSerialID())

		end
	end

	local tMember = faction:getMember(leaderID)
	if tMember then
		tMember:setPosition(FACTION_POSITION.Leader)
		faction:setLeaderName(tMember:getName())
		faction:setLeaderID(leaderID)
		faction:addUpdateMem(leaderID)
		faction:setFactionSyn(true)
		self:NotifyPalyerFactionPosition(leaderID)
		g_factionMgr:freshUI(factionID)

		if factionID == g_manorWarMgr:getZhongzhouFacId() then
			--通知中州王和沙巴克王刷新
			local ret = {}
			ret.sex = tMember:getSex()
			ret.school = tMember:getSchool()
			ret.name = tMember:getName()
			boardProtoMessage(MANORWAR_SC_GET_LEADERINFO_RET, 'ManorGetLeaderInfoRetProtocol', ret)
		end
		
		if factionID == g_shaWarMgr:getShaFactionId() then
			ret = {}
			ret.sex = tMember:getSex()
			ret.school = tMember:getSchool()
			ret.name = tMember:getName()
			boardProtoMessage(SHAWAR_SC_GETLEADER_RET, 'ShaGetLeaderRetProtocol', ret)
		end
	end

	if factionID == g_shaWarMgr:getShaFactionId() then
		local leader = g_entityMgr:getPlayerBySID(faction:getLeaderID())
		if leader then
			local buffmgr = leader:getBuffMgr()
			buffmgr:addBuff(SHAWAR_LEADER_BUFF)
			--强制下马
			g_rideMgr:offRide(leader:getSerialID())
		end
	end
end

function FactionManager:onLevelChanged(player)
	local factionID = player:getFactionID()
	local faction = self:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(player:getSerialID ())
		if myMem then
			myMem:setLevel(player:getLevel())
		end
	end
end

function FactionManager:battleChanged(player, battle)
	local factionID = player:getFactionID()
	if factionID > 0 then
		local faction = self:getFaction(factionID)
		if faction then
			local myMem = faction:getMember(player:getSerialID())
			if myMem then
				local totalBattle = faction:getTotalAbility()
				totalBattle = totalBattle + battle - myMem:getAbility()
				faction:setTotalAbility(totalBattle)
				faction:notifyFacRank()
				myMem:setAbility(battle)
				faction:addUpdateMem(myMem:getRoleSID())
			end
		end
	end	
end

--玩家下线
function FactionManager:onPlayerOffLine(player)
	local factionID = player:getFactionID()
	if factionID <= 0 then
		return
	end
	if player:getMapID() == FACTION_AREA_MAP_ID then
		self:outFactionArea(player:getSerialID())
	end	
	local faction = self:getFaction(factionID)
	if faction then
		local myMem = faction:getMember(player:getSerialID())
		if myMem then
			myMem:setActiveState(os.time())
			myMem:update2DB(factionID)
		end
	end	
end

--更新排名
function FactionManager:updateFactionRank()
	if table.size(self._factionRank) > 0 then
		if os.time() - self._rankTime >= 1800 then
			table.sort(self._factionRank, function(a,b) return a:getTotalAbility() > b:getTotalAbility() end)
			local cnt = #self._factionRank
			for i=1, cnt do 
				self._factionRank[i]:setRank(i)
			end
			self._rankTime = os.time()
		end
	end
end

function FactionManager:clearCache(dbid)
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		g_entityMgr:deleteCache(dbid)--清除缓存，下次登入会读数据库
	end
end

--存储所有帮会数据
function FactionManager:sysnAllData()
	if os.time() - self._updateTime >= 10 then
		for facID, fac in pairs(self.m_allFactions) do
			if fac:getFactionSyn() then
				fac:update2DB()
				fac:setFactionSyn(false)
			end

			--帮会成员数据更新
			local updateMems = fac:getUpdateMems()
			for k,v in pairs(updateMems) do
				local tmpMem = fac:getMember(k)
				if tmpMem then 
					tmpMem:update2DB(facID)
				else
					print("---update factionmem err ", k, v, facID, toString(updateMems))
				end
			end
			fac:clearUpdateMems()
			--[[
			if fac:getRecordSyn() then
				local msgStr = fac:writeMsgString()	--帮会日志数据
				local fileName = tostring(facID)..".txt"
				local f = openFile("../ServerLog/Faction/"..fileName,"w+")
				if f then
					f:write(msgStr)
					f:close()
				else
					lfs.mkdir("../ServerLog")
					lfs.mkdir("../ServerLog/Faction")
					local f = openFile("../ServerLog/Faction/"..fileName,"w+")
					if f then
						f:write(msgStr)
						f:close()
					end
				end
				fac:setRecordSyn(false)
			end
			]]
		end
		self._updateTime = os.time()
	end
end

--清空捐献数据
function FactionManager:clearStatueData()
	self._addStatueRd = {}

	for facID, faction in pairs(self.m_allFactions) do
		if faction:getStatueNum() > 0 then
			faction:setStatueNum(0)
			faction:setStatueTime(0)
			faction:setFactionSyn(true)
		end
	end
end

--加载捐献记录
function FactionManager:onLoadStatueRdData(data)
	if data then
		if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
			self._addStatueRd = unserialize(data)
		end
	end
end

function FactionManager:addStatue(player, factionID, palyerName, addNum)
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then
		return
	end
		
	local dbId = player:getSerialID()
	local mem = faction:getMember(dbId)
	if mem then
		mem:setContribution(mem:getContribution() + addNum * FACTION_STATUE_SCALE)
		faction:addUpdateMem(dbId)
	end
	faction:setStatueNum(faction:getStatueNum() + addNum)
	faction:setStatueTime(os.time())
	faction:setFactionSyn(true)
	FactionServlet.getInstance():sendErrMsg2Client(player:getID(), FACERR_ADD_STATUE_SUCCESS, 1, {addNum * FACTION_STATUE_SCALE})


	--添加捐献记录
	local tb = {facName=faction:getName(), memName=palyerName, num=addNum, addTime = os.time()}
	table.insert(self._addStatueRd, tb)
    local tbNum = table.size(self._addStatueRd)
    --超过10条记录要删除多余的
    if tbNum > FACTION_STATUE_MAX_RD then
        table.remove(self._addStatueRd, 1)
    end
	updateCommonData(COMMON_DATA_ID_FACTION_STATUE_RD, self._addStatueRd)
	
	local ret = {}
	ret.addNum = addNum
	fireProtoMessage(player:getID(), FACTION_SC_ADDSTATUE_RET, 'FactionAddStatueRet', ret)
end

function FactionManager:getStatueRank(hGate, dbId)
	local tmpRd = {}
	for facID, faction in pairs(self.m_allFactions) do
		if faction:getStatueNum() > 0 then
			local tb = {facID=faction:getFactionID(), facName=faction:getName(), facLeaderName=faction:getLeaderName(), statueNum=faction:getStatueNum(),statueTime=faction:getStatueTime()}
			table.insert(tmpRd, tb)
		end
	end

	local sortFunc = function(a, b) 
		if a.statueNum ~= b.statueNum then
			return a.statueNum > b.statueNum
		else
			return a.statueTime < b.statueTime 
		end
	end
    table.sort(tmpRd, sortFunc)

	local ret = {}
	ret.shaFacId = g_shaWarMgr:getShaFactionId() or 0

	if ret.shaFacId > 0 then
		local shaFac = self:getFaction(ret.shaFacId)
		if shaFac then
			ret.shaFacName = shaFac:getName()
			ret.shaFacLeaderName = shaFac:getName()
		end
	end

	ret.zhongzhouFacId = g_manorWarMgr:getManorFacId(MANOR_MAINCITYWAR) or 0
	if ret.zhongzhouFacId > 0 then
		local zhongzhouFac = self:getFaction(ret.zhongzhouFacId)
		if zhongzhouFac then
			ret.zhongFacName = zhongzhouFac:getName()
			ret.zhongFacLeaderName = zhongzhouFac:getName()
		end
	end

	ret.rdData = {}

    for _,v in ipairs(tmpRd) do
		local info = {}
		info.facID = v.facID
		info.facName = v.facName
		info.facLeaderName = v.facLeaderName
		info.statueNum = v.statueNum
		table.insert(ret.rdData, info)
    end

	local player = g_entityMgr:getPlayerBySID(dbId)
	if player then
		fireProtoMessage(player:getID(), FACTION_SC_GETSTATUERANK_RET, 'FactionGetStatueRankRet', ret)
	end
end

function FactionManager:getStatueRd(hGate, dbId)
	--按时间排序
    local sortFunc = function(a, b) return a.addTime < b.addTime end
    table.sort(self._addStatueRd, sortFunc)
	
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_GETSTATUERD_RET)
	local rNum = table.size(self._addStatueRd)
    retBuff:pushChar(rNum)
    for _,v in ipairs(self._addStatueRd) do
        retBuff:pushString(v.facName)
        retBuff:pushString(v.memName)
		retBuff:pushInt(v.num)
        retBuff:pushInt(v.addTime)
    end
	g_engine:fireClientEvent(hGate, dbId, retBuff)
end

function FactionManager:getShaDefendFacId(factionID)
	local tmpRd = {}
	for facID, faction in pairs(self.m_allFactions) do
		if faction:getStatueNum() > 0 then
			local tb = {facID=faction:getFactionID(), facName=faction:getName(), facLevel=faction:getLevel(),statueNum=faction:getStatueNum(),statueTime=faction:getStatueTime()}
			table.insert(tmpRd, tb)
		end
	end

	local sortFunc = function(a, b) 
		if a.statueNum ~= b.statueNum then
			return a.statueNum > b.statueNum
		else
			return a.statueTime < b.statueTime 
		end
	end

    table.sort(tmpRd, sortFunc)

	local countNum = 0
	local retTb = {}
	for _,v in ipairs(tmpRd) do
		if not (factionID > 0 and v.facID == factionID) then
			table.insert(retTb, v.facID)
			countNum = countNum + 1
		end
		
		if countNum >= 3 then
			break
		end
	end
	return retTb
end


function FactionManager:addOffRemoveBuff(roleSID)
	self._offRemoveBuff[roleSID] = os.time()
	updateCommonData(COMMON_DATA_ID_OFFLINE_REMOVEFAC_BUFF, self._offRemoveBuff)
end

--------------------------------------------------------------行会外交---------------------------------------------------------------------
--获取所有的帮会外交信息
function FactionManager:getAllFactionSocial()
	return self._allFactionSocials or {}
end

--获取具体行会的外交信息 TODO:优化
function FactionManager:getFactionSocials(factionID)
	local socials = {}
	for _, facSocial in pairs(self._allFactionSocials) do
		if factionID == facSocial:getAFactionID() or factionID == facSocial:getBFactionID() then
			table.insert(socials,facSocial)
		end
	end
	return socials
end

--更新各个行会外交信息缓存
function FactionManager:_getFactionSocialDetailInfo(factionID,state)
	local factionSocialsDetail = self._allFactionSocialsDetail[factionID] or {}
	return factionSocialsDetail[state] or {}
end

function FactionManager:disbandFactionSocialDetailInfo(factionID)
	print("FactionManager:disbandFactionSocialDetailInfo",factionID)
	local ret = {}
	ret.factionID = factionID
	
	local factionSocialsDetail = self._allFactionSocialsDetail[factionID] or {}
	for state, factionIds in pairs(factionSocialsDetail) do
		for ofactionId, _ in pairs(factionIds) do
			local oFactionSocialState = self:getFactionSocialDetailInfo(ofactionId,state)
			oFactionSocialState[factionID] = nil
			print("FactionDisbandNotify",ofactionId,factionID)
			--给该行会的所有人广播 行会解散消息
			self:sendProtoMsg2AllMem(ofactionId, FACTION_SC_DISBAND_NOTIFY, "FactionDisbandNotify", ret)
		end
	end

	self._allFactionSocialsDetail[factionID] = nil
end

function FactionManager:getFactionSocialDetailInfo(factionID,state)
	if self._allFactionSocialsDetail[factionID] == nil then
		self._allFactionSocialsDetail[factionID] = {}
	end
	local factionSocialsDetail = self._allFactionSocialsDetail[factionID]

	if factionSocialsDetail[state] == nil then
		factionSocialsDetail[state] = {}
	end
	return factionSocialsDetail[state]
end

function FactionManager:updateSocialDetailInfo(aFactionID,bFactionID,curState,oldState)
	--缓存新状态
	if curState then
		local aFactionSocialState = self:getFactionSocialDetailInfo(aFactionID,curState)
		local bFactionSocialState = self:getFactionSocialDetailInfo(bFactionID,curState)
		aFactionSocialState[bFactionID] = true
		bFactionSocialState[aFactionID] = true
	end
	
	--删除旧状态
	if oldState then
		aFactionSocialState = self:getFactionSocialDetailInfo(aFactionID,oldState)
		bFactionSocialState = self:getFactionSocialDetailInfo(bFactionID,oldState)
		aFactionSocialState[bFactionID] = nil
		bFactionSocialState[aFactionID] = nil
	end
end

--同步玩家联盟行会信息
function FactionManager:synFactionPlayerUnionInfo(roleSID,factionID)
	local factionSocialState = {}
	if factionID ~= nil then
		factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Union)
	end
	
	local ret = {}
	ret.factionIDs = {}
	for facid, _ in pairs(factionSocialState) do
		--print('FactionManager:synFactionPlayerUnionInfo',roleSID,factionID,facid)
		table.insert(ret.factionIDs,facid)
	end
	fireProtoMessageBySid(roleSID, FACTION_SC_UNIONSOCIALR_RET, "FactionUnionSocialNotify", ret)
end

--同步玩家宣战行会信息
function FactionManager:synFactionPlayerHostilityInfo(roleSID,factionID)
	local factionSocialState = {}
	if factionID ~= nil then
		factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Hostility)
	end
	
	local ret = {}
	ret.factionIDs = {}
	for facid, _ in pairs(factionSocialState) do
		--print('FactionManager:synFactionPlayerHostilityInfo',roleSID,factionID,facid)
		table.insert(ret.factionIDs,facid)
	end
	fireProtoMessageBySid(roleSID, FACTION_SC_HOSTILITYSOCIALR_RET, "FactionHostilitySocialNotify", ret)
end

--同步成员联盟行会信息
function FactionManager:synFactionMemUnionInfo(factionID)
	local factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Union)
	local ret = {}
	ret.factionIDs = {}
	for facid, _ in pairs(factionSocialState) do
		--print('FactionManager:synFactionMemUnionInfo',factionID,facid)
		table.insert(ret.factionIDs,facid)
	end
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_UNIONSOCIALR_RET, "FactionUnionSocialNotify", ret)
end

--同步成员宣战行会信息
function FactionManager:synFactionMemHostilityInfo(factionID)
	local factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Hostility)
	local ret = {}
	ret.factionIDs = {}
	for facid, _ in pairs(factionSocialState) do
		--print('FactionManager:synFactionMemHostilityInfo',factionID,facid)
		table.insert(ret.factionIDs,facid)
	end
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_HOSTILITYSOCIALR_RET, "FactionHostilitySocialNotify", ret)
end

--获取所有联盟行会列表
function FactionManager:getUnionFacList(factionID)
	local retTB = {}
	local factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Union)
	for facid, _ in pairs(factionSocialState) do
		table.insert(retTB, facid)
	end
	
	return retTB
end

--获取所有敌对行会列表
function FactionManager:getHostilityFacList(factionID)
	local retTB = {}
	local factionSocialState = self:_getFactionSocialDetailInfo(factionID,SocialState.Hostility)
	for facid, _ in pairs(factionSocialState) do
		table.insert(retTB, facid)
	end
	
	return retTB
end

--获取具体行会之间的外交信息
function FactionManager:getFactionSocial(aFactionID,bFactionID)
	local socialID = FactionSocial.GetUniqueID(aFactionID,bFactionID)
	if self._allFactionSocials[socialID] == nil then
		self._allFactionSocials[socialID] = FactionSocial(aFactionID,bFactionID)
	end
	return self._allFactionSocials[socialID]
end

function FactionManager:addFactionSocial(socialID, aFactionID, bFactionID, state, opRoleSID, opFactionID, opTime, aFactionOpTime,bFactionOpTime)
	if self._allFactionSocials[socialID] == nil then
		self._allFactionSocials[socialID] = FactionSocial(aFactionID,bFactionID)
	end
	local social = self._allFactionSocials[socialID]
	social:onUpdateState(state,opRoleSID,opFactionID,opTime,aFactionOpTime,bFactionOpTime)

	--更新具体行会的详细外交信息
	self:updateSocialDetailInfo(aFactionID,bFactionID,state)
end

function FactionManager:_getFactionSocial(socialID)
	return self._allFactionSocials[socialID]
end

--行会外交数据载入
function FactionManager.onLoadFactionSocial(luaBuf)
	local buff = tolua.cast(luaBuf, "LuaMsgBuffer")
	num = buff:popInt()
	
	print("FactionManager.onLoadFactionSocial totalnum", num)
	if num < 1 then
		return
	end

	for i = 1, num do
		local socialID = buff:popString()
		local aFactionID = buff:popInt()
		local bFactionID = buff:popInt()
		local state = buff:popInt()
		local opRoleSID = buff:popString()
		local opFactionID = buff:popInt()
		local opTime = buff:popInt()
		local aFactionOpTime = buff:popInt()
		local bFactionOpTime = buff:popInt()

		--print("FactionManager.onLoadFactionSocial record", socialID, aFactionID, bFactionID, state, opRoleSID, opFactionID, opTime, aFactionOpTime, bFactionOpTime)
		g_factionMgr:addFactionSocial(socialID, aFactionID, bFactionID, state, opRoleSID, opFactionID, opTime, aFactionOpTime,bFactionOpTime)
	end
end

--行会外交 以邮件方式回退道具
function FactionManager:returnItemByEmail(roleSID,itemID,itemNum,emailID,source,notifyid,reason)
	print("FactionManager:returnItemByEmail",roleSID,itemID,itemNum,reason)
	--local player = g_entityMgr:getPlayerBySID(roleSID)

	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setDescId(emailID)
	email:insertProto(itemID, itemNum, true)
	offlineMgr:recvEamil(roleSID, email, source, 0)

	--日志 通知
	local msg = LuaEventManager:instance():getLuaRPCEvent(notifyid)
	g_engine:fireSerialEvent(roleSID, msg)
end

--行会外交操作请求 (检查物品 提前收取道具)
function FactionManager:reqFactionSocialOperator(roleSID,op,srcFactionID,dstFactionID)
	--print("FactionManager:reqFactionSocialOperator",roleSID,op,srcFactionID,dstFactionID)
	
	--自己对自己操作
	if srcFactionID == dstFactionID then
		return SocialOperatorError_InvalidFID
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	--角色有效性检测
	if not player or player:getFactionID() ~= srcFactionID then
		return SocialOperatorError_InvalidRSID
	end
	
	--一些本GS的预处理操作 收物品
	if op == SocialOperator.ApplyUnion then			--申请联盟
		--检查数量
		if not isMatEnough(player, ApplyUnionItemID, ApplyUnionItemNum) then
			return ApplyUnionError_NoItem
		end
		
		--收取道具
		costMat(player, ApplyUnionItemID, ApplyUnionItemNum, SocialOperatorItemLogSource, 1)
		--print("FactionManager:reqFactionSocialOperator destoryItem",roleSID,ApplyUnionItemID,num,ApplyUnionItemNum)

	elseif op == SocialOperator.ApplyHostility then		--宣战
		--检查数量
		if not isMatEnough(player, ApplyHostilityItemID, ApplyHostilityItemNum) then
			return ApplyHostilityError_NoItem
		end
		
		--收取道具
		costMat(player, ApplyHostilityItemID, ApplyHostilityItemNum, SocialOperatorItemLogSource, 1)
		--print("FactionManager:reqFactionSocialOperator destoryItem",roleSID,ApplyHostilityItemID,num,ApplyHostilityItemNum)
	end

	return SocialOperator_Success
end

--行会外交操作失败
function FactionManager:factionSocialOperatorFail(roleSID,operator,srcFactionID,dstFactionID)
	--print("FactionManager:factionSocialOperatorFail",roleSID,operator,srcFactionID,dstFactionID)

	--退回道具
	if operator == SocialOperator.ApplyUnion then							--申请联盟
		g_factionMgr:returnItemByEmail(roleSID,ApplyUnionItemID,ApplyUnionItemNum,SocialItemEmail1,SocialOperatorItemLogSource,FACTION_SC_SOCIALRETURNITEM,'ApplyUnionFail')
	elseif operator == SocialOperator.ApplyHostility then						--宣战
		g_factionMgr:returnItemByEmail(roleSID,ApplyHostilityItemID,ApplyHostilityItemNum,SocialItemEmail2,SocialOperatorItemLogSource,FACTION_SC_SOCIALRETURNITEM,'ApplyHostilityFail')
	end
end

--行会外交数据库更新结果返回
function FactionManager.onUpdateSocialCallBack(socialID,operator,res)
	--print("FactionManager:onUpdateSocialCallBack",socialID,operator,res)

	--异步回调有效性检测
	local social = g_factionMgr:_getFactionSocial(socialID)
	if not social then
		print("FactionManager:onUpdateSocialCallBack invalid socialID",socialID)
		return
	end

	if social:getAsynOp() ~= operator then
		print("FactionManager:onUpdateSocialCallBack invalid operator",socialID,operator,social:getAsynOp())
		return
	end
	
	local opRoleSID = social:getAsynOpRoleSID()
	local opFactionID = social:getAsynOpFactionID()
	local srcFactionID = opFactionID > 0 and opFactionID or social:getAFactionID()			--默认的发起方
	local dstFactionID = social:getDstFactionID(srcFactionID)
	
	local srcfaction = g_factionMgr:getFaction(srcFactionID)
	local dstfaction = g_factionMgr:getFaction(dstFactionID)

	if not srcfaction or not dstfaction then
		print("FactionManager:onUpdateSocialCallBack invalid factionid",socialID,srcFactionID,dstFactionID)
		return
	end

	--数据库操作失败
	if res ~= 0 then
		print("FactionManager:onUpdateSocialCallBack return false",res)
		g_factionMgr:factionSocialOperatorFail(opRoleSID,operator,srcFactionID,dstFactionID)
		social:resetAsynOpContext()
		return
	end
	
	--数据库操作成功
	--local buff = tolua.cast(luaBuf, "LuaMsgBuffer")
	--local resocialID = buff:popString()
	--local reaFactionID = buff:popInt()
	--local rebFactionID = buff:popInt()
	--local restate = buff:popInt()
	--local reopRoleSID = buff:popInt()
	--local reopFactionID = buff:popInt()
	--local reopTime = buff:popInt()
	--local reaFactionOpTime = buff:popInt()
	--local rebFactionOpTime = buff:popInt()
	
	local restate = social:getAsynOpState()
	local reopTime = social:getAsynOpTime()
	local reaFactionOpTime = social:getAsynOpAFactionOpTime()
	local rebFactionOpTime = social:getAsynOpBFactionOpTime()

	--更新具体行会的详细外交信息
	g_factionMgr:updateSocialDetailInfo(srcFactionID,dstFactionID,restate,social:getState())

	--一些额外的通知操作
	if operator == SocialOperator.ApplyUnion then							--申请联盟
		--通知目标行会的会长和副会长
		local msg = LuaEventManager:instance():getLuaRPCEvent(FACTION_SC_SOCIALAPPLYUNION)
		local leader1 = dstfaction:getLeaderID()
		local leader2 = dstfaction:getAssLeaderID()
		g_engine:fireSerialEvent(leader1, msg)
		g_engine:fireSerialEvent(leader2, msg)
	elseif operator == SocialOperator.ApplyHostility then						--宣战成功
		local srcFacName = srcfaction:getName()
		local dstFacName = dstfaction:getName()
		g_ChatSystem:SystemMsgIntoChat(0,2,"",EVENT_PUSH_MESSAGE,74,2,{srcFacName,dstFacName})
		--同步行会玩家宣战行会信息
		g_factionMgr:synFactionMemHostilityInfo(srcFactionID)
		g_factionMgr:synFactionMemHostilityInfo(dstFactionID)
		g_factionMgr:addNewBigEvent(FACTION_EVENT_HOSTILITY, {srcFacName, dstFacName})
	elseif operator == SocialOperator.RefuseUnion then						--拒绝联盟
		--退回道具 给申请人
		g_factionMgr:returnItemByEmail(social:getOpRoleSID(),ApplyUnionItemID,ApplyUnionItemNum,SocialItemEmail1,SocialOperatorItemLogSource,FACTION_SC_SOCIALRETURNITEM,'RefuseUnion')
	elseif operator == SocialOperator.AcceptUnion or operator == SocialOperator.StopUnion then	--接受联盟  --终止联盟
		--同步行会玩家联盟行会信息
		g_factionMgr:synFactionMemUnionInfo(srcFactionID)
		g_factionMgr:synFactionMemUnionInfo(dstFactionID)
		if operator == SocialOperator.AcceptUnion then
			g_factionMgr:addNewBigEvent(FACTION_EVENT_UNION, {srcfaction:getName(), dstfaction:getName()})
		end
	end
	
	--更新缓存
	social:onUpdateState(restate,opRoleSID,opFactionID,reopTime,reaFactionOpTime,rebFactionOpTime)

	--全服公告
	local ret = {}
	local srcFacName = srcfaction:getName()
	local dstFacName = dstfaction:getName()
	--操作类型
	ret.opType = operator
	--双方行会名
	ret.srcFactionName = srcFacName
	ret.dstFactionName = dstFacName
	--双方行会ID
	ret.srcFactionID = srcFactionID
	ret.dstFactionID = dstFactionID
	boardProtoMessage(FACTION_SC_SOCIALOPERATOR_SUC, "FactionSocialOperatorSuc", ret)
	--g_engine:broadWorldEvent(retBuff)
	--print('ret FACTION_SC_SOCIALOPERATOR_SUC',operator)
end

--行会外交操作
function FactionManager:doFactionSocialOperator(roleSID,operator,srcFactionID,dstFactionID)
	--print("FactionManager:doFactionSocialOperator1",roleSID,operator,srcFactionID,dstFactionID)

	local srcfaction = self:getFaction(srcFactionID)
	local dstfaction = self:getFaction(dstFactionID)

	if not srcfaction or not dstfaction then
		return SocialOperatorError_InvalidFID
	end
	
	--角色有效性检测 只有会长和副会长才能操作
	local myMem = srcfaction:getMember(roleSID)
	if not myMem  or (myMem:getPosition() ~= FACTION_POSITION.Leader and myMem:getPosition() ~= FACTION_POSITION.AssociateLeader) then
		return SocialOperatorError_NoRight
	end
	
	--获取外交关系
	local social = self:getFactionSocial(srcFactionID,dstFactionID)
	
	--进行操作
	return social:doOperator(operator,roleSID,srcFactionID)
end

--获取行会外交状态
function FactionManager.getFactionSocialState(aFactionID,bFactionID)
	--print("FactionManager.getFactionSocialState",aFactionID,bFactionID)
	local socialID = FactionSocial.GetUniqueID(aFactionID,bFactionID)
	local social = g_factionMgr:_getFactionSocial(socialID)
	if social then
		return social:getState()
	end
	return SocialState.Neutral
end

-------------行会祈福-------------
--行会祈福扣元宝操作回调
function FactionManager.DoYuanBaoFactionPray(roleSID, ret, money, itemId, itemCount, callBackContext)
	print("FactionManager.DoYuanBaoFactionPray", roleSID, ret, money, itemId, itemCount, callBackContext)
	local prayContext = unserialize(callBackContext)
	local prayType = prayContext.prayType
	
	--检查玩家的有效性
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("FactionManager.DoYuanBaoFactionPray player not online")
		return TPAY_FAILED
	end
	
	local retCode = g_factionMgr:YuanBaoFactionPray(player, ret, money, prayType)
	local ret = {}
	--操作返回值
	ret.retCode = retCode
	--操作上下文
	ret.prayType = prayType
	fireProtoMessageBySid(roleSID, FACTION_SC_PRAY_RET, "FactionPrayRet", ret)

	if retCode == FactionPray_Success then
		return TPAY_SUCESS
	else
		return TPAY_FAILED
	end
end

function FactionManager:YuanBaoFactionPray(player, ret, money, prayType)
	if ret ~= 0 then
		return FactionPrayError_InBusy
	end

	local roleSID = player:getSerialID()
	local factionID = player:getFactionID()
	if factionID <= 0 then
		return FactionPrayError_NoFaction
	end

	--行会的有效性检测
	local faction = self:getFaction(factionID)
	if not faction then
		return FactionPrayError_NoFaction
	end

	local facMem = faction:getMember(roleSID)
	if not facMem then 
		return FactionPrayError_NoFaction
	end
	
	if player:hasEffectState(EXIT_FACTION_SPECIAL) then
		return FactionPrayError_LeaveBuff
	end

	--祈福类型的有效性
	local contriData = CONTRIBUTION_DATA[prayType]
	if prayType ~= FactionPrayType.Ingot or contriData == nil then
		return FactionPray_InvalidType
	end
	
	local money = contriData.needIngot

	--增加祈福次数
	facMem:addDayPrayCount(prayType)
	g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.SHANGXIANG, 1)  --行会上香

	--提示
	FactionServlet.getInstance():sendErrMsg2Client(player:getID(), FACTION_PRAY_SUC, 2, {contriData.facXp,contriData.conbri})
	--给奖励
	--添加数据库捐献记录
	--g_entityDao:addFacContriRd(faction:getFactionID(), roleSID, faction:getMoney(), addMon)
	faction:addXp(contriData.facXp)
	facMem:setContribution(facMem:getContribution() + contriData.conbri)
	
	--行会日志 见闻
	print("pray faction:addMsgRecord")
	faction:addMsgRecord(FactionPrayMsgID, {player:getName(), tostring(prayType), tostring(contriData.conbri), tostring(contriData.facXp)}, {{roleSID, player:getName()}, })
	
	faction:setFactionSyn(true)
	faction:addUpdateMem(roleSID)
	
	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.factionPray, 1)
	
	--祈福成功行会通知
	local ret = {}
	ret.prayType = prayType
	ret.roleName = player:getName()
	ret.facXp = faction:getXp()
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_PRAY_SUC, "FactionPrayNotify", ret)

	--print('ret FACTION_SC_PRAY_SUC',prayType)

	--通知捐献者
	local ret = {}
	ret.roleSID = facMem:getRoleSID()
	ret.contribution = facMem:getContribution()
	ret.facXp = faction:getXp()
	fireProtoMessageBySid(roleSID, FACTION_SC_CONTRIBUTE_RET, "FactionContributeRet", ret)

	--扣元宝成功
	g_PayRecord:Record(player:getID(), -money, CURRENCY_INGOT, 7)

	--添加数据库捐献记录
	g_entityDao:addFacContriRd(faction:getFactionID(), roleSID, faction:getXp(), contriData.facXp)
	--充值成就
	g_achieveSer:costIngot(player:getID(), money)
	return FactionPray_Success
end

function FactionManager:FactionPray(roleSID,prayType)
	--检查玩家的有效性
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return FactionPrayError_InvalidRSID
	end

	local factionID = player:getFactionID()

	local faction = self:getFaction(factionID)
	if not faction then
		return FactionPrayError_NoFaction
	end

	local facMem = faction:getMember(roleSID)
	if not facMem then 
		return FactionPrayError_NoFaction
	end

	if player:hasEffectState(EXIT_FACTION_SPECIAL) then
		return FactionPrayError_LeaveBuff
	end

	--祈福类型的有效性
	local contriData = CONTRIBUTION_DATA[prayType]
	if prayType ~= FactionPrayType.Free and prayType ~= FactionPrayType.Ingot  or contriData == nil then
		return FactionPray_InvalidType
	end
	
	--当天次数检测 累加
	local dayLimit = contriData.num
	if dayLimit then
		local oldcount = facMem:_getDayPrayCount(prayType)
		local curcount = facMem:getDayPrayCount(prayType)
		if dayLimit <= curcount then
			if oldcount ~= curcount then
				faction:addUpdateMem(roleSID)
			end
			return FactionPrayError_NoTimes
		end
	end

	--金币 元宝检测
	if prayType == FactionPrayType.Ingot  then		--元宝
		if FactionPrayYBTest == true then
			--消耗绑定元宝
			if player:getBindIngot() >= contriData.needIngot then
				player:setBindIngot(player:getBindIngot() - contriData.needIngot)
				g_logManager:writeMoneyChange(player:getSerialID(), '0', 4, FactionPrayLogSource, player:getBindIngot(), contriData.needIngot, 2)
				facMem:addDayPrayCount(prayType)
				g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.SHANGXIANG, 1)  --行会上香
			else
				--没有足够的绑定元宝 
				--return FactionPrayError_NoBindIngot
				return FactionPrayError_NoIngot
			end
		else
			if isIngotEnough(player, contriData.needIngot) then
				--costIngot(player, contriData.needIngot, FactionPrayLogSource)

				--g_PayRecord:Record(player:getID(), -contriData.needIngot, CURRENCY_INGOT, 7)
				--充值成就
				--g_achieveSer:costIngot(player:getID(), contriData.needIngot)

				--请求扣元宝
				local prayContext = {prayType = prayType}
				local ret = g_tPayMgr:TPayScriptUseMoney(player, contriData.needIngot, FactionPrayLogSource, "", 0, 0, "FactionManager.DoYuanBaoFactionPray", serialize(prayContext)) 
				if ret ~= 0 then
					return FactionPrayError_InBusy
				else
					return FactionPray_Success
				end
			else
				--没有足够的元宝 
				return FactionPrayError_NoIngot
			end
		end
	elseif prayType == FactionPrayType.Free then
		--增加祈福次数
		facMem:addDayPrayCount(prayType)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.SHANGXIANG, 1)  --行会上香
	end


	--提示
	FactionServlet.getInstance():sendErrMsg2Client(player:getID(), FACTION_PRAY_SUC, 2, {contriData.facXp,contriData.conbri})
	--添加数据库捐献记录
	g_entityDao:addFacContriRd(faction:getFactionID(), roleSID, faction:getXp(), contriData.facXp)
	faction:addXp(contriData.facXp)
	facMem:setContribution(facMem:getContribution() + contriData.conbri)
	
	--行会日志 见闻
	print("pray faction:addMsgRecord")
	faction:addMsgRecord(FactionPrayMsgID, {player:getName(), tostring(prayType), tostring(contriData.conbri), tostring(contriData.facXp)}, {{roleSID, player:getName()}, })
	
	faction:setFactionSyn(true)
	faction:addUpdateMem(roleSID)

	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.factionPray, 1)
	
	--祈福成功行会通知
	local ret = {}
	ret.prayType = prayType
	ret.roleName = player:getName()
	ret.facXp = faction:getXp()
	g_factionMgr:sendProtoMsg2AllMem(factionID, FACTION_SC_PRAY_SUC, "FactionPrayNotify", ret)

	--print('ret FACTION_SC_PRAY_SUC',prayType)

	--通知捐献者
	local ret = {}
	ret.roleSID = facMem:getRoleSID()
	ret.contribution = facMem:getContribution()
	ret.facXp = faction:getXp()
	fireProtoMessageBySid(roleSID, FACTION_SC_CONTRIBUTE_RET, "FactionContributeRet", ret)
	
	local ret = {}
	--操作返回值
	ret.retCode = FactionPray_Success
	--操作上下文
	ret.prayType = prayType
	fireProtoMessageBySid(roleSID, FACTION_SC_PRAY_RET, "FactionPrayRet", ret)
	return FactionPray_Success
end

------------------------------------------------------------------行会任务--------------------------------------------------------------------------
--获取行会任务管理器
function FactionManager:getFactionTaskInfo(factionID)
	return self._allFactionTasks[factionID]
end

function FactionManager:_getFactionTaskInfo(faction)
	local factionID = faction:getFactionID()
	if not self._allFactionTasks[factionID] then
		self._allFactionTasks[factionID] = FactionTaskInfo(faction)
	end
	return self._allFactionTasks[factionID]
end

--行会公共任务载入
function FactionManager.onLoadFactionTask(factionID,strfactionTask)
	--print("FactionManager.onLoadFactionTask", factionID, #strfactionTask)
	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local factionTaskInfo = g_factionMgr:_getFactionTaskInfo(faction)
		factionTaskInfo:loaddb(strfactionTask,FACTIONTASK_DBDATAS_FMT)
	end
end

--获取行会任务事件监听器
function FactionManager:getTaskEventHandler(factionID)
	local factionTaskInfo = self:getFactionTaskInfo(factionID)
	if factionTaskInfo then
		return factionTaskInfo:getTaskEventSet()
	end
	return nil
end

--通知观察该事件的任务目标
--本GS触发通知
function FactionManager:NotifyListener(player, eventName, ...)
	if not player or player:getFactionID() == 0 then 
		return
	end
	
	--local t = {}
	--for i = 1, select("#", ...) do
	--	table.insert(t, select(i, ...))
	--end

	if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
		if player:hasEffectState(EXIT_FACTION_SPECIAL) then
			return
		end
		local eventHandler = self:getTaskEventHandler(player:getFactionID())
		if eventHandler then
			local ret = false
			ret = eventHandler:notifyWatchers(eventName, player, ...)
			--print("FactionManager:NotifyListener ", eventName, ret)
			if ret == true then
				local factionTaskInfo = self:getFactionTaskInfo(player:getFactionID())
				if factionTaskInfo then
					factionTaskInfo:addJoinMem(player:getSerialID())
				end
			end
		end
	end
end

--行会GS处理触发通知
--function FactionManager:doNotifyListener(player, eventName, ...)
--	if not player then return end
--	local eventHandler = self:GetTaskEventHandler(player:getID())
--	if eventHandler then
--		eventHandler:notifyWatchers(eventName, player, ...)
--	end				
--end

function FactionManager:NotifyPalyerFactionPosition(dbid)
	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if cPlayer then
		local nPosition = 0
		local ret = {}
		local cFaction = g_factionMgr:getFaction(cPlayer:getFactionID());
		if cFaction then
			local cMember = cFaction:getMember(dbid);
			if cMember then
				nPosition = cMember:getPosition();
			end
			ret.nCommandId = cFaction:getCommandId();

			--cFaction:setCommandId(9999999)
			--cFaction:setFactionSyn(true)
		end

		ret.position = nPosition
		ret.dwHasVoiceRoom = 0;
		local fvInfo = self:getFactionVoiceInfo(cPlayer:getFactionID());
		if fvInfo then
			g_tFactionVoiceMgr:CheckVoiceRoomIsExist(dbid,cPlayer:getFactionID(),fvInfo[1],fvInfo[2],fvInfo[3],2);
			ret.dwHasVoiceRoom = 1;
		end 

		

		--print("-----commandid----"..ret.nCommandId)



		--print("--FactionInviteNotify--"..tostring(ret.dwHasVoiceRoom))
		--g_engine:fireLuaEvent(cPlayer:getID(),retBuff)
		fireProtoMessage(cPlayer:getID(), FACTION_SC_INVITE_NOTIFY_FACTIONINFO, "FactionInviteNotify", ret)
		--print("send faction ",nPosition)
	end
end

--------------------------------------------------------
----- 行会镖车 监听

function FactionManager:onFacDart()
	if not self._factionDart then 
		self._factionDart = FactionDart()
	end
end

function FactionManager:offFacDart( )
	local facDart = self._factionDart
	if not facDart then 
		return 
	end
	g_normalLimitMgr:sendErrMsg2Client(100,0,{})
	local curFactionOwner = facDart._curFactionOwner
	local itemOldFacID = facDart._itemOldFacID
	local dropItem = facDart
	for i,v in pairs(curFactionOwner) do
		local player = g_entityMgr:getPlayerBySID(v.roleSID)
		if player then
			local factionID = player:getFactionID()
			local faction = g_factionMgr:getFaction(factionID)
			player:deleteShowItems()
		end
	end
	for i,v in pairs(itemOldFacID) do
		self:writeTlog(v, 2, 0)

		facDart:sendBaseReward(i)
	end
	
	self._factionDart = nil

	local scene = g_sceneMgr:getPublicScene(4100)
	if scene then
		for i = 6200052, 6200058 do
			scene:removeMpws(i)
		end
	end
end

--头顶显示物品
function FactionManager:onShowDropItem(player, itemID)
	print("FactionManager:onShowDropItem")
	print(player:getSerialID(),itemID)
	local factionDart = self._factionDart
	if factionDart and factionDart._dropItem[itemID] then 
		factionDart:pickUp(player,itemID)
	elseif itemID >= 6200052 and itemID <= 6200058 then 
		player:deleteShowItems()
	end
end

--掉落头顶物品
function FactionManager:onDropShowItems(player, itemID)
	print("FactionManager:onDropShowItems")
	print(player:getSerialID(),itemID)
	local factionDart = self._factionDart
	if factionDart and factionDart._curFactionOwner[itemID] then 
		factionDart:drop(player, itemID)
	end
end

function FactionManager:sendEmail(roleSID,emailConfigId,itemID,itemNum,Params)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	local emailConfigId = emailConfigId
	email:setDescId(emailConfigId)
	if itemID then 
		email:insertProto(itemID, itemNum, true)
	end
	if Params then 
		email:insertParam(tostring(Params))
	end
	offlineMgr:recvEamil(roleSID, email, 41, 0)
end


function FactionManager:setFacionVoiceInfo(nFactionId,strBuff)
	local req, err = protobuf.decode("FactionVoiceRoomInfo" , strBuff)
	if not req then
		print('FactionManager:setFacionVoiceInfo '..tostring(err))
		return
	end
	print("--"..req.gid.."--"..req.roomid.."--"..req.roomkey.."--"..tostring(req.user_openid).."--"..req.uuid.."--"..tostring(req.business_id))
	self._factinonVoice[nFactionId] = {req.gid,req.roomid,req.roomkey,req.user_openid,req.uuid,req.business_id}
end

function FactionManager:getFactionVoiceInfo(nFactionId)
	return self._factinonVoice[nFactionId]
end

function FactionManager:clearFactionVoiceInfo(nFactionId)
	self._factinonVoice[nFactionId] = nil
end

--传出行会驻地设置玩家普通模式
function FactionManager:onSwitchScene(player, mapID)
	print('FactionManager:onSwitchScene() ', mapID)
	if not player then
		warning('not find player ')
		return
	end

	if player:getAreaFactionID() > 0 and mapID ~= FACTION_AREA_MAP_ID then
		print('FactionManager:onSwitchScene->', ePattern_Normal)
		player:setAreaFactionID(0)
		player:setPattern(ePattern_Normal)
		g_factionAreaManager:outFactionArea(player:getSerialID())
		local roleSID = player:getSerialID()
		if self._enterOtherArea[roleSID] then
			self._enterOtherArea[roleSID] = nil
		end
	end
end

--行会活动邮件通知
function FactionManager:notifyAllMemByEmail(factionID, factionHDID, ...)
	print("FactionManager:notifyAllMemByEmail1", factionID, factionHDID)
	local faction = self:getFaction(factionID)
	local emailConfigId = FactionNotifyEmail[factionHDID]
	if faction and emailConfigId then
		print("FactionManager:notifyAllMemByEmail", factionID, emailConfigId)
		local allMems = faction:getAllMembers()
		for roleSID, mem in pairs(allMems) do
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			email:setDescId(emailConfigId)

			--参数
			for i = 1, select("#", ...) do
				local value = select(i, ...)
				email:insertParam(tostring(value))
			end
			offlineMgr:recvEamil(roleSID, email, FactionNotifyEmailSource, 0)
		end
	end
end

function FactionManager.getInstance()
	return FactionManager()
end

g_factionMgr = FactionManager.getInstance()