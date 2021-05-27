XuiBaseView = XuiBaseView or BaseClass()

OpenMode = OpenMode or {
	OpenOnly = 1,
	OpenToggle = 2,
}

CloseMode = CloseMode or {
	CloseVisible = 1,
	CloseDestroy = 2,
}

XuiLoadState = {
	Loading = 1,
	Loaded = 2,
}

ViewCacheTime = {
	LEAST = 0.5,
	DEV = 5,
	NORMAL = 60,
	MOST = 3000,
}

FULL_SCREEN_UI_OPEN_FLAG = 0

-------------------------------------------------------------------
--XuiBaseView
-------------------------------------------------------------------
function XuiBaseView:__init(view_name)
	self.open_mode = OpenMode.OpenOnly
	self.close_mode = CloseMode.CloseDestroy
	self.is_async_load = true											-- 是否异步加载

	self.zorder = 10														-- 值越大位于越上层
	self.can_penetrate = false											-- 点击事件是否可穿透
	self.is_modal = false												-- 是否模态
	self.background_opacity = 180										-- 背景透明度
	self.is_any_click_close = false										-- 是否点击其它地方要关闭界面

	self.is_loaded_config = false										-- 配置是否已加载
	self.config_tab = {}												-- 配置 {{lua_name, cfg_index, {index, index ...}, visible}, ...}

	self.texture_is_loaded = false										-- 需要的纹理是否加载好
	self.texture_path_list = {}											-- 图集纹理路径
	self.loading_texture_list = {}										-- 加载中的
	self.loaded_path_list = {}											-- 已加载的plsit
	
	self.root_node = nil												-- UI根节点
	self.real_root_node = nil											-- 真正的根节点
	self.node_tree = {}													-- 节点树，通过name.name...node的方式找到一个节点
	self.node_t_list = {}												-- 节点树列表，通过名字索引，指向self.node_tree中的name
	self.ph_list = {}
	self.root_node_off_pos = {x = 0, y = 0}

	self.async_task_count = 0											-- 异步任务数
	self.loadstate_list = {}											-- 加载状态
	self.loading_index = nil											-- 正在加载的标签
	self.loaded_times = 0												-- load完成次数
	self.next_load_index = nil											-- 下一个加载的标签
	self.def_index = 0													-- 默认显示的标签
	self.last_index = nil												-- 上次显示的标签
	self.show_index = -1												-- 当前显示的标签

	self.is_popup = false												-- 是否已打开
	self.flush_param_t = {}												-- 界面刷新参数
	self.delay_flush_timer = nil
	self.funopen_modal_list = {}
	self.global_event_map = {}

	if nil ~= view_name and "" ~= view_name then
		self.view_name = view_name										-- 界面名字 在view_def.lua中定义
		-- ViewManager.Instance:RegisterView(self, view_name)
	end

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function XuiBaseView:__delete()
	if nil ~= self.view_name then
		ViewManager.Instance:UnRegisterView(self.view_name)
	end

	self:Release()
end

function XuiBaseView:Release()
	if nil == self.real_root_node then
		return
	end

	self.view_top_title = nil
	self.text_title = nil

	self:CancelReleaseTimer()

	XUI.cancelAsyncByKey(self)

	self:ReleaseCallBack()

	if self.common_bar then
		self.common_bar:DeleteMe()
		self.common_bar = nil
	end

	NodeCleaner.Instance:AddNode(self.real_root_node)
	self.real_root_node = nil
	self.root_node = nil
	self.def_close_btn = nil
	self.change_theme_btn = nil

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
	self.show_index = -1

	self.is_popup = false
	self.flush_param_t = {}
	self.funopen_modal_list = {}

	self:CancelDelayFlushTimer()

	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}

	self:DispatchEvent(GameObjEvent.REMOVE_ALL_LISTEN)
	self:RemoveAllEventlist()
end

function XuiBaseView:CancelReleaseTimer()
	if nil ~= self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function XuiBaseView:LoadUiConfig()
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

function XuiBaseView:IsLoading()
	return nil ~= self.loading_index
end

function XuiBaseView:IsLoadedIndex(index)
	return nil ~= self.loadstate_list[index] and XuiLoadState.Loaded == self.loadstate_list[index]
end

function XuiBaseView:Load(index)
	if nil ~= self.loadstate_list[index] then
		return
	end

	self:LoadUiConfig()

	-- 创建根节点
	if nil == self.real_root_node then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node = XUI.CreateLayout(screen_w / 2 + self.root_node_off_pos.x, screen_h / 2 + self.root_node_off_pos.y, 0, 0)
		self.root_node:setAnchorPoint(0.5, 0.5)
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
				XUI.AddClickEventListener(self.real_root_node, BindTool.Bind1(self.OnCloseHandler, self))
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

	-- 创建UI
	if self.is_async_load then
		self:AsyncLoadPlist(index)
	else
		self:CreateUI(index)
	end
