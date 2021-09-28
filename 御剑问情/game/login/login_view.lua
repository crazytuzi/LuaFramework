LoginView = LoginView or BaseClass(BaseView)
LoginView.ProfIcon = {
	[1] = {"icon_102", "icon_099"},
	[2] = {"icon_101", "icon_098"},
	[3] = {"icon_100", "icon_097"},
}
local GROUP_SERVER_COUNT = 10

local CG_BUNDLE = {
	[1] = {bundle = "cg/xjjm_zs_prefab", asset = "CG_zhanshi"},
	[2] = {bundle = "cg/xjjm_fs_prefab", asset = "CG_fashi"},
	[3] = {bundle = "cg/xjjm_qs_prefab", asset = "CG_qiangshou"},
	[4] = {bundle = "cg/xjjm_tianyin_prefab", asset = "CG_tianyin"},
}

local SCENE_BUNDLE = {
	[1] = {bundle = "scenes/map/w2_ts_nanzhan_main", asset = "W2_TS_NanZhan_Main"},
	[2] = {bundle = "scenes/map/w2_ts_liandao_main", asset = "W2_TS_LianDao_Main"},
	[3] = {bundle = "scenes/map/w2_ts_nanshan_main", asset = "W2_TS_NanShan_Main"},
	[4] = {bundle = "scenes/map/w2_ts_nvqin_main", asset = "W2_TS_NvQin_Main"},
}

function LoginView:__init()
	LoginView.Instance = self
	self.ui_config = {"uis/views/login_prefab", "LoginView"}
	self.ui_scene = {"scenes/map/uijsdt01", "UIjsdt01"}

	self.server_list = LoginData.Instance:GetShowServerList()
	self.server_count = #self.server_list

	self.group_count = math.ceil(self.server_count / GROUP_SERVER_COUNT)
	self.server_temp_end_index = GROUP_SERVER_COUNT - 1

	self.select_server_id = 1
	self.scene_cache = {}
	self.scene_loaded_bundle_name_t = {}
	self.has_scene_cached = false

	self.is_open_create = false				-- 是否打开过创建角色界面(用于返回的时候做判断用)
	self.is_click_event = false				-- 监听模型点击事件

	self.select_sex = GameEnum.MALE
	self.select_prof = 0
	self.server_group_cell_list = {}
	self.server_content_cell_list = {}
	self.server_item_num_in_group = GROUP_SERVER_COUNT
	self.cur_group_index = 0
	self.last_server = LoginData.Instance:GetLastLoginServer()
	self.cur_select_server = self.last_server

	self.cg_instance_list = {}

	self.profession_icon_list = {}

	self.login_succ = false
end

function LoginView:__delete()
end

function LoginView:ReleaseCallBack()
	for k,v in pairs(self.scene_loaded_bundle_name_t) do
		AssetManager.UnloadAsseBundle(v)
	end
	self.scene_loaded_bundle_name_t = {}

	self:DeleteSelectRoleView()

	-- 取消监听模型点击事件
	if self.is_click_event then
		self.is_click_event = false
		EasyTouch.On_TouchDown = EasyTouch.On_TouchDown - self.click_handle
	end
	EasyTouch.SetEnableAutoSelect(false)
	--[[if self.role_model_view then
		self.role_model_view:DeleteMe()
		self.role_model_view = nil
	end]]

	for k, v in pairs(self.server_content_cell_list) do
		v:DeleteMe()
	end
	self.server_content_cell_list = {}

	self.cg_chuchang = nil
	self.cg_to_female = nil
	self.cg_to_male = nil
	self.cg_idle_female = nil
	self.cg_idle_male = nil
	self.cg_attack_female = nil
	self.cg_attack_male = nil
	self.cg_idle = nil
	self.cg_attack = nil

	self.last_sever_state = nil
	self.group_list_view = nil
	self.server_list_view = nil
	self.select_role = nil
	self.select_role_list = nil

	self.login_root = nil
	self.select_server = nil
	self.select_common = nil
	self.select_male = nil
	self.select_female = nil
	self.select_role = nil

	self.default_sever_text = nil
	self.profession_ability = nil
	self.profession_icon = nil
	self.create_role = nil

	self.craps = nil
	self.default_login = nil
	self.login_view = nil

	self.role_display = nil
	self.serverlist_bg = nil
	self.prof_desc = nil
	self.character_name = nil
	self.prof_toggle_1 = nil
	self.prof_toggle_2 = nil
	self.prof_toggle_3 = nil
	self.prof_toggle_4 = nil

	self.input_name = nil
	self.back_ground = nil
	self.back_ground_url = nil
	self.show_default_logo = nil
	self.logo_url = nil
	self.cg_camera = nil
	self.obj_select_role_event = nil
	self.request_priority_id = nil
	self.ios_shield = nil

	self.profession_icon_list = nil
	if self.cg_handler_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler_2)
		self.cg_handler_2 = nil
	end
	self.load_callback = nil

	if self.enter_game_server_succ then
		GlobalEventSystem:UnBind(self.enter_game_server_succ)
		self.enter_game_server_succ = nil
	end
end

function LoginView:OnLoadDengluLevelScene(bundle_name)
	self.scene_loaded_bundle_name_t[bundle_name] = bundle_name
end

function LoginView:SetCurSelectServerId(server_id)
	self.cur_select_server = server_id
end

function LoginView:GetCurSelectServerId()
	return self.cur_select_server
end

function LoginView:SetLoadCallBack(load_callback)
	self.load_callback = load_callback
end

