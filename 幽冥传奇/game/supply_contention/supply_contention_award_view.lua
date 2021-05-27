SupplyContentionAwardView = SupplyContentionAwardView or BaseClass(XuiBaseView)

function SupplyContentionAwardView:__init()
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"supply_contention_award_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	-- self.title_img_path = ResPath.GetCommon()

	self.cells_win_list = {}
	self.cells_win_first_list = {}

end

function SupplyContentionAwardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then

		self:UpdateRankList()

		self.node_t_list.txt_win_score.node:setString(SupplyContentionConfig.rankLimit..Language.SupplyContentionAward.Desc_1)

		self:CreateCell(SupplyContentionConfig.winnerAwards,self.cells_win_list,self.node_t_list.winpanel.node);
		self:CreateCell(SupplyContentionConfig.winnerFirst,self.cells_win_first_list,self.node_t_list.winfirstpanel.node);

	end
end

function SupplyContentionAwardView:UpdateRankList()
	if nil == self.rank_item_list then
		local ph = self.ph_list.rank_list
		self.rank_item_list = ListView.New()
		self.rank_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SupplyContentionAwardRender, nil, nil, self.ph_list.rank_item)
		self.rank_item_list:GetView():setAnchorPoint(0, 0)
		self.rank_item_list:SetItemsInterval(5)
		self.rank_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_info.node:addChild(self.rank_item_list:GetView(), 100)
	end

	local rank_cfg_data = SupplyContentionConfig.Awards
	self.rank_item_list:SetDataList(rank_cfg_data or {})
end


function SupplyContentionAwardView:CreateCell(awards_data,list,pane)
	local cell
	local propsId
	local count
	for i, v in ipairs(awards_data) do
		if not list[i] then
			cell = BaseCell.New()
			cell:SetPosition((i - 1) * 100, 0)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0, 0)
			cell:SetCellBg(ResPath.GetCommon("cell_100"))
			pane:addChild(cell:GetView(), 100)
			list[i] = cell
		else
			cell = list[i]	
		end
		if v.type > 0 then
			propsId = ItemData.Instance:GetVirtualItemId(v.type)
			if v.type == tagAwardType.qatAddExp then
				count = ItemData.Instance:CalcuSpecialExpVal(v)
			else
				count = v.count
			end
		else
			propsId	= v.id
			count = v.count
		end 
		cell:SetData({item_id = propsId, num = count, is_bind = v.bind})
	end
end



function SupplyContentionAwardView:__delete()
end

function SupplyContentionAwardView:ReleaseCallBack()
	if self.rank_item_list then
		self.rank_item_list:DeleteMe()
		self.rank_item_list = nil
	end

	for k, v in pairs(self.cells_win_list) do
		v:DeleteMe()
	end
	self.cells_win_list = {}


	for k, v in pairs(self.cells_win_first_list) do
		v:DeleteMe()
	end
	self.cells_win_first_list = {}
end








SupplyContentionAwardRender = SupplyContentionAwardRender or BaseClass(BaseRender)
function SupplyContentionAwardRender:__init()
	self.cells_list = {}
end

function SupplyContentionAwardRender:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
end


function SupplyContentionAwardRender:OnFlush()
	if self.data == nil then return end
	local index = self:GetIndex()
	if index > 3 then
		self.node_tree.txt_rankName.node:setVisible(true)
		self.node_tree.img_rankPic.node:setVisible(false)
		self.node_tree.txt_rankName.node:setString(string.format(Language.SupplyContentionAward.Desc_2,index))
	else
		self.node_tree.txt_rankName.node:setVisible(false)
		self.node_tree.img_rankPic.node:setVisible(true)
		if not self.rank_pic then
			self.rank_pic = XUI.CreateImageView(40,22,ResPath.GetCommon("stage_"..index), true)
			self.rank_pic:setAnchorPoint(0.5, 0.5)
			self.node_tree.img_rankPic.node:addChild(self.rank_pic);
		end	
	end 	
	self.node_tree.txt_scoreText.node:setString(self.data.condition[1]..Language.SupplyContentionAward.Desc_1)

	self:CreateCell(self.data.award)
end


function SupplyContentionAwardRender:CreateCell(awards_data)
	local cell
	local propsId
	local count
	for i, v in ipairs(awards_data) do
		if not self.cells_list[i] then
			cell = BaseCell.New()
			cell:SetPosition((i - 1) * 100, 0)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0, 0)
			cell:SetCellBg(ResPath.GetCommon("cell_100"))
			self.node_tree.itemPane.node:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			cell = self.cell_list[i]	
		end
		if v.type > 0 then
			propsId = ItemData.Instance:GetVirtualItemId(v.type)
			if v.type == tagAwardType.qatAddExp then
				count = ItemData.Instance:CalcuSpecialExpVal(v)
			else
				count = v.count
			end
		else
			propsId	= v.id
			count = v.count
		end 
		cell:SetData({item_id = propsId, num = count, is_bind = v.bind})
	end
end
