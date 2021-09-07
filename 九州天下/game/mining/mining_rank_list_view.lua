MiningRankListView = MiningRankListView or BaseClass(BaseView)

function MiningRankListView:__init()
	self.ui_config = {"uis/views/mining","MiningRankView"}
	self.cell_list = {}
end

function MiningRankListView:__delete()

end

function MiningRankListView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.scroller = nil
	self.text_title_name = nil
	self.text_my_rank = nil
	self.text_my_score = nil
end

function MiningRankListView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))

	-- 生成滚动条
	self.scroller_data = RankData.Instance:GetRankList()
	self.scroller = self:FindObj("rank_list")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local rank_cell = self.cell_list[cell]
		if rank_cell == nil then
			rank_cell = MiningChallengeRankListItem.New(cell.gameObject)
			rank_cell.root_node.toggle.group = self.scroller.toggle_group
			self.cell_list[cell] = rank_cell
		end

		rank_cell:SetRank(data_index)
		rank_cell:SetData(self.scroller_data[data_index])
	end

	self.text_title_name = self:FindVariable("text_title_name")
	self.text_my_rank = self:FindVariable("text_my_rank")
	self.text_my_score = self:FindVariable("text_my_score")
end

function MiningRankListView:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHTING_CHALLENGE)
end

function MiningRankListView:CloseWindow()
	self:Close()
end

function MiningRankListView:CloseCallBack()
	self.select_index = nil
end

function MiningRankListView:OnFlush()
	local my_rank = RankData.Instance:GetMyInfoList()
	self.scroller_data = RankData.Instance:GetRankList()
	self.scroller.scroller:ReloadData(0)
	my_rank = my_rank >= 1 and my_rank or Language.Mining.NoRank

	self.text_my_rank:SetValue(ToColorStr(my_rank, TEXT_COLOR.GREEN))

	-- 分数展示
	local challenge_base_info = MiningData.Instance:GetFightingChallengeBaseInfo()
	local my_score = challenge_base_info.challenge_score
	self.text_my_score:SetValue(ToColorStr(my_score, TEXT_COLOR.GREEN))
end

----------------------------------------------------------------------------
--MiningChallengeRankListItem 		排行滚动条格子
----------------------------------------------------------------------------

MiningChallengeRankListItem = MiningChallengeRankListItem or BaseClass(BaseCell)

function MiningChallengeRankListItem:__init()
	self.avatar_key = 0
	self.rank = -1

	-- 获取变量
	self.text_name = self:FindVariable("text_name")
	self.text_fighting = self:FindVariable("text_fighting")
	self.text_reputation = self:FindVariable("text_reputation")
	self.text_rank = self:FindVariable("text_rank")
	self.rank_img = self:FindVariable("rank_img")
	self.show_img_1 = self:FindVariable("show_img_1")

	self.item_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		local obj = self:FindObj("Item" .. i)
		item:SetInstanceParent(obj)
		item:SetData(nil)
		-- item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		local item_t = {}
		item_t.item = item
		item_t.obj = obj
		self.item_list[i] = item_t
	end

	-- 监听事件
	--self:ListenEvent("OnClickBtn", BindTool.Bind(self.OnClickBtn, self))
end

function MiningChallengeRankListItem:__delete()
	self.avatar_key = 0

	self.text_name = nil
	self.text_fighting = nil
	self.text_reputation = nil
	self.text_rank = nil
	self.rank_img = nil
	self.show_img_1 = nil
	self.rank = -1

	self.item_list = {}
end

function MiningRankListView:SetData(data)
	self.data = data
	self:Flush()
end

function MiningChallengeRankListItem:OnFlush()
	if not self.data then return end

	self.text_name:SetValue(self.data.user_name)
	local power = string.format(self.data.flexible_int)
	self.text_fighting:SetValue(power)
	self.text_reputation:SetValue(self.data.rank_value)
	local rank_cfg = MiningData.Instance:GetChallengeRewardByRank(self.rank)
	local reward_list = rank_cfg.reward_item or {}
	for i=1,2 do
		local data = reward_list[i - 1]
		if nil == data then
			self.item_list[i].obj:SetActive(false)
		else
			self.item_list[i].obj:SetActive(true)
			self.item_list[i].item:SetData(data)
		end
		
	end

	if self.rank <= 3 then
		local bundle, asset = ResPath.GetMiningRes("rank_" .. self.rank)
		self.rank_img:SetAsset(bundle, asset)
		self.show_img_1:SetValue(true)
		self.text_rank:SetValue("")
	else
		local rank_text = self.rank
		self.text_rank:SetValue(rank_text)
		self.show_img_1:SetValue(false)
	end
end

function MiningChallengeRankListItem:SetRank(rank)
	self.rank = rank
end

function MiningChallengeRankListItem:OnClickBtn()

end