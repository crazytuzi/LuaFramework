AncientRelicsView = AncientRelicsView or BaseClass(BaseView)

function AncientRelicsView:__init()
	self.ui_config = {"uis/views/ancientrelics_prefab", "AncientRelicsInfoView"}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.role_attr_change = BindTool.Bind(self.RoleAttrChange,self)
end

function AncientRelicsView:LoadCallBack()
	self:ListenEvent("AddGatherCount", BindTool.Bind(self.AddGatherCount, self))
	self.show_panel = self:FindVariable("ShowPanel")
	self.leave_stone = self:FindVariable("LeaveStone")
	self.cur_gather_count = self:FindVariable("CurGatherCount")
	self.max_gather_count = self:FindVariable("MaxGatherCount")
	self.nomal_count = self:FindVariable("NomalCount")
	self.better_count = self:FindVariable("BetterCount")
	self.best_count = self:FindVariable("bestCount")
	self.cur_color = self:FindVariable("CurColor")
	self.next_time = self:FindVariable("NextTime")
	self.item_name_1 = self:FindVariable("ItemName1")
	self.item_name_2 = self:FindVariable("ItemName2")
	self.item_name_3 = self:FindVariable("ItemName3")
	self.item_color_1 = self:FindVariable("ItemColor1")
	self.item_color_2 = self:FindVariable("ItemColor2")
	self.item_color_3 = self:FindVariable("ItemColor3")

	self.show_first_text = self:FindVariable("ShowFirstText")  --首充之后自动采集
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function AncientRelicsView:__delete()

end
function AncientRelicsView:RoleAttrChange(key, value)
	if key == "vip_level" then
		if value > 0 then
			self.show_first_text:SetValue(false)
		else
			self.show_first_text:SetValue(true)
		end
	end
end
function AncientRelicsView:AddGatherCount()
	local function ok_callback()
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_BUY_GATHER_TIME)
	end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").other[1]
	local str = string.format(Language.AncientRelics.BuyGatherTips, other_cfg.buy_day_gather_num_cost)
	TipsCtrl.Instance:ShowCommonAutoView("ancient_relics_gather_times", str, ok_callback)
end

function AncientRelicsView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.show_panel = nil
	self.leave_stone = nil
	self.cur_gather_count = nil
	self.max_gather_count = nil
	self.nomal_count = nil
	self.better_count = nil
	self.best_count = nil
	self.cur_color = nil
	self.next_time = nil
	self.item_name_1 = nil
	self.item_name_2 = nil
	self.item_name_3 = nil
	self.item_color_1 = nil
	self.item_color_2 = nil
	self.item_color_3 = nil

	self.show_first_text = nil

	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change)
end

function AncientRelicsView:OpenCallBack()
	self:Flush()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if vip_level > 0 then
		self.show_first_text:SetValue(false)
	else
		self.show_first_text:SetValue(true)
	end
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change)
end

function AncientRelicsView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change)
end

function AncientRelicsView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function AncientRelicsView:OnFlush(param_t)
	local info = AncientRelicsData.Instance:GetInfo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").other[1]
	self.leave_stone:SetValue(info.scene_leave_num)
	self.cur_gather_count:SetValue(info.today_gather_times)
	local total_count = other_cfg.role_day_gather_num + info.today_buy_gather_times
	self.max_gather_count:SetValue(total_count)
	self.nomal_count:SetValue(info.normal_item_num)
	self.better_count:SetValue(info.rare_item_num)
	self.best_count:SetValue(info.unique_item_num)
	self.cur_color:SetValue(info.today_gather_times < total_count and "#00ff99" or "#ff0000")

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	if self.next_timer == nil then
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	local gather_reward_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").gather_reward
	for i = 1, 3 do
		if gather_reward_cfg[i] and gather_reward_cfg[i].gather_reward[0] then
			local item = gather_reward_cfg[i].gather_reward[0]
			local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
			if item_cfg then
				self["item_name_" .. i]:SetValue(item_cfg.name)
				self["item_color_" .. i]:SetValue(ITEM_COLOR[item_cfg.color] or ITEM_COLOR[1])
			end
		end
	end
end

function AncientRelicsView:FlushNextTime()
	local info = AncientRelicsData.Instance:GetInfo()
	local time = math.max(info.next_refresh_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.next_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.next_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
end