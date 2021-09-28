RechargeRankView = RechargeRankView or BaseClass(BaseView)

function RechargeRankView:__init()
	self.ui_config = {"uis/views/randomact/rechargerank_prefab","RechargeRank"}
	self.play_audio = true
	self.cell_list = {}
end

function RechargeRankView:__delete()

end

function RechargeRankView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self.rank = self:FindVariable("Rank")
	self.recharge = self:FindVariable("Recharge")
	self:InitScroller()
	self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))
end

function RechargeRankView:ReleaseCallBack()
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

function RechargeRankView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = RechargeRankData.Instance:GetRechargeRankCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  RechargeRankCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function RechargeRankView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE)
	self:Flush()
end

function RechargeRankView:OnRankChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
		self:Flush()
	end
end

function RechargeRankView:ShowIndexCallBack(index)

end

function RechargeRankView:CloseCallBack()

end

function RechargeRankView:OnFlush(param_t)
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
		local rank_list = RankData.Instance:GetNameList()
		for k,v in pairs(rank_list) do
			if v.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
				rank = k
			end
		end
	end
	self.rank:SetValue(rank)
	self.recharge:SetValue(RechargeRankData.Instance:GetRandActRecharge())
end

function RechargeRankView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_CHONGZHI_RANK)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 6))
	elseif time > 3600 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
end

---------------------------------------------------------------
--滚动条格子

RechargeRankCell = RechargeRankCell or BaseClass(BaseCell)

function RechargeRankCell:__init()
	self.recharge_txt = self:FindVariable("RechargeTxt")
	self.name = self:FindVariable("Name")
	self.nedd_gold = self:FindVariable("NeedGold")
	self.num = 0
	self.is_show = self:FindVariable("IsShow")
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
		self.reward_list[i]:IgnoreArrow(true)
	end
	self:ListenEvent("ClickRechange",
		BindTool.Bind(self.ClickRechange, self))
end

function RechargeRankCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	self.is_show = nil
end

function RechargeRankCell:OnFlush()
	if nil == self.data then return end
	local name = ""
	if self.data.rank_index < 3 then
		 local rank_type = RankData.Instance:GetNameList()
		-- if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_RAND_RECHARGE then
		-- 	local rank_list = RankData.Instance:GetRankList()
		-- 	if rank_list[self.data.rank_index + 1] then
		-- 		name = rank_list[self.data.rank_index + 1].user_name
		-- 	end
		-- end
		if rank_type[self.data.rank_index + 1] then
			name = rank_type[self.data.rank_index + 1].user_name
			self.is_show:SetValue(true)
		end
	end
	if name == "" then
		self.is_show:SetValue(false)
	end
	self.name:SetValue(name)
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v:ShowGetEffect(item_list[k] ~= nil and self.data.rank_index < 3 and k == 1)
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.recharge_txt:SetValue(self.data.need_rank)
	self.nedd_gold:SetValue(self.data.limit_chongzhi)
end

function RechargeRankCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RechargeRankCell:SetCellIndex(num)
	self.num = num
end
