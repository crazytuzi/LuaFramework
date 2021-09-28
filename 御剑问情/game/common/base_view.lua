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

if not IsLowMemSystem and not develop_mode:IsDeveloper() then
	ViewCacheTime = {
		LEAST = 5,
		NORMAL = 60,
		MOST = 3000,
	}
else
	ViewCacheTime = {
		LEAST = 5,
		NORMAL = 60,
		MOST = 3000,
	}
end

local UIRoot = GameObject.Find("GameRoot/UILayer").transform
local total_pop_view_count = 0
local pop_view_stack = {}

function BaseView:__init(view_name)
	self.close_mode = CloseMode.CloseDestroy				-- 默认关闭后会销毁
	self.view_layer = UiLayer.Normal

	self.pre_back_ground_bundle = nil
	self.pre_back_ground_asset = nil

	self.ui_config = nil									-- {bundle_name, prefab_name}
	self.ui_scene = nil										-- 是否有UI伴随场景
	self.config_tab = {}									-- 配置 {{prefab, {index, index ...}, visible}, ...}
	self.full_screen = false								-- 是否是全屏界面
	self.vew_cache_time = ViewCacheTime.LEAST				-- 界面缓存时间
	self.is_async_load = true								-- 是否异步加载
	self.is_check_reduce_mem = false						-- 是否检查减少内存
	self.is_safe_area_adapter = false						-- IphoneX适配

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
	self.pop_view_count = 0
	self.black_mask_color_a = 0.75							-- 弹框黑幕a值

	self.async_load_panel_list = {}							-- 用于记录是否已异步加载界面

	self.audio_config = AudioData.Instance:GetAudioConfig()
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultOpen)				-- 打开面板音效
		self.close_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].DefaultClose)				-- 关闭面板音效
	end
	self.play_audio = false									-- 播放音效

	if nil ~= view_name and "" ~= view_name then
		self.view_name = view_name							-- 界面名字 在view_def.lua中定义
		ViewManager.Instance:RegisterView(self, view_name)
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
	self.safe_adapter = nil

	self.last_index = nil
	self.show_index = -1

	self.is_open = false
	self.is_rendering = false
	self.is_real_open = false
	self.flush_param_t = nil
	self:CancelDelayFlushTimer()
	self:RemoveSafeAdapterUpdate()

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
function BaseView:FindObj(name_path, component_type, no_print)
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
	if not no_print then
		print_error("BaseView: can not find: " .. name_path)
	end
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
	local request_id = LoadingPriorityManager.Instance:RequestPriority(
		LoadingPriority.High)

	function load_prefab()
			UtilU3d.PrefabLoad(self.ui_config[1], self.ui_config[2], function(obj)
			LoadingPriorityManager.Instance:CancelRequest(request_id)
			self:PrefabLoadCallback(index, obj)
			end)
	end

	if nil == self.pre_back_ground_bundle or nil == self.pre_back_ground_asset then
		load_prefab()
	else
		TexturePool.Instance:Load(AssetID(self.pre_back_ground_bundle, self.pre_back_ground_asset), function(texture)
			load_prefab()
			TexturePool.Instance:Free(texture)
		end)
	end

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
		self:AddPopView()
		self:OpenCallBack()
		self:FlushHelper()
	else
		self:SetActive(false, true)
	end


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
				self:AddPopView()
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
	if SafeAreaAdpater then
		if not self.safe_adapter then
			self.safe_adapter = SafeAreaAdpater.Bind(self.root_node)
		end
	else
		if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
			and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then

			local rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
			self:RemoveSafeAdapterUpdate()
			local end_time = Status.NowTime + 2
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
end

