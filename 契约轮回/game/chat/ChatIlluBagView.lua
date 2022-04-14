ChatIlluBagView = ChatIlluBagView or class("ChatIlluBagView",BaseChatBagView)
local ChatIlluBagView = ChatIlluBagView

function ChatIlluBagView:ctor(parent_node,layer)

	self.height = 0

	local illus = BagModel.GetInstance().illustrationItems
	local cCount = #illus
	if cCount > self.cellCount then
		self.cellCount = cCount
	end

	for i=1, #illus do 
		table.insert(self.itemDatas, illus[i])
	end

	self.bagId = BagModel.illustration
	ChatIlluBagView.super.Load(self)
end