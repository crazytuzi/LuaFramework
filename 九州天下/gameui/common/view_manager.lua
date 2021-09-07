ViewManager = ViewManager or BaseClass()

function ViewManager:__init()
	if nil ~= ViewManager.Instance then
		print_error("[ViewManager]:Attempt to create singleton twice!")
	end
	ViewManager.Instance = self

	self.view_list = {}

	self.open_view_list = {}

	self.wait_load_chat_list = {}
end

function ViewManager:__delete()
	if self.main_open_event then
		GlobalEventSystem:UnBind(self.main_open_event)
		self.main_open_event = nil
	end
	ViewManager.Instance = nil
end

function ViewManager:DestoryAllAndClear(record_list)
	for k,v in pairs(self.view_list) do
		if v:IsOpen() then
			v:Close()
			v:Release()
		end
	end

	self.view_list = {}
	self.open_view_list = {}
	self.wait_load_chat_list = {}
end

-- 注册一个界面
function ViewManager:RegisterView(view, view_name)
	self.view_list[view_name] = view
end

-- 反注册一个界面
function ViewManager:UnRegisterView(view_name)
	self.view_list[view_name] = nil
end

-- 获取一个界面
function ViewManager:GetView(view_name)
	return self.view_list[view_name]
end

-- 界面是否打开
function ViewManager:IsOpen(view_name)
	if nil == self.view_list[view_name] then
		return false
	end

	return self.view_list[view_name]:IsOpen()
end

-- 界面是否打开
function ViewManager:HasOpenView()
	local list = self.open_view_list[UiLayer.Normal]
	if nil == list then
		return false
	end

	for k,v in pairs(list) do
		if v.view_name and v.view_name ~= ViewName.Main and v.view_name ~= "" and v.active_close and v:IsRealOpen() then
			return true
		end
	end

	return false
end

-- 打开界面
local now_view = nil
function ViewManager:Open(view_name, index, key, values, tab_index)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		--活动界面特殊处理
		if view_name == ViewName.ActivityDetail then
			ActivityCtrl.Instance:ShowDetailView(index)
			return
		end
		local is_open, tips = self:CheckShowUi(view_name, index, tab_index)
		if is_open then
			now_view:Open(index)
			if key ~= nil and values ~= nil then
				now_view:Flush(key, values)
			end
		else
			tips = (tips and tips ~= "" and tips) or Language.Common.FunOpenTip
			SysMsgCtrl.Instance:ErrorRemind(tips)
		end
	end
end

-- 配表打开界面
function ViewManager:OpenByCfg(cfg, data, flush_key)
	if cfg == nil then
		return
	end

	local t = Split(cfg, "#")
	local view_name = t[1]
	local tab_index = t[2]

	-- 判断功能开启
	if TabIndex[tab_index] == TabIndex.baoju_medal and not OpenFunData.Instance:CheckIsHide("baoju_medal") then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.FuncNoOpen)
		return
	end

	local param_t = {
		open_param = nil,			--打开面板参数
		sub_view_name = nil,		--打开二级面板
		to_ui_name = 0,				--跳转ui
		to_ui_param = 0,			--跳转ui参数
	}
	param_t.item_id = data and data.item_id or 0
	if t[3] ~= nil then
		local key_value_list = Split(t[3], ",")
		for k,v in pairs(key_value_list) do
			local key_value_t = Split(v, "=")
			local key = key_value_t[1]
			local value = key_value_t[2]

			if key == "sub" then
				param_t.sub_view_name = value
			elseif key == "op" then
				param_t.open_param = value
			elseif key == "uin" then
				param_t.to_ui_name = value
			elseif key == "uip" then
				param_t.to_ui_param = value
			end
		end
	end
	local index = TabIndex[tab_index]
	if tonumber(tab_index) then
		index = tonumber(tab_index)
	end
	self:Open(view_name, index, flush_key or "all", param_t, tab_index)
end

-- 关闭界面
function ViewManager:Close(view_name, ...)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Close(...)
	end
end

-- 关闭所有界面
function ViewManager:CloseAll()
	for k,v in pairs(self.view_list) do
		if v:CanActiveClose() then
			if v:IsOpen() then
				v:Close()
			end
		end
	end
end

-- 关闭界面
function ViewManager:CloseAllViewExceptViewName(view_name, value)
	local no_view_name = view_name
	if no_view_name == ViewName.ActivityDetail then
		local act_id = tonumber(value)
		if act_id ~= nil then
			if act_id == ACTIVITY_TYPE.KF_ONEVONE then
				no_view_name = ViewName.KuaFu1v1
			elseif act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
				no_view_name = ViewName.ClashTerritory
			elseif act_id == ACTIVITY_TYPE.GONGCHENGZHAN then
				no_view_name = ViewName.CityCombatView
			end
		end
	end
	
	for k, v in pairs(self.view_list) do
		if v:CanActiveClose() and k ~= no_view_name then
			if v:IsOpen() then
				v:Close()
			end
		end
	end
end

-- 是否可以显示该UI
function ViewManager:CheckShowUi(view_name, index, tab_index)
	local can_show_view = true
	local tips = ""
	if IS_ON_CROSSSERVER then
		if view_name then
			-- 跨服中是否可以打开
			can_show_view, tips = CrossServerData.Instance:CheckCanOpenInCross(view_name)
		end
	end
	if view_name and can_show_view and OpenFunData.Instance then
		can_show_view, tips = OpenFunData.Instance:CheckIsHide(string.lower(view_name))
	end
	local can_show_index = true
	if index and can_show_view then
		local check_index = tab_index or index
		can_show_index, tips = OpenFunData.Instance:CheckIsHide(check_index)
	end
	return can_show_view and can_show_index, tips
