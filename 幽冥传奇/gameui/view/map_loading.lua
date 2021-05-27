----------------------------------------------------
-- 地图加载条,仅用于切换场景时
----------------------------------------------------
MapLoading = MapLoading or BaseClass(XuiBaseView)
function MapLoading:__init()
	if MapLoading.Instance then
		ErrorLog("[MapLoading] Attemp to create a singleton twice !")
	end
	MapLoading.Instance = self

	self.zorder = COMMON_CONSTS.ZORDER_CHANGE_SCENE

	self.is_first_loading = true
	self.loading_off_on = false						-- loading界面开关
	self.load_complete_callback = nil

	self.loading_scene_id = 0
	self.res_loaded_size = 0
	self.res_tatol_size = 0

	self.fail_alert = nil
end

function MapLoading:__delete()
	MapLoading.Instance = nil

	if nil ~= self.fail_alert then
		self.fail_alert:DeleteMe()
		self.fail_alert = nil
	end
end

function MapLoading:LoadCallBack()
 	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setPosition(0, 0)
	self.root_node:setAnchorPoint(0,0)
	self.root_node:setContentSize(cc.size(screen_w, screen_h))

	--创建背景
	local bg_path = ResPath.GetLoadingBgPath()
	local bg = XUI.CreateImageView(screen_w / 2, screen_h / 2, bg_path, false)
	bg:setAnchorPoint(0.5, 0.5)
	self.root_node:addChild(bg, 0, 0)

	--创建进度条
	local loading_bar_bg = XUI.CreateImageView(screen_w / 2, 114, ResPath.GetLogin("loading"), false)
	self.root_node:addChild(loading_bar_bg, 0, 0)

	local loading_progress = XUI.CreateLoadingBar(screen_w / 2, 110, ResPath.GetLogin("loading_progress"), false)
	self.root_node:addChild(loading_progress, 998, 998)

	 local progress_size = loading_progress:getContentSize()
	 local loading_up = XUI.CreateImageView(progress_size.width / 2, progress_size.height / 2, ResPath.GetLogin("loading_up"), false)
	 loading_progress:addChild(loading_up)

	self.loading_progress_bar = ProgressBar.New()
	self.loading_progress_bar:SetView(loading_progress)
	self.loading_progress_bar:SetTailEffect(990, 1.5)
	self.loading_progress_bar:SetTotalTime(1.5)
	self.loading_progress_bar:SetEffectOffsetY(-1)
	self.loading_progress_bar:SetCompleteCallback(BindTool.Bind1(self.LoadingBarComplete, self))
	if IS_AUDIT_VERSION then
		loading_bar_bg:setVisible(false)
		loading_progress:setVisible(false)
	end
	
	self.progress_txt = XUI.CreateText(screen_w / 2, 70, screen_w, 30, nil, "", nil, 30)
	XUI.EnableOutline(self.progress_txt)
	self.root_node:addChild(self.progress_txt)
end

function MapLoading:SetLoadCompleteCallBack(load_complete_callback)
	self.load_complete_callback = load_complete_callback
end

function MapLoading:StartLoad(scene_id, old_scene_type)
	if self.loading_scene_id == scene_id then
		return
	end

	if self.is_first_loading then					-- 第一次打开不进行进度加载
		self.is_first_loading = false
		self:ExecuteCallBack(scene_id)
		return
	end

	self.res_tatol_size = self.res_tatol_size + ResManager.Instance:ChangeScene(scene_id, BindTool.Bind1(self.LoadResCallback, self), old_scene_type)

	if not self.loading_off_on and self.res_tatol_size <= 0 then	-- 开关没打开不进行进度加载
		self:ExecuteCallBack(scene_id)
		GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT)
		return
	end

	self:Open()
	if self.loading_scene_id ~= 0 then
		self:ExecuteCallBack(self.loading_scene_id)
		GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT)
	end

	local tip_index = math.random(1, #Language.MapLoading.Tips)
	self.progress_txt:setString(Language.MapLoading.Tips[tip_index])

	self.loading_scene_id = scene_id
	self.loading_progress_bar:SetPercent(0, false)
	if self.res_tatol_size <= 0 then
		self.loading_progress_bar:SetPercent(100)
	else
		self.loading_progress_bar:SetPercent(self.res_loaded_size / self.res_tatol_size * 100, false)
	end
end

function MapLoading:StopLoad()
	local scene_id = self.loading_scene_id
	self.loading_scene_id = 0
	self:ExecuteCallBack(scene_id)
	self.res_loaded_size = 0
	self.res_tatol_size = 0
	self.loading_progress_bar:SetPercent(0, false)
end

function MapLoading:ExecuteCallBack(scene_id)
	if self.load_complete_callback ~= nil then
		self.load_complete_callback(scene_id)
	end
end

function MapLoading:GetIsLoading()
	return self.loading_scene_id > 0
end

-- 下载资源回调
function MapLoading:LoadResCallback(path, size)
	if size <= 0 or self.res_tatol_size <= 0 then
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

	local rate = self.res_loaded_size / self.res_tatol_size
	local percent = (rate - rate % 0.0001) * 100

	self.progress_txt:setString(Language.Common.ResLoading .. percent .. "%")
	self.loading_progress_bar:SetPercent(percent)
end

function MapLoading:LoadingBarComplete()
	if self.res_loaded_size >= self.res_tatol_size then
		self:StopLoad()
		self:Close()
		GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT)
	end
end