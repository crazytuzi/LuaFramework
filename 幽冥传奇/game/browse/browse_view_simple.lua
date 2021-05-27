BrowseViewSimple = BrowseViewSimple or BaseClass(XuiBaseView)

function BrowseViewSimple:__init()
	self:SetModal(true)
	self.def_index = 1
	self.record_cur_index = 1

	self.texture_path_list = {
		"res/xui/role.png",
		"res/xui/equipbg.png",
	}

	self.config_tab = {
		-- {"common_ui_cfg", 7, {0}},
		-- {"common_ui_cfg", 8, {0}},
		{"simple_browse_cfg", 1, {0}},
	}

	
	self.itemconfig_callback = BindTool.Bind1(self.ItemConfigCallback, self)
end

function BrowseViewSimple:__delete()

end

function BrowseViewSimple:ReleaseCallBack()
	if self.role_info_widget then
		self.role_info_widget:DeleteMe()
		self.role_info_widget = nil
	end
	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
	end
end

function BrowseViewSimple:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRoleInfoWidget()
		ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_callback)
	end
end

function BrowseViewSimple:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseViewSimple:ShowIndexCallBack(index)
	self:Flush(index)
end

function BrowseViewSimple:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseViewSimple:CreateRoleInfoWidget()
	self.role_info_widget = RoleInfoView.New()
	self.role_info_widget:CreateViewByUIConfig(self.ph_list.ph_role_info_widget, "player_equip", true)
	self.node_t_list.layout_simple.node:addChild(self.role_info_widget:GetView(), 200) 
	for k,v in pairs(self.role_info_widget.all_text or {}) do
		v:setVisible(false)
	end
end

function BrowseViewSimple:OnFlush(param_list, index)
	local role_vo = BrowseData.Instance:GetRoleInfo()
	self.role_info_widget:SetRoleData(role_vo)
end

function BrowseViewSimple:ItemConfigCallback(item_config_t)
	self:Flush()
end