function LoginView:LoadCallBack()
	if self.load_callback then
		self.load_callback()
	end
	-- 选服
	self:InitLastItem()
	self:InitGroupListView()
	self:InitServerListView()
	-- 初始化选择角色面板
	self:InitSelectRoleView()

	self.login_root = self:FindObj("LoginRoot")
	self.select_server = self:FindObj("SelectServer")
	self.select_common = self:FindObj("SelectCommon")
	self.select_male = self:FindObj("SelectMale")
	self.select_female = self:FindObj("SelectFemale")
	self.select_role = self:FindObj("SelectRole")

	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then
		local rect = self.select_role.transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.offsetMin = Vector2(66, 0)
		rect.offsetMax = Vector2(-66, 0)
	end

	local back_btn = self:FindObj("SelectBackBtn")
	back_btn.button:AddClickListener(BindTool.Bind(self.OnClickSelectBack, self))

	local new_server_flag = self:FindVariable("new_server_flag")
	if LoginData.Instance:GetServerFlag(self.last_server) == 2 then
		new_server_flag:SetValue(false)
	else
		new_server_flag:SetValue(true)
	end

	-- 设置版本号
	local app_version = self:FindVariable("app_version")
	local asset_version = self:FindVariable("asset_version")
	app_version:SetValue(GLOBAL_CONFIG.package_info.version)
	asset_version:SetValue(GLOBAL_CONFIG.assets_info.version)

	self.default_sever_text = self:FindVariable("DefaultSeverText")
	self.profession_ability = self:FindVariable("profession_ability")
	self.profession_icon = self:FindVariable("profession_icon")
	for i = 1,4 do
		self.profession_icon_list[i] = self:FindVariable("profession_icon_"..i)
	end

	local confirm_btn = self:FindObj("SelectConfirmBtn")
	confirm_btn.button:AddClickListener(BindTool.Bind(self.OnClickSelectConfirm, self))

	-- 创建角色
	self.create_role = self:FindObj("CreateRole")

	-- 记录是否可点击创建动画模型进行切换角色
	self.if_can_click_model = {}
	self.cg_played_t = {}
	for i = 1, 4 do
		self:ListenEvent("CreatePro" .. i, BindTool.Bind2(self.OnToggleChange, self, i))
	end

	self:ListenEvent("CreateRetunClick", BindTool.Bind(self.OnCreateRetunClick, self))
	self:ListenEvent("DefaultReturnClick", BindTool.Bind(self.OnDefaultReturnClick, self))
	self:ListenEvent("StartGame", BindTool.Bind(self.OnStartGameClick, self))
	self:ListenEvent("SelectServer", BindTool.Bind(self.OnSelectServerClick, self))
	self:ListenEvent("RotateCrapsClick", BindTool.Bind(self.OnCrapsClick, self))
	self:ListenEvent("ClickSex1", BindTool.Bind(self.ClickSex1, self))
	self:ListenEvent("ClickSex2", BindTool.Bind(self.ClickSex2, self))
	self:ListenEvent("OnClickLogin", BindTool.Bind(self.OnClickLogin, self))

	self.login_succ = false
	self.enter_game_server_succ = GlobalEventSystem:Bind(LoginEventType.ENTER_GAME_SERVER_SUCC, BindTool.Bind(self.EnterGameServerSucc, self))

	local create_confirm_btn = self:FindObj("CreateConfirmBtn")
	create_confirm_btn.button:AddClickListener(
		BindTool.Bind(self.OnClickCreateConfirm, self))
	self.craps = self:FindObj("Craps")
	self.default_login = self:FindObj("Default_login")
	self.login_view = self:FindObj("LoginView")

	self.role_display = self:FindObj("RoleModel")
	self.serverlist_bg = self:FindObj("ServerListBg")
	self.prof_desc = self:FindVariable("prof_desc")
	self.character_name = self:FindVariable("character_name")
	self.prof_toggle_1 = self:FindObj("prof_toggle_1")
	self.prof_toggle_2 = self:FindObj("prof_toggle_2")
	self.prof_toggle_3 = self:FindObj("prof_toggle_3")
	self.prof_toggle_4 = self:FindObj("prof_toggle_4")

	local last_item = self:FindObj("SelectLastItem")
	last_item.toggle.isOn = true
	self.select_index = 0
	-- 显示账号登陆界面

	local ip = LoginData.Instance:GetGetServerIP(self.last_server)
	local port = LoginData.Instance:GetGetServerPort(self.last_server)
	GameNet.Instance:SetLoginServerInfo(ip, port)
	GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
	GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)
	self.login_view:SetActive(true)

	self:ShowLogin()
	self.input_name = self:FindObj("CreateNameInput")

	self.back_ground = self:FindObj("BackGround")
	self.back_ground_url = self:FindVariable("BackGroundURL")
	if self.bg_url ~= nil and self.bg_url ~= "" then
		self.back_ground:SetActive(true)
		self.back_ground_url:SetValue(self.bg_url)
	else
		self.back_ground:SetActive(false)
	end

	-- 显示Logo
	self.show_default_logo = self:FindVariable("ShowDefaultLogo")
	--暂时屏蔽logo
	self.show_default_logo:SetValue(false)
	self.logo_url = self:FindVariable("LogoURL")
	-- 检查SDK是否存在特殊的Logo，如果存在则使用SDK的Logo
	if AssetManager.ExistedInStreaming("AgentAssets/logo.png") then
		self.show_default_logo:SetValue(false)
		local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/logo.png"
		self.logo_url:SetValue(url)
	else
		self.show_default_logo:SetValue(true)
	end

	self.ios_shield = self:FindVariable("IOS_Shield")
	self.ios_shield:SetValue(IS_AUDIT_VERSION)

	EasyTouch.SetEnableAutoSelect(true)
	self:PlayLoginMusic()
end

function LoginView:CloseCallBack()
	self.login_succ = false
end

function LoginView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_select_role_view" then
			self:FlushSelectRoleView()
		end
	end
end

-- 设置登录背景
function LoginView:SetLoginURL(url)
	if url ~= nil and url ~= "" then
		self.bg_url = url
		if self.back_ground_url and self.back_ground then
			self.back_ground:SetActive(true)
			self.back_ground_url:SetValue(url)
		end
	end
end

----------最近登录、新服--------------
function LoginView:InitLastItem()
	local last_item = self:FindObj("SelectLastItem")
	local name = LoginData.Instance:GetShowServerNameById(self.last_server)
	self.SetServerItemName(last_item, name)
	last_item.toggle:AddValueChangedListener(
		BindTool.Bind(self.OnClickLastItem, self))
	self.last_sever_state = self:FindVariable("last_sever_state")

	local flag = LoginData.Instance:GetServerFlag(self.last_server)
	self.last_sever_state:SetAsset(self:GetServerState(flag))
end

function LoginView:OnClickLastItem(is_click)
	if is_click then
		local name = LoginData.Instance:GetShowServerNameById(self.last_server)
		local ip = LoginData.Instance:GetGetServerIP(self.last_server)
		local port = LoginData.Instance:GetGetServerPort(self.last_server)

		GameNet.Instance:SetLoginServerInfo(ip, port)
		GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
		GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)
		self.default_sever_text:SetValue(name)
		self:SetCurSelectServerId(self.last_server)
	end
end
----------最近登录、新服--------------

----------创建ListView------------
function LoginView:InitGroupListView()
	self.group_list_view = self:FindObj("SelectServerGroup")
	local list_delegate = self.group_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LoginView:GetNumberOfCells()
	return self.group_count
