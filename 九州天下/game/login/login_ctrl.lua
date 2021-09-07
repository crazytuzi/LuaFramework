require("game/login/login_data")
require("game/login/login_view")
require("game/login/login_select_role_view")

-- 登录
LoginCtrl = LoginCtrl or BaseClass(BaseController)

LOGIN_STATE_PLAT_LOGIN = 0
LOGIN_STATE_SERVER_LIST = 1
LOGIN_STATE_CREATE_ROLE = 2
LOGIN_STATE_LOADING = 3
LOGIN_VERIFY_KEY = "566713d23b8810efb313d6934cf77610"

function LoginCtrl:__init()
	if LoginCtrl.Instance ~= nil then
		print_error("[LoginCtrl] attempt to create singleton twice!")
		return
	end
	LoginCtrl.Instance = self

	self.data = LoginData.New()
	self.view = LoginView.New(ViewName.Login)

	self:RegisterAllProtocols()
	self:RegisterAllEvents()

	self.retry_connect_login_times = 0

	-- 加载品质控制器
	QualityConfig.ClearInstance()
	AssetManager.LoadObject(
		"misc/quality",
		"QualityConfig",
		typeof(QualityConfig),
		function(config)
			
			if IsLowMemSystem then -- 低内存系统不开启实时阴影
				QualityConfig.SetOverrideShadowQuality(0, 0)
			end

			if config ~= nil then
				print_log("Load the QualityConfig.")
			else
				print_error("Can not load the QualityConfig")
			end
		end)

	-- 创建渠道匹配器.
	AgentAdapter.New()

	--直接选角的话跳过
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		return
	end

	-- 检查SDK是否存在特殊的登录页，如果存在则使用SDK的登录页,并且服务端show_3dlogin开关为false，则不播放开场CG
	if AssetManager.ExistedInStreaming("AgentAssets/login_bg.png") and not GLOBAL_CONFIG.param_list.switch_list.show_3dlogin then
		local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/login_bg.png"
		self.view:SetLoginURL(url)
		--InitCtrl:HideLoading()
		return
	end
end

function LoginCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	
	LoginCtrl.Instance = nil

	if nil ~= AgentAdapter.Instance then
		AgentAdapter.Instance:DeleteMe()
		AgentAdapter.Instance = nil
	end
end

function LoginCtrl:ClearViewScenes()
	self.view:ClearCgObj()
end

function LoginCtrl:StartLogin(complete_callback)
	-- 取消异步加载
	-- self.view:PreloadScene("scenes/map/gz_chuangjue_main", "Gz_ChuangJue_Main", function()
	-- 	print_log("StartLogin ... ")
	-- 	ViewManager.Instance:Open(ViewName.Login)
	-- end)
	self.view:SetLoadCallBack(complete_callback)
	self.view:Open()
end

function LoginCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCLoginAck, "OnLoginAck")
	self:RegisterProtocol(SCRoleListAck, "OnRoleListAck")
	self:RegisterProtocol(SCMergeRoleListAck, "OnMergeRoleListAck")
	self:RegisterProtocol(SCCreateRoleAck, "OnCreateRoleAck")
	self:RegisterProtocol(SCUserEnterGSAck, "OnUserEnterGSAck")
	self:RegisterProtocol(SCProfNumInfo, "OnProfNumInfo")
	self:RegisterProtocol(SCLHeartBeat, "OnLHeartBeat")
	-- self:RegisterProtocol(SCServerBusy, "OnServerBusy")
	self:RegisterProtocol(SCDisconnectNotice, "OnDisconnectNotice")
	self:RegisterProtocol(SCCampCapability,"OnCampCapability")
end

function LoginCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.OnConnectGameServer, self))
	self:BindGlobalEvent(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectGameServer, self))

	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoaded, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneEnter, self))
end