end

function XuiBaseView:IsValidIndex(index_list, index)
	for _, v in pairs(index_list) do
		if v == 0 or v == index then
			return true
		end
	end
	return false
end

function XuiBaseView:CreateUI(index)
	-- 加载纹理
	for _, v in pairs(self.texture_path_list) do
		if not ResourceMgr:getInstance():loadPlist(v) then
			ErrorLog("XuiBaseView:CreateUI fail 1:" .. v)
			return
		end
		table.insert(self.loaded_path_list, v)
	end

	for k, v in pairs(self.config_tab) do
		if nil == v.node and self:IsValidIndex(v[3], index) then
			local node_tree = XUI.GeneratorUI(v.config, self.root_node, k, self.node_t_list, self.node_tree, self.ph_list)
			v.node = node_tree.node
			if false == v[4] then
				v.node:setVisible(false)
			end
			self.loadstate_list[0] = XuiLoadState.Loaded
			self.loadstate_list[index] = XuiLoadState.Loaded
		end
	end
	
	self:RegisterDefClose()

	self.loaded_times = self.loaded_times + 1
	self:LoadCallBack(index, self.loaded_times)
end

function XuiBaseView:AsyncLoadPlist(index)
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
			ErrorLog("XuiBaseView:AsyncLoadPlist fail:" .. path)
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

function XuiBaseView:AsyncCreateUI(index)
	if self.loadstate_list[index] then
		return
	end

	for k, v in pairs(self.config_tab) do
		if nil == v.node and self:IsValidIndex(v[3], index) then
			self.async_task_count = self.async_task_count + 1
			XUI.AsyncGeneratorUI(v.config, self.root_node, k, self.node_t_list, self.node_tree, self.ph_list, 
				BindTool.Bind2(self.OnAsyncLoadFinish, self, v), self, v[4])

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

function XuiBaseView:OnAsyncLoadFinish(cfg_info, node_tree)
	cfg_info.node = node_tree.node
	self.async_task_count = self.async_task_count - 1
	if self.async_task_count <= 0 then
		self:asyncLoadComplete()
	end
end

function XuiBaseView:asyncLoadComplete()
	self.loadstate_list[0] = XuiLoadState.Loaded
	self.loadstate_list[self.loading_index] = XuiLoadState.Loaded

	self.async_task_count = 0

	local index = self.loading_index
	self.loading_index = nil

	self:RegisterDefClose()

	self.loaded_times = self.loaded_times + 1
	if self.loaded_times <= 1 and self.config_tab[1] and self.config_tab[1][1] == "common_ui_cfg" then
		self:CreateTopTitle()
	end
	self:LoadCallBack(index, self.loaded_times)
	if self.show_index == index then
		self:ShowIndexCallBack(index)
		self:FlushIndex(0)
		self:FlushIndex(index)
	end

	if self.next_load_index then
		local next_index = self.next_load_index
		self.next_load_index = nil
		self:ShowIndex(next_index, true)
	end
end

-- 默认关闭按钮
function XuiBaseView:RegisterDefClose()
	if nil ~= self.node_t_list.btn_close_window and not self.node_t_list.btn_close_window.is_listener then
		self.node_t_list.btn_close_window.node:addClickEventListener(BindTool.Bind1(self.OnCloseHandler, self))
		self.node_t_list.btn_close_window.is_listener = true
	end
end

function XuiBaseView:OnCloseHandler()
	self:Close()
end

function XuiBaseView:Open(index)
	if self.open_mode == OpenMode.OpenOnly then
		self:OpenOnly(index)
	elseif self.open_mode == OpenMode.OpenToggle then
		self:OpenToggle(index)
	end
end

function XuiBaseView:OpenOnly(index)
	self:CancelReleaseTimer()
	index = index or self.def_index
	self:ShowIndex(index)
	self:UpdateLocalZOrder()

	
	if not self.is_popup and nil ~= self.real_root_node then
		self:SetVisible(true)
		self:OpenCallBack()
	end
end

function XuiBaseView:UpdateLocalZOrder()
	if nil ~= self.real_root_node then
		self.real_root_node:resetLocalZOrder()
	end
end

function XuiBaseView:OpenToggle(index)
	if self.is_popup then
		self:Close()
	else 
		self:OpenOnly(index)
	end
end

function XuiBaseView:Close(...)
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