end

function LoginView:RefreshCell(cell, cell_index)
	-- 倒序排列
	cell_index = self.group_count - cell_index - 1

	local server_group_cell = self.server_group_cell_list[cell]
	if server_group_cell == nil then
		server_group_cell = ServerGroupItem.New(cell.gameObject, self)
		self.server_group_cell_list[cell] = server_group_cell
		server_group_cell:SetToggleGroup(self.group_list_view.toggle_group)
	end

	local data = {}
	data.begin_index = GROUP_SERVER_COUNT * cell_index
	data.end_index = data.begin_index + math.min(GROUP_SERVER_COUNT, self.server_count - data.begin_index) - 1
	data.cell_index = cell_index

	server_group_cell:SetData(data)
end

function LoginView:GetCurGroupIndex()
	return self.cur_group_index
end

function LoginView:SetCurGroupIndex(group_index)
	self.cur_group_index = group_index

	if group_index < math.floor(self.server_count / GROUP_SERVER_COUNT) then
		self.server_item_num_in_group = GROUP_SERVER_COUNT
	else
		self.server_item_num_in_group = self.server_count % GROUP_SERVER_COUNT
	end

	self.server_list_view.scroller:ReloadData(0)
end

function LoginView:InitServerListView()
	self.server_list_view = self:FindObj("SelectServerList")
	local list_delegate = self.server_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells2, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell2, self)
end

function LoginView:GetNumberOfCells2()
	return math.ceil(self.server_item_num_in_group / 2)
end

function LoginView:RefreshCell2(cell, cell_index)
	local server_content_cell = self.server_content_cell_list[cell]
	if server_content_cell == nil then
		server_content_cell = ServerItemContent.New(cell.gameObject, self)
		self.server_content_cell_list[cell] = server_content_cell
		self.server_content_cell_list[cell].index = cell_index
	end

	local begin_index = self.server_temp_end_index - self.server_temp_end_index % GROUP_SERVER_COUNT
	local index = self.server_temp_end_index - cell_index * 2

	local data = {}
	data[1] = self.server_list[index + 1]
	if index > begin_index then
		data[2] = self.server_list[index - 1 + 1]
	end

	server_content_cell:SetData(data)
end

----------创建ListView------------

function LoginView.SetServerItemName(server_item, name)
	local left_text = server_item:FindObj("LeftText")
end

function LoginView:SetTempServerEndIndex(index)
	self.server_temp_end_index = index
end

function LoginView:SetLowProf(low_prof)
	self.low_prof = low_prof
end

function LoginView:ShowLogin()
	--直接选角的话跳过
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		self.login_view:SetActive(false)
		local uservo = GameVoManager.Instance:GetUserVo()
		uservo.plat_name = UtilU3d.GetCacheData("select_role_plat_name")

		local ip = LoginData.Instance:GetGetServerIP(self.last_server)
		local port = LoginData.Instance:GetGetServerPort(self.last_server)
		GameNet.Instance:SetLoginServerInfo(ip, port)
		GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
		GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)

		LoadingPriorityManager.Instance:CancelRequest(self.request_priority_id)
		self.request_priority_id = LoadingPriorityManager.Instance:RequestPriority(LoadingPriority.High)

		-- 预加载场景
		self:PreloadScene("scenes/map/w2_ts_nanzhan_main", "W2_TS_NanZhan_Main", CG_BUNDLE[1].bundle, CG_BUNDLE[1].asset, function()
			self:PreloadScene("scenes/map/w2_ts_liandao_main", "W2_TS_LianDao_Main", CG_BUNDLE[2].bundle, CG_BUNDLE[2].asset, function()
				self:PreloadScene("scenes/map/w2_ts_nanshan_main", "W2_TS_NanShan_Main", CG_BUNDLE[3].bundle, CG_BUNDLE[3].asset, function()
					self:PreloadScene("scenes/map/w2_ts_nvqin_main", "W2_TS_NvQin_Main", CG_BUNDLE[4].bundle, CG_BUNDLE[4].asset, function()
						LoadingPriorityManager.Instance:CancelRequest(self.request_priority_id)
						ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
						GameNet.Instance:AsyncConnectLoginServer(5)
						self.select_server:SetActive(false)
						self.default_login:SetActive(false)
						self.select_role:SetActive(false)
						self.login_view:SetActive(false)
					end)
				end)
			end)
		end)
		return
	end

	self.login_view:SetActive(true)
	-- SDK登录
	-- 这里延迟一帧，因为调用SDK登录接口可能会暂停游戏进程，导致某些逻辑没有执行
	Scheduler.Delay(function ()
		ReportManager:Step(Report.STEP_SHOW_LOGIN)
		AgentAdapter.Instance:ShowLogin(function(is_succ)
			if is_succ then
				self.default_login:SetActive(true)
				self.login_view:SetActive(false)

				local ip = LoginData.Instance:GetGetServerIP(self.last_server)
				local port = LoginData.Instance:GetGetServerPort(self.last_server)
				local name = LoginData.Instance:GetShowServerNameById(self.last_server)
				self.default_sever_text:SetValue(name)

				GameNet.Instance:SetLoginServerInfo(ip, port)
				GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
				GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.last_server)

				ReportManager:Step(Report.STEP_LOGIN_COMPLETE)
				-- 入场CG
				if not self.is_played_loginCG then
					local stage_enter = GameObject.Find("CG/stage_enter")
					if not IsNil(stage_enter) then
						local cg_enter = stage_enter:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
						if not IsNil(cg_enter) then
							cg_enter:Play()
							self.is_played_loginCG = true
						end
					end
				end
			else
				self.default_login:SetActive(false)
				self.login_view:SetActive(true)
			end
		end)
	end)
end

function LoginView:OnCrapsClick()
	self:RandomName()
end

function LoginView:FlushDetails()
	local role_conifg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	if role_conifg then
		local role_res_id = 0
		local weapon_res_id = 0
		local job_config = role_conifg[self.select_prof]
		if job_config then
			self.prof_desc:SetValue(job_config.describe)
			self.character_name:SetValue(job_config["name" .. self.select_sex])
			role_res_id = job_config["model" .. self.select_sex]
			right_weapon_res_id = job_config["right_weapon" .. self.select_sex]
			left_weapon_res_id = job_config["left_weapon" .. self.select_sex]
			self:SetModle(role_res_id, right_weapon_res_id, left_weapon_res_id)
		end
	end
end

