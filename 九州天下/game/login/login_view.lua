LoginView = LoginView or BaseClass(BaseView)
LoginView.ProfIcon = {
	[1] = {"icon_102", "icon_099"},
	[2] = {"icon_101", "icon_098"},
	[3] = {"icon_100", "icon_097"},
}
local GROUP_SERVER_COUNT = 10

function LoginView:__init()
	LoginView.Instance = self
	self.ui_config = {"uis/views/login", "LoginView"}

	self.server_list = LoginData.Instance:GetShowServerList()
	self.server_count = #self.server_list

	self.group_count = math.ceil(self.server_count / GROUP_SERVER_COUNT)
	self.server_temp_end_index = GROUP_SERVER_COUNT - 1

	self.select_server_id = 1
	self.scene_cache = {}
	self.scene_loaded_bundle_name_t = {}
	self.has_scene_cached = false

	self.is_open_create = false				-- 是否打开过创建角色界面(用于返回的时候做判断用)
	-- self.is_click_event = false				-- 监听模型点击事件

	self.select_sex = GameEnum.MALE
	self.select_prof = 0
	self.server_group_cell_list = {}
	self.server_content_cell_list = {}
	self.server_item_num_in_group = GROUP_SERVER_COUNT
	self.cur_group_index = 0
	self.select_guojia_index = 1
	self.last_server = LoginData.Instance:GetLastLoginServer()
	self.cur_select_server = self.last_server

	self.cg_instance_list = {}
	self.current_cg_obj = nil

	self.first_list = {}
	self.last_list = {}
	self.re_count = 0
	self.need_show_spid = false
end

function LoginView:__delete()
end

