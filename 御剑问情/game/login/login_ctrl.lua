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

	self.is_click_start_game = false
	self.is_load_complete = false

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
	-- 加载鼠标点击特效
	LoginCtrl.CreateClickEffectCanvas()
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
	LoginCtrl.Instance = nil

	if nil ~= AgentAdapter.Instance then
		AgentAdapter.Instance:DeleteMe()
		AgentAdapter.Instance = nil
	end
	self.depend = nil
end

function LoginCtrl:StartLogin(complete_callback)
	-- self.view:PreloadScene("scenes/map/xjjm_zs_main", "Xjjm_zs_Main", function()
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
end

function LoginCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.OnConnectGameServer, self))
	self:BindGlobalEvent(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectGameServer, self))

	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectLoginServer, self))

	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoaded, self))
end

function LoginCtrl.CreateClickEffectCanvas()
	UtilU3d.PrefabLoad("uis/views/clickeffectcanvas_prefab", "ClickEffectCanvas", function(obj)
		local canvas = obj:GetComponent(typeof(UnityEngine.Canvas))
		canvas.overrideSorting = true
		canvas.sortingOrder = 32767

		local UIRoot = GameObject.Find("GameRoot/UILayer").transform
		if nil ~= UIRoot then
			canvas.transform:SetParent(UIRoot, false)
			canvas.transform:SetLocalScale(1, 1, 1)
			local rect = canvas.transform:GetComponent(typeof(UnityEngine.RectTransform))
			rect.anchorMax = Vector2(1, 1)
			rect.anchorMin = Vector2(0, 0)
			rect.anchoredPosition3D = Vector3(0, 0, 0)
			rect.sizeDelta = Vector2(0, 0)
		end
	end)
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

function LoginCtrl:OnConnectCrossServer(is_suc)

end

function LoginCtrl:OnDisconnectCrossServer()

end

function LoginCtrl:OnSceneLoaded()

end

function LoginCtrl:OnLoginAck(protocol)
	TimeCtrl.Instance:SetServerTime(protocol.server_time)

	if 0 == protocol.result then
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

		if not IS_ON_CROSSSERVER then
			ReportManager:Step(Report.STEP_ON_LOGIN_ACK)
			ReportManager:ReportLoginEvent()
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			ReportManager:ReportRoleInfo(main_role_vo.server_id, main_role_vo.name, main_role_vo.role_id, main_role_vo.level, "", "Login")
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
	-- 下发正常角色列表表示未合服
	IS_MERGE_SERVER = false
	self.data:SetRoleListAck(protocol)
	ReportManager:Step(Report.STEP_ROLE_LIST_ACK)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if 0 == protocol.result and protocol.count > 0 then
		if IS_ON_CROSSSERVER or IS_AUDIT_VERSION then
			user_vo:SetNowRole(protocol.role_list[1].role_id)
			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = protocol.role_list[1].role_name
			self.SendRoleReq()
		else
			local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
			-- 检查是不是从跨服出来，或者是断线重连
			for k,v in pairs(protocol.role_list) do
				if v.role_id == curr_select_role_id then
					user_vo:SetNowRole(protocol.role_list[k].role_id)
					local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
					mainrole_vo.name = protocol.role_list[k].role_name
					self.SendRoleReq()
					return
				end
			end
			self.view:OnRoleListAck(protocol)
			-- self.view:OpenSelectRole()
		end

	elseif -6 == protocol.result then
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
		-- 审核服自动创建角色
		if IS_AUDIT_VERSION then
			self:ReqCreateRole()
		else
			-- 如果角色列表为空，则核对一次服务器时间，防止部分玩家通过修改本地时间提前进新服
			local server_id = self.view:GetCurSelectServerId()
			local is_can_login, tip = LoginData.Instance:IsCanLoginServer(server_id, protocol.server_time + 10)
			if not is_can_login then
				TipsCtrl.Instance:OpenMessageBox(tip, function()
					GameRoot.Instance:Restart()
				end)
				return
			end
			self.view:OnRoleListAck(protocol)
		end
		-- self.view:OnChangeToCreate()
	else
		local call_back = function ()
			ViewManager.Instance:Close(ViewName.LoadingTips)
			self.view:OnDefaultReturnClick()
		end
		TipsCtrl.Instance:ShowReminding(Language.Common.Band, call_back)
		print_log("LoginCtrl:OnRoleListAck", protocol.result)
	end
end

