XuKongRankingView = XuKongRankingView or BaseClass(XuiBaseView)

function XuKongRankingView:__init()
	self.texture_path_list[1] = 'res/xui/magiccity.png'
	self.texture_path_list[2] = 'res/xui/rankinglist.png'
	self.is_modal = true	
	self.config_tab = {
		{"magic_city_ui_cfg", 3, {0}},
	}
end

function XuKongRankingView:__delete()
end

function XuKongRankingView:ReleaseCallBack()
	if self.xk_ranking_list ~= nil then
		self.xk_ranking_list:DeleteMe()
		self.xk_ranking_list = nil 
	end
end

function XuKongRankingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRanking()
		self.node_t_list.btn_ranking_tip.node:setVisible(false)
		XUI.AddClickEventListener(self.node_t_list.btn_ranking_tip.node, BindTool.Bind1(self.OnRankingTipDesc, self))
	end
end

function XuKongRankingView:OpenCallBack()
	--MagicCityCtrl.Instance:ReqRankinglistData(MagicCityRankingListData_TYPE.XuKong_type)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function XuKongRankingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function XuKongRankingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function XuKongRankingView:OnRankingTipDesc()
	DescTip.Instance:SetContent(Language.Fuben.RankingTitleContent, Language.Fuben.RankingTitle)
end

function XuKongRankingView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "data" then
			local data = MagicCityData.Instance:GetRankingList(v.rankinglist_type)
			self.xk_ranking_list:SetData(data)
			self.node_t_list.txt_my_rank_score.node:setString(Language.Fuben.MaxFloor)
			self.node_t_list.txt_show.node:setString(Language.Fuben.MyFloor)
			local _, my_score = MagicCityData.Instance:GetMyRankingData()
			self.node_t_list.txt_my_jifen.node:setString(my_score)
		end
	end

end

function XuKongRankingView:CreateRanking()
	if nil == self.xk_ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.xk_ranking_list = ListView.New()
		self.xk_ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RankingFloorRender, nil, nil, self.ph_list.ph_list_item)
		self.xk_ranking_list:GetView():setAnchorPoint(0, 0)
		self.xk_ranking_list:SetMargin(2)
		self.xk_ranking_list:SetItemsInterval(5)
		self.xk_ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_jifen_ranking.node:addChild(self.xk_ranking_list:GetView(), 100)
	end	
end

RankingFloorRender = RankingFloorRender or BaseClass(BaseRender)
function RankingFloorRender:__init()

end

function RankingFloorRender:__delete()	
	if self.reward_cell ~= nil then
		for k, v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function RankingFloorRender:CreateChild()
	BaseRender.CreateChild(self)

	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_rewrd_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 80*(i - 1)-60 , ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
 	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(67, 45, ResPath.GetRankingList("bg_crowns_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function RankingFloorRender:OnFlush()
	if self.data == nil then return end
	if self.index <= 3 then
		self.node_tree.txt_my_ranking.node:setVisible(false)
	end
	if self.index == 1 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_prof.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("ffff00"))
	elseif self.index == 2 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_name.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_prof.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("de00ff"))
	elseif self.index == 3 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_prof.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("00ff00"))
	else
		self.node_tree.txt_my_ranking.node:setString(self.index)
	end	
	self.node_tree.txt_my_ranking.node:setString(self.data.role_data.rank)
	self.node_tree.txt_name.node:setString(self.data.role_data.player_name)
	self.node_tree.txt_prof.node:setString( Language.Common.ProfName[self.data.role_data.prof])
	self.node_tree.txt_jifen.node:setString(self.data.role_data.score)
	for k,v in pairs(self.reward_cell) do
		v:GetView():setVisible(false)
	end
	local ph = self.ph_list.ph_rewrd_cell
	local lenth =  (3 - #self.data.item_data)* 40 - 10
	for k, v in pairs(self.data.item_data) do
		self.reward_cell[k]:GetView():setVisible(true)
		self.reward_cell[k]:SetPosition(ph.x + 80*(k - 1)-60 + lenth , ph.y)
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)

			if virtual_item_id then
				self.reward_cell[k]:SetData({["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0})
			end
		else
			self.reward_cell[k]:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
		end
	end
end