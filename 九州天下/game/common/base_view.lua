require("game/common/ui_scene")

local develop_mode = require("editor/develop_mode")
BaseView = BaseView or BaseClass()

CloseMode = {
	CloseVisible = 1,			-- 隐藏
	CloseDestroy = 2,			-- 延时销毁
}

UiLayer = {
	SceneName = 0,				-- 场景名字
	FloatText = 1,				-- 飘字
	MainUILow = 2,				-- 主界面(低)
	MainUI = 3,					-- 主界面
	MainUIHigh = 4,				-- 主界面(高)
	Normal = 5,					-- 普通界面
	Pop = 6,					-- 弹出框
	PopTop = 7,					-- 弹出框(高)
	Guide = 8,					-- 引导层
	SceneLoading = 9,			-- 场景加载层
	SceneLoadingPop = 10,		-- 场景加载层上的弹出层
	Disconnect = 11,			-- 断线面板弹出层
	Standby = 12,				-- 待机遮罩
	MaxLayer = 13
}

ViewCacheTime = {
	LEAST = 5,
	NORMAL = 60,
	MOST = 3000,
}

GmAdapter = false

local UIRoot = GameObject.Find("GameRoot/UILayer").transform

function BaseView:__init(view_name)
	self.close_mode = CloseMode.CloseDestroy				-- 默认关闭后会销毁
	self.view_layer = UiLayer.Normal

	self.ui_config = nil									-- {bundle_name, prefab_name}
	self.ui_scene = nil										-- 是否有UI伴随场景
	self.config_tab = {}									-- 配置 {{prefab, {index, index ...}, visible}, ...}
	self.full_screen = false								-- 是否是全屏界面
	self.vew_cache_time = ViewCacheTime.LEAST				-- 界面缓存时间
	self.is_async_load = true								-- 是否异步加载
	self.is_check_reduce_mem = false						-- 是否检查减少内存
	self.is_safe_area_adapter = false						-- IphoneX适配
	self.safe_area_adapter_check_time = 2

	self.active_close = true								-- 是否可以主动关闭(用于关闭所有界面操作)
	self.fight_info_view = false

	self.root_node = nil									-- UI根节点
	self.name_table = nil									-- 名字绑定
	self.event_table = nil
	self.variable_table = nil
	self.animator = nil

	self.is_loading = false									-- 是否加载中
	self.is_open = false									-- 是否已打开
	self.is_rendering = false								-- 是否渲染
	self.is_real_open = false								-- 是否已打开

	self.flush_param_t = nil								-- 界面刷新参数

	self.def_index = 0										-- 默认显示的标签
	self.last_index = nil									-- 上次显示的标签
	self.show_index = -1									-- 当前显示的标签

	-- 在init初始化的时候使用self:SetMaskBg()调用
	self.is_use_mask = false								-- 是否使用蒙板(就是那块透明的黑背景)
	self.is_maskbg_click = true								-- 蒙板是否可点击(能点击的情况下无法穿透点击场景)
	self.is_maskbg_button_click = false						-- 是否可点击蒙板关闭面板
	self.async_load_panel_list = {}							-- 用于记录是否已异步加载界面

	self.audio_config = AudioData.Instance:GetAudioConfig()
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultOpen)				-- 打开面板音效
		self.close_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultClose)				-- 关闭面板音效
	end
	self.play_audio = false									-- 播放音效

	-- self.is_first_open = false
	if nil ~= view_name and "" ~= view_name then
		self.view_name = view_name							-- 界面名字 在view_def.lua中定义
		ViewManager.Instance:RegisterView(self, view_name)
		--获取是否第一次打开界面
		-- local key = "Base" .. self.view_name
		-- local is_first_open = UnityEngine.PlayerPrefs.GetInt(key)
		-- if is_first_open ~= 1 then
		-- 	self.is_first_open = true
		-- end
	end
end

function BaseView:__delete()
	self:Release()
end