function LoginCtrl:OnMergeRoleListAck(protocol)
	-- 下发合服角色列表表示已经合服
	IS_MERGE_SERVER = true

	self.data:SetRoleListAck(protocol)
	ReportManager:Step(Report.STEP_ROLE_LIST_MERGE_ACK)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if protocol.count == 0 then
		print_log("OnMergeRoleListAck has no count")
		if IS_AUDIT_VERSION then
			self:ReqCreateRole()
		else
			self.view:OnRoleListAck(protocol, true)
		end
	else
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
				protocol.combine_role_list[i].halo_used_imageid)
		end

		-- 合服之后若只有一个角色，直接跳过选角面板(这里包括了只有一个角色的玩家从跨服出来的情况)
		if protocol.count == 1 then
			user_vo:SetNowRole(protocol.combine_role_list[1].role_id)
			local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
			mainrole_vo.name = protocol.combine_role_list[1].role_name
			-- self.view:OnRoleListAck(protocol, true)
			self.SendRoleReq()
		else
			if IS_ON_CROSSSERVER or IS_AUDIT_VERSION then
				user_vo:SetNowRole(protocol.combine_role_list[1].role_id)
				local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
				mainrole_vo.name = protocol.combine_role_list[1].role_name
				self.SendRoleReq()
			else
				local curr_select_role_id = LoginData.Instance:GetCurrSelectRoleId()
				-- 检查是不是从跨服出来，或者是断线重连
				for k,v in pairs(protocol.combine_role_list) do
					if v.role_id == curr_select_role_id then
						user_vo:SetNowRole(protocol.combine_role_list[k].role_id)
						local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
						mainrole_vo.name = protocol.combine_role_list[k].role_name
						self.SendRoleReq()
						return
					end
				end
				-- self.view:OpenSelectRole()
				self.view:OnRoleListAck(protocol, true)
			end
		end
	end

	self.data:SetCombineData(protocol)
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

function LoginCtrl:ReqCreateRole()
	local user_vo = GameVoManager.Instance:GetUserVo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateRoleReq)
	protocol.plat_name = user_vo.plat_name
	protocol.login_time = os.time()
	protocol.key = user_vo.plat_session_key
	protocol.plat_server_id = user_vo.plat_server_id
	protocol.plat_fcm = user_vo.plat_fcm
	protocol.avatar = 1
	local prof = math.floor(math.random(1, 4))
	protocol.prof = prof
	protocol.sex = LoginCtrl.GetSexByProf(prof)
	protocol.role_name = LoginCtrl.GetRoleName(protocol.sex)
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function LoginCtrl.GetSexByProf(prof)
	local sex = GameEnum.MALE
	if prof == GameEnum.ROLE_PROF_2 or prof == GameEnum.ROLE_PROF_4 then
		sex = GameEnum.FEMALE
	end
	return sex
end

function LoginCtrl.GetRoleName(sex)
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local first_list = {}
	local last_list = {}
	local the_list_1 = {}
	local the_list_2 = {}
	if sex == GameEnum.FEMALE then
		the_list_1 = name_cfg.female_first
		the_list_2 = name_cfg.female_last
	else
		the_list_1 = name_cfg.male_first
		the_list_2 = name_cfg.male_last
	end

	for k,v in pairs(the_list_1) do
		table.insert(first_list,v)
	end

	for k,v in pairs(the_list_2) do
		table.insert(last_list,v)
	end
	local name = first_list[math.random(1, #first_list)] .. last_list[math.random(1, #last_list)]
	return name
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
		UnityEngine.PlayerPrefs.SetString("last_login_prof", mainrole_vo.prof)
		ReportManager:Step(Report.STEP_SEND_ROLE_REQUEST)
		protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
	end
end

function LoginCtrl.SendCreateRole(role_name, prof, sex)
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
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	protocol:EncodeAndSend(GameNet.Instance:GetLoginNet())
end

function LoginCtrl:OnCreateRoleAck(protocol)
	if RET_TYPE.RESULT_TYPE_SUCC == protocol.result then
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

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		ReportManager:ReportRoleInfo(main_role_vo.server_id, protocol.role_name, protocol.role_id, protocol.level, protocol.create_time, "createRole")
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Login.CreateRoleResultTip[protocol.result] or "")
		print_log("LoginCtrl:OnCreateRoleAck2", protocol.result)
		ReportManager:Step(Report.STEP_CREATE_ROLE_ACK_FAILED)

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
	protocol.plat_spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
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
		self.view:BackLoginView()
	end
end

function LoginCtrl:PreLoadDependBundles(call_back)
	if IS_AUDIT_VERSION then
		if call_back then
			call_back(1)
		end
		return
	end
	self.depend = require("init/preload_depend_bundles")
	self.depend:Start(call_back)
end

function LoginCtrl:DestoryDependBundles()
	if self.depend then
		self.depend:Destory()
	end
end

function LoginCtrl:ModulesComplete()
	self.is_load_complete = true
	self:CheckTrulyComplete()
end

function LoginCtrl:StartGame()
	self.is_click_start_game = true
	self:CheckTrulyComplete()
end

function LoginCtrl:CheckTrulyComplete()
	if self.is_load_complete and self.is_click_start_game then
		GameNet.Instance:AsyncConnectLoginServer(5)
	end
end