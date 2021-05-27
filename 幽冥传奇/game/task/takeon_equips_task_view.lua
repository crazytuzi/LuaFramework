--穿x件x级装备任务view
TakeonEquipsTaskView = TakeonEquipsTaskView or BaseClass(XuiBaseView)
function TakeonEquipsTaskView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
						{"takeon_equips_task_ui_cfg", 1, {0}}	
		}

end

function TakeonEquipsTaskView:__delete()

end

function TakeonEquipsTaskView:ReleaseCallBack()

end

function TakeonEquipsTaskView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_unknow_dark_palace.node:addClickEventListener(BindTool.Bind(self.OnDarkPalaceClicked, self))
		self.node_t_list.btn_maya_palace.node:addClickEventListener(BindTool.Bind(self.OnMayaPalaceClicked, self))
		self.node_t_list.btn_personal_boss.node:addClickEventListener(BindTool.Bind(self.OnPersonalBossClicked, self))
		self.node_t_list.btn_boss_home.node:addClickEventListener(BindTool.Bind(self.OnBossHomeClicked, self))
		self.node_t_list.btn_circle_palace.node:addClickEventListener(BindTool.Bind(self.OnCirclePalaceClicked, self))
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node:setAnchorPoint(0, 1)
		self.root_node:setPosition(250, screen_h - 211)
	end
end

function TakeonEquipsTaskView:OnDarkPalaceClicked()
	self:Close()
	Scene.SendQuicklyTransportReq(1)
end

function TakeonEquipsTaskView:OnMayaPalaceClicked()
	self:Close()
	Scene.SendQuicklyTransportReq(ActiveDegreeData.Instance:GetNpcQuicklyTransportId(88))
end

function TakeonEquipsTaskView:OnPersonalBossClicked()
	self:Close()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.boss_personal)
end

function TakeonEquipsTaskView:OnBossHomeClicked()
	self:Close()
	Scene.SendQuicklyTransportReq(ActiveDegreeData.Instance:GetNpcQuicklyTransportId(85))
end

function TakeonEquipsTaskView:OnCirclePalaceClicked()
	self:Close()
	Scene.SendQuicklyTransportReq(ActiveDegreeData.Instance:GetNpcQuicklyTransportId(89))
end

function TakeonEquipsTaskView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TakeonEquipsTaskView:ShowIndexCallBack(index)
	self:Flush(index)
end

function TakeonEquipsTaskView:OnFlush(param_t, index)

end

function TakeonEquipsTaskView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end
