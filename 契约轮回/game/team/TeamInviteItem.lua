TeamInviteItem = TeamInviteItem or class("TeamInviteItem",BaseItem)
local TeamInviteItem = TeamInviteItem

function TeamInviteItem:ctor(parent_node,layer)
	self.abName = "team"
	self.assetName = "TeamInviteItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	self.vipTxt = {}
	TeamInviteItem.super.Load(self)
end

function TeamInviteItem:dctor()
	if self.role_icon then
		self.role_icon:destroy()
		self.role_icon = nil
	end
end

function TeamInviteItem:LoadCallBack()
	self.nodes = {
		"icon_bg",
		"name",
		"level",
		"Toggle",
		"power/power_Text",
		"vip",
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.level = GetText(self.level)
	self.power_Text = GetText(self.power_Text)
	self.vip = GetText(self.vip)
	self:AddEvent()

	self:UpdateView()
end

function TeamInviteItem:AddEvent()

end

function TeamInviteItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TeamInviteItem:UpdateView()
	--[[local head_res = self.data.gender == 1 and "img_role_head_1" or "img_role_head_2"
	lua_resMgr:SetImageTexture(self, self.icon, "main_image", head_res, true)--]]
	local param = {}
    param['is_can_click'] = false
    param["is_squared"] = false
    param["is_hide_frame"] = false
    param["size"] = 60
    param["role_data"] = self.data
    self.role_icon = RoleIcon(self.icon_bg)
    self.role_icon:SetData(param)

	self.name.text = self.data.name
	self.level.text = string.format(ConfigLanguage.Common.Level, self.data.level)
	self.power_Text.text = self.data.power
	self.vip.text = string.format(ConfigLanguage.Common.Vip, self.data.viplv)
end

function TeamInviteItem:GetHeight()
	return 100
end

--获取角色id,未选中位0
function TeamInviteItem:GetRoleId()
	return self.Toggle:GetComponent('Toggle').isOn and self.data.id or ""
end