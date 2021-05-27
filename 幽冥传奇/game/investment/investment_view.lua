--超值投资
InvestmentView = InvestmentView or BaseClass(BaseView)
function InvestmentView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_investment")
	self.texture_path_list[1] = "res/xui/investment.png"
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, true, 999},
	}

	self.btn_info = {
		ViewDef.Investment.DailyChange,
		ViewDef.Investment.Investment,
		ViewDef.Investment.Everyrebate,
		ViewDef.Investment.LuxuryGifts,
		ViewDef.Investment.Blessing,
	}
	require("scripts/game/investment/investment_child_view").New(ViewDef.Investment.Investment, self)
	require("scripts/game/charge/charge_everyday_view").New(ViewDef.Investment.DailyChange, self)
	require("scripts/game/investment/investment_rebate_view").New(ViewDef.Investment.Everyrebate, self)
	require("scripts/game/investment/investment_rebate_view").New(ViewDef.Investment.LuxuryGifts, self)
	require("scripts/game/blessing/make_vow_view").New(ViewDef.Investment.Blessing, self)

	self.tabbar = nil
end

function InvestmentView:__delete()
end

--释放回调
function InvestmentView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

--加载回调
function InvestmentView:LoadCallBack(index, loaded_times)
	self:InitTabbar()

	EventProxy.New(InvestmentData.Instance, self):AddEventListener(InvestmentData.RewardChange, BindTool.Bind(self.OnRewardChange, self))
	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function InvestmentView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function InvestmentView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function InvestmentView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			break
		end
	end

	local bool = RemindManager.Instance:GetRemind(RemindName.ChargeEveryDay) > 0
	self.tabbar:SetRemindByIndex(1, bool)
	
	local bool = RemindManager.Instance:GetRemind(RemindName.Investment) > 0
	self.tabbar:SetRemindByIndex(2, bool)

	local bool = RemindManager.Instance:GetRemind(RemindName.EveryDayRebate) > 0
	self.tabbar:SetRemindByIndex(3, bool)

	local bool = RemindManager.Instance:GetRemind(RemindName.LuxuryGifts) > 0
	self.tabbar:SetRemindByIndex(4, bool)

	local bool = RemindManager.Instance:GetRemind(RemindName.CanBlessing) > 0
	self.tabbar:SetRemindByIndex(5, bool)

	self.tabbar:SetToggleVisible(2, InvestmentData.Instance:CheckInvestmentReward())
	self.tabbar:SetToggleVisible(3, InvestmentData.Instance:GetRebateEveryDayIsOpen())

	local cond_id = ViewDef.Investment.LuxuryGifts.v_open_cond
	self.tabbar:SetToggleVisible(4, GameCondMgr.Instance:GetValue(cond_id))
end

--标签栏初始化
function InvestmentView:InitTabbar()
	if nil == self.tabbar then
		local name_list = {}
		for k, v in pairs(self.btn_info) do
			name_list[#name_list + 1] = v.name
		end
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		-- self.tabbar:SetClickItemValidFunc(function(index)
		-- 	return ViewManager.Instance:CanOpen(self.btn_info[index]) 
		-- end)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
			name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
	end
end

--选择标签回调
function InvestmentView:TabSelectCellBack(index)
	if ViewManager.Instance:CanOpen(self.btn_info[index]) then
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	else
		local text = self.btn_info[index].v_open_cond and GameCond[self.btn_info[index].v_open_cond].Tip or ""
		SysMsgCtrl.Instance:FloatingTopRightText(text)
	end
	--刷新标签栏显示
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			break
		end
	end
end

function InvestmentView:RemindChange(remind_name, num)
	if self:IsOpen() then
		if self and self.tabbar then
			if remind_name == RemindName.ChargeEveryDay then
				self.tabbar:SetRemindByIndex(1, num > 0)
			elseif remind_name == RemindName.Investment then
				self.tabbar:SetRemindByIndex(2, num > 0)
			elseif remind_name == RemindName.EveryDayRebate then
				self.tabbar:SetRemindByIndex(3, num > 0)
			elseif remind_name == RemindName.LuxuryGifts then
				self.tabbar:SetRemindByIndex(4, num > 0)
			elseif remind_name == RemindName.CanBlessing then
				self.tabbar:SetRemindByIndex(5, num > 0)
			end
		end
	end
end

function InvestmentView:OnRewardChange()
	if self:IsOpen() then
		-- 超值投资-投资 切面按钮显示
		self.tabbar:SetToggleVisible(2, InvestmentData.Instance:CheckInvestmentReward())

		-- 需要屏蔽时,自动切换到第一个面板
		if self:IsOpen(self.btn_info[2]) and not InvestmentData.Instance:CheckInvestmentReward() then
			self:TabSelectCellBack(1)
		end
	end
end
