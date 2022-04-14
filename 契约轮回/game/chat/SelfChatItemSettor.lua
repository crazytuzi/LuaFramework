--
-- @Author: chk
-- @Date:   2018-09-04 20:40:36
--
SelfChatItemSettor = SelfChatItemSettor or class("SelfChatItemSettor", BaseChatItemSettor)
local SelfChatItemSettor = SelfChatItemSettor

SelfChatItemSettor.__cache_count = 5
function SelfChatItemSettor:ctor(parent_node, layer)
    self.abName = "chat"
    self.assetName = "SelfChatItem"
    self.layer = layer
    self.is_self = true

    SelfChatItemSettor.super.Load(self)
end
