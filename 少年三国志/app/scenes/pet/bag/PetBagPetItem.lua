local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local PetBagPetItem = class("PetBagPetItem", function()
	return CCSItemCellBase:create("ui_layout/PetBag_PetItem.json")
end)

local STAR_MAX = 5

function PetBagPetItem:ctor()
	self:setTouchEnabled(true)
end

function PetBagPetItem:updateItem(tPet)
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

	-- 是否出战
	self:showWidgetByName("ImageView_wearon", tPet["id"] == G_Me.bagData.petData:getFightPetId())
	-- 是否护佑
	self:showWidgetByName("ImageView_protect", G_Me.formationData:isProtectPetByPetId(tPet["id"]))
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


	self:registerBtnClickEvent("Button_hero_back", function()
		if not tPet then
			return
		end
		require("app.scenes.pet.PetInfo").showEquipmentInfo(tPet, 1)
	end)

	self:registerBtnClickEvent("Button_showDetail", function()
		self:_onShowPetDetail(tPet["id"], true)
		self:_updateShowDetail()
	end)
	self:registerBtnClickEvent("Button_hideDetail", function()
		self:_onShowPetDetail(tPet["id"], true)
		self:_updateShowDetail()
	end)

end

function PetBagPetItem:_updateShowDetail( ... )
	self:showWidgetByName("Button_showDetail", not self._isShowDetail)
	self:showWidgetByName("Button_hideDetail", self._isShowDetail)
end

function PetBagPetItem:onDetailShow( show )
	self._isShowDetail = show or false
	self:_updateShowDetail()
end

function PetBagPetItem:_onShowPetDetail( petId, show )
	self:selectedCell(petId, show and 1 or 0)
end


return PetBagPetItem