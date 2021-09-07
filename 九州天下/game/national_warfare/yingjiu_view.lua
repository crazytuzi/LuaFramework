-- 国家战事（营救界面）
YingJiuView = YingJiuView or BaseClass(BaseRender)

function YingJiuView:__init()
	self.item_list = {}
end

function YingJiuView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function YingJiuView:LoadCallBack(instance)
	self.can_buy = self:FindVariable("can_buy")
	self.show_buy = self:FindVariable("show_buy")
	self.show_reward = self:FindVariable("show_reward")
	self.next_vip_text = self:FindVariable("next_vip_text")
	self.buy_num_text = self:FindVariable("buy_num_text")
	self.can_yingjiu = self:FindVariable("can_yingjiu")
	self.show_flag = self:FindVariable("show_flag")
	self.show_target = self:FindVariable("ShowTarget")
	self.task_title = self:FindVariable("TaskTitle")

	self.start_task_panel = self:FindObj("StartTaskPanel")
	self.target_arrow = self:FindObj("TargetArrow")

	self:CreateRewared()	

	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickStartTask", BindTool.Bind(self.OnClickStartTask, self))
	self:ListenEvent("OnClickTarget", BindTool.Bind(self.OnClickTarget, self))
end

function YingJiuView:CreateRewared()
	local reward_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg().rewards
	for i = 0, #reward_cfg do
		local item_obj = self:FindObj("Item_" .. i)
		if item_obj then
			self.item_list[i] = ItemCell.New()
			self.item_list[i]:SetInstanceParent(item_obj)
			if reward_cfg and reward_cfg[i] then
				self.item_list[i]:SetData(reward_cfg[i])
			end
		end
	end
end

function YingJiuView:OnFlush(param_t)
	local accept_times, buy_times, max_accept_times = NationalWarfareData.GetYingJiuTimes()
	local yingjiu_info = NationalWarfareData.Instance:GetYingJiuInfo()

	self.show_reward:SetValue((max_accept_times + buy_times) > accept_times or yingjiu_info.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT)
	local vip_times = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)

	self.can_buy:SetValue(vip_times > buy_times)

	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
	self.show_buy:SetValue(next_vip > 0)
	self.next_vip_text:SetValue(string.format(Language.NationalWarfare.NextAddVip, next_vip))
	self.buy_num_text:SetValue(string.format(Language.NationalWarfare.CanBuyNum, vip_times - buy_times))

	self.can_yingjiu:SetValue((max_accept_times + buy_times) > accept_times)

	-- 开始任务位置
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local pos_list = NationalWarfareData.Instance:GetCampObjPos()
	self.start_task_panel.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 50, pos_list[vo.camp].z)

	local yingjiu_info = NationalWarfareData.Instance:GetYingJiuInfo()
	self.show_flag:SetValue(yingjiu_info.task_phase ~= CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID)

	-- 指向目标
	local task_data = NationalWarfareData.Instance:GetYingJiuInfo()
	local task_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq(task_data.task_seq)
	if not task_cfg or not next(task_cfg) then return end
	self.show_target:SetValue(CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT == task_data.task_phase)
	if CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT == task_data.task_phase then
		local aim = NationalWarfareData.SceneId[task_cfg["scene_id_" .. task_data.task_aim_camp]] or task_data.task_aim_camp
		self.target_arrow.transform.localPosition = Vector3(pos_list[aim].x + 3, pos_list[aim].y + 35, pos_list[aim].z)
	end
	-- 标题
	local bundle, asset = ResPath.GetNationalWarfare("yingjiu_stage_" .. task_data.task_seq)
	self.task_title:SetAsset(bundle, asset)
end

function YingJiuView:CloseCallBack()

end

function YingJiuView:OnClickBuy()
	local other_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg()
	if not other_cfg or not next(other_cfg) then return end
	local left_time = NationalWarfareData.Instance:GetYingJiuLeftTime()
	local content = string.format(Language.NationalWarfare.CostGoldYingJiu, other_cfg.buy_need_gold, left_time)
	TipsCtrl.Instance:ShowCommonTip(function ()
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_YINGJIU_BUY_TIMES)
	end, nil, content)
end

function YingJiuView:OnClickStartTask()
	local other_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg()
	if not other_cfg or not next(other_cfg) then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local npc_id = other_cfg["camp" .. main_role_vo.camp .. "_accept_npc"]
	local camp_scene = CampData.Instance:GetCampScene(main_role_vo.camp)
	
	local target_cfg = MainUIViewTaskInfo.GetTargetCfg(camp_scene, "npcs", npc_id)
	if not target_cfg then return end

	MoveCache.end_type = MoveEndType.NpcTask
	MoveCache.param1 = npc_id
	GuajiCache.target_obj_id = npc_id
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	GuajiCtrl.Instance:MoveToPos(camp_scene, target_cfg.x, target_cfg.y, 4, 2, false, scene_key)

	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function YingJiuView:OnClickTarget()
	local yingjiu_info = NationalWarfareData.Instance:GetYingJiuInfo()
	local task_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq(yingjiu_info.task_seq)
	if not task_cfg or not next(task_cfg) then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local param2 = task_cfg["camp" .. main_role_vo.camp .. "_param2"]
	local guaji_type = GuajiType.HalfAuto
	if CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_KILL_MONSTER == param2 then
		guaji_type = GuajiType.Monster
	end

	local task_view = MainUICtrl.Instance:GetView():GetTaskView()
	if task_view then
		GuajiCtrl.Instance:SetGuajiType(guaji_type)
		local task_data = NationalWarfareData.Instance:GetYingJiuInfo()
		task_view:OperateTask(task_data)
	end
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function YingJiuView:GetStartTaskBtn()
	return self.start_task_panel,BindTool.Bind(self.OnClickStartTask, self)
end