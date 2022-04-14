--
-- @Author: chk
-- @Date:   2018-09-05 10:18:11
--
PrivateChatView = PrivateChatView or class("PrivateChatView",BaseChatView)
local PrivateChatView = PrivateChatView

function PrivateChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.PrivateChannel
	PrivateChatView.super.Load(self)
end