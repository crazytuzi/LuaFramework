BossBattledRewardView = BossBattledRewardView or BaseClass(XuiBaseView)

function BossBattledRewardView:__init()
	self.is_async_load = false
	self.is_modal = true
	self.config_tab = {
		{"desert_killer_god_ui_cfg", 1, {0}},
	}
	self.ranking_list = nil 
end

function BossBattledRewardView:__delete()
end

function BossBattledRewardView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

	if self.role_attr_change_call_back then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_call_back)
		self.role_attr_change_call_back = nil
	end
end

function BossBattledRewardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRankingList()
		self.role_attr_change_call_back = BindTool.Bind(self.OnRoleAttrChangeCallback, self)
		RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.role_attr_change_call_back, self))
	end
end

function BossBattledRewardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossBattledRewardView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossBattledRewardView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossBattledRewardView:OnFlush(param_t, index)
	local rank_award_data = BossBattleData.Instance:GetBossRankData()
	self.ranking_list:SetDataList(rank_award_data)
end

function BossBattledRewardView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossBattledRewardRender, nil, nil, self.ph_list.ph_rankinglist_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_desert_killer_rank_list.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

function BossBattledRewardView:OnRoleAttrChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		if self.ranking_list then
			local rank_award_data = BossBattleData.Instance:GetBossRankData()
			self.ranking_list:SetDataList(rank_award_data)
		end
	end
end

BossBattledRewardRender = BossBattledRewardRender or BaseClass(BaseRender)
function BossBattledRewardRender:__init()
	self.cells_list = {}
	self.cells_view_container = nil
end

function BossBattledRewardRender:__delete()
	for k, v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil	
end

function BossBattledRewardRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCellsContainer()
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(66, 45, ResPath.GetCommon("stage_"..self.index),true)
		self.view:addChild(self.img_bg, 100)
	end
end

function BossBattledRewardRender:OnFlush()
	if self.data == nil then return end
	if self.index > 3 then
		local stage_str = string.format(Language.DesertKillGod.StageStr, Language.DesertKillGod.ChnNum[self.index])
		self.node_tree.txt_stage.node:setString(stage_str)
	end
	local rank_str = ""
	if self.data.rank_range[1] == self.data.rank_range[2] then
		rank_str = string.format(Language.DesertKillGod.RankStr[1], self.data.rank_range[1])
	else	
		rank_str = string.format(Language.DesertKillGod.RankStr[2], self.data.rank_range[1], self.data.rank_range[2])
	end
	self.node_tree.txt_rank.node:setString(rank_str)
	self:SetAwardCells(self.data.awards)
end

function BossBattledRewardRender:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_cells_container
		self.cells_view_container = XLayout:create(0, 80)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function BossBattledRewardRender:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (80 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 80)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		local awar = {
							item_id = v.id,
							num = v.count,
							is_bind = v.bind,
						}
		--虚拟物品
		if v.type > 0 then
			awar.item_id = ItemData.Instance:GetVirtualItemId(v.type)
			-- print("3333333333333",v.type, tagAwardType.qatExp)
			if awar.item_id == tagAwardItemIdDef[tagAwardType.qatExp] then
				awar.num = 1
			end
		end
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:SetPosition((i - 1) * (80 + gap), 0)
			cell:SetData(awar)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (80 + gap))
			cell:SetData(awar)
		end
	end
end

-- 创建选中特效
function BossBattledRewardRender:CreateSelectEffect()

end