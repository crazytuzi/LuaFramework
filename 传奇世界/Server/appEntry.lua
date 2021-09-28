--appEntry.lua
g_isOpenShellCmd = true
g_serverVersion = "0.14.1"

require "system.maze.Maze"

function loadLocalModules()
	require "base.base"
	require "event.ListenerHandler"
	g_listHandler = ListenerHandler()
	math.randomseed(os.time())
	--TODO:Lua随机数的第一个随机数总是固定,所以先消耗掉它
	for i=1,7 do math.random() end
	
	--timer manager
	require "core.TimerMgr"
	TimerMgr.bindEngine(g_frame:getTimerEngine())
	
	
	require("util.commonFunc")
	require("util.globalConst")

	--events
	require "event.EventUtil"
	require "event.EventManager"
	require "event.RemoteEventProxy"

	--api for engine
	require "apiEntry"

	require "system.includes"
	require("system.backTool.LuaDBAccess")
	require("system.backTool.DealBackToolEvent")
	require("system.cardprize.CardPrizeServlet")
	require("system.sharedtask.SharedTaskMgr")

	require "base.protobuf"	

	cjson.encode_sparse_array(true)
end

function setGlobals()	
	g_logger = Logger.getLogger()
	g_timerMgr = TimerMgr.getInstance()	
	g_eventMgr = EventManager.getInstance()
	g_eventFct = EventFactory.getInstance()
end

ManagedApp = {}

function ManagedApp.start(worldFrame, moduleFace, worldID)
	g_worldID = worldID
	g_frame = tolua.cast(worldFrame, "Server")
	g_engine = tolua.cast(moduleFace, "CModuleFace")
		
	g_spaceID = g_frame:getAreaId()
	g_dbProxy = g_frame:getDBProxy()

	g_buffMgr = LuaEventManager:instance()

	if g_worldID >= 800 and g_worldID < 910 then
		g_isOpenShellCmd = true
	end

	loadLocalModules()
	setGlobals()

	loadGlobalData() 
	loadCommonData()
	loadBossRecordInfo()
	print("Managed lua application start......", g_worldID, g_spaceID)
end

function ManagedApp.stop()
	g_frame:evalPerform()
	print("Managed lua application stopped......")
end

function ManagedApp.peerRemoting(peer, event, source, ...)
	RemoteEventProxy.receive(peer, event, source, ...)
end

function ManagedApp.worldRemoting(peer, event, source, ...)
	RemoteEventProxy.wreceive(peer, event, source, ...)
end

function ManagedApp.timerFired(timer)
	g_timerMgr:update(timer)
end

function ManagedApp.InitGlobalModules(entityMgr, entityFct, sceneMgr, configMgr,tlogMgr,tPayMgr)
	g_entityMgr = tolua.cast(entityMgr, "EntityManager")
	g_entityFct = tolua.cast(entityFct, "EntityFactory")
	g_sceneMgr = tolua.cast(sceneMgr, "SceneManager")
	g_configMgr = tolua.cast(configMgr, "ConfigMgr")
	g_entityDao = g_entityMgr:getEntityDao()
	g_logManager = g_entityMgr:getLogger()
	g_tlogMgr = tolua.cast(tlogMgr, "CTlogManager")
	g_tPayMgr = tolua.cast(tPayMgr, "CTPayManager")
	g_tFactionVoiceMgr = g_entityMgr:getFactionVoiceMgr()
end

--------------------------------------------------------------------------------------------
--helper functions
--------------------------------------------------------------------------------------------
local bEvalFlag = true		--性能测试
function gBeginEval(call)
	if (bEvalFlag) then
		return g_frame:beginEval(call)
	end
end

function gEndEval(call)
	if (bEvalFlag) then
		return g_frame:endEval(call)
	end
end

function _s()
	g_frame:evalPerform()
	g_frame:evalTraffic()
end

--加载全局数据库数据
function loadGlobalData()
	if g_spaceID == 0 or g_spaceID == FACTION_DATA_SERVER_ID then
		g_entityDao:loadAllData("faction", g_frame:getWorldId())
		g_entityDao:loadFactionSocial(g_frame:getWorldId())	-- 加载行会外交数据
		g_entityDao:loadAllData("fightTeam", g_frame:getWorldId())
		g_entityDao:loadAllData("fightTeam3v3", g_frame:getWorldId())
	end

	g_entityDao:loadGlobalEmail(g_worldID)	
	g_entityDao:loadManorWar(g_worldID)				-- 加载领地数据
end

local lastTick = os.time()
local lastTick2 = os.time()
local lastTick3 = os.time()
local lastTick4 = os.time()
local lastTick5 = os.time()
local lastTick6 = os.time()

