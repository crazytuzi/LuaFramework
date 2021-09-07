-- 国家战事（营救界面） 
YingJiuTaskView = YingJiuTaskView or BaseClass(BaseView)

function YingJiuTaskView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "YingJiuTaskTip"}
	self:SetMaskBg(true)
	self.item_list = {}
end

function YingJiuTaskView:ReleaseCallBack()
	self.task_title = nil
	self.task_desc = nil
	self.task_buy_num = nil
	self.reward_text = nil
	self.top_title = nil
	self.cur_num = nil
	self.total_num = nil
	self.can_buy = nil
	self.yes_btn_gray = nil
	self.yes_btn_obj = nil

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function YingJiuTaskView:LoadCallBack(instance)
	self.task_title = self:FindVariable("TaskTitle")
	self.task_desc = self:FindVariable("TaskDesc")
	self.task_buy_num = self:FindVariable("TaskBuyNum")
	self.reward_text = self:FindVariable("RewardText")
	self.top_title = self:FindVariable("TopTiTle")
	self.cur_num = self:FindVariable("CurNum")
	self.total_num = self:FindVariable("TotalNum")
	self.can_buy = self:FindVariable("CanBuy")
	self.yes_btn_gray = self:FindVariable("YesBtnGray")

	self.yes_btn_obj = self:FindObj("YesBtnObj")

	self:CreateRewared()	

	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickYes", BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
end

function YingJiuTaskView:CreateRewared()
	local reward_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg().rewards
	for i = 0, #reward_cfg do
		local item_obj = self:FindObj("Reward_" .. i)
		if item_obj then
			self.item_list[i] = ItemCell.New()
			self.item_list[i]:SetInstanceParent(item_obj)
			if reward_cfg and reward_cfg[i] then
				self.item_list[i]:SetData(reward_cfg[i])
			end
		end
	end
end

function YingJiuTaskView:OnFlush(param_t)
	local accept_times, buy_times, max_accept_times = NationalWarfareData.GetYingJiuTimes()
	local vip_times = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
	local buy_str = ""
	if (vip_times > buy_times) or (buy_times + max_accept_times - accept_times) > 0 then
		buy_str = string.format(Language.NationalWarfare.TaskCanBuy, (buy_times + max_accept_times - accept_times))
	else
		buy_str = Language.NationalWarfare.TaskMax
	end
	self.task_buy_num:SetValue(buy_str)
	self.yes_btn_gray:SetValue((buy_times + max_accept_times - accept_times) > 0)
	self.yes_btn_obj.button.interactable = (buy_times + max_accept_times - accept_times) > 0

	local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
	self.can_buy:SetValue(next_vip > 0 or vip_times > buy_times)

	self:FlushTaskInfo()
end

function YingJiuTaskView:FlushTaskInfo()
	local task_info = NationalWarfareData.Instance:GetYingJiuInfo()
	local cur_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq(task_info.task_seq)
	local total_cfg = NationalWarfareData.Instance:GetYingJiuCfg()
	if not cur_cfg then return end
	self.task_title:SetValue(cur_cfg.task_name)
	self.task_desc:SetValue(cur_cfg.task_information)
	self.top_title:SetValue(Language.NationalWarfare.YingJiuTitle)
	self.cur_num:SetValue(task_info.task_seq + 1)
	self.total_num:SetValue(#total_cfg)
end

function YingJiuTaskView:CloseCallBack()

end

function YingJiuTaskView:OnClickYes()
	CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_ACCEPT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU)
	self:Close()
	ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_rescue)
end

function YingJiuTaskView:OnClickBuy()
	local other_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg()
	if not other_cfg or not next(other_cfg) then return end

	local left_time = NationalWarfareData.Instance:GetYingJiuLeftTime()
	if left_time > 0 then
		local yes_func = function()
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_YINGJIU_BUY_TIMES)	
		end
		local content = string.format(Language.NationalWarfare.CostGoldYingJiu, other_cfg.buy_need_gold, left_time)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
	else
		local next_vip = VipData.Instance:GetNextVipLevel(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
		local yes_func = function()
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
			ViewManager.Instance:Open(ViewName.VipView)
		end
		local content = string.format(Language.NationalWarfare.AddBuyTimesDesc, next_vip)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func, nil, nil, Language.Common.Recharge)
	end
end