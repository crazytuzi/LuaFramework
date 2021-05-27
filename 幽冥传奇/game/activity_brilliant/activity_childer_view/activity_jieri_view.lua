JieRiView = JieRiView or BaseClass(ActBaseView)

function JieRiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function JieRiView:__delete()
	if nil~=self.grid_jieri_scroll_list then
		self.grid_jieri_scroll_list:DeleteMe()
	end
	self.grid_jieri_scroll_list = nil
	if BagData.Instance then
		BagData.Instance:RemoveEventListener(self.bag_item_change)
	end
end

function JieRiView:InitView()
	self:CreateJieriGridScroll()
	self.bag_item_change = BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE,BindTool.Bind(self.RefreshView, self))
end

function JieRiView:RefreshView(param_list)
	local old_data_list = self.grid_jieri_scroll_list:GetDataList()
	self.grid_jieri_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetJieriItemList())
	if nil == old_data_list or nil == next(old_data_list) then
		self.grid_jieri_scroll_list:JumpToTop()
	end
end

function JieRiView:CreateJieriGridScroll()
	if nil == self.node_t_list.layout_jieri then
		return
	end
	if nil == self.grid_jieri_scroll_list then
		local ph = self.ph_list.ph_qmqg_list
		self.grid_jieri_scroll_list = GridScroll.New()
		self.grid_jieri_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, JieriItemRender, ScrollDir.Vertical, false, self.ph_list.ph_jieri_item)
		self.node_t_list.layout_jieri.node:addChild(self.grid_jieri_scroll_list:GetView(), 100)
	end
end
