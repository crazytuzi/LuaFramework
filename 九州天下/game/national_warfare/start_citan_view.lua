-- 国家战事（搬砖任务界面）
StartCiTanView = StartCiTanView or BaseClass(BaseView)

function StartCiTanView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "StartCiTan"}
	self:SetMaskBg()
	self.item_cell = {}
	self.animation_list = {}
	self.animation_lists = {}
	self.citan_list = {}

	self.max_reward = 5 --最高的奖励
end

function StartCiTanView:__delete()

end

function StartCiTanView:ReleaseCallBack()
	self.citan_state = nil
	self.residue_number = nil
	self.is_highest_reward = nil
	self.reward_color = nil
	self.show_add_btn = nil

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	self.item_cell = {}
end

function StartCiTanView:LoadCallBack()
	self.citan_state = self:FindVariable("CiTanState")
	self.residue_number = self:FindVariable("ResidueNumber")
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

function StartCiTanView:OnExplain()
	TipsCtrl.Instance:ShowHelpTipView(181)
end

function StartCiTanView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
end

function StartCiTanView:ShowIndexCallBack()
	self:Flush()
end

-- 关闭事件
function StartCiTanView:HandleClose()
	ViewManager.Instance:Close(ViewName.StartCiTanView)
end

-- 购买次数
function StartCiTanView:AddBanZhuanResidue()
	local other_cfg = NationalWarfareData.Instance:GetCiTanOtherCfg()
	if not other_cfg or not next(other_cfg) then return end

	local left_time = NationalWarfareData.Instance:GetCiTanLeftTime()
	if left_time > 0 then
		local yes_func = function()
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_CITAN_BUY_TIMES, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)	
		end
		local content = string.format(Language.NationalWarfare.CostGoldStartCiTan, other_cfg.buy_need_gold, left_time)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
	else
		local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_CITAN_TIMES)
		local yes_func = function()
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
			ViewManager.Instance:Open(ViewName.VipView)
		end
		local content = string.format(Language.NationalWarfare.AddBuyTimesDesc, next_vip)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func, nil, nil, Language.Common.Recharge)
	end
end

-- 开始任务
function StartCiTanView:OnStartTask()
	if self.citan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT then
		local task_view = MainUICtrl.Instance:GetView():GetTaskView()
		if task_view then
			task_view:OperateTask(NationalWarfareData.Instance:GetCitanTaskCfg())
		end
	else
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_ACCEPT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN)
	end
	self:HandleClose()
end

function StartCiTanView:OnFlush()
	self.citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local citan_day_count = NationalWarfareData.Instance:GetCampCitanDayCount()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.citan_list.cur_qingbao_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN)
	self.citan_state:SetValue(Language.NationalWarfare.CiTanState)
	self.residue_number:SetValue(citan_day_count)

	if self.citan_list.cur_qingbao_color ~= 0 then
		self.is_highest_reward:SetValue(true)
		local bundle, asset = ResPath.GetNationalWarfare("word_color_" .. self.citan_list.cur_qingbao_color)
		self.reward_color:SetAsset(bundle, asset)
	else
		self.is_highest_reward:SetValue(false)
	end
	
	for k,v in pairs(color_cfg) do
		self.item_cell[k]:SetData(v)
	end

	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
	local left_time = NationalWarfareData.Instance:GetCiTanLeftTime()
	self.show_add_btn:SetValue(next_vip > 0 or left_time > 0)
end