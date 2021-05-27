require("scripts/game/login/login_loading")
require("scripts/game/login/login_recommend")
require("scripts/game/login/login_all_serverlist")
require("scripts/game/login/login_server_item")
require("scripts/gameui/widgets/accordion")
require("scripts/gameui/xui")

LoginView = LoginView or BaseClass(BaseView)

LOGIN_FONT_SIZE = 35

LOGIN_BG_MOVE_SPEED = 30

LOGIN_SEVER_GROUP = 10

ALL_SERVER_HAVE_ROLES_T = {}

function LoginView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_LOGIN
	self.is_async_load = false

	self.texture_path_list[1] = 'res/xui/login.png'
	self.texture_path_list[2] = 'res/xui/login_3.png'													  

	self.config_tab = {
		{"login_ui_cfg", 1, {0}},
		{"login_ui_cfg", 2, {0}},
	}

	self.cur_server_data = nil
	self.server_info = {}
end

function LoginView:__delete()
	self.cur_server_data = nil
	self.server_info = {}
end

function LoginView:LoadCallBack()
	self.root_node:setContentSize(cc.size(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()))
	self:InitView()
	self:RegisterEvents()

	self:SetLoginVisible(false)

	-- 背景音乐
	local audio_res_path = ResPath.GetAudioBgResPath(AudioBg.LoginView)
	AudioManager.Instance:PlayMusic(audio_res_path)
end

function LoginView:CloseCallBack()
	LoginController.Instance:AgentLoginViewClose(false)
end

function LoginView:ReleaseCallBack()
	self:AllListReleaseCallBack()
	self:RecommondReleaseCallBack()
	self:LoadingReleaseCallBack()
end

function LoginView:OpenCallBack()
	if self:IsLoaded() then
		self:SetLoginVisible(false)
	end
end

function LoginView:InitView()
	self:InitLoginView()
	--loading
	self:InitLoadingView()
	--选服
	self:InitRecommendView()
	self:InitAllListView()
end

function LoginView:RegisterEvents()
	XUI.AddClickEventListener(self.node_tree.layout_bg.layout_return_btn.node, BindTool.Bind1(self.OnLoginBack, self), true)
	XUI.AddClickEventListener(self.node_tree.layout_bg.layout_enter_game.node, BindTool.Bind1(self.OnLoginConfirm, self), true)
end

function LoginView:InitLoginView()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	self.node_tree.layout_bg.node:setPosition(screen_w / 2, screen_h / 2)

	--创建背景
	local bg_path = "agentres/login_bg.jpg"
	local login_bg = "agentres/login_bg.jpg"
	if cc.FileUtils:getInstance():isFileExist(login_bg) then
		bg_path = login_bg
	end
	self.bg1 = XUI.CreateImageView(screen_w / 2, screen_h / 2, bg_path, false)
	self.root_node:addChild(self.bg1, 0, 0)

	local full_bg = XUI.CreateImageViewScale9(screen_w / 2, screen_h / 2, screen_w + 50, screen_h + 50, ResPath.GetCommon("img9_full"), true)
	self.root_node:addChild(full_bg, -1)
	-- local top_img = XUI.CreateImageView(screen_w / 2, screen_h, ResPath.GetLogin("bg_top"))
	-- top_img:setAnchorPoint(0.5, 1)
	-- self.root_node:addChild(top_img, 0, 0)

	-- local down_img = XUI.CreateImageView(screen_w / 2, 0, ResPath.GetLogin("bg_top"))
	-- down_img:setAnchorPoint(0.5, 1)
	-- down_img:setScaleY(-1)
	-- self.root_node:addChild(down_img, 0, 0)

	--和谐游戏提示(健康游戏忠告)
	local str = AgentAdapter.GetGameTips and AgentAdapter:GetGameTips() or Language.Login.HeXieGameTips
	local game_tips = XUI.CreateText(screen_w / 2, 60, screen_w, 0, cc.TEXT_ALIGNMENT_CENTER, str, nil, 24, COLOR3B.WHITE)
	game_tips:enableOutline(COLOR4B.BLACK, XUI.outline_size)
	self.root_node:addChild(game_tips, 0, 0)

	-- self:CreateDecoration()
end

function LoginView:SetLogoVisible(is_visible)
	-- self.title_img:setVisible(is_visible)
