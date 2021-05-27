GuildBossRankingView = GuildBossRankingView or BaseClass(XuiBaseView)

function GuildBossRankingView:__init()
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self:SetModal(false)
	self.can_penetrate = true
	self.config_tab = {
		{"fuben_view_ui_cfg", 2, {0}},
	}
end

function GuildBossRankingView:__delete()
	
end

function GuildBossRankingView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil 
	end
	if self.reward_cell ~= nil then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function GuildBossRankingView:LoadCallBack(index, loaded_times)
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_rankinglist.node:setVisible(false)
	if loaded_times <= 1 then
		self:CreateRankingList()
		self:CreateCell()
		local ph = self.ph_list.ph_btn_pos
		self.toggle = XUI.CreateToggleButton(ph.x + 25, ph.y + 30, 56, 56, false, ResPath.GetCommon("btn_down_bg_1"), ResPath.GetCommon("btn_down_bg_1"), "", true)
		self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.node:addChild(self.toggle, 999)
		XUI.AddClickEventListener(self.toggle, BindTool.Bind1(self.LockOpen, self), true)
		local size_1 = self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.node:getContentSize()
		self.node_t_list.layout_fuben_2.layout_my_ranking.node:setPosition(HandleRenderUnit:GetWidth()/2 + size_1.width , HandleRenderUnit:GetHeight()/2)
		local ph_btn = self.ph_list.ph_show_btn
		self.toggle_vis = XUI.CreateToggleButton(ph_btn.x + 35, ph_btn.y+30, 0, 0, false, ResPath.GetCommon("btn_dow_1"), ResPath.GetCommon("btn_dow_1"), "", true)
		self.node_t_list.layout_fuben_2.layout_my_ranking.node:addChild(self.toggle_vis, 999)
		XUI.AddClickEventListener(self.toggle_vis, BindTool.Bind1(self.LockOpenVis, self), true)	
	end
end


function GuildBossRankingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildBossRankingView:ShowIndexCallBack(index)

end

function GuildBossRankingView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildBossRankingView:OnFlush(param_t, index)
	local data = GuildData.Instance:GetBossRankingData()
	self.ranking_list:SetDataList(data)
	local txt = ""
	if #data == 0 then
		txt = ""
	else
		local name = ""
		name = data[1] and data[1].role_name or ""
		txt = string.format(Language.Guild.BossFirstRanking, name)
	end
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.txt_first_ranking.node:setString(txt)
	local my_ranking = GuildData.Instance:GetMyContent()
	local my_ranking_txt = ""
	if my_ranking == 0 then
		my_ranking_txt = Language.Guild.WeiShangBang
	else
		my_ranking_txt = string.format(Language.Guild.MyRanking, my_ranking)
	end
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_my_rank.txt_my_ranking.node:setString(my_ranking_txt)
	local data = GuildData.Instance:GetRewardData()
	for k, v in pairs(self.reward_cell) do
		v:SetData(data[k])
	end
end

function GuildBossRankingView:CreateRankingList()
	if self.ranking_list == nil then
		local ph = self.ph_list.ph_item_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, GuildBossRankingRender, nil, nil, self.ph_list.ph_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(3)
		self.ranking_list:SetItemsInterval(10)
		self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_rankinglist.node:addChild(self.ranking_list:GetView(), 10)
	end
end

function GuildBossRankingView:LockOpen()
	self:BoolShowList()
end

function GuildBossRankingView:BoolShowList()
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_rankinglist.node:setVisible(self.toggle:isTogglePressed())
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_my_rank.node:setVisible(not self.toggle:isTogglePressed())
	self.ranking_list:JumpToTop(true)
end

function GuildBossRankingView:LockOpenVis()
	self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.node:setVisible(not self.toggle_vis:isTogglePressed())
end

function GuildBossRankingView:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + (i-1)*100 + 20, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_fuben_2.layout_my_ranking.layout_data.layout_my_rank.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end


GuildBossRankingRender = GuildBossRankingRender or BaseClass(BaseRender)
function GuildBossRankingRender:__init()

end

function GuildBossRankingRender:__delete()

end

function GuildBossRankingRender:CreateChild()
	BaseRender.CreateChild(self)
end
	
function GuildBossRankingRender:OnFlush()
	if self.data == nil then return end
	local ranking = Language.StrenfthFb.Num[self.data.rank] or self.data.rank
	local txt = string.format(Language.Guild.BossRanking, ranking, self.data.role_name)
	self.node_tree.txt_role_name.node:setString(txt)
end