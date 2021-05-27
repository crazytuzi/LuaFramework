MainProber = { 
	error_view = nil,
	error_log = nil,
	error_alert_view = nil,

	screen_on = true,
	print_on = true,
	countly_on = true,

	agent_id = "",
	device_id = "",
	pkg_ver = "",
	assets_ver = "",
	session_id = 0,
	net_state = 0,
	user_id = "",
	server_id = 0,
	role_id = 0,
	role_name = "",
	role_level = 0,
	last_ping = 0,
	ping_itvl = 600,

	step_count = {},
	step2_count = {},

	LOG_DELIMITER = "\t",

	STEP_SESSION_BEDIN 				= 20,
	STEP_LUA_BEG					= 30,
	STEP_MAIN_LOADER_BEG 			= 40,
	STEP_AGENT_LOADER_BEG 			= 42,
	STEP_AGENT_LOADER_END 			= 44,
	STEP_TASK_INIT_QUERY_BEG 		= 60,
	STEP_TASK_INIT_QUERY_END 		= 80,
	STEP_TASK_CHECK_UPDATE_BEG 		= 100,
	STEP_TASK_CHECK_UPDATE_END 		= 120,
	STEP_TASK_ASSET_UPDATE_BEG 		= 140,
	STEP_TASK_ASSET_UPDATE_END 		= 160,
	STEP_TASK_LOAD_SCRIPT_BEG 		= 180,
	STEP_TASK_LOAD_SCRIPT_END 		= 200,
	STEP_INIT_TOOLS					= 400,
	STEP_PERLOAD_RES				= 410,
	STEP_INIT_GAME					= 420,
	STEP_AGENT_LOGIN_BEG 			= 202,
	STEP_AGENT_LOGIN_END 			= 204,
	STEP_PHP_VERIFY_END 			= 206,
	STEP_SERVER_SHOW_LIST 			= 220,
	STEP_CLICK_CONFIRM_LOGIN		= 230,
	STEP_SERVER_LOGIN_BEG 			= 240,
	STEP_CONNECT_LOGIN_SERVER 		= 250,
	STEP_SERVER_CREATE_ROLE_BEG 	= 280,
	STEP_SERVER_CREATE_ROLE_END 	= 300,
	STEP_CONNECT_GAME_SERVER		= 310,
	STEP_GAME_ENTER 				= 320,
	STEP_SESSION_END 				= 10000,

	EVENT_ON_CREATE 				= 10001,
	EVENT_ON_START 					= 10002,
	EVENT_ON_PAUSE 					= 10003,
	EVENT_ON_RESUME 				= 10004,
	EVENT_ON_STOP 					= 10005,
	EVENT_ON_DESTROY 				= 10006,
	EVENT_KEY_DOWN 					= 10007,
	EVENT_NET_STATE_CHANGE 			= 10008,
	EVENT_MEMORY_WARN 				= 10009,
	EVENT_ERROR 					= 10010,
	EVENT_CRASH_NATIVE 				= 10011,
	EVENT_CRASH_JAVA 				= 10012,
	EVENT_UPDATE_RETRY 				= 10013,
	EVENT_UPDATE_ERROR 				= 10014,
	EVENT_UPDATE_FATAL 				= 10015,
	EVENT_CONFIG_RETRY 				= 10016,
	EVENT_ASSET_RETRY 				= 10017,

	COUNT_TEST = 20001,
}

function MainProber:Start()
	self:GlobalConfigChanged()

	self.agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	self.device_id = PlatformAdapter.GetPhoneUniqueId()
	self.pkg_ver = GLOBAL_CONFIG.package_info.version
	self.assets_ver = GLOBAL_CONFIG.assets_info.version
	self.net_state = PlatformAdapter:GetNetState()

	self.session_id = AdapterToLua:getInstance():getDataCache("LOG_SESSION_ID")
	if "" == self.session_id then
		self.session_id = tostring(math.random(1000, 10000000))
		AdapterToLua:getInstance():setDataCache("LOG_SESSION_ID", self.session_id)
	end
end

function MainProber:Update(dt)
	if nil ~= self.error_view then
		self.error_view:Update()
	end

	if NOW_TIME - self.last_ping > self.ping_itvl then
		self.last_ping = NOW_TIME
		if nil ~= self.step2_count[2000] then
			MainProber:Step2(20000, MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id, MainProber.role_level) 
		end
	end
end

function MainProber:Stop()
	if nil ~= self.error_view then
		self.error_view:Destroy()
		self.error_view = nil
	end

	self.screen_on = false
	self.print_on = true
	self.countly_on = true

	self.step_count = {}
end

function MainProber:GlobalConfigChanged()
	print("GlobalConfigChanged " .. cjson.encode(GLOBAL_CONFIG.local_config))

	local switch_list = GLOBAL_CONFIG.local_config.switch_list or {}

	self.screen_on = switch_list.error_screen
	self.print_on = switch_list.log_print

	-- 允许本地输出报信息
	if cc.PLATFORM_OS_WINDOWS == PLATFORM then
		self.print_on = true
		self.screen_on = true
	end

	if nil ~= switch_list.countly_report then
		self.countly_on = switch_list.countly_report

		if self.countly_on then
			PlatformBinder:JsonCall("call_countly_enable_log", "true")
		else
			PlatformBinder:JsonCall("call_countly_enable_log", "false")
		end
	end

	if nil ~= GLOBAL_CONFIG.local_config.report_url then
		PlatformBinder:JsonCall("call_countly_set_server", GLOBAL_CONFIG.local_config.report_url)
	end