end

function LoginView:CreateDecoration()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local clouds_cfg = {{res_id = 22, x = 0, y = 60},
						{res_id = 22, x = 0, y = 70},
						{res_id = 22, x = 0, y = 120},
						{res_id = 22, x = 0, y = 60},
						{res_id = 22, x = 0, y = 130},
						{res_id = 22, x = 0, y = 70},
						{res_id = 22, x = 0, y = 120},
						{res_id = 22, x = 0, y = 30},
						}

	for k,v in pairs(clouds_cfg) do
		local anim_path, anim_name = ResPath.GetDecorationAnimPath(v.res_id)
		local cloud = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20)
		self.root_node:addChild(cloud)
		cloud:setPosition(v.x + screen_w / #clouds_cfg * k, v.y)
	end

	--stand he
	local stand_he_cfg = {--{res_id = 3, x = 1042, y = 337, scale = 0.7},
						  {res_id = 3, x = 590, y = 45, scale = 1},}

	for k,v in pairs(stand_he_cfg) do
		for i = 1, 2 do 
			local anim_path, anim_name = ResPath.GetDecorationAnimPath(v.res_id)
			local stand_he = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20)
			stand_he:setPosition(v.x, v.y)
			stand_he:setScale(v.scale)
			if 1 == i then self.bg1:addChild(stand_he) end
			if 2 == i then self.bg2:addChild(stand_he) end
		end
	end

	--move he
	local move_he_config = {{res_id = 27, x = screen_w - 140, y = screen_h - 200},
							{res_id = 27, x = screen_w - 120, y = screen_h - 230},
							{res_id = 27, x = screen_w - 100, y = screen_h - 270}}

	for k,v in pairs(move_he_config) do
		local anim_path, anim_name = ResPath.GetDecorationAnimPath(v.res_id)
		local move_he = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20)
		self.root_node:addChild(move_he, 0, 0)
		move_he:setPosition(v.x, v.y)
		move_he:setFlippedX(true)
		-- local act = CCActionEdit.Instance:CreateCCAction("xianhe_login_move", v.x, v.y, -(screen_w + 100)) 
		-- move_he:runAction(act)	
	end	
end

--开始移动背景 
function LoginView:BeginBgMove(bg1,bg2)
	if nil == bg1 or nil == bg2 then return end
	function move_fun(bg, time)
		if nil == bg or nil == time then return end
		local size = bg:getContentSize()
		local move_by = cc.MoveBy:create(time, cc.p(-size.width, 0))
		function func()
			local x = bg:getPositionX()
			if x < 0 then --是否需要重设位置
				bg:setPosition(cc.p(HandleRenderUnit:GetWidth()/2 + size.width, HandleRenderUnit:GetHeight()/2))
			end
			move_fun(bg, LOGIN_BG_MOVE_SPEED)
		end
		local call_back = cc.CallFunc:create(func)
		local sequence = cc.Sequence:create(move_by, call_back)
		bg:stopAllActions()
		bg:runAction(sequence)
	end
	move_fun(bg1, LOGIN_BG_MOVE_SPEED)
	move_fun(bg2, LOGIN_BG_MOVE_SPEED)
end

-- 重连
function LoginView:Reconnect()
	self:SetChooseServerVisible(false)

	local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
	if quick_reconnect == "true" then
		self.root_node:setVisible(false)
	else
		self.node_tree.layout_loading.node:setVisible(true)
	end

	self:OnLoginPlatSucc()

	self:UpdateLoading(0)
end

-- 显示/隐藏选服界面
function LoginView:SetChooseServerVisible(is_visible)
	if nil == self.node_tree.layout_bg then return end
	self.node_tree.layout_bg.node:setVisible(is_visible)
	self.node_tree.layout_bg.layout_select_sever_list.node:setVisible(is_visible)
	self.node_tree.layout_bg.layout_server_recommend.node:setVisible(is_visible)
	self.node_tree.layout_bg.layout_all.node:setVisible(is_visible)
end

-- 登录平台成功
function LoginView:OnLoginPlatSucc()
	ALL_SERVER_HAVE_ROLES_T = {}
	self:SentAllServerRoleUrlReq()
	self:LoadServerList()
	if IS_AUDIT_VERSION then
		self:SetLoginVisible(false)
		for k, v in pairs(self.server_info.server_list) do
			self.cur_server_data = v
			break
		end
		self:OnLoginConfirm()
	end
