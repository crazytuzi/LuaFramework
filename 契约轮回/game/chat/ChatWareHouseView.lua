ChatWareHouseView = ChatWareHouseView or class("ChatWareHouseView", BaseChatBagView)
local ChatWareHouseView = ChatWareHouseView

function ChatWareHouseView:ctor(parent_node,layer)
	--self.abName = "chat"
	--self.assetName = "ChatWareHouseView"

	self.height = 0
	local cCount = table.nums(BagModel.Instance.wareHouseItems)
	if cCount > self.cellCount then
		self.cellCount = cCount
	end


	for i, v in pairs(BagModel.Instance.wareHouseItems) do
		table.insert(self.itemDatas,v)
	end

	ChatWareHouseView.super.Load(self)
end