function LoginView:ReleaseCallBack()
	self:DeleteSelectRoleView()
	--[[if self.role_model_view then
		self.role_model_view:DeleteMe()
		self.role_model_view = nil
	end]]

	for k,v in pairs(self.scene_loaded_bundle_name_t) do
		AssetManager.UnloadAsseBundle(v)
	end
	self.scene_loaded_bundle_name_t = {}


	for k, v in pairs(self.server_content_cell_list) do
		v:DeleteMe()
	end
	self.server_content_cell_list = {}

	self.cg_chuchang = nil
	self.cg_to_idle = nil
	self.cg_zhujue = nil

	self.selectguojia = {}
	self.create_role_scene_camera = nil
	self.last_sever_state = nil
	self.group_list_view = nil
	self.server_list_view = nil

	self.login_root = nil
	self.select_server = nil
	self.select_common = nil
	--self.select_male = nil
	--self.select_female = nil

	self.default_sever_text = nil
	self.img_prof_name = nil
	self.img_prof_desc = nil

	self.create_role = nil

	self.craps = nil
	self.default_login = nil
	self.login_view = nil

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

	self.obj_select_role_event = nil

	self.role_rotate_area = nil

	self.first_list = {}
	self.last_list = {}
	self.re_count = 0

	self.load_callback = nil
	self.show_arrow = {}

	self.show_flag = false
	self.show_login_btn = false
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
	self:InitRanDomName()

	self.show_flag = self:FindVariable("ShowSpidInfo")
	self:InitSpidInfo()

	self.login_root = self:FindObj("LoginRoot")
	self.select_server = self:FindObj("SelectServer")
	self.select_common = self:FindObj("SelectCommon")
	--self.select_male = self:FindObj("SelectMale")
	--self.select_female = self:FindObj("SelectFemale")
	self.select_role = self:FindObj("SelectRole")

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

	self.img_prof_name = self:FindVariable("ProfName")
	self.img_prof_desc = self:FindVariable("ProfDesc")

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

	-- 创建角色旋转区域(暂时屏蔽创角旋转)
	self.role_rotate_area = self:FindObj("RoleRotateArea")
	local event_trigger = self.role_rotate_area:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self:ListenEvent("CreateRetunClick", BindTool.Bind(self.OnCreateRetunClick, self))
	self:ListenEvent("DefaultReturnClick", BindTool.Bind(self.OnDefaultReturnClick, self))
	self:ListenEvent("StartGame", BindTool.Bind(self.OnStartGameClick, self))
	self:ListenEvent("SelectServer", BindTool.Bind(self.OnSelectServerClick, self))
	self:ListenEvent("RotateCrapsClick", BindTool.Bind(self.OnCrapsClick, self))
	self:ListenEvent("OnClickLogin", BindTool.Bind(self.OnClickLogin, self))

	local create_confirm_btn = self:FindObj("CreateConfirmBtn")
	create_confirm_btn.button:AddClickListener(
		BindTool.Bind(self.OnClickCreateConfirm, self))
	self.craps = self:FindObj("Craps")
	self.default_login = self:FindObj("Default_login")
	self.login_view = self:FindObj("LoginView")

	self.serverlist_bg = self:FindObj("ServerListBg")
	self.prof_desc = self:FindVariable("prof_desc")
	self.character_name = self:FindVariable("character_name")
	self.prof_toggle_1 = self:FindObj("prof_toggle_1")
	self.prof_toggle_2 = self:FindObj("prof_toggle_2")
	self.prof_toggle_3 = self:FindObj("prof_toggle_3")
	self.prof_toggle_4 = self:FindObj("prof_toggle_4")

	self.show_arrow = {}
	self.selectguojia = {}
	for i = 1, 3 do
		self.selectguojia[i] = {}
		self.selectguojia[i].select_btn = self:FindObj("SelectGuoJia" .. i)
		self:ListenEvent("BtnSelectGuoJia" .. i ,BindTool.Bind(self.OnSelectGuoJia, self, i))
		self.show_arrow[i] = self:FindVariable("ShowArrow"..i)
	end

	local last_item = self:FindObj("SelectLastItem")
	last_item.toggle.isOn = true
	self.select_index = 0
	-- 显示账号登陆界面

	local login_data = LoginData.Instance
	local ip = login_data:GetGetServerIP(self.last_server)
	local port = login_data:GetGetServerPort(self.last_server)
	GameNet.Instance:SetLoginServerInfo(ip, port)
	GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
	GameVoManager.Instance:GetUserVo().plat_server_name = login_data:GetServerName(self.last_server)

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
	self.login_view:SetActive(true)

	-- 显示Logo
	self.show_default_logo = self:FindVariable("ShowDefaultLogo")
	self.logo_url = self:FindVariable("LogoURL")
	-- 检查SDK是否存在特殊的Logo，如果存在则使用SDK的Logo
	if AssetManager.ExistedInStreaming("AgentAssets/logo.png") then
		self.show_default_logo:SetValue(false)
		local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/logo.png"
		self.logo_url:SetValue(url)
	else
		self.show_default_logo:SetValue(true)
	end

	self:PlayLoginMusic()

	self.show_login_btn = self:FindVariable("ShowLogBtn")
	local check_agent_id = ChannelAgent.GetChannelID()
	local show_log_bt_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shieldloginbtn_list or {}
	local show_login_btn_flag = true
	for k,v in pairs(show_log_bt_cfg) do
		if v.spid == check_agent_id then
			show_login_btn_flag = false
			break
		end
	end

	self.show_login_btn:SetValue(show_login_btn_flag)
end

function LoginView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_select_role_view" then
			self:FlushSelectRoleView()
		elseif k == "back_login_view" then
			self:BackLoginView()
		elseif k =="server_list" then
			self:FlushServerList()
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
	local last_server = LoginData.Instance:GetServerVoById(self.last_server)
	self.last_sever_state:SetAsset(self:GetServerState(flag, last_server))
end

function LoginView:OnClickLastItem(is_click)
	if is_click then
		local login_Data = LoginData.Instance
		local name = login_Data:GetShowServerNameById(self.last_server)
		local ip = login_Data:GetGetServerIP(self.last_server)
		local port = login_Data:GetGetServerPort(self.last_server)

		GameNet.Instance:SetLoginServerInfo(ip, port)
		GameVoManager.Instance:GetUserVo().plat_server_id = self.last_server
		GameVoManager.Instance:GetUserVo().plat_server_name = login_Data:GetServerName(self.last_server)
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

