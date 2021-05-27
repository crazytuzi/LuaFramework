require("scripts/game/login/login_view")
require("scripts/game/login/role_create")
require("scripts/game/login/combine_select_role")
require("scripts/game/login/notice_view")

-- 登录
LoginController = LoginController or BaseClass(BaseController)

-- 名称服务器操作返回值定义
TAG_NAME_SERVER_OP_ERROR =
{
	SUCCESS = 0,					--操作成功
	INVALID_NAME = 1,				--名称无效，名称中包含非法字符或长度不合法
	DATA_BASE_ERROR = 2,			--名称服务器数据库操作错误
	DATA_BASE_CALL_ERROR = 3,		--名称服务器数据库调用错误
	NAMEINUSE = 4,					--名称已被使用
	TIME_OUT = 0xFFFF,				--操作超时（本地定义的错误，非名称服务器返回的错误）
}

-- 错误码定义
ERROR_DEFINITION = {
	NOERR					= 0,			--正确
	SQL						= 101,		--sql错误
	SESS					= 102,		--用户没登陆
	GAMESER					= 103,		--游戏服务没准备好
	DATASAVE				= 104,		--角色上一次保存数据是否出现异常
	SELACTOR				= 105,		--客户端选择角色的常规错误
	NOGATE					= 106,		--客户端无匹配的路由数据的错误
	NOUSER					= 107,		--角色不存在
	SEX						= 108,		--错误的性别
	NORANDOMNAME			= 109,		--随机生成的名字已经分配完
	ZY						= 110,		--客户端上传的角色阵营参数错误
	JOB						= 111,		--客户端上传的角色职业参数错误
	GUILD					= 112,		--存在帮派不能删除角色
	SELSERVER				= 113,		--选择服务器错误
	SQL_NOT_CONNECT			= 114,		--sql没有准备好
	PASSWD_ERR				= 115,		--密码错误
	PASSWD_EXIST			= 116,		--密码已经存在
	}

-- 登陆的时候返回的错误码
TAG_LOGIN_OP_ERROR = {
	SUCCESS = 0,	     				--操作成功
	PASSWD_ERROR =1,    				--密码错误
	NOACCOUNT=2,       					--没有这个账号
	IS_ONLINE =3,       				--已经在线
	SERVER_BUSY =4,     				--服务器忙
	SERVER_CLOSE =5,    				--服务器没有开放 
	SESSION_SERVER_ERROR =6 , 			--session服务器有问题，比如db没有连接好
	SERVER_NOT_EXISTING =7, 			--不存在这个服务器
	FCM_LIMITED =8 ,      				--账户纳入防沉迷
	SESSION_SERVER_CLOSE =9, 			--会话服务器处于关闭状态
	DB_SERVER_CLOSE =10,     			--数据服务器处于关闭状态
	LOGIN_IP_LIMIT = 11,     			--登陆IP数量限制

	-- xsp modify begin 新会话服
	IP_ERROR = 12,    					--ip收到了限制
	IP_TOO_MANY_CONNECT = 13,    		--ip连接了太多
	IP_MD5_ERROR = 14,    				--Md5计算错误
	SIGN_OUTOF_DATE = 15,    			--发过来的时间已经过期了
	TIME_FORMAT_ERROR = 16,    			--前面的格式错误
	ACCOUNT_SEAL = 17,    				--登陆过封停的账户
	-- xsp modify end

}

CloseType = {
	CT_ACTORDEL = 0,			-- 角色被删除
	CT_OTHERLOGIN = 1,			-- 在别的手机登录
	CT_NORMALLOGIN = 2,		 	-- 常规被踢下线
	CT_CLIENTOUTTIME = 3,		-- 客户端心跳包超时
	CT_USEWAIGUA = 4,			-- 使用外挂
	CT_GMKICKOUT = 5,			-- GM踢下线
	CT_CROSSLIMIT = 6,			-- 跨服限制
	CT_CROSSLOGIN = 7,			-- 跨服下线
	CT_CROSSREPEATLOGIN = 8,	-- 跨服重复登录
	CT_BACKSTAGEKICKOUT = 9,	-- 后台踢下线
}

Auto_ReStart_Time = 5 			--自动重连时间
RESTART_WAIT_TIME = 5 			--重连等待时间(留一些时间给服务器处理掉线)

LOGIN_STATE_PLAT_LOGIN = 0
LOGIN_STATE_SERVER_LIST = 1
LOGIN_STATE_CREATE_ROLE = 2
LOGIN_STATE_LOADING = 3
LOGIN_VERIFY_KEY = "566713d23b8810efb313d6934cf77610" 
function LoginController:__init()
	if LoginController.Instance ~= nil then
		ErrorLog("[LoginController] attempt to create singleton twice!")
		return
	end
	LoginController.Instance = self

	self.login_server_heartbeat_timer = nil
	self.game_server_connect_times = 0
	self.loginview = LoginView.New()
	self.createroleview = RoleCreateView.New()
	self.combine_select_role_view = CombineSelectRoleView.New()
	self.notice_view = NoticeView.New(ViewDef.Notice)
	self.user_agreement = NoticeView.New(ViewDef.UserAgreement) -- 用户协议
	self.privacy_policy = NoticeView.New(ViewDef.PrivacyPolicy) -- 隐私保护政策

	self.disconnect_alert = nil
	self.fail_alert = nil							-- 失败弹出框
	self.enter_gs_count = 0
	self.enter_gs_timer = nil

	self:RegisterAllProtocols()						-- 注册所有协议
	self:RegisterAllEvents()						-- 注册所有需要监听的事件

	self.is_opening_animation_fun = true 	 		-- 是否开启登陆动画功能

	self.is_game_server_connect_success = false
	self.is_login_verifying = false					-- 是否登录验证中

	self.login_state = LOGIN_STATE_PLAT_LOGIN
	require(AGENT_PATH .. "agent_login_view")
	self.agent_login_view = AgentLoginView.New()	-- 渠道相关的登录界面
	self.has_select_role = false
	AgentMs:InitLimitInfo()
	if AgentMs.RegisterEvents then
		AgentMs:RegisterEvents()
	end
	self.ip = PlatformAdapter.GetServerIp()	
	self.agreement_state = nil 						-- 协议确认状态 0-未同意 1-已同意 2-请求状态
	self.agreement_state_alert = nil
end

function LoginController:__delete()
	LoginController.Instance = nil

	self.loginview:DeleteMe()
	self.loginview = nil

	if nil ~= self.combine_select_role_view then
		self.combine_select_role_view:DeleteMe()
		self.combine_select_role_view = nil
	end

	if nil ~= self.createroleview then
		self.createroleview:DeleteMe()
		self.createroleview = nil
	end
	if nil ~= self.disconnect_alert then
		self.disconnect_alert:DeleteMe()
		self.disconnect_alert = nil
	end

	if nil ~= self.fail_alert then
		self.fail_alert:DeleteMe()
		self.fail_alert = nil
	end

	if nil ~= self.enter_gs_timer then
		GlobalTimerQuest:CancelQuest(self.enter_gs_timer)
		self.enter_gs_timer = nil
	end

	if nil ~= self.agreement_state_alert then
		self.agreement_state_alert:DeleteMe()
		self.agreement_state_alert = nil
	end

	self.agent_login_view:DeleteMe()
	self.agent_login_view = nil

	self.notice_view:DeleteMe()
	self.notice_view = nil

	self.user_agreement:DeleteMe()
	self.user_agreement = nil

	self.privacy_policy:DeleteMe()
	self.privacy_policy = nil