function LoginCtrl:OnConnectLoginServer(is_suc)
	if is_suc then
		ReportManager:Step(Report.STEP_LOGIN_SERVER_CONNECTED)
		local user_vo = GameVoManager.Instance:GetUserVo()
		local protocol = ProtocolPool.Instance:GetProtocol(CSLoginReq)
		protocol.rand_1 = math.floor(math.random(1000000, 10000000))
		protocol.login_time = os.time()
		protocol.key = user_vo.plat_session_key
		protocol.rand_2 = math.floor(math.random(1000000, 10000000))
		protocol.plat_fcm = user_vo.plat_fcm
		protocol.plat_name = user_vo.plat_name
		protocol.plat_server_id = user_vo.plat_server_id
		if IS_ON_CROSSSERVER then
			protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
		else
			protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
		end

		if nil == self.login_server_heartbeat_timer then
			self.login_server_heartbeat_timer = GlobalTimerQuest:AddRunQuest(function()
				self.SendLoginServerHeartBeat()
			end, 10)
		end
	else
		print_log("LoginCtrl:OnConnectLoginServer fail")
		ReportManager:Step(Report.STEP_LOGIN_SERVER_CONNECTED_FAILED)
		if not ViewManager.Instance:IsOpen(ViewName.LoadingTips) then
			TipsCtrl.Instance:ShowDisconnected()
		else
			-- 自动重试5次之后，提示玩家连接失败
			if self.retry_connect_login_times >= 5 then
				self.retry_connect_login_times = 0
				ViewManager.Instance:Close(ViewName.LoadingTips)
				TipsCtrl.Instance:ShowDisconnected()
			else
				self.retry_connect_login_times = self.retry_connect_login_times + 1
				GameNet.Instance:ResetLoginServer()
				GameNet.Instance:ResetGameServer()
				GameNet.Instance:AsyncConnectLoginServer(5)
			end
		end
		TipsCtrl.Instance:ShowSystemMsg("登陆认证服务器失败.")
	end
end

function LoginCtrl:OnSceneEnter()
	-- local role_info = GameVoManager.Instance:GetMainRoleVo()
	-- local camp_index = self.data:GetCampIndex()
	-- if role_info and role_info.camp ~= nil and role_info.level ~= nil then
	-- 	if role_info.camp == 0 and role_info.level <= 1 then
	-- 		self:SendRoleChooseCamp(camp_index)
	-- 	end
	-- end
end

function LoginCtrl:OnDisconnectLoginServer()
	if nil ~= self.login_server_heartbeat_timer then
		GlobalTimerQuest:CancelQuest(self.login_server_heartbeat_timer)
		self.login_server_heartbeat_timer = nil
	end

	if CrossServerData.Instance then
		-- 是否手动断线
		if not CrossServerData.Instance:GetIsManualDisconnect() then
			ReportManager:Step(Report.STEP_DISCONNECT_LOGIN_SERVER)
			-- if nil == self.show_disconnect_tips_timer then
				-- local func = function ()
					if TipsCtrl.Instance ~= nil then
						TipsCtrl.Instance:ShowDisconnected(reason ~= GameNet.DISCONNECT_REASON_MULTI_LOGIN)
					end
					-- self.show_disconnect_tips_timer = nil
				-- end
				-- self.show_disconnect_tips_timer = GlobalTimerQuest:AddDelayTimer(func, 10)
			-- end
		end
	end
end

function LoginCtrl:OnConnectGameServer(is_suc)
	if is_suc then
		ReportManager:Step(Report.STEP_CONNECT_GAME_SERVER)
		self.SendUserEnterGSReq()
	else
		print_log("LoginCtrl:OnConnectGameServer fail")
		ReportManager:Step(Report.STEP_CONNECT_GAME_SERVER_FAILED)
		TipsCtrl.Instance:ShowSystemMsg("登陆游戏服务器失败.")
	end
end

function LoginCtrl:OnDisconnectGameServer(reason)
	print_warning("#########OnDisconnectGameServer", reason)

	if ActivityData.Instance then
		ActivityData.Instance:ClearAllActivity()
	end

	-- 是否手动断线
	if CrossServerData.Instance then
		if CrossServerData.Instance:GetIsManualDisconnect() then return end
	end

	ReportManager:Step(Report.STEP_DISCONNECT_GAME_SERVER)
	-- if nil == self.show_disconnect_tips_timer then
		-- local func = function ()
			if TipsCtrl.Instance ~= nil then
				TipsCtrl.Instance:ShowDisconnected(reason ~= GameNet.DISCONNECT_REASON_MULTI_LOGIN)
			end
		-- 	self.show_disconnect_tips_timer = nil
		-- end
		-- self.show_disconnect_tips_timer = GlobalTimerQuest:AddDelayTimer(func, 10)
	-- end
end

-- 发送国家协议
function LoginCtrl:SendRoleChooseCamp(camp_type,is_random)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRoleChooseCamp)
	send_protocol.camp_type = camp_type
	send_protocol.is_random = is_random or 0
	send_protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function LoginCtrl:OnConnectCrossServer(is_suc)

end

function LoginCtrl:OnDisconnectCrossServer()

end

function LoginCtrl:OnSceneLoaded()