function XuiBaseView:CloseVisible()
	self.show_index = -1
	self:SetVisible(false)
	self:CancelDelayFlushTimer()
end

function XuiBaseView:CloseDestroy()
	self:CloseVisible()
	if nil == self.release_timer then
		local timer = 60
		-- 如果是开发服的话释放资源时间改为2，为了方便测试，外网的话60秒释放
		if AgentAdapter.GetSpid and AgentAdapter:GetSpid() == "dev" then
			timer = 2
		end
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			self:Release()
		end, timer)
	end
end

function XuiBaseView:ChangeToIndex(index)
	if not self:IsOpen() then
		return
	end

	self:ShowIndex(index)
end

function XuiBaseView:ShowIndex(index, is_force)
	if self.show_index == index and not is_force then
		return
	end

	if nil == index then
		DebugLog("XuiBaseView:ShowIndex index == nil")
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

	for k, v in pairs(self.funopen_modal_list) do
		v.node:setVisible(self.show_index == v.show_index)
	end

	if self:IsLoadedIndex(index) then
		self:ShowIndexCallBack(index)
		self:FlushIndex(index)
	end
end

function XuiBaseView:SetVisible(visible)
	if self.is_popup ~= visible and nil ~= self.real_root_node then
		self.is_popup = visible
		self.real_root_node:setVisible(visible)
	end
end

function XuiBaseView:IsOpen()
	return self.is_popup
end

function XuiBaseView:IsLoaded()
	return nil ~= self.root_node and 0 == self.async_task_count
end

function XuiBaseView:GetRootNode()
	return self.root_node
end

function XuiBaseView:GetRealRootNode()
	return self.real_root_node
end

function XuiBaseView:GetLocalZOrder()
	return self.real_root_node:getLocalZOrder()
end

----------------------------------------------------
-- 继承 begin
----------------------------------------------------
function XuiBaseView:LoadCallBack(index, loaded_times)
	-- override
end

function XuiBaseView:OpenCallBack()
	-- override
end

function XuiBaseView:ShowIndexCallBack(index)
	-- override
end

function XuiBaseView:CloseCallBack(...)
	-- override
end

function XuiBaseView:ReleaseCallBack()
	-- override
end

function XuiBaseView:OnFlush(param_list, index)
	-- override
end

-- 返回 (node, is_next)
function XuiBaseView:OnGetUiNode(node_name)
	-- override
	if nil ~= self.tabbar and nil ~= TabIndex[node_name] then
		local node, is_next = self.tabbar:GetToggleByIndex(TabIndex[node_name])
		if nil ~= node then
			return node, is_next
		end
	end
	if nil ~= self.node_t_list[node_name] then
		return self.node_t_list[node_name].node, true
	end
	if nil ~= self[node_name] then
		return self[node_name], true
	end

	local list_node, list_index, list_item_node = string.match(node_name, "list#(.+)#(%d+)#(.+)")
	if nil ~= list_node and nil ~= self[list_node] then
		local item = self[list_node]:GetItemAt(tonumber(list_index))
		if nil ~= item then
			if nil ~= item.node_tree[list_item_node] then
				return item.node_tree[list_item_node].node, true
			elseif nil ~= item[list_item_node] then
				return item[list_item_node], true
			end
		end
	end
end

function XuiBaseView:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function XuiBaseView:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end


----------------------------------------------------
-- 继承 end
----------------------------------------------------
-- index可以是数字也可以是数字table，key一般是字符串，value必须是一个table
function XuiBaseView:Flush(index, key, value, immediately)
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

	if immediately then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self:OnDelayFlush(self.show_index)
		return
	end

	if nil == self.delay_flush_timer and self:IsOpen() then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnDelayFlush, self, self.show_index), 0)
	end
end

function XuiBaseView:OnDelayFlush(index)
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

function XuiBaseView:CancelDelayFlushTimer()
	if self.delay_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function XuiBaseView:FlushIndex(index)
	if nil ~= self.flush_param_t[index] and self:IsLoadedIndex(index) then
		local param_list = self.flush_param_t[index]
		self.flush_param_t[index] = nil
		self:OnFlush(param_list, index)
	end
end

function XuiBaseView:IsModal()
	return self.is_modal
end

-- 必须在Load之前设置
function XuiBaseView:SetModal(value)
	self.is_modal = value
end

-- 必须在Load之前设置
function XuiBaseView:SetIsAnyClickClose(is_any_click_close)
	self.is_any_click_close = is_any_click_close
end

-- 必须在Load之前设置
function XuiBaseView:SetBgOpacity(opacity)
	self.background_opacity = opacity
end