end

function LoginController:RegisterAllProtocols()
	self:RegisterProtocol(SCLoginFailAck, "OnLoginFailAck")
	self:RegisterProtocol(SCRoleListAck, "OnRoleListAck")
	self:RegisterProtocol(SCCreateRoleAck, "OnCreateRoleAck")
	self:RegisterProtocol(SCDelRoleAck, "OnDelRoleAck")
	self:RegisterProtocol(SCDisconnectServerNotice, "OnDisconnectServerNotice")
	self:RegisterProtocol(SCServerReqSentHttpReq, "OnServerReqSentHttpReq")
end

function LoginController:RegisterAllEvents()
	GlobalEventSystem:Bind(AppEventType.GAME_START_COMPLETE, BindTool.Bind(self.OnGameStartComplete, self))
	GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.OnConnectGameServer, self))
	GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectGameServer, self))
	GlobalEventSystem:Bind(LoginEventType.END_OPENING_ANIMATION, BindTool.Bind(self.EndOpenAnimation, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
end

function LoginController:OnGameStartComplete()
	LoginController.Instance:StartLogin()			-- 登录
end

function LoginController:StartLogin()
	-- 添加跨服标记
	local cs_info_str = AdapterToLua:getInstance():getDataCache("CROSS_SERVER_INFO")
	local is_reconnect_ing = AdapterToLua:getInstance():getDataCache("IS_RECONNECT_ING")
	if cs_info_str and cs_info_str ~= "" and is_reconnect_ing and is_reconnect_ing == "true" then
		IS_ON_CROSSSERVER = true
	else
		AdapterToLua:getInstance():setDataCache("CROSS_SERVER_INFO", "")
		IS_ON_CROSSSERVER = false
	end
	if (not IS_ON_CROSSSERVER and not self:GetIsReConnectIng()) or not self.loginview:IsLoadedIndex(0) then
		self.loginview:Open()
		if AdapterToLua:getInstance():getDataCache("HAS_OPEN_NOTICE") ~= "true" and not IS_AUDIT_VERSION then
			AdapterToLua:getInstance():setDataCache("HAS_OPEN_NOTICE", "true")
			self.notice_view:Open()
		end
		self.notice_view:Open()
	end

	if self:GetIsReConnectIng() then
		if AgentAdapter.Init then
			AgentAdapter:Init()
		end
		self:Reconnect()
	else
		MainProber:Step(MainProber.STEP_AGENT_LOGIN_BEG)
		self:AgentLoginViewOpen(false)
	end
	Log("StartLogin ... ")
end

function LoginController:AgentLoginViewOpen(only_visible)
	if only_visible then
		if self.agent_login_view:IsLoaded() then
			self.agent_login_view:Open()
			self.login_state = LOGIN_STATE_PLAT_LOGIN
		end
	else
		self.agent_login_view:Open()
		self.login_state = LOGIN_STATE_PLAT_LOGIN
	end
end

function LoginController:AgentLoginViewClose(only_hide)
	if only_hide then
		if self.agent_login_view:IsOpen() then
			self.agent_login_view:CloseVisible()
		end
	else
		self.agent_login_view:Close()
	end
end

function LoginController:AgentLoginViewIsOpen()
	return self.agent_login_view:IsOpen()
end

function LoginController:GetLoginState()
	return self.login_state
end

function LoginController:ResetConnectCount()
	self.game_server_connect_times = 0
end

-- 登录平台成功回调，session_id不为nil则会发送到php后台验证session_id是否合法
function LoginController:LoginPlatSucc(account_name, session_id)
	local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
	if agent_id == "dev" or agent_id == "alz" then
		self:RequestAgreementState(2, account_name) -- 请求"用户协议确认状态"
	end

	if GameVoManager.Instance:GetUserVo():GetNowRole() > 0 then
		-- 该帐号已进入游戏
		return
	end

	if self.is_login_verifying then
		return
	end

	MainProber:Step(MainProber.STEP_AGENT_LOGIN_END)
	AdapterToLua:getInstance():setDataCache("PRVE_ACCOUNT_NAME", account_name)

	self.login_state = LOGIN_STATE_SERVER_LIST

	self:LoginVerifyByPhp(account_name, session_id, function(is_succ)
		MainProber:Step(MainProber.STEP_PHP_VERIFY_END or 206, tostring(is_succ))
		if MainProber.Step2 then MainProber:Step2(700, MainProber.user_id, tostring(is_succ)) end

		if is_succ then
			self.loginview:OnLoginPlatSucc()
		end
	end)
end
function LoginController:SendLoginCallBack(account_name, password, data)
	
	if nil == data then
		SysMsgCtrl.Instance:ErrorRemind("登录超时，请稍后再试", true)
	return 
	end
	
	local init_info = cjson.decode(data);
	if init_info == nil then
	return 
	end
	--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
	if tostring(init_info.code) ==  "0" then
		local account_name = cc.UserDefault:getInstance():getStringForKey("last_account")
		self:LoginPlatSucc(account_name)
		self.agent_login_view:setInitPage()							 
		SysMsgCtrl.Instance:ErrorRemind("登陆成功", true)
	elseif tostring(init_info.code) ==  "1" then
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
	elseif tostring(init_info.code) ==  "2" then
			SysMsgCtrl.Instance:ErrorRemind("当前账号不存在,请注册账号！", true)
	elseif tostring(init_info.code) ==  "3" then
		SysMsgCtrl.Instance:ErrorRemind("密码错误,请重新输入", true)
	elseif tostring(init_info.code) ==  "4" then
		SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
	elseif tostring(init_info.code) ==  "5" then
		SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
	elseif tostring(init_info.code) ==  "6" then
		SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
	elseif tostring(init_info.code) ==  "7" then
		SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
	elseif tostring(init_info.code) ==  "8" then
		SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
	elseif tostring(init_info.code) ==  "9" then
		SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
	else
		SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
	end
end
-- 通过php验证登录是否合法，取得服务端登录凭证
function LoginController:LoginVerifyByPhp(account_name, session_id, callback_func, times)
	local user_vo = GameVoManager.Instance:GetUserVo()
	user_vo.plat_name = account_name

	if MainProber.Step2 then
		if string.len(account_name) > 4 then
			MainProber.user_id = string.sub(account_name, 5, -1)
		else
			MainProber.user_id = account_name
		end
		MainProber:Step2(600, MainProber.user_id, GLOBAL_CONFIG.param_list.verify_url)
	end

	if nil ~= session_id and "" ~= session_id and string.len(account_name) > 4 then
		local spid = string.sub(account_name, 1, 3)
		local uid = string.sub(account_name, 5, -1)
		local now_server_time = math.floor(GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time))

		local try_times = times or 1
		local verify_url = GLOBAL_CONFIG.param_list.verify_url
		if 0 == math.mod(try_times, 2) and nil ~= GLOBAL_CONFIG.param_list.verify_url2 then
			verify_url = GLOBAL_CONFIG.param_list.verify_url2
		end

		local sign = UtilEx:md5Data(spid .. uid .. session_id .. now_server_time .. LOGIN_VERIFY_KEY)
		local real_url = string.format("%s?spid=%s&uid=%s&sid=%s&time=%s&sign=%s&device=%s", 
			verify_url, spid, uid, session_id, now_server_time, sign, tostring(PlatformAdapter.GetPhoneUniqueId()))
		Log("LoginVerifyByPhp, url=" .. real_url)
		user_vo.plat_is_verify = false

		self.is_login_verifying = true
		HttpClient:Request(real_url, "", function(url, arg, data, size)
			Log("LoginVerifyByPhp, callback", url, size, "data:", data)

			if not self.is_login_verifying then
				return
			end

			self.is_login_verifying = false

			if size <= 0 then
				if try_times < 4 then
					self:LoginVerifyByPhp(account_name, session_id, callback_func, try_times + 1)
					return
				end

				if nil ~= callback_func then
					callback_func(false)
				end
				return
			end

			local ret_t = cjson.decode(data)
			if nil == ret_t or 0 ~= ret_t.ret or nil == ret_t.user or ret_t.user.account ~= user_vo.plat_name then
				Log("LoginVerifyByPhp, fail")
				if nil ~= callback_func then
					callback_func(false)
				end
				return
			end

			self:SetLoginUserData(user_vo.plat_name, ret_t.user)

			Log("LoginVerifyByPhp, success")
			if nil ~= callback_func then
				callback_func(true)
			end
		end)
	else
		user_vo.plat_is_verify = true
		if nil ~= callback_func then
			callback_func(true)
		end
	end
end

function LoginController:SetLoginUserData(acount_name, user)
	local user_vo = GameVoManager.Instance:GetUserVo()
	user_vo.plat_is_verify = true
	user_vo.plat_account_type = user.account_type
	user_vo.plat_fcm = user.fcm_flag
	user_vo.plat_login_time = user.login_time
	user_vo.plat_session_key = user.login_sign

	user_vo.plat_name = acount_name

	AdapterToLua:getInstance():setDataCache("PRVE_PLAT_ACCOUNT_TYPE", tostring(user_vo.plat_account_type))
	AdapterToLua:getInstance():setDataCache("PRVE_PLAT_FCM", tostring(user_vo.plat_fcm))
	AdapterToLua:getInstance():setDataCache("PRVE_PLAT_LOGIN_TIME", tostring(user_vo.plat_login_time))
	AdapterToLua:getInstance():setDataCache("PRVE_PLAT_SESSION_KEY", tostring(user_vo.plat_session_key))
end

function LoginController:EndOpenAnimation()
	self:DoOpenCreateRoleView()
end

function LoginController:OnRecvMainRoleInfo()
	self.has_select_role = true  
	if self.combine_select_role_view then
		self.combine_select_role_view:Close()
	end
	self:DoLogin()
end

function LoginController:OnConnectGameServer(is_succ)
	if self.delay_quick_reconnect then
		GlobalTimerQuest:CancelQuest(self.delay_quick_reconnect)
  		self.delay_quick_reconnect = nil
	end
	if is_succ then
		local user_vo = GameVoManager.Instance:GetUserVo()
		-- 选择区服上报
		local zone_name = user_vo.plat_server_id .. "服-" .. user_vo.plat_server_name
		if nil ~= AgentAdapter.SelectAreaClothing then
			AgentAdapter:SelectAreaClothing(user_vo.plat_server_id, zone_name)
		end

		self:ResetConnectCount()
		self:SendLoginReq()
	else
		if self.login_state == LOGIN_STATE_PLAT_LOGIN then
			return
		end
		Log("Login::game_server_connect_fail")
		self.game_server_connect_times = self.game_server_connect_times + 1
		local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
		if self.game_server_connect_times >= 5 then
			if quick_reconnect == "true" then
				if nil ~= MainLoader.CloseReconnectView then
					MainLoader:CloseReconnectView()
				end
				self.has_select_role = false
				AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "false")
				AdapterToLua:getInstance():setDataCache("QUICK_RECONNECT", "false")
				self:OnDisconnectGameServer(GameNet.DISCONNECT_REASON_NORMAL)
			else
				self:ReconnectFail()
				self:OpenFailAlert(Language.Login.ConnectGameServerFailTip)
			end
		else
			local str = Language.Login.ReconnectGameServer .. self.game_server_connect_times
			Log(str)
			if quick_reconnect ~= "true" then
				SysMsgCtrl.Instance:ErrorRemind(str, true)
			end
			GameNet.Instance:AsyncConnectGameServer(3)
		end
	end