end

function LoginCtrl:OnLoginAck(protocol)
	TimeCtrl.Instance:SetServerTime(protocol.server_time)

	if 0 == protocol.result then
		ReportManager:Step(Report.STEP_ON_LOGIN_ACK)
		GameNet.Instance:SetGameServerInfo(protocol.gs_hostname, protocol.gs_port)
		print_log("LoginCtrl:OnLoginAck hostname:" .. protocol.gs_hostname .. "  prot:" .. protocol.gs_port)
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:SetNowRole(protocol.role_id)
		user_vo.login_time = protocol.time
		user_vo.session_key = protocol.key
		user_vo.anti_wallow = protocol.anti_wallow
		user_vo.scene_id = protocol.scene_id
		user_vo.last_scene_id = protocol.last_scene_id

		-- 设置为手动断线
		CrossServerData.Instance:SetDisconnectGameServer()

		if IS_ON_CROSSSERVER then
			GameNet.Instance:DisconnectCrossServer()
		else
			GameNet.Instance:DisconnectLoginServer()
		end
		GameNet.Instance:AsyncConnectGameServer(5)

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:ReportUrlToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, "", "login")
		if ReportManager.ReportLoginEvent then
			ReportManager:ReportLoginEvent()
		end
	elseif -4 == protocol.result then
		TipsCtrl.Instance:OpenMessageBox(Language.Common.GameWorldNotExist, function()
			GameRoot.Instance:Restart()
		end)
	else
		print_log("LoginCtrl:OnLoginAck", protocol.result)
		ReportManager:Step(Report.STEP_ON_LOGIN_ACK_FAILED)
		TipsCtrl.Instance:ShowSystemMsg(string.format("登陆认证失败: %d.", protocol.result))
	end
end

function LoginCtrl:OnRoleListAck(protocol)
	self.data:SetIsMerge(false)
	self.data:SetRoleListAck(protocol)

	ReportManager:Step(Report.STEP_ROLE_LIST_ACK)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if 0 == protocol.result and protocol.count > 0 then
		if IS_ON_CROSSSERVER then
			user_vo:SetNowRole(protocol.role_list[1].role_id)
			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = protocol.role_list[1].role_name
			self.SendRoleReq()
		else
			if IS_AUDIT_VERSION then
				self:SendRoleReqSkipSelecet(protocol.role_list)
			else
				local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
				for k,v in pairs(protocol.role_list) do
					if v.role_id == curr_select_role_id then
						user_vo:SetNowRole(protocol.role_list[k].role_id)
						local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
						mainrole_vo.name = protocol.role_list[k].role_name
						self.SendRoleReq()
						return
					end
				end
				self.view:OnChangeToSelectRole()
			end
		end

	elseif -6 == protocol.result then
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
		
		if IS_AUDIT_VERSION then
			self:SendRandomCreateRole()
		else
			self.view:OnChangeToCreate()
		end
	else
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
	end
end

function LoginCtrl:OnMergeRoleListAck(protocol)
	print_log("Login::LoginCtrl:OnMergeRoleListAck")
	ReportManager:Step(Report.STEP_ROLE_LIST_MERGE_ACK)
	self.data:SetIsMerge(true)
	self.data:SetRoleListAck(protocol)
	if protocol.count == 0 then
		print_log("OnMergeRoleListAck has no count")
		self.view:OnChangeToCreate()
	else
		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:ClearRoleList()
		for i = 1, protocol.count do
			user_vo:AddRole(
				protocol.combine_role_list[i].role_id,
				protocol.combine_role_list[i].role_name,
				protocol.combine_role_list[i].avatar,
				protocol.combine_role_list[i].sex,
				protocol.combine_role_list[i].prof,
				protocol.combine_role_list[i].country,
				protocol.combine_role_list[i].level,
				protocol.combine_role_list[i].create_time,
				protocol.combine_role_list[i].last_login_time,
				protocol.combine_role_list[i].wuqi_id,
				protocol.combine_role_list[i].shizhuang_wuqi,
				protocol.combine_role_list[i].shizhuang_body,
				protocol.combine_role_list[i].wing_used_imageid,
				protocol.combine_role_list[i].halo_used_imageid,
				protocol.combine_role_list[i].wuqi_used_type,
				protocol.combine_role_list[i].body_use_type,
				protocol.combine_role_list[i].shenbing_img_id,
				protocol.combine_role_list[i].shenbing_texiao_id,
				protocol.combine_role_list[i].baojia_img_id,
				protocol.combine_role_list[i].baojia_texiao_id,
				protocol.combine_role_list[i].fazhen_used_imageid)
		end

		-- if protocol.count == 1 then
		-- 	user_vo:SetNowRole(protocol.combine_role_list[1].role_id)

		-- 	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		-- 	mainrole_vo.name = protocol.combine_role_list[1].role_name

		-- 	self.SendRoleReq()
		-- else
			if IS_ON_CROSSSERVER then
				user_vo:SetNowRole(protocol.combine_role_list[1].role_id)
				local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
				mainrole_vo.name = protocol.combine_role_list[1].role_name
				self.SendRoleReq()
			else
				if IS_AUDIT_VERSION then
					self:SendRoleReqSkipSelecet(protocol.combine_role_list)
				else
					local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
					for k,v in pairs(protocol.combine_role_list) do
						if v.role_id == curr_select_role_id then
							user_vo:SetNowRole(protocol.combine_role_list[k].role_id)
							local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
							mainrole_vo.name = protocol.combine_role_list[k].role_name
							self.SendRoleReq()
							return
						end
					end
					self.view:OnChangeToSelectRole()
				end
			end
		-- end
	end
