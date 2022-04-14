SendFlowerPanel = SendFlowerPanel or class("SendFlowerPanel",BasePanel)
local SendFlowerPanel = SendFlowerPanel

function SendFlowerPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "SendFlowerPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.model = FriendModel:GetInstance()
end

function SendFlowerPanel:dctor()
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function SendFlowerPanel:Open( )
	SendFlowerPanel.super.Open(self)
end

function SendFlowerPanel:LoadCallBack()
	self.nodes = {
		"roleicon_bg/icon","roleicon_bg/vip","roleicon_bg/name","roleicon_bg/gender","bg2/content",
		"sendbackbtn","kissbackbtn","goodmanbtn","bg3/friendly_value","closebtn",
	}
	self:GetChildren(self.nodes)
	--self.icon = GetImage(self.icon)
	self.vip = GetText(self.vip)
	self.name = GetText(self.name)
	self.gender = GetImage(self.gender)
	self.content = GetText(self.content)
	self.friendly_value = GetText(self.friendly_value)

	self:AddEvent()
end

function SendFlowerPanel:AddEvent()

	local function call_back(target,x,y)
		FriendController:GetInstance():RequestFeedback(self.sender.id, 1)
		FriendController:GetInstance():RequestAddFriend(self.sender.id)
	end
	AddClickEvent(self.kissbackbtn.gameObject,call_back)

	local function call_back(target,x,y)
		GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel, self.sender)
		self:Close()
	end
	AddClickEvent(self.sendbackbtn.gameObject,call_back)

	local function call_back(target,x,y)
		FriendController:GetInstance():RequestFeedback(self.sender.id, 2)
	end
	AddClickEvent(self.goodmanbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject,call_back)

	local function call_back()
		self:Close()
	end
	self.event_id = self.model:AddListener(FriendEvent.FeedBackClose, call_back)
end

function SendFlowerPanel:OpenCallBack()
	self:UpdateView()
end

function SendFlowerPanel:UpdateView( )
	self.name.text = self.sender.name
	self.vip.text = string.format(ConfigLanguage.Common.Vip, self.sender.viplv)
	local gender = self.sender.gender
	if gender == 1 then
		lua_resMgr:SetImageTexture(self,self.gender, 'common_image', 'male_icon_1')
	else
		lua_resMgr:SetImageTexture(self,self.gender, 'common_image', 'female_icon_1')
	end
	local param = {}
    param['is_can_click'] = false
    param["is_squared"] = false
    param["is_hide_frame"] = false
    param["size"] = 72
    param["role_data"] = self.sender
    self.role_icon = RoleIcon(self.icon)
    self.role_icon:SetData(param)

	local item = Config.db_item[self.item_id]
	local flower = Config.db_flower[self.item_id]
	local pfriend = self.model:GetPFriend(self.sender.id)
	if pfriend then
		self.content.text = string.format(ConfigLanguage.Mail.ReceiveFlowerContent, self.sender.name, item.name, flower.charm)
	else
		self.content.text = string.format(ConfigLanguage.Mail.ReceiveFlowerContent2, self.sender.name, item.name, flower.charm, flower.intimacy)
	end
	local intimacy = pfriend and pfriend.intimacy or 0
	self.friendly_value.text = string.format(ConfigLanguage.Mail.FriendValue2, intimacy)
end

function SendFlowerPanel:CloseCallBack(  )
	if self.role_icon then
		self.role_icon:destroy()
	end
end

function SendFlowerPanel:SetData(sender, item_id)
	self.sender = sender
	self.item_id = item_id
end
