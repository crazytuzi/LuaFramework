 LoginView = LoginView or BaseClass(XuiBaseView)

function LoginView:InitLoadingView()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	local layout_loading = self.node_tree.layout_loading.node
	layout_loading:setContentSize(cc.size(screen_w, screen_h))
	layout_loading:setPosition(screen_w / 2, screen_h / 2)
	--创建背景
	local bg_path = ResPath.GetLoadingBgPath()
	local bg = XUI.CreateImageView(screen_w / 2, screen_h / 2, bg_path, false)

	layout_loading:addChild(bg, 0, 0)

	--创建进度条
	local loading_bg = XUI.CreateImageView(screen_w / 2, 114, ResPath.GetLogin("loading"), false)
	layout_loading:addChild(loading_bg, 997, 997)

	self.prog_loading = XUI.CreateLoadingBar(screen_w / 2, 110, ResPath.GetLogin("loading_progress"), false)
	layout_loading:addChild(self.prog_loading, 998, 998)

	-- local progress_size = self.prog_loading:getContentSize()
	-- local loading_up = XUI.CreateImageView(progress_size.width / 2, progress_size.height / 2, ResPath.GetLogin("loading_up"), false)
	-- self.prog_loading:addChild(loading_up)

	self.loading_progress_bar = ProgressBar.New()
	self.loading_progress_bar:SetView(self.prog_loading)
	self.loading_progress_bar:SetTailEffect(990, 1.5)
	self.loading_progress_bar:SetTotalTime(1)
	self.loading_progress_bar:SetEffectOffsetY(-1)
	self.loading_progress_bar:SetCompleteCallback(BindTool.Bind1(self.LoadingBarComplete, self))
	if IS_AUDIT_VERSION then
		loading_bg:setVisible(false)
		self.prog_loading:setVisible(false)
	end

	self.perload_percent = 0
	self.res_loaded_size = 0
	self.res_tatol_size = 0
	self.res_weight = 0

	self.is_loading_finish = false
	self.is_loading_bar_complete = false
	self.is_enter_scene_succ = false
	self.is_done_on_all_ready = false

	self.fail_alert = nil

	self.progress_txt = XUI.CreateText(screen_w / 2, 70, screen_w, 30, nil, "", nil, 30)
	XUI.EnableOutline(self.progress_txt)
	layout_loading:addChild(self.progress_txt, 1000)

	--隐藏加载界面
	layout_loading:setVisible(false)

	-- 进入场景事件
	self.enter_scene_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.OnEnterSceneSucc, self))

	PerloadCtrl.Instance:Start()
end

function LoginView:LoadingReleaseCallBack()
	if nil ~= self.loading_progress_bar then
		self.loading_progress_bar:DeleteMe()
		self.loading_progress_bar = nil
	end

	if nil ~= self.enter_scene_handle then
		GlobalEventSystem:UnBind(self.enter_scene_handle)
		self.enter_scene_handle = nil
	end

	if nil ~= self.fail_alert then
		self.fail_alert:DeleteMe()
		self.fail_alert = nil
	end
end