function LoginView:SetModle(role_res_id, right_weapon_res_id, left_weapon_res_id)
	--[[if not self.role_model_view then
		self.role_model_view = RoleModel.New()
		self.role_model_view:SetDisplay(self.role_display.ui3d_display)
	end
	self.role_model_view:ResetRotation()
	self.role_model_view:SetRoleResid(role_res_id)
	self.role_model_view:SetWeaponResid(right_weapon_res_id)
	self.role_model_view:SetWeapon2Resid(left_weapon_res_id)]]
end

function LoginView:OnClickSelectConfirm()
	self:OnStartGameClick()
end

function LoginView:OnClickSelectBack()
	-- 清空缓存的场景
	local SceneManager = UnityEngine.SceneManagement.SceneManager
	for k,v in pairs(self.scene_cache) do
		SceneManager.UnloadSceneAsync(v.scene)
	end
	self.scene_cache = {}
	self.cg_instance_list = {}
	self.has_scene_cached = false

	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end

	self.select_server:SetActive(false)
	self.select_role:SetActive(false)
	self.default_login:SetActive(true)
	self.login_view:SetActive(false)
	local name = LoginData.Instance:GetShowServerNameById(self.cur_select_server)
	self.default_sever_text:SetValue(name)
end

function LoginView:ClearScenes()
	if nil ~= self.create_role_scene_camera and not IsNil(self.create_role_scene_camera.gameObject) and not self.create_role_scene_camera.gameObject.activeSelf then
		self.create_role_scene_camera:SetActive(true)
		self.create_role_scene_camera = nil
	end

	-- 清空缓存的场景
	local SceneManager = UnityEngine.SceneManagement.SceneManager
	for k,v in pairs(self.scene_cache) do
		SceneManager.UnloadSceneAsync(v.scene)
	end
	self.scene_cache = {}
	self.has_scene_cached = false

	-- 清空CG实例
	for k, v in pairs(self.cg_instance_list) do
		GameObject.Destroy(v)
	end
	self.cg_instance_list = {}

	-- if self.cg_instance then
	-- 	GameObject.Destroy(self.cg_instance)
	-- 	self.cg_instance = nil
	-- end

	-- 清理绘制物体
	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end
end

function LoginView:LoginScene()
	local bunle_name = "scenes/map/w2_ts_denglu_denglu"
	local asset_name = "W2_TS_DengLu.unity"
	AssetManager.LoadLevelSync(
		bunle_name,
		asset_name,
		UnityEngine.SceneManagement.LoadSceneMode.Single,
		function()
			self.scene_loaded_bundle_name_t[bunle_name] = bunle_name
			Scheduler.Delay(function()
				local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName("W2_TS_DengLu")
				print_log("Login scene: ", scene)
				-- 入场CG
				local stage_idle = GameObject.Find("CG/stage_idle")
				if not IsNil(stage_idle) then
					local cg_idle = stage_idle:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
					if not IsNil(cg_idle) then
						cg_idle:Play()
					end
				end
			end)
		end)
end

-- 打开选角面板
-- 这里是为了解决在创建角色面板停留时，掉线导致返回选角面板，而没有施放内存
function LoginView:OpenSelectRole()
	if self.is_open_create then
		self:OnCreateRetunClick()
	else
		self:OnChangeToSelectRole()
	end
end

function LoginView:OnCreateRetunClick()
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	GlobalTimerQuest:CancelQuest(self.cg_handler)
	self.cg_handler = nil
	if self.cg_handler_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler_2)
		self.cg_handler_2 = nil
	end
	self.modelparent = nil
	self.select_role_id = 0
	self.is_enter_select_role = false
	if self.is_open_create and role_list_ack_info.count > 0 then
		for k, v in pairs(self.cg_instance_list) do
			GameObject.Destroy(v)
		end
		self.cg_instance_list = {}

		self:OnChangeToSelectRole()
		self:PlayLoginMusic()
	else
		self:ClearScenes()
		if self.bg_url == nil or self.bg_url == "" then
			self:LoginScene()
		end
		LoginData.Instance:SetCurrSelectRoleId(-1)
		GameNet.Instance:ResetLoginServer()
		self.default_login:SetActive(true)
		self.login_view:SetActive(false)
		self.create_role:SetActive(false)
		self.select_role:SetActive(false)
		self.login_root:SetActive(true)

		local name = LoginData.Instance:GetShowServerNameById(self.cur_select_server)
		self.default_sever_text:SetValue(name)
		if self.is_open_create then
			self:PlayLoginMusic()
		end
	end
end

function LoginView:OnDefaultReturnClick()
	self:BackLoginView()

	GlobalEventSystem:Fire(LoginEventType.LOGOUT)
end

function LoginView:BackLoginView()
	self:OnCreateRetunClick()

	LoginData.Instance:SetCurrSelectRoleId(-1)
	GameNet.Instance:ResetLoginServer()
	self.default_login:SetActive(false)
	self.login_view:SetActive(true)
	self.select_server:SetActive(false)
end

function LoginView:OnClickLogin()
	self.login_view:SetActive(false)
	self:ShowLogin()
end

function LoginView:OnStartGameClick()
	if not LoginData.Instance:IsCanLoginServer(self.cur_select_server) then
		return
	end

	if self.login_succ then
		return
	end

	ReportManager:Step(Report.STEP_CLICK_START_GAME)
	if TipsCtrl.Instance then
		TipsCtrl.Instance:ShowLoadingTips()
	end

	if IS_AUDIT_VERSION then
		LoginCtrl.Instance:StartGame()
	else
		GameNet.Instance:AsyncConnectLoginServer(5)
	end

	if not IS_ON_CROSSSERVER then
		UnityEngine.PlayerPrefs.SetString("PRVE_SRVER_ID", self.cur_select_server)
		self.last_server = self.cur_select_server
	end
end

