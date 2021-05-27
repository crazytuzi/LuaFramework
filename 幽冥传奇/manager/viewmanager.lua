ViewManager = ViewManager or BaseClass()

local ViewDef = ViewDef
local OffsetPosCfg = OffsetPosCfg
local RelationOpenStateCfg = RelationOpenStateCfg

function ViewManager:__init()
	if nil ~= ViewManager.Instance then
		ErrorLog("[ViewManager]:Attempt to create singleton twice!")
	end

	ViewManager.Instance = self

	self.view_list = {}
	self.check_fun_open_func = nil
	self.check_fun_vis_func = nil
	self.funopen_tab_list = {}
	self.funopen_node_list = {}
	self.is_everopened_view_list = {}

	self.release_obj_list = {}
	Runner.Instance:AddRunObj(self, 15)
end

function ViewManager:__delete()
	ViewManager.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

-- 每帧只销毁一个界面对象
function ViewManager:Update(now_time, elapse_time)
	if #self.release_obj_list <= 0 then
		return
	end

	for i, v in ipairs(self.release_obj_list) do
		if v:CanRelease() then -- 加强判断是否可以被销毁
			v:Release()
		end
		table.remove(self.release_obj_list, i)
		break
	end
end

-- 添加要销毁界面对象
function ViewManager:AddReleaseObj(obj)
	table.insert(self.release_obj_list, obj)
end

-- 是否是根界面定义
function ViewManager:IsRootDef(def)
	return #def.view_key_t == 1
end

-- 获取根界面定义
function ViewManager:GetRootDef(def)
	return ViewDef[def.view_key_t[1]]
end

-- 获取界面定义深度
function ViewManager:GetDefDepth(def)
	return #def.view_key_t
end

-- 打开界面
function ViewManager:OpenViewByDef(view_def)
	if view_def and view_def.view_key_t then
		return self:OpenViewByKeyT(view_def.view_key_t)
	end
	return false
end

-- 关闭界面
function ViewManager:CloseViewByDef(view_def)
	self:SetRecursiveOpenState(view_def, false)
	self:UpdateViewRootPos(self:GetRootDef(view_def), true)
	self:UpdateRelationViewVis(self:GetRootDef(view_def))
	self:UpdateViewVis(view_def)
end

-- 将节点界面打开状态都设置为false
function ViewManager:SetRecursiveOpenState(node, bool)
	self:SetOpenState(node, bool)
	for k, v in pairs(self:GetChildGroup(node)) do
		self:SetRecursiveOpenState(v, bool)
	end
end

-- 递归设置node的默认打开状态
function ViewManager:SetDefaultOpen(node)
	local default_child = node.default_child
	if default_child and node[default_child] and self:CanOpen(node[default_child]) then
		self:SetOpenState(node[default_child], true)
		self:SetDefaultOpen(node[default_child])
	end
end

function ViewManager:GetDefByKeyT(v_key_t)
	local cur_node = ViewDef[v_key_t[1]]
	for i = 2, #v_key_t do
		local node = cur_node[v_key_t[i]]
		if node then
			cur_node = node
		else
			return nil
		end
	end
	return cur_node
end

-- 打开界面需要用到界面定义中的 界面key表
function ViewManager:OpenViewByKeyT(v_key_t)
	local def = self:GetDefByKeyT(v_key_t)
	local root_node = ViewDef[v_key_t[1]]
	if nil == root_node or nil == def then
		return false
	end

	-- 打印栈信息
	if def.name == "" then
		print("查找打开面板的代码位置,屏蔽打印需ViewDef中的name不为空字符串")
		DebugLog()
	end

	-- 界面是否能打开
	if not self:CanOpen(def) then

		if root_node == ViewDef.Guild and self:CanOpen(ViewDef.Guild.GuildView.GuildJoinList) then
			-- 未加入行会之前，跳转至行会加入
			return self:OpenViewByDef(ViewDef.Guild.GuildView.GuildJoinList)
		end
		local tip_str = GameCondMgr.Instance:GetTip(def.v_open_cond) or "功能未开启"
		local is_on_crossserver = GameCond[def.v_open_cond] and GameCond[def.v_open_cond].IsOnCrossserver
		if IS_ON_CROSSSERVER and not is_on_crossserver then
			tip_str = Language.Common.IsOnCrossserver
		end
		
		SysMsgCtrl.Instance:FloatingTopRightText(tip_str)
		return false
	end

	-- 先将所有界面状态标记为关闭
	self:SetRecursiveOpenState(root_node, false)
	-- 然后把所有要打开的界面状态标记为打开
	local cur_node = root_node
	self:SetOpenState(cur_node, true)
	for i = 2, #v_key_t do
		local node = cur_node[v_key_t[i]]
		if node and self:GetViewObj(node) then
			self:SetOpenState(node, true)
			cur_node = node
		end
	end

	-- 默认孩子打开状态处理
	self:SetDefaultOpen(cur_node)
	if "dev" == AgentAdapter:GetSpid() then
		print("viewLink: " .. table.concat(v_key_t, "#"))
	end

	self:UpdateViewRootPos(root_node, true)		-- 界面坐标偏移处理
	self:UpdateViewVis(root_node)				-- 更新界面的显示
	self:UpdateRelationViewVis(root_node) 		-- 关联界面显示处理
	return true
