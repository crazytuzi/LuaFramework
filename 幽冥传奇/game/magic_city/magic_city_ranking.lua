MagicCityRankingView = MagicCityRankingView or BaseClass(XuiBaseView)

function MagicCityRankingView:__init()
	self.texture_path_list[1] = 'res/xui/magiccity.png'
	self.texture_path_list[2] = 'res/xui/rankinglist.png'
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"magic_city_ui_cfg", 3, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
end

function MagicCityRankingView:__delete()
end

function MagicCityRankingView:ReleaseCallBack()
	if self.ranking_list ~= nil then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil 
	end
end

function MagicCityRankingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRanking()
		XUI.AddClickEventListener(self.node_t_list.btn_ranking_tip.node, BindTool.Bind1(self.OnRankingTip, self))
	end
end

function MagicCityRankingView:OpenCallBack()
	MagicCityCtrl.Instance:ReqRankinglistData(MagicCityRankingListData_TYPE.Magic_city_type)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MagicCityRankingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MagicCityRankingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MagicCityRankingView:OnRankingTip()
	DescTip.Instance:SetContent(Language.MagicCity.RankingTitleContent, Language.MagicCity.RankingTitle)
end

function MagicCityRankingView:OnFlush(param_t, index)
	local data = MagicCityData.Instance:GetRankingList(MagicCityRankingListData_TYPE.Magic_city_type)
	self.ranking_list:SetData(data)
	local _, my_score = MagicCityData.Instance:GetMyRankingData()
	self.node_t_list.txt_my_jifen.node:setString(my_score)
end

function MagicCityRankingView:CreateRanking()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RankingJifenRender, nil, nil, self.ph_list.ph_list_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_jifen_ranking.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

RankingJifenRender = RankingJifenRender or BaseClass(BaseRender)
function RankingJifenRender:__init()

end

function RankingJifenRender:__delete()	
	if self.reward_cell ~= nil then
		for k, v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function RankingJifenRender:CreateChild()
	BaseRender.CreateChild(self)

	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_rewrd_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 80*(i - 1) , ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
 	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(67, 45, ResPath.GetRankingList("bg_crowns_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function RankingJifenRender:OnFlush()
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
	self.node_tree.txt_prof.node:setString(Language.Common.ProfName[self.data.role_data.prof])
	self.node_tree.txt_jifen.node:setString(self.data.role_data.score)
	for k,v in pairs(self.reward_cell) do
		v:GetView():setVisible(false)
	end
	for k, v in pairs(self.data.item_data) do
		self.reward_cell[k]:GetView():setVisible(true)
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