function LoginView:OnRoleListAck(role_list, is_hefu)
	local scene_load_complete_callback = function ()
		ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
		self.select_server:SetActive(false)
		self.default_login:SetActive(false)
		self.select_role:SetActive(false)
		self.login_view:SetActive(false)
		if (0 == role_list.result or is_hefu) and role_list.count > 0 then
			self:OpenSelectRole()
		elseif -6 == role_list.result or is_hefu then
			self:OnChangeToCreate()
		end
	end

	-- 已经有角色了
	if (0 == role_list.result or is_hefu) and role_list.count > 0 then
		local temp_role_list = TableCopy(role_list.role_list or role_list.combine_role_list)
		table.sort(temp_role_list, SortTools.KeyUpperSorter("last_login_time"))
		local prof = temp_role_list[1].prof
		if IS_AUDIT_VERSION then
			scene_load_complete_callback()
			return
		end
		-- 只加载玩家最后一次登录的职业的场景
		self:PreloadScene(SCENE_BUNDLE[prof].bundle, SCENE_BUNDLE[prof].asset, nil, nil, function()
			scene_load_complete_callback()
		end)
	else
		if IS_AUDIT_VERSION then
			scene_load_complete_callback()
			return
		end
		-- 没有角色则预加载所有场景
		self:PreloadScene(SCENE_BUNDLE[1].bundle, SCENE_BUNDLE[1].asset, CG_BUNDLE[1].bundle, CG_BUNDLE[1].asset, function()
			self:PreloadScene(SCENE_BUNDLE[2].bundle, SCENE_BUNDLE[2].asset, CG_BUNDLE[2].bundle, CG_BUNDLE[2].asset, function()
				self:PreloadScene(SCENE_BUNDLE[3].bundle, SCENE_BUNDLE[3].asset, CG_BUNDLE[3].bundle, CG_BUNDLE[3].asset, function()
					self:PreloadScene(SCENE_BUNDLE[4].bundle, SCENE_BUNDLE[4].asset, CG_BUNDLE[4].bundle, CG_BUNDLE[4].asset, function()
						scene_load_complete_callback()
					end)
				end)
			end)
		end)
	end
end

function LoginView:OnSelectServerClick()
	self.default_login:SetActive(false)
	self.select_role:SetActive(false)
	self.login_view:SetActive(false)
	self.select_server:SetActive(true)
end

function LoginView:OnChangeToCreate()
	if self:IsOpen() then
		self.is_open_create = true
		self.select_prof = 0
		local index = math.random(1, 4)
		self:OnToggleChange(index, true)
		AudioService.Instance:PlayBgm("audios/musics/bgmlogin", "loginmusic")
	end
end

function LoginView:OnToggleChange(prof, is_click)
	if IS_AUDIT_VERSION then
		self:OnToggleChangeIosShield(prof, is_click)
		return
	end
	if is_click then
		if prof == self.select_prof then
			return
		end
		-- 显示加载页面
		TipsCtrl.Instance:ShowLoadingTips()

		if self.draw_obj ~= nil then
			self.draw_obj:DeleteMe()
			self.draw_obj = nil
		end

		self.select_prof = prof
		self:FlushDetails()
		local prof_numb = 62 + prof
		self.profession_ability:SetAsset("uis/views/login/images_atlas", "icon_0" .. prof_numb)
		self.profession_icon:SetAsset("uis/views/login/images_atlas", "prof_icon_" .. prof)
		for i,v in ipairs(self.profession_icon_list) do
			if i == prof then
				v:SetValue(true);
			else
				v:SetValue(false);
			end
		end
		self.cg_chuchang = nil
		self.cg_to_female = nil
		self.cg_to_male = nil
		self.cg_idle_female = nil
		self.cg_idle_male = nil
		self.cg_attack_female = nil
		self.cg_attack_male = nil
		local bundle, asset, cg_bundle, cg_asset, position, rotation
		self.select_sex = PlayerData.Instance:GetSexByProf(prof)
		self.is_male = self.select_sex == GameEnum.MALE

		if prof == 1 then
			position = Vector3.zero
			rotation = Quaternion.Euler(0, 0, 0)
		elseif prof == 2 then
			position = Vector3.zero
			rotation = Quaternion.Euler(0, 0, 0)
		elseif prof == 3 then
			position = Vector3.zero
			rotation = Quaternion.Euler(0, 0, 0)
		else
			position = Vector3.zero
			rotation = Quaternion.Euler(0, -2.7, 0)
		end
		bundle = SCENE_BUNDLE[prof].bundle
		asset = SCENE_BUNDLE[prof].asset
		cg_bundle = CG_BUNDLE[prof].bundle
		cg_asset = CG_BUNDLE[prof].asset

		self:RandomName()

		if self.cg_handler ~= nil then
			GlobalTimerQuest:CancelQuest(self.cg_handler)
			self.cg_handler = nil
		end

		-- 取消监听模型点击事件
		if self.click_handle and self.is_click_event then
			self.is_click_event = false
			EasyTouch.RemoveCamera(self.cg_camera)
			EasyTouch.On_TouchDown = EasyTouch.On_TouchDown - self.click_handle
		end

		local cg_key = cg_bundle .. cg_asset
		local change_scene_func = function()
			self:ChangeScene(bundle, asset, function()
				local cg_obj = self.cg_instance_list[cg_key]

				self.select_server:SetActive(false)
				self.login_root:SetActive(false)
				self.select_role:SetActive(false)
				TipsCtrl.Instance:CloseLoadingTips()

				-- 容错，外网cg可能会加载失败
				if nil == cg_obj then
					self.create_role:SetActive(true)
					return
				end
				local center = UnityEngine.GameObject.Find("Center")
				local key = bundle..asset
				if self.scene_cache[key] then
					local objs = self.scene_cache[key].roots
					for i = 0, objs.Length - 1 do
						if objs[i].gameObject.name == "Center" then
							center = objs[i]
						elseif objs[i].gameObject.name == "Camera" then
							self.create_role_scene_camera = objs[i]
							objs[i].gameObject:SetActive(false)
						end
					end
				end
				cg_obj.gameObject:SetActive(true)
				cg_obj.transform:SetParent(center.transform)
				cg_obj.transform.localPosition = position
				cg_obj.transform.localRotation = rotation

				local chuchang = cg_obj.transform:Find("stage_chuchang")
				self.cg_chuchang = chuchang:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				self.cg_chuchang:Play()
				local idle = cg_obj.transform:Find("stage_idle")
				local attack = cg_obj.transform:Find("stage_attack")
				self.cg_idle = idle:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				self.cg_attack = attack:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

				if self.modelparent ~= nil then
					self.modelparent.transform.localRotation = Quaternion.identity
				end
				local nanshan_sence = "scenes/map/w2_ts_nanshan_mainW2_TS_NanShan_Main"
				if key == nanshan_sence then
					local equitment = UnityEngine.GameObject.Find("910200101(Clone)")
					if equitment then
						equitment.transform:SetParent(center.transform)
					end
				end
				-- 关闭其他的场景.
				for k,v in pairs(self.scene_cache) do
					if k ~= key then
						local objs = v.roots
						for i = 0,objs.Length-1 do
							local obj = objs[i]
							obj:SetActive(false)
						end
					end
				end

				self.cg_camera = self.cg_instance_list[cg_key]:GetComponentInChildren(typeof(UnityEngine.Camera))
				if self.cg_camera then
					EasyTouch.AddCamera(self.cg_camera)
				end

				-- 卸载登录界面
				local SceneManager = UnityEngine.SceneManagement.SceneManager
				local scene = SceneManager.GetSceneByName("W2_TS_DengLu")
				if scene and scene:IsValid() then
					local roots = scene:GetRootGameObjects()
					for i = 0,roots.Length-1 do
						local obj = roots[i]
						obj:SetActive(false)
					end
					SceneManager.UnloadSceneAsync(scene)
				end

				self.click_handle = function(gesture)
					-- 只有跳过动画了才能点击模型切换角色
					if self.if_can_click_model[prof] then
						if gesture.pickedObject ~= nil then
							self.modelparent = gesture.pickedObject.transform.parent
							if self.modelparent.name == "1101001" or
								self.modelparent.name == "1001001" or
								self.modelparent.name == "1002001" or
								self.modelparent.name == "1102001"  then
								local rotation = Vector3(0,-gesture.deltaPosition.x,0)
								self.modelparent.transform:Rotate(rotation,UnityEngine.Space.World)
							end
						end
					end
				end

				-- 监听模型拖拽事件
				if not self.is_click_event then
					self.is_click_event = true
					EasyTouch.On_TouchDown = EasyTouch.On_TouchDown + self.click_handle
				end

				for k,v in pairs(self.if_can_click_model) do
					if k ~= prof then
						self.if_can_click_model[k] = false
					end
				end


				if self.cg_played_t[prof] and not IsNil(self.cg_chuchang) then
					self.cg_chuchang:Stop()
					self.create_role:SetActive(true)
					if not self["prof_toggle_" .. prof].toggle.isOn then
						self["prof_toggle_" .. prof].toggle.isOn = true
					end

					if self.cg_handler_2 ~= nil then
						GlobalTimerQuest:CancelQuest(self.cg_handler_2)
						self.cg_handler_2 = nil
					end
					self.cg_handler_2 = GlobalTimerQuest:AddRunQuest(
						function()
							if not IsNil(self.cg_attack) then
								if self.cg_attack.duration - self.cg_attack.time <= 2 then
									GlobalTimerQuest:CancelQuest(self.cg_handler)
									self.cg_handler = nil
									self.if_can_click_model[prof] = true
								end
							end
						end, 0)

					self:ChangeProf()
					return
				end

				self.create_role:SetActive(false)
				if self.is_male then
					self.select_sex = GameEnum.MALE
				else
					self.select_sex = GameEnum.FEMALE
				end

				self.cg_played_t[prof] = true
				if self.cg_handler ~= nil then
					GlobalTimerQuest:CancelQuest(self.cg_handler)
					self.cg_handler = nil
				end
				self.cg_handler = GlobalTimerQuest:AddRunQuest(
					function()
						if not IsNil(self.cg_chuchang) then
							if self.cg_chuchang.duration - self.cg_chuchang.time <= 0.1 then
								GlobalTimerQuest:CancelQuest(self.cg_handler)
								self.create_role:SetActive(true)
								self.cg_handler = nil
								self.if_can_click_model[prof] = true
							elseif self.cg_chuchang.duration - self.cg_chuchang.time <= 2 then
								self.create_role:SetActive(true)
								self.if_can_click_model[prof] = true
								if not self["prof_toggle_" .. prof].toggle.isOn then
									self["prof_toggle_" .. prof].toggle.isOn = true
								end
							end
						end
					end, 0)
				end)

		end

		-- 加载场景
		self:PreloadScene(bundle, asset, cg_bundle, cg_asset, change_scene_func, true)
	end
