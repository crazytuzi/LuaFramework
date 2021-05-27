QMQiangGouView = QMQiangGouView or BaseClass(ActBaseView)

function QMQiangGouView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function QMQiangGouView:__delete()
	if nil~=self.grid_qm_qianggou_scroll_list then
		self.grid_qm_qianggou_scroll_list:DeleteMe()
	end
	self.grid_qm_qianggou_scroll_list = nil
end

function QMQiangGouView:InitView()
	self:CreateQmQianggouGridScroll()
end

function QMQiangGouView:RefreshView(param_list)
	self.grid_qm_qianggou_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetQmQianggouItemList())
	self.grid_qm_qianggou_scroll_list:JumpToTop()
end

function QMQiangGouView:CreateQmQianggouGridScroll()
	if nil == self.node_t_list.layout_qm_qianggou then
		return
	end
	if nil == self.grid_qm_qianggou_scroll_list then
		local ph = self.ph_list.ph_qmqg_list
		local ph_item = self.ph_list.ph_qm_qianggou_item
		self.grid_qm_qianggou_scroll_list = GridScroll.New()
		self.grid_qm_qianggou_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 2, QmQianggouItemRender, ScrollDir.Vertical, false, ph_item)
		self.node_t_list.layout_qm_qianggou.node:addChild(self.grid_qm_qianggou_scroll_list:GetView(), 100)
	end
end
