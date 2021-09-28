--EquipmentListCellDetail.lua
local EquipmentConst = require("app.const.EquipmentConst")
local funLevelConst = require("app.const.FunctionLevelConst")

local EquipmentListCellDetail = class("EquipmentListCellDetail", function (  )
	return CCSItemCellBase:create("ui_layout/equipment_EquipmentListCellDetail.json")
end)


function EquipmentListCellDetail.create(  )
	return EquipmentListCellDetail.new()
end

function EquipmentListCellDetail:ctor( ... )


	self:registerBtnClickEvent("Button_strength", function ( widget )
		self:_onStrengthClick()
	end)

	self:registerBtnClickEvent("Button_xilian", function ( widget )
		self:_onXilianClick()
	end)

	self:registerBtnClickEvent("Button_star", function ( widget )
		self:_onStarClick()
	end)

end


function EquipmentListCellDetail:getEquipment()
	return self._equipment
end

function EquipmentListCellDetail:updateDetail( equipment )
	self._equipment = equipment

	local level = equipment.level
	local maxLevel = equipment:getMaxStrengthLevel()

	if not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_STRENGTH) then 
		self:showWidgetByName("Label_strength_level", true)
		self:showTextWithLabel("Label_strength_level", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.EQUIP_STRENGTH)}))
	elseif level >= maxLevel then  
		self:showWidgetByName("Label_strength_level", true)
		self:showTextWithLabel("Label_strength_level", G_lang:get("LANG_MAX_VALUE"))
	else
		self:showWidgetByName("Label_strength_level", false)
	end


	local refining_level = equipment.refining_level
	local maxRefineLevel = equipment:getMaxRefineLevel()
	if not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING) then  
		self:showWidgetByName("Label_xilian_level", true)
		self:showTextWithLabel("Label_xilian_level", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.EQUIP_TRAINING)}))
	elseif refining_level >= maxRefineLevel then 
		self:showWidgetByName("Label_xilian_level", true)
		self:showTextWithLabel("Label_xilian_level", G_lang:get("LANG_MAX_VALUE"))
	else
		self:showWidgetByName("Label_xilian_level", false)
	end

	-- 装备升星
	local star_level = equipment.star or 0
	local maxStarLevel = equipment:getMaxStarLevel()
	local equipmentInfo = equipment:getInfo()
	local starLevelLabel = self:getLabelByName("Label_star_level")
	starLevelLabel:setVisible(true)

	if equipmentInfo.potentiality < EquipmentConst.Star_Potentiality_Min_Value then 
		-- 不可升星
		starLevelLabel:setText(G_lang:get("LANG_EQUIPMENT_STAR_CAN_NOT_DO"))

	elseif not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_STAR) then
		-- 等级不足
		starLevelLabel:setText(G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.EQUIP_STAR)}))

	elseif star_level >= maxStarLevel then
		-- 最大值
		starLevelLabel:setText(G_lang:get("LANG_EQUIPMENT_STAR_MAX_LEVEL"))
	else

		starLevelLabel:setVisible(false)
	end



	-- self._knightId = knightId or 0
	-- if self._knightId == 0 then
	-- 	return 
	-- end

	-- local mainKnightId = G_Me.formationData:getMainKnightId()
	-- local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)		
	-- local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	-- if mainKnightInfo == nil or knightInfo == nil then
	-- 	__LogError("main knight or normal knight is invalid!")
	-- 	return 
	-- end

	-- self._isMaxStrengthLevel = knightInfo["level"] >= mainKnightInfo["level"]
	-- self._isMaxJingjieLevel = not G_Me.bagData.knightsData:canJingJieWithKnightId(self._knightId)
	-- self._isMaxXilianLevel = not G_Me.bagData.knightsData:isKnightCanTraining(self._mainKnightId)

	-- self:showWidgetByName("ImageView_strength_level", self._isMaxStrengthLevel)
	-- self:showWidgetByName("ImageView_jingjie_level", self._isMaxJingjieLevel)
	-- self:showWidgetByName("ImageView_xilian_level", self._isMaxXilianLevel)
	-- self:showWidgetByName("ImageView_guanhzi_level", self._isMaxGuanzhiLevel)
end

function EquipmentListCellDetail:_onStrengthClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_STRENGTH) then 
		return 
	end
	require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.StrengthMode)
end


function EquipmentListCellDetail:_onXilianClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_TRAINING) then 
		return 
	end
	require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.RefineMode)
end

function EquipmentListCellDetail:_onStarClick( ... )
	require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.StarMode)
end

return EquipmentListCellDetail