end

function LoginCtrl:OnProfNumInfo(protocol)
	local prof, prof_num = 1, protocol.prof1_num
	if prof_num > protocol.prof2_num then
		prof, prof_num = 2, protocol.prof2_num
	end
	if prof_num > protocol.prof3_num then
		prof, prof_num = 3, protocol.prof3_num
	end
	if prof_num > protocol.prof4_num then
		prof, prof_num = 4, protocol.prof4_num
	end

	self.view:SetLowProf(prof)
end

function LoginCtrl.SendRoleReq()
	print_log("Login::LoginCtrl.SendRoleReq")

	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleReq)
	protocol.rand_1 = math.floor(math.random(1000000, 10000000))
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.rand_2 = math.floor(math.random(1000000, 10000000))
	protocol.role_id = mainrole_vo.role_id
	protocol.plat_name = user_vo.plat_name
	protocol.plat_server_id = user_vo.plat_server_id

	if IS_ON_CROSSSERVER then
		ReportManager:Step(Report.STEP_SEND_ROLE_REQUEST_CROSS)
		protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
	else
		ReportManager:Step(Report.STEP_SEND_ROLE_REQUEST)
		protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
	end
end

function LoginCtrl.SendCreateRole(role_name, prof, sex, camp_type)
	print_log("Login::LoginCtrl:SendCreateRole")
	ReportManager:Step(Report.STEP_SEND_CREATE_ROLE)

	local user_vo = GameVoManager.Instance:GetUserVo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateRoleReq)
	protocol.plat_name = user_vo.plat_name
	protocol.role_name = role_name
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_server_id = user_vo.plat_server_id
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.avatar = 1
	protocol.sex = sex
	protocol.prof = prof
	protocol.camp_type = camp_type
	--protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	local plat_spid = user_vo.plat_id or GLOBAL_CONFIG.package_info.config.agent_id
	protocol.plat_spid = tostring(plat_spid)
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function LoginCtrl:OnCreateRoleAck(protocol)
	if 0 == protocol.result then
		Scene.Instance:OpenSceneLoading()

		print_log("LoginCtrl:OnCreateRoleAck", protocol.result)
		ReportManager:Step(Report.STEP_CREATE_ROLE_ACK)
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
		LoginData.Instance:SetCurrSelectRoleId(protocol.role_id)

		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = protocol.role_name

		self.SendRoleReq()

		GlobalEventSystem:Fire(LoginEventType.CREATE_ROLE)

		-- 神起上报
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:ReportUrlToSQ(main_role_vo.server_id, protocol.role_name, protocol.role_id, protocol.level, protocol.create_time, "createRole")
	else
		print_log("LoginCtrl:OnCreateRoleAck", protocol.result)
		ReportManager:Step(Report.STEP_CREATE_ROLE_ACK_FAILED)

		local show_msg = "创建角色失败"
		if -1 == protocol.result then
			show_msg = "拥有角色太多，没有空间再创角色"
		elseif -2 == protocol.result then
			show_msg = "该昵称已存在, 请修改昵称"
		elseif -3 == protocol.result then
			show_msg = "名字不合法"
		elseif -4 == protocol.result then
			show_msg = "当前区服角色已满，大侠请转战新区玩耍！"
		end

		TipsCtrl.Instance:ShowSystemMsg(show_msg)
	end
end

