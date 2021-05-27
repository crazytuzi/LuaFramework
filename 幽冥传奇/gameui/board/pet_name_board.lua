
PetNameBoard = PetNameBoard or BaseClass(NameBoard)

function PetNameBoard:__init()
	self.hero_name_text_rich = XUI.CreateRichText(0, 24, 200, 24)
	XUI.RichTextSetCenter(self.hero_name_text_rich)
	self.root_node:addChild(self.hero_name_text_rich, -1)
end

function PetNameBoard:__delete()
	
end

function PetNameBoard:SetPet(vo)
	local name = vo.owner_name and RoleData.SubRoleName(vo.owner_name) .. Language.Common.De .. vo.name or vo.name 
	self:SetName(name, Str2C3b("00c0ff"))

end
