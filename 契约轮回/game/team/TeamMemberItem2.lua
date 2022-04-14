TeamMemberItem2 = TeamMemberItem2 or class("TeamMemberItem2",BaseItem)
local TeamMemberItem2 = TeamMemberItem2

function TeamMemberItem2:ctor(parent_node,layer)
	self.abName = "team"
	self.assetName = "TeamMemberItem2"
	self.layer = layer

	self.vipTxts = {}
	self.model = TeamModel:GetInstance()
	TeamMemberItem2.super.Load(self)
end

function TeamMemberItem2:dctor()
	if self.role_icon then
		self.role_icon:destroy()
		self.role_icon = nil
	end
end

function TeamMemberItem2:LoadCallBack()
	self.nodes = {
		"power/power_Text",
		"icon_bg",
		"name",
		"level",
		"power",
		"btn_refuse",
		"btn_accept",
		"vip",
	}
	self:GetChildren(self.nodes)
	self.vip = GetText(self.vip)
	self:AddEvent()

	self:UpdateView()
end

function TeamMemberItem2:AddEvent()
	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleApply(self.data.role_id, 0)
	end
	AddClickEvent(self.btn_refuse.gameObject,call_back)

	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleApply(self.data.role_id, 1)
	end
	AddClickEvent(self.btn_accept.gameObject,call_back)
end

function TeamMemberItem2:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TeamMemberItem2:UpdateView()
	if self.data then
		local role = self.data.role

		self.vip.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
		local param = {}
	    param['is_can_click'] = false
	    param["is_squared"] = false
	    param["is_hide_frame"] = false
	    param["size"] = 60
	    param["role_data"] = role
	    self.role_icon = RoleIcon(self.icon_bg)
	    self.role_icon:SetData(param)


		self.level:GetComponent('Text').text = role.level
		self.power_Text:GetComponent('Text').text = self.model:FormatPower(role.power)
	end
end

function TeamMemberItem2:GetHeight()
	return 100
end