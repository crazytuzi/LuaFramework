local QuickLogin= {}
local is_init = false
local module_list = {}

function QuickLogin:IsOpenQuick()
	return "1" == UnityEngine.PlayerPrefs.GetString("is_quick_login")
end

function QuickLogin:Start()
	self:ReqireLua()
	self:InitModule()
	self:RegisterProtocols()
	self:Preload()
	UnityEngine.PlayerPrefs.DeleteKey("is_quick_login")

	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
end

function QuickLogin:Stop()
	for i=#module_list, 1, -1 do
		module_list[i]:DeleteMe()
	end
	module_list = {}
end

function QuickLogin:ReqireLua()
	require("init/global_config")
	require("init/init_ctrl")
	require("manager/report_manager")

	local list = require("game/common/require_list")
	for _, v in ipairs(list) do
		require(v)
	end

	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
end

function QuickLogin:InitModule()
	require("play")

	module_list = {}
	table.insert(module_list, Runner.New())
	
	GlobalEventSystem = EventSystem.New()					-- 全局事件系统
	table.insert(module_list, GlobalEventSystem)

	GlobalTimerQuest = TimerQuest.New()						-- 定时器
	table.insert(module_list, GlobalTimerQuest)

	Runner.Instance:AddRunObj(GlobalEventSystem, 3)
	
	table.insert(module_list, CountDown.New())
	table.insert(module_list, GameNet.New())
	table.insert(module_list, ConfigManager.New())
	table.insert(module_list, StepPool.New())
	table.insert(module_list, GameMapHelper.New())
	table.insert(module_list, PreloadManager.New())
	table.insert(module_list, EffectManager.New())
	table.insert(module_list, ModulesController.New(true))
	table.insert(module_list, TipsSystemManager.New())
	table.insert(module_list, TipsFloatingManager.New())
	table.insert(module_list, TipsFloatingName.New())
	table.insert(module_list, TipsActivityNoticeManager.New())
	table.insert(module_list, RareItemTipManager.New())

	COMMON_CONSTS.SCENE_LOADING_MIN_TIME = 0.2
	is_init = true
end

function QuickLogin:Update(now_time, elapse_time)
	if is_init then
		Runner.Instance:Update(now_time, elapse_time)
	end
end

function QuickLogin:RegisterProtocols()
	local list = {
		{SCLoginAck, "OnLoginAck"},
		{SCRoleListAck, "OnRoleListAck"},
		{SCCreateRoleAck, "OnCreateRoleAck"},
		{SCUserEnterGSAck, "OnUserEnterGSAck"},
		{SCDisconnectNotice, "OnDisconnectNotice"},
	}

	for _, v in ipairs(list) do
		local msg_type = ProtocolPool.Instance:Register(v[1])
		GameNet.Instance:RegisterMsgOperate(msg_type, BindTool.Bind1(self[v[2]], self))
	end
end

function QuickLogin:Preload()
	local preload_list_cfg = PreloadManager.Instance:GetLoadListCfg()
	local total_count = #preload_list_cfg
	local loaded_count = 0
	local loaded_list = {}

	for _, v in ipairs(preload_list_cfg) do
		PrefabPool.Instance:Load(AssetID(v[1], v[2]), function(prefab)
			loaded_count = loaded_count + 1

			loaded_list[v[1]] = loaded_list[v[1]] or {}
			loaded_list[v[1]][v[2]] = prefab
			PrefabPool.Instance:Free(prefab)

			if loaded_count >= total_count then
				PreloadManager.Instance:SetLoadList(loaded_list)
				self:ReqInitHttp()
			end
		end)
	end
end

function QuickLogin:ReqInitHttp()
	local os = "unknown"
	local platform = UnityEngine.Application.platform
	if platform == UnityEngine.RuntimePlatform.Android then
		os = "android"
	elseif platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		os = "ios"
	elseif platform == UnityEngine.RuntimePlatform.WindowsEditor or
		platform == UnityEngine.RuntimePlatform.OSXEditor then
		os = "windows"
	end

	local url = string.format("%s?plat=%s&pkg=%s&asset=%s&device=%s&os=%s",
		GLOBAL_CONFIG.package_info.config.init_urls[1],
		GLOBAL_CONFIG.package_info.config.agent_id,
		GLOBAL_CONFIG.package_info.version,
		GLOBAL_CONFIG.assets_info.version,
		DeviceTool.GetDeviceID(),
		os)

	print("[QuickLogin]ReqInitHttp", url)
	HttpClient:Request(url, function(url, is_succ, data)

		if not is_succ then
			print("[QuickLogin]ReqInitHttp Fail", url)
			return
		end

		local init_info = cjson.decode(data)
		if init_info == nil then
			print("[QuickLogin]ReqInitHttp Fail", url)
			return
		end

		GLOBAL_CONFIG.param_list = init_info.param_list
		GLOBAL_CONFIG.server_info = init_info.server_info
		local version_info = init_info.version_info
		GLOBAL_CONFIG.version_info = {}
		GLOBAL_CONFIG.version_info.package_info = version_info.package_info

		if cjson.null ~= version_info.assets_info then
			GLOBAL_CONFIG.version_info.assets_info = version_info.assets_info
			AssetManager.AssetVersion = version_info.assets_info.version
		end

		self:ReqConnectLoginServer()
	end)