function LoginView:FlushServerList()
	self.server_list = LoginData.Instance:GetShowServerList()
	self.server_count = #self.server_list
	self.group_count = math.ceil(self.server_count / GROUP_SERVER_COUNT)
	if self.server_list_view then
		self.server_list_view.scroller:ReloadData(0)
	end
	if self.group_list_view then
		self.group_list_view.scroller:ReloadData(0)
	end
end

----------创建ListView------------

function LoginView.SetServerItemName(server_item, name)
	local left_text = server_item:FindObj("LeftText")
	left_text.text.text = name
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
		-- 预加载场景
		self:PreloadScene("scenes/map/gz_chuangjue_main", "Gz_ChuangJue_Main", function()
			-- PreloadManager.Instance:WaitComplete(function()
				ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
				GameNet.Instance:AsyncConnectLoginServer(5)
				self.select_server:SetActive(false)
				self.default_login:SetActive(false)
				self.select_role:SetActive(false)
				self.login_view:SetActive(false)
			-- end)
		end)
		return
	end

	-- SDK登录
	self.login_view:SetActive(true)
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
end
 
function LoginView:OnCrapsClick()
	self:RandomName()
end

function LoginView:FlushDetails()
	local role_conifg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	if role_conifg then
		local job_config = role_conifg[self.select_prof]
		if job_config then
			self.prof_desc:SetValue(job_config.describe)
			self.character_name:SetValue(job_config["name" .. self.select_sex])
		end
	end
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

	if self.show_flag ~= nil then
		self.show_flag:SetValue(self.need_show_spid)
	end
end

function LoginView:ClearCgObj()
	-- 清空CG实例
	for k, v in pairs(self.cg_instance_list) do
		GameObject.Destroy(v)
	end
	self.cg_instance_list = {}
	self.current_cg_obj = nil
end