end

-- 更新界面的显示
function ViewManager:UpdateViewVis(def)
	local view_obj = self:GetViewObj(def)
	if view_obj then
		if self:IsOpen(def) then
			view_obj:Open()
		else
			view_obj:Close()
		end
	else
		if "dev" == AgentAdapter:GetSpid() then
			print("[ViewManager]:not register view " .. table.concat(def.view_key_t, "#"))
		end
	end

	for k, v in pairs(self:GetChildGroup(def)) do
		self:UpdateViewVis(v)
	end
end

-- 更新相关界面的显示
function ViewManager:UpdateRelationViewVis(def)
	local open_cfg = RelationOpenStateCfg[def]
	if nil == open_cfg then
		return
	end

	for k, v in pairs(open_cfg) do
		if (v[2] == self:IsOpen(def)) then
			if v[3] then
				self:OpenViewByDef(v[1])
			else
				self:CloseViewByDef(v[1])
			end
		end
	end
end

-- 更新界面的坐标
-- relation_update 是否更新相关的界面
function ViewManager:UpdateViewRootPos(def, relation_update)
	local offset_pos_cfg = OffsetPosCfg[def]
	if nil == offset_pos_cfg then
		return
	end

	local is_offset = false
	for k, v in pairs(offset_pos_cfg) do
		if not is_offset and self:IsOpen(def) and self:IsOpen(v[1]) then
			self:GetViewObj(def):SetRootNodeOffPos(v[2], true)
			is_offset = true
		end
		if relation_update then
			self:UpdateViewRootPos(v[1], false)
		end
	end
	if not is_offset then
		self:GetViewObj(def):SetRootNodeOffPos(cc.p(0, 0), true)
	end
end

-- 界面是否可以打开
function ViewManager:CanOpen(def)
	return (nil == def.v_open_cond) or GameCondMgr.Instance:GetValue(def.v_open_cond)
end

-- 界面是否打开
function ViewManager:IsOpen(def)
	return def and def.open or false
end

-- 设置界面是否打开
function ViewManager:SetOpenState(def, state)
	def.open = state
end

-- 获取一个界面
function ViewManager:GetView(def)
	return def and def.view_obj
end

function ViewManager:GetViewByStr(str)
	return self:GetDefByKeyT(Split(str or "", "#"))
end

-- 以字符串配置打开界面
function ViewManager:OpenViewByStr(str)
	local view_param = Split(str or "", "#")
	self:OpenViewByKeyT(view_param)
end

-- 生成配置字符串
function ViewManager:GetStrByView(view_def)
	return table.concat(view_def.view_key_t or {}, "#")
end

-- 注册一个界面
function ViewManager:RegisterView(view, def)
	if nil == def.view_obj then
		def.view_obj = view
	else
		ErrorLog(string.format("[ViewManager]:Attempt to create %s twice!", ViewManager:GetStrByView(def)))
	end
end

-- 获取一个界面
function ViewManager:GetViewObj(def)
	return def and def.view_obj
end

-- 获取子节点组
function ViewManager:GetChildGroup(def)
	return def and def.child_group
end

-- 刷新界面
function ViewManager:FlushViewByDef(def, ...)
	local view = self:GetViewObj(def)
	if nil ~= view then
		view:Flush(...)
	end
end

--刷新界面2
function ViewManager:FlushViewByStr(str,... )
	local def = self:GetViewByStr(str)
	local view = self:GetViewObj(def)
	if nil ~= view then
		view:Flush(...)
	end
end

-- 关闭所有界面
function ViewManager:CloseAllView()
	for key, root_def in pairs(ViewDef) do
		if self:IsOpen(root_def) and not root_def.cannotbeclose then
			self:CloseViewByDef(root_def)
		end
	end
end

-- 获得UI节点
function ViewManager:GetUiNode(view_str, node_name, view_name)
	local view_def = self:GetViewByStr(view_str)
	local view_obj = self:GetViewObj(view_def)
	if nil ~= view_obj then
		return view_obj:OnGetUiNode(node_name, view_name)
	end
	return nil
end

-------------------------------------------------------------------------------------------------

function ViewManager:IsOpenByViewName(view_name)
	return self.view_list[view_name] and self.view_list[view_name]:IsOpen()
end