end

function QuickLogin:ReqConnectLoginServer()
	local server_id = UnityEngine.PlayerPrefs.GetString("quick_login_server_id")
	if nil ~= server_id then
		server_id = tonumber(server_id)
	end

	local plat_name = UnityEngine.PlayerPrefs.GetString("quick_login_user_name")
	if nil == plat_name then
		plat_name = math.floor(math.random(1, 10000000))
	end

	local cfg = nil
	for _, v in pairs(GLOBAL_CONFIG.server_info.server_list) do
		if v.id == server_id then
			cfg = v
			break
		end
	end

	if nil == cfg then
		print(string.fomrmat("[QuickLogin] server %d is not exist", server_id))
		return
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	user_vo.plat_server_id = cfg.id
	user_vo.plat_name = "dev_" .. plat_name

	GameNet.Instance:SetLoginServerInfo(cfg.ip, cfg.port)

	GameNet.Instance:AsyncConnectLoginServer(5)
	GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_CONNECTED, function(is_succ)
		print("[QuickLogin] connect login server success")
		self:ReqLogin()

		self.login_server_heartbeat_timer = GlobalTimerQuest:AddRunQuest(function()
				local cmd = ProtocolPool.Instance:GetProtocol(CSLHeartBeat)
				cmd:EncodeAndSend(GameNet.Instance:GetLoginNet())
			end, 10)
	end)

	GlobalEventSystem:Bind(LoginEventType.LOGIN_SERVER_DISCONNECTED, function()
		print("[QuickLogin] login server disconnect")
		GlobalTimerQuest:CancelQuest(self.login_server_heartbeat_timer)
	end)
end

function QuickLogin:ReqLogin()
	print("[QuickLogin] ReqLogin")

	local user_vo = GameVoManager.Instance:GetUserVo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSLoginReq)
	protocol.rand_1 = math.floor(math.random(1000000, 10000000))
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.rand_2 = math.floor(math.random(1000000, 10000000))
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.plat_name = user_vo.plat_name
	protocol.plat_server_id = user_vo.plat_server_id
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function QuickLogin:OnRoleListAck(protocol)
	print("[QuickLogin] OnRoleListAck", protocol.result)

	if nil ~= self.login_data then
		self.login_data:DeleteMe()
	end
	self.login_data = LoginData.New()
	self.login_data:SetRoleListAck(protocol)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local user_vo = GameVoManager.Instance:GetUserVo()

	if 0 == protocol.result and protocol.count > 0 then
		local info = protocol.role_list[1]
		user_vo:SetNowRole(info.role_id)
		mainrole_vo.name = info.role_name
		self.SendRoleReq()

	elseif -6 == protocol.result then -- 没有角色
		self:ReqCreateRole()
	end
end

function QuickLogin.ReqCreateRole()
	print("[QuickLogin] ReqCreateRole")

	local prof_list = {
		{1, 1},
		{2, 0},
		{3, 1},
		{4, 0},
	}
	local prof_index = math.floor(math.random(1, 4))

	local user_vo = GameVoManager.Instance:GetUserVo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateRoleReq)
	protocol.plat_name = user_vo.plat_name
	protocol.role_name = math.floor(math.random(1, 10000000))
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_server_id = user_vo.plat_server_id
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.avatar = 1
	protocol.sex = prof_list[prof_index][2] or 1		 --math.floor(math.random(0, 1))
	protocol.prof =  prof_list[prof_index][1] or 1		 --math.floor(math.random(1, 3))
	protocol.camp_type = math.floor(math.random(1, 3))
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function QuickLogin:OnCreateRoleAck(protocol)
	print("[QuickLogin] OnCreateRoleAck", protocol.result)

	if 0 == protocol.result then
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:ClearRoleList()
		user_vo:AddRole(
			protocol.role_id,
			protocol.role_name,
			protocol.avatar,
			protocol.sex,
			protocol.prof,
			0,
			protocol.level,
			protocol.create_time)

		user_vo:SetNowRole(protocol.role_id)
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = protocol.role_name

		self.SendRoleReq()
	else
		print("[QuickLogin] OnCreateRoleAck", protocol.result)
		TipsCtrl.Instance:ShowSystemMsg("该昵称已存在, 请修改昵称")
	end
