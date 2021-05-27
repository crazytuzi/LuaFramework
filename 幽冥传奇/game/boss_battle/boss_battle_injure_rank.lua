BossBattleInjureRankView = BossBattleInjureRankView or BaseClass(XuiBaseView)

function BossBattleInjureRankView:__init()
	self.is_async_load = false
	self.is_modal = false
	self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/rankinglist.png'
	self.config_tab = {
		{"fuben_view_ui_cfg", 4, {0}},
	}
	self.ranking_list = nil 
end

function BossBattleInjureRankView:__delete()
end

function BossBattleInjureRankView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

end


function BossBattleInjureRankView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRankingList()
		-- local ph = self.ph_list.ph_open_view
		-- self.toggle = XUI.CreateToggleButton(ph.x + 25, ph.y + 30, 56, 56, false, ResPath.GetCommon("btn_down_bg_1"), ResPath.GetCommon("btn_down_bg_1"), "", true)
		-- self.node_t_list.layout_boss_injure_ran.node:addChild(self.toggle, 999)
		-- XUI.AddClickEventListener(self.toggle, BindTool.Bind1(self.LockOpen, self), true)
		local x = HandleRenderUnit:GetWidth()
		local y = HandleRenderUnit:GetHeight()
		self.node_t_list.layout_ranking.node:setPosition(x*3/4, y/2-50)
	end
end

function BossBattleInjureRankView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossBattleInjureRankView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossBattleInjureRankView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossBattleInjureRankView:OnFlush(param_t, index)
	local data = MagicCityData.Instance:GetRankingList(MagicCityRankingListData_TYPE.Battle_Boss)
	self.ranking_list:SetDataList(data)
end

-- function BossBattleInjureRankView:LockOpen()
-- 	self.node_t_list.layout_boss_injure_ran.layout_ranking.node:setVisible(not self.toggle:isTogglePressed())
-- end

function BossBattleInjureRankView:CreateRankingList()
	if self.ranking_list == nil then
		local ph = self.ph_list.ph_injure_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, BossBattleInjureRankingRender, nil, nil, self.ph_list.ph_injure_list_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_ranking.node:addChild(self.ranking_list:GetView(), 100)
	end
end

BossBattleInjureRankingRender = BossBattleInjureRankingRender or BaseClass(BaseRender)
function BossBattleInjureRankingRender:__init()
	
end

function BossBattleInjureRankingRender:__delete()
end

function BossBattleInjureRankingRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(67, 45, ResPath.GetRankingList("bg_crowns_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function BossBattleInjureRankingRender:OnFlush()
	if self.data == nil then return end 
	if self.data == nil then return end
	if self.index <= 3 then
		self.node_tree.txt_my_ranking.node:setVisible(false)
	end
	if self.index == 1 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("ffff00"))
	elseif self.index == 2 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_name.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("de00ff"))
	elseif self.index == 3 then
		self.node_tree.txt_my_ranking.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_jifen.node:setColor(Str2C3b("00ff00"))
	else
		self.node_tree.txt_my_ranking.node:setString(self.index)
	end	
	self.node_tree.txt_my_ranking.node:setString(self.data.role_data.rank)
	self.node_tree.txt_name.node:setString(self.data.role_data.player_name)
	self.node_tree.txt_jifen.node:setString(self.data.role_data.score)
end