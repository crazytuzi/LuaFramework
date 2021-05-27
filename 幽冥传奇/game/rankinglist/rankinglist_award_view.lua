RankListAwardView = RankListAwardView or BaseClass(XuiBaseView)

function RankListAwardView:__init()
	self.texture_path_list[1] = 'res/xui/rankinglist.png'
	self.is_async_load = false
	self.is_any_click_close = true
	-- self.is_modal = true
	self.config_tab = {
		{"rankinglist_ui_cfg", 3, {0}},
	}

	self.def_index = 1
	self.tabbar = nil
	self.ranking_list = nil 
end

function RankListAwardView:__delete()
end

function RankListAwardView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end
end

function RankListAwardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRankingList()
		self.node_t_list.txt_desc.node:setString(Language.RankingList.AwarDesc)
	end
end

function RankListAwardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
end

function RankListAwardView:ShowIndexCallBack(index)

end

function RankListAwardView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
end

function RankListAwardView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "type" then
			self:FlushRanking(v[1])
		end
	end
end

function RankListAwardView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RankingAwardRender, nil, nil, self.ph_list.ph_rankinglist_item)
		self.ranking_list:SetMargin(1)
		self.ranking_list:SetItemsInterval(3)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_awar_show.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

function RankListAwardView:FlushRanking(type)
	local data = RankingListData.Instance:GetRankShowAwardsByType(type or 0)
	self.ranking_list:SetDataList(data)
end

RankingAwardRender = RankingAwardRender or BaseClass(BaseRender)
function RankingAwardRender:__init()
	self.save_data = {}
end

function RankingAwardRender:__delete()	
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function RankingAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(2)
	self.view:addChild(self.cells_list:GetView(), 90)
	
end

function RankingAwardRender:OnFlush()
	-- if self.index % 2 == 0 then
	-- 	self.node_tree.img_bg.node:loadTexture(ResPath.GetCommon("img9_200"))
	-- end	
	if self.data == nil then return end
	local my_ranking = RankingListData.Instance:GetMyData()
	self.node_tree.txt_rank_des.node:setVisible(my_ranking == self.index)
	local path = my_ranking == self.index and ResPath.GetCommon("stamp_9") or ResPath.GetCommon("stamp_3")
	self.node_tree.img_stamp.node:loadTexture(path)
	self.node_tree.txt_title.node:setString(string.format(Language.RankingList.RankTitle, self.index))
	self.cells_list:SetData(self.data)
end

-- 创建选中特效
function RankingAwardRender:CreateSelectEffect()

end