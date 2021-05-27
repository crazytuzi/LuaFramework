
BaseView = BaseView or BaseClass()

function BaseView:__init(view_def)
	GameObject.Extend(self)
	self:AddComponent(EventProtocol):ExportMethods()					-- 增加事件组件
	self.view_manager = ViewManager.Instance

	self.close_mode = CloseMode.CloseDestroy							-- 关闭方式
	-- self.view_cache_time = ViewCacheTime.LEAST							-- 界面缓存时间
	self.view_cache_time = ViewCacheTime.NORMAL							-- 界面缓存时间
	if AgentAdapter.GetSpid and AgentAdapter:GetSpid() == "dev" then
		self.view_cache_time = ViewCacheTime.DEV
	end
	self.is_async_load = true											-- 是否异步加载

	self.zorder = 10													-- 值越大位于越上层
	self.can_penetrate = false											-- 点击事件是否可穿透
	self.is_modal = false												-- 是否模态
	self.background_opacity = 180										-- 背景透明度
	self.is_any_click_close = false										-- 是否点击其它地方要关闭界面
	self.is_back_rendertexture = false 									-- 是否屏蔽场景纹理渲染

	self.is_loaded_config = false										-- 配置是否已加载
	self.config_tab = {}												-- 配置 {{lua_name, cfg_index, {index, index ...}, visible, zorder}, ...}

	self.texture_is_loaded = false										-- 需要的纹理是否加载好
	self.texture_path_list = {}											-- 图集纹理路径
	self.loading_texture_list = {}										-- 加载中的
	self.loaded_path_list = {}											-- 已加载的plsit
	
	self.root_node = nil												-- UI根节点
	self.real_root_node = nil											-- 真正的根节点
	self.node_tree = {}													-- 节点树，通过name.name...node的方式找到一个节点
	self.node_t_list = {}												-- 节点树列表，通过名字索引，指向self.node_tree中的name
	self.ph_list = {}
	self.root_node_off_pos = {x = 0, y = 0}								-- 根节点偏移坐标

	self.async_task_count = 0											-- 异步任务数
	self.loadstate_list = {}											-- 加载状态
	self.loading_index = nil											-- 正在加载的标签
	self.loaded_times = 0												-- load完成次数
	self.next_load_index = nil											-- 下一个加载的标签
	self.def_index = 0													-- 默认显示的标签
	self.last_index = nil												-- 上次显示的标签
	self.show_index = 0													-- 当前显示的标签

	self.is_popup = false												-- 是否已打开
	self.flush_param_t = {}												-- 界面刷新参数
	self.delay_flush_timer = nil
	self.global_event_map = {}
	self.bool_show_money_panel = true                                    --是否显示金钱面板

	self.special_show_panel = false 									 -- 不是通用面板需调整y坐标

 
	if view_def and type(view_def) == "table" then
		self.view_def = view_def										-- 在view_def.lua中定义
		self.view_manager:RegisterView(self, self.view_def)
	end

	
end

function BaseView:__delete()
	self:ReleaseHelper()
	self.view_manager = nil
end

function BaseView:ReleaseHelper()
	if self.view_def then
		for k, v in pairs(self.view_manager:GetChildGroup(self.view_def)) do
			local view_obj = self.view_manager:GetViewObj(v)
			if view_obj and view_obj:IsLoaded() then
				view_obj:ReleaseHelper()
			end
		end
	end
	self.view_manager:AddReleaseObj(self)
end

-- 关闭中且已加载好的界面才可以销毁
function BaseView:CanRelease()
	return not self:IsOpen() and self:IsLoaded()
end

function BaseView:Release()
	if nil == self.real_root_node then
		return
	end

	NeedDelObjs:clear(self)
	self:ReleaseCallBack()

	self.view_top_title = nil
	self:CancelReleaseTimer()
	XUI.cancelAsyncByKey(self)

	self:CleanRootNode()

	for k, v in pairs(self.loading_texture_list) do
		ResourceMgr:getInstance():abortAsyncLoad(k, v)
	end
	self.loading_texture_list = {}

	for k, v in pairs(self.loaded_path_list) do
		ResourceMgr:getInstance():releasePlist(v, 1, false)
	end
	self.loaded_path_list = {}

	for k, v in pairs(self.config_tab) do
		v.config = nil
		v.node = nil
	end
	self.is_loaded_config = false

	self.async_task_count = 0
	self.texture_is_loaded = false
	self.node_t_list = {}
	self.node_tree = {}
	self.loadstate_list = {}
	self.loading_index = nil
	self.loaded_times = 0
	self.next_load_index = nil
	self.show_index = 0

	self.is_popup = false
	self.flush_param_t = {}

	self:CancelDelayFlushTimer()

	self:UnBindAllGlobalEvent()

	self:DispatchEvent(GameObjEvent.REMOVE_ALL_LISTEN)
	self:RemoveAllEventlist()
