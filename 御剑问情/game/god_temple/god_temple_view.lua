require("game/god_temple/god_temple_pata_view")
require("game/god_temple/god_temple_shenqi_view")

GodTempleView = GodTempleView or BaseClass(BaseView)

function GodTempleView:__init()
	self.ui_config = {"uis/views/godtemple_prefab", "GodTempleView"}
	self.full_screen = true
	self.is_init_toggle = true

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
	self.best_rank_change = BindTool.Bind(self.BestRankChange, self)
end

function GodTempleView:__delete()
end

function GodTempleView:ReleaseCallBack()
	for k, v in pairs(self.view_cfg) do
		if v.view then
			v.view:DeleteMe()
		end
	end
	self.view_cfg = nil

	self.view_index_info = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.force_fix_time_quest then
		GlobalTimerQuest:CancelQuest(self.force_fix_time_quest)
		self.force_fix_time_quest = nil
	end

	if self.best_rank_event then
		GlobalEventSystem:UnBind(self.best_rank_event)
		self.best_rank_event = nil
	end

	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)

	self.variable_list = nil
	self.other_node_list = nil
	self.red_point_list = nil
end

function GodTempleView:LoadCallBack()
	self.variable_list = {
		gold = self:FindVariable("Gold"),
		bind_gold = self:FindVariable("BindGold"),
	}

	self.other_node_list = {
		tab_list = self:FindObj("tab_list"),
	}

	self.view_cfg = {
		[TabIndex.godtemple_pata] = {
			toggle = self:FindObj("toggle_pata"),
			event_name = "OpenPaTa",
			content = self:FindObj("pata_content"),
			view = nil,
			view_class = GodTemplePaTaView,
			flush_params = {["pata"] = true, ["rank"] = true},
			asset_bundle = {"uis/views/godtemple_prefab", "PaTaContent"},
			interval_remind_info = nil,														--间隔提醒红点
			funopen_name = "godtemple_pata",
		},
		[TabIndex.godtemple_shenqi] = {
			toggle = self:FindObj("toggle_shenqi"),
			event_name = "OpenShenQi",
			content = self:FindObj("shenqi_content"),
			view = nil,
			view_class = GodTempleShenQiView,
			flush_params = {["shenqi"] = true},
			asset_bundle = {"uis/views/godtemple_prefab", "ShenQiContent"},
			interval_remind_info = nil,
			funopen_name = "godtemple_shenqi",
		},
	}

	self.view_index_info = {}
	local key = 0
	for k, v in pairs(self.view_cfg) do
		--只有后面两位是有意义的
		key = k % 100
		self.view_index_info[key] = k
	end

	-- 监听UI事件
	for k, v in pairs(self.view_cfg) do
		self:ListenEvent(v.event_name, BindTool.Bind(self.ClickTab, self, k))
	end

	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.CloseWindow, self))

	--红点
	self.red_point_list = {
		[RemindName.GodTemple_PaTa] = self:FindVariable("ShowPaTaRed"),
		[RemindName.GodTemple_ShenQi] = self:FindVariable("ShowShenQiRed"),
	}
	for k,v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function GodTempleView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function GodTempleView:CloseWindow()
	self:Close()
end

--根据选中的标签强制定位tab列表
function GodTempleView:ForceFixTabList()
	--加延迟防止列表没创建获取的数据是错的
	self.force_fix_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local tab_list = self.other_node_list.tab_list

		local view_cfg_info = self.view_cfg[self.show_index or 0]
		if view_cfg_info then
			local viewport = tab_list.scroll_rect.viewport

			local viewport_height = viewport.rect.height

			local tab = U3DObject(view_cfg_info.toggle.transform.parent.gameObject)

			--加10的偏移值
			if math.abs(tab.rect.anchoredPosition.y) >= viewport_height - 10 then
				tab_list.scroll_rect.verticalNormalizedPosition = 0
			else
				tab_list.scroll_rect.verticalNormalizedPosition = 1
			end
		else
			tab_list.scroll_rect.verticalNormalizedPosition = 1
		end
	end, 0.1)
end

