--全服争霸排行奖励界面
AllSerFightMatchRankView = AllSerFightMatchRankView or BaseClass(XuiBaseView)

function AllSerFightMatchRankView:__init()

	self.is_async_load = false
	self.is_modal = true
	self.config_tab = {
		{"common_rank_info_ui_cfg", 1, {0}},
	}
	self.ranking_list = nil 
end

function AllSerFightMatchRankView:__delete()
end

function AllSerFightMatchRankView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

	if self.role_attr_change_call_back then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_call_back)
		self.role_attr_change_call_back = nil
	end
end

function AllSerFightMatchRankView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRankingList()
		--XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind(self.OnCloseClicked, self))
		-- self.role_attr_change_call_back = BindTool.Bind(self.OnRoleAttrChangeCallback, self)
		-- RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.role_attr_change_call_back, self))
	end
end

function AllSerFightMatchRankView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	MagicCityCtrl.AllSerFightRankInfoReq()
end

function AllSerFightMatchRankView:ShowIndexCallBack(index)
	self:Flush(index)
end

function AllSerFightMatchRankView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AllSerFightMatchRankView:OnFlush(param_t, index)
	if self.ranking_list then
		local rank_award_data = MagicCityData.Instance:GetAllSerFightAwards()
		self.ranking_list:SetDataList(rank_award_data)
	end
end

function AllSerFightMatchRankView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CommonRankAwardRender, nil, nil, self.ph_list.ph_rankinglist_item)
		-- self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(2)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_rank_list.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

function AllSerFightMatchRankView:OnRoleAttrChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		if self.ranking_list then
			local rank_award_data = MagicCityData.Instance:GetAllSerFightAwards()
			self.ranking_list:SetDataList(rank_award_data)
		end
	end
end

-- function AllSerFightMatchRankView:OnCloseClicked()
-- 	self:Close()
-- end

CommonRankAwardRender = CommonRankAwardRender or BaseClass(BaseRender)
function CommonRankAwardRender:__init()
	
end

function CommonRankAwardRender:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function CommonRankAwardRender:CreateChild()
	BaseRender.CreateChild(self)

	self.cells_list = ListView.New()
	local ph = self.ph_list.ph_cells_container
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, GridCell, nil, nil, self.ph_list.cell_item)
	self.cells_list:SetItemsInterval(2)
	self.cells_list:SetJumpDirection(ListView.Left)
	self.view:addChild(self.cells_list:GetView(), 100)
	
end

function CommonRankAwardRender:OnFlush()
	if self.data == nil then return end
	local info = MagicCityData.Instance:GetAllSerFightInfoByIdx(self.index)
	self.node_tree.txt_stage.node:setString(string.format(Language.DesertKillGod.RankStr[1], self.index))
	self.node_tree.txt_name.node:setString(info and info.name or Language.MagicCity.ZhanWu)
	self.node_tree.txt_score.node:setString(info and info.score or Language.MagicCity.ZhanWu)
	if not self.cells_list.data_list or not next(self.cells_list.data_list) then
		local len = #self.data
		local ph = self.ph_list.ph_cells_container
		if len < 3 then
			local item_ui_cfg = self.ph_list.cell_item
			local interval = self.cells_list:GetView():getItemsInterval()
			local w = item_ui_cfg.w * len + (len - 1) * interval
			self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
		else
			self.cells_list:GetView():setPosition(ph.x, ph.y)
		end	
		self.cells_list:SetData(self.data)
	end
end

-- function CommonRankAwardRender:SetAwardCells(awards_data)
-- 	if not awards_data or not next(awards_data) then return end

-- 	local gap = 2
-- 	local award_cnt = #awards_data
-- 	local need_width = (80 * award_cnt) + (award_cnt - 1) * gap
-- 	self.cells_view_container:setContentWH(need_width, 80)
-- 	-- 多余的删除掉
-- 	if #self.cells_list > award_cnt then
-- 		local no_need_cnt = #self.cells_list - award_cnt
-- 		for i = 1, no_need_cnt do
-- 			local cell = table.remove(self.cells_list, #self.cells_list)
-- 			if cell then
-- 				cell:GetView():removeFromParent()
-- 				cell:DeleteMe()
-- 			end
-- 		end
-- 	end

-- 	for i, v in ipairs(awards_data) do
-- 		local awar = {
-- 							item_id = v.id,
-- 							num = v.count,
-- 							is_bind = v.bind,
-- 						}
-- 		--虚拟物品
-- 		if v.type > 0 then
-- 			awar.item_id = ItemData.Instance:GetVirtualItemId(v.type)
-- 			if ItemData.Instance:CalcuSpecialExpVal(v) then
-- 				awar.num = ItemData.Instance:CalcuSpecialExpVal(v)
-- 			end
-- 		end
-- 		if not self.cells_list[i] then
-- 			local cell = BaseCell.New()
-- 			cell:SetPosition((i - 1) * (80 + gap), 0)
-- 			cell:SetData(awar)
-- 			self.cells_view_container:addChild(cell:GetView(), 100)
-- 			self.cells_list[i] = cell
-- 		else
-- 			local cell = self.cells_list[i]
-- 			cell:GetView():setPositionX((i - 1) * (80 + gap))
-- 			cell:SetData(awar)
-- 		end
-- 	end
-- end

-- 创建选中特效
function CommonRankAwardRender:CreateSelectEffect()

end