end

function LoginController:OnDisconnectGameServer(disconnect_reason, need_tips)
	if GameNet.DISCONNECT_REASON_SILENT_LOGIN == disconnect_reason then
		return
	elseif GameNet.DISCONNECT_REASON_CROSSLOGIN == disconnect_reason then
	elseif GameNet.DISCONNECT_REASON_KICKOUT == disconnect_reason then
		-- 被踢下线
		if AgentAdapter.OnClickRestartGame then
			AgentAdapter.OnClickRestartGame()
		else	
			ReStart()
		end
		return
	elseif GameNet.DISCONNECT_REASON_NORMAL == disconnect_reason and self.has_select_role
		and not need_tips and MainLoader.OpenReconnectView and not IS_ON_CROSSSERVER then
		self:QuickReconnect()
		return
	end

	if self:GetIsReConnectIng() then
		self:StartLogin()
		return
	end

	GuideCtrl.Instance:EndGuide()
	
	if nil == self.disconnect_alert then
		self.disconnect_alert = Alert.New()
		self.disconnect_alert.zorder = COMMON_CONSTS.ZORDER_SYSTEM_HINT + 1
		self.disconnect_alert:SetModal(true)
		self.disconnect_alert:SetIsAnyClickClose(false)
	end
	local ok_callback = nil
	local dis_str = ""
	local ok_str = ""
	if disconnect_reason == GameNet.DISCONNECT_REASON_BE_DEL
	or disconnect_reason == GameNet.DISCONNECT_REASON_MULTI_LOGIN then
		ok_callback = function ()
			if AgentAdapter.OnClickRestartGame then
				AgentAdapter.OnClickRestartGame()
			else	
				ReStart()
			end
		end
		if disconnect_reason == GameNet.DISCONNECT_REASON_BE_DEL then
			dis_str = Language.Common.Disconnect2
		else
			dis_str = Language.Login.MultiLogin
		end
		ok_str = Language.Login.ReLogin
	else
		ok_callback = function ()
			AdapterToLua:getInstance():setDataCache("GUA_JI_TYPE", GuajiCache.guaji_type)
			if self.has_select_role then
				AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
			end
			if IS_ON_CROSSSERVER then
				-- CrossServerCtrl.Instance:OnReturnOriginalServer({})
				-- return
			end
		 	ReStart()
		end
		dis_str = Language.Common.Disconnect
		ok_str = Language.Login.AutoReStart
	end
	self.disconnect_alert:SetLableString(dis_str)
	if disconnect_reason ~= GameNet.DISCONNECT_REASON_BE_DEL then
		self.disconnect_alert:SetOkString(ok_str)
	else
		self.disconnect_alert:SetOkString(ok_str .. "(" .. Auto_ReStart_Time .. ")")
		local cd = Auto_ReStart_Time
		local function cd_callback()
			cd = math.max(cd - 1, 0 )
			self.disconnect_alert:SetOkString(ok_str.. "(" .. cd .. ")")
		end
		-- CountDownManager.Instance:RemoveCountDown("re_start")
		-- CountDownManager.Instance:AddCountDown("re_start", cd_callback, ok_callback, nil, Auto_ReStart_Time, 1)
	end
	self.disconnect_alert.zorder = COMMON_CONSTS.ZORDER_ENDGAME
	self.disconnect_alert:SetOkFunc(ok_callback)
	self.disconnect_alert:Open()
	self.disconnect_alert:NoCloseButton()
	self.disconnect_alert:UseOne()
