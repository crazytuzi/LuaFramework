ShenGeView = ShenGeView or BaseClass(BaseView)

local SHEN_GE = 1

function ShenGeView:__init()
	self.ui_config = {"uis/views/shengeview_prefab", "ShenGeView"}
	self.play_audio = true
	self.full_screen = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	self.discount_close_time = 0
	self.discount_index = 0
end

function ShenGeView:ReleaseCallBack()
	if self.inlay_view then
		self.inlay_view:DeleteMe()
		self.inlay_view = nil
	end

	if self.bless_view then
		self.bless_view:DeleteMe()
		self.bless_view = nil
	end

	if self.group_view then
		self.group_view:DeleteMe()
		self.group_view = nil
	end

	if self.zhangkong_view then
		self.zhangkong_view:DeleteMe()
		self.zhangkong_view = nil
	end

	if self.godbody_view then
		self.godbody_view:DeleteMe()
		self.godbody_view = nil
	end

	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
	end
	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end

	-- 清理变量
	self.bind_gold = nil
	self.gold = nil
	self.tab_inlay = nil
	self.tab_bless = nil
	self.tab_group = nil
	self.tab_zhangkong = nil
	self.tab_godbody = nil
	self.red_point_list = nil
	self.bless_content = nil
	self.zhang_kong_content = nil
	self.inlay_content = nil
	self.god_body_content = nil
	-- self.show_bipin_icon = nil
	-- self.discount_time = nil
	self.is_hide_zhangkong = nil
	self.IsGodBody = nil
	self.advance_content = nil
	self.tab_advance = nil
end

function ShenGeView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("HandleAddGold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OpenInlay", BindTool.Bind(self.OpenInlay, self))
	self:ListenEvent("OpenBless", BindTool.Bind(self.OpenBless, self))
	self:ListenEvent("OpenGroup", BindTool.Bind(self.OpenGroup, self))
	self:ListenEvent("OpenZhangKong", BindTool.Bind(self.OpenZhangKong, self))
	-- self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OpenGodBody", BindTool.Bind(self.OpenGodBody, self))
	self:ListenEvent("OpenAdvance", BindTool.Bind(self.OpenAdvance, self))

	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")
	-- self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	-- self.discount_time = self:FindVariable("BiPinTime")

	-- 左标签
	self.tab_inlay = self:FindObj("TabInlay")
	self.tab_bless = self:FindObj("TabBless")
	self.tab_group = self:FindObj("TabGroup")
	self.tab_zhangkong = self:FindObj("TabZhangKong")
	self.tab_godbody = self:FindObj("TabGodBody")
	self.tab_advance = self:FindObj("TabAdvance")

	self.inlay_content = self:FindObj("InlayContent")
	self.bless_content = self:FindObj("BlessContent")
	self.zhang_kong_content = self:FindObj("ZhangKongContent")
	self.god_body_content = self:FindObj("GodBodyContent")
	self.advance_content = self:FindObj("AdvanceContent")

	self.red_point_list = {
		[RemindName.ShenGe_ShenGe] = self:FindVariable("InlayRemind"),
		[RemindName.ShenGe_Bless] = self:FindVariable("BlessRemind"),
		[RemindName.ShenGe_Zhangkong] = self:FindVariable("ZhangKongRemind"),
		[RemindName.ShenGe_Godbody] = self:FindVariable("GodBodyRemind"),
		[RemindName.ShenGe_Advance] = self:FindVariable("AdvanceRemind"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.is_hide_zhangkong = self:FindVariable("IsHideZhangkong")
	self.IsGodBody = self:FindVariable("IsGodBody")

	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShenGeView:OpenCallBack()

	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	-- local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(11)
	-- self.discount_index = index
	-- self.show_bipin_icon:SetValue(discount_info ~= nil)
	-- self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	-- if discount_info and self.discount_timer == nil then
	-- 	self:UpdateTimer()
	-- 	self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	-- end
	if OpenFunData.Instance:CheckIsHide("shen_ge_zhangkong") == false then
		self.is_hide_zhangkong:SetValue(false)
	else
		self.is_hide_zhangkong:SetValue(true)
	end

	if OpenFunData.Instance:CheckIsHide("shen_ge_godbody") == false then
		self.IsGodBody:SetValue(false)
	else
		self.IsGodBody:SetValue(true)
	end

	if OpenFunData.Instance:CheckIsHide("shen_ge_advance") == false then
		self.tab_advance:SetActive(false)
	else
		self.tab_advance:SetActive(true)
	end
end

-- function ShenGeView:UpdateTimer()
-- 	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
-- 	if time <= 0 then
-- 		GlobalTimerQuest:CancelQuest(self.discount_timer)
-- 		self.discount_timer = nil
-- 		self.show_bipin_icon:SetValue(false)
-- 	else
-- 		if time > 3600 then
-- 			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 1))
-- 		else
-- 			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 2))
-- 		end
-- 	end
-- end

