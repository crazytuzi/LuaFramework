
SportsListView = SportsListView or BaseClass(BaseView)

function SportsListView:__init()
	self:SetModal(true)
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 12, {0}},
	}
	self:SetIsAnyClickClose(true)
end

function SportsListView:__delete()
end

function SportsListView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SportsListView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SportsListView:ReleaseCallBack()
end

function SportsListView:LoadCallBack(index, loaded_times)
	self:CreateLogList()
end

function SportsListView:CreateLogList()
	local ph = self.ph_list.ph_log_list
	self.sports_list_list = ListView.New()
	self.sports_list_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SportsListItemRender, nil, nil, self.ph_list.ph_list_item)
	self.sports_list_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_list.node:addChild(self.sports_list_list:GetView(), 100)
	self.sports_list_list:SetItemsInterval(1)
	self.sports_list_list:SetJumpDirection(ListView.Top)
end

function SportsListView:ShowIndexCallBack(index)
	local sports_list = OpenServiceAcitivityData.Instance:GetSportsListDataList(OpenServiceAcitivityData.Instance:GetSportsShowIndex())
	self.sports_list_list:SetDataList(sports_list)
end

SportsListItemRender = SportsListItemRender or BaseClass(BaseRender)

function SportsListItemRender:__init()
end

function SportsListItemRender:__delete()
end

function SportsListItemRender:CreateChild()
	SportsListItemRender.super.CreateChild(self)
end

function SportsListItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local content, rank_grade = OpenServiceAcitivityData.GetGredeContent(self.data.fraction)
	self.node_tree.lbl_rank.node:setString(self.data.rank)
	self.node_tree.lbl_name.node:setString(self.data.name)
	self.node_tree.lbl_grade.node:setString(rank_grade)
end

-- 创建选中特效
function SportsListItemRender:CreateSelectEffect()
end