function BaseView:Release()
	self.is_loading = false
	if nil == self.root_node then
		return
	end

	self:CancelReleaseTimer()

	self:ReleaseCallBack()

	self.async_load_panel_list = {}

	if not IsNil(self.event_table) then
		self.event_table:ClearAllEvents()
		self.event_table = nil
	end
	
	GameObject.Destroy(self.root_node)
	self.root_node = nil
	self.name_table = nil
	
	self.variable_table = nil
	self.animator = nil

	self.last_index = nil
	self.show_index = -1

	self.is_open = false
	self.is_rendering = false
	self.is_real_open = false
	self.show_index = nil
	self.flush_param_t = nil
	self:CancelDelayFlushTimer()
	self:RemoveSafeAdapterUpdate()

	if self.mask_bg then
		if self.mask_bg.gameObject then
			GameObject.Destroy(self.mask_bg.gameObject)
		end
		self.mask_bg = nil
	end

	if develop_mode:IsDeveloper() then
		develop_mode:OnReleaseView(self)
	end
end

function BaseView:CancelReleaseTimer()
	if nil ~= self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

-- 查找组件
-- name_path 对象名，支持name/name/name的形式
function BaseView:FindObj(name_path, component_type)
	if self.name_table ~= nil then
		local game_obj = self.name_table:Find(name_path)
		if game_obj ~= nil then
			node = U3DObject(game_obj)
			return node
		end
	end

	local transform = self.root_node.transform:FindHard(name_path)
	if transform ~= nil then
		node = U3DObject(transform.gameObject, transform)
		return node
	end

	print_error("BaseView: can not find: " .. name_path)
	return nil
end

-- 监听指定的时间.
-- eventName: 事件名.
-- listener: 监听回调.
function BaseView:ListenEvent(eventName, listener)
	if self.event_table == nil then
		return
	end

	return self.event_table:ListenEvent(eventName, listener)
end

function BaseView:ClearEvent(eventName)
	if self.event_table == nil then
		return
	end

	return self.event_table:ClearEvent(eventName)
end

-- 查找指定的绑定变量.
-- name: 绑定变量的名字.
function BaseView:FindVariable(name)
	if self.variable_table == nil then
		return
	end

	return self.variable_table:FindVariable(name)
end

function BaseView:Load(index)
	if nil == self.ui_config or self:IsLoaded() or self.is_loading then
		return
	end

	self.is_loading = true
	-- print_log("==== load begin", self.view_name or "", os.clock())
	-- UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.High
	--local request_id = LoadingPriorityManager.Instance:RequestPriority(
	--	LoadingPriority.High)

	UtilU3d.PrefabLoad(self.ui_config[1] .. "_prefab", self.ui_config[2], function(obj)
		-- LoadingPriorityManager.Instance:CancelRequest(request_id)
		self:PrefabLoadCallback(index, obj)
		end, true)
end

function BaseView:PrefabLoadCallback(index, obj)
	if nil == obj or not self.is_loading then
		self.is_loading = false
		return
	end

	obj.name = string.gsub(obj.name, "%(Clone%)", "")

	self.is_loading = false

	self.root_node = obj
	self.name_table = self.root_node:GetComponent(typeof(UINameTable))
	self.event_table = self.root_node:GetComponent(typeof(UIEventTable))
	self.variable_table = self.root_node:GetComponent(typeof(UIVariableTable))
	self.animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))

	local transform = self.root_node.transform
	transform:SetParent(UIRoot, false)

	self:LoadCallBack(0, 1)
	self:UpdateSortOrder()

	if self:IsOpen() then
		if self.animator ~= nil then
			self.animator:SetBool("show", true)
		end
		self:ShowIndex(index)
		if self.open_audio_id and self.play_audio then
			AudioManager.PlayAndForget(self.open_audio_id)
		end
		self:OpenCallBack()
		self:FlushHelper()

		if self.is_use_mask then
			self:CreateMaskBg()
		end

	else
		self:SetActive(false, true)
	end
end

-- 必须在init初始化的时候使用。参数分别是：是否点击蒙板关闭面板，是否蒙板可点击
function BaseView:SetMaskBg(is_maskbg_button_click, is_maskbg_click)
	-- self.is_use_mask = is_use_mask or false
	self.is_use_mask = true
	self.is_maskbg_button_click = is_maskbg_button_click or false
	self.is_maskbg_click = is_maskbg_click or true
end

