
local RoleIntroView = BaseClass(SubView)

function RoleIntroView:__init()
	self.texture_path_list = {
		'res/xui/role.png',
		'res/xui/equipbg.png',
	}
	self.config_tab = {
		{"role1_ui_cfg", 3, {0}},
	}
end

function RoleIntroView:__delete()
end

function RoleIntroView:ReleaseCallBack()
	if self.role_info_view then
		self.role_info_view:DeleteMe()
		self.role_info_view = nil
	end

end

function RoleIntroView:LoadCallBack(index, loaded_times)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local size = self.node_t_list.layout_role_equip.node:getContentSize()
	self.role_info_view = MainRoleInfoView.New()
	local view_node = self.role_info_view:CreateView()
	view_node:setPosition(size.width / 2, size.height / 2)
	self.role_info_view:SetRoleVo(role_vo)
	self.node_t_list.layout_role_equip.node:addChild(view_node, 99)
	self.node_t_list.lbl_role_name.node:setString(role_vo.name)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, function (vo)
		if vo.key == OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE then
			self.role_info_view:SetRoleVo(GameVoManager.Instance:GetMainRoleVo())
		end
	end)
end

function RoleIntroView:OpenCallBack()
end

function RoleIntroView:ShowIndexCallBack(index)
end

function RoleIntroView:OnFlush(param_t, index)
end

function RoleIntroView:OnGetUiNode(node_name)
	if NodeName.RoleIntroQuickEquip == node_name then
		return self.role_info_view and self.role_info_view:GetBtnQuickEquip(), true
	end
	return RoleIntroView.super.OnGetUiNode(node_name)
end

return RoleIntroView