function ShenGeView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end
function ShenGeView:AsyncLoadView(index)
	if index == TabIndex.shen_ge_inlay and not self.inlay_view then
		UtilU3d.PrefabLoad("uis/views/shengeview_prefab", "InlayContent",
			function(obj)
				obj.transform:SetParent(self.inlay_content.transform, false)
				obj = U3DObject(obj)
				self.inlay_view = ShenGeInlayView.New(obj)
				self.inlay_view:IsBiPin()
				self.inlay_view:Flush()
			end)
	end
	
	if index == TabIndex.shen_ge_bless and not self.bless_view then
		UtilU3d.PrefabLoad("uis/views/shengeview_prefab", "BlessContent",
			function(obj)
				obj.transform:SetParent(self.bless_content.transform, false)
				obj = U3DObject(obj)
				self.bless_view = ShenGeBlessView.New(obj)
				self.bless_view:Flush()
			end)
	end
	if index == TabIndex.shen_ge_zhangkong and not self.zhangkong_view then
		UtilU3d.PrefabLoad("uis/views/shengeview_prefab", "ZhangKongContent",
			function(obj)
				obj.transform:SetParent(self.zhang_kong_content.transform, false)
				obj = U3DObject(obj)
				self.zhangkong_view = ShenGeZhangKongView.New(obj)
				self.zhangkong_view:Flush()
			end)
	end
	if index == TabIndex.shen_ge_godbody and not self.godbody_view then
		UtilU3d.PrefabLoad("uis/views/shengeview_prefab", "GodBodyContent",
			function(obj)
				obj.transform:SetParent(self.god_body_content.transform, false)
				obj = U3DObject(obj)
				self.godbody_view = ShenGeGodBodyView.New(obj)
				self.godbody_view:Flush()
			end)
	end
	if index == TabIndex.shen_ge_advance and not self.advance_view then
		UtilU3d.PrefabLoad("uis/views/shengeview_prefab", "InlayAdvanceContent",
			function(obj)
				obj.transform:SetParent(self.advance_content.transform, false)
				obj = U3DObject(obj)
				self.advance_view = ShenGeAdvanceContent.New(obj)
				self.advance_view:Flush()
			end)
	end


end
function ShenGeView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	if index == TabIndex.shen_ge_inlay then
		self.tab_inlay.toggle.isOn = true
	elseif index == TabIndex.shen_ge_bless then
		self.tab_bless.toggle.isOn = true
	elseif index == TabIndex.shen_ge_group then
		self.tab_group.toggle.isOn = true
	elseif index == TabIndex.shen_ge_zhangkong then
		self.tab_zhangkong.toggle.isOn = true
	elseif index == TabIndex.shen_ge_godbody then
		self.tab_godbody.toggle.isOn = true
	elseif index == TabIndex.shen_ge_compose then
		self:OpenShenGeCompose()
	elseif index == TabIndex.shen_ge_advance then
		self.tab_advance.toggle.isOn = true
	else
		self:ShowIndex(TabIndex.shen_ge_inlay)
	end

	RemindManager.Instance:Fire(RemindName.ShenGe_Bless)
	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)
	RemindManager.Instance:Fire(RemindName.ShenGe_Zhangkong)
	RemindManager.Instance:Fire(RemindName.ShenGe_Godbody)
	RemindManager.Instance:Fire(RemindName.ShenGe_Advance)
end

function ShenGeView:OnClickClose()
	self:Close()
end

function ShenGeView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenGeView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function ShenGeView:OnFlush(param_list)
	if self.tab_inlay.toggle.isOn then
		if nil ~= self.inlay_view then
			self.inlay_view:Flush(param_list)
		end
	elseif self.tab_bless.toggle.isOn then
		if nil ~= self.bless_view then
			self.bless_view:Flush(param_list)
		end
	elseif self.tab_group.toggle.isOn then
		if nil ~= self.group_view then
			self.group_view:Flush(param_list)
		end
	elseif self.tab_zhangkong.toggle.isOn then
		if nil ~= self.zhangkong_view then
			self.zhangkong_view:Flush(param_list)
		end
	elseif self.tab_godbody.toggle.isOn then
		if nil ~= self.godbody_view then
			self.godbody_view:Flush(param_list)
		end
	elseif self.tab_advance.toggle.isOn then
		if nil ~= self.advance_view then
			self.advance_view:OnFlush(param_list)
		end
	end
end

function ShenGeView:OpenInlay()
	self:ShowIndex(TabIndex.shen_ge_inlay)
	if nil ~= self.inlay_view then
		self.inlay_view:Flush()
	end
end

function ShenGeView:OpenBless()
	self:ShowIndex(TabIndex.shen_ge_bless)
	if nil ~= self.bless_view then
		self.bless_view:Flush()
	end
end

function ShenGeView:OpenGroup()
	self:ShowIndex(TabIndex.shen_ge_group)
	if nil ~= self.group_view then
		self.group_view:Flush()
	end
end

function ShenGeView:OpenZhangKong()
	self:ShowIndex(TabIndex.shen_ge_zhangkong)
	if nil ~= self.zhangkong_view then
		self.zhangkong_view:Flush()
	end
end

function ShenGeView:OpenGodBody()
	self:ShowIndex(TabIndex.shen_ge_godbody)
	if nil ~= self.godbody_view then
		self.godbody_view:Flush()
	end
end

function ShenGeView:OpenAdvance()
	self:ShowIndex(TabIndex.shen_ge_advance)
	if nil ~= self.advance_view then
		self.advance_view:Flush()
	end
end

function ShenGeView:OpenShenGeCompose()
	ViewManager.Instance:Open(ViewName.ShenGeComposeView)
end

-- function ShenGeView:OnClickBiPin()
-- 	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
-- end

function ShenGeView:OnDataChange(info_type, param1, param2, param3, bag_list)
	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)
	RemindManager.Instance:Fire(RemindName.ShenGe_Advance)

	if self.tab_inlay.toggle.isOn and nil ~= self.inlay_view then
		self.inlay_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end

	if (self.tab_bless.toggle.isOn or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO) and nil ~= self.bless_view then
		self.bless_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end

	if self.tab_group.toggle.isOn and nil ~= self.group_view then
		self.group_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end

	if self.tab_advance.toggle.isOn and nil ~= self.advance_view then
		self.advance_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end
end

function ShenGeView:UnlockFlag()
	if self.godbody_view then
		self.godbody_view:UnlockFlag()
	end
end

