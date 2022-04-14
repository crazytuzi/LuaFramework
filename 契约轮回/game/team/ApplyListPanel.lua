ApplyListPanel = ApplyListPanel or class("ApplyListPanel",WindowPanel)
local ApplyListPanel = ApplyListPanel

function ApplyListPanel:ctor()
	self.abName = "team"
	self.assetName = "ApplyListPanel"
	self.layer = "UI"

	--self.use_background = true
	--self.change_scene_close = true
	self.panel_type = 3
	self.click_bg_close = true

	self.height = 0
	self.applyitem_list = {}
	self.model = TeamModel:GetInstance()
end

function ApplyListPanel:dctor()
	for i, v in pairs(self.applyitem_list) do
		v:destroy()
	end
	self.applyitem_list = nil
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil 
	end
end

function ApplyListPanel:Open( )
	ApplyListPanel.super.Open(self)
end

function ApplyListPanel:LoadCallBack()
	self.nodes = {
		"apply_list/Viewport/Content", "btn_refuseall",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	self:SetPanelSize(642, 467)
	self:SetTileTextImage("team_image", "team_f_2")
end

function ApplyListPanel:AddEvent()
	local function call_back()
		local apply_list = self.model:GetApplyList()
		if table.nums(apply_list) <= 0 then
			self:Close()
		else
			self:UpdateView()
		end

	end
	self.event_id = GlobalEvent:AddListener(TeamEvent.UpdateApplyList, call_back)

	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleApply(nil, nil, 1)
		self:Close()
	end
	AddClickEvent(self.btn_refuseall.gameObject,call_back)

end

function ApplyListPanel:OpenCallBack()
	self:UpdateView( )
end

function ApplyListPanel:UpdateView( )
	for _, memItem in pairs(self.applyitem_list or {}) do
		memItem:destroy()
	end
	self.height = 0
	local apply_list = self.model:GetApplyList()
	--if #apply_list == 0 then
	--	self:Close()
	--else
		for i=1, #apply_list do
			local item = apply_list[i]
			local memItem = TeamMemberItem2(self.Content)
			memItem:SetData(item)
			self.height = self.height + memItem:GetHeight()
			table.insert(self.applyitem_list, memItem)
		end
		self:ReLayoutScroll()
	--end
end

function ApplyListPanel:CloseCallBack(  )

end

function ApplyListPanel:ReLayoutScroll()
	self.Content.sizeDelta = Vector2(self.Content.sizeDelta.x, self.teamlist_height)
end