end

function LoginController:QuickReconnect()
	if AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT") == "true" then return end
	AdapterToLua:getInstance():setDataCache("GUA_JI_TYPE", GuajiCache.guaji_type)
	AdapterToLua:getInstance():setDataCache("SCENE_ID", Scene.Instance:GetSceneId())
	AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
	AdapterToLua:getInstance():setDataCache("QUICK_RECONNECT", "true")
	TeamCtrl.Instance:OnRemoveTeammate({role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)})
	ViewManager.Instance:CloseAllView()

	MainLoader:OpenReconnectView()
	GlobalTimerQuest:AddDelayTimer(function()
		local function AsyncConnectGameServerDelay()
			GameNet.Instance:AsyncConnectGameServer(5, false)
			self.delay_quick_reconnect = GlobalTimerQuest:AddDelayTimer(AsyncConnectGameServerDelay, 6)
		end
		AsyncConnectGameServerDelay()
	end, RESTART_WAIT_TIME)
end

function LoginController:SendLoginReq()
	local user_vo = GameVoManager.Instance:GetUserVo()

	local original_merge_id = AdapterToLua:getInstance():getDataCache("CROSS_BEFORE_MERGE_ID")
	original_merge_id = (original_merge_id and original_merge_id ~= "") and tonumber(original_merge_id) or 0
	local protocol = ProtocolPool.Instance:GetProtocol(CSLoginReq)
	protocol.account = user_vo.plat_name
	protocol.password = UtilEx:md5Data("000")
	protocol.server_span_id = user_vo.merge_id or user_vo.plat_server_id
	protocol.server_id = original_merge_id ~= 0 and original_merge_id or protocol.server_span_id

	protocol.plat_info = protocol.spid
	Log("SendLoginReq.plat_info", protocol.plat_info, protocol.server_id, protocol.server_span_id, user_vo.merge_id)

	if PlatformAdapter.GetDeviceType then
		local device_type =  PlatformAdapter.GetDeviceType()
		local device_id = ""
		if cc.PLATFORM_OS_ANDROID == PLATFORM then
			device_id = PlatformAdapter.GetPhoneUniqueIMEI()
		elseif cc.PLATFORM_OS_IPHONE == PLATFORM 
		or cc.PLATFORM_OS_IPAD == PLATFORM 
		or cc.PLATFORM_OS_MAC == PLATFORM then
			device_id = PlatformAdapter.GetPhoneUniqueId()
		end
		local ip_address = PlatformAdapter.GetIpAddress()
		local vsersion = PlatformAdapter.GetPhoneVsersion()
		protocol.dev_info = device_type .. "," .. device_id .. "," .. ip_address .. "," .. vsersion
		Log("SendLoginReq.dev_info", protocol.dev_info)
		if not IS_ON_CROSSSERVER then
			PlatformAdapter:SaveShareValue(AgentAdapter:GetPlatName() .. "last_login_server", user_vo.plat_server_id)
		end
	end

	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNetId())
end

function LoginController:OnLoginFailAck(protocol)
	Log("登录失败", protocol.error_code)

	self:RemoveWaitingEffect()
	
	if 1 == protocol.error_code then
	elseif 2 == protocol.error_code then
		-- self:SendCreateAccountReq()
	elseif 3 == protocol.error_code then
	end

	-- enSuccess = 0,	     //操作成功
	-- enPasswdError =1,    //密码错误
	-- enNoAccount=2,       //没有这个账号
	-- enIsOnline =3,       //已经在线
	-- enServerBusy =4,     //服务器忙
	-- enServerClose =5,    //服务器没有开放 
	-- enSessionServerError =6 , //ssion服务器有问题，比如db没有连接好
	-- enServerNotExisting =7, //不存在这个服务器
	-- enFcmLimited =8 ,      //账户纳入防沉迷
	-- enSessionServerClose =9, //会话服务器处于关闭状态
	-- enDbServerClose =10,     //数据服务器处于关闭状态
	-- enLoginIpLimit = 11,     //登陆IP数量限制
	-- enIpError = 12,    //ip收到了限制
	-- enIpTooManyConnect = 13,    //ip连接了太多
	-- enIpMd5Error = 14,    //Md5计算错误
	-- enSignOutofDate = 15,    //发过来的时间已经过期了
	-- enTimeFormatError = 16,    //前面的格式错误
	-- enAccountSeal = 17,    //登陆过封停的账户
end

function LoginController:SendCreateAccountReq()
	Log("LoginController:SendCreateAccountReq")
	local user_vo = GameVoManager.Instance:GetUserVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateAccountReq)
	protocol.account = user_vo.plat_name
	protocol.password = UtilEx:md5Data("000")
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNetId())
end

function LoginController:SendRoleListReq()
	Log("LoginController:SendRoleListReq")
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleListReq)
	protocol:EncodeAndSend()
end

