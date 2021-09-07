SingleRechargeView = SingleRechargeView or BaseClass(BaseView)

function SingleRechargeView:__init()
	self.ui_config = {"uis/views/serveractivity/singlerecharge","SingleRecharge"}
	self.play_audio = true
	self:SetMaskBg()
end

function SingleRechargeView:__delete()

end

function SingleRechargeView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self.rank = self:FindVariable("Rank")
	self.recharge = self:FindVariable("Recharge")
	self:InitScroller()
	self.cell_list = {}
	-- self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))
end

function SingleRechargeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.rank_change_event then
		GlobalEventSystem:UnBind(self.rank_change_event)
		self.rank_change_event = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.rank = nil
	self.recharge = nil
end

function SingleRechargeView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = SingleRechargeData.Instance:GetSingleRechargeCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  SingleRechargeCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function SingleRechargeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO)
	self:Flush()
end

function SingleRechargeView:ShowIndexCallBack(index)

end

function SingleRechargeView:CloseCallBack()

end

function SingleRechargeView:OnFlush(param_t)
	self.data = SingleRechargeData.Instance:GetSingleRechargeCfg()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local rank_type = RankData.Instance:GetRankType()
	local rank = Language.Common.NoRank
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
		local rank_list = RankData.Instance:GetRankList()
		for k,v in pairs(rank_list) do
			if v.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
				rank = k
			end
		end
	end
	self.rank:SetValue(rank)
	self.recharge:SetValue(RechargeRankData.Instance:GetRandActRecharge())
	self.scroller.scroller:RefreshActiveCellViews()
end

function SingleRechargeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time) .. "</color>")
	else
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子

SingleRechargeCell = SingleRechargeCell or BaseClass(BaseCell)

function SingleRechargeCell:__init()
	self.recharge_txt = self:FindVariable("RechargeTxt")
	-- self.name = self:FindVariable("Name")
	-- self.nedd_gold = self:FindVariable("NeedGold")
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
		self.reward_list[i]:IgnoreArrow(true)
	end
	self:ListenEvent("ClickRechange",
		BindTool.Bind(self.ClickRechange, self))

	self.text_reward_gold = self:FindVariable("text_reward_gold")
	self.button = self:FindObj("Button")
	self.has_get = self:FindVariable("has_get")
	self.is_recharge = self:FindVariable("is_recharge")
	self.is_can_get = self:FindVariable("is_can_get")
	self.path_icon = self:FindVariable("path_icon")
	self.show_red_point = self:FindVariable("show_red_point")
end

function SingleRechargeCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	self.text_reward_gold = nil
	self.button = nil
	self.text_btn = nil
	self.has_can_get = nil
	self.path_icon = nil
end

function SingleRechargeCell:OnFlush()
	if nil == self.data then return end
	local config = self.data.config
	local reward_gold = config.reward_gold
	self.text_reward_gold:SetValue(reward_gold)
	self.recharge_txt:SetValue(ToColorStr(config.need_gold, TEXT_COLOR.GREEN))
	local reward_item_list = ItemData.Instance:GetGiftItemList(config.reward_item.item_id)
	self.show_red_point:SetValue(SingleRechargeData.Instance:GetSingleRechargeFlag(config.seq) == 1)
	for i = 1, 4 do
		local cell = self.reward_list[i]
		local data = {}
		if i == 1 then
			data = {is_bind = 1, item_id = 65534, num = reward_gold}
		else
			data = reward_item_list[i - 1]
		end
		if data then
			cell:SetActive(true)
			cell:SetData(data)
		else
			cell:SetActive(false)
		end
	end

	-- 按钮显示
	self.button.button.interactable = self.data.has_can_get_reward == 0
	-- local btn_text = (self.data.is_can_get_reward == 1 or self.data.has_can_get_reward == 1) and Language.Common.LingQu or Language.Common.Recharge
	self.is_recharge:SetValue(self.data.is_can_get_reward == 1 or self.data.has_can_get_reward == 1)
	self.is_can_get:SetValue(self.data.is_can_get_reward == 1)
	self.has_get:SetValue(self.data.has_can_get_reward == 1)

	local icon_name = ""
	if config.seq <= 1 then
		icon_name = "icon_01"
	elseif config.seq <= 3 then
		icon_name = "icon_02"
	else
		icon_name = "icon_03"
	end
	
	--local asset, bundle = ResPath.GetRandomActRes(icon_name)
	--self.path_icon:SetAsset(asset, bundle)
end

function SingleRechargeCell:ClickRechange()
	if self.data.is_can_get_reward == 1 then
		local config = self.data.config
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, 
														RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, config.seq)
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
end