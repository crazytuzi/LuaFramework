-- 跨服联盟积分排行榜
CrossUnionScoreRankView = CrossUnionScoreRankView or BaseClass(XuiBaseView)

function CrossUnionScoreRankView:__init()
	self.is_async_load = false
	self.is_modal = false
	self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/rankinglist.png'
	self.config_tab = {
		{"cross_union_fight_ui_cfg", 1, {0}},
	}
	self.ranking_list = nil 
end

function CrossUnionScoreRankView:__delete()
end

function CrossUnionScoreRankView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

end

function CrossUnionScoreRankView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRankingList()
		-- local ph = self.ph_list.ph_open_view
		-- self.toggle = XUI.CreateToggleButton(ph.x + 25, ph.y + 30, 56, 56, false, ResPath.GetCommon("btn_down_bg_1"), ResPath.GetCommon("btn_down_bg_1"), "", true)
		-- self.node_t_list.layout_boss_injure_ran.node:addChild(self.toggle, 999)
		-- XUI.AddClickEventListener(self.toggle, BindTool.Bind1(self.LockOpen, self), true)
		local x = HandleRenderUnit:GetWidth()
		local y = HandleRenderUnit:GetHeight()
		self.node_t_list.layout_jifen_ranking.node:setPosition(x*0.4, y/2-50)
	end
end

function CrossUnionScoreRankView:OpenCallBack()
	MagicCityCtrl.Instance:HeroesFightRankDataReq()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossUnionScoreRankView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CrossUnionScoreRankView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossUnionScoreRankView:OnFlush(param_t, index)
	if self.ranking_list then
		local _, _, team_info, data, my_team_id = MagicCityData.Instance:GetHeroesFightRankData()
		local team_info_2 = TableCopy(team_info)
		self.ranking_list:SetDataList(data)
		local my_team_score = 0
		local enemy_team_score = 0
		if team_info_2[my_team_id] then
			local team_data = table.remove(team_info_2, my_team_id)
			my_team_score = team_data.team_score
		end
		for k, v in pairs(team_info_2) do
			enemy_team_score = v.team_score
			break
		end

		self.node_t_list.txt_my_team_score.node:setString(my_team_score)
		self.node_t_list.txt_enemy_team_score.node:setString(enemy_team_score)
	end
end

function CrossUnionScoreRankView:CreateRankingList()
	if self.ranking_list == nil then
		local ph = self.ph_list.ph_heroes_score_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CrossUnionScoreRankRender, nil, nil, self.ph_list.ph_heroes_score_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_jifen_ranking.node:addChild(self.ranking_list:GetView(), 100)
	end
end

CrossUnionScoreRankRender = CrossUnionScoreRankRender or BaseClass(BaseRender)
function CrossUnionScoreRankRender:__init()
	
end

function CrossUnionScoreRankRender:__delete()
end

function CrossUnionScoreRankRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(67, 45, ResPath.GetRankingList("bg_crowns_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function CrossUnionScoreRankRender:OnFlush()
	if self.data == nil then return end 
	local rank = ""
	if self.index > 3 then
		rank = self.index
	end
	local path = "img9_158"
	if self.index % 2 == 0 then
		path = "img9_200"
	end
	self.node_tree.img9_bg.node:loadTexture(ResPath.GetCommon(path))
	self.node_tree.txt_rank.node:setString(rank)
	self.node_tree.txt_name.node:setString(self.data.player_name)
	local color = COLOR3B.RED
	local _, _, _, _, my_team_id = MagicCityData.Instance:GetHeroesFightRankData()
	if self.data.team_id == my_team_id then
		color = COLOR3B.BLUE
	end
	self.node_tree.txt_name.node:setColor(color)
	self.node_tree.txt_score.node:setString(self.data.score)
end