function lua_mem_gc()
	if os.time() - lastTick >= 5 then
		collectgarbage("step")	
		lastTick = os.time()
	end
	if os.time() - lastTick2 > 600 then
		lastTick2 = os.time()
		_s()
		_m()
	end
end

--整点触发功能
local lastDay = 0
local lastHour = 26
function lua_whole_clock()
	local iswhole, hour, day = time.isclock()
	if iswhole and (hour ~= lastHour or day ~= lastDay) then
		g_listHandler:notifyListener("onWholeClock", hour)
		if hour == 0 then
			g_listHandler:notifyListener("onFreshDay")
		end
		lastHour = hour
		lastDay = day
	end
	if os.time() - lastTick3 >= 3 then
		lua_timer_update()
		lastTick3 = os.time()
	end
	if os.time() - lastTick4 >= 60 then
		print("统计在线玩家时间, minute:", time.tostring(os.time()))
		print(string.format("current player number is: %d ios[%d] android[%d]", g_entityMgr:getPlayerCnt(), g_frame:getOnlineCntIos(), g_frame:getOnlineCntAndroid()))
		print(string.format("Player Count[%d],Monster Count[%d],MPW Count[%d],SceneBuff Count[%d],Scene Count[%d],aiengine count[%d],aistate count[%d],aiaction count[%d]",
			g_entityMgr:getPlayerCount(),g_entityMgr:getMonsterCount(),
			g_entityMgr:getMPWCount(),g_entityMgr:getSceneBuffCount(),g_entityMgr:getSceneCount(),
			g_entityMgr:getAIEngineCount(),g_entityMgr:getAIStateCount(),g_entityMgr:getAIActionCount()))
		--print(string.format("AI Status Count[%d],AI Action Count[%d],AI Engine Count[%d]",g_entityMgr:getAiStatusCount(),g_entityMgr:getAiActionCount(),g_entityMgr:getAiEngineCount()))
		if g_entityMgr:getSceneCount()<100 then
			--testAccept()
		end

		--Tlog[GameSvrState]
		g_tlogMgr:TlogGameSvrState(g_frame:getLocalIPAddr(),g_frame:getSerialId())
		--Tdlog 在线人数 在线注册
		g_tlogMgr:TdlogOnlineCnt()
		g_tlogMgr:TdlogRegister()

		lua_timer_minute_update()
		lastTick4 = os.time()
	end	
	if os.time() ~= lastTick5 then
		lua_time_second_update()
		lastTick5 = os.time()
	end
	if os.time() - lastTick6 >= 5 then
		lua_timer_update2()
		lastTick6 = os.time()
	end
end

function testAccept()
	local player = g_entityMgr:getPlayerBySID("360009612")
	local proto = g_copyMgr:getProto(3001)
	local count = 1000
	while count>=0 do
		if player then
			local newBook = g_copyMgr:createCopy(player:getID(), 3001)
			if newBook and newBook:createBookScene(proto:getMapID()) then
--				g_copySystem:flushMonster(newBook, 1)
			end
		end
		count = count - 1
	end
	--g_sharedTaskMgr:AcceptSharedTask(900000010,1,1)
end

--3秒更新一次的定时器
function lua_timer_update()
	g_listHandler:notifyListener("onThreeSecond")
end

--5秒更新一次的定时器
function lua_timer_update2()
	g_listHandler:notifyListener("onFiveSecond")
end

--1分钟更新一次的定时器
function lua_timer_minute_update()
	g_listHandler:notifyListener("onOneMinute")
end

--每秒更新一次的定时器
function lua_time_second_update()
	g_listHandler:notifyListener("onOneSecond")
end

function _m()
	local mem = collectgarbage("count")
	print(string.format("game memory used: %.3fK", mem))
end

--LUA_RPC消息处理
function processRPCMessage2(eventID, buff, hSource, hGate)
	if eventID then
		local buff = tolua.cast(buff, "LuaMsgBuffer")
		local event = g_eventFty:getEvent(eventID, nil, buff, hSource, hGate)
		g_eventMgr:fireEvent(event)
	end
end

--LUA_RPC消息处理
function processRPCMessage(eventID, hSource, hGate, pbcString)
	if eventID then
		local event = g_eventFty:getEvent(eventID, nil, pbcString, hSource, hGate)
		g_eventMgr:fireEvent(event)
	end
end

