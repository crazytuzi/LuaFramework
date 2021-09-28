-- 积分面板
FishingTablePanelView = FishingTablePanelView or BaseClass(BaseRender)

function FishingTablePanelView:__init()
	self.obj_score_animator = false

	-- 监听UI事件
	self:ListenEvent("OnClickScore", BindTool.Bind(self.OnClickScoreHandler, self))
	self:ListenEvent("OnClickReceivebtn", BindTool.Bind(self.OnClickReceivebtn, self))
	self.obj_score_info = self:FindObj("ScoreInfo")
	self.obj_score_info_animator = self.obj_score_info.animator
	self.obj_btn_arrows = self:FindObj("BtnArrows")

	self.obj_score_rank = self:FindObj("ScoreRank")
	self.obj_score_rank_animator = self.obj_score_rank.animator

	self.parent_item_cell = self:FindObj("ItemCellLeft")
	self.item_cell_list = nil
	-- self.item_cell_left = ItemCell.New()
	-- self.item_cell_left:SetInstanceParent(self:FindObj("ItemCellLeft"))

	-- self.item_cell_right = ItemCell.New()
	-- self.item_cell_right:SetInstanceParent(self:FindObj("ItemCellRight"))
	
	-- 获取变量
	self.lbl_next_stage = self:FindVariable("LabelNextStage")
	self.lbl_my_stealed = self:FindVariable("LabelMyStealed")
	self.lbl_my_steal = self:FindVariable("LabelMySteal")

	self.button = self:FindVariable("Button")
	self.text = self:FindVariable("Text")

	self.lbl_ranking = self:FindVariable("Ranking")
	self.lbl_rank = self:FindVariable("Rank")
	self.lbl_name = self:FindVariable("Name")
	self.lbl_score = self:FindVariable("Score")
	self.show_no_rank_text = self:FindVariable("ShowNoRankText")

	--监听UI事件
	-- self:ListenEvent("OnClose", BindTool.Bind(self.OnCloseHandler, self))
	----------------------------------------------------
	-- 列表生成日志滚动条
	self.fishing_rank_cell_list = {}
	self.rank_listview_data = {}
	self.rank_list = self:FindObj("RankList")
	local rank_list_delegate = self.rank_list.list_simple_delegate
	--生成数量
	rank_list_delegate.NumberOfCellsDel = function()
		return #self.rank_listview_data or 0
	end
	--刷新函数
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingRankListView, self)	
end

function FishingTablePanelView:__delete()
	if self.item_cell_left then
		self.item_cell_left:DeleteMe()
		self.item_cell_left = nil
	end

	if self.item_cell_right then
		self.item_cell_right:DeleteMe()
		self.item_cell_right = nil
	end
	

	if self.fishing_rank_cell_list then
		for k,v in pairs(self.fishing_rank_cell_list) do
			v:DeleteMe()
		end
	end
	self.fishing_rank_cell_list = {}

	self.lbl_ranking = nil
	self.lbl_rank = nil
	self.lbl_name = nil
	self.lbl_score = nil
	self.button = nil
	self.text = nil

	self.rank_list = nil
	self.show_no_rank_text = nil
end

function FishingTablePanelView:LoadCallBack(instance)
	----------------------------------------------------
	self:Flush()
end

