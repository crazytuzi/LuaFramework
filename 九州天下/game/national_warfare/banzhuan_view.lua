-- 国家战事（搬砖界面）
BanZhuanView = BanZhuanView or BaseClass(BaseRender)

BanZhuanView.CampPost = {true, false, false, false, false, false, false}

function BanZhuanView:__init()
	self.banzhuan_list = {}
end

function BanZhuanView:__delete()
	if self.camp_role_info_change then
		GlobalEventSystem:UnBind(self.camp_role_info_change)
		self.camp_role_info_change = nil
	end
	if self.reward_cell then
		for k, v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
	end	
	self.reward_cell = {}
end

function BanZhuanView:LoadCallBack(instance)
	self.yunbiao_state = self:FindVariable("yunbiao_state")
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
	self.is_banzhuan_click = self:FindVariable("IsBanZhuanClick")

	self.start_task_panel = self:FindObj("StartTaskPanel")
	self.target_arrow = self:FindObj("TargetArrow")

	self:ListenEvent("OnClickStartTask", BindTool.Bind(self.OnClickStartTask, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickTarget", BindTool.Bind(self.OnClickTarget, self))
	self:ListenEvent("OnBtnBanZhuan", BindTool.Bind(self.OnBtnBanZhuan, self))

	self.reward_cell = {}
	for i = 1, 3 do
		self.reward_cell[i] = ItemCell.New()
		self.reward_cell[i]:SetInstanceParent(self:FindObj("cell" .. i))
	end

	self.camp_role_info_change = GlobalEventSystem:Bind(OtherEventType.CAMP_ROLE_INFO, BindTool.Bind(self.CampRoleInfoChange, self))
end

function BanZhuanView:OnClickStartTask()

	local npc_cfg = NationalWarfareData.Instance:GetBanZhuanNpcCfg()
	NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function BanZhuanView:OnClickBuy()
	local other_cfg = NationalWarfareData.Instance:GetBanZhuanOtherCfg()
	local yes_func = function()
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_BANZHUAN_BUY_TIMES, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)	
	end
	local left_time = NationalWarfareData.Instance:GetBanZhuanLeftTime()
	local content = string.format(Language.NationalWarfare.CostGoldBuBanZhuan, other_cfg.buy_need_gold, left_time)
	TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
end

function BanZhuanView:FlushRewardData()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.banzhuan_list.cur_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)

	for k,v in pairs(color_cfg) do
		self.reward_cell[k]:SetData(v)
	end
end

function BanZhuanView:FlushYunBiaoInfo()
	-- self.show_yunbiao_info:SetValue(self.banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT)
end

function BanZhuanView:OnFlush(param_t)
	self.banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	

	local max_accept_times = NationalWarfareData.Instance:GetBanZhuanOtherCfg().max_accept_times
	local accept_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_ACCEPT_TIMES)
	local buy_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES)
	local banzhuan_day_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	local vip_times = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
	
	if self.banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then 
		self.can_banzhuan:SetValue((max_accept_times + buy_times) > accept_times)
	end

	-- 能否购买，下一次购买的vip等级
	self.can_buy:SetValue(vip_times > buy_times)
	self.buy_num_text:SetValue(string.format(Language.NationalWarfare.CanBuyNum, vip_times - buy_times))
	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
	self.show_buy:SetValue(next_vip > 0)
	self.next_vip_text:SetValue(string.format(Language.NationalWarfare.NextAddVip, next_vip))
	self.show_flag:SetValue(self.banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID and (max_accept_times + buy_times) > accept_times)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local pos_list = NationalWarfareCtrl.Instance.data:GetCampObjPos()
	self.start_task_panel.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 50, pos_list[vo.camp].z)

	-- 指向目标
	self.show_target:SetValue(CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID ~= self.banzhuan_list.task_phase)
	if self.banzhuan_list.task_phase ~= CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then
		if CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID == self.banzhuan_list.cur_color then
			self.target_arrow.transform.localPosition = Vector3(pos_list[self.banzhuan_list.task_aim_camp].x, pos_list[self.banzhuan_list.task_aim_camp].y + 35, pos_list[self.banzhuan_list.task_aim_camp].z)
			-- 标题
			local bundle, asset = ResPath.GetNationalWarfare("banzhuan_aim_1")
			self.task_title:SetAsset(bundle, asset)
		else
			self.target_arrow.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 35, pos_list[vo.camp].z)
			-- 标题
			local bundle, asset = ResPath.GetNationalWarfare("banzhuan_aim_2")
			self.task_title:SetAsset(bundle, asset)
		end
	end
	self:FlushRewardData()
	self:CampRoleInfoChange()
end

function BanZhuanView:OnClickTarget()
	local task_view = MainUICtrl.Instance:GetView():GetTaskView()
	if task_view then
		local task_data = NationalWarfareData.Instance:GetBanZhuanTaskCfg()
		task_view:OperateTask(task_data)
	end
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function BanZhuanView:OnBtnBanZhuan()
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Camp.IsOpenBanZhuan, function ()
		CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_BANZHUAN)
	end)
end

function BanZhuanView:CampRoleInfoChange()
	local camp_post = PlayerData.Instance.role_vo.camp_post
	if BanZhuanView.CampPost then
		local day_counter_num = CampData.Instance:GetDayCounterList(2)
		self.is_banzhuan_click:SetValue(BanZhuanView.CampPost[camp_post] and day_counter_num > 0)
	end

	self:FlushBanZhuanState()
end

function BanZhuanView:FlushBanZhuanState()
	local state = NationalWarfareData.Instance:GetBanZhuanState()
	self.yunbiao_state:SetValue(Language.NationalWarfare.BanZhuanState[state])
end