-- 反注册一个界面
function ViewManager:UnRegisterView(view_name)
	self.view_list[view_name] = nil
end

-- 打开界面 弃用
local now_view = nil
function ViewManager:Open(view_name, index, is_ignore_funopen)
end

-- 关闭界面
function ViewManager:Close(view_name, ...)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Close(...)
	end
end

-- 该功能是否开启
function ViewManager:CanShowUi(view_name, index)
	if nil ~= self.check_fun_open_func then
		return self.check_fun_open_func(view_name, index)
	end
	return true
end

-- 是否可以显示该UI
function ViewManager:FunVis(view_name, index)
	if nil ~= self.check_fun_vis_func then
		return self.check_fun_vis_func(view_name, index)
	end
	return true
end

-- 注册功能开启检测函数, func(view_name, index)
function ViewManager:RegisterCheckFunOpen(func)
	self.check_fun_open_func = func
end

-- 注册功能显示检测函数, func(view_name, index)
function ViewManager:RegisterCheckFunVis(func)
	self.check_fun_vis_func = func
end

-- 刷新界面
function ViewManager:FlushView(view_name, ...)
	ErrorLog("ViewManager:FlushView, 此接口已弃用")
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Flush(...)
	end
end

-------标签-------------

function ViewManager:RegsiterTabFunUi(view_name, tab)
end

function ViewManager:UnRegsiterTabFunUi(view_name)
	self.funopen_tab_list[view_name] = nil
end

function ViewManager:RegsiterNodeFunUi(view_name, node)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("funopen_auto").funopen_list) do
		if v.ui_type == FunOpenUiType.Node and v.view_name == view_name then 
			if nil == self.funopen_node_list[view_name] then
				self.funopen_node_list[view_name] = {}
			end
			if nil == self.funopen_node_list[view_name] then
				self.funopen_node_list[view_name] = {}
			end
			self.funopen_node_list[view_name][node] = 1
			self:SetFunOpenNodeVisible(view_name, v)
			node:registerScriptHandler(function(event_text)
				if "cleanup" == event_text then
					-- 节点清除时自动反注册检测事件
					self:UnRegsiterNodeFunUi(view_name, node)
				end
			end)
		end
	end
end

function ViewManager:UnRegsiterNodeFunUi(view_name, node)
	if self.funopen_node_list[view_name] then
		self.funopen_node_list[view_name][node] = nil
	end
end

function ViewManager:SetFunOpenTabVisible(view_name, index, cfg_param)
	if nil == self.funopen_tab_list[view_name] or nil == index then return end
	local tab = self.funopen_tab_list[view_name]
	local view = self:GetView(view_name)
	local vis = self:FunVis(view_name, index)
	local is_open = self:CanShowUi(view_name, index)

	if nil ~= tab.SetToggleVisible then
		tab:SetToggleVisible(index, vis)
	end

	if cfg_param then
		if FunOpenTabType.BlockLayer == cfg_param.tab_param and nil ~= view and nil ~= view.SetFunOpenBlockLayer then
			view:SetFunOpenBlockLayer(index, not is_open, cfg_param)
		elseif FunOpenTabType.Tip == cfg_param.tab_param and nil ~= tab.SetBtnModalEnabled then
			tab:SetBtnModalEnabled(index, not is_open, BindTool.Bind(self.ShowFunOpenTips, self, view_name, index))
		end
	end
end

function ViewManager:SetFunOpenNodeVisible(view_name, cfg_param)
	if nil == self.funopen_node_list[view_name] then
		return
	end

	local node_list = self.funopen_node_list[view_name]
	local vis = self:FunVis(view_name)
	local is_open = self:CanShowUi(view_name)

	for node, _ in pairs(node_list) do
		node:setVisible(vis)
		if vis then
			if nil == node.fun_open_modal and not is_open then
				local size = node:getContentSize()
				node.fun_open_modal = XUI.CreateLayout(size.width / 2, size.height / 2, size.width, size.height)
				node.fun_open_modal:addClickEventListener(function() self:ShowFunOpenTips(view_name) end)
				node.fun_open_modal:setTouchEnabled(true)
				node:addChild(node.fun_open_modal, 999)
			elseif nil ~= node.fun_open_modal then
				node.fun_open_modal:setTouchEnabled(not is_open)
			end
		end
	end
end

function ViewManager:ShowFunOpenTips(view_name, index)
	if self.check_fun_open_func then
		local _, tip = self.check_fun_open_func(view_name, index)
		if tip then
			SysMsgCtrl.Instance:ErrorRemind(tip)
		else
			if view_name ~= ViewName.NpcDialog then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.FunOpenTip)
			end
		end
	else
		if view_name ~= ViewName.NpcDialog then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.FunOpenTip)
		end
	end
end

function ViewManager:GetEverOpenedViewList()
	return self.is_everopened_view_list
end