end

function BaseView:CancelReleaseTimer()
	if nil ~= self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function BaseView:LoadUiConfig()
	if not self.is_loaded_config then
		self.is_loaded_config = true
		local ui_config = nil
		for k, v in pairs(self.config_tab) do
			if nil == v[1] or nil == v[2] or nil == v[3] or "table" ~= type(v[3]) then
				ErrorLog("LoadUiConfig fail 0: config_tab error")
				return
			end

			ui_config = ConfigManager.Instance:GetUiConfig(v[1])
			if nil == ui_config then
				ErrorLog("LoadUiConfig fail 1:", v[1], v[2])
				return
			end

			v.config = ui_config[v[2]]
			if nil == v.config then
				ErrorLog("LoadUiConfig fail 2:", v[1], v[2])
				return
			end
		end
	end
end

function BaseView:BaseLoad()
	self:LoadUiConfig()
	self:CreateRootNode()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.CommonRoleDataChangeCallback, self))
end

function BaseView:Load(index)
	if nil ~= self.loadstate_list[index] then
		return
	end

	-- 创建UI
	if self.is_async_load then
		self:AsyncLoadPlist(index)
	else
		self:CreateUI(index)
	end
end

-- 清除根节点
function BaseView:CleanRootNode()
	NodeCleaner.Instance:AddNode(self.real_root_node)
	self.real_root_node = nil
	self.root_node = nil
end

function BaseView:FlushRootPos()
	if nil == self.root_node then
		return
	end
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setPosition(screen_w / 2 + self.root_node_off_pos.x, screen_h / 2 + self.root_node_off_pos.y)
end

-- 创建根节点
function BaseView:CreateRootNode()
	if nil == self.real_root_node then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node = XUI.CreateLayout(screen_w / 2 + self.root_node_off_pos.x, screen_h / 2 + self.root_node_off_pos.y, 0, 0)
		self.root_node:setAnchorPoint(0.5, 0.5)
		self:FlushRootPos()
		if not self.can_penetrate then
			self.root_node:setTouchEnabled(true)
		end

		if self.is_modal or self.is_any_click_close then
			self.real_root_node = XUI.CreateLayout(screen_w / 2, screen_h / 2, screen_w, screen_h)
			self.real_root_node:setTouchEnabled(true)
			self.real_root_node:addChild(self.root_node)

			if self.is_modal then
				self.real_root_node:setBackGroundColor(COLOR3B.BLACK)
				self.real_root_node:setBackGroundColorOpacity(self.background_opacity)
			end

			if self.is_any_click_close then
				XUI.AddClickEventListener(self.real_root_node, BindTool.Bind(self.OnCloseHandler, self))
			end
		else
			self.real_root_node = self.root_node
		end
		HandleRenderUnit:AddUi(self.real_root_node, self.zorder, self.zorder)

		local root_width, root_height = 0, 0
		for k, v in pairs(self.config_tab) do
			if v.config.x + v.config.w > root_width then root_width = v.config.x + v.config.w end
			if v.config.y + v.config.h > root_height then root_height = v.config.y + v.config.h end
		end
		self.root_node:setContentWH(root_width, root_height)
	end
end

function BaseView:IsValidIndex(index_list, index)
	for _, v in pairs(index_list) do
		if v == 0 or v == index then
			return true
		end
	end
	return false
end

function BaseView:GetConfigUiZOrder(k)
	return self.config_tab[k][5] or k
end

function BaseView:CreateUI(index)
	-- 加载纹理
	for _, v in pairs(self.texture_path_list) do
		if not ResourceMgr:getInstance():loadPlist(v) then
			ErrorLog("BaseView:CreateUI fail 1:" .. v)
			return
		end
		table.insert(self.loaded_path_list, v)
	end

	for k, v in pairs(self.config_tab) do
		if nil == v.node and self:IsValidIndex(v[3], index) then
			local node_tree = XUI.GeneratorUI(v.config, self.root_node, self:GetConfigUiZOrder(k), self.node_t_list, self.node_tree, self.ph_list)
			v.node = node_tree.node
			if false == v[4] then
				v.node:setVisible(false)
			end
			self.loadstate_list[index] = XuiLoadState.Loaded
		end
	end
	self.loadstate_list[0] = XuiLoadState.Loaded
	
	self:RegisterDefClose()

	self.loaded_times = self.loaded_times + 1
	self:LoadCallBack(index, self.loaded_times)
