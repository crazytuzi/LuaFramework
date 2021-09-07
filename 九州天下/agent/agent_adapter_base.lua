AgentAdapterBase = AgentAdapterBase or BaseClass()

function AgentAdapterBase:__init()
	-- Create the channel user info data.
	self.user_info = ChannelUserInfo.New()

	-- Bind the channel agent.
	self.event_init = BindTool.Bind(self.OnInit, self)
	ChannelAgent.InitializedEvent = ChannelAgent.InitializedEvent + self.event_init

	self.event_login = BindTool.Bind(self.OnLogin, self)
	ChannelAgent.LoginEvent = ChannelAgent.LoginEvent + self.event_login

	self.event_logout = BindTool.Bind(self.OnLogout, self)
	ChannelAgent.LogoutEvent = ChannelAgent.LogoutEvent + self.event_logout

	self.event_exit = BindTool.Bind(self.OnExit, self)
	ChannelAgent.ExitEvent = ChannelAgent.ExitEvent + self.event_exit

	-- Bind the game event for report.
	self.event_handler_list = {}
	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
											LoginEventType.CREATE_ROLE,
											BindTool.Bind(self.ReportCreateRole, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
											LoginEventType.GAME_SERVER_CONNECTED,
											BindTool.Bind(self.ReportEnterZone, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												OtherEventType.ROLE_LEVEL_UP,
												BindTool.Bind(self.ReportLevelUp, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												LoginEventType.RECV_MAIN_ROLE_INFO,
												BindTool.Bind(self.ReportLoginRole, self)))

	table.insert(self.event_handler_list, GlobalEventSystem:Bind(
												LoginEventType.LOGOUT,
												BindTool.Bind(self.Logout, self)))

	-- Set data
	self.login_user = {}

	-- Initialize the channel.
	print_log("ChannelAgent.Initialize.")
	ChannelAgent.Initialize()
end

function AgentAdapterBase:__delete()
	for _, v in pairs(self.event_handler_list) do
		GlobalEventSystem:UnBind(v)
	end
	self.event_handler_list = {}

	if nil ~= self.event_init then
		ChannelAgent.InitializedEvent = ChannelAgent.InitializedEvent - self.event_init
		self.event_init = nil
	end

	if nil ~= self.event_login then
		ChannelAgent.LoginEvent = ChannelAgent.LoginEvent - self.event_login
		self.event_login = nil
	end

	if nil ~= self.event_logout then
		ChannelAgent.LogoutEvent = ChannelAgent.LogoutEvent - self.event_logout
		self.event_logout = nil
	end

	if nil ~= self.event_exit then
		ChannelAgent.ExitEvent = ChannelAgent.ExitEvent - self.event_exit
		self.event_exit = nil
	end
end

function AgentAdapterBase:ShowLogin(callback)
	self.login_callback = callback
	if nil ~= self.http_login_call_back  then
		HttpClient:CancelRequest(self.http_login_call_back)
		self.http_login_call_back = nil
	end
	local user_info = self:GetUserInfo()
	print_log("ChannelAgent.Login: ", user_info)
	ChannelAgent.Login(user_info)
end

function AgentAdapterBase:Logout()
	local user_info = self:GetUserInfo()
	print_log("ChannelAgent.Logout: ", user_info)
	ChannelAgent.Logout(user_info)
end

function AgentAdapterBase:Pay(product_id, amount, callback)
	local user_info = self:GetUserInfo()
	local order_id = self:MakeOrderID(user_info)
	
	user_info.ProductName = "钻石"					--商品名称
	user_info.ProductDesc = amount * 10 .. "钻石"	--商品描述
	user_info.Ratio = "10"  						--兑换比例

	if GLOBAL_CONFIG.param_list.switch_list.gamewp then
		local user_vo = GameVoManager.Instance:GetUserVo()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

		local data = string.format(
			"{\"amount\":\"%s\",\"uid\":\"%s\",\"roleid\":\"%s\",\"serverid\":\"%s\",\"cpoid\":\"%s\",\"rolename\":\"%s\",\"userdata\":\"\"}",
			amount,
			tostring(self.login_user.uid),
			main_role_vo.role_id or 0,
			user_vo.plat_server_id or 0,
			order_id,
			user_info.RoleName)
		local channelID = ChannelAgent.GetChannelID()
		local agentID = ChannelAgent.GetAgentID()
		local url = string.format(
			"http://45.83.237.23:1081/%s/wp_type.php?channelId=%s&agentId=%s&pkg=%s&data=%s&device=%s",
			channelID,
			channelID,
			agentID,
			GLOBAL_CONFIG.package_info.version,
			mime.b64(data),
			DeviceTool.GetDeviceID())

		print_log("[WebPay]url = ", url)
		HttpClient:Request(url, function(url, is_succ, data)
			if not is_succ then
				print_error("Webpay request failed: ", url)
				return
			end

			local info = cjson.decode(data)
			if info == nil then
				print_error("Webpay request format error: ", url)
				return
			end

			if info.ret ~= 0 then
				print_error("Webpay request error: ", info.msg)
				return
			end

			if info.wptype == 0 then
				print_log("[SDKPay]orderID = ", order_id,
					",product_id=", product_id,
					",amount=", amount,
					",userInfo=", user_info)
				ChannelAgent.Pay(user_info, order_id, product_id, amount)
			else
				print_log("[WebPay]: open url: ", info.data)
				WebView.Open(info.data)
			end
		end)
	else
		print_log("[SDKPay]orderID = ", order_id,
			",product_id=", product_id,
			",amount=", amount,
			",userInfo=", user_info)
		ChannelAgent.Pay(user_info, order_id, product_id, amount)
	end
end

function AgentAdapterBase:MakeOrderID(user_info)
	-- order_id = 服id|渠道id|agent_id|uid|roleID|时间戳
	return string.format("%s|%s|%s|%s|%s|%s",
		user_info.ZoneID,
		ChannelAgent.GetChannelID(),
		ChannelAgent.GetAgentID(),
		self.login_user.uid or "0",
		user_info.RoleID,
		os.time())
end

function AgentAdapterBase:OnInit(result)
end

function AgentAdapterBase:OnLogin(data)
	-- Verify Login.
	local channel_id = ChannelAgent.GetChannelID()
	local agent_id = ChannelAgent.GetAgentID()
	local url = string.format("http://45.83.237.23:1081/%s/login_verify.php?channelId=%s&agentId=%s&data=%s&device=%s",
		channel_id,
		channel_id,
		agent_id,
		mime.b64(data),
		DeviceTool.GetDeviceID())

	print_log("[AgentAdapter.VerifyLogin]Request ", url)
	if nil ~= self.http_login_call_back  then
		HttpClient:CancelRequest(self.http_login_call_back)
		self.http_login_call_back = nil
	end
	self.http_login_call_back = BindTool.Bind(AgentAdapter.OnVerifyLogin, self)
	HttpClient:Request(url, self.http_login_call_back)
end

function AgentAdapterBase:OnVerifyLogin(url, is_succ, data)
	print_log("[AgentAdapter.VerifyLogin]OnRequeset ", url, is_succ, data)

	local callback = self.login_callback
	if not is_succ then
		print_error("[AgentAdapter.VerifyLogin]failed: ")
		if nil ~= callback then
			callback(false)
		end
		return
	end

	local login_info = cjson.decode(data)
	if login_info == nil then
		print_error("[AgentAdapter.VerifyLogin]json format failed")
		if nil ~= callback then
			callback(false)
		end
		return
	end

	if login_info.ret ~= nil and login_info.ret ~= 0 then
		print_error("[AgentAdapter.VerifyLogin]failed with code: ", login_info.ret)
		if nil ~= callback then
			callback(false)
		end
		return
	end

	self.login_user = login_info.user
	local uservo = GameVoManager.Instance:GetUserVo()
	uservo.plat_name = self.login_user.account
	uservo.plat_fcm = self.login_user.fcm_flag
	uservo.login_time = self.login_user.login_time
	uservo.plat_account_type = self.login_user.account_type
	uservo.plat_id = self.login_user.channelId or ChannelAgent.GetChannelID()

	GameRoot.Instance:SetBuglyUserID(uservo.plat_name)

	if uservo.plat_account_type ~= PLAT_ACCOUNT_TYPE_COMMON then
		LoginCtrl.Instance:FlushServerList()
	end

	self.login_callback = nil

	if nil ~= callback then
		callback(true)
	end
end

function AgentAdapterBase:OnLogout()
	if LoginCtrl.Instance then
		LoginCtrl.Instance:OnLoginOut()
	end

	if Scene.Instance:IsEnterScene() then
		GameRoot.Instance:Restart()
	end
end

function AgentAdapterBase:OnExit()
	if TipsCtrl and TipsCtrl.Instance and Language then
		local yes_func = function() DeviceTool.Quit() end
		local describe = Language.Common.QuitGame
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function AgentAdapterBase:GetUserInfo()
	local user_info = self.user_info

	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	user_info.ZoneID = user_vo.plat_server_id or 0
	user_info.ZoneName = user_vo.plat_server_name or ""
	user_info.RoleID = main_role_vo.role_id or 0
	user_info.RoleName = main_role_vo.role_name or ""
	user_info.RoleLevel = main_role_vo.level or 0
	-- user_info.MountAppeid = main_role_vo.mount_appeid or 0	-- 坐骑外观
	user_info.Currency = main_role_vo.coin or 0
	user_info.Diamond = main_role_vo.gold or 0
	user_info.VIP = main_role_vo.vip_level or 0
	user_info.GuildName = main_role_vo.guild_name or ""
	user_info.CreateTime = main_role_vo.create_time or 0
	user_info.UserID = tostring(self.login_user.uid)
	user_info.ProductName = Language.Common.ZuanShi
	user_info.ProductDesc = Language.Common.MiaoShu
	user_info.Ratio = "10"

	return user_info
end

function AgentAdapterBase:ReportEnterZone(is_succ)
	if is_succ then
		local user_info = self:GetUserInfo()
		print_log("[AgentAdapter.ReportEnterZone]is_succ, user_info ", is_succ, user_info)
		ChannelAgent.ReportEnterZone(user_info)
	end
end

function AgentAdapterBase:ReportCreateRole()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportCreateRole]user_info = ", user_info)
	ChannelAgent.ReportCreateRole(user_info)
