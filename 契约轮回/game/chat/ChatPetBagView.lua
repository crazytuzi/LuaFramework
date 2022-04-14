ChatPetBagView = ChatPetBagView or class("ChatPetBagView",BaseChatBagView)
local ChatPetBagView = ChatPetBagView

function ChatPetBagView:ctor(parent_node,layer)

	self.height = 0

	local pets = PetModel:GetInstance():GetAllPet()
	local cCount = #pets
	if cCount > self.cellCount then
		self.cellCount = cCount
	end

	for i=1, #pets do 
		table.insert(self.itemDatas, pets[i])
	end

	self.bagId = BagModel.Pet
	ChatPetBagView.super.Load(self)
end

