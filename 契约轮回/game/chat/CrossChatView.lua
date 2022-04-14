--
-- @Author: chk
-- @Date:   2018-09-05 10:07:48
--
CrossChatView = CrossChatView or class("CrossChatView",BaseChatView)
local CrossChatView = CrossChatView

function CrossChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.CrossChannel
	CrossChatView.super.Load(self)
end

