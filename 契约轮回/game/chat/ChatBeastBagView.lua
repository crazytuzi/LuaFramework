ChatBeastBagView = ChatBeastBagView or class("ChatBeastBagView", BaseChatBagView)
local ChatBeastBagView = ChatBeastBagView

function ChatBeastBagView:ctor(parent_node,layer)
	--self.abName = "chat"
	--self.assetName = "ChatBeastBagView"

	self.height = 0
	local cCount = table.nums(BeastModel.GetInstance().EmbedEquips) + table.nums(BagModel.Instance.bags[BagModel.beast].items)
	if cCount > self.cellCount then
		self.cellCount = cCount
	end


	for i, v in pairs(BeastModel.Instance.EmbedEquips) do
		table.insert(self.itemDatas,v)
	end

	for i, v in pairs(BagModel.Instance.bags[BagModel.beast].items) do
		table.insert(self.itemDatas,v)
	end

	self.bagId = BagModel.beast
	ChatBeastBagView.super.Load(self)
end