end

function LoginView:OnClickCreateConfirm()
	local role_name = self.input_name.input_field.text
	if role_name == "" then
		return
	end
	if ChatFilter.Instance:IsIllegal(role_name, true) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
		return
	end
	if string.len(role_name) > 18 then
		return
	end
	LoginCtrl.SendCreateRole(role_name, self.select_prof, self.select_sex)
end

function LoginView:RandomName()
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local first_list = {}
	local last_list = {}
	local the_list_1 = {}
	local the_list_2 = {}
	if self.select_sex == GameEnum.FEMALE then
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

	self.input_name.input_field.text = name
end

function LoginView:GetProfDesc(prof)
	local cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local prof_info = {}
	for k,v in pairs(cfg) do
		if v.id == prof then
			prof_info.describe = v.describe
			prof_info.character = v.character
			return prof_info
		end
	end
end

-- 服务器标记 (1: 火爆 2: 新服 3: 即将开服 4: 测试 5: 维护)
function LoginView:GetServerState(flag)
	local asset = ""
	if flag == 1 then
		asset = "ball_red"
	elseif flag == 2 then
		asset = "ball_green"
	elseif flag == 3 then
		asset = "ball_blue"
	elseif flag == 4 then
		asset = "ball_org"
	elseif flag == 5 then
		asset = "ball_gray"
	end
	return "uis/views/login/images_atlas", asset
end

function LoginView:ChangeProf()
	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end

	if not IsNil(self.cg_idle) then
		self.cg_idle:Stop()
	end

	if not IsNil(self.cg_attack) then
		self.cg_attack:Play()
	end
	-- if self.select_sex == GameEnum.MALE then
	-- 	self:ClickRoleAttackMale()
	-- else
	-- 	self:ClickRoleAttackFemale()
	-- end
end

-- 选择男
function LoginView:ClickSex1()
	self.select_sex = GameEnum.MALE
	if self.select_male.toggle.isOn then
		return
	end
	self.select_male.toggle.isOn = true
	self:FlushDetails()
	self:RandomName()

	if not IsNil(self.cg_chuchang) then
		self.cg_chuchang:Stop()
	end

	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end

	if not IsNil(self.cg_idle_male) then
		self.cg_idle_male:Stop()
	end

	if not IsNil(self.cg_idle_female) then
		self.cg_idle_female:Stop()
	end

	if not IsNil(self.cg_attack_male) then
		self.cg_attack_male:Stop()
	end

	if not IsNil(self.cg_attack_female) then
		self.cg_attack_female:Stop()
	end

	if not IsNil(self.cg_to_female) then
		self.cg_to_female:Stop()
	end

	if not IsNil(self.cg_to_male) then
		self.cg_to_male:Play()
	end
end

