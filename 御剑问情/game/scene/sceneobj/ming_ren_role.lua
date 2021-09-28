MingRenRole = MingRenRole or BaseClass(Role)

function MingRenRole:__init(vo)
	self.obj_type = SceneObjType.MingRen
	self.draw_obj:SetObjType(self.obj_type)
	local follow_ui = self.draw_obj:GetSceneObj():GetFollowUi()
	follow_ui:SetHpVisiable(false)
	if self.draw_obj then
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(1.3, 1.3, 1.3)
	end
	local angle = ConfigManager.Instance:GetAutoConfig("rankconfig_auto").mingrentang_coordinates[-self.vo.role_id].Model_angles
	self.draw_obj:Rotate(0, angle, 0)
	follow_ui:SetLocalScale({1.3, 1.3, 1.3})
end

function MingRenRole:__delete()

end

function MingRenRole:OnClick()
	return
end

function MingRenRole:IsRole()
	return false
end

function MingRenRole:IsMainRole()
	return false
end

function MingRenRole:OnClick()
	return
end

function MingRenRole:CancelSelect()
	return
end

function MingRenRole:FlushAppearance()
	self:UpdateAppearance()
	self:UpdateMount()
end