function LoginController:OnRoleListAck(protocol)
	LogT("OnRoleListAck", protocol.role_count)
	self.has_select_role = false
	MainProber:Step2(900, MainProber.user_id, MainProber.server_id)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if 0 == protocol.role_count and not IS_ON_CROSSSERVER then
		user_vo:ClearRoleList()
		self:RemoveWaitingEffect()
		if self:IsLimitServerWithSpid() then
		else
			if IS_AUDIT_VERSION then
				self:CreateRoleEnterGame()
			else
				self:DoOpenCreateRoleView()
			end
		end
	else
		user_vo:ClearRoleList()
		user_vo.account_id = protocol.account_id
		for i, v in ipairs(protocol.role_list) do
			user_vo:AddRole(v)
			if self.create_role == v.role_name then
				user_vo:SetNowRole(v.role_id, v.role_name)
			end
		end
		local is_reconnect_ing = AdapterToLua:getInstance():getDataCache("IS_RECONNECT_ING")
		local is_reselectrole = AdapterToLua:getInstance():getDataCache("IS_RESELECTROLE")
		local last_role_id = tonumber(AdapterToLua:getInstance():getDataCache("SET_NOW_ROLE")) or 0
		local last_role_name = tonumber(AdapterToLua:getInstance():getDataCache("SET_NOW_ROLE_NAME")) or ""
		if is_reconnect_ing == "true" and last_role_id > 0 and is_reselectrole ~= "true" then
			user_vo:SetNowRole(last_role_id, last_role_name)
			user_vo:AddRole({role_id = last_role_id, role_name = last_role_name})
		end
		if (user_vo:GetNowRole() > 0 or is_reconnect_ing == "true") and is_reselectrole ~= "true" then
			if is_reconnect_ing == "true" then
				self:ReconnectSuccess()
			end
			self:DoLogin()
		else
			if is_reselectrole == "true" then
				self:ReconnectSuccess()
			end
			self:RemoveWaitingEffect()
			if IS_AUDIT_VERSION then
				self:TryEnterGameServer(protocol.role_list[1])
			else
				self:DoOpenCombineSelectRoleView()
			end
		end
	end
end

-- 直接创建角色进入游戏
function LoginController:CreateRoleEnterGame()
	local sex = math.random(0, 1)
	local prof = math.random(1, 3)
	local role_name = os.time()
	role_name = string.sub( role_name, string.len( role_name ) - 5, string.len( role_name ) ) 
	self:SendCreateRole(role_name, prof, sex)
end

function LoginController:DoLogin()
	self.login_state = LOGIN_STATE_LOADING
	self:RemoveWaitingEffect()
	self.loginview:OpenLoading()
	self:SendLoginRoleReq()
end

function LoginController:SendLoginRoleReq()
	local now_role_info = GameVoManager.Instance:GetUserVo():GetNowRoleInfo()
	if nil == now_role_info then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSLoginRoleReq)
	protocol.account_id = GameVoManager.Instance:GetUserVo().account_id
	protocol.role_id = now_role_info.role_id
	protocol:EncodeAndSend()
end

function LoginController:DoOpenCreateRoleView()
	self.createroleview:Open()
	self.createroleview:OpenRoleCreate()
end

function LoginController:DoOpenCombineSelectRoleView()
	self.combine_select_role_view:Open()
	self.combine_select_role_view:OpenRoleSelect()
end

function LoginController:CreateRoleViewReturnLogin()
	GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_SILENT_LOGIN)
	self.login_state = LOGIN_STATE_SERVER_LIST
	self.loginview:SetLoginVisible(true)
	if self.loginview.sec_server_list then
		self.loginview.sec_server_list:SelectIndex(1)
	end
	self.loginview:SelectTabCallback(1)
end

function LoginController:SendCreateRole(role_name, prof, sex)
	Log("Login::LoginController:SendCreateRole", role_name, prof, sex)
	self:ShowWaitingEffect()

	local user_vo = GameVoManager.Instance:GetUserVo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCreateRoleReq)
	local merge_id = GameVoManager.Instance:GetUserVo().merge_id or GameVoManager.Instance:GetUserVo().plat_server_id
	self.create_role = "s" .. merge_id .. "." .. role_name
	send_protocol.name = self.create_role
	send_protocol.sex = sex
	send_protocol.prof = prof
	send_protocol.avatar = 0
	send_protocol.camp = 0
	send_protocol.spid = AgentAdapter:GetSpid()
	send_protocol.adid = 0
	send_protocol:EncodeAndSend()
end

function LoginController:SendDelRoleReq(role_id)
	Log("Login::LoginController:SendDelRoleReq", role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDelRoleReq)
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

function LoginController:TryEnterGameServer(role_vo)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if role_vo then
		user_vo:SetNowRole(role_vo.role_id, role_vo.role_name)
		self.send_role_req_flag = true
		self:SendLoginRoleReq()
	end
end

function LoginController:OnCreateRoleAck(protocol)
	LogT("====OnCreateRoleAck", protocol.role_id, protocol.result)
	if 0 == protocol.result then
		self:SendRoleListReq()
		if self.createroleview then
			self.createroleview:Close()
		end

		MainProber.role_id = protocol.role_id
		MainProber:Step2(1100, MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id)

		-- 标记一下角色创建，用于创建角色上报
		RoleCtrl.ROLE_CREATED = true
	else
		self:RemoveWaitingEffect()
		if Language.Login.CreateRoleResultTip[protocol.result] then
			SysMsgCtrl.Instance:ErrorRemind(Language.Login.CreateRoleResultTip[protocol.result], true)
		end
	end
end

function LoginController:OnDelRoleAck(protocol)
	LogT("====OnDelRoleAck", protocol.role_id, protocol.result)
	if 0 == protocol.result then
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:RemoveRole(protocol.role_id)
		if self.combine_select_role_view:IsOpen() then
			self.combine_select_role_view:UpdateRoleList()
		end
	end
end


function LoginController:OnDisconnectServerNotice(protocol)
	LogT("====OnDisconnectServerNotice", protocol.reason)
	if protocol.reason == CloseType.CT_ACTORDEL then
		GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_BE_DEL)
	elseif protocol.reason == CloseType.CT_NORMALLOGIN
		or protocol.reason == CloseType.CT_GMKICKOUT
		or protocol.reason == CloseType.CT_BACKSTAGEKICKOUT then
		GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_KICKOUT)
	elseif protocol.reason == CloseType.CT_OTHERLOGIN then
		GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_MULTI_LOGIN)
	-- elseif protocol.reason == CloseType.CT_CROSSLOGIN then
	-- 	GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_CROSSLOGIN)
	-- 	local cs_info_str = AdapterToLua:getInstance():getDataCache("CROSS_SERVER_INFO")
	-- 	if cs_info_str and "" ~= cs_info_str then
	-- 		local list = Split(cs_info_str, "##")
	-- 		local cs_server_data = {}
	-- 		cs_server_data.id = list[1]						-- 服务器ID
	-- 		cs_server_data.name = list[2]					-- 服务器名字
	-- 		cs_server_data.ip = list[3]						-- 登录服务器IP
	-- 		cs_server_data.port = list[4]					-- 登录服务器端口

	-- 		local user_vo = GameVoManager.Instance:GetUserVo()
	-- 		user_vo.plat_name = AdapterToLua:getInstance():getDataCache("PRVE_ACCOUNT_NAME")
	-- 		user_vo.plat_server_id = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_SRVER_ID")) or 0
	-- 		user_vo.merge_id = tonumber(AdapterToLua:getInstance():getDataCache("MERGE_ID")) or 0
	-- 		user_vo.plat_account_type = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_ACCOUNT_TYPE")) or 0
	-- 		user_vo.plat_fcm = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_FCM")) or 0
	-- 		user_vo.plat_login_time = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_LOGIN_TIME")) or 0
	-- 		user_vo.plat_session_key = AdapterToLua:getInstance():getDataCache("PRVE_PLAT_SESSION_KEY")
	-- 		IS_ON_CROSSSERVER = true

	-- 		self.loginview:Open()
	-- 		self.loginview:OpenLoading()

	-- 		local game_net = GameNet.Instance
	-- 		game_net:SetGameServerInfo(cs_server_data.ip, cs_server_data.port)
	-- 		local function AsyncConnectGameServerDelay()
	-- 			GameNet.Instance:AsyncConnectGameServer(5, false)
	-- 			self.delay_quick_reconnect = GlobalTimerQuest:AddDelayTimer(AsyncConnectGameServerDelay, 6)
	-- 		end
	-- 		AsyncConnectGameServerDelay()
	-- 	end
	else
		GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_NORMAL)
	end
	