function LoginView:ClearScenes()
	if nil ~= self.create_role_scene_camera and not IsNil(self.create_role_scene_camera.gameObject) and not self.create_role_scene_camera.gameObject.activeSelf then
		self.create_role_scene_camera.gameObject:SetActive(true)
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
		print("----- clear ----- ")
		GameObject.Destroy(v)
	end
	self.cg_instance_list = {}

	self.current_cg_obj = nil
	self.current_cg_chuchang = nil
	self.current_cg_idle = nil

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
	local bunle_name = "scenes/map/gz_denglu01_denglu01"
	local asset_name = "GZ_DengLu01.unity"
	local scene_name = "GZ_DengLu01"

	local check_agent_id = ChannelAgent.GetChannelID()
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").aml_loinscene or {}
	for k,v in pairs(agent_cfg) do
		if v.spid == check_agent_id and v.show_type == 1 then
			bunle_name = "scenes/map/gz_xindenglu01_xindenglu01"
			asset_name = "GZ_XinDengLu01.unity"
			scene_name = "GZ_XinDengLu01"
			break
		end
	end		

	AssetManager.LoadLevelSync(
		bunle_name,
		asset_name,
		UnityEngine.SceneManagement.LoadSceneMode.Single,
		function()
			self.scene_loaded_bundle_name_t[bunle_name] = bunle_name
			Scheduler.Delay(function()
				local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(scene_name)
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

function LoginView:OnCreateRetunClick()
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	GlobalTimerQuest:CancelQuest(self.cg_handler)
	self.cg_handler = nil
	self.select_role_id = 0
	self.is_enter_select_role = false

	if self.is_open_create and role_list_ack_info.count > 0 then
		-- if self.cg_instance then
		-- 	GameObject.Destroy(self.cg_instance)
		-- 	self.cg_instance = nil
		-- end
		-- 清空CG实例
		for k, v in pairs(self.cg_instance_list) do
			GameObject.Destroy(v)
		end
		self.cg_instance_list = {}
		self.current_cg_obj = nil

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
	self:ShowLogin()
end

function LoginView:OnClickLogin()
	self.login_view:SetActive(false)
	self:ShowLogin()
end

function LoginView:OnStartGameClick()
	if not LoginData.Instance:IsCanLoginServer(self.cur_select_server) then
		return
	end

	ReportManager:Step(Report.STEP_CLICK_START_GAME)
	TipsCtrl.Instance:ShowLoadingTips()

	-- 预加载场景
	-- self:PreloadScene("scenes/map/xjjm_zs_main", "Xjjm_zs_Main", function()
		-- self:PreloadScene("scenes/map/xjjm_fs_main", "Xjjm_fs_Main", function()
			-- self:PreloadScene("scenes/map/xjjm_qs_main", "Xjjm_qs_Main", function()
			self:PreloadScene("scenes/map/gz_chuangjue_main", "Gz_ChuangJue_Main", function()
				PreloadManager.Instance:WaitComplete(function()
					-- 卸载登陆场景.
					-- local SceneManager = UnityEngine.SceneManagement.SceneManager
					-- local scene = SceneManager.GetSceneByName("Dljm01_Main")
					-- if scene:IsValid() then
					-- 	SceneManager.UnloadSceneAsync(scene)
					-- end

					ReportManager:Step(Report.STEP_CONNECT_LOGIN_SERVER)
					GameNet.Instance:AsyncConnectLoginServer(5)
					self.select_server:SetActive(false)
					self.default_login:SetActive(false)
					self.select_role:SetActive(false)
					self.login_view:SetActive(false)
				end)
			end)
		-- end)
	-- end)

	if not IS_ON_CROSSSERVER then
		UnityEngine.PlayerPrefs.SetString("PRVE_SRVER_ID", self.cur_select_server)
		self.last_server = self.cur_select_server
	end
end

--自动选择战斗力最弱的国家
function LoginView:OnAutoSelectGuoJia()
	-- local camp_capability = LoginData.Instance:GetCampCapability()
	-- local tmp = camp_capability[1]
	-- local min_index = 1						
	-- for i = 2, 3 do
	-- 	if camp_capability[i] < tmp then
	-- 		min_index = i
	-- 		tmp = camp_capability[i]
	-- 	end
	-- end
	math.randomseed(os.time())
	local min_index = math.random(1, 3)
	self:OnSelectGuoJia(min_index)
	for k, v in pairs(self.selectguojia) do
		if v ~= nil and v.select_btn ~= nil and v.select_btn.toggle ~= nil then
			v.select_btn.toggle.isOn = k == min_index
			self.show_arrow[k]:SetValue(k == min_index)
		end
	end

	for i = 1, 3 do
		if self.show_arrow and self.show_arrow[i] then
			self.show_arrow[i]:SetValue(false)
		end
	end

	local arrow_state = LoginData.Instance:GetShowArrowState()
	if arrow_state and min_index <= 3 then
		if self.show_arrow and self.show_arrow[min_index] then
			self.show_arrow[min_index]:SetValue(true)
		end
	end
	-- if self.selectguojia[min_index] and self.selectguojia[min_index].select_btn and self.selectguojia[min_index].select_btn.toggle then
	-- 	self.selectguojia[min_index].select_btn.toggle.isOn = true
	-- end
end

function LoginView:OnSelectServerClick()
	self.default_login:SetActive(false)
	self.select_role:SetActive(false)
	self.login_view:SetActive(false)
	self.select_server:SetActive(true)

	if self.show_flag ~= nil then
		self.show_flag:SetValue(false)
	end
end

-- 选择国家
function LoginView:OnSelectGuoJia(index)
	self.select_guojia_index = index
	LoginData.Instance:SetCampIndex(self.select_guojia_index)
end

function LoginView:OnChangeToCreate()
	if self:IsOpen() then
		self.is_open_create = true
		self.select_prof = 0
		-- self.select_server:SetActive(false)
		-- self.login_root:SetActive(false)
		-- self.select_role:SetActive(false)
		-- self.create_role:SetActive(true)
		local index = math.random(1, 4)
		self:OnToggleChange(index, true)
		AudioService.Instance:PlayBgm("audios/musics/bgmxuanjue", "xuanjuebgm")
	end
end

function LoginView:OnToggleChange(prof, is_click)
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
		-- self:FlushDetails()

		local img_asset, img_name = ResPath.GetLoginPackRes("prof_name_" .. prof)
		self.img_prof_name:SetAsset(img_asset, img_name)

		img_asset, img_name = ResPath.GetLoginRes("prof_desc_bg_" .. prof)
		self.img_prof_desc:SetAsset(img_asset, img_name)

		self.cg_chuchang = nil
		self.cg_to_idle = nil
		self.cg_zhujue = nil
		-- self.cg_to_female = nil
		-- self.cg_to_male = nil
		-- self.cg_idle_female = nil
		-- self.cg_idle_male = nil
		-- self.cg_attack_female = nil
		-- self.cg_attack_male = nil
		local bundle = "scenes/map/gz_chuangjue_main"
		local asset = "Gz_ChuangJue_Main"
		local cg_bundle, cg_asset
		if prof == 1 then
			cg_bundle = "cg/gz_xjjm_jian_prefab"
			cg_asset = "CG_nanjian"
			-- position = Vector3.zero
			-- rotation = Quaternion.Euler(0, -42.517, 0)
			self.select_sex = GameEnum.MALE
		elseif prof == 2 then
			cg_bundle = "cg/gz_xjjm_qiang_prefab"
			cg_asset = "CG_qiang"
			-- position = Vector3.zero
			-- rotation = Quaternion.Euler(0, -2.7, 0)
			self.select_sex = GameEnum.FEMALE
		elseif prof == 3 then
			cg_bundle = "cg/gz_xjjm_gong_prefab"
			cg_asset = "CG_gong"
			self.select_sex = GameEnum.MALE
		else
			cg_bundle = "cg/gz_xjjm_qin_prefab"
			cg_asset = "CG_qin"
			self.select_sex = GameEnum.FEMALE
		end

		self:RandomName()

		if self.cg_handler ~= nil then
			GlobalTimerQuest:CancelQuest(self.cg_handler)
			self.cg_handler = nil
		end

		-- if self.cg_instance ~= nil then
		-- 	GameObject.Destroy(self.cg_instance)
		-- 	self.cg_instance = nil
		-- end

		-- 清空CG实例
		-- for k,v in pairs(self.cg_instance_list) do
		-- 	GameObject.Destroy(v)
		-- end
		-- self.cg_instance_list = {}
		-- self.current_cg_obj = nil


		-- CG 切换
		local change_scene_func = function(bundle, asset, cg_key, cg_obj)
			self:ChangeScene(bundle, asset, function()

				if not cg_obj and not self.cg_instance_list[cg_key] then
					return
				end


				self.select_server:SetActive(false)
				self.login_root:SetActive(false)
				self.select_role:SetActive(false)
				TipsCtrl.Instance:CloseLoadingTips()

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

				if not self.cg_instance_list[cg_key] then
					self.cg_instance_list[cg_key] = cg_obj
				else
					cg_obj = self.cg_instance_list[cg_key]
				end
				
				if self.current_cg_obj and not IsNil(self.current_cg_obj) then
					self.current_cg_obj:SetActive(false)
				end
				self.current_cg_obj = cg_obj

				if cg_obj and not IsNil(cg_obj) then
					cg_obj:SetActive(true)
				end

				if self.cg_instance_list == nil or cg_key == nil or IsNil(self.cg_instance_list[cg_key]) then
					return
				end

				self.cg_instance_list[cg_key].transform:SetParent(center.transform)

				self.cg_instance_list[cg_key].transform.localPosition = Vector3.zero
				self.cg_instance_list[cg_key].transform.localRotation = Quaternion.identity

				-- 创角色的CG角色
				self.cg_zhujue = self.cg_instance_list[cg_key].transform:Find("zhujue")
				self.cg_zhujue_rotate_cache = {x = 0, y = 0, z = 0}
				self.cg_zhujue.transform.localRotation = Quaternion.Euler(
				self.cg_zhujue_rotate_cache.x, self.cg_zhujue_rotate_cache.y, self.cg_zhujue_rotate_cache.z)

				local chuchang = self.cg_instance_list[cg_key].transform:Find("stage_chuchang")
				local idle = self.cg_instance_list[cg_key].transform:Find("stage_idle")

				if self.cg_chuchang then
					self.cg_chuchang:Stop()
				end

				if self.cg_to_idle then
					self.cg_to_idle:Stop()
				end

				self.cg_chuchang = chuchang:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
				self.cg_to_idle = idle:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))


				self.cg_chuchang:Play()

				-- 关闭其他的场景.
				-- for k,v in pairs(self.scene_cache) do
				-- 	if k ~= key then
				-- 		local objs = v.roots
				-- 		for i = 0, objs.Length-1 do
				-- 			local obj = objs[i]
				-- 			obj:SetActive(false)
				-- 		end
				-- 	end
				-- end

				-- 卸载登录界面(龙出来喷火那个)
				-- local SceneManager = UnityEngine.SceneManagement.SceneManager
				-- local scene = SceneManager.GetSceneByName("GZ_DengLu01")
				-- if scene and scene:IsValid() then
				-- 	local roots = scene:GetRootGameObjects()
				-- 	for i = 0,roots.Length-1 do
				-- 		local obj = roots[i]
				-- 		obj:SetActive(false)
				-- 	end
				-- 	SceneManager.UnloadSceneAsync(scene)
				-- end

				-- local camera = UnityEngine.GameObject.Find("Main/Camera")
				-- if camera then
				-- 	camera.gameObject:SetActive(false)
				-- end

				-- -- 屏蔽动画换角色后继续播放动画
				-- if self.cg_played_t[prof] and not IsNil(self.cg_chuchang) then
				-- 	self.cg_chuchang:Stop()
				-- 	self.create_role:SetActive(true)
				-- 	if not self["prof_toggle_" .. prof].toggle.isOn then
				-- 		self["prof_toggle_" .. prof].toggle.isOn = true
				-- 	end
				-- 	return
				-- end
				-- self.cg_played_t[prof] = true

				self.create_role:SetActive(false)
				if self.cg_handler ~= nil then
					GlobalTimerQuest:CancelQuest(self.cg_handler)
					self.cg_handler = nil
				end
				self.cg_handler = GlobalTimerQuest:AddRunQuest(
					function()
						if not IsNil(self.cg_chuchang) then
							if self.cg_chuchang.duration - self.cg_chuchang.time <= 0 then
								GlobalTimerQuest:CancelQuest(self.cg_handler)
								self.cg_handler = nil
							-- 	self.if_can_click_model[prof] = true
							-- elseif self.cg_chuchang.duration - self.cg_chuchang.time <= 0.2 then
							
								local bundle, asset = ResPath.GetVoiceRes("prof_" .. prof)
								AudioManager.PlayAndForget(bundle, asset)

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
		local cg_key = cg_bundle..cg_asset
		if not self.cg_instance_list[cg_key] then
			UtilU3d.PrefabLoad(cg_bundle, cg_asset, function(cg_obj)
				if not cg_obj then return end
				change_scene_func(bundle, asset, cg_key, cg_obj)
			end)
		else
			change_scene_func(bundle, asset, cg_key)
		end
	end
end

-- 角色被拖转动事件
function LoginView:OnRoleDrag(data)
	if self.cg_zhujue then
		local cache = self.cg_zhujue_rotate_cache
		self.cg_zhujue_rotate_cache = {x = cache.x, y = -data.delta.x * 0.25 + cache.y, z = cache.z}
		self.cg_zhujue.transform.localRotation = Quaternion.Euler(
			self.cg_zhujue_rotate_cache.x, self.cg_zhujue_rotate_cache.y, self.cg_zhujue_rotate_cache.z)
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
	LoginCtrl.SendCreateRole(role_name, self.select_prof, self.select_sex, LoginData.Instance:GetCampIndex())
end

function LoginView:RandomName()
	local first_list = self.first_list[self.select_sex]
	local last_list = self.last_list[self.select_sex]
	
	local first_index = math.random(1, #first_list)
	local last_index = math.random(1, #last_list)
	local name = first_list[first_index] .. last_list[last_index]
	local isill = ChatFilter.Instance:IsIllegal(name, true)
	
	-- 存在敏感字
	if isill and self.re_count <= 10 then
		self.re_count = self.re_count + 1
		table.remove(first_list, first_index)
		table.remove(last_list, last_index)
		self:RandomName()
	else
		self.input_name.input_field.text = name
		self.re_count = 0
	end
end

function LoginView:InitRanDomName()
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	if not name_cfg then return end
	self.first_list = {}
	self.last_list = {}

	local the_list_1 = {}
	local the_list_2 = {}
	the_list_1[GameEnum.FEMALE] = name_cfg.female_first
	the_list_2[GameEnum.FEMALE] = name_cfg.female_last
	the_list_1[GameEnum.MALE] = name_cfg.male_first
	the_list_2[GameEnum.MALE] = name_cfg.male_last
	
	self.first_list = TableCopy(the_list_1)
	self.last_list = TableCopy(the_list_2)
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
function LoginView:GetServerState(flag, data)
	local server_state = {[0] = "ball_green", [1] = "ball_yellow", [2] = "ball_red", [3] = "ball_blue", [4] = "ball_green", [5] = "ball_gray"}

	local real_flag = flag
	if data ~= nil and data.open_time ~= nil then
		if TimeCtrl ~= nil and TimeCtrl.Instance ~= nil then
			local server_time = TimeCtrl.Instance:GetServerTime() or 0
			if data.open_time > server_time then
				real_flag = 3
			end
		end
	end
	return ResPath.GetLoginRes(server_state[real_flag] or "")
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
		-- SceneManager.SetActiveScene(scene.scene)
		local objs = scene.roots
		for i = 0,objs.Length-1 do
			local obj = objs[i]
			if obj then
				obj:SetActive(true)
			end
		end
		callback()
	else
		local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Additive
		if not self.has_scene_cached then
			self.scene_cache = {}
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

function LoginView:PreloadScene(bundle, asset, callback)
	local key = bundle..asset
	local SceneManager = UnityEngine.SceneManagement.SceneManager

	local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Single
	if not self.has_scene_cached then
		self.scene_cache = {}
	end

	if self.scene_cache[key] then
		callback()
		return
	end

	AssetManager.LoadLevel(
		bundle,
		asset,
		load_mode,
		function()
			self.scene_loaded_bundle_name_t[bundle] = bundle
			Scheduler.Delay(function()
				local scene = SceneManager.GetSceneByName(asset)
				-- local objs = scene:GetRootGameObjects()
				-- for i = 0,objs.Length-1 do
				-- 	local obj = objs[i]
				-- 	obj:SetActive(false)
				-- end
				if scene then
					self.scene_cache[key] = {
						scene = scene,
						roots = scene:GetRootGameObjects(),
					}
					self.has_scene_cached = true
					callback()
				end
			end)
		end)
end

function LoginView:PlayLoginMusic()
	AudioService.Instance:PlayBgm("audios/musics/bgmlogin", "loginmusic")
end

function LoginView:InitSpidInfo()
	local check_agent_id = ChannelAgent.GetChannelID()
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").spid_str
	local show_info = false

	if agent_cfg ~= nil and next(agent_cfg) ~= nil then
		for k,v in pairs(agent_cfg) do
			if v.spid == check_agent_id then
				for i = 1, 4 do
					local tip_str = self:FindVariable("Tip" .. i)
					if tip_str ~= nil and v["str_" .. i] ~= nil then
						tip_str:SetValue(v["str_" .. i])
					end
				end

				show_info = true
				break
			end
		end
	end

	self.need_show_spid = show_info
	--local show_flag = self:FindVariable("ShowSpidInfo")
	if self.show_flag ~= nil then
		self.show_flag:SetValue(show_info)
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
	local hand_bundle, hand_asset = ResPath.GetImages("Torch_2")

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
end

function ServerItem:OnValueChange()
--点击
end

function ServerItem:GetServerState(flag)
	local server_state = {[0] = "ball_green", [1] = "ball_yellow", [2] = "ball_red", [3] = "ball_blue", [4] = "ball_green", [5] = "ball_gray"}
	local real_flag = flag

	if self.data ~= nil and self.data.open_time ~= nil then
		if TimeCtrl ~= nil and TimeCtrl.Instance ~= nil then
			local server_time = TimeCtrl.Instance:GetServerTime() or 0
			if self.data.open_time > server_time then
				real_flag = 3
			end
		end
	end
	return ResPath.GetLoginRes(server_state[real_flag] or "")
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
