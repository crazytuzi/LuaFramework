ChatBagView = ChatBagView or class("ChatBagView", BaseChatBagView)
local ChatBagView = ChatBagView

function ChatBagView:ctor(parent_node,layer)
	--self.abName = "chat"
	--self.assetName = "ChatBagView"

	self.height = 0
	self.putOnedEquipCount = table.nums(EquipModel.Instance.putOnedEquipDetailList)
	self.bagItemCount = table.nums(BagModel.Instance.bagItems)

	local cCount = self.putOnedEquipCount + self.bagItemCount
	if cCount > self.cellCount then
		self.cellCount = cCount
	end


	for i, v in pairs(EquipModel.Instance.putOnedEquipDetailList) do
		table.insert(self.itemDatas,v)
	end

	for i, v in pairs(BagModel.Instance.bagItems) do
		if v ~= nil  and v ~= 0 then
			table.insert(self.itemDatas,v)
		end
	end

	ChatBagView.super.Load(self)
end





