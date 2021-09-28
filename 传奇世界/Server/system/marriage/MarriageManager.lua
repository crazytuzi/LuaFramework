--MarriageManager.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageManager.lua
 --* Author:  goddard
 --* Modified: 2016年8月11日
 --* Purpose: 婚姻管理器
 -------------------------------------------------------------------*/

require ("system.marriage.MarriageServlet")
require ("system.marriage.MarriageInfo")
require ("system.marriage.MarriageConstant")

--全局对象定义
g_marriageServlet = MarriageServlet.getInstance()

MarriageManager = class(nil, Singleton)

function MarriageManager:__init()
	self._config = require "data.MarriageTourTask"
	self._marriageInfos = {} --marriageId
--	self._max_id = g_worldID * 100000		-- reserve 100k for id
	g_listHandler:addListener(self)
	--g_entityDao:loadMaxMarriageId()
	g_entityDao:loadAllData("marriageinfo", g_frame:getWorldId())
	self._marriageIDMap = {} --SID -> marriageId
	self._weddingCarMap = {} --MonID -> info
	self._nextCreateCarTime = nil
	self:initWeddingAvailableVenue()
	self._venueMemberMap = {} --SID -> WeddingVenue
	self._venueMapMap = {} --MapID -> WeddingVenue
	self._loadDBFini = false
end

function MarriageManager:findTaskConfig(id)
	for _, config in pairs(self._config) do
		if config.q_taskid == id then
			return config
		end
	end
end

function MarriageManager:test(id, s)
	local scene = g_sceneMgr:getPublicScene(id)
	if scene then
		scene:setAllSafe(s)
	end
end

--加载数据
function MarriageManager.loadDBData(id, buff)
	local marriage = MarriageInfo(id)
	if buff then
		marriage:loadMarriageData(buff)
		gTimerMgr:regTimer(marriage, MARRIAGE_TIMER_PERIOD, MARRIAGE_TIMER_PERIOD)
	end
	g_marriageMgr:addMarriage(marriage)
end

function MarriageManager:setLoadDBFini(b)
	self._loadDBFini = b
end

function MarriageManager:getLoadDBFini(b)
	return self._loadDBFini
end

--加载数据完成
function MarriageManager.loadDBFini()
	g_marriageMgr:setLoadDBFini(true)
end

--获取玩家信息
function MarriageManager:getMarriageInfo(marriageID)
	return self._marriageInfos[marriageID]
end

--[[
function MarriageManager:setMaxMarriageID(id)
	print("setMaxMarriageID:", id)
	if id > 0 then
		self._max_id = id
	end
end
]]

function MarriageManager:genMarriageID()
	--self._max_id = self._max_id + 1
	--return self._max_id
	local guid = NEW_GUID(g_worldID, 10)
	local str = GUID2STR(guid)
	return str
end

