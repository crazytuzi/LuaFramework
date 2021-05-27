XunBaoView = XunBaoView or BaseClass(ActBaseView)

function XunBaoView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XunBaoView:__delete()
	if nil~=self.grid_xunbao_scroll_list then
		self.grid_xunbao_scroll_list:DeleteMe()
	end
	self.grid_xunbao_scroll_list = nil
end

function XunBaoView:InitView()
	self:CreateXunbaoGridScroll()
end

function XunBaoView:RefreshView(param_list)
	local xunbao_num = ActivityBrilliantData.Instance.xunbao_num
	self.node_t_list.layout_xunbao.lbl_activity_tip.node:setString(xunbao_num)
	self.grid_xunbao_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetXunbaoRewardList())
end

--疯狂寻宝
function XunBaoView:CreateXunbaoGridScroll()
	if nil == self.node_t_list.layout_xunbao then
		return
	end
	if nil == self.grid_xunbao_scroll_list then
		local ph = self.ph_list.ph_xunbao_view_list
		self.grid_xunbao_scroll_list = GridScroll.New()
		self.grid_xunbao_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, XunbaoItemRender, ScrollDir.Vertical, false, self.ph_list.ph_xunbao_list)
		self.node_t_list.layout_xunbao.node:addChild(self.grid_xunbao_scroll_list:GetView(), 100)
		self.grid_xunbao_scroll_list:JumpToTop()
	end
end