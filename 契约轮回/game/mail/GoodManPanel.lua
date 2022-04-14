GoodManPanel = GoodManPanel or class("GoodManPanel",BasePanel)
local GoodManPanel = GoodManPanel

function GoodManPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "GoodManPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	--self.model = 2222222222222end:GetInstance()
end

function GoodManPanel:dctor()
end

function GoodManPanel:Open( )
	GoodManPanel.super.Open(self)
end

function GoodManPanel:LoadCallBack()
	self.nodes = {
		"closebtn","sendbtn","content",
	}
	self:GetChildren(self.nodes)
	self.content = GetText(self.content)

	self:AddEvent()
end

function GoodManPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject,call_back)

	local function call_back(target,x,y)
		GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel, self.data)
		self:Close()
	end
	AddClickEvent(self.sendbtn.gameObject,call_back)

end

function GoodManPanel:OpenCallBack()
	self:UpdateView()
end

function GoodManPanel:UpdateView( )
	self.content.text = string.format(ConfigLanguage.Mail.GoodManCard, self.data.name)
end

function GoodManPanel:CloseCallBack(  )

end

--data:p_role_base
function GoodManPanel:SetData(data)
	self.data = data
end