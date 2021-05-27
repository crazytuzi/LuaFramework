
MineralContentionView = MineralContentionView or BaseClass(XuiBaseView)

function MineralContentionView:__init()
	self:SetModal(true)
	self.def_index = 1
	self.texture_path_list[1] = "res/xui/magiccity.png"
	self.texture_path_list[2] = "res/xui/rankinglist.png"
	self.texture_path_list[3] = "res/xui/cross_server.png"
	self.title_img_path = ResPath.GetCrossServer("title_mineral")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"mineral_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
end

function MineralContentionView:__delete()

end

function MineralContentionView:ReleaseCallBack()
	if self.ranking_reward_list then
		self.ranking_reward_list:DeleteMe()
		self.ranking_reward_list = nil
	end
	if self.show_jifen_list then
		self.show_jifen_list:DeleteMe()
		self.show_jifen_list = nil 
	end
	if self.reward_canyu_cell ~= nil then
		self.reward_canyu_cell:DeleteMe()
		self.reward_canyu_cell = nil
	end
end

function MineralContentionView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateRankingReward()
		self:CreateShowList()
		self:CreateMyRewardCells()
		self.node_t_list.btn_get_canyu_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
		self.node_t_list.btn_hand_in.node:addClickEventListener(BindTool.Bind(self.HandInMerial, self))
		RichTextUtil.ParseRichText(self.node_t_list.rich_desc_text.node, Language.MagicCity.TipDesc, 22)
		self:CreateTopTitle(Language.OpenLink.MineralContention)
	end
end

function MineralContentionView:CreateMyRewardCells()
	if self.reward_canyu_cell == nil then
		local ph = self.ph_list.ph_rewrd_cell
		self.reward_canyu_cell = BaseCell.New()
		self.reward_canyu_cell:SetPosition(ph.x, ph.y)
		self.reward_canyu_cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_mineral.node:addChild(self.reward_canyu_cell:GetView(), 100)
	end
end

function MineralContentionView:OpenCallBack()
	 MagicCityCtrl.Instance:ReqContentionRankinglistData()
end

function MineralContentionView:GetReward()
	MagicCityCtrl.Instance:ReqGetMyContentionReward()
end

function MineralContentionView:HandInMerial()
	MagicCityCtrl.Instance:ReqHandInShuiJIng()
end

function MineralContentionView:CreateRankingReward()
	if self.ranking_reward_list == nil then
		local ph = self.ph_list.ph_reeard_list
		self.ranking_reward_list = ListView.New()
		self.ranking_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, MineralContentionRender, nil, nil, self.ph_list.ph_list_reward_item)
		self.ranking_reward_list:GetView():setAnchorPoint(0, 0)
		self.ranking_reward_list:SetMargin(2)
		self.ranking_reward_list:SetItemsInterval(5)
		self.ranking_reward_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_mineral.node:addChild(self.ranking_reward_list:GetView(), 100)
	end
end

function MineralContentionView:CreateShowList()
	if self.show_jifen_list == nil then
		local ph = self.ph_list.ph_item_list
		self.show_jifen_list = ListView.New()
		self.show_jifen_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ShowJIfenRender, nil, nil, self.ph_list.ph_list_item)
		self.show_jifen_list:GetView():setAnchorPoint(0, 0)
		self.show_jifen_list:SetMargin(2)
		self.show_jifen_list:SetItemsInterval(5)
		self.show_jifen_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_mineral.node:addChild(self.show_jifen_list:GetView(), 100)
	end
	local cfg = MagicCityData.Instance:GetMyRankingCfg()
	self.show_jifen_list:SetDataList(cfg)
end

function MineralContentionView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MineralContentionView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MineralContentionView:OnFlush(param_list, index)
	local ranking_info = MagicCityData.Instance:GetRankingInfoData()
	self.ranking_reward_list:SetDataList(ranking_info)
	local my_score, my_ranking, reward_state = MagicCityData.Instance:GetMyData()
	self.node_t_list.txt_my_jifen.node:setString(my_score)
	local txt = ""
	if my_ranking == 0 then
		txt = Language.RankingList.MyRanking 
	else
		txt = my_ranking
	end
	self.node_t_list.txt_my_rank.node:setString(txt)
	--参与奖
	local reward = MagicCityData.Instance:GetCanYUJiang()
	self.reward_canyu_cell:SetData({item_id = reward[1] and reward[1].id, num = 1, is_bind =0})
	if my_ranking == 0 or my_ranking > CrossGatherCrystalCfg.RankShowNum then --没有排名或超过排名限制
		self.node_t_list.btn_get_canyu_reward.node:setVisible(true)
		if reward_state == 1 then
			XUI.SetButtonEnabled(self.node_t_list.btn_get_canyu_reward.node, true)
		else
			XUI.SetButtonEnabled(self.node_t_list.btn_get_canyu_reward.node, false)
		end
	else
		self.node_t_list.btn_get_canyu_reward.node:setVisible(false)
	end
end

MineralContentionRender = MineralContentionRender or BaseClass(BaseRender)
function MineralContentionRender:__init()
	
end

function MineralContentionRender:__delete()
	if self.my_reward_cell ~= nil then
		self.my_reward_cell:DeleteMe()
		self.my_reward_cell = nil 
	end
end

function MineralContentionRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(67, 45, ResPath.GetRankingList("bg_crowns_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end	
	if self.my_reward_cell == nil then
		local ph = self.ph_list.ph_rewrd_cell
		self.my_reward_cell = BaseCell.New()
		self.my_reward_cell:SetPosition(ph.x, ph.y)
		self.my_reward_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.my_reward_cell:GetView(), 100)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetMyReward, self))
end

function MineralContentionRender:GetMyReward()
	MagicCityCtrl.Instance:ReqGetMyContentionReward()
end

function MineralContentionRender:OnFlush()
	if self.data == nil then return end 
	if self.index > 3 then
		self.node_tree.txt_my_ranking.node:setString(self.index)
	else
		self.node_tree.txt_my_ranking.node:setString("")
	end
	self.node_tree.txt_name.node:setString(self.data.player_name)
	self.node_tree.txt_score.node:setString(self.data.score)
	self.my_reward_cell:SetData({item_id = self.data.reward[1].id, num = 1, is_bind =0})
	if self.data.fetch_reward == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
	else
		self.node_tree.btn_get_reward.node:setVisible(true)
		if self.data.is_can_reward == 1 then
			XUI.SetButtonEnabled(self.node_tree.btn_get_reward.node, true)
		else
			XUI.SetButtonEnabled(self.node_tree.btn_get_reward.node, false)
		end
	end
end

ShowJIfenRender = ShowJIfenRender or BaseClass(BaseRender)
function ShowJIfenRender:__init()
	
end

function ShowJIfenRender:__delete()
end

function ShowJIfenRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ShowJIfenRender:OnFlush()
	if self.data == nil then return end 
	self.node_tree.txt_jifen.node:setString(string.format(Language.DesertKillGod.ScoreChange, self.data.score))
	self.node_tree.img_bg.node:loadTexture(ResPath.GetMgicCity("img_bg_"..self.index))
end

