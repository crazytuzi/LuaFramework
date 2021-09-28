local FunctionLevelConst = require "app.const.FunctionLevelConst"
local PetBagConst = require "app.const.PetBagConst"

local PetBagFosterDetailLayer = class("PetBagFosterDetailLayer", function (  )
	return CCSItemCellBase:create("ui_layout/PetBag_PetItemDetail.json")
end)


function PetBagFosterDetailLayer.create()
	return PetBagFosterDetailLayer.new()
end

function PetBagFosterDetailLayer:ctor()
	self._nPetId = 0
	self._canQiangHua = false
	self._canShenXing = false
	self._canShenLian = false

	self._nQiangHuaLevel = 0
	self._nShenXingLevel = 0
	self._nShenLianLevel = 0

	-- 强化
	self:registerBtnClickEvent("Button_QiangHua", function()
		self:_onStrengthClick()
	end)
	-- 升星
	self:registerBtnClickEvent("Button_ShenXing", function()
		self:_onUpStarClick()
	end)
	-- 神炼
	self:registerBtnClickEvent("Button_ShenLian", function()
		self:_onRefineClick()
	end)
end

function PetBagFosterDetailLayer:updateDetailWithPetId(nPetId)
	if type(nPetId) ~= "number" or nPetId <= 0 then
		return
	end
	self._nPetId = nPetId
	self._tPet = G_Me.bagData.petData:getPetById(self._nPetId)
	assert(self._tPet)

	local tPet = G_Me.bagData.petData:getPetById(self._nPetId)
	if not tPet then
		return 
	end

	local label = self:getLabelByName("Label_QiangHua")
	if label then
		label:setText(G_lang:get("LANG_PET_STRENGTH_MAX_LEVEL"))
	end
	label = self:getLabelByName("Label_ShenXing")
	if label then
		label:setText(G_lang:get("LANG_PET_UPSTAR_MAXLEVEL"))
	end
	label = self:getLabelByName("Label_ShenLian")
	if label then
		label:setText(G_lang:get("LANG_PET_REFINE_MAXLEVEL"))
	end

	-- 满级、满星、满神炼时显示
	self:showWidgetByName("Label_QiangHua", not G_Me.bagData.petData:couldStrength(self._tPet))
	self:showWidgetByName("Label_ShenXing", not G_Me.bagData.petData:couldUpStar(self._tPet))
	self:showWidgetByName("Label_ShenLian", self._tPet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel())

end

-- 强化
function PetBagFosterDetailLayer:_onStrengthClick()
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
		return 
	end
    local tPet =  G_Me.bagData.petData:getPetById(self._nPetId) 

    if not G_Me.bagData.petData:couldStrength(tPet) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_STRENGTH_MAX_LEVEL_TIPS"))
        return
    end

    require("app.scenes.pet.develop.PetDevelopeScene").show(tPet,PetBagConst.DevelopType.STRENGTH)
end

-- 升星
function PetBagFosterDetailLayer:_onUpStarClick()
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
		return 
	end
    local tPet =  G_Me.bagData.petData:getPetById(self._nPetId) 

    if not G_Me.bagData.petData:couldUpStar(tPet) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_UPSTAR_MAXLEVEL_TIPS"))
        return
    end

    require("app.scenes.pet.develop.PetDevelopeScene").show(tPet,PetBagConst.DevelopType.STAR)
end

-- 神炼
function PetBagFosterDetailLayer:_onRefineClick()
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
		return 
	end
	local tPet =  G_Me.bagData.petData:getPetById(self._nPetId) 

	if tPet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel() then
	    G_MovingTip:showMovingTip(G_lang:get("LANG_PET_REFINE_MAXLEVEL_TIPS"))
	    return false
	end

    require("app.scenes.pet.develop.PetDevelopeScene").show(tPet,PetBagConst.DevelopType.REFINE)
end




return PetBagFosterDetailLayer