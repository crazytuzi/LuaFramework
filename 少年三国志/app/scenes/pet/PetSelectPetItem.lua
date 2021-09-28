local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local PetSelectPetItem = class("PetSelectPetItem", function()
	return CCSItemCellBase:create("ui_layout/PetBag_SelectPetItem.json")
end)

local STAR_MAX = 5

function PetSelectPetItem:ctor()
	self:attachImageTextForBtn("Button_Battle", "Image_35")
	self:setTouchEnabled(true)
end

function PetSelectPetItem:updateItem(tPet)
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
	-- 强化等级
	CommonFunc._updateLabel(self, "Label_level", {text=tPet.level})
	-- 神炼等级
	CommonFunc._updateLabel(self, "Label_jingjie", {text=tPet.addition_lvl..G_lang:get("LANG_JING_LIAN_CURLEVEL2")})
	-- 战力
	CommonFunc._updateLabel(self, "Label_FightValue", {text=G_GlobalFunc.ConvertNumToCharacter(tPet.fight_value), stroke=Colors.strokeBrown, color=Colors.qualityColors[1]})
	-- 星级
	local nStar = tPetTmpl.star
    for i=1, STAR_MAX do
        self:showWidgetByName("Image_star_"..i.."_full", nStar >= i)
    end

    local battleButton = self:getButtonByName("Button_Battle")
    self:showWidgetByName("ImageView_wearon", tPet.id == G_Me.bagData.petData:getFightPetId())
    self:showWidgetByName("ImageView_protect", G_Me.formationData:isProtectPetByPetId(tPet.id))
    battleButton:setTouchEnabled(tPet.id ~= G_Me.bagData.petData:getFightPetId() and not G_Me.formationData:isProtectPetByPetId(tPet.id))


	self:registerBtnClickEvent("Button_hero_back", function()
		-- if not tPet then
		-- 	return
		-- end
		-- require("app.scenes.pet.PetInfo").showEquipmentInfo(tPet, 1)
		-- 点你妹啊，不给点
	end)

	-- 上阵
	self:registerBtnClickEvent("Button_Battle", function()
		G_HandlersManager.petHandler:sendChangeFightPet(tPet.id)
	end)
end


return PetSelectPetItem