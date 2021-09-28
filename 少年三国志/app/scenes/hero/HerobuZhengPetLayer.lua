local HerobuZhengLayer = require("app.scenes.hero.HerobuZhengLayer")

local HerobuZhengPetLayer = class("HerobuZhengPetLayer",function(...)
    return HerobuZhengLayer.new(...)
end)

function HerobuZhengPetLayer.create(  )
	return HerobuZhengPetLayer.new("ui_layout/knight_buzhengPet.json", Colors.modelColor)
end

function HerobuZhengPetLayer:ctor( ... )
	self.super.ctor(self, ...)
end

function HerobuZhengPetLayer:onLayerLoad( ... )
	self.super.onLayerLoad(self,...)
	self:registerBtnClickEvent("Button_board_pet", function ( widget )
		self:_onPetClicked()
	end)
	self:registerBtnClickEvent("Button_changePet", function ( widget )
		self:_onPetChangeClicked()
	end)
	self:updatePet()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_CHANGE, self._onPetChange, self)
end

function HerobuZhengPetLayer:updatePet(  )
	local pet = G_Me.bagData.petData:getFightPet()
	local petImg = self:getImageViewByName("Image_icon_pet")
	local petIcon = self:getImageViewByName("Image_board_pet")
	if pet then
		petImg:setVisible(true)
		petIcon:setVisible(true)
		local info = pet_info.get(pet.base_id)
		petImg:loadTexture(G_Path.getPetIcon(info.res_id))
		petIcon:loadTexture(G_Path.getEquipColorImage(info.quality))
	else
		petImg:setVisible(false)
		petIcon:setVisible(false)
	end
end

function HerobuZhengPetLayer:_onPetChange(  )
	self:updatePet()
end

function HerobuZhengPetLayer:_onPetClicked(  )
	local pet = G_Me.bagData.petData:getFightPet()
	if pet  then
	    local tLayer = require("app.scenes.pet.PetInfo").showEquipmentInfo(pet , 2,{})
	    tLayer:setTag(10100)
	else
	    require("app.scenes.pet.PetSelectPetLayer").show()
	end
end

function HerobuZhengPetLayer:_onPetChangeClicked(  )
	require("app.scenes.pet.PetSelectPetLayer").show()
end

return HerobuZhengPetLayer
