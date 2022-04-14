DungeTeamMemberRoleItem = DungeTeamMemberRoleItem or class("DungeTeamMemberRoleItem",BaseCloneItem)
local DungeTeamMemberRoleItem = DungeTeamMemberRoleItem

function DungeTeamMemberRoleItem:ctor(obj,parent_node,layer)
	DungeTeamMemberRoleItem.super.Load(self)
end

function DungeTeamMemberRoleItem:dctor()
	if self.role_icon then
		self.role_icon:destroy()
		self.role_icon = nil
	end
end

function DungeTeamMemberRoleItem:LoadCallBack()
	self.nodes = {
		"icon","levelbg/level", "levelbg"
	}
	self:GetChildren(self.nodes)
	self.level = GetText(self.level)
	self.levelbg = GetImage(self.levelbg)
	self:AddEvent()
end

function DungeTeamMemberRoleItem:AddEvent()
end

--data:team:member
function DungeTeamMemberRoleItem:SetData(data)
	self.data = data
	if self.data then
		if not self.role_icon then
			self.role_icon = RoleIcon(self.icon)
		end
	    local param = {}
	    param["is_squared"] = true
	    param["size"] = 65
	    param["role_data"] = self.data.role
	    param["is_show_defa_frame"] = true
	    self.role_icon:SetData(param)
	    SetTopLevelImg(self.data.role.level, self.levelbg, self, self.level)
	else
		SetVisible(self.levelbg, false)
	end
end