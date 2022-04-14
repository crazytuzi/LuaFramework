--
-- @Author: chk
-- @Date:   2018-09-05 10:11:21
--
OrganizeChatView = OrganizeChatView or class("OrganizeChatView",BaseChatView)
local OrganizeChatView = OrganizeChatView

function OrganizeChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "SystemChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.OrganizeChannel
	OrganizeChatView.super.Load(self)
end

function OrganizeChatView:LoadCallBack()
	self.nodes = {
		"ScrollView",
		"ScrollView/Viewport/Content",
		"ScrollView/Viewport/Content/inlineManager",
	}

	self:GetChildren(self.nodes)

	--[[self.model.inlineManagers[self.channel] = self.inlineManager
	self.model.inlineManagerScps[self.channel] = self.model.inlineManagers[self.channel]:GetComponent('InlineManager')
	self.model.inlineManagerScps[self.channel]:LoadEmoji("asset/chatemoji_asset","e",0,30)--]]


	self.scrollRect = self.ScrollView:GetComponent('ScrollRect')
	self.rectTra = self.ScrollView:GetComponent('RectTransform')
	self.contentRectTra = self.Content:GetComponent('RectTransform')
	self:AddEvent()
	self:LoadItems()
end
--
function OrganizeChatView:AddEvent()
	self.events[#self.events+1] =  GlobalEvent:AddListener(ChatEvent.CreateItemEnd,handler(self,self.DealCreateItemEnd))
	self.events[#self.events+1] =  GlobalEvent:AddListener(ChatEvent.AddMsgItem,handler(self,self.ReceiveMessage))
end

function OrganizeChatView:CreateChatItem(chatMsg)

	local settor = nil
	if chatMsg.sender.id == self.roleInfoModel:GetMainRoleId() then
		settor = SelfChatItemSettor(self.Content,"UI")
	else
		settor = ChatItemSettor(self.Content,"UI")
	end
	settor:SetInfo(chatMsg,self.scrollRect)

	table.insert(self.model:GetChannelItemsByChannel(chatMsg.channel_id),settor)
	self.settors = self.model:GetChannelItemsByChannel(chatMsg.channel_id)
end