function GodTempleView:OpenCallBack()
	-- 监听系统事件
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	--监听全局事件
	self.best_rank_event = GlobalEventSystem:Bind(OtherEventType.BEST_RANK_CHANGE, self.best_rank_change)

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self:ShowOrHideTab()

	-- 由于右侧标签列表过长，所以打开时要做列表定位处理，防止打开界面时选中的tab看不到
	-- self:ForceFixTabList()

	--请求协议
	GodTemplePataCtrl.Instance:ReqPataFbNewAllInfo()
	GodTempleShenQiCtrl.Instance:ReqPataFbNewShenQiInfo()
end

function GodTempleView:CloseCallBack()
	if self.force_fix_time_quest then
		GlobalTimerQuest:CancelQuest(self.force_fix_time_quest)
		self.force_fix_time_quest = nil
	end

	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)

	if self.best_rank_event then
		GlobalEventSystem:UnBind(self.best_rank_event)
		self.best_rank_event = nil
	end

	local index = self.show_index or 0
	local view_cfg_info = self.view_cfg[index]
	if view_cfg_info and view_cfg_info.view and view_cfg_info.view.CloseView then
		view_cfg_info.view:CloseView()
	end
end

function GodTempleView:ShowOrHideTab()
	for k, v in pairs(self.view_cfg) do
		v.toggle.transform.parent.gameObject:SetActive(OpenFunData.Instance:FunIsUnLock(v.funopen_name) == true)
	end
end

function GodTempleView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		value = CommonDataManager.ConverMoney(value)

		if attr_name == "bind_gold" then
			self.variable_list.bind_gold:SetValue(value)
		else
			self.variable_list.gold:SetValue(value)
		end
	end
end

function GodTempleView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GodTempleView:ClickTab(tab_index)
	if tab_index == self.show_index then
		return
	end

	self.is_init_toggle = false
	self:ShowIndex(tab_index)
end

function GodTempleView:InitAllToggleIsOn()
	for k, v in pairs(self.view_cfg) do
		v.toggle.toggle.isOn = false
	end
end

function GodTempleView:AsyncLoadCallBack(index, obj)
	local view_cfg_info = self.view_cfg[index]
	if view_cfg_info then
		obj.transform:SetParent(view_cfg_info.content.transform, false)
		obj = U3DObject(obj)
		view_cfg_info.view = view_cfg_info.view_class.New(obj)

		if self.show_index == index then
			view_cfg_info.view:InitView()
		end
	end
end

function GodTempleView:ShowIndexCallBack(index)
	index = index or 0
	local view_cfg_info = self.view_cfg[index]
	if nil == view_cfg_info then
		local tab_index = TabIndex.godtemple_pata
		for k, v in ipairs(self.view_index_info) do
			view_cfg_info = self.view_cfg[v]
			if OpenFunData.Instance:FunIsUnLock(view_cfg_info.funopen_name) then
				tab_index = v
				break
			end
		end
		self:ShowIndex(tab_index)
		return
	end

	local last_index = self.last_index or 0
	local last_view_cfg_info = self.view_cfg[last_index]
	if last_view_cfg_info and last_view_cfg_info.view and last_view_cfg_info.view.CloseView then
		last_view_cfg_info.view:CloseView()
	end

	--这个初始化toggle的isOn状态比较消耗性能
	if self.is_init_toggle then
		self:InitAllToggleIsOn()
	else
		self.is_init_toggle = true
	end

	local asset_bundle_info = view_cfg_info.asset_bundle
	self:AsyncLoadView(index, asset_bundle_info[1], asset_bundle_info[2], self.async_load_call_back)

	view_cfg_info.toggle.toggle.isOn = true
	if view_cfg_info.view then
		view_cfg_info.view:InitView()
	end
end

function GodTempleView:OnFlush(param_t)
	local index = self.show_index or 0
	--根据index取得对应的界面配置
	local view_cfg_info = self.view_cfg[index]
	if nil == view_cfg_info then
		return
	end

	local view = view_cfg_info.view
	if nil == view then
		return
	end

	local flush_params = view_cfg_info.flush_params

	for k, v in pairs(param_t) do
		if flush_params[k] then
			view:Flush(k, v)
		end
	end
end

function GodTempleView:BestRankChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_GOD_TEMPLE then
		if self.show_index == TabIndex.godtemple_pata then
			self:Flush("rank")
		end
	end
end