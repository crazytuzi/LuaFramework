AnswerChatItem = AnswerChatItem or class("AnswerChatItem", BaseChatItemSettor)
local AnswerChatItem = AnswerChatItem

AnswerChatItem.__cache_count=3
function AnswerChatItem:ctor(parent_node,layer)
	self.abName = "guild_house"
	self.assetName = "AnswerChatItem"
	self.layer = layer

	AnswerChatItem.super.Load(self)
end

function AnswerChatItem:GetHeight( )
	return self.height
end