MoonLightLandingView = MoonLightLandingView or BaseClass(BaseView)

function MoonLightLandingView:__init()
	self.ui_config = {"uis/views/moonlightlanding", "MoonLightLandingView"}
	self.play_audio = true
	self.full_screen = false
	self:SetMaskBg()
	self.cur_logindday = 0
	self.reward = 0
	self.sortljreward = {}
end

function MoonLightLandingView:ReleaseCallBack()
	if self.touzi_cell_list and next(self.touzi_cell_list) then
		for k,v in pairs(self.touzi_cell_list) do
			v:DeleteMe()
		end
		self.touzi_cell_list = {}
	end

	if self.reward then 
		self.reward:DeleteMe()
		self.reward = nil
	end

	self.moonscroller = nil
	self.curlandingtext = nil
	self.isreward = nil
	self.showredpoint = nil
	self.cur_logindday = nil 
	self.anim = nil
	self.sortljreward = {}
end

function MoonLightLandingView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnBtnTips", BindTool.Bind(self.OnBtnTipsHandler, self))
	self:ListenEvent("Reward", BindTool.Bind(self.OnBtnDailyReward, self))

	self.curlandingtext = self:FindVariable("CurLandingText")
	self.isreward = self:FindVariable("IsReward")
	self.showredpoint = self:FindVariable("ShowRedPoint")

	self.reward = ItemCell.New()
	self.reward:SetInstanceParent(self:FindObj("Item2"))

	self.touzi_cell_list = {}
	self.moonscroller = self:FindObj("ListView")
	local delegate = self.moonscroller.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)	

	self.anim = self:FindObj("Anim")
end

function MoonLightLandingView:OpenCallBack()
	MoonLightLandingCtrl.Instance:SendLotteryInfo(RA_LJDL_REQ_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

end

function MoonLightLandingView:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN and status == ACTIVITY_STATUS.CLOSE then
		self:Close()
	end 
end

function MoonLightLandingView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function MoonLightLandingView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.touzi_cell_list[cell]
	if nil == target_cell then
		target_cell = MoonLightItemCell.New(cell.gameObject)
		self.touzi_cell_list[cell] = target_cell
	end
	
	if self.sortljreward and next(self.sortljreward)then
		target_cell:SetIndex(data_index)
		target_cell:SetData(self.sortljreward[data_index])
	end
end

function MoonLightLandingView:OnFlush()
	self.sortljreward = MoonLightLandingData.Instance:SortLjReward()
	if self.moonscroller.scroller.isActiveAndEnabled then
		self.moonscroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushDailyReward()
end

function MoonLightLandingView:FlushDailyReward()
	self.cur_logindday = MoonLightLandingData.Instance:GetCurLogindDay() 
	self.curlandingtext:SetValue(self.cur_logindday)
	self.isreward:SetValue(MoonLightLandingData.Instance:GetDailyRewardIsReceive())
	self.showredpoint:SetValue(MoonLightLandingData.Instance:GetDailyRewardIsReceive())
	
	if self.anim then
		if MoonLightLandingData.Instance:GetDailyRewardIsReceive() == 0 then
			self.anim.animator:SetBool("bool", false)
		else
			self.anim.animator:SetBool("bool", true)
		end
	end

	local data = MoonLightLandingData.Instance:GetMoonLightDaliyCfg()
	if data then
		self.reward:SetData(data)
		self.reward:SetActive(true)
	else
		self.reward:SetData(nil)
		self.reward:SetActive(false)
	end

end

function MoonLightLandingView:GetNumberOfCells()
	local get_actcfg = MoonLightLandingData.Instance:GetMoonLightActivityCfg() or {}
	return #get_actcfg
end

function MoonLightLandingView:OnBtnTipsHandler()
	TipsCtrl.Instance:ShowHelpTipView(262)
end

function MoonLightLandingView:OnBtnDailyReward()
	MoonLightLandingCtrl.Instance:SendLotteryInfo(RA_LJDL_REQ_TYPE.RA_LJDL_REQ_TYPE_FETCH_DAILY_REWARD)
end

----------------------------MoonLightItem-----------------------------------
MoonLightItemCell  = MoonLightItemCell or BaseClass(BaseCell)

function MoonLightItemCell:__init()
	self.cur_logindday = nil 
	self.reward_list = {}

	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))

	self.recharge = self:FindVariable("RechargeTxt")
	self.showred = self:FindVariable("ShowRed")
	self.btnenble = self:FindVariable("BtnEnble")

	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
	end
end

function MoonLightItemCell:__delete()
	if self.reward_list and next(self.reward_list) then
		for k,v in pairs(self.reward_list) do
			v:DeleteMe()
		end
		self.reward_list = {}
	end
	self.recharge = nil
	self.showred = nil 
	self.btnenble = nil
	self.cur_logindday = nil
end

function MoonLightItemCell:OnFlush()
	if self.data == nil and next(self.data) == nil then return end
	
	self.cur_logindday = MoonLightLandingData.Instance:GetCurLogindDay() or 0
	self.btnenble:SetValue(self.data.reward_flag)
	self.recharge:SetValue(string.format(Language.MoonLight.CurDailySpeed,self.cur_logindday,self.data.continue_login_days))
	self.showred:SetValue(self.cur_logindday >= self.data.continue_login_days and self.data.reward_flag == MOONLIGHTLANDING_REWARD_FLAG.NOT_RECEIVED)

	local reward_cfg = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.rewards, true)
	if reward_cfg and next(reward_cfg) then
		for i = 1, 4 do
			if 	reward_cfg[i] then
				self.reward_list[i]:SetData(reward_cfg[i])
				self.reward_list[i]:SetActive(true)
			else
				self.reward_list[i]:SetData(nil)
				self.reward_list[i]:SetActive(false)
			end
		end
	end
end

function MoonLightItemCell:ClickBuy()
	if self.data == nil and next(self.data) == nil then return end
	
	if self.cur_logindday >= self.data.continue_login_days and self.data.reward_flag == MOONLIGHTLANDING_REWARD_FLAG.NOT_RECEIVED then
		MoonLightLandingCtrl.Instance:SendLotteryInfo(RA_LJDL_REQ_TYPE.RA_LJDL_REQ_TYPE_FETCH_REWARD,self.data.continue_login_days)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.MoonLight.Description)
	end
end