function MarriageManager:createNewMarriage(maleSID, femaleSID, male, female)
	local marriageID = self:genMarriageID()
	local marriage = MarriageInfo(marriageID)
	print("======new marriage created!", marriageID, " maleID:", maleSID, " femaleID:", femaleSID)
	marriage:setMaleSID(maleSID)
	marriage:setFemaleSID(femaleSID)
	marriage:setMaleName(male:getName())
	marriage:setFemaleName(female:getName())
	self:addMarriage(marriage)
	local buf = marriage:serializeBuf()
	g_entityDao:createMarriage(marriageID, buf, #buf)
	gTimerMgr:regTimer(marriage, MARRIAGE_TIMER_PERIOD, MARRIAGE_TIMER_PERIOD)
	self._marriageIDMap[maleSID] = marriage:getMarriageID()
	self._marriageIDMap[femaleSID] = marriage:getMarriageID()
	marriage:setMale(male)
	marriage:setFemale(female)
	return marriage
end

function MarriageManager:deleteMarriage(marriageID)
	local marriage = self._marriageInfos[marriageID]
	if marriage then
		g_entityDao:deleteMarriage(marriageID)
		self._marriageIDMap[marriage:getMaleSID()] = nil
		self._marriageIDMap[marriage:getFemaleSID()] = nil
		release(marriage)
		self._marriageInfos[marriageID] = nil
		return true
	end
	return false
end

function MarriageManager:addMarriage(marriage)
	print("addMarriage, id=", marriage:getMarriageID())
	self._marriageInfos[marriage:getMarriageID()] = marriage
	return true
end

function MarriageManager:saveMarriage(marriageID)
	local marriage = self._marriageInfos[marriageID]
	if marriage then
		local buf = marriage:serializeBuf()
		g_entityDao:saveMarriageData(marriageID, buf, #buf)
	end
	return true
end

function MarriageManager:mapProcess(player)
	local mapID = player:getMapID()
	for id, _ in pairs(WEDDING_VENUE_AVAILABLE) do
		if id == mapID then
			g_marriageMgr:transmitTo(player, 2100, WEDDING_VENUE_KICKOUT_POINT)
			break
		end
	end
end

--玩家登陆的消息
function MarriageManager:onPlayerLoaded(player)
	self:mapProcess(player)
	local marriageID = player:getMarriageID()
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		marriage:onPlayerOnline(player)
	end
end

function MarriageManager:onActivePlayer(player)
end

function MarriageManager:onPlayerOffLine(player)
	local marriageID = player:getMarriageID()
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		marriage:onPlayerOffline(player)
	end
	local venue = g_marriageMgr:getVenueBySID(player:getSerialID())
	if venue then
		venue:onPlayerOffLine(player)
	end
end

--怪物被杀死消息
function MarriageManager:onMonsterKill(monSID, roleID, monID, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		self:notifyListener(marriage, "onMonsterKill", monSID, roleID, monID, mapID)
	end
end

function MarriageManager:teamClose(members)
	for _, mem in pairs(members) do
		local marriageID = self._marriageIDMap[mem]
		if marriageID then
			local marriage = self._marriageInfos[marriageID]
			if marriage then
				marriage:teamClose()
			end
		end
	end
end

function MarriageManager:setMarriageIDMap(SID, marriageID)
	self._marriageIDMap[SID] = marriageID
end

function MarriageManager:getMarriageIDBySID(SID)
	return self._marriageIDMap[SID]
end

function MarriageManager:notifyListener(marriage, eventName, ...)
	marriage:notifyListener(eventName, ...)
end

function MarriageManager:transmitTo(player, mapID, pos)
	if not g_entityMgr:canSendto(player:getID(), mapID, pos.x, pos.y) then
		print("not canSendto")
		return false
	end

	if g_sceneMgr:posValidate(mapID, pos.x, pos.y) then
		print("transmitToCeremony======posValidate")
		local old_pos = player:getPosition()
		player:setLastMapID(player:getMapID())
		player:setLastPosX(old_pos.x)
		player:setLastPosY(old_pos.y)
		g_sceneMgr:enterPublicScene(player:getID(), mapID, pos.x, pos.y)
		return true
	else
		return false
	end
end

function MarriageManager:onPlayerMoveInCeremony(monID)
	local player = g_entityMgr:getPlayer(monID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		self:notifyListener(marriage, "onPlayerMoveInCeremony", monID)
	end
end

function MarriageManager.DoYuanBaoMarriagePray(roleSID, ret, money, itemId, itemCount, callBackContext)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		marriage:payWeddingCallback(player, ret, callBackContext)
	end
end

function MarriageManager.DoYuanBaoSendBonus(roleSID, ret, money, itemId, itemCount, callBackContext)
	local context = unserialize(callBackContext)
	if 0 ~= ret then
		print("MarriageManager.DoYuanBaoSendBonus: ret ~0, playerSerialID: ", roleSID, " bonustype: ", context.bonus)
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local ret = {}
			ret.res = MarriageErrorCode.WeddingVenueWeddingSendBonusPay
			fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		end
		return TPAY_FAILED
	end
	local marriageID = context.marriageID
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if marriage then
		local res, errorCode = marriage:paySendBonusCallback(roleSID, callBackContext)
		if TPAY_SUCESS ~= res then
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player then
				local ret = {}
				ret.res = errorCode
				fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
			end
		end
		return res
	else
		print("MarriageManager.DoYuanBaoSendBonus: marriage not found maybe finish, playerSerialID: ", roleSID, " bonustype: ", context.bonus, " ingot:", context.ingot)
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			local ret = {}
			ret.res = MarriageErrorCode.WeddingVenueWeddingSendBonusFini
			fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		end
		return TPAY_FAILED
	end
end

function MarriageManager:sendErrMsg2Client(errId, paramCount, params)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = 0
	ret.param = {}
	paramCount = paramCount or 0
	for i = 1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function MarriageManager:broadCastScene2Client(mapID, eventId, errId, paramCount, params)
	local ret = {}
	ret.eventId = eventId
	ret.eCode = errId
	ret.mesId = 0
	ret.param = {}
	paramCount = paramCount or 0
	for i = 1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	local scene = g_sceneMgr:getPublicScene(mapID)
	if scene then
		boardSceneProtoMessage(scene:getID(), FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	end
end

-- 怪物停止移动
function MarriageManager:onMonsterStop(monID)
	local info = self:getWeddingCarMap(monID)
	if info then
		info:stopMove(monID)
	end
end

function MarriageManager:addWeddingCarMap(monID, info)
	self._weddingCarMap[monID] = info
end

function MarriageManager:delWeddingCarMap(monID)
	self._weddingCarMap[monID] = nil
end

function MarriageManager:getWeddingCarMap(monID)
	return self._weddingCarMap[monID]
end

function MarriageManager:print(id)
	local marriage = g_marriageMgr:getMarriageInfo(id)
	if marriage then
		marriage:printself()
	end
end

function MarriageManager:initWeddingAvailableVenue()
	for id = WEDDING_VENUE_MIN, WEDDING_VENUE_MAX do
		WEDDING_VENUE_AVAILABLE[id] = true
	end
end

function MarriageManager:addWeddingAvailableVenue(id)
	WEDDING_VENUE_AVAILABLE[id] = true
end

function MarriageManager:delWeddingAvailableVenue(id)
	WEDDING_VENUE_AVAILABLE[id] = nil
end

function MarriageManager:getWeddingAvailableVenue()
	for id, _ in pairs(WEDDING_VENUE_AVAILABLE) do
		return id
	end
end

function MarriageManager:getCreateCarTime()
	return self._nextCreateCarTime or os.time()
end

function MarriageManager:updateCreateCarTime(time)
	if not _nextCreateCarTime then
		self._nextCreateCarTime = os.time()
	else
		if not time then
			self._nextCreateCarTime = self._nextCreateCarTime + WEDDING_CAR_CREATE_PERIOD
		else
			self._nextCreateCarTime = time + WEDDING_CAR_CREATE_PERIOD
		end
	end
end

function MarriageManager:getVenueBySID(SID)
	return self._venueMemberMap[SID]
end

function MarriageManager:addVenueMap(SID, venue)
	self._venueMemberMap[SID] = venue
end

function MarriageManager:delVenueMap(SID)
	self._venueMemberMap[SID] = nil
end

--玩家死亡
function MarriageManager:onPlayerDied(player, killerID)
	local venue = g_marriageMgr:getVenueBySID(player:getSerialID())
	if venue then
		venue:onPlayerDied(player, killerID)
	end
end

--切地图
function MarriageManager:onSwitchScene(player, mapID, lastMapID)
	local venueNow = g_marriageMgr:getVenueMapMap(mapID)
	if venueNow then
		venueNow:onSwitchScene(player, mapID, lastMapID)
	end

	local venueLast = g_marriageMgr:getVenueMapMap(lastMapID)
	if venueLast then
		venueLast:onSwitchScene(player, mapID, lastMapID)
	end
end

function MarriageManager:addVenueMapMap(id, venue)
	self._venueMapMap[id] = venue
end

function MarriageManager:delVenueMapMap(id)
	self._venueMapMap[id] = nil
end

function MarriageManager:getVenueMapMap(id)
	return self._venueMapMap[id]
end

function MarriageManager.getInstance()
	return MarriageManager()
end

g_marriageMgr = MarriageManager.getInstance()