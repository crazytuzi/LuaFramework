SysChatItem = SysChatItem or class("SysChatItem",BaseChatItemSettor)
local SysChatItem = SysChatItem

function SysChatItem:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "SysChatItem"
	self.layer = layer

	SysChatItem.super.Load(self)
end