end

function QuickLogin.SendRoleReq()
	print("[QuickLogin] SendRoleReq")
	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleReq)
	protocol.rand_1 = math.floor(math.random(1, 10000000))
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.rand_2 = math.floor(math.random(1000000, 10000000))
	protocol.role_id = mainrole_vo.role_id
	protocol.plat_name = user_vo.plat_name
	protocol.plat_server_id = user_vo.plat_server_id
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function QuickLogin:OnLoginAck(protocol)
	TimeCtrl.Instance:SetServerTime(protocol.server_time)

	if 0 ~= protocol.result then
		print("[OnLoginAck] OnLoginAck fail")
		return
	end
 	
	print("[QuickLogin] OnLoginAck hostname:" .. protocol.gs_hostname .. "  prot:" .. protocol.gs_port)
	GameNet.Instance:SetGameServerInfo(protocol.gs_hostname, protocol.gs_port)
	local user_vo = GameVoManager.Instance:GetUserVo()
	user_vo:SetNowRole(protocol.role_id)
	user_vo.login_time = protocol.time
	user_vo.session_key = protocol.key
	user_vo.anti_wallow = protocol.anti_wallow
	user_vo.scene_id = protocol.scene_id
	user_vo.last_scene_id = protocol.last_scene_id
	GameNet.Instance:DisconnectLoginServer()

	self:ReqConnectGameServer()
end

function QuickLogin:ReqConnectGameServer()
	GameNet.Instance:AsyncConnectGameServer(5)

	GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_CONNECTED, function(is_succ)
		print("[QuickLogin] connect game server success")
		self:SendUserEnterGSReq()
	end)

	GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_DISCONNECTED, function( ... )
		print("[QuickLogin] game server disconnect")
	end)
end

function QuickLogin.SendUserEnterGSReq()
	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSUserEnterGSReq)
	protocol.scene_id = user_vo.scene_id
	protocol.scene_key = 0
	protocol.last_scene_id = user_vo.last_scene_id
	protocol.role_id = mainrole_vo.role_id
	protocol.role_name = mainrole_vo.role_name
	protocol.time = user_vo.login_time
	protocol.is_login = 1
	protocol.server_id = mainrole_vo.server_id
	protocol.key = user_vo.session_key
	protocol.plat_name = user_vo.plat_name
	protocol.is_micro_pc = 0
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNet())

	print("[QuickLogin] SendUserEnterGSReq name=" .. mainrole_vo.role_name.."server_id="..mainrole_vo.server_id)
end

function QuickLogin:OnUserEnterGSAck(protocol)
	print("[QuickLogin] OnUserEnterGSAck result=" .. protocol.result)
	if 0 == protocol.result then
		GlobalEventSystem:Fire(LoginEventType.ENTER_GAME_SERVER_SUCC)
	end
end

function QuickLogin:OnDisconnectNotice(protocol)
	if protocol.reason == DISCONNECT_NOTICE_TYPE.LOGIN_OTHER_PLACE then
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_MULTI_LOGIN)
	else
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_NORMAL)
	end
end

function QuickLogin:ExecuteGm(text)
	local len = string.len(text)
	if len >= 3 and string.sub(text, 1, 3) == "/gm" then
		local blank_begin, blank_end = string.find(text, " ")
		local colon_begin, colon_end = string.find(text, ":")
		if blank_begin and blank_end and colon_begin and colon_end then
			local cmd_type = string.sub(text, blank_end + 1, colon_begin - 1)
			local command = string.sub(text, colon_end + 1, -1)
			SysMsgCtrl.SendGmCommand(cmd_type, command)
		end
	elseif len >= 4 and string.sub(text, 1 , 5) == "/cmd " then
		local blank_begin, blank_end = string.find(text, " ")
		if blank_begin and blank_end then
			ClientCmdCtrl.Instance:Cmd(string.sub(text, blank_end + 1, len))
		end
	else
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, CHAT_CONTENT_TYPE.TEXT)
	end
end
	

return QuickLogin