end

-- 刷新界面
function ViewManager:FlushView(view_name, ...)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Flush(...)
	end
end

-- 获得UI节点
function ViewManager:GetUiNode(view_name, node_name)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		return now_view:OnGetUiNode(node_name)
	end
	return nil
end

function ViewManager:AddOpenView(view)
	self:RemoveOpenView(view, true)
	self.open_view_list[view:GetLayer()] = self.open_view_list[view:GetLayer()] or {}
	table.insert(self.open_view_list[view:GetLayer()], view)

	self:SortView(view:GetLayer())
	self:CheckViewRendering()
	GlobalEventSystem:Fire(OtherEventType.VIEW_OPEN, view)
end

function ViewManager:RemoveOpenView(view, ignore)
	if nil == self.open_view_list[view:GetLayer()] then
		return
	end

	for k, v in ipairs(self.open_view_list[view:GetLayer()]) do
		if v == view then
			v.__sort_order__ = 0
			table.remove(self.open_view_list[view:GetLayer()], k)
			break
		end
	end
	if not ignore then
		self:CheckViewRendering()
	end
	GlobalEventSystem:Fire(OtherEventType.VIEW_CLOSE, view)
end

local is_full_screen = false
local can_inactive = false
local view = nil
local is_open = false
local is_rendering = false
local task_view = nil
local task_view_isopen = false
local unlock_view = nil
local unlock_view_isopen = false
function ViewManager:CheckViewRendering()
	is_full_screen = false
	task_view = task_view or self:GetView(ViewName.TaskDialog)
	task_view_isopen = task_view and task_view.is_real_open
	unlock_view = unlock_view or self:GetView(ViewName.Unlock)
	unlock_view_isopen = unlock_view and unlock_view.is_real_open
	for i=UiLayer.MaxLayer, 0, -1 do
		if self.open_view_list[i] then
			for j=#self.open_view_list[i], 1, -1 do
				view = self.open_view_list[i][j]
				can_inactive = false
				if view then
					if view.view_name ~= ViewName.TaskDialog
						and view.view_name ~= ViewName.TipsPowerChangeView
						and view.view_name ~= ViewName.TipsDisconnectedView
						and view.view_name ~= ViewName.LoadingTips
						and view.view_name ~= ViewName.Unlock
						and view.view_name ~= ViewName.SceneLoading then
						if unlock_view_isopen and view.view_name ~= ViewName.Main then
							can_inactive = true
						elseif task_view_isopen or is_full_screen then
							can_inactive = true
						elseif MainUIData.IsFightState and view.fight_info_view then
							can_inactive = true
						end
					end
					is_open = view.is_real_open
					is_rendering = view:IsRendering()
					if is_open and is_rendering ~= not can_inactive then
						view:SetRendering(not can_inactive)
						if not is_rendering and not can_inactive and view.root_node then
							-- if view.animator ~= nil then
							-- 	view.animator:SetBool("show", true)
							-- end
							-- 重置坐标位置
							local transform = view.root_node.transform
							transform:SetLocalScale(1, 1, 1)
							local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
							rect.anchorMax = Vector2(1, 1)
							rect.anchorMin = Vector2(0, 0)
							rect.anchoredPosition3D = Vector3(0, 0, 0)
							rect.sizeDelta = Vector2(0, 0)

							view:ShowIndexCallBack(view.show_index)
						end
					end
					if view.full_screen and not is_full_screen and not task_view_isopen and not unlock_view_isopen then
						is_full_screen = true
					end
				end
			end
		end
	end

	--屏蔽场景和屏幕上的移动UI
	if Scene.Instance ~= nil and not Scene.Instance:IsSceneLoading() then
		Scene.Instance:SetSceneVisible(task_view_isopen or not is_full_screen)
		FightText.Instance:SetActive(task_view_isopen or not is_full_screen)
	end

	-- Close the ui scene.
	if not is_full_screen and UIScene.scene_asset then
		UIScene:ChangeScene(nil)
	end
end

local sort_interval = 10
function ViewManager:SortView(layer)
	if nil == self.open_view_list[layer] then
		return
	end

	for i, v in ipairs(self.open_view_list[layer]) do
		if v.__sort_order__ ~= i then
			v.__sort_order__ = i
			local root = v:GetRootNode()
			if nil ~= root then
				local canvases = root:GetComponentsInChildren(typeof(UnityEngine.Canvas), true)
				local canvas_len = canvases.Length
				for j = 0, canvas_len - 1 do
					local canvas = canvases[j]
					-- Dropdown会设置到30000，默认是所有层级的最上面。
					-- 防止把Dropdown的行为改变了.
					if canvas.sortingOrder < 30000 then
						canvas.overrideSorting = true
						canvas.sortingOrder = canvas.sortingOrder % sort_interval + layer * 1000 + i * sort_interval
					end
				end

				local overriders = root:GetComponentsInChildren(typeof(SortingOrderOverrider), true)
				local overrider_len = overriders.Length
				for j = 0, overrider_len - 1 do
					local overrider = overriders[j]
					overrider.SortingOrder = overrider.SortingOrder % sort_interval + layer * 1000 + i * sort_interval
				end
			end
		end
	end
end