end

function LoginView:LoadServerList()
	if not self:IsLoaded() then
		return
	end
	Log("Login::LoadServerList ")

	local recommend_server = GLOBAL_CONFIG.server_info.last_server or 1  --推荐服，名字不改了

	local local_last_server = PlatformAdapter:GetShareValueByKey(AgentAdapter:GetPlatName() .. "last_login_server")
	if local_last_server == nil or local_last_server == "" then
		self.server_info.last_server = recommend_server
	else	
		self.server_info.last_server = tonumber(local_last_server) or 1
	end
	self.server_info.server_list = {}
	self.server_info.recommend_server = recommend_server

	local server_offset = GLOBAL_CONFIG.server_info.server_offset or 0 --偏移id
	if server_offset >= 1500 then
		server_offset = 0
	end

	local plat_account_type = GameVoManager.Instance:GetUserVo().plat_account_type
	for _, v in ipairs(GLOBAL_CONFIG.server_info.server_list) do
		if PLAT_ACCOUNT_TYPE_TEST == plat_account_type or 4 ~= v.flag and v.id > server_offset then	-- 非测试号屏蔽测试服
			self.server_info.server_list[v.id] = v
		end
	end

	local last_login_server = self.server_info.last_server

	if LoginController.Instance:GetIsReConnectIng() then 
		local server_id = AdapterToLua:getInstance():getDataCache("PRVE_SRVER_ID")
		if server_id == "" then server_id = last_login_server end
		server_id = tonumber(server_id)

		local last_login_server_data = self.server_info.server_list[server_id] --上次登陆的服务器
		-- 跨服
		local cs_info_str = AdapterToLua:getInstance():getDataCache("CROSS_SERVER_INFO")
		-- AdapterToLua:getInstance():setDataCache("CROSS_SERVER_INFO", "")

		if nil ~= cs_info_str and "" ~= cs_info_str then
			local list = Split(cs_info_str, "##")
			local cs_server_data = {}

			cs_server_data.id = list[1]						-- 服务器ID
			cs_server_data.name = list[2]					-- 服务器名字
			cs_server_data.ip = list[3]						-- 登录服务器IP
			cs_server_data.port = list[4]					-- 登录服务器端口
			cs_server_data.open_time = list[5]				-- 服务器开服时间
			cs_server_data.ahead_time = list[6]       	 	-- 提前开放登录时间(秒)
			cs_server_data.pause_time = list[7]        		-- 维护结束时间
			cs_server_data.flag = list[8]					-- 服务器标记 (1: 火爆 2: 新服 3: 即将开服 4: 测试 5: 维护)
			cs_server_data.avatar = list[9]					-- 头像ID (未实现)
			cs_server_data.role_name = list[10]				-- 角色名字 (未实现)
			cs_server_data.role_level = list[11]			-- 角色等级 (未实现)
			last_login_server_data = cs_server_data
			IS_ON_CROSSSERVER = true
		end
		if last_login_server_data == nil then  -- 重连失败
			LoginController.Instance:ReconnectFail()
		else   --重连成功
			self:SetUserVoByServerData(last_login_server_data)
			self:DoLogin(last_login_server_data.ip, last_login_server_data.port)
		end
	end
	local is_reselectrole = AdapterToLua:getInstance():getDataCache("IS_RESELECTROLE")
	if not LoginController.Instance:GetIsReConnectIng() or is_reselectrole == "true" then
		MainProber:Step(MainProber.STEP_SERVER_SHOW_LIST)
		self:SetLoginVisible(is_reselectrole ~= "true")
		if nil == self.select_server_list then
			local ph = self.ph_list.ph_selectsever_list
			self.select_server_list = ListView.New()
			self.select_server_list:Create(ph.x, ph.y, ph.w, ph.h, nil, LoginSelectServersItem)
			self.select_server_list:GetView():setAnchorPoint(0, 0)
			self.node_tree.layout_bg.layout_select_sever_list.node:addChild(self.select_server_list:GetView(), 300, 300)
			self.select_server_list:SetSelectCallBack(BindTool.Bind1(self.SelectServerCallback, self))
		end
		self.select_server_list:SetDataList(self:GetSecSeverListData())
		self.select_server_list:JumpToTop(true)
		self.select_server_list:SelectIndex(1)
	end
