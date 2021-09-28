-- PetProtectSelectItem.lua

require("app.cfg.pet_info")

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local PetProtectSelectItem = class("PetProtectSelectItem", function()
	return CCSItemCellBase:create("ui_layout/knight_SelectPetProtectItem.json")
end)

function PetProtectSelectItem:ctor(pos)

	self._pos = pos or 1
	self:attachImageTextForBtn("Button_Battle", "Image_35")
end

function PetProtectSelectItem:updateItem(tPet)
	if not tPet then
		return
	end
	local nBaseId = tPet["base_id"]
	if not nBaseId then
		return
	end

	local tPetTmpl = pet_info.get(nBaseId)
	assert(tPetTmpl)
	if not tPetTmpl then
		return
	end

	-- 战宠名字
	CommonFunc._updateLabel(self, "Label_name", {text=tPetTmpl.name, color=Colors.qualityColors[tPetTmpl.quality], stroke=Colors.strokeBrown})
	-- icon后面的底
	CommonFunc._updateImageView(self, "Image_di", {texture=G_Path.getEquipIconBack(tPetTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	-- icon
	CommonFunc._updateImageView(self, "ImageView_hero_head", {texture=G_Path.getPetIcon(tPetTmpl.res_id)})
	-- 品质框
	CommonFunc._updateImageView(self, "ImageView_pingji", {texture=G_Path.getEquipColorImage(tPetTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	-- 等级
	CommonFunc._updateLabel(self, "Label_level", {text=G_lang:get("LANG_LEVEL_FORMAT_CHN", {levelValue = tPet.level}) })

	-- 属性
	local attrLang = {"LANG_GROWUP_ATTRIBUTE_GONGJI", "LANG_GROWUP_ATTRIBUTE_SHENGMING", "LANG_GROWUP_ATTRIBUTE_WUFANG", "LANG_GROWUP_ATTRIBUTE_MOFANG"}
	local data = {G_Me.bagData.petData:getBaseAttr(tPet.level, tPet.base_id,tPet.addition_lvl)}
	for i = 1 , #data do
		local nameLabel = self:getLabelByName("Label_name"..i)
		local valueLabel = self:getLabelByName("Label_value"..i)
		nameLabel:setText(G_lang:get(attrLang[i]))
		valueLabel:setText(" +" .. math.floor(data[i] * tPetTmpl.protect_account / 1000))
		valueLabel:setPositionX(nameLabel:getContentSize().width)
	end

    local battleButton = self:getButtonByName("Button_Battle")
    self:showWidgetByName("ImageView_wearon", tPet.id == G_Me.bagData.petData:getFightPetId())
    self:showWidgetByName("ImageView_protect", G_Me.formationData:isProtectPetByPetId(tPet.id))

    self:showWidgetByName("Label_protecting", false)
    local canSelcet = tPet.id ~= G_Me.bagData.petData:getFightPetId() and not G_Me.formationData:isProtectPetByPetId(tPet.id)
    if canSelcet and G_Me.formationData:isSampleNameProtectPetByPetIdExclusivePosId(tPet.id, self._pos) then
    	canSelcet = false
    	self:showWidgetByName("Label_protecting", true)
    end
    battleButton:setTouchEnabled(canSelcet)


	self:registerBtnClickEvent("Button_hero_back", function()
		if not tPet then
			return
		end
		require("app.scenes.pet.PetInfo").showEquipmentInfo(tPet, 3)
	end)

	-- 上阵
	self:registerBtnClickEvent("Button_Battle", function()
		self:setClickCell()
		self:selectedCell(tPet.id, 0)
	end)
end


return PetProtectSelectItem