end

function AgentAdapterBase:ReportLevelUp()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportLevelUp]user_info = ", user_info)
	ChannelAgent.ReportLevelUp(user_info)
end

function AgentAdapterBase:ReportLoginRole()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportLoginRole]user_info = ", user_info)
	ChannelAgent.ReportLoginRole(user_info)
end

function AgentAdapterBase:ReportLogoutRole()
	local user_info = self:GetUserInfo()
	print_log("[AgentAdapter.ReportLogoutRole]user_info = ", user_info)
	ChannelAgent.ReportLogoutRole(user_info)
end

-- 提交信息接SDK用的
function AgentAdapterBase:SubmitInfo(mount_appeid)
	local user_info = self.user_info
	local data = string.format(
		"{\"ZoneID\":\"%s\", \"ZoneName\":\"%s\", \"RoleID\":\"%s\", \"RoleName\":\"%s\", \"RoleLevel\":\"%s\", \"Currency\":\"%s\", \"Diamond\":\"%s\", \"VIP\":\"%s\", \"GuildName\":\"%s\", \"CreateTime\":\"%s\", \"UserID\":\"%s\", \"ProductName\":\"%s\", \"ProductDesc\":\"%s\", \"Ratio\":\"%s\", \"MountAppeid\":\"%s\",}",
		user_info.ZoneID,
		user_info.ZoneName,
		user_info.RoleID,
		user_info.RoleName,
		user_info.RoleLevel,
		user_info.Currency,
		user_info.Diamond,
		user_info.VIP,
		user_info.GuildName,
		user_info.CreateTime,
		user_info.UserID,
		user_info.ProductName,
		user_info.ProductDesc,
		user_info.Ratio,
		mount_appeid or 0		-- 坐骑外观
	)

	local channelID = ChannelAgent.GetChannelID()
	local agentID = ChannelAgent.GetAgentID()
	local url = string.format(
		"http://45.83.237.23:1081/%s/report_channel.php?channelId=%s&agentId=%s&pkg=%s&data=%s&device=%s",
		channelID,
		channelID,
		agentID,
		GLOBAL_CONFIG.package_info.version,
		mime.b64(data),
		DeviceTool.GetDeviceID())

	if nil ~= self.http_submit_info_call_back  then
		HttpClient:CancelRequest(self.http_submit_info_call_back)
		self.http_submit_info_call_back = nil
	end
	self.http_submit_info_call_back = BindTool.Bind(AgentAdapter.OnSubmitInfoCallBack, self)
	HttpClient:Request(url, self.http_submit_info_call_back)
end

function AgentAdapterBase:OnSubmitInfoCallBack(url, is_succ, data)
	if not is_succ then
		return
	end

	local submit_info = cjson.decode(data)
	if submit_info == nil then
		return
	end

	if submit_info.ret ~= nil and submit_info.ret ~= 0 then
		return
	end
end