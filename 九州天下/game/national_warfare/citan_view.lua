-- 国家战事（刺探界面）
CiTanView = CiTanView or BaseClass(BaseRender)

function CiTanView:__init()
	self.citan_list = {}
end

function CiTanView:__delete()

end

function CiTanView:LoadCallBack(instance)
	self.can_banzhuan = self:FindVariable("can_banzhuan")
	self.show_flag = self:FindVariable("show_flag")
	self.show_yunbiao_info = self:FindVariable("show_yunbiao_info")
	self.can_buy = self:FindVariable("can_buy")
	self.show_buy = self:FindVariable("show_buy")
	-- self.show_reward = self:FindVariable("show_reward")
	self.next_vip_text = self:FindVariable("next_vip_text")
	self.buy_num_text = self:FindVariable("buy_num_text")
	self.show_target = self:FindVariable("ShowTarget")
	self.task_title = self:FindVariable("TaskTitle")

	self.start_task_panel = self:FindObj("StartTaskPanel")
	self.target_arrow = self:FindObj("TargetArrow")

	self:ListenEvent("OnClickStartTask", BindTool.Bind(self.OnClickStartTask, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickTarget", BindTool.Bind(self.OnClickTarget, self))

	self.reward_cell = {}
	for i = 1, 3 do
		self.reward_cell[i] = ItemCell.New()
		self.reward_cell[i]:SetInstanceParent(self:FindObj("cell" .. i))
	end

end

function CiTanView:OnClickStartTask()
	local npc_cfg = NationalWarfareData.Instance:GetCiTanNpcCfg()
	NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function CiTanView:OnClickBuy()
	local other_cfg = NationalWarfareData.Instance:GetCiTanOtherCfg()
	local yes_func = function()
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_CITAN_BUY_TIMES, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN)	
	end
	local left_time = NationalWarfareData.Instance:GetCiTanLeftTime()
	local content = string.format(Language.NationalWarfare.CostGoldStartCiTan, other_cfg.buy_need_gold, left_time)
	TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
end

function CiTanView:FlushRewardData()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.citan_list.cur_qingbao_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN)

	for k,v in pairs(color_cfg) do
		self.reward_cell[k]:SetData(v)
	end
end

function CiTanView:FlushYunBiaoInfo()
	-- self.show_yunbiao_info:SetValue(self.citan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT)
end

function CiTanView:OnFlush(param_t)
	self.citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local max_accept_times = NationalWarfareData.Instance:GetCiTanOtherCfg().max_accept_times
	local accept_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_ACCEPT_TIMES)
	local buy_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES)
	local banzhuan_day_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	local vip_times = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_CITAN_TIMES)
	
	if self.citan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then 
		self.can_banzhuan:SetValue((max_accept_times + buy_times) > accept_times)
	end

	self.can_buy:SetValue(vip_times > buy_times)
	self.buy_num_text:SetValue(string.format(Language.NationalWarfare.CanBuyNum, vip_times - buy_times))
	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_CITAN_TIMES)
	self.show_buy:SetValue(next_vip > 0)
	
	self.next_vip_text:SetValue(string.format(Language.NationalWarfare.NextAddVip, next_vip))
	self.show_flag:SetValue(self.citan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID and (max_accept_times + buy_times) > accept_times)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local pos_list = NationalWarfareCtrl.Instance.data:GetCampObjPos()
	self.start_task_panel.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 50, pos_list[vo.camp].z)

	-- 指向目标
	self.show_target:SetValue(CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID ~= self.citan_list.task_phase)
	if self.citan_list.task_phase ~= CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then
		if CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID == self.citan_list.cur_qingbao_color then
			self.target_arrow.transform.localPosition = Vector3(pos_list[self.citan_list.task_aim_camp].x, pos_list[self.citan_list.task_aim_camp].y + 35, pos_list[self.citan_list.task_aim_camp].z)
			-- 标题
			local bundle, asset = ResPath.GetNationalWarfare("citan_aim_1")
			self.task_title:SetAsset(bundle, asset)
		else
			self.target_arrow.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 35, pos_list[vo.camp].z)
			-- 标题
			local bundle, asset = ResPath.GetNationalWarfare("citan_aim_2")
			self.task_title:SetAsset(bundle, asset)
		end
	end

	self:FlushRewardData()
	-- self:FlushYunBiaoInfo()
end

function CiTanView:OnClickTarget()
	local task_view = MainUICtrl.Instance:GetView():GetTaskView()
	if task_view then
		local task_data = NationalWarfareData.Instance:GetCitanTaskCfg()
		task_view:OperateTask(task_data)
	end
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function CiTanView:GetStartTaskBtn()
	return self.start_task_panel, BindTool.Bind(self.OnClickStartTask, self)
end