function FishingTablePanelView:OnFlush(param_list)
	local fishing_score_info = CrossFishingData.Instance:GetFishingScoreStageInfo()
	local user_info = CrossFishingData.Instance:GetFishingUserInfo()
	local steal_count = CrossFishingData.Instance:GetFishingOtherCfg().steal_count
	local be_stealed_count = CrossFishingData.Instance:GetFishingOtherCfg().be_stealed_count
	local score_reward_cfg = CrossFishingData.Instance:GetFishingScoreRewardCfgByStage(fishing_score_info.cur_score_stage)
	if not score_reward_cfg then
		self.button.grayscale.GrayScale = 255
		self.text.grayscale.GrayScale = 255
		score_reward_cfg = CrossFishingData.Instance:GetFishingScoreRewardCfgByStage(#CrossFishingData.Instance:GetFishingCfg().score_reward - 1)
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = CommonDataManager.GetExpNumber(score_reward_cfg.exp_reward or 0, main_vo.level)
	
	local item = {}
	for k, v in pairs(score_reward_cfg.reward_item) do
		table.insert(item, v)
	end
	table.insert(item, {item_id = ResPath.CurrencyToIconId.exp or 0,num = exp,is_bind = 0})

	self:InitItemCell(GetListNum(item))
	for i = 1, GetListNum(item) do
		if item[i] then
			self.item_cell_list[i]:SetData(item[i])
		end
	end
	-- for 
	-- if self.item_cell_left then
	-- 	self.item_cell_left:SetData({item_id = ResPath.CurrencyToIconId.exp or 0,num = exp,is_bind = 0})
	-- end

	-- self.parent_item_cell

	-- if self.item_cell_right then
	-- 	self.item_cell_left:SetData({item_id = ResPath.CurrencyToIconId.exp or 0,num = exp,is_bind = 0})
	-- end
	
	local text_color = 	fishing_score_info.fishing_score < score_reward_cfg.need_score and COLOR.RED or COLOR.FISHING
	self.lbl_next_stage:SetValue(string.format(Language.Fishing.LabelNextStage, text_color, fishing_score_info.fishing_score, score_reward_cfg.need_score))
	self.lbl_my_stealed:SetValue(string.format(Language.Fishing.LabelMyStealed, user_info.be_stealed_fish_count or 0 , be_stealed_count))
	self.lbl_my_steal:SetValue(string.format(Language.Fishing.LabelMySteal, (steal_count - user_info.steal_fish_count)))

	self:OnFlushRank()
end

function FishingTablePanelView:InitItemCell(index)
	if nil ~= self.item_cell_list then
		return
	end
	self.item_cell_list = {}
	for i = 1, index do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.parent_item_cell)
		self.item_cell_list[i] = item_cell
	end
end

function FishingTablePanelView:OnFlushRank()
	-- 设置排行榜list数据
	local rank_info = CrossFishingData.Instance:GetCrossFishingScoreRankList()
	self.rank_listview_data = rank_info.fish_rank_list
	-- if self.rank_list.scroller.isActiveAndEnabled then
		self.rank_list.scroller:ReloadData(0)
	-- end

	-- 自己的排行信息
	local my_rank_data = CrossFishingData.Instance:GetMyRankInfo()
	if not next(my_rank_data) then
		self.show_no_rank_text:SetValue(true)
		return
	end
	self.show_no_rank_text:SetValue(false)
	self.lbl_ranking:SetValue(my_rank_data.rank_index)
	-- if my_rank_data.rank_index <= 3 and my_rank_data.rank_index > 0 then
	-- 	local bundle, asset = ResPath.GetRankIcon(my_rank_data.rank_index)
	-- 	self.lbl_rank:SetAsset(bundle, asset)
	-- end
	self.lbl_name:SetValue(my_rank_data.user_name)
	self.lbl_score:SetValue(my_rank_data.total_score)
end

-- 日志列表listview
function FishingTablePanelView:RefreshFishingRankListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local rank_cell = self.fishing_rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = FishingRankItemRender.New(cell.gameObject)
		self.fishing_rank_cell_list[cell] = rank_cell
	end
	rank_cell:SetIndex(data_index)
	rank_cell:SetData(self.rank_listview_data[data_index])
end

function FishingTablePanelView:OnClickScoreHandler()
	self.obj_score_animator = not self.obj_score_animator
	self.obj_btn_arrows.transform.localScale = Vector3(self.obj_score_animator and 1 or -1, 1, 1)
	self.obj_score_info_animator:SetBool("fold", self.obj_score_animator)
	self.obj_score_rank_animator:SetBool("fold", self.obj_score_animator)
end

function FishingTablePanelView:OnClickReceivebtn()
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_SCORE_REWARD)
end
----------------------------------------------------------------------------
--FishingRankItemRender	钓鱼排行榜itemder
----------------------------------------------------------------------------
FishingRankItemRender = FishingRankItemRender or BaseClass(BaseCell)
function FishingRankItemRender:__init()
	self.lbl_ranking = self:FindVariable("Ranking")
	self.lbl_rank = self:FindVariable("Rank")
	self.lbl_name = self:FindVariable("Name")
	self.lbl_score = self:FindVariable("Score")
end

function FishingRankItemRender:__delete()
end

function FishingRankItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	
	self.lbl_ranking:SetValue(self.data.rank_index)
	-- if self.data.rank_index <= 3 then
	-- 	local bundle, asset = ResPath.GetRankIcon(self.data.rank_index)
	-- 	self.lbl_rank:SetAsset(bundle, asset)
	-- end

	self.lbl_name:SetValue(self.data.user_name)
	self.lbl_score:SetValue(self.data.total_score)
end