end

function BaseView:AsyncLoadPlist(index)
	if self:IsLoading() then
		self.next_load_index = index
		return
	end

	self.loading_index = index

	if self.texture_is_loaded then
		self:AsyncCreateUI(index)
		return
	end

	local function load_callback(path, is_succ, texture)
		self.async_task_count = self.async_task_count - 1
		self.loading_texture_list[path] = nil
		if not is_succ then
			ErrorLog("BaseView:AsyncLoadPlist fail:" .. path)
			return
		end
		table.insert(self.loaded_path_list, path)

		if self.async_task_count <= 0 then
			self.texture_is_loaded = true
			self.async_task_count = 0
			self:AsyncCreateUI(index)
		end
	end

	self.async_task_count = 0

	for _, v in pairs(self.texture_path_list) do
		self.async_task_count = self.async_task_count + 1
		self.loading_texture_list[v] = ResourceMgr:getInstance():asyncLoadPlist(v, load_callback)
	end

	if self.async_task_count <= 0 then
		self.texture_is_loaded = true
		self:AsyncCreateUI(index)
	end
end

function BaseView:AsyncCreateUI(index)
	if self.loadstate_list[index] then
		return
	end

	for k, v in pairs(self.config_tab) do
		if nil == v.node and self:IsValidIndex(v[3], index) then
			self.async_task_count = self.async_task_count + 1
			XUI.AsyncGeneratorUI(v.config, self.root_node, self:GetConfigUiZOrder(k), self.node_t_list, self.node_tree, self.ph_list, 
				BindTool.Bind(self.OnAsyncLoadFinish, self, v), self, v[4] ~= false)

			if nil == self.loadstate_list[0] then
				self.loadstate_list[0] = XuiLoadState.Loading
			end
			self.loadstate_list[index] = XuiLoadState.Loading
		end
	end

	if self.async_task_count <= 0 then
		self:asyncLoadComplete()
	end
end

function BaseView:OnAsyncLoadFinish(cfg_info, node_tree)
	cfg_info.node = node_tree.node
	self.async_task_count = self.async_task_count - 1
	if self.async_task_count <= 0 then
		self:asyncLoadComplete()
	end
end

function BaseView:asyncLoadComplete()
	self.loadstate_list[0] = XuiLoadState.Loaded
	self.loadstate_list[self.loading_index] = XuiLoadState.Loaded

	self.async_task_count = 0

	local index = self.loading_index
	self.loading_index = nil

	self:RegisterDefClose()

	self:SetVisible(self.is_popup)
	
	self.loaded_times = self.loaded_times + 1
	if self.loaded_times <= 1 and self.config_tab[1] and self.config_tab[1][1] == "common_ui_cfg" then
		self:SetAddLister()
		self:CreateTopTitle()
		self:FlushMoneyShow()
	end
	self:LoadCallBack(index, self.loaded_times)

	if self.show_index == index then
		self:ShowIndexCallBack(index)
	end

	if self.next_load_index then
		local next_index = self.next_load_index
		self.next_load_index = nil
		self:ShowIndex(next_index, true)
	end
end

-- 默认关闭按钮
function BaseView:RegisterDefClose()
	if nil ~= self.node_t_list.btn_close_window and not self.node_t_list.btn_close_window.is_listener then
		self.node_t_list.btn_close_window.node:addClickEventListener(BindTool.Bind(self.OnCloseHandler, self))
		self.node_t_list.btn_close_window.is_listener = true
	end
end

--通用跳转
function BaseView:SetAddLister( ... )
	if self.node_t_list.layout_common_money then
		self.node_t_list.layout_common_money.node:setVisible(self.bool_show_money_panel)
		if self.special_show_panel then
			local y = HandleRenderUnit:GetHeight() - 23
			local x = HandleRenderUnit:GetWidth()/2
			self.node_t_list.layout_common_money.node:setPositionY(y)
		end
		if self.node_t_list.layout_common_money.btn_open_charge then
			self.node_t_list.layout_common_money.btn_open_charge.node:setScale(0.8)
			self.node_t_list.layout_common_money.btn_open_charge.node:addClickEventListener(function ()
				ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			end)
		end
		if self.node_t_list.layout_common_money.btn_open_recycle then
			self.node_t_list.layout_common_money.btn_open_recycle.node:setScale(0.8)
			self.node_t_list.layout_common_money.btn_open_recycle.node:addClickEventListener(function ()
				--ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
				TipCtrl.Instance:OpenGetNewStuffTip(266)
			end)
		end
		if self.node_t_list.layout_common_money.btn_open_recycle1 then
			self.node_t_list.layout_common_money.btn_open_recycle1.node:setScale(0.8)
			self.node_t_list.layout_common_money.btn_open_recycle1.node:addClickEventListener(function ()
				--ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
				TipCtrl.Instance:OpenGetStuffTip(2096)
			end)
		end
	end
