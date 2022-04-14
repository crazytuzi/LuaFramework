SysChatItem2 = SysChatItem2 or class("SysChatItem2",BaseChatItemSettor)
local SysChatItem2 = SysChatItem2

function SysChatItem2:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "SysChatItem2"
	self.layer = layer

	SysChatItem2.super.Load(self)
end