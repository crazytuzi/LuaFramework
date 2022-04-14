--
-- @Author: chk
-- @Date:   2018-09-04 20:40:28
--
ChatItemSettor = ChatItemSettor or class("ChatItemSettor",BaseChatItemSettor)
local this = ChatItemSettor

ChatItemSettor.__cache_count = 5
function ChatItemSettor:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatItem"
	self.layer = layer

	
	ChatItemSettor.super.Load(self)
end