end

function LoginController:Reconnect()
	if self:GetIsReConnectIng() then
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo.plat_name = AdapterToLua:getInstance():getDataCache("PRVE_ACCOUNT_NAME")
		user_vo.plat_server_id = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_SRVER_ID")) or 0
		user_vo.merge_id = tonumber(AdapterToLua:getInstance():getDataCache("MERGE_ID")) or 0
		user_vo.plat_account_type = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_ACCOUNT_TYPE")) or 0
		user_vo.plat_fcm = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_FCM")) or 0
		user_vo.plat_login_time = tonumber(AdapterToLua:getInstance():getDataCache("PRVE_PLAT_LOGIN_TIME")) or 0
		user_vo.plat_session_key = AdapterToLua:getInstance():getDataCache("PRVE_PLAT_SESSION_KEY")
		
		local cs_info_str = AdapterToLua:getInstance():getDataCache("CROSS_SERVER_INFO")
		if nil ~= cs_info_str and "" ~= cs_info_str then
			local list = Split(cs_info_str, "##")
			user_vo.plat_server_id = list[1]
			-- user_vo.plat_name = list[2]
		end
		user_vo.plat_is_verify = true
		Log("Loggin::start_reconnect plat_name:" .. user_vo.plat_name .. ",plat_server_id:" .. user_vo.plat_server_id)
		self.loginview:Reconnect()
	end
end

function LoginController:ReconnectSuccess()
	if self:GetIsReConnectIng() then
		Log("Loggin::reconnect_success")
		self:EndReconnect()
	end
end

function LoginController:ReconnectFail()
	if self:GetIsReConnectIng() then
		Log("Loggin::reconnect_fail")
		self.loginview:Open()
		self:AgentLoginViewOpen(false)
		self.loginview:SetLoginVisible(false)
		self:EndReconnect()
	end
end

function LoginController:EndReconnect()
	Log("Loggin::reconnect_end")
	AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "false")
	AdapterToLua:getInstance():setDataCache("QUICK_RECONNECT", "false")
	AdapterToLua:getInstance():setDataCache("IS_RESELECTROLE", "false")
	AdapterToLua:getInstance():setDataCache("CROSS_SERVER_INFO", "")
end

--是否在重连中
function LoginController:GetIsReConnectIng()
	local name = AdapterToLua:getInstance():getDataCache("PRVE_ACCOUNT_NAME")
	local is_reconnect_ing = AdapterToLua:getInstance():getDataCache("IS_RECONNECT_ING")
	return name ~= "" and is_reconnect_ing ~= "" and is_reconnect_ing == "true"
end

function LoginController:OpenFailAlert(str)
	self:RemoveWaitingEffect()
	
	GameNet.Instance:DisconnectGameServer()

	if nil == self.fail_alert then
		self.fail_alert = Alert.New()
		local function ok_callback()
			-- if nil ~= self.createroleview then
			-- 	self.createroleview:DeleteMe()
			-- 	self.createroleview = RoleCreateView.New()
			-- end
			-- self.agent_login_view:DeleteMe()
			-- self.agent_login_view = AgentLoginView.New()
			-- self:AgentLoginViewOpen(false)

			-- self.loginview:DeleteMe()
			-- self.loginview = LoginView.New()
			-- self.loginview:Open()
		end
		local function cancel_callback()
			AdapterToLua:endGame()
		end

		self.fail_alert = Alert.New("", ok_callback, cancel_callback)
		self.fail_alert.is_checkvisible_onopen = true  --在开头动画中隐藏面板时不应该出现
		self.fail_alert.zorder = COMMON_CONSTS.ZORDER_MAX
		self.fail_alert:SetModal(true)
		-- self.fail_alert:SetIsAnyClickClose(false)
		self.fail_alert:SetOkString(Language.Login.ReLogin)
		self.fail_alert:SetCancelString(Language.Login.EndGame)
	end

	self.fail_alert:SetLableString(str)
	self.fail_alert:Open()
	self.fail_alert:NoCloseButton()
end

function LoginController:ShowWaitingEffect(is_force_show)
	local is_show = is_force_show or (self.loginview:GetIsInSelectServerView() or self.createroleview:IsOpen())
	if nil == self.connecting_effect and is_show then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1220)
		self.connecting_effect = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.1, 15)
		self.connecting_effect:setScale(1.6)
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.connecting_effect:setPosition(screen_w / 2, screen_h / 2)
		HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.connecting_effect, GRQ_UI_UP)
	end
end

function LoginController:RemoveWaitingEffect()
	if nil ~= self.connecting_effect then
		self.connecting_effect:removeFromParent()
		self.connecting_effect = nil
	end
end

function LoginController:ExitReq()
	-- local send_protocol = ProtocolPool.Instance:GetProtocol(CSDisconnectReq)
	-- send_protocol:EncodeAndSend(GameNet.Instance:GetGameServerNetId())
end

function LoginController:OnServerReqSentHttpReq(protocol)
	if "" ~= protocol.url then
		HttpClient:Request(protocol.url, "")
	end
end

function LoginController:IsLimitServerWithSpid(spid)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local limit_day = user_vo.create_role_limit_day
	local server_id = user_vo.plat_server_id or 0

	--1501为审核服 开放注册
	if limit_day and limit_day > 0 and server_id ~= 1501 then
		local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time)
		if 0 < user_vo.open_time then
			local time_space = now_server_time - user_vo.open_time
			local compare_time = limit_day * 24 * 3600  --开服限制天以上
			if time_space > compare_time then
				if nil == self.limit_alert then
					self.limit_alert = Alert.New("")
					self.limit_alert.zorder = COMMON_CONSTS.ZORDER_MAX
					self.limit_alert:SetModal(true)
					self.limit_alert:SetIsAnyClickClose(false)
					self.limit_alert:SetOkString(Language.Common.Confirm)
					self.limit_alert:SetCancelString(Language.Common.Cancel)
				end

				self.limit_alert:SetLableString(Language.Common.Disconnect11)
				self.limit_alert:Open()
				self.limit_alert:NoCloseButton()
				GameNet.Instance:DisconnectGameServer(GameNet.DISCONNECT_REASON_SILENT_LOGIN)
				return true
			end
		end
	end

	return false
end