-- 必须在Load之前设置
function XuiBaseView:SetRootNodeOffPos(pos)
	self.root_node_off_pos = pos
end

function XuiBaseView:GetViewName()
	return self.view_name
end

function XuiBaseView:GetShowIndex()
	return self.show_index
end

----------------------------------------------------
-- 创建通用UI
----------------------------------------------------
-- 设置功能未开启黑色阻挡层
function XuiBaseView:SetFunOpenBlockLayer(index, vis, cfg_param)
	if nil == self.root_node then
		return
	end

	if nil == self.funopen_modal_list[index] and vis then
		local offset_x, offset_y, param_w, param_h = string.match(cfg_param.other_param, "xywh=([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)#")
		if nil == offset_x then
			offset_x, offset_y, param_w, param_h = 0, -26, 953, 594
		else
			offset_x = tonumber(offset_x)
			offset_y = tonumber(offset_y)
			param_w = tonumber(param_w)
			param_h = tonumber(param_h)
		end

		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		local w, h = param_w, param_h
  		local real_pos = self.root_node:convertToNodeSpace(cc.p(offset_x + screen_w / 2, offset_y + screen_h / 2))
		local funopen_modal = XUI.CreateLayout(real_pos.x, real_pos.y, w, h)
		funopen_modal:setBackGroundColor(COLOR3B.BLACK)
		funopen_modal:setBackGroundColorOpacity(180)
		funopen_modal:setTouchEnabled(true)
		funopen_modal:setVisible(index == self.show_index)
		self.root_node:addChild(funopen_modal, 999)
		self.funopen_modal_list[index] = {show_index = index, node = funopen_modal}

		if FunOpenTriggerType.UpLevel == cfg_param.trigger_type then
			local rich_content = XUI.CreateRichText(w * 0.5, h * 0.5, 100, 30, true)
			rich_content:setHorizontalAlignment(RichHAlignment.HA_CENTER)
			rich_content:setVerticalAlignment(RichVAlignment.VA_CENTER)
			funopen_modal:addChild(rich_content, 1)

			local funopen_bg = XUI.CreateImageView(w * 0.5, h * 0.5, ResPath.GetCommon("bg_156"), true)
			funopen_modal:addChild(funopen_bg)

			XUI.RichTextAddImage(rich_content, ResPath.GetWord("word_rwdd"), false)
			local check_level = FunOpen.ParseCfgLevel(cfg_param.trigger_param)
			local check_zhuan = FunOpen.ParseCfgCircle(cfg_param.trigger_param)
			if 0 < check_zhuan then
				CommonDataManager.SetUiLabelAtlasImage(check_zhuan, rich_content, "num_117_", "common", nil, true)
				XUI.RichTextAddImage(rich_content, ResPath.GetWord("word_zhuan"), false)
			end
			if 0 < check_level then
				CommonDataManager.SetUiLabelAtlasImage(check_level, rich_content, "num_117_", "common", nil, true)
				XUI.RichTextAddImage(rich_content, ResPath.GetWord("word_ji"), false)
			end
			XUI.RichTextAddImage(rich_content, ResPath.GetWord("word_kqggn"), false)
		end

	elseif nil ~= self.funopen_modal_list[index] then
		if vis then
			self.funopen_modal_list[index].node:setVisible(index == self.show_index)
		else
			self.funopen_modal_list[index].node:removeFromParent()
			self.funopen_modal_list[index] = nil
		end
	end
end

function XuiBaseView:CreateDefCloseBtn()
	if nil == self.real_root_node or self.def_close_btn then
		return nil
	end

	local pos = self.real_root_node:convertToNodeSpace(cc.p(HandleRenderUnit:GetWidth() - 50, HandleRenderUnit:GetHeight() - 42))
	self.def_close_btn = XUI.CreateButton(pos.x, pos.y, 0, 0, false, ResPath.GetCommon("btn_106"))
	self.real_root_node:addChild(self.def_close_btn, 9999)
	self.def_close_btn:addClickEventListener(BindTool.Bind(self.OnCloseHandler, self))
end

function XuiBaseView:CreateTopTitle(path, x, y, parent)
	if nil == self.root_node then
		ErrorLog("CreateTopTitle失败,请在loadcallback后创建")
		return
	end

	if nil == self.view_top_title and nil ~= path then
		local content_size = self.root_node:getContentSize()
		x = x or content_size.width / 2
		y = y or content_size.height - 50
		parent = parent or self.root_node
		self.view_top_title = XUI.CreateImageView(x, y, path, false)
		parent:addChild(self.view_top_title, 999)
	elseif nil ~= self.view_top_title and nil ~= path then
		self.view_top_title:loadTexture(path)
	end
end
