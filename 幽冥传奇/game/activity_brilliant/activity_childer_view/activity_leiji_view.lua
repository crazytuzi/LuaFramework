LeiJiCZView = LeiJiCZView or BaseClass(ActBaseView)

function LeiJiCZView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LeiJiCZView:__delete()
	if nil~=self.grid_leiji_scroll_list then
		self.grid_leiji_scroll_list:DeleteMe()
	end
	self.grid_leiji_scroll_list = nil
end

function LeiJiCZView:InitView()
	self:CreateLeijiGridScroll()
end

function LeiJiCZView:RefreshView(param_list)
	self.grid_leiji_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetLeijiRewardList())
	self.grid_leiji_scroll_list:JumpToTop()
end

--累冲奖励
function LeiJiCZView:CreateLeijiGridScroll()
	if nil == self.node_t_list.layout_leiji then
		return
	end
	if nil == self.grid_leiji_scroll_list then
		local ph = self.ph_list.ph_leichong_view_list
		local ph_item = self.ph_list.ph_leichong_list
		self.grid_leiji_scroll_list = GridScroll.New()
		self.grid_leiji_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 3, LeijiItemRender, ScrollDir.Vertical, false, ph_item)
		self.node_t_list.layout_leiji.node:addChild(self.grid_leiji_scroll_list:GetView(), 100)
	end
end