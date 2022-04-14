ChatEquipBagView = ChatEquipBagView or class("ChatEquipBagView", BaseChatBagView)
local ChatEquipBagView = ChatEquipBagView

function ChatEquipBagView:ctor(parent_node,layer)
	--self.abName = "chat"
	--self.assetName = "ChatEquipBagView"

	self.height = 0
	local bagEquips = BagModel.Instance:GetEquipsByMoreQuality(1)
	local cCount = table.nums(EquipModel.Instance.putOnedEquipDetailList) + table.nums(bagEquips)
	if cCount > self.cellCount then
		self.cellCount = cCount
	end


	for i, v in pairs(EquipModel.Instance.putOnedEquipDetailList) do
		table.insert(self.itemDatas,v)
	end

	for i, v in pairs(bagEquips) do
		table.insert(self.itemDatas,v)
	end

	ChatEquipBagView.super.Load(self)
end