function BaseView:Close(...)
	self.is_real_open = false
	if not self.is_open then --下面为什么还要再调关闭
		if self.close_mode == CloseMode.CloseVisible then
			self:CloseVisible()
		elseif self.close_mode == CloseMode.CloseDestroy then
			self:CloseDestroy()
		end

		return
	end

	-- if self.close_audio_id and self.play_audio then
	-- 	AudioManager.PlayAndForget(self.close_audio_id)
	-- end
	if self.pop_view_count > 0 then
		self:ReducePopView()
	end
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
	if self.full_screen then
		UtilU3d.ForceReSetCamera()
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
	self.last_index = self.show_index
	self.show_index = index

	self:ShowIndexCallBack(index)
end

function BaseView:SetActive(active, force)
	if self.is_open ~= active or force then
		self.is_open = active
		self.is_rendering = active
		self:SetRootNodeActive(active)
	end

	if IS_AUDIT_VERSION then
		local color = GLOBAL_CONFIG.param_list.ui_skin_color
		if "" ~= color and nil ~= color then
			self:ChangeColorInIosAudit(active)
		end
	end
end

function BaseView:ChangeColorInIosAudit(active)
	if not IosAudit then
		return
	end
	if active then
		self.ios_audit_change_color = GlobalTimerQuest:AddRunQuest(function ()
			if self.root_node then
				IosAudit.ChangeUISkinColor(self.root_node, GLOBAL_CONFIG.param_list.ui_skin_color)
			end
		end, 0)
	else
		if nil ~= self.ios_audit_change_color then
			GlobalTimerQuest:CancelQuest(self.ios_audit_change_color)
			self.ios_audit_change_color = false
		end
	end
end

function BaseView:SetRendering(value)
	if self.is_rendering ~= value then
		self.is_rendering = value
		self:SetRootNodeActive(value)
	end
end

function BaseView:SetRootNodeActive(value)
	if not IsNil(self.root_node) then
		self.root_node:SetActive(value)
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

function BaseView:AddPopView()
	if self.full_screen == false and self.view_layer ~= UiLayer.Standby then
		local bg = self:FindBg()
		if nil ~= bg and nil ~= bg.image then
			total_pop_view_count = total_pop_view_count + 1
			local index = #pop_view_stack + 1
			for i = #pop_view_stack, 1, -1 do
				local view = pop_view_stack[i]
				if view then
					if view.view_layer <= self.view_layer then
						break
					end
				end
				index = i
			end
			self.pop_view_count = index
			table.insert(pop_view_stack, index, self)
			for i = self.pop_view_count + 1, #pop_view_stack do
				local view = pop_view_stack[i]
				if view then
					view.pop_view_count = view.pop_view_count + 1
				end
			end
			BaseView.CheckPopBg()
		end
	end
end

function BaseView:ReducePopView()
	total_pop_view_count = math.max(total_pop_view_count - 1, 0)
	for i = self.pop_view_count + 1, #pop_view_stack do
		local view = pop_view_stack[i]
		if view then
			view.pop_view_count = view.pop_view_count - 1
		end
	end
	table.remove(pop_view_stack, self.pop_view_count)
	self.pop_view_count = 0
	local bg = self:FindBg()
	if nil ~= bg and nil ~= bg.image then
		bg.image.color = Color.New(bg.image.color.r, bg.image.color.b, bg.image.color.g, 0)
	end
	BaseView.CheckPopBg()
end

function BaseView:FindBg()
	if not self:IsLoaded() then
		return nil
	end
	local bg = self:FindObj("BGButton", nil, true)
	if nil == bg then
		bg = self:FindObj("Bg", nil, true)
	end
	if nil == bg then
		bg = self:FindObj("Block", nil, true)
	end
	return bg
end

function BaseView.CheckPopBg()
	for k,v in ipairs(pop_view_stack) do
		local bg = v:FindBg()
		if nil ~= bg and nil ~= bg.image then
			if k == total_pop_view_count then
				local color_a = v.black_mask_color_a or 0.75
				bg.image.color = Color.New(bg.image.color.r, bg.image.color.b, bg.image.color.g, color_a)
			else
				bg.image.color = Color.New(bg.image.color.r, bg.image.color.b, bg.image.color.g, 0)
			end
		end
	end
end

function BaseView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
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