end

function BaseView:FlushMoneyShow()
	if self.node_t_list.layout_common_money then
		local gold_num =  GameMath.GetStringShowMoneynum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
		self.node_t_list.lbl_common_xuan_num.node:setString(gold_num)
		local jifen_num = GameMath.GetStringShowMoneynum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BRAVE_POINT)) 
		self.node_t_list.lbl_common_jifen_num.node:setString(jifen_num)

		--local bind_coin = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
		local coin = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
		local num = coin
		local text  = GameMath.GetStringShowMoneynum(num)
		self.node_t_list.lbl_common_gold_num.node:setString(text)
	end
end

function BaseView:OnCloseHandler()
	self:CloseHelper()
end

function BaseView:Open(index)
	local old_visible = self.is_popup

	self:OpenOnly(index)

	if old_visible ~= true and self.is_back_rendertexture then
		MainuiCtrl.Instance:OpenBaseViewRenderTexture()
	end
end

function BaseView:OpenOnly(index)
	self:CancelReleaseTimer()
	index = index or self.def_index

	self:BaseLoad()

	if not self.is_popup and nil ~= self.real_root_node then
		self:SetVisible(true)
		self:OpenCallBack()
	end

	self:ShowIndex(index)
	self:UpdateLocalZOrder()
end

function BaseView:UpdateLocalZOrder()
	if nil ~= self.real_root_node then
		self.real_root_node:resetLocalZOrder()
	end
end

function BaseView:CloseHelper()
	if self.view_def then
		ViewManager.Instance:CloseViewByDef(self.view_def)
	else
		self:Close()
	end
end

function BaseView:Close(...)
	if not self.is_popup then
		if self.close_mode == CloseMode.CloseDestroy then
			self:CloseDestroy()
		end
		return
	end

	self:CloseCallBack()

	if self.close_mode == CloseMode.CloseVisible then
		self:CloseVisible()
	elseif self.close_mode == CloseMode.CloseDestroy then
		self:CloseDestroy()
	end
end

function BaseView:CloseVisible()
	-- self.show_index = -1
	local old_visible = self.is_popup

	self:SetVisible(false)

	if old_visible ~= false and self.is_back_rendertexture then
		MainuiCtrl.Instance:CloseBaseViewRenderTexture()
	end
end

function BaseView:CloseDestroy()
	self:CloseVisible()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			self:ReleaseHelper()
		end, self.view_cache_time)
	end
end

function BaseView:ChangeToIndex(index)
	if not self:IsOpen() then
		return
	end

	self:ShowIndex(index)
end

function BaseView:ShowIndex(index, is_force)
	-- if self.show_index == index and not is_force then
	-- 	return
	-- end

	if nil == index then
		DebugLog("BaseView:ShowIndex index == nil")
		return
	end
	self:Load(index)
	self.show_index = index
	self.last_index = index

	for k, v in pairs(self.config_tab) do
		if nil ~= v.node then
			v.node:setVisible((false ~= v[4]) and self:IsValidIndex(v[3], index))
		end
	end
	
	if self:IsLoadedIndex(index) then
		self:ShowIndexCallBack(index)
	end
end

function BaseView:SetVisible(visible)
	if self.is_popup ~= visible and nil ~= self.real_root_node then
		self.is_popup = visible
		self.real_root_node:setVisible(visible)
	end
end

-- index可以是数字也可以是数字table，key一般是字符串，value必须是一个table
function BaseView:Flush(index, key, value)
	index = index or 0
	key = key or "all"
	value = value or {"all"}

	if type(index) == "table" then
		for k, v in pairs(index) do
			self.flush_param_t[v] = self.flush_param_t[v] or {}
			for k1, v1 in pairs(value) do
				self.flush_param_t[v][key] = self.flush_param_t[v][key] or {}
				self.flush_param_t[v][key][k1] = v1
			end
		end
	else
		self.flush_param_t[index] = self.flush_param_t[index] or {}
		for k1, v1 in pairs(value) do
			self.flush_param_t[index][key] = self.flush_param_t[index][key] or {}
			self.flush_param_t[index][key][k1] = v1
		end
	end

	if nil == self.delay_flush_timer and self:IsOpen() then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnDelayFlush, self, self.show_index), 0)
	end
end