function BaseView:CreateMaskBg()
	if nil ~= self.mask_bg then
		GameObject.Destroy(self.mask_bg)
	end

	self.mask_bg = U3DObject(GameObject.New("MaskBg"))
	local mask_bg_transform = self.mask_bg.transform
	mask_bg_transform:SetParent(self.root_node.transform, false)
	mask_bg_transform:SetSiblingIndex(0)

	local image = self.mask_bg.gameObject:AddComponent(typeof(UnityEngine.UI.Image))
	local bundle, asset = ResPath.GetImages("white")
	image:LoadSprite(bundle, asset)  
	image.color = Color.New(0, 0, 0, 0.74)
	image.raycastTarget = self.is_maskbg_click

	if self.is_maskbg_click and self.is_maskbg_button_click then
		local button = self.mask_bg.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
		button.transition = UnityEngine.UI.Selectable.Transition.None
		button:AddClickListener(function ()
			self:Close()
		end)
	end

	local rect = self.mask_bg.rect
	rect.anchorMin = Vector2(0, 0)
	rect.anchorMax = Vector2(1, 1)
	rect.anchoredPosition3D = Vector3(0, 0, 0)
	rect.sizeDelta = Vector2(0, 0)
end

function BaseView:Open(index)
	self.is_real_open = true
	index = index or self.def_index
	self:CancelReleaseTimer()

	if self.is_check_reduce_mem and IsLowMemSystem then
		Scene.Instance:ReduceMemory()
	end

	if not self.is_open then
		self:SetActive(true)
		--记录是否第一次打开界面
		-- if self.view_name and self.view_name ~= "" then
		-- 	self.is_first_open = false
		-- 	local key = "Base" .. self.view_name
		-- 	local is_first_open = UnityEngine.PlayerPrefs.GetInt(key)
		-- 	if is_first_open ~= 1 then
		-- 		self.is_first_open = true
		-- 		UnityEngine.PlayerPrefs.SetInt(key, 1)
		-- 	end
		-- end

		if not self:IsLoaded() then
			self:Load(index)
		else
			if nil ~= self.root_node then
				if self.animator ~= nil then
					self.animator:SetBool("show", true)
				end
				self:UpdateSortOrder()
				self:ShowIndex(index)
				if self.open_audio_id and self.play_audio then
					AudioManager.PlayAndForget(self.open_audio_id)
				end
				self:OpenCallBack()
				self:FlushHelper()
			end
		end
	else
		self:ShowIndex(index)
	end
end

function BaseView:UpdateSortOrder()
	if nil ~= self.root_node then
		-- 重置坐标位置
		local transform = self.root_node.transform
		transform:SetLocalScale(1, 1, 1)
		local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchorMax = Vector2(1, 1)
		rect.anchorMin = Vector2(0, 0)
		rect.anchoredPosition3D = Vector3(0, 0, 0)
		rect.sizeDelta = Vector2(0, 0)

		if self.is_safe_area_adapter then
			self:SetSafeAdapter()
		end
		-- 更新深度值
		ViewManager.Instance:AddOpenView(self)
	end
end

function BaseView:RemoveSafeAdapterUpdate()
	if self.safe_adapter_update then
		GlobalTimerQuest:CancelQuest(self.safe_adapter_update)
		self.safe_adapter_update = nil
	end
end

function BaseView:SetSafeAdapter()
	if (UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
			and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX ) or GmAdapter then

		local rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
		self:RemoveSafeAdapterUpdate()
		local end_time = Status.NowTime + self.safe_area_adapter_check_time
		self.safe_adapter_update = GlobalTimerQuest:AddRunQuest(function ()
			if nil == rect or IsNil(rect.gameObject) then
				self:RemoveSafeAdapterUpdate()
				return
			end
			if rect.offsetMin.x ~= 66 or rect.offsetMax.x ~= -66 then
				rect.offsetMin = Vector2(66, 0)
				rect.offsetMax = Vector2(-66, 0)
			end
			if Status.NowTime > end_time then
				self:RemoveSafeAdapterUpdate()
			end
		end, 0.1)
	end
end

function BaseView:Close(...)
	self.is_real_open = false
	if not self.is_open then
		self:CloseDestroy()
		return
	end

	-- if self.close_audio_id and self.play_audio then
	-- 	AudioManager.PlayAndForget(self.close_audio_id)
	-- end
	self:CloseCallBack(...)

	if self.animator ~= nil and self.animator.isActiveAndEnabled and self.is_rendering and self.animator:GetBool("show") then
		self.is_rendering = false
		self.animator:SetBool("show", false)
		self.animator:WaitEvent("exit", function(param)
			if self.is_real_open then
				self.is_open = false
				self:Open()
			else
				if self.close_mode == CloseMode.CloseVisible then
					self:CloseVisible()
				elseif self.close_mode == CloseMode.CloseDestroy then
					self:CloseDestroy()
				end
			end
		end)
	else
		if self.close_mode == CloseMode.CloseVisible then
			self:CloseVisible()
		elseif self.close_mode == CloseMode.CloseDestroy then
			self:CloseDestroy()
		end
	end