function LoginView:OpenLoading()
	if nil == self.node_tree.layout_loading then return end
	self.is_done_on_all_ready = false
	self.is_loading_finish = false

	LoginController.Instance:AgentLoginViewClose(true)
	self:SetChooseServerVisible(false)

	self.node_tree.layout_loading.node:setVisible(true)
	
	local tip_index = math.floor(math.random(1, #Language.MapLoading.Tips + 1))
	self.progress_txt:setString(Language.MapLoading.Tips[tip_index])

	local scene_id = GameVoManager.Instance:GetUserVo().scene_id
	self.res_tatol_size = ResManager.Instance:ChangeScene(scene_id, BindTool.Bind1(self.LoadResCallback, self))

	self.res_weight = 0
	if self.res_tatol_size > 0 then
		self.res_weight = self.res_tatol_size / (1024 * 512) * 0.1
		if self.res_weight > 0.8 then self.res_weight = 0.8 end
		if self.res_weight < 0.1 then self.res_weight = 0.1 end
	end

	if PerloadCtrl.Instance:GetPercent() >= 100 then
		self.perload_percent = 100
	else
		PerloadCtrl.Instance:SetCallbackFunc(BindTool.Bind1(self.PerloadCallback, self))
	end

	self:UpdateLoading(self:CalcPercent())
end

function LoginView:LoadingBarComplete()
	if self.is_loading_finish then
		self:CompleteLoading()
	end
end

-- 下载资源回调
function LoginView:LoadResCallback(path, size)
	if size <= 0 then
		ResManager.Instance:CancelAll()

		if nil ~= self.fail_alert then
			return
		end

		local function ok_callback()
			ReStart()
		end
		local function cancel_callback()
			AdapterToLua:endGame()
		end

		self.fail_alert = Alert.New(Language.Common.ResLoadingFail, ok_callback, cancel_callback)
		self.fail_alert.zorder = COMMON_CONSTS.ZORDER_MAX
		self.fail_alert:SetModal(true)
		self.fail_alert:SetIsAnyClickClose(false)
		self.fail_alert:Open()
		self.fail_alert:NoCloseButton()
		self.fail_alert:SetOkString(Language.Login.ReLogin)
		self.fail_alert:SetCancelString(Language.Login.EndGame)
		return
	end

	self.res_loaded_size = self.res_loaded_size + size

	local tip = string.format("%s%dk/%dk", Language.Common.ResLoading, 
		math.floor(self.res_loaded_size / 1024), math.floor(self.res_tatol_size / 1024))
	
	local rate = self.res_loaded_size / self.res_tatol_size
	local percent = (rate - rate % 0.0001) * 100

	self.progress_txt:setString(Language.Common.ResLoading .. percent .. "%")

	self:UpdateLoading(self:CalcPercent())
end

-- 预加载回调
function LoginView:PerloadCallback(percent)
	self.perload_percent = percent
	self:UpdateLoading(self:CalcPercent())
end

-- 计算百分比
function LoginView:CalcPercent()
	if self.res_tatol_size <= 0 then
		return self.perload_percent
	end

	if self.res_loaded_size >= self.res_tatol_size and self.perload_percent >= 100 then
		return 100
	end

	return self.perload_percent * (1 - self.res_weight) + self.res_loaded_size / self.res_tatol_size * 100 * self.res_weight
end

-- 更新进度条
function LoginView:UpdateLoading(percent)
	if percent >= 100 then
		self.is_loading_finish = true
	end
	self.loading_progress_bar:SetPercent(percent)
end

-- 进度条跑完
function LoginView:CompleteLoading()
	GlobalEventSystem:Fire(LoginEventType.LOADING_COMPLETED)
	self.is_loading_bar_complete = true
	self:CloseOnAllReady()
end

function LoginView:GetIsLoadingFinish()
	return self.is_loading_finish
end

-- 进入场景成功
function LoginView:OnEnterSceneSucc()
	self.is_enter_scene_succ = true
	self:CloseOnAllReady()
end

--所有准备好后，才关闭加载界面，关闭后将看到地图，主界面
function LoginView:CloseOnAllReady()
	if self.is_loading_bar_complete and self.is_enter_scene_succ and not self.is_done_on_all_ready then
		self.is_done_on_all_ready = true
		self:Close()
		GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT)
		if AgentAdapter.OnFirstEnterGameScene then
			AgentAdapter:OnFirstEnterGameScene()
		end
		local user_id = AgentAdapter:GetPlatName() or ""
		if string.len(user_id) > 4 then
			MainProber.user_id = string.sub(user_id, 5, -1)
		else
			MainProber.user_id = user_id
		end
		MainProber.role_name = mime.b64(RoleData.Instance:GetAttr("name"))
		MainProber.role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		MainProber.role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
		MainProber:Step2(2000, MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id, MainProber.role_level)

		if RoleCtrl.ROLE_CREATED then
			-- 创建角色后抛出剧情开场事件
			GlobalEventSystem:Fire(LoginEventType.START_OPENING_ANIMATION)
		end
	end
end