end

function MainProber:Step(st, ...)
	if self.countly_on and nil ~= st and nil == self.step_count[st] then
		self.step_count[st] = 1

		local login_times = AdapterToLua:getInstance():getDataCache("LOGIN_TIMES")

		local log = tostring(st) .. self.LOG_DELIMITER .. login_times
		for i=1, select("#", ...) do
			log = log .. self.LOG_DELIMITER .. tostring(select(i, ...))
		end

		PlatformBinder:JsonCall("call_countly_log_step", log)

		if self.print_on then
			print("MainProber:Step -> " .. log)
		end
	end
end

function MainProber:Step2(st, ...)
	if self.countly_on and nil ~= st then
		self.step2_count[st] = 1

		local url = GLOBAL_CONFIG.local_config.report_url2
		if nil == url or "" == url then
			url = GLOBAL_CONFIG.local_config.report_url
		end
		if nil == url then
			return
		end

		local log = ""
		for i=1, select("#", ...) do
			log = log .. self.LOG_DELIMITER .. tostring(select(i, ...))
		end
		local login_times = AdapterToLua:getInstance():getDataCache("LOGIN_TIMES")
		local now = os.time()
		local arg = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s", tostring(st), tostring(self.agent_id), tostring(self.device_id), 
			tostring(self.pkg_ver), tostring(self.assets_ver), tostring(self.session_id), tostring(login_times), tostring(self.net_state), tostring(now), log)

		local sign = UtilEx:md5Data(tostring(st) .. tostring(self.agent_id) .. tostring(self.session_id) .. tostring(now) .. "a0167e746e90736a1dfa16a0f65a6fa7")

		HttpClient:Request(string.format("%s?data=%s&sign=%s", tostring(url), tostring(mime.b64(arg)), tostring(sign)), "")

		if self.print_on then
			print("MainProber:Step2 -> " .. url .. "?" .. arg)
		end
	end
end

function MainProber:Info(st, ...)
	if self.countly_on and nil ~= st then
		local log = tostring(st)
		for i=1, select("#", ...) do
			log = log .. self.LOG_DELIMITER .. tostring(select(i, ...))
		end
		PlatformBinder:JsonCall("call_countly_log_info", log)
	end
end

function MainProber:Warn(st, ...)
	if self.countly_on and nil ~= st then
		local log = tostring(st)
		for i=1, select("#", ...) do
			log = log .. self.LOG_DELIMITER .. tostring(select(i, ...))
		end
		PlatformBinder:JsonCall("call_countly_log_warn", log)
	end
end

function MainProber:Error(log)
	if nil == log or nil ~= self.error_log then
		print(log)
		return
	end

	self.error_log = log

	if self.print_on or cc.PLATFORM_OS_WINDOWS == PLATFORM then
		print(log)
	end

	if self.countly_on then
		local assets_ver = ""
		if GLOBAL_CONFIG and GLOBAL_CONFIG.assets_info and GLOBAL_CONFIG.assets_info.version then
			assets_ver = tostring(GLOBAL_CONFIG.assets_info.version)
		end
		PlatformBinder:JsonCall("call_countly_script_error", log, assets_ver)
	end
	
	if self.screen_on then
		if nil == self.error_view then
			self.error_view = require("scripts/preload/prober_view")
		end

		if nil == self.error_alert_view and Alert then
			self:ShowErrorAlert()
		end
	end
end

function MainProber:ShowErrorAlert()
	if nil ~= self.error_alert_view then return end

	local ok_callback = function ()
		ReStart()
	end

	local cd = Auto_ReStart_Time
	function cd_callback(elapse_time, total_time)
		cd = math.max(cd - 1, 0 )
		self.error_alert_view:SetOkString(Language.Login.AutoReStart .. "(" .. cd .. ")")

		if elapse_time >= total_time then
			ok_callback()
		end
	end

	local dis_str = "亲爱的玩家，非常抱歉，游戏出现错误，我们已经进行记录，请您重新登录游戏，祝游戏愉快！"
	self.error_alert_view = Alert.New(dis_str, ok_callback, nil, nil, nil, false, false)
	self.error_alert_view.zorder = COMMON_CONSTS.ZORDER_ERROR
	self.error_alert_view:UseOne()
	self.error_alert_view:NoCloseButton()
	self.error_alert_view:SetBgOpacity(172)
	self.error_alert_view:Open()

	-- 移到右下角显示
	local screen_w = HandleRenderUnit:GetWidth()
	self.error_alert_view:GetRootNode():setPosition(screen_w - 10, 10)
	self.error_alert_view:GetRootNode():setAnchorPoint(1, 0)

	self.error_alert_view:SetOkString(Language.Login.AutoReStart .. "(" .. Auto_ReStart_Time .. ")")

	CountDown.Instance:RemoveCountDown(self.count_down)
	self.count_down = CountDown.Instance:AddCountDown(Auto_ReStart_Time, 1, cd_callback)
end

function MainProber:CloseView()
	if nil ~= self.error_view then
		self.error_view:Destroy()
		self.error_view = nil
	end
end

function MainProber:NetStateChanged(net_state)
	self.net_state = net_state
end