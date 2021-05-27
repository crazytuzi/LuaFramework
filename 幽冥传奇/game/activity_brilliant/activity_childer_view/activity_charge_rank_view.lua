ChongZhiRankView = ChongZhiRankView or BaseClass(ActBaseView)

function ChongZhiRankView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChongZhiRankView:__delete()
	if nil~=self.grid_rcharge_scroll_list then
		self.grid_rcharge_scroll_list:DeleteMe()
	end
	self.grid_rcharge_scroll_list = nil

	if RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.gold_listener)
	end
end

function ChongZhiRankView:InitView()
	self:CreateRChargeGridScroll()
	self.gold_listener = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_GOLD,BindTool.Bind(self.RefreshView, self))
end

function ChongZhiRankView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local act_id = ACT_ID.CZRANK
	local reward_list = ActivityBrilliantData.Instance:GetRankList(act_id)
	self.node_t_list.layout_chager_rank.lbl_chargei_rank.node:setString(data.mine_rank[ACT_ID.CZRANK])
	self.node_t_list.layout_chager_rank.lbl_activity_tip.node:setString(OtherData.Instance:GetDayChargeGoldNum())
	-- self.node_t_list.layout_chager_rank.lbl_activity_tip.node:setString(data.today_charge_gold_count)
	self.grid_rcharge_scroll_list:SetDataList(reward_list)
	self.grid_rcharge_scroll_list:JumpToTop()
end

--消费豪礼
function ChongZhiRankView:CreateRChargeGridScroll()
	if nil == self.node_t_list.layout_chager_rank then
		return
	end
	if nil == self.grid_rcharge_scroll_list then
		local ph = self.ph_list.ph_charge_rank_view_list
		self.grid_rcharge_scroll_list = GridScroll.New()
		self.grid_rcharge_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, ActRankItemRender, ScrollDir.Vertical, false, self.ph_list.ph_chagre_rank_list)
		self.node_t_list.layout_chager_rank.node:addChild(self.grid_rcharge_scroll_list:GetView(), 100)
	end
end