end

function LoginView:GetSecSeverListData(index)
	if nil == self.server_data_list then
		self.server_data_list = {}
		table.insert(self.server_data_list, 1, {})

		local show_list = {}
		local test_server_list = {}

		local group_list = {}

		for k, v in pairs(self.server_info.server_list) do
			if v.id >= 2000 then
				table.insert(test_server_list, v)
			else
				local name = v.name
				local group_name = string.match(name, "^(.-)-")
				if nil ~= group_name then
					-- 有组名的区服
					v.special_group_name = group_name
					if nil == group_list[group_name] then
						group_list[group_name] = {}
					end
					table.insert(group_list[group_name], 1, v)
				else
					table.insert(show_list, v)
				end
			end
		end

		for k, v in pairs(group_list) do
			table.sort(v, SortTools.KeyUpperSorter("id"))
			table.insert(self.server_data_list, v)
		end

		table.sort(show_list, SortTools.KeyLowerSorter("id"))
		-- 每LOGIN_SEVER_GROUP个服为一组
		local temp_server_list = {}
		for i, v in ipairs(show_list) do
			table.insert(temp_server_list, 1, v)
			if #temp_server_list >= LOGIN_SEVER_GROUP then
				table.insert(self.server_data_list, 2, temp_server_list)
				temp_server_list = {}
			end
		end
		if #temp_server_list > 0 then
			table.insert(self.server_data_list, 2, temp_server_list)
			temp_server_list = {}
		end

		table.sort(test_server_list, SortTools.KeyUpperSorter("id"))
		-- 若有体验服，则把体验服放到最后
		if #test_server_list > 0 then
			table.insert(self.server_data_list, test_server_list)
		end
	end

	return index and self.server_data_list[index] or self.server_data_list
end

function LoginView:SelectServerCallback(select_item)
	self:SelectTabCallback(select_item:GetIndex())
end

function LoginView:SelectTabCallback(index)
	if 1 == index then
		self.recommend.node:setVisible(true)
		self.alllist.node:setVisible(false)
		self:OnFlushRecommond(self.server_info)
	else
		self.recommend.node:setVisible(false)
		self.alllist.node:setVisible(true)
		self:OnFlushAll(self:GetSecSeverListData(index))
	end
end

--点击确认按钮
function LoginView:OnLoginConfirm()
	if self.cur_server_data == nil then return end

	local user_vo = GameVoManager.Instance:GetUserVo()
	if not user_vo.plat_is_verify then
		return
	end

	local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time)
	if PLAT_ACCOUNT_TYPE_COMMON == user_vo.plat_account_type and 
		nil ~= self.cur_server_data.open_time and nil ~= self.cur_server_data.ahead_time and
		 now_server_time < self.cur_server_data.open_time - self.cur_server_data.ahead_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.ServerOpenTips2, true)
		return
	end

	if PLAT_ACCOUNT_TYPE_COMMON == user_vo.plat_account_type and 
		nil ~= self.cur_server_data.pause_time and 0 < self.cur_server_data.pause_time and
		now_server_time < self.cur_server_data.pause_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.ServerOpenTips3, true)
		return
	end

	------------写死ip
	-- self.cur_server_data.ip = "127.0.0.1"
	-- self.cur_server_data.port = 13019
	-- self.cur_server_data.id = 1
	-------------------
	
	local text_ip = self.cur_server_data.ip
	local text_port = self.cur_server_data.port

	user_vo.plat_server_id = self.cur_server_data.id
	user_vo.merge_id = self.cur_server_data.merge_id or user_vo.plat_server_id
	user_vo.real_server_id = user_vo.plat_server_id
	user_vo.plat_server_name = self.cur_server_data.name

	self:SetUserVoByServerData(self.cur_server_data)

	AdapterToLua:getInstance():setDataCache("PRVE_SRVER_ID", self.cur_server_data.id)
	AdapterToLua:getInstance():setDataCache("MERGE_ID", self.cur_server_data.merge_id or self.cur_server_data.id)

	MainProber:Step(MainProber.STEP_CLICK_CONFIRM_LOGIN or 230, user_vo.plat_name, self.cur_server_data.id, text_ip, text_port)

	Log("Login::OnLoginConfirm ip:" .. tostring(text_ip) .. " , port:" .. tostring(text_port) 
		.. ", name:" .. tostring(user_vo.plat_name) .. ", server_id:" ..tostring(self.cur_server_data.id))
	self:DoLogin(text_ip, text_port)
