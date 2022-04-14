KissbackPanel = KissbackPanel or class("KissbackPanel",BasePanel)
local KissbackPanel = KissbackPanel

function KissbackPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "KissbackPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.model = FriendModel:GetInstance()
end

function KissbackPanel:dctor()
end

function KissbackPanel:Open( )
	KissbackPanel.super.Open(self)
end

function KissbackPanel:LoadCallBack()
	self.nodes = {
		"icon_bg","content","sendbtn","closebtn",
	}
	self:GetChildren(self.nodes)
	self.content = GetText(self.content)

	self:AddEvent()
end

function KissbackPanel:AddEvent()
	local function call_back(target,x,y)
		GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel, self.data)
		self:Close()
	end
	AddClickEvent(self.sendbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject,call_back)
end

function KissbackPanel:OpenCallBack()
	self:UpdateView()
end

function KissbackPanel:UpdateView( )
	local role = self.data
	local param = {}
	param["size"] = 85
	param["role_data"] = self.data
	self.roleicon = RoleIcon(self.icon_bg)
	self.roleicon:SetData(param)

	self.content.text = string.format(ConfigLanguage.Mail.Kissback, role.name)
end

function KissbackPanel:CloseCallBack(  )
	if self.roleicon then
		self.roleicon:destroy()
		self.roleicon = nil
	end
end

--data:p_role_base
function KissbackPanel:SetData(data)
	self.data = data
end