function LoginController:RequestAgreementState(state, account_name)
	local params = {}
	local sign = "";
	params.spid = AgentAdapter:GetSpid()								--平台ID     spid
	params.plat_user_name = account_name or AgentAdapter:GetPlatName()					--平台帐号	 plat_user_name
	params.state = state		--状态 0-未同意 1-已同意 2-请求状态
	local sign = UtilEx:md5Data(params.plat_user_name .. "&" .. 123456 .. "&" .. 1242821087)
	local url_format = PlatformAdapter.GetServerIp().."/api/user/check_state.php?spid=%s&account=%s&state=%s&sign=%s"
	local url_str = string.format(url_format, params.spid, params.plat_user_name, params.state , sign)
	--Log("url_str==========" .. url_str)
	HttpClient:Request(url_str, "", 
		function(url, arg, data, size)
			if nil == data then
				Log("--->>>ReqAgreementState data is nil")
				return
			end

			if size <= 0 then
				Log("--->>>ReqAgreementState size <= 0")
				return
			end
			
			local ret_t = cjson.decode(data)
			if nil ~= ret_t and nil ~= ret_t.ret then
				Log("用户协议确认状态", ret_t.ret)
				local state = tonumber(ret_t.ret)
				if state ~= 1 then
					if self:GetAgreementState() == 1 then
						self:RequestAgreementState(1)
					else
						if nil == self.agreement_state_alert then
							self.agreement_state_alert = Alert.New()
							self.agreement_state_alert.zorder = COMMON_CONSTS.ZORDER_SYSTEM_HINT + 1
							self.agreement_state_alert:SetModal(true)
							self.agreement_state_alert:SetIsAnyClickClose(false)
							self.agreement_state_alert:SetTitleString(Language.Common.YHXZ) -- 用户须知
							local str = Language.Login.AgreementContent1
							self.agreement_state_alert:SetLableString2(str, RichHAlignment.HA_CENTER, COLOR3B.GREEN)

							local function cancel_callback()
								if AgentAdapter.OnClickRestartGame then
									AgentAdapter.OnClickRestartGame()
								else
									ReStart()
								end
								self:SetAgreementState(0)
							end

							local function ok_callback()
								self:RequestAgreementState(1)
								self:SetAgreementState(1)
							end

							self.agreement_state_alert:SetOkString(Language.Common.Confirm)
							self.agreement_state_alert:SetCancelString(Language.Common.Cancel)
							self.agreement_state_alert:SetLableString(Language.Login.AgreementContent2)
							self.agreement_state_alert:SetOkFunc(ok_callback)
							self.agreement_state_alert:SetCancelFunc(cancel_callback)
							self.agreement_state_alert:SetCloseFunc(cancel_callback)
						end

						self.agreement_state_alert:Open()
					end
				end
			end
		end)
		
end

function LoginController:SetAgreementState(state)
	self.agreement_state = state
end

function LoginController:GetAgreementState()
	return self.agreement_state
end

function LoginController:accountSignNew(account_name, password,mobile,code,real_name,id_card)
	local url = self.ip.."/login_new/register.php?action=register"
	local access_key = "Cp6lDSlv"
	local access_secret = "eTVq2LZjmh46n3i9Jo6x"
	local platform_id = "3"
	local timestamp = os.time() 
	local pw = password
	local mb = mobile
	if mobile == "" then
		mb = "0"
	end
	local cod = code
	if mobile == "" or code == "" then
		cod = "0"
	end
	local name = real_name
	local id = id_card
	if name == "" then
		name = "1"
	end
	if id == "" then
		id = "1"
	end
	local str  = ""
	local str = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&id_card=%s&mobile=%s&password=%s&platform_id=%s&real_name=%s&timestamp=%s",access_key,access_secret,account_name,cod,id,mb,pw,platform_id,name,timestamp)
	local sign = string.upper(UtilEx:md5Data(str.."&key=5Ov00ljb7MyP"))
	local str_2 = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&id_card=%s&mobile=%s&password=%s&platform_id=%s&real_name=%s&sign=%s&timestamp=%s",access_key,access_secret,account_name,cod,id,mb,pw,platform_id,name,sign,timestamp)
	local real_url = string.format("%s&%s", url,str_2)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
		print(data)
		if nil == data then return end
			local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end

		--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
		if tostring(init_info.code) ==  "0" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册成功,请登陆游戏", true)
			self.agent_login_view:setFastFlag()
		elseif tostring(init_info.code) ==  "1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
		elseif tostring(init_info.code) ==  "2" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册账号失败", true)
		elseif tostring(init_info.code) ==  "3" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码错误,请不要放肆哦", true)
		elseif tostring(init_info.code) ==  "4" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
		elseif tostring(init_info.code) ==  "5" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
		elseif tostring(init_info.code) ==  "6" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
		elseif tostring(init_info.code) ==  "7" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
		elseif tostring(init_info.code) ==  "8" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
		elseif tostring(init_info.code) ==  "9" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
		elseif tostring(init_info.code) ==  "-1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind(init_info.msg, true)
		else
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
		end
	 end)
end

--快速注册逻辑
function LoginController:accountSignFast()
	local real_url = self.ip.."/login_new/register.php?action=fast"
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
		print(data)
		if nil == data then return end
			local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end

		--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
		print(init_info.code)
		if tostring(init_info.code) ==  "0" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册成功,请登陆游戏", true)
			self.agent_login_view:setFastState(tostring(init_info.account),tostring(init_info.password))
		elseif tostring(init_info.code) ==  "1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
		elseif tostring(init_info.code) ==  "2" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册账号失败", true)
		elseif tostring(init_info.code) ==  "3" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码错误,请不要放肆哦", true)
		elseif tostring(init_info.code) ==  "4" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
		elseif tostring(init_info.code) ==  "5" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
		elseif tostring(init_info.code) ==  "6" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
		elseif tostring(init_info.code) ==  "7" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
		elseif tostring(init_info.code) ==  "8" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
		elseif tostring(init_info.code) ==  "9" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
		else
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
		end
	 end)
end

function LoginController:getCodeMobile(mobile,type)
	local url = self.ip.."/login_new/send.php"

	local access_key = "Cp6lDSlv"
	local access_secret = "eTVq2LZjmh46n3i9Jo6x"
	local platform_id = "3"
	local timestamp = os.time() 
	
	local str = ""
	if type == 1 then
		str = string.format("access_key=%s&access_secret=%s&mobile=%s&platform_id=%s&timestamp=%s&type=%s",access_key,access_secret,mobile,platform_id,timestamp,type)
	else
		str = string.format("access_key=%s&access_secret=%s&account=%s&platform_id=%s&timestamp=%s&type=%s",access_key,access_secret,mobile,platform_id,timestamp,type)
	end
	local sign = string.upper(UtilEx:md5Data(str.."&key=5Ov00ljb7MyP"))
	local str_2 = ""
	if type == 1 then
		str_2 = string.format("access_key=%s&access_secret=%s&mobile=%s&platform_id=%s&sign=%s&timestamp=%s&type=%s",access_key,access_secret,mobile,platform_id,sign,timestamp,type)
	else
		str_2 = string.format("access_key=%s&access_secret=%s&account=%s&platform_id=%s&sign=%s&timestamp=%s&type=%s",access_key,access_secret,mobile,platform_id,sign,timestamp,type)
	end
	local real_url = string.format("%s?%s", url,str_2)
	print(str)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size) 
		if nil == data then return end
		print(data)
		local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end
		if init_info.code == 0 then
			SysMsgCtrl.Instance:ErrorRemind("发送成功", true)
		elseif init_info.code == -1 then
			SysMsgCtrl.Instance:ErrorRemind(init_info.msg, true)
		else
			SysMsgCtrl.Instance:ErrorRemind("发送失败", true)
		end
	end)
