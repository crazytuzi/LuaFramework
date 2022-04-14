--
-- @Author: chk
-- @Date:   2018-09-05 10:02:15
--
WorldChatView = WorldChatView or class("WorldChatView",BaseChatView)
local WorldChatView = WorldChatView

function WorldChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	self.channel = ChatModel.WorldChannel
	WorldChatView.super.Load(self)

	self.settors = self.model.channelSettors[self.model.WorldChannel] or {}
	self.model.channelSettors[self.model.WorldChannel] = self.settors
end

function WorldChatView:dctor()

	local settors = self.model.channelSettors[self.model.WorldChannel] or {}
end

function WorldChatView:LoadCallBack()
	WorldChatView.super.LoadCallBack(self)
end


