-- PetProtectLayer.lua

require("app.cfg.knight_info")
require("app.cfg.pet_info")

local PetProtectLayer = class ("PetProtectLayer", UFCCSModelLayer)

function PetProtectLayer.show(...)
	local p = PetProtectLayer.create(...)
	uf_sceneManager:getCurScene():addChild(p)
	return p
end

function PetProtectLayer.create(pos, removeCallback, changeCallback, knightInfoCallback, petInfoCallback, ...)
	return PetProtectLayer.new("ui_layout/knight_petProtect.json", Colors.modelColor, pos, removeCallback, changeCallback, knightInfoCallback, petInfoCallback, ...)
end

function PetProtectLayer:ctor(json, param, pos, removeCallback, changeCallback, knightInfoCallback, petInfoCallback, ...)

	self._removeCallback = removeCallback
	self._changeCallback = changeCallback
	self._knightInfoCallback = knightInfoCallback
	self._petInfoCallback = petInfoCallback
	local protectPetId = G_Me.formationData:getProtectPetIdByPos(pos)
	self._petInfo = G_Me.bagData.petData:getPetById(protectPetId)

	local knightId = G_Me.formationData:getKnightIdBySlot(pos)
	self._knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	
	self.super.ctor(self, json, param, ...)

	self:showAtCenter(true)
end

function PetProtectLayer:onLayerLoad( ... )

	self:registerKeypadEvent(true)

	self:enableAudioEffectByName("Button_close", false)
	
	self:registerBtnClickEvent("Button_close", function ( widget )
		self:animationToClose()
	end)

	self:registerBtnClickEvent("Button_remove", function ( widget )
		if self._removeCallback then self._removeCallback() end
		self:close()
	end)

	self:registerBtnClickEvent("Button_change", function ( widget )
		if self._changeCallback then self._changeCallback() end
		self:close()
		
	end)

	self:registerWidgetClickEvent("ImageView_knight_bg", function ()
		if self._knightInfoCallback then self._knightInfoCallback() end
		self:close()
	end)

	self:registerWidgetClickEvent("ImageView_pet_bg", function ()
		if self._petInfoCallback then self._petInfoCallback() end
		self:close()
	end)
end

function PetProtectLayer:onBackKeyEvent()
	self:close()
	return true
end

function PetProtectLayer:onLayerEnter( ... )

	self:_initView()

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function PetProtectLayer:_setKnightIcon()
	
	local baseInfo = knight_info.get(self._knightInfo.base_id)
	if baseInfo then
		local headImage = self:getImageViewByName("ImageView_hero_head")

		local resId = baseInfo.res_id
	    if self._knightInfo.id == G_Me.formationData:getMainKnightId() then 
	        resId = G_Me.dressData:getDressedPic()
	    end

		headImage:loadTexture(G_Path.getKnightIcon(resId))

		local pinjiImage = self:getImageViewByName("ImageView_pingji_knight")
		pinjiImage:loadTexture(G_Path.getAddtionKnightColorImage(baseInfo.quality))

		local nameLabel = self:getLabelByName("Label_knight")
		nameLabel:setColor(Colors.getColor(baseInfo.quality))
		nameLabel:setText(baseInfo.name)
		nameLabel:createStroke(Colors.strokeBrown, 1)

	end
end

function PetProtectLayer:_setPetInfo()
	
	local baseInfo = pet_info.get(self._petInfo.base_id)
	if baseInfo then

		local headImage = self:getImageViewByName("ImageView_pet_head")
		headImage:loadTexture(G_Path.getPetIcon(baseInfo.res_id))

		local pinjiImage = self:getImageViewByName("ImageView_pingji_pet")
		pinjiImage:loadTexture(G_Path.getAddtionKnightColorImage(baseInfo.quality))

		local backImage = self:getImageViewByName("Image_pet_back")
		backImage:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))

		local nameLabel = self:getLabelByName("Label_pet")
		nameLabel:setColor(Colors.getColor(baseInfo.quality))
		nameLabel:setText(baseInfo.name)
		nameLabel:createStroke(Colors.strokeBrown, 1)

	end
end

function PetProtectLayer:_setAttrInfo()

	local attrLang = {"LANG_GROWUP_ATTRIBUTE_GONGJI", "LANG_GROWUP_ATTRIBUTE_SHENGMING", "LANG_GROWUP_ATTRIBUTE_WUFANG", "LANG_GROWUP_ATTRIBUTE_MOFANG"}
	local baseInfo = pet_info.get(self._petInfo.base_id)
	if baseInfo then
		local data = {G_Me.bagData.petData:getBaseAttr(self._petInfo.level, self._petInfo.base_id,self._petInfo.addition_lvl)}
		for i = 1 , 4 do
			local nameLabel = self:getLabelByName("Label_name"..i)
			local valueLabel = self:getLabelByName("Label_value"..i)
			nameLabel:setText(G_lang:get(attrLang[i]))
			valueLabel:setText(" +" .. math.floor(data[i] * baseInfo.protect_account / 1000))
			valueLabel:setPositionX(nameLabel:getContentSize().width)
		end
	end
end

function PetProtectLayer:_initView()
	
	self:_setKnightIcon()

	self:enableLabelStroke("Label_huyou", Colors.strokeBrown, 1)

	self:_setPetInfo()

	self:enableLabelStroke("Label_attr_header", Colors.strokeBrown, 2)

	self:_setAttrInfo()

end

return PetProtectLayer