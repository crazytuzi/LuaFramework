--
-- @Author: chk
-- @Date:   2018-09-05 10:21:07
--
SystemChatView = SystemChatView or class("SystemChatView",BaseChatView)
local SystemChatView = SystemChatView

function SystemChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "SystemChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.SystemChannel
	SystemChatView.super.Load(self)
end

--function SystemChatView:dctor()
--end
--
function SystemChatView:LoadCallBack()
	self.nodes = {
		"ScrollView",
		"ScrollView/Viewport/Content",
		--"bottom/sendBtn",
		--"bottom/TextInput",
	}

	self:GetChildren(self.nodes)

	self.scrollRect = self.ScrollView:GetComponent('ScrollRect')
	self.rectTra = self.ScrollView:GetComponent('RectTransform')
	self.contentRectTra = self.Content:GetComponent('RectTransform')
	--self.InputText = self.TextInput:GetComponent('InputField')
	--self.InputText.text = ""
	self:AddEvent()
	self:LoadItems()
end
--
function SystemChatView:AddEvent()
	self.events[#self.events+1] =  GlobalEvent:AddListener(ChatEvent.CreateItemEnd,handler(self,self.DealCreateItemEnd))
	self.events[#self.events+1] =  GlobalEvent:AddListener(ChatEvent.AddMsgItem,handler(self,self.ReceiveMessage))
end

function SystemChatView:CreateChatItem(chatMsg)

	local settor = nil
	settor = SysChatItem(self.Content,"UI")
	settor:SetInfo(chatMsg,self.scrollRect)

	table.insert(self.model:GetChannelItemsByChannel(chatMsg.channel_id),settor)
	self.settors = self.model:GetChannelItemsByChannel(chatMsg.channel_id)
end