function LoginCtrl.SendLoginServerHeartBeat()
	local protocol = ProtocolPool.Instance:GetProtocol(CSLHeartBeat)
	if IS_ON_CROSSSERVER then
		protocol:EncodeAndSend(GameNet.Instance:GetCrossServerNet())
	else
		protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
	end

end

-- 登录服心跳返回
function LoginCtrl:OnLHeartBeat()
end

function LoginCtrl:OnUserEnterGSAck(protocol)
	local result_str = tostring(protocol.result)
	if 0 == protocol.result then
		result_str = result_str .. " 成功"
	elseif -1 == protocol.result then
		result_str = result_str .. " 角色已存在"
	elseif -2 == protocol.result then
		result_str = result_str .. " 没找到场景"
	end
	print_log("Login::LoginCtrl:OnUserEnterGSAck result:" .. tostring(protocol.result) .. ",result_str:" .. result_str)

	if 0 == protocol.result then
		ReportManager:Step(Report.STEP_ENTER_GS_ACK)
		-- -- 清空资源
		-- self.view:ClearScenes()
		-- 关闭网络提示
		-- GlobalTimerQuest:CancelQuest(self.show_disconnect_tips_timer)
		TipsCtrl.Instance:CloseDisconnected()
		ViewManager.Instance:Close(ViewName.LoadingTips)
		-- 发送进度游戏成功事件
		GlobalEventSystem:Fire(LoginEventType.ENTER_GAME_SERVER_SUCC)

		ReportManager:GetShieldListReq()
	elseif -1 == protocol.result then
		ReportManager:Step(Report.STEP_ENTER_GS_ACK_FAILED)
		self.enter_gs_count = self.enter_gs_count or 0 + 1
		if self.enter_gs_count >= 5 then
			self.enter_gs_count = 0
		else
			self.enter_gs_timer = GlobalTimerQuest:AddDelayTimer(
				function() self.SendUserEnterGSReq() end, 0.1)
		end
	else
		ReportManager:Step(Report.STEP_ENTER_GS_ACK_FAILED)
		self.enter_gs_count = 0
		print_log("LoginCtrl:OnUserEnterGSAck", protocol.result)
	end
end

function LoginCtrl.SendUserEnterGSReq()
	ReportManager:Step(Report.STEP_SEND_ENTER_GS)
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

	local plat_spid = user_vo.plat_id or GLOBAL_CONFIG.package_info.config.agent_id
	protocol.plat_spid = tostring(plat_spid)
	--protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNet())

	print_log("Login::LoginCtrl.SendUserEnterGSReq name=" .. mainrole_vo.role_name.."server_id="..mainrole_vo.server_id)
end

function LoginCtrl:ExitReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSDisconnectReq)
	protocol:EncodeAndSend(GameNet.Instance:GetGameServerNet())
end

-- 断开当前服务器
function LoginCtrl.SendUserLogout()
	local protocol = ProtocolPool.Instance:GetProtocol(CSUserLogout)
	protocol:EncodeAndSend()
end

-- 断开当前服务器
function LoginCtrl:OnDisconnectNotice(protocol)
	if protocol.reason == DISCONNECT_NOTICE_TYPE.LOGIN_OTHER_PLACE then
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_MULTI_LOGIN)
	else
		GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_NORMAL)
	end
end

-- 在加载页面出来后,再清空资源
function LoginCtrl:ClearScenes()
	if self.view then
		self.view:ClearScenes()
	end
end

function LoginCtrl:OnLoginOut()
	if self.view:IsOpen() then
		self.view:Flush("back_login_view")
	end
end

function LoginCtrl:OnCampCapability(protocol)
	if protocol then
		self.data:SetCampCapability(protocol.capability_list)
		LoginView.Instance:OnAutoSelectGuoJia()
	end
end

function LoginCtrl:FlushServerList()
	self.view:Flush("server_list")
end

function LoginCtrl:SendRandomCreateRole()
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

function LoginCtrl:SendRoleReqSkipSelecet(role_list)
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
    local temp_role_list = TableCopy(role_list_ack_info.role_list)

    local user_vo = GameVoManager.Instance:GetUserVo()
    user_vo:SetNowRole(temp_role_list[1].role_id)

    Scene.Instance:OpenSceneLoading()
    LoginData.Instance:SetCurrSelectRoleId(temp_role_list[1].role_id)

	for k,v in pairs(role_list) do
		if v.role_id == temp_role_list[1].role_id then
			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = role_list[k].role_name
   			self.SendRoleReq()
   			return
		end
	end
end