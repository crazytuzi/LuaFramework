YiZhanDaoDiView = YiZhanDaoDiView or BaseClass(BaseView)

function YiZhanDaoDiView:__init()
	self.ui_config = {"uis/views/yizhandaodiview_prefab","YiZhanDaoDiView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.rank_count = 0
	self.active_close = false
	self.fight_info_view = true
end

function YiZhanDaoDiView:__delete()

end

function YiZhanDaoDiView:LoadCallBack()
	self.cell_list = {}

	self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickReward",BindTool.Bind(self.OnClickReward, self))
	self:ListenEvent("OnClickRank",BindTool.Bind(self.OnClickRank, self))

	self.show_info = self:FindVariable("ShowPanel")
	self.cur_kill_num = self:FindVariable("CurKill")
	self.cur_rank = self:FindVariable("CurRank")
	self.cur_reward = self:FindVariable("CurReward")
	self.next_reward = self:FindVariable("NextReward")
	self.add_gongji_percent = self:FindVariable("AddPercent")
	self.cur_score = self:FindVariable("Score")
	self.rest_times = self:FindVariable("RestTImes")
	self.die_count = self:FindVariable("DieCount")
	self.is_first = self:FindVariable("IsFirst")

	self.item_list = {}
	for i=1,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)

	self.reward_toggle = self:FindObj("RewardToggle")
	self.rank_toggle = self:FindObj("RankToggle")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

end

function YiZhanDaoDiView:OpenCallBack()
	self.reward_toggle.toggle.isOn = true
	self.rank_count = #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()
	self:Flush()
end

function YiZhanDaoDiView:CloseCallBack()
end

function YiZhanDaoDiView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.item_list = {}

	-- 清理变量
	self.show_info = nil
	self.cur_kill_num = nil
	self.cur_rank = nil
	self.cur_reward = nil
	self.next_reward = nil
	self.add_gongji_percent = nil
	self.cur_score = nil
	self.rest_times = nil
	self.is_first = nil

	self.list_view = nil
	self.reward_toggle = nil
	self.rank_toggle = nil
	self.die_count = nil
end

function YiZhanDaoDiView:SwitchButtonState(enable)
	self.show_info:SetValue(enable)
end

function YiZhanDaoDiView:GetRankNumberOfCells()
	return #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()
end

function YiZhanDaoDiView:RefreshRankCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = YiZhanDaoDiRankCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data = YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()[data_index + 1]
	group_cell:SetData(data, data_index)
end

function YiZhanDaoDiView:OnClickBuy()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil == other_cfg then return end

	if user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per then
		TipsCtrl.Instance:ShowSystemMsg(Language.YiZhanDaoDi.MaxGuWu)
		return
	end

	local func = function()
		YiZhanDaoDiCtrl.Instance:SendYiZhanDaoDiGuwuReq(YIZHANDAODI_GUWU_TYPE.YIZHANDAODI_GUWU_TYPE_GONGJI)
	end
	local cost_gold = other_cfg.gongji_guwu_gold
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.YiZhanDaoDi.BuyGongJiTip, cost_gold), nil, nil, true, false, "buy_yzdd_gongji", false, "", "", false, nil, true, Language.Common.Cancel, nil, true)
end

function YiZhanDaoDiView:OnClickReward()
	self:SetRewardPanelInfo()
end

function YiZhanDaoDiView:OnClickRank()
	self:FlushRankList()
end

function YiZhanDaoDiView:FlushRankList()
	if self.list_view.scroller.isActiveAndEnabled then
		if self.rank_count ~= #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo() then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function YiZhanDaoDiView:SetRewardPanelInfo()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	self.cur_kill_num:SetValue(user_info.jisha_count)

	local is_in_rank, rank_index = YiZhanDaoDiData.Instance:IsUserInRank()
	self.cur_rank:SetValue(is_in_rank and rank_index or Language.YiZhanDaoDi.NoInRank)

	local rank_reward_cfg = YiZhanDaoDiData.Instance:GetKillRankRewardCfg()
	if nil ~= rank_reward_cfg then
		local reward_cfg_index = is_in_rank and rank_index or YIZHANDAODI_RANK_NUM + 1
		local next_reward_cfg_index = is_in_rank and (rank_index - 1) or YIZHANDAODI_RANK_NUM

		if nil ~= rank_reward_cfg[reward_cfg_index] then
			local reward_item = rank_reward_cfg[reward_cfg_index].reward_item
			if nil ~= reward_item then
				self.item_list[1]:SetData(reward_item)
			end

			-- 下一排名奖励
			local next_reward_cfg = rank_reward_cfg[next_reward_cfg_index]
			if nil == next_reward_cfg then
				self.is_first:SetValue(true)
			else
				self.is_first:SetValue(false)
				local next_reward_item = next_reward_cfg.reward_item
				if nil ~= next_reward_item then
					self.item_list[2]:SetData(next_reward_item)
				end
			end
		end
	end
	self.add_gongji_percent:SetValue(user_info.gongji_guwu_per)
	self.cur_score:SetValue(user_info.jisha_score)

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}
	self.rest_times:SetValue((other_cfg.dead_max_count or 0) - user_info.dead_count)
	self.die_count:SetValue(string.format(Language.YiZhanDaoDi.DieCount,other_cfg.dead_max_count))
end

function YiZhanDaoDiView:OnFlush(param_t)
	if self.reward_toggle.toggle.isOn then
		self:SetRewardPanelInfo()
	else
		self:FlushRankList()
	end
end


YiZhanDaoDiRankCell = YiZhanDaoDiRankCell or BaseClass(BaseRender)

function YiZhanDaoDiRankCell:__init(instance)
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.kill_num = self:FindVariable("KillNum")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.item.root_node.transform:SetLocalScale(0.6, 0.6, 0.6)
end

function YiZhanDaoDiRankCell:__delete()
	self.item:DeleteMe()
end

function YiZhanDaoDiRankCell:SetData(data, rank_index)
	if nil == data then return end
 
 	local cfg = YiZhanDaoDiData.Instance:GetKillRankRewardCfg()
	self.rank:SetValue(rank_index + 1)
	self.name:SetValue(data.user_name)
	self.kill_num:SetValue(data.jisha_count)
	if cfg and cfg[rank_index + 1] then

		self.item:SetData(cfg[rank_index + 1].reward_item)
	else
		self.item.root_node:SetActive(false)
	end
end