
SubView = SubView or BaseClass(BaseView)

function SubView:__init()
	if nil == self.view_def then
		DebugLog("[SubView]: view_def can not be nil")
	end

	self.view_depth = self.view_manager:GetDefDepth(self.view_def)
	self.root_def = self.view_manager:GetRootDef(self.view_def)
end

function SubView:__delete()
end

function SubView:CleanRootNode()
	self.real_root_node = nil
	self.root_node = nil

	for k, v in pairs(self.config_tab) do
		NodeCleaner.Instance:AddNode(v.node)
		v.config = nil
		v.node = nil
	end
end

function SubView:CreateRootNode()
	if nil == self.real_root_node then
		self.root_node = self.view_manager:GetViewObj(self.root_def):GetRootNode()
		self.real_root_node = self.root_node
	end
end

function SubView:GetConfigUiZOrder(k)
	return self.config_tab[k][5] or (k + self.view_depth)
end

function SubView:UpdateLocalZOrder()
end

function SubView:Close(...)
	self:CloseCallBack()
	self:CloseVisible()
end

function SubView:SetVisible(visible)
	self.is_popup = visible
	
	for k, v in pairs(self.config_tab or {}) do
		if v.node then
			v.node:setVisible(visible and (v[4] == nil or v[4]))
		end
	end
end