end

function BaseView:CloseVisible()
	self.is_real_open = false
	self.show_index = -1
	if self:IsOpen() then
		ViewManager.Instance:RemoveOpenView(self)
	end
	self:SetActive(false)
	self:CancelDelayFlushTimer()
end

function BaseView:CloseDestroy()
	self:CloseVisible()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			self:Release()
		end, self.vew_cache_time)
	end
end

function BaseView:ChangeToIndex(index)
	if not self:IsOpen() then
		return
	end
	self:ShowIndex(index)
	self:FlushHelper()
end

function BaseView:ShowIndex(index)
	if not self:IsLoaded() then
		return
	end
	if self.show_index == index then
		return
	end
	if nil == index then
		print_log("BaseView:ShowIndex index == nil")
		return
	end
	self.show_index = index
	self.last_index = index

	self:ShowIndexCallBack(index)
end

function BaseView:SetActive(active, force)
	if self.is_open ~= active or force then
		self.is_open = active
		self.is_rendering = active
		if nil ~= self.root_node then
			self.root_node:SetActive(active)
		end
		self:SetRootNodeActive(value)
	end
end


function BaseView:SetRendering(value)
	if self.is_rendering ~= value then
		self.is_rendering = value
		if nil ~= self.root_node then
			self.root_node:SetActive(value)
		end
		self:SetRootNodeActive(value)
	end
end

function BaseView:SetRootNodeActive(value)
	if nil ~= self.root_node then
		if value and self.is_safe_area_adapter then
			self:SetSafeAdapter()
		end
	end
end

function BaseView:CanActiveClose()
	return self.active_close
end

function BaseView:GetLayer()
	return self.view_layer
end

function BaseView:IsOpen()
	return self.is_open
end

function BaseView:IsRealOpen()
	return self.is_real_open
end

function BaseView:IsRendering()
	return self.is_rendering
end

function BaseView:IsLoaded()
	return nil ~= self.root_node
end

function BaseView:GetRootNode()
	return self.root_node
end

function BaseView:Flush(key, value_t)
	key = key or "all"
	value_t = value_t or {"all"}

	self.flush_param_t = self.flush_param_t or {}
	for k, v in pairs(value_t) do
		self.flush_param_t[key] = self.flush_param_t[key] or {}
		self.flush_param_t[key][k] = v
	end
	if nil == self.delay_flush_timer and self:IsLoaded() and self:IsOpen() then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushHelper, self), 0)
	end
end

function BaseView:FlushHelper()
	self:CancelDelayFlushTimer()

	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	if nil ~= self.flush_param_t then
		local param_list = self.flush_param_t
		self.flush_param_t = nil
		self:OnFlush(param_list)
	end
end

function BaseView:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function BaseView:GetViewName()
	return self.view_name or ""
end

function BaseView:GetShowIndex()
	return self.show_index
end

function BaseView:AsyncLoadView(index, bundle, asset, callback)
	if nil == index or nil == bundle or nil == asset or self.async_load_panel_list[index] then
		return
	end

	self.async_load_panel_list[index] = true
	UtilU3d.PrefabLoad(bundle, asset, function (obj)
		if not self:IsLoaded() then
			return
		end

		if callback then
			callback(index, obj)
		end
	end)
end

----------------------------------------------------
-- 继承 begin
----------------------------------------------------
-- 创建完调用
function BaseView:LoadCallBack()
	-- override
end

-- 打开后调用
function BaseView:OpenCallBack()
	-- override
end

-- 切换标签调用
function BaseView:ShowIndexCallBack(index)
	-- override
end

-- 关闭前调用
function BaseView:CloseCallBack()
	-- override
end

-- 销毁前调用
function BaseView:ReleaseCallBack()
	-- override
end

-- 刷新
function BaseView:OnFlush(param_list)
	-- override
end
----------------------------------------------------
-- 继承 end
----------------------------------------------------
