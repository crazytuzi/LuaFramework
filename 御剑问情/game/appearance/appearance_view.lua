require("game/appearance/multi_mount_view")
require("game/appearance/waist_content_view")
require("game/appearance/toushi_content_view")
require("game/appearance/qilinbi_content_view")
require("game/appearance/mask_content_view")
require("game/appearance/lingzhu_content_view")
require("game/appearance/xianbao_content_view")
require("game/appearance/linggong_content_view")
require("game/appearance/lingqi_content_view")

AppearanceView = AppearanceView or BaseClass(BaseView)

function AppearanceView:__init()
	self.ui_config = {"uis/views/appearance_prefab", "AppearanceView"}
	self.full_screen = true
	self.play_audio = true
	self.is_check_reduce_mem = true
	self.is_init_toggle = true

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
end

function AppearanceView:__delete()
end

function AppearanceView:ReleaseCallBack()
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

	self.variable_list = nil
	self.other_node_list = nil
	self.red_point_list = nil
end

function AppearanceView:LoadCallBack()
	self.variable_list = {
		gold = self:FindVariable("Gold"),
		bind_gold = self:FindVariable("BindGold"),
	}

	self.other_node_list = {
		tab_list = self:FindObj("TabList"),
	}

	self.view_cfg = {
		[TabIndex.appearance_multi_mount] = {
			tab = self:FindObj("TabMulti"),
			toggle = self:FindObj("ToggleMulti"),
			event_name = "OpenMulti",
			content = self:FindObj("MultiMountContent"),
			view = nil,
			view_class = MultiMountView,
			flush_params = {},
			asset_bundle = {"uis/views/appearance_prefab", "MultiMount"},
			interval_remind_info = nil,														--间隔提醒红点
			funopen_name = "appearance_multi_mount",
		},
		[TabIndex.appearance_waist] = {
			tab = self:FindObj("TabWaist"),
			toggle = self:FindObj("ToggleWaist"),
			event_name = "OpenWaist",
			content = self:FindObj("WaistContent"),
			view = nil,
			view_class = WaistContentView,
			flush_params = {["waist"] = true, ["waist_upgrade"] = true, ["waist_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "WaistContent"},
			interval_remind_info = {remind_name = RemindName.Waist_UpGrade, interval = 3600},
			funopen_name = "appearance_waist",
		},
		[TabIndex.appearance_toushi] = {
			tab = self:FindObj("TabTouShi"),
			toggle = self:FindObj("ToggleTouShi"),
			event_name = "OpenTouShi",
			content = self:FindObj("TouShiContent"),
			view = nil,
			view_class = TouShiContentView,
			flush_params = {["toushi"] = true, ["toushi_upgrade"] = true, ["toushi_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "TouShiContent"},
			interval_remind_info = {remind_name = RemindName.TouShi_UpGrade, interval = 3600},
			funopen_name = "appearance_toushi",
		},
		[TabIndex.appearance_qilinbi] = {
			tab = self:FindObj("TabQilinBi"),
			toggle = self:FindObj("ToggleQilinBi"),
			event_name = "OpenQilinBi",
			content = self:FindObj("QilinBiContent"),
			view = nil,
			view_class = QilinBiContentView,
			flush_params = {["qilinbi"] = true, ["qilinbi_upgrade"] = true, ["qilinbi_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "QilinBiContent"},
			interval_remind_info = {remind_name = RemindName.QilinBi_UpGrade, interval = 3600},
			funopen_name = "appearance_qilinbi",
		},
		[TabIndex.appearance_mask] = {
			tab = self:FindObj("TabMask"),
			toggle = self:FindObj("ToggleMask"),
			event_name = "OpenMask",
			content = self:FindObj("MaskContent"),
			view = nil,
			view_class = MaskContentView,
			flush_params = {["mask"] = true, ["mask_upgrade"] = true, ["mask_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "MaskContent"},
			interval_remind_info = {remind_name = RemindName.Mask_UpGrade, interval = 3600},
			funopen_name = "appearance_mask",
		},
		[TabIndex.appearance_lingzhu] = {
			tab = self:FindObj("TabLingZhu"),
			toggle = self:FindObj("ToggleLingZhu"),
			event_name = "OpenLingZhu",
			content = self:FindObj("LingZhuContent"),
			view = nil,
			view_class =LingZhuContentView,
			flush_params = {["lingzhu"] = true, ["lingzhu_upgrade"] = true, ["lingzhu_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "LingZhuContent"},
			interval_remind_info = {remind_name = RemindName.LingZhu_UpGrade, interval = 3600},
			funopen_name = "appearance_lingzhu",
		},
		[TabIndex.appearance_xianbao] = {
			tab = self:FindObj("TabXianBao"),
			toggle = self:FindObj("ToggleXianBao"),
			event_name = "OpenXianBao",
			content = self:FindObj("XianBaoContent"),
			view = nil,
			view_class = XianBaoContentView,
			flush_params = {["xianbao"] = true, ["xianbao_upgrade"] = true, ["xianbao_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "XianBaoContent"},
			interval_remind_info = {remind_name = RemindName.XianBao_UpGrade, interval = 3600},
			funopen_name = "appearance_xianbao",
		},
		[TabIndex.appearance_linggong] = {
			tab = self:FindObj("TabLingGong"),
			toggle = self:FindObj("ToggleLingGong"),
			event_name = "OpenLingGong",
			content = self:FindObj("LingGongContent"),
			view = nil,
			view_class = LingGongContentView,
			flush_params = {["linggong"] = true, ["linggong_upgrade"] = true, ["linggong_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "LingGongContent"},
			interval_remind_info = {remind_name = RemindName.LingGong_UpGrade, interval = 3600},
			funopen_name = "appearance_linggong",
		},
		[TabIndex.appearance_lingqi] = {
			tab = self:FindObj("TabLingQi"),
			toggle = self:FindObj("ToggleLingQi"),
			event_name = "OpenLingQi",
			content = self:FindObj("LingQiContent"),
			view = nil,
			view_class = LingQiContentView,
			flush_params = {["lingqi"] = true, ["lingqi_upgrade"] = true, ["lingqi_item_change"] = true},
			asset_bundle = {"uis/views/appearance_prefab", "LingQiContent"},
			interval_remind_info = {remind_name = RemindName.LingQi_UpGrade, interval = 3600},
			funopen_name = "appearance_lingqi",
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
		[RemindName.MultiMount] = self:FindVariable("ShowMutliRed"),
		[RemindName.Waist] = self:FindVariable("ShowWaistRed"),
		[RemindName.TouShi] = self:FindVariable("ShowTouShiRed"),
		[RemindName.QilinBi] = self:FindVariable("ShowQilinBiRed"),
		[RemindName.Mask] = self:FindVariable("ShowMaskRed"),
		[RemindName.LingZhu] = self:FindVariable("ShowLingZhuRed"),
		[RemindName.XianBao] = self:FindVariable("ShowXianBaoRed"),
		[RemindName.LingGong] = self:FindVariable("ShowLingGongRed"),
		[RemindName.LingQi] = self:FindVariable("ShowLingQiRed"),
	}
	for k,v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function AppearanceView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function AppearanceView:CloseWindow()
	local show_index = self.show_index or -1
	AppearanceCtrl.Instance:OpenClearBlessView(show_index, function()
		self:Close()
	end)
end

--根据选中的标签强制定位tab列表
function AppearanceView:ForceFixTabList()
	--加延迟防止列表没创建获取的数据是错的
	self.force_fix_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local tab_list = self.other_node_list.tab_list

		local view_cfg_info = self.view_cfg[self.show_index or 0]
		if view_cfg_info then
			local viewport = tab_list.scroll_rect.viewport

			local viewport_height = viewport.rect.height

			local tab = view_cfg_info.tab

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

function AppearanceView:OpenCallBack()
	-- 监听系统事件
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self:ShowOrHideTab()

	--由于右侧标签列表过长，所以打开时要做列表定位处理，防止打开界面时选中的tab看不到
	self:ForceFixTabList()

	--请求协议
	WaistCtrl.Instance:SendYaoShiGetInfo()
	TouShiCtrl.Instance:SendTouShiGetInfo()
	QilinBiCtrl.Instance:SendQilinBiGetInfo()
	MaskCtrl.Instance:SendMaskGetInfo()
	LingZhuCtrl.Instance:SendLingZhuGetInfo()
	XianBaoCtrl.Instance:SendXianBaoGetInfo()
	LingGongCtrl.Instance:SendLingGongGetInfo()
	LingQiCtrl.Instance:SendLingQiGetInfo()
end

function AppearanceView:CloseCallBack()
	if self.force_fix_time_quest then
		GlobalTimerQuest:CancelQuest(self.force_fix_time_quest)
		self.force_fix_time_quest = nil
	end

	local index = self.show_index or 0
	local view_cfg_info = self.view_cfg[index]
	if view_cfg_info and view_cfg_info.view and view_cfg_info.view.CloseView then
		view_cfg_info.view:CloseView()
	end

	AppearanceCtrl.Instance:ClearTipsBlessT()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
end

function AppearanceView:ShowOrHideTab()
	for k, v in pairs(self.view_cfg) do
		v.tab:SetActive(OpenFunData.Instance:FunIsUnLock(v.funopen_name) == true)
	end
end

function AppearanceView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		value = CommonDataManager.ConverMoney(value)

		if attr_name == "bind_gold" then
			self.variable_list.bind_gold:SetValue(value)
		else
			self.variable_list.gold:SetValue(value)
		end
	end
end

function AppearanceView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AppearanceView:ClickTab(tab_index)
	if tab_index == self.show_index then
		return
	end

	self.is_init_toggle = false

	local temp_index = -1
	if self.show_index then
		temp_index = self.show_index
	end
	AppearanceCtrl.Instance:OpenClearBlessView(temp_index, function()
		self:ShowIndex(tab_index)
	end)
end

function AppearanceView:InitAllToggleIsOn()
	for k, v in pairs(self.view_cfg) do
		v.toggle.toggle.isOn = false
	end
end

function AppearanceView:AsyncLoadCallBack(index, obj)
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

function AppearanceView:ShowIndexCallBack(index)
	index = index or 0
	local view_cfg_info = self.view_cfg[index]
	if nil == view_cfg_info then
		local tab_index = TabIndex.appearance_multi_mount
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

	--处理红点问题（做间隔提醒红点，提醒过一次后等待X秒后才再次提醒）
	local remind_info = view_cfg_info.interval_remind_info
	if remind_info and RemindManager.Instance:GetRemind(remind_info.remind_name) > 0 then
		RemindManager.Instance:AddNextRemindTime(remind_info.remind_name, remind_info.interval)
	end

	local asset_bundle_info = view_cfg_info.asset_bundle
	self:AsyncLoadView(index, asset_bundle_info[1], asset_bundle_info[2], self.async_load_call_back)

	view_cfg_info.toggle.toggle.isOn = true
	if view_cfg_info.view then
		view_cfg_info.view:InitView()
	end
end

function AppearanceView:OnFlush(param_t)
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

	if index == TabIndex.appearance_multi_mount then
		view:Flush(param_t)
	end

	local flush_params = view_cfg_info.flush_params

	for k, v in pairs(param_t) do
		if k == "FlsuhAutoBuyToggle" then
			if index == TabIndex.appearance_multi_mount then
				view:FlsuhAutoBuyToggle()
			end

		elseif k == "multi_mount_item_change" then
			if index == TabIndex.appearance_multi_mount then
				view:ItemDataChangeCallback()
			end

		elseif flush_params[k] then
			view:Flush(k, v)
		end
	end
end

function AppearanceView:MultiMountUpgradeResult(result)
	if self.view_cfg and self.view_cfg[TabIndex.appearance_multi_mount].view then
		self.view_cfg[TabIndex.appearance_multi_mount].view:MultiMountUpgradeResult(result)
	end
end

function AppearanceView:ItemDataChangeCallback()
	if self.show_index == TabIndex.appearance_multi_mount then
		self:Flush("multi_mount_item_change")

	elseif self.show_index == TabIndex.appearance_waist then
		self:Flush("waist_item_change")

	elseif self.show_index == TabIndex.appearance_toushi then
		self:Flush("toushi_item_change")

	elseif self.show_index == TabIndex.appearance_qilinbi then
		self:Flush("qilinbi_item_change")

	elseif self.show_index == TabIndex.appearance_mask then
		self:Flush("mask_item_change")

	elseif self.show_index == TabIndex.appearance_lingzhu then
		self:Flush("lingzhu_item_change")

	elseif self.show_index == TabIndex.appearance_xianbao then
		self:Flush("xianbao_item_change")

	elseif self.show_index == TabIndex.appearance_linggong then
		self:Flush("linggong_item_change")

	elseif self.show_index == TabIndex.appearance_lingqi then
		self:Flush("lingqi_item_change")
	end
end