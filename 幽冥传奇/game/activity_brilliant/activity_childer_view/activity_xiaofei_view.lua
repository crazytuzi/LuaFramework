XiaoFeiView = XiaoFeiView or BaseClass(ActBaseView)

function XiaoFeiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XiaoFeiView:__delete()
	if nil~=self.grid_xiaofei_scroll_list then
		self.grid_xiaofei_scroll_list:DeleteMe()
	end
	self.grid_xiaofei_scroll_list = nil
end

function XiaoFeiView:InitView()
	self:CreateXiaofeiGridScroll()
end

function XiaoFeiView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	self.node_t_list.layout_xiaofei.lbl_xiaofei_rank.node:setString(data.mine_rank[ACT_ID.XF])
	self.node_t_list.layout_xiaofei.lbl_activity_tip.node:setString(data.mine_num[ACT_ID.XF])
	self.grid_xiaofei_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetRankList(ACT_ID.XF))
	self.grid_xiaofei_scroll_list:JumpToTop()
end

--消费豪礼
function XiaoFeiView:CreateXiaofeiGridScroll()
	if nil == self.node_t_list.layout_xiaofei then
		return
	end
	if nil == self.grid_xiaofei_scroll_list then
		local ph = self.ph_list.ph_xiaofei_view_list or {x = 0, y = 0, w = 10, h = 10}
		self.grid_xiaofei_scroll_list = GridScroll.New()
		self.grid_xiaofei_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, ActRankItemRender, ScrollDir.Vertical, false, self.ph_list.ph_xiaofei_list)
		self.node_t_list.layout_xiaofei.node:addChild(self.grid_xiaofei_scroll_list:GetView(), 100)
	end
end