-- 选择女
function LoginView:ClickSex2()
	self.select_sex = GameEnum.FEMALE
	if self.select_female.toggle.isOn then
		return
	end
	self.select_female.toggle.isOn = true

	self:FlushDetails()
	self:RandomName()

	if not IsNil(self.cg_chuchang) then
		self.cg_chuchang:Stop()
	end

	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.cg_handler)
		self.cg_handler = nil
	end

	if not IsNil(self.cg_idle_male) then
		self.cg_idle_male:Stop()
	end

	if not IsNil(self.cg_idle_female) then
		self.cg_idle_female:Stop()
	end

	if not IsNil(self.cg_attack_male) then
		self.cg_attack_male:Stop()
	end

	if not IsNil(self.cg_attack_female) then
		self.cg_attack_female:Stop()
	end

	if not IsNil(self.cg_to_male) then
		self.cg_to_male:Stop()
	end

	if not IsNil(self.cg_to_female) then
		self.cg_to_female:Play()
	end
end

function LoginView:ChangeScene(bundle, asset, callback)
	local key = bundle..asset
	local SceneManager = UnityEngine.SceneManagement.SceneManager
	-- 关闭其他的场景.
	-- for k,v in pairs(self.scene_cache) do
	-- 	if k ~= key then
	-- 		local objs = v.roots
	-- 		for i = 0,objs.Length-1 do
	-- 			local obj = objs[i]
	-- 			obj:SetActive(false)
	-- 		end
	-- 	end
	-- end
	-- 激活/加载当前场景
	local scene = self.scene_cache[key]
	if scene ~= nil then
		SceneManager.SetActiveScene(scene.scene)
		local objs = scene.roots
		for i = 0,objs.Length-1 do
			local obj = objs[i]
			obj:SetActive(true)
		end
		callback()
	else
		local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Additive
		if not self.has_scene_cached then
			self.scene_cache = {}
			self.cg_instance_list = {}
		end
		AssetManager.LoadLevelSync(
			bundle,
			asset,
			load_mode,
			function()
				self.scene_loaded_bundle_name_t[bundle] = bundle

				Scheduler.Delay(function()
					local scene = SceneManager.GetSceneByName(asset)
					SceneManager.SetActiveScene(scene)
					self.scene_cache[key] = {
						scene = scene,
						roots = scene:GetRootGameObjects()
					}
					self.has_scene_cached = true
					callback()
				end)
			end)
	end
end

function LoginView:PreloadScene(bundle, asset, cg_bundle, cg_asset, callback, not_hide)
	local key = bundle..asset
	local SceneManager = UnityEngine.SceneManagement.SceneManager

	local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Additive
	if not self.has_scene_cached then
		self.scene_cache = {}
		self.cg_instance_list = {}
	end

	local scene_load_callback = function ()
		print_log("[loading] finish load create scene", bundle, asset, os.date())
		local scene = SceneManager.GetSceneByName(asset)
		local objs = scene:GetRootGameObjects()

		if not not_hide then
			for i = 0,objs.Length-1 do
				local obj = objs[i]
				obj:SetActive(false)
			end
		end

		self.scene_cache[key] = {
			scene = scene,
			roots = objs
		}
		self.has_scene_cached = true
		self:PreLoadCG(cg_bundle, cg_asset, objs, function ()
			callback()
		end)
	end

	if self.scene_cache[key] then
		scene_load_callback()
	else
		print_log("[loading] start load create scene", bundle, asset, os.date())
		AssetManager.LoadLevelSync(bundle, asset, load_mode,
		function()
			self.scene_loaded_bundle_name_t[bundle] = bundle
			Scheduler.Delay(function()
				scene_load_callback()
			end)
		end)
	end
end

function LoginView:PreLoadCG(bundle, asset, objs, callback)
	if nil == bundle or nil == asset then
		callback()
		return
	end
	local cg_key = bundle .. asset
	if not self.cg_instance_list[cg_key] then
		print_log("[loading] start load create cg", bundle, asset, os.date())
		UtilU3d.PrefabLoad(bundle, asset, function(cg_obj)
			print_log("[loading] finish load create cg", bundle, asset, os.date())
			if cg_obj then
				cg_obj.gameObject:SetActive(false)
				local center = nil
				for i = 0, objs.Length - 1 do
					if objs[i].gameObject.name == "Center" then
						center = objs[i]
						break
					end
				end
				if center then
					self.cg_instance_list[cg_key] = cg_obj
					cg_obj.transform:SetParent(center.transform)
				end
			end
			callback()
		end, true)
	else
		callback()
	end
end

function LoginView:PlayLoginMusic()
	AudioService.Instance:PlayBgm("audios/musics/bgmlogin", "loginmusic")
end

function LoginView:OnToggleChangeIosShield(prof, is_click)
	if is_click then
		local bundle = SCENE_BUNDLE[1].bundle
		local asset = SCENE_BUNDLE[1].asset
		self:ChangeScene(bundle, asset, function()
			self.select_server:SetActive(false)
			self.login_root:SetActive(false)
			self.select_role:SetActive(false)
			self.create_role:SetActive(true)

			self.select_prof = prof
			self:FlushDetails()
			local prof_numb = 62 + prof
			self.profession_ability:SetAsset("uis/views/login/images_atlas", "icon_0" .. prof_numb)
			self.profession_icon:SetAsset("uis/views/login/images_atlas", "prof_icon_" .. prof)
			for i,v in ipairs(self.profession_icon_list) do
				if i == prof then
					v:SetValue(true)
				else
					v:SetValue(false)
				end
			end
			self.select_sex = PlayerData.Instance:GetSexByProf(prof)
			self.is_male = self.select_sex == GameEnum.MALE
			self:RandomName()

			if not self["prof_toggle_" .. prof].toggle.isOn then
				self["prof_toggle_" .. prof].toggle.isOn = true
			end

			-- self.select_role:SetActive(true)
			local key = bundle..asset
			for k,v in pairs(self.scene_cache) do
				if k ~= key then
					local objs = v.roots
					for i = 0,objs.Length-1 do
						local obj = objs[i]
						obj:SetActive(false)
					end
				else
					local objs = v.roots
					for i = 0,objs.Length-1 do
						local obj = objs[i]
						obj:SetActive(true)
					end
				end
			end
			local center = UnityEngine.GameObject.Find("Center")
			if not center then
				return
			end
			local camera = UnityEngine.GameObject.Find("Camera")
			self.cg_camera = camera:GetComponent(typeof(UnityEngine.Camera))
			if self.cg_camera then
				EasyTouch.AddCamera(self.cg_camera)
			end

			if self.draw_obj then
				self.draw_obj:DeleteMe()
				self.draw_obj = nil
			end
			self.draw_obj = DrawObj.New(self, center.transform)
			self.draw_obj.root.transform.localPosition = Vector3.zero
			self.draw_obj.root.transform.localRotation = Quaternion.identity

			--镰刀角色，休闲动画特殊处理
			if prof == 2 then
				self.draw_obj:GetPart(SceneObjPart.Main):SetBool("idle_n2",true)
			end

			local role_res_id = 0
			local weapon_res_id = 0
			-- 查找职业表
			local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
			local role_job = job_cfgs[prof]
			if role_job ~= nil then
				if role_res_id == 0 then
					role_res_id = role_job["model" .. self.select_sex]
				end
				if weapon_res_id == 0 then
					weapon_res_id = role_job["right_weapon" .. self.select_sex]
				end
			end

			self.draw_obj:SetLoadComplete(function(part, obj)
				if part == SceneObjPart.Main then
					local colider = obj.gameObject:GetComponentInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
					local gameObject = colider.gameObject
					colider = gameObject:GetComponent(typeof(UnityEngine.CapsuleCollider))
					if colider == nil then
						gameObject:AddComponent(typeof(UnityEngine.CapsuleCollider))
					end
					TipsCtrl.Instance:CloseLoadingTips()
				end
				local related_part = self.draw_obj:GetPart(part)
				if nil ~= related_part then
					related_part:SetMaterialIndex(1)
				end
			end)
			-- 主角
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:ChangeModel(ResPath.GetRoleModel(role_res_id))

			-- 武器1
			local wepapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
			wepapon_part:ChangeModel(ResPath.GetWeaponModel(weapon_res_id))
		end)
	end
