TeamMemberItem3 = TeamMemberItem3 or class("TeamMemberItem3",BaseItem)
local TeamMemberItem3 = TeamMemberItem3

function TeamMemberItem3:ctor(parent_node,layer)
	self.abName = "team"
	self.assetName = "TeamMemberItem3"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	TeamMemberItem3.super.Load(self)
end

function TeamMemberItem3:dctor()
	if self.role_icon then
		self.role_icon:destroy()
		self.role_icon = nil
	end
end

function TeamMemberItem3:LoadCallBack()
	self.nodes = {
		"vip", "name", "power/power_Text", "btn_accept","level","icon_bg",
		"btn_refuse"
	}
	self:GetChildren(self.nodes)
	self.vip = GetText(self.vip)
	self.name = GetText(self.name)
	self.power_Text = GetText(self.power_Text)
	self.level = GetText(self.level)
	self:AddEvent()

	self:UpdateView()
end

function TeamMemberItem3:AddEvent()

	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleInvite(self.data.team_id)
	end
	AddClickEvent(self.btn_accept.gameObject,call_back)

	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleInvite(self.data.team_id, 2)
	end
	AddClickEvent(self.btn_refuse.gameObject,call_back)
end

function TeamMemberItem3:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TeamMemberItem3:UpdateView()
	local role = self.data.invitor.role
	self.vip.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
	self.name.text = role.name
	self.power_Text.text = TeamModel.GetInstance():FormatPower(role.power)
	self.level.text = string.format(ConfigLanguage.Common.Level, role.level)
	
	local param = {}
	param['is_can_click'] = false
	param["is_squared"] = false
	param["is_hide_frame"] = false
	param["size"] = 60
	param["role_data"] = role
	self.role_icon = RoleIcon(self.icon_bg)
	self.role_icon:SetData(param)
end
