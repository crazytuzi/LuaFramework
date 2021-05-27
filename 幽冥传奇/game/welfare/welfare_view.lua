
-- 福利大厅
WelfareView = WelfareView or BaseClass(BaseView)

function WelfareView:__init()
	self.title_img_path = ResPath.GetWord("word_welfare")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		"res/xui/bag.png"
	}
	self.remind_temp = {}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"welfare_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil , 999},
	}

	require("scripts/game/welfare/daily_sign_in_view").New(ViewDef.Welfare.DailyRignIn, self)
	require("scripts/game/welfare/online_reward_view").New(ViewDef.Welfare.OnlineReward, self)
	require("scripts/game/welfare/welfare_gift_view").New(ViewDef.Welfare.Gift, self)
	-- require("scripts/game/welfare/update_affiche_view").New(ViewDef.Welfare.UpdateAffiche, self)
	require("scripts/game/welfare/welfare_findres_view").New(ViewDef.Welfare.Findres, self)
	-- require("scripts/game/welfare/wechat_attention_view").New(ViewDef.Welfare.WechatAttention, self)

	self.tabbar = nil
	self.item_config_bind = BindTool.Bind(self.ItemConfigCallBack, self)
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	-- self.add_sign_reward_tips = AddSignRewardTipsView.New()
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function WelfareView:__delete()
	self.tabbar = nil
end

function WelfareView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	WelfareData.Instance:UpdateSignInData()

	--self:GetRootNode():setBackGroundColor(COLOR3B.BLUE)
end

function WelfareView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.node_t_list.layout_daily_sign_in then
		self.node_t_list.layout_daily_sign_in.can_jump = 1
	end
	-- if self.node_t_list.btn_buy_financing then
	-- 	self.node_t_list.btn_buy_financing.can_jump = 1
	-- end
	self.is_max_level_flush = false
end

function WelfareView:ReleaseCallBack()

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	end

	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
	end
end

function WelfareView:LoadCallBack(index, loaded_times)
local btn_info
	if IS_AUDIT_VERSION then
		 btn_info = {ViewDef.Welfare.DailyRignIn,}
	else
		btn_info = {
			ViewDef.Welfare.DailyRignIn, 
			ViewDef.Welfare.OnlineReward, 
			ViewDef.Welfare.Findres, 
			ViewDef.Welfare.Gift, 
			-- ViewDef.Welfare.UpdateAffiche,
		}
	end
	local name_list = {}
	for k, v in pairs(btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = ScrollTabbar.New()
	self.tabbar.space_interval_V = 1
	self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 7, -3, function (index)
		ViewManager.Instance:OpenViewByDef(btn_info[index])
		self.tabbar:ChangeToIndex(index)
	end, name_list, true, ResPath.GetCommon("toggle_120"), 20)


	local welfare_data_event_proxy = EventProxy.New(WelfareData.Instance, self)
	welfare_data_event_proxy:AddEventListener(WelfareData.DAILY_SIGN_IN_HAVEREWARD, BindTool.Bind(self.ShowSignInCanGetReward, self))
	welfare_data_event_proxy:AddEventListener(WelfareData.ONLINE_HAVEREWARD, BindTool.Bind(self.ShowOnlineCanGetReward, self))
	welfare_data_event_proxy:AddEventListener(WelfareData.FINDRES_COUNT, BindTool.Bind(self.ShowFindres, self))

	self:ShowSignInCanGetReward(WelfareData.Instance:UpdateSignInData())
	self:ShowOnlineCanGetReward(WelfareData.Instance:GetOnlineState())
	self:ShowFindres()
end

function WelfareView:ShowOnlineCanGetReward(falg)
	self.tabbar:SetRemindByIndex(2, falg, ResPath.GetCommon("stamp_receive"), 154, 35)
end

function WelfareView:ShowSignInCanGetReward(falg)
	self.tabbar:SetRemindByIndex(1, falg, ResPath.GetCommon("stamp_receive"), 154, 35)
end

function WelfareView:ShowFindres()
	self.tabbar:SetRemindByIndex(3, WelfareData.Instance:FindresShow() > 0)
	self.tabbar:SetToggleVisible(3, WelfareData.Instance:FindresShow() > 0)
end

function WelfareView:ShowIndexCallBack(index)
	
	if index ~= TabIndex.welfare_daily_sign_in and self.node_t_list.layout_daily_sign_in then
		self.node_t_list.layout_daily_sign_in.can_jump = 1
	end


	if index == TabIndex.welfare_online_reward then
		WelfareCtrl.OnlineRewardInfoReq()
	end

	self:Flush(index)
	self.tabbar:ChangeToIndex(1)
end


function WelfareView:FlushTabRemind()
	if self.tabbar == nil then return end
	for i,v in pairs(self.remind_temp) do
		self.tabbar:SetRemindByIndex(i, v > 0, ResPath.GetCommon("stamp_receive"), 105, 67)
	end
end

function WelfareView:RemindChange(remind_name, num)
	if remind_name == RemindName.SignInReward then
		self.remind_temp[TabIndex.welfare_daily_sign_in] = num
	elseif remind_name == RemindName.OnlineReward then
		self.remind_temp[TabIndex.welfare_online_reward] = num
	end
	self:Flush(0, "remind")
end

function WelfareView:OnFlush(param_t, index)
end

function WelfareView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

function WelfareView:RoleDataChangeCallback(key, value, old_value)

end

function WelfareView:ItemConfigCallBack()
	self:Flush({TabIndex.welfare_online_reward})
end