end

---------------------------------------------------------------
ServerItemContent = ServerItemContent  or BaseClass(BaseCell)

function ServerItemContent:__init()
	self.server_item_contain_list = {}
	for i = 1, 2 do
		self.server_item_contain_list[i] = {}
		self.server_item_contain_list[i].server_item_item = ServerItem.New(self:FindObj("ServerItem" .. i))

		self.server_item_contain_list[i].server_item_item:SetToggleGroup(LoginView.Instance.select_common.toggle_group)
	end
end

function ServerItemContent:__delete()
	for i=1,2 do
		self.server_item_contain_list[i].server_item_item:DeleteMe()
		self.server_item_contain_list[i].server_item_item = nil
	end
end

function ServerItemContent:SetData(data)
	for i=1,2 do
		self.server_item_contain_list[i].server_item_item:SetData(data[i])
	end
end

----------------------------------------------------------------------------
ServerItem = ServerItem or BaseClass(BaseCell)

function ServerItem:__init()

	self.server_id = 0

	self.status = self:FindVariable("status")
	self.level = self:FindVariable("level")
	self.server_name = self:FindVariable("server_name")
	self.hand_image = self:FindVariable("hand_image")
	self.new_server_flag = self:FindVariable("new_server_flag")
	self:ListenEvent("click_item", BindTool.Bind(self.OnClickItem, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
end

function ServerItem:SetData(data)
	self.data = data
	self:OnFlush()
end

function ServerItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ServerItem:OnFlush()
	self.root_node:SetActive(true)
	if self.data == nil then
		self.root_node:SetActive(false)
		return
	end

	if self.data.id == LoginView.Instance:GetCurSelectServerId() then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end

	local bundle_bundle, bundle_asset = self:GetServerState(self.data.flag)
	local hand_bundle, hand_asset = "uis/images_atlas", "Torch_2"

	if self.data.flag == 2 then
		self.new_server_flag:SetValue(false)
	else
		self.new_server_flag:SetValue(true)
	end

	self.status:SetAsset(bundle_bundle, bundle_asset)
	self.level:SetValue(self.data.role_level)

	local name = LoginData.Instance:GetShowServerName(self.data)
	self.server_name:SetValue(name)
	self.hand_image:SetAsset(hand_bundle, hand_asset)
end

function ServerItem:OnClickItem()
--点击
	LoginView.Instance:SetCurSelectServerId(self.data.id)
	GameNet.Instance:SetLoginServerInfo(self.data.ip, self.data.port)
	GameVoManager.Instance:GetUserVo().plat_server_id = self.data.id
	GameVoManager.Instance:GetUserVo().plat_server_name = LoginData.Instance:GetServerName(self.data.id)
	LoginView.Instance:OnClickSelectBack()
end

function ServerItem:OnValueChange()
--点击
end

function ServerItem:GetServerState(flag)
	local asset = ""
	if flag == 1 then
		asset = "ball_red"
	elseif flag == 2 then
		asset = "ball_green"
	elseif flag == 3 then
		asset = "ball_blue"
	elseif flag == 4 then
		asset = "ball_gray"
	elseif flag == 5 then
		asset = "ball_org"
	end
	return "uis/views/login/images_atlas", asset
end

---------------------------------
ServerGroupItem = ServerGroupItem or BaseClass(BaseCell)

function ServerGroupItem:__init()

	self.server_name = self:FindVariable("server_name")
	self.cur_group_index = 0

	self:ListenEvent("click_item", BindTool.Bind(self.OnClickItem, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnValueChange,self))
end

function ServerGroupItem:SetData(data)
	self.data = data
	self.cur_group_index = data.cell_index
	self:OnFlush()
end

function ServerGroupItem:OnFlush()
	if self.cur_group_index == LoginView.Instance:GetCurGroupIndex() then
		self.root_node.toggle.isOn = true
		self:OnClickItem()
	else
		self.root_node.toggle.isOn = false
	end

	local server_name = (self.data.begin_index + 1) .. "-" .. (self.data.end_index + 1) .. Language.Login.Qu
	if self.data.begin_index == self.data.end_index then
		server_name = (self.data.begin_index + 1) .. Language.Login.Qu
	end

	self.server_name:SetValue(server_name)
end

function ServerGroupItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ServerGroupItem:OnClickItem()
	LoginView.Instance:SetTempServerEndIndex(self.data.end_index)
	LoginView.Instance:SetCurGroupIndex(self.cur_group_index)
end

function ServerGroupItem:OnValueChange(is_click)
	--点击
	--if is_click then
	--end
end

function LoginView:EnterGameServerSucc()
	self.login_succ = true
	-- 提前打开加载页（为了进游戏时的体验）
	Scene.Instance:OpenSceneLoading()
end