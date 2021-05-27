MaFaExploreRankingView = MaFaExploreRankingView or BaseClass(XuiBaseView)

function MaFaExploreRankingView:__init()
	self.texture_path_list[1] = 'res/xui/rankinglist.png'
	self.config_tab = {
		{"mafa_explore_ui_cfg", 2, {0}},
	}
	
end

function MaFaExploreRankingView:__delete()

end

function MaFaExploreRankingView:ReleaseCallBack()
	if self.mafa_explore_ranking_list then
		self.mafa_explore_ranking_list:DeleteMe()
		self.mafa_explore_ranking_list = nil 
	end
end

function MaFaExploreRankingView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateRankingView()
	end
end

function MaFaExploreRankingView:CreateRankingView()
	if self.mafa_explore_ranking_list == nil then
		local ph = self.ph_list.ph_answer_list
		self.mafa_explore_ranking_list = ListView.New()
		self.mafa_explore_ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MaFaExploreRankingRender, nil, nil, self.ph_list.ph_answer_item)
		self.mafa_explore_ranking_list:GetView():setAnchorPoint(0, 0)
		self.mafa_explore_ranking_list:SetItemsInterval(10)
		self.mafa_explore_ranking_list:SetJumpDirection(ListView.Top)
		self.mafa_explore_ranking_list:SetMargin(3)
		self.node_t_list.layout_ranking_mafa_explore.node:addChild(self.mafa_explore_ranking_list:GetView(), 100)
	end
end

function MaFaExploreRankingView:SetMaFaExploreRankingData()
	local data, my_ranking = ActivityData.Instance:GetRankingListData()
	self.mafa_explore_ranking_list:SetDataList(data)
	local txt = ""
	if my_ranking == 0 then
		txt = Language.Guild.WeiShangBang
	else
		txt = my_ranking
	end
	self.node_t_list.layout_ranking_mafa_explore.txt_my_ranking_explore.node:setString(txt)
end

function MaFaExploreRankingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaExploreRankingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MaFaExploreRankingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新界面
function MaFaExploreRankingView:OnFlush(param_t, index)
	self:SetMaFaExploreRankingData()
end

MaFaExploreRankingRender = MaFaExploreRankingRender or BaseClass(BaseRender)

function MaFaExploreRankingRender:__init()
end

function MaFaExploreRankingRender:__delete()
	
end

function MaFaExploreRankingRender:CreateChild()
	BaseRender.CreateChild(self)
	-- if self.index <= 3 then
	-- 	self.img_bg = XUI.CreateImageView(67, 10, ResPath.GetRankingList("bg_crowns_"..self.index),true)
	-- 	self.view:addChild(self.img_bg, 100)
	-- end
end

function MaFaExploreRankingRender:OnFlush()
	if self.data == nil then return end
	if self.index <= 3 then
		self.node_tree.txt_rank.node:setVisible(false)
		self.node_tree.img_rank.node:setVisible(true)
		self.node_tree.img_rank.node:loadTexture(ResPath.GetRankingList("bg_crowns_"..self.index))
	else
		self.node_tree.txt_rank.node:setVisible(true)
		self.node_tree.img_rank.node:setVisible(false)
		self.node_tree.txt_rank.node:setString(string.format(Language.AllDayActivity.Ranking,self.data.rank))
	end
	self.node_tree.txt_role_name.node:setString(self.data.role_name)
	self.node_tree.txt_step.node:setString(string.format(Language.AllDayActivity.Step,self.data.step))
end