end

function LoginView:DoLogin(text_ip, text_port)
	if nil == text_ip or string.len(text_ip) <= 0 then
		return
	end

	if nil == text_port or string.len(text_port) <= 0 then
		return
	end

	local game_net = GameNet.Instance
	if game_net:IsGameServerConnected() or game_net:IsGameServerInAsyncConnect() then
		return
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	MainProber:Step(MainProber.STEP_SERVER_LOGIN_BEG, user_vo.plat_name, user_vo.plat_server_id, text_ip, text_port)
	if MainProber.Step2 then
		MainProber.server_id = user_vo.plat_server_id
		MainProber:Step2(800, MainProber.user_id, MainProber.server_id) 
	end

	LoginController.Instance:ShowWaitingEffect()
	LoginController.Instance:ResetConnectCount()
	game_net:SetGameServerInfo(text_ip, text_port)
	game_net:AsyncConnectGameServer(3)
end

function LoginView:SetUserVoByServerData(server_data)
	if nil == server_data then
		return
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	if PLAT_ACCOUNT_TYPE_TEST == user_vo.plat_account_type then
		user_vo.open_time = 0
	else
		user_vo.open_time = server_data.open_time or 0
	end
end

--点击返回按钮
function LoginView:OnLoginBack()
	local login_state = LoginController.Instance:GetLoginState()
	if login_state == LOGIN_STATE_CREATE_ROLE or login_state == LOGIN_STATE_LOADING then
		return
	end

	LoginController.Instance:RemoveWaitingEffect()
	self:SetLoginVisible(false, false)

	GameNet.Instance:DisconnectGameServer()

	if AgentAdapter.OnClickBackLogin then
		AgentAdapter:OnClickBackLogin()
	end
end

function LoginView:SetLoginVisible(is_show, is_only)
	is_only = is_only == nil and true or false
	if is_show then
		LoginController.Instance:AgentLoginViewClose(is_only)
	else
		LoginController.Instance:AgentLoginViewOpen(is_only)
	end

	self:SetChooseServerVisible(is_show)
	self.node_tree.layout_loading.node:setVisible(false)
end

function LoginView:GetIsInSelectServerView()
	if nil == self.node_tree.layout_bg.layout_select_sever_list.node then
		return false
	end
	return self.node_tree.layout_bg.layout_select_sever_list.node:isVisible()
end

function LoginView:CreateAnimDisplay(parent, stage, scale, prof)
	if nil == parent or nil == stage or nil == scale then
		return
	end

	local display = RoleDisplay.New(parent, 999, false, true, true)
	local x, y = stage:getPosition()
	display:SetPosition(x, y + 30)
	display:SetScale(scale)
	display:SetRoleResId(prof)

	return display
end

-- 获取帐号所有拥有角色的服务器id并刷新列表提醒
function LoginView:SentAllServerRoleUrlReq()
	local url = "http://l.cqtest.jianguogame.com:88/api/check_server.php?spid=%s&user_id=%s&time=%d&sign=%s"
	local spid = AgentAdapter:GetSpid()
	local user_id = AgentAdapter:GetPlatName()
	local now_time = os.time()
	local sign = UtilEx:md5Data(spid .. user_id .. now_time .. "hdISla9sjXphPqEoE8lZcg==") 
	url = string.format(url, spid, user_id, now_time, sign)

	local verify_callback = function(url, arg, data, size)
		local ret_t = cjson.decode(data)
		Log("LoginView:SentAllServerRoleUrlReq ret_data" .. data)
		if ret_t and 0 == ret_t.ret then
			for k, v in pairs(ret_t.data) do
				ALL_SERVER_HAVE_ROLES_T[tonumber(v.src_server_id)] = 1
			end

			if self.select_server_list then
				for k, v in pairs(self.select_server_list:GetAllItems()) do
					v:Flush()
				end
				self.select_server_list:SelectIndex(self.select_server_list:GetSelectIndex())
			end
		end
	end
	HttpClient:Request(url, "", verify_callback)
end