function BaseView:OnDelayFlush(index)
	self.delay_flush_timer = nil

	if not self:IsOpen() then
		return
	end

	if not self:IsLoadedIndex(index) then
		return
	end

	self:FlushIndex(0)
	self:FlushIndex(index)

end

function BaseView:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function BaseView:FlushIndex(index)
	if nil ~= self.flush_param_t[index] and self:IsLoadedIndex(index) then
		local param_list = self.flush_param_t[index]
		self.flush_param_t[index] = nil
		self:OnFlush(param_list, index)
	end
end

function BaseView:IsModal()
	return self.is_modal
end

-- 必须在Load之前设置
function BaseView:SetModal(value)
	self.is_modal = value
end

function BaseView:ChangeModal(is_modal)
	if nil == self.real_root_node then return end
	if is_modal then
		self.real_root_node:setBackGroundColor(COLOR3B.BLACK)
		self.real_root_node:setBackGroundColorOpacity(self.background_opacity)
	else
		self.real_root_node:setBackGroundColorOpacity(0)
	end
end

-- 必须在Load之前设置
function BaseView:SetIsAnyClickClose(is_any_click_close)
	self.is_any_click_close = is_any_click_close
end

-- 必须在Load之前设置
function BaseView:SetBgOpacity(opacity)
	self.background_opacity = opacity
end

-- 必须在Load之前设置
function BaseView:SetRootNodeOffPos(pos, need_flush)
	self.root_node_off_pos = pos
	if need_flush then
		self:FlushRootPos()
	end
end

-- 必须在Load之前设置
function BaseView:SetBackRenderTexture(bool)
	self.is_back_rendertexture = bool
end

function BaseView:GetViewDef()
	return self.view_def
end

function BaseView:GetViewName()
	return ""
end

function BaseView:GetShowIndex()
	return self.show_index
end

function BaseView:IsLoading()
	return nil ~= self.loading_index
end

function BaseView:IsLoadedIndex(index)
	return nil ~= self.loadstate_list[index] and XuiLoadState.Loaded == self.loadstate_list[index]
end

function BaseView:IsOpen()
	return self.is_popup and self.real_root_node ~= nil
end

function BaseView:IsLoaded()
	return nil ~= self.root_node and 0 == self.async_task_count
end

function BaseView:GetRootNode()
	return self.root_node
end

function BaseView:GetRealRootNode()
	return self.real_root_node
end

function BaseView:GetLocalZOrder()
	return self.real_root_node:getLocalZOrder()
end

function BaseView:GetViewManager()
	return self.view_manager
end

-- 加入自动清理列表
function BaseView:AddObj(key)
	NeedDelObjs:add(self, key)
end

----------------------------------------------------
-- 继承 begin
----------------------------------------------------
function BaseView:LoadCallBack(index, loaded_times)
	-- override
end

function BaseView:OpenCallBack()
	-- override
end

function BaseView:ShowIndexCallBack(index)
	-- override
end

function BaseView:CloseCallBack(...)
	-- override
end

function BaseView:ReleaseCallBack()
	-- override
end

function BaseView:OnFlush(param_list, index)
	-- override
end

-- 返回 (node, is_next)
function BaseView:OnGetUiNode(node_name)
	if nil ~= self.node_t_list[node_name] then
		return self.node_t_list[node_name].node, true
	end
end
----------------------------------------------------
-- 继承 end
----------------------------------------------------

----------------------------------------------------
-- 通用接口
----------------------------------------------------
-- 生成界面标题图片
function BaseView:CreateTopTitle(path, x, y, parent)
	if nil == self.root_node then
		ErrorLog("CreateTopTitle失败,请在loadcallback后创建")
		return
	end

	path = path or self.title_img_path
	if nil == self.view_top_title and nil ~= path then
		local content_size = self.root_node:getContentSize()
		x = x or content_size.width / 2
		y = y or content_size.height - 122
		parent = parent or self.root_node
		self.view_top_title = XUI.CreateImageView(x, y, path)
		parent:addChild(self.view_top_title, 999)
	elseif nil ~= self.view_top_title and nil ~= path then
		self.view_top_title:loadTexture(path)
	end
end

-- 注册全局事件，Release时会自动反注册事件
function BaseView:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function BaseView:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end

function BaseView:UnBindAllGlobalEvent()
	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}
end


function BaseView:CommonRoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_BIND_COIN or vo.key == OBJ_ATTR.ACTOR_GOLD or 
		vo.key == OBJ_ATTR.ACTOR_COIN or vo.key == OBJ_ATTR.ACTOR_BRAVE_POINT then
		self:FlushMoneyShow()
	end
end


----------------------------------------------------
-- 通用接口
----------------------------------------------------