--发送pb协议给客户端
--[[ex: 
	local protoData = {
		eventId = 2001, 
		srcEventId = 2000, 
		errorId = -6, 
		paramCnt = 0
	}
	fireProtoMessage(roleId, FRAME_SC_MESSAGE, "ErrorProtocol", protoData)
]]
function fireProtoMessage(roleId, eventId, protoName, protoData)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	--local ret,err = protobuf.decode(protoName,pb_str)
	if pb_str then
		g_engine:firePbcLuaEvent(roleId, eventId, pb_str, #pb_str)
		if roleId==nil then
			print("-----roleID nil ",  debug.traceback())
		end
		--print("fireProtoMessage sucess", roleId, eventId, protoName, #pb_str)
	else
		print("fireProtoMessage encode error! context: ", errorCode, roleId, eventId, protoName, toString(protoData))
	end
end

--发送pb协议给客户端
function fireProtoMessageBySid(roleSid, eventId, protoName, protoData)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	if pb_str then
		local buff = g_buffMgr:getLuaRPCEvent(eventId)
		buff:pushPbc(pb_str, #pb_str)
		g_engine:fireSerialEvent(roleSid, buff)
		--print("fireProtoMessageBySid sucess", roleSid, eventId, protoName, #pb_str)
	else
		print("fireProtoMessageBySid encode error! context: ", errorCode, roleSid, eventId, protoName, toString(protoData))
	end
end

function fireProtoMessageToGroup(allRoleId,eventId, protoName, protoData)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	if pb_str then
		local buff = g_buffMgr:getLuaRPCEvent(eventId)
		buff:pushPbc(pb_str, #pb_str)
		g_frame:sendMsgToPeerGroupBySid(allRoleId, buff)
	else
		print("fireProtoMessageToGroup encode error! context: ", errorCode, eventId, protoName, toString(protoData))
	end
end

--广播pb协议给客户端
function boardProtoMessage(eventId, protoName, protoData)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	if pb_str then
		local buff = g_buffMgr:getLuaRPCEvent(eventId)
		buff:pushPbc(pb_str, #pb_str)
		g_engine:broadWorldEvent(buff)
	else
		print("boardProtoMessage encode error! context: ", errorCode, eventId, protoName, toString(protoData))
	end
end

--发送系统提示给客户端
function fireProtoSysMessage(mesID, roleID, eventID, eCode, paramCnt, params)
	local ret = {}
	ret.eventId = eventID
	ret.eCode = eCode
	ret.mesId = mesID
	ret.param = {}
	paramCnt = paramCnt or 0
	for i=1, paramCnt do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	fireProtoMessage(roleID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function fireProtoSysMessageBySid(mesID, roleSid, eventID, eCode, paramCnt, params)
	local ret = {}
	ret.eventId = eventID
	ret.eCode = eCode
	ret.mesId = mesID
	ret.param = {}
	paramCnt = paramCnt or 0
	for i=1, paramCnt do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	fireProtoMessageBySid(roleSid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end


--广播pb协议给客户端
--mapID:场景的动态ID
function boardSceneProtoMessage(mapID, eventId, protoName, protoData)
	local pb_str, errorCode = protobuf.encode(protoName, protoData)
	if pb_str then
		local buff = g_buffMgr:getLuaRPCEvent(eventId)
		buff:pushPbc(pb_str, #pb_str)
		g_engine:broadSceneEvent(mapID, buff)
	else
		print("boardSceneProtoMessage encode error! context: ", errorCode, eventId, protoName, toString(protoData))
	end
end

function testAccept()
	g_sharedTaskMgr:AcceptSharedTask(900000010,1,1)
end

function testShare()
	g_sharedTaskMgr:ShareTaskToTeamMate(900000010,30000)
end

function testConfirm()
	g_sharedTaskMgr:doConfirmSharedTask(998000010,30000)
end

function testMob()
	local __EditionBaseTime=time.totime("2016-04-22 11:18:00")
	print("time:",__EditionBaseTime)
end


function tt()	
--[[
	local skill =
	{
		skills = 
		{
			{
				id=2001,
				level=2,
				exp=55,
				key=1,
			}
		}
	}
	local code = protobuf.encode("SkillProtocol", skill)
	local decode = protobuf.decode("SkillProtocol" , code)
	for _, v in pairs(decode.skills) do
		print("\t" .. v.id, v.key, v.level, v.exp)
	end]]

	local guid = NEW_GUID(800, 2)
	local str = GUID2STR(guid)
	local world1 = GUID_WORLD(guid)
	local type1 = GUID_TYPE(guid)
	local searl1 = GUID_SERIAL(guid)
	local tm1 = GUID_TIMESTAMP(guid)
	print("1111111111", guid, world1, type1, searl1, tm1)
	local str = GUID2STR(guid)
	print(str)
	local guid2 = STR2GUID(str)
	local world2 = GUID_WORLD(guid2)
	local type2 = GUID_TYPE(guid2)
	local searl2 = GUID_SERIAL(guid2)
	local tm2 = GUID_TIMESTAMP(guid2)
	print("2222222222", guid2, world2, type2, searl2, tm2)
end
