-- 国家战事（搬砖任务界面）
StartBanZhuanView = StartBanZhuanView or BaseClass(BaseView)

function StartBanZhuanView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "StartBanZhuan"}
	self:SetMaskBg()
	self.item_cell = {}
	self.banzhuan_list = {}

	self.max_reward = 5 --最高的奖励
end

function StartBanZhuanView:__delete()

end

function StartBanZhuanView:ReleaseCallBack()
	self.is_double_start = nil
	self.residue_number = nil
	self.button_type = nil
	self.is_highest_reward = nil
	self.reward_color = nil
	self.show_add_btn = nil

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	self.item_cell = {}
	UnityEngine.PlayerPrefs.DeleteKey("double_banzhuan")
end

function StartBanZhuanView:LoadCallBack()
	self.is_double_start = self:FindVariable("IsStart")
	self.residue_number = self:FindVariable("ResidueNumber")
	self.button_type = self:FindVariable("ButtonType")
	self.is_highest_reward = self:FindVariable("IsHighestReward")
	self.reward_color = self:FindVariable("RewardColor")
	self.show_add_btn = self:FindVariable("ShowAddBtn")

	self.key = 0
	self.last_refresh_time = 0

	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	self:ListenEvent("OnClose", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("StartTask", BindTool.Bind(self.OnStartTask, self))
	self:ListenEvent("Explain", BindTool.Bind(self.OnExplain, self))
	self:ListenEvent("AddResidue", BindTool.Bind(self.AddBanZhuanResidue, self))
end

function StartBanZhuanView:OnExplain()
	TipsCtrl.Instance:ShowHelpTipView(182)
end

function StartBanZhuanView:OpenCallBack()
	self:Flush()
end

-- 关闭事件
function StartBanZhuanView:HandleClose()
	ViewManager.Instance:Close(ViewName.StartBanZhuanView)
end

function StartBanZhuanView:AddBanZhuanResidue()
	local other_cfg = NationalWarfareData.Instance:GetBanZhuanOtherCfg()
	if not other_cfg or not next(other_cfg) then return end

	local left_time = NationalWarfareData.Instance:GetBanZhuanLeftTime()
	if left_time > 0 then
		local yes_func = function()
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_BANZHUAN_BUY_TIMES, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)	
		end
		local content = string.format(Language.NationalWarfare.CostGoldBuBanZhuan, other_cfg.buy_need_gold, left_time)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
	else
		local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
		local yes_func = function()
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
			ViewManager.Instance:Open(ViewName.VipView)
		end
		local content = string.format(Language.NationalWarfare.AddBuyTimesDesc, next_vip)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func, nil, nil, Language.Common.Recharge)
	end
end

-- 开始任务
function StartBanZhuanView:OnStartTask()
	if self.banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT then
		local task_view = MainUICtrl.Instance:GetView():GetTaskView()
		if task_view then
			task_view:OperateTask(NationalWarfareData.Instance:GetBanZhuanTaskCfg())
		end
	else
		if NationalWarfareData.Instance:GetBanZhuanState() ~= NationalWarfareData.YunBiaoState.Opening then
			local click_func = function ()
				CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_ACCEPT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
			end
			if UnityEngine.PlayerPrefs.GetInt("double_banzhuan") == 1 then
				click_func()
			else
				TipsCtrl.Instance:ShowCommonTip(click_func, nil, Language.NationalWarfare.DoubleBanZhuanDesc, nil, nil, true, false, "double_banzhuan")
			end
		else
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_ACCEPT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
		end
	end
	self:HandleClose()
end

function StartBanZhuanView:OnFlush()
	self.banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local banzhuan_day_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.banzhuan_list.cur_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
	
	self.residue_number:SetValue(banzhuan_day_count)

	if self.banzhuan_list.task_phase >= CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then
		self.button_type:SetValue(Language.NationalWarfare.BanZhuanFinish)
	else
		self.button_type:SetValue(Language.NationalWarfare.BanZhuanStart)
	end

	if self.banzhuan_list.cur_color ~= 0 then
		self.is_highest_reward:SetValue(true)
		local bundle, asset = ResPath.GetNationalWarfare("word_color_" .. self.banzhuan_list.cur_color)
		self.reward_color:SetAsset(bundle, asset)
	else
		self.is_highest_reward:SetValue(false)
	end
	
	for k,v in pairs(color_cfg) do
		self.item_cell[k]:SetData(v)
	end

	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
	local left_time = NationalWarfareData.Instance:GetBanZhuanLeftTime()
	self.show_add_btn:SetValue(next_vip > 0 or left_time > 0)
end