end

--绑定逻辑
function LoginController:accountSignBind(account_name,mobile,code)
	local url = self.ip.."/login_new/bind.php"
	local access_key = "Cp6lDSlv"
	local access_secret = "eTVq2LZjmh46n3i9Jo6x"
	local platform_id = "3"
	local timestamp = os.time() 
	local mb = mobile
	local cod = code
	local str = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&mobile=%s&platform_id=%s&timestamp=%s",access_key,access_secret,account_name,cod,mb,platform_id,timestamp)
	local sign = string.upper(UtilEx:md5Data(str.."&key=5Ov00ljb7MyP"))
	local str_2 = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&mobile=%s&platform_id=%s&sign=%s&timestamp=%s",access_key,access_secret,account_name,cod,mb,platform_id,sign,timestamp)
	local real_url = string.format("%s?%s", url,str_2)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
		print(data)
		if nil == data then return end
			local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end

		--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
		if tostring(init_info.code) ==  "0" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("绑定成功,请登陆游戏", true)
			self.agent_login_view:setFastFlag()
		elseif tostring(init_info.code) ==  "1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
		elseif tostring(init_info.code) ==  "2" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册账号失败", true)
		elseif tostring(init_info.code) ==  "3" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码错误,请不要放肆哦", true)
		elseif tostring(init_info.code) ==  "4" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
		elseif tostring(init_info.code) ==  "5" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
		elseif tostring(init_info.code) ==  "6" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
		elseif tostring(init_info.code) ==  "7" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
		elseif tostring(init_info.code) ==  "8" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
		elseif tostring(init_info.code) ==  "-1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind(init_info.msg, true)
		elseif tostring(init_info.code) ==  "9" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
		else
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
		end
	 end)
end

--改绑逻辑
function LoginController:accountSignChangeBind(account_name,code_1,newmobile,code_2)
	local url = self.ip.."/login_new/change.php"
	local access_key = "Cp6lDSlv"
	local access_secret = "eTVq2LZjmh46n3i9Jo6x"
	local platform_id = "3"
	local timestamp = os.time()
	local str = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&new_code=%s&new_mobile=%s&platform_id=%s&timestamp=%s",access_key,access_secret,account_name,code_1,code_2,newmobile,platform_id,timestamp)
	local sign = string.upper(UtilEx:md5Data(str.."&key=5Ov00ljb7MyP"))
	local str_2 = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&new_code=%s&new_mobile=%s&platform_id=%s&sign=%s&timestamp=%s",access_key,access_secret,account_name,code_1,code_2,newmobile,platform_id,sign,timestamp)
	local real_url = string.format("%s?%s", url,str_2)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
		print(data)
		if nil == data then return end
			local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end

		--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
		if tostring(init_info.code) ==  "0" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("绑定成功,请登陆游戏", true)
			self.agent_login_view:setFastFlag()
		elseif tostring(init_info.code) ==  "1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
		elseif tostring(init_info.code) ==  "2" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册账号失败", true)
		elseif tostring(init_info.code) ==  "3" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码错误,请不要放肆哦", true)
		elseif tostring(init_info.code) ==  "4" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
		elseif tostring(init_info.code) ==  "5" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
		elseif tostring(init_info.code) ==  "6" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
		elseif tostring(init_info.code) ==  "7" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
		elseif tostring(init_info.code) ==  "8" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
		elseif tostring(init_info.code) ==  "-1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind(init_info.msg, true)
		elseif tostring(init_info.code) ==  "9" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
		else
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
		end
	 end)
end

--登陆逻辑
function LoginController:accountSignLogin(account_name,password)
	local url = PlatformAdapter.GetloginIp()
	local sign = UtilEx:md5Data(account_name .. "&" .. password .. "&" .. 1242821087)
	local real_url = string.format("%s?account=%s&password=%s&sign=%s", url, account_name, password, sign)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
	
		cc.UserDefault:getInstance():setStringForKey("last_account", account_name)
		cc.UserDefault:getInstance():setStringForKey("last_password", password)
		
		self:SendLoginCallBack(account_name, password, data, code)
	end)
end


--修改逻辑
function LoginController:accountSignChange(account_name,password,code)
	local url = self.ip.."/login_new/reset.php"
	local access_key = "Cp6lDSlv"
	local access_secret = "eTVq2LZjmh46n3i9Jo6x"
	local platform_id = "3"
	local timestamp = os.time() 
	local cod = code
	local str = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&new_password=%s&platform_id=%s&timestamp=%s",access_key,access_secret,account_name,cod,password,platform_id,timestamp)
	local sign = string.upper(UtilEx:md5Data(str.."&key=5Ov00ljb7MyP"))
	local str_2 = string.format("access_key=%s&access_secret=%s&account=%s&code=%s&new_password=%s&platform_id=%s&sign=%s&timestamp=%s",access_key,access_secret,account_name,cod,password,platform_id,sign,timestamp)
	local real_url = string.format("%s?%s", url,str_2)
	print(real_url)
	HttpClient:Request(real_url, "", function(url, arg, data, size)
		print(data)
		if nil == data then return end
			local init_info = cjson.decode(data);
		if init_info == nil then
			return
		end

		--SysMsgCtrl.Instance:ErrorRemind(tostring(init_info.code), true)
		if tostring(init_info.code) ==  "0" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("修改成功", true)
			self.agent_login_view:setFastFlag()
			self.agent_login_view:ChangeAndLogin()
		elseif tostring(init_info.code) ==  "1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号已经存在,请重新注册", true)
		elseif tostring(init_info.code) ==  "2" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("注册账号失败", true)
		elseif tostring(init_info.code) ==  "3" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码错误,请不要放肆哦", true)
		elseif tostring(init_info.code) ==  "4" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号只能英文和数字", true)
		elseif tostring(init_info.code) ==  "5" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码只能英文和数字", true)
		elseif tostring(init_info.code) ==  "6" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("账号需要6-16位字符", true)
		elseif tostring(init_info.code) ==  "7" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("密码需要6-10位字符", true)
		elseif tostring(init_info.code) ==  "8" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("签名错误", true)
		elseif tostring(init_info.code) ==  "9" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("Request param error", true)
		elseif tostring(init_info.code) ==  "-1" then
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind(init_info.msg, true)
		else
			self.is_login_verifying = false
			SysMsgCtrl.Instance:ErrorRemind("系统错误", true)
		end
	 end)
end		