FriendChatItem = FriendChatItem or class("FriendChatItem", BaseChatItemSettor)
local FriendChatItem = FriendChatItem

FriendChatItem.__cache_count = 3
function FriendChatItem:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "FriendChatItem"
    self.layer = layer

    FriendChatItem.super.Load(self)
end

function FriendChatItem:GetHeight()
    return self.height
end