--StrengthEquipLayer.lua


require("app.cfg.equipment_info")
require("app.cfg.team_target_info")
require("app.cfg.treasure_info")
local EquipmentConst = require("app.const.EquipmentConst")
local funLevelConst = require("app.const.FunctionLevelConst")
local StrengthEquipLayer = class("StrengthEquipLayer", UFCCSModelLayer)

function StrengthEquipLayer.create( heroIndex, fun )
	local layer = StrengthEquipLayer.new("ui_layout/knight_strengthEquip.json", Colors.modelColor, heroIndex, fun)
	uf_sceneManager:getCurScene():addChild(layer, 1)
end

function StrengthEquipLayer:ctor( ... )
	self._curHeroIndex = 0
	self._tabIndex = 0
	self._equipTreasureIds = {}
	self._hasEnter = false
	self._closeCallback = nil

	self.super.ctor(self, ...)

	self:showAtCenter(true)
end

function StrengthEquipLayer:onLayerLoad( jsonFile, param, heroIndex, fun )
	self._curHeroIndex = heroIndex or 1
	self._closeCallback = fun

	local closeFun = function ( ... )
		self:_onCloseLayer()
		self:animationToClose()
		local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end
	self:registerBtnClickEvent("Button_close", closeFun)
	self:registerBtnClickEvent("Button_close_1", closeFun)

	self:registerBtnClickEvent("Button_equip_1", function ( ... )
		self:_onItemClick(1)
	end)
	self:registerBtnClickEvent("Button_equip_2", function ( ... )
		self:_onItemClick(2)
	end)
	self:registerBtnClickEvent("Button_equip_3", function ( ... )
		self:_onItemClick(3)
	end)
	self:registerBtnClickEvent("Button_equip_4", function ( ... )
		self:_onItemClick(4)
	end)

	self:addCheckBoxGroupItem(1, "CheckBox_equip_s")
    self:addCheckBoxGroupItem(1, "CheckBox_equip_t")
    self:addCheckBoxGroupItem(1, "CheckBox_treasure_s")
    self:addCheckBoxGroupItem(1, "CheckBox_treasure_t")
    
    self:addCheckNodeWithStatus("CheckBox_equip_s", "Label_e_strength_check", true)
    self:addCheckNodeWithStatus("CheckBox_equip_s", "Label_e_strength_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_equip_t", "Label_e_jinglian_check", true)
    self:addCheckNodeWithStatus("CheckBox_equip_t", "Label_e_jinglian_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_treasure_s", "Label_t_strength_check", true)
    self:addCheckNodeWithStatus("CheckBox_treasure_s", "Label_t_strength_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_treasure_s", "Label_t_strength_disable", false, false)
    self:addCheckNodeWithStatus("CheckBox_treasure_t", "Label_t_jinglian_check", true)
    self:addCheckNodeWithStatus("CheckBox_treasure_t", "Label_t_jinglian_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_treasure_t", "Label_t_jinglian_disable", false, false)

    self:enableLabelStroke("Label_e_strength_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_e_jinglian_check", Colors.strokeBrown, 2 )  
    self:enableLabelStroke("Label_t_strength_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_t_jinglian_check", Colors.strokeBrown, 2 )  

    self:registerCheckboxEvent("CheckBox_equip_s", function ( widget, type, isCheck )
    	self:_doLoadEquipForStrength()
	end)
	self:registerCheckboxEvent("CheckBox_equip_t", function ( widget, type, isCheck )
    	self:_doLoadEquipForJinglian()
	end)
	self:registerCheckboxEvent("CheckBox_treasure_s", function ( widget, type, isCheck )
    	self:_doLoadTreasureForStrength()
	end)
	self:registerCheckboxEvent("CheckBox_treasure_t", function ( widget, type, isCheck )
    	self:_doLoadTreasureForJinglian()
	end)

	local fullTreasure = G_Me.formationData:isFullTreasureForPos(1, self._curHeroIndex)
	self:enableWidgetByName("CheckBox_treasure_s", fullTreasure)
	self:enableWidgetByName("CheckBox_treasure_t", fullTreasure)

    self:setCheckStatus(1, "CheckBox_equip_s")

    self:enableLabelStroke("Label_equip_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_equip_2", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_equip_3", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_equip_4", Colors.strokeBrown, 1 )

    self:enableLabelStroke("Label_progress_1", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_progress_2", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_progress_3", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_progress_4", Colors.strokeBrown, 1 )

    self:enableLabelStroke("Label_equip_title", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_desc_title", Colors.strokeBrown, 2 )
    
	if not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING) then 
		self:showWidgetByName("CheckBox_equip_t", false)
	end
    if not G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_STRENGTH) then 
		self:showWidgetByName("CheckBox_treasure_s", false)
	end
	if not G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_TRAINING) then 
		self:showWidgetByName("CheckBox_treasure_t", false)
	end
end

function StrengthEquipLayer:_onCloseLayer( ... )
	if self._closeCallback then 
		self._closeCallback()
	end
end

function StrengthEquipLayer:onLayerEnter( ... )
	self:closeAtReturn(true)

	if self._hasEnter then 
		if self._tabIndex == 1 then
			self:_doLoadEquipForStrength() 
		elseif self._tabIndex == 3 then
			self:_doLoadEquipForJinglian() 
		elseif self._tabIndex == 2 then 
			self:_doLoadTreasureForStrength() 
		elseif self._tabIndex == 4 then 
			self:_doLoadTreasureForJinglian() 
		end
	else
		require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	end

	-- 当装备精炼未开启，而宝物强化开启时，把宝物强化的tab往左挪一个tab位
	self:callAfterFrameCount(2, function ( ... )
    	if G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_STRENGTH) and
		not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING) then
		local equipTraining = self:getWidgetByName("CheckBox_equip_t")
		local treasureStrength = self:getWidgetByName("CheckBox_treasure_s")
		if treasureStrength and equipTraining then 
			treasureStrength:setPositionXY(equipTraining:getPosition())
		end
	end
    end)
	

	self._hasEnter = true
end

function StrengthEquipLayer:onBackKeyEvent( ... )
	self:_onCloseLayer()
    return true
end

function StrengthEquipLayer:_onItemClick( index )
	index = index or 1 
	if type(index) ~= "number" or index < 1 or index > 4 then 
		return 
	end

	local itemId = self._equipTreasureIds[index]
	if type(itemId) ~= "number" or itemId < 1 then 
		return 
	end

	local _EquipStrength = function ( itemId )
		local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(itemId)
		require("app.scenes.equipment.EquipmentDevelopeScene").show(equipmentInfo, EquipmentConst.StrengthMode)
	end
	local _EquipRefine = function ( itemId )
		if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_TRAINING) then 
			return 
		end

		local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(itemId)
		require("app.scenes.equipment.EquipmentDevelopeScene").show(equipmentInfo, EquipmentConst.RefineMode)
	end
	local _TreasureStrength = function ( itemId )
		if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_STRENGTH) then 
			return 
		end
		local equipmentInfo = G_Me.bagData.treasureList:getItemByKey(itemId)
		require("app.scenes.treasure.TreasureDevelopeScene").show(equipmentInfo, EquipmentConst.StrengthMode)
	end
	local _TreasureRefine = function ( itemId )
		if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_TRAINING) then 
			return 
		end
		local equipmentInfo = G_Me.bagData.treasureList:getItemByKey(itemId)
		require("app.scenes.treasure.TreasureDevelopeScene").show(equipmentInfo, EquipmentConst.RefineMode)
	end
	-- 点击装备/宝物位时，根据当前tab决定要跳转到的养成界面
	if self._tabIndex == 1 then 
		_EquipStrength(itemId)
	elseif self._tabIndex == 2 then 
		_TreasureStrength(itemId)
	elseif self._tabIndex == 3 then 
		_EquipRefine(itemId)
	elseif self._tabIndex == 4 then 
		_TreasureRefine(itemId)
	end
end

function StrengthEquipLayer:_doLoadEquipForStrength( ... )
	local lastIndex = self._tabIndex
	self._tabIndex = 1

	self:_doLoadEquip(lastIndex)
end

function StrengthEquipLayer:_doLoadEquipForJinglian( ... )
	local lastIndex = self._tabIndex
	self._tabIndex = 3

	self:_doLoadEquip(lastIndex)
end

function StrengthEquipLayer:_doLoadTreasureForStrength( ... )
	local lastIndex = self._tabIndex
	self._tabIndex = 2

	self:_doLoadTreasure(lastIndex)
end

function StrengthEquipLayer:_doLoadTreasureForJinglian( ... )
	local lastIndex = self._tabIndex
	self._tabIndex = 4

	self:_doLoadTreasure(lastIndex)
end

function StrengthEquipLayer:_loadEquipOrTreasure( index, equipId, isEquip )
	index = index or 0
	equipId = equipId or 0
	if type(index) ~= "number" or index > 4 or index < 1 then 
		return 0
	end

	local iconImage = self:getImageViewByName("Image_equip_"..index)
	local nameLabel = self:getLabelByName("Label_equip_"..index)
	local curLevel = 0
	local equipmentInfo = nil 
	if isEquip then 
		equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(equipId)
	else
		equipmentInfo = G_Me.bagData.treasureList:getItemByKey(equipId)
	end

	if equipmentInfo then
		curLevel = (self._tabIndex == 1 or self._tabIndex == 2) and equipmentInfo["level"] or equipmentInfo.refining_level
		local baseInfo = nil 
		if isEquip then 
		 	baseInfo = equipment_info.get(equipmentInfo["base_id"])
		 else
		 	baseInfo = treasure_info.get(equipmentInfo["base_id"])
		 end
       	if baseInfo then
			if iconImage then
				local imgPath = ""
				if isEquip then 
					imgPath = G_Path.getEquipmentIcon(baseInfo.res_id)
				else
					imgPath = G_Path.getTreasureIcon(baseInfo.res_id)
				end
	       		iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
			end
			if nameLabel then
                nameLabel:setColor(Colors.getColor(baseInfo.quality))
				nameLabel:setText(baseInfo.name)
			end
		end
	end

	return curLevel
end

function StrengthEquipLayer:_doLoadEquip( lastIndex )
	local curMinLevel = 1000000
	local equipLevels = {}
	local equips = G_Me.formationData:getFightEquipByPos(1, self._curHeroIndex) or {}
	for loopi = 1, 4, 1 do 
		local equipId = equips["slot_"..loopi] or 0
		self._equipTreasureIds[loopi] = equipId
		local level = self:_loadEquipOrTreasure(loopi, equipId, true) or 0
		equipLevels[loopi] = level
		if level < curMinLevel then 
			curMinLevel = level
		end
	end
	self:showWidgetByName("Button_equip_2", true)
	self:showWidgetByName("Button_equip_4", true)

	if curMinLevel < 0 then 
		curMinLevel = 0
	end

	local targetId, lastTarget, nextTarget = G_Me.formationData:calcTargetLevel(curMinLevel, self._tabIndex)
	for loopi = 1, 4, 1 do 
		local curLevel = equipLevels[loopi] or 0
		local loadingBar = self:getLoadingBarByName("ProgressBar_equip_"..loopi)
		if loadingBar then 
			if nextTarget > 0 then 
				loadingBar:setPercent(curLevel >= nextTarget and 100 or (curLevel*100/nextTarget))
			else
				loadingBar:setPercent(100)
			end
		end

		local progress = self:getLabelByName("Label_progress_"..loopi)
		if progress then 
			if nextTarget > 0 then 
				progress:setText(""..curLevel.."/"..nextTarget)
			else
				progress:setText(""..curLevel.."/"..lastTarget)
			end
		end
	end

	self:_loadEquipOrTreasureAttri(targetId, lastTarget, nextTarget, self._tabIndex, true)
	self:showTextWithLabel("Label_desc", 
		G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_CLICK_EQUIP_TO_STRENGTH" or "LANG_KNIGHT_CLICK_EQUIP_TO_JINGLIAN"))
	self:showTextWithLabel("Label_equip_title", 
		G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_STRENGTH_PROGRESS_DESC" or "LANG_KNIGHT_JIGNLIAN_PROGRESS_DESC"))
	self:showTextWithLabel("Label_desc_title", G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
		{targetName = G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME" ),
		targetLevel = targetId}))
end

function StrengthEquipLayer:_doLoadTreasure( lastIndex )
	local curMinLevel = 1000000
	local equipLevels = {}
	local equips = G_Me.formationData:getFightTreasureByPos(1, self._curHeroIndex) or {}
	for loopi = 1, 2, 1 do 
		local equipId = equips["slot_"..loopi] or 0
		self._equipTreasureIds[loopi > 1 and 3 or 1] = equipId
		local level = self:_loadEquipOrTreasure(loopi > 1 and 3 or 1, equipId, false) or 0
		equipLevels[loopi] = level
		if level < curMinLevel then 
			curMinLevel = level
		end
	end
	self:showWidgetByName("Button_equip_2", false)
	self:showWidgetByName("Button_equip_4", false)

	if curMinLevel < 0 then 
		curMinLevel = 0
	end

	local targetId, lastTarget, nextTarget = G_Me.formationData:calcTargetLevel(curMinLevel, self._tabIndex)
	for loopi = 1, 2, 1 do 
		local ctrlIndex = loopi > 1 and 3 or 1
		local curLevel = equipLevels[loopi] or 0
		local loadingBar = self:getLoadingBarByName("ProgressBar_equip_"..ctrlIndex)
		if loadingBar then 
			if nextTarget > 0 then 
				loadingBar:setPercent(curLevel >= nextTarget and 100 or (curLevel*100/nextTarget))
			else
				loadingBar:setPercent(100)
			end
		end

		local progress = self:getLabelByName("Label_progress_"..ctrlIndex)
		if progress then 
			if nextTarget > 0 then 
				progress:setText(""..curLevel.."/"..nextTarget)
			else
				progress:setText(""..curLevel.."/"..lastTarget)
			end
		end
	end

	self:_loadEquipOrTreasureAttri(targetId, lastTarget, nextTarget, self._tabIndex, false)
	self:showTextWithLabel("Label_desc", 
		G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_CLICK_TREASURE_TO_STRENGTH" or "LANG_KNIGHT_CLICK_TREASURE_TO_JINGLIAN"))
	self:showTextWithLabel("Label_equip_title", 
		G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_STRENGTH_PROGRESS_DESC" or "LANG_KNIGHT_JIGNLIAN_PROGRESS_DESC"))
	self:showTextWithLabel("Label_desc_title", G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
		{targetName = G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME" ), 
		targetLevel = targetId}))
end

-- function StrengthEquipLayer:_calcTargetLevel( curLevel, typeId )
-- 	curLevel = curLevel or 1
-- 	typeId = typeId or 1

-- 	local lastRecordLevel = 0
-- 	local nextRecordLevel = 0
-- 	for loopi = 1, team_target_info.getLength(), 1 do 
-- 		local record = team_target_info._data[loopi]
-- 		if record and typeId == record[2] then 
-- 			if curLevel >= record[3] then 
-- 				lastRecordLevel = record[3]
-- 			elseif curLevel < record[3] then 
-- 				nextRecordLevel = record[3]
-- 				return lastRecordLevel, nextRecordLevel
-- 			end
-- 		end
-- 	end

-- 	return lastRecordLevel, nextRecordLevel
-- end

function StrengthEquipLayer:_loadEquipOrTreasureAttri( targetId, lastTarget, nextTarget, typeId, isEquip )
	lastTarget = lastTarget or 0
	nextTarget = nextTarget or 0
	typeId = typeId or 1

	local panel = self:getWidgetByName("Panel_desc_content")
	if panel then 
		panel:removeAllChildren()
	end
	-- load current level target attributes
	if type(lastTarget) == "number" and lastTarget > 0 then 
		local maxSize = panel:getSize()
		local maxHeight = maxSize.height

		local titleLabel = ""
		if isEquip then 
			titleLabel = G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
				{targetName = G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME" ), 
				targetLevel = targetId})
		else
			titleLabel = G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
				{targetName = G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME" ), 
				targetLevel = targetId})
		end
		--titleLabel = titleLabel.."\n"..G_lang:get("LANG_KNIGHT_TARGET_ACTIVITY")
		if titleLabel then 
			local titleCtrl = GlobalFunc.createGameLabel(titleLabel, 22, Colors.lightColors.TIPS_01 )
			panel:addChild(titleCtrl)
			titleCtrl:setTextHorizontalAlignment(kCCTextAlignmentCenter) 
			titleCtrl:setText(titleLabel, true)
			local titleSize = titleCtrl:getSize()
			titleCtrl:setPosition(ccp(maxSize.width/2, maxHeight - titleSize.height/2))
			maxHeight = maxHeight - titleSize.height
		end

		titleLabel = G_lang:get("LANG_KNIGHT_TARGET_ACTIVITY")
		titleLabel = GlobalFunc.createGameLabel(desc, 22, Colors.lightColors.DESCRIPTION)
		if titleLabel then 
			panel:addChild(titleLabel)
			local titleSize = titleLabel:getSize()
			titleLabel:setPosition(ccp(maxSize.width/2, maxHeight - titleSize.height/2))
			maxHeight = maxHeight - titleSize.height
		end

		local curTargetDesc = ""
		local targetRecord = team_target_info.get(typeId, lastTarget)
		if targetRecord then 
			if targetRecord.att_type_1 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_1, targetRecord.att_value_1).."\n"
			end
			if targetRecord.att_type_2 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_2, targetRecord.att_value_2).."\n"
			end
			if targetRecord.att_type_3 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_3, targetRecord.att_value_3).."\n"
			end
			if targetRecord.att_type_4 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_4).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_4, targetRecord.att_value_4)
			end
		end
		local attriLabel = GlobalFunc.createGameLabel(curTargetDesc, 22, Colors.lightColors.TIPS_01)
		if attriLabel then
			attriLabel:setTextHorizontalAlignment(kCCTextAlignmentCenter) 
			attriLabel:setText(curTargetDesc, true)
			panel:addChild(attriLabel)
			local attriSize = attriLabel:getSize()
			attriLabel:setPosition(ccp(maxSize.width/2, maxHeight - attriSize.height/2))
		end		
	else
		local text = ""
		if isEquip then 
			text = G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_EQUIP_STRENGTH_ATTRI_NULL" or "LANG_KNIGHT_EQUIP_TRAINING_ATTRI_NULL")
		else
			text = G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_TREASURE_STRENGTH_ATTRI_NULL" or "LANG_KNIGHT_TREASURE_TRAINING_ATTRI_NULL")
		end
		local nullLabel = GlobalFunc.createGameLabel(text, 22, Colors.lightColors.TIPS_01)
		if nullLabel then 
			local maxSize = panel:getSize()
			panel:addChild(nullLabel)
			nullLabel:setPosition(ccp(maxSize.width/2, maxSize.height - 50))
		end
	end

	local panel = self:getWidgetByName("Panel_desc_content_1")
	if panel then 
		panel:removeAllChildren()
	end
	-- load next level target attributes
	if type(nextTarget) == "number" and nextTarget > 0 then
		panel:removeAllChildren()
		local maxSize = panel:getSize()
		local maxHeight = maxSize.height

		local desc = ""
		if isEquip then 
			desc = G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
				{targetName = G_lang:get(self._tabIndex == 1 and "LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME" ), 
				targetLevel = targetId + 1})
		else
			desc = G_lang:get("LANG_KNIGHT_TARGET_LEVEL_FORMAT", 
				{targetName = G_lang:get(self._tabIndex == 2 and "LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME" or "LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME" ), 
				targetLevel = targetId + 1})
		end

		--desc = desc.."\n"..G_lang:get(isEquip and "LANG_KNIGHT_EQUIP_STRENGTH_LEVEL" or "LANG_KNIGHT_TREASURE_STRENGTH_LEVEL", {levelValue=nextTarget})
		local titleLabel = GlobalFunc.createGameLabel(desc, 22, Colors.lightColors.DESCRIPTION)
		if titleLabel then 
			panel:addChild(titleLabel)
			local titleSize = titleLabel:getSize()
			titleLabel:setPosition(ccp(maxSize.width/2, maxHeight - titleSize.height/2))
			maxHeight = maxHeight - titleSize.height
		end

		local tName = ""
		if self._tabIndex == 1 then 
			tName = G_lang:get("LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME")
		elseif self._tabIndex == 2 then 
			tName = G_lang:get("LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME")
		elseif self._tabIndex == 3 then 
			tName = G_lang:get("LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME")
		elseif self._tabIndex == 4 then 
			tName = G_lang:get("LANG_KNIGHT_TREASURE_JINGLIAN_TARGET_NAME")
		end
		desc = G_lang:get("LANG_KNIGHT_TARGET_LEVEL_TITLE", {targetName=tName, levelValue=nextTarget})
		--desc = G_lang:get(isEquip and "LANG_KNIGHT_EQUIP_STRENGTH_LEVEL" or "LANG_KNIGHT_TREASURE_STRENGTH_LEVEL", {levelValue=nextTarget})
		titleLabel = GlobalFunc.createGameLabel(desc, 22, Colors.lightColors.DESCRIPTION)
		if titleLabel then 
			panel:addChild(titleLabel)
			local titleSize = titleLabel:getSize()
			titleLabel:setPosition(ccp(maxSize.width/2, maxHeight - titleSize.height/2))
			maxHeight = maxHeight - titleSize.height
		end

		local curTargetDesc = ""
		local targetRecord = team_target_info.get(typeId, nextTarget)
		if targetRecord then 
			if targetRecord.att_type_1 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_1, targetRecord.att_value_1).."\n"
			end
			if targetRecord.att_type_2 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_2, targetRecord.att_value_2).."\n"
			end
			if targetRecord.att_type_3 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_3, targetRecord.att_value_3).."\n"
			end
			if targetRecord.att_type_4 > 0 then
				curTargetDesc = curTargetDesc..G_lang.getGrowthTypeName(
					targetRecord.att_type_4).."+"..G_lang.getGrowthValue(
					targetRecord.att_type_4, targetRecord.att_value_4)
			end
		end
		local attriLabel = GlobalFunc.createGameLabel(curTargetDesc, 22, Colors.lightColors.DESCRIPTION)
		if attriLabel then 
			panel:addChild(attriLabel)
			local attriSize = attriLabel:getSize()
			attriLabel:setPosition(ccp(maxSize.width/2, maxHeight - attriSize.height/2))
		end
		
	else
		local nullLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_KNIGHT_EQUIP_ATTRI_NULL"), 22, Colors.lightColors.TIPS_01)
		if nullLabel then 
			local maxSize = panel:getSize()
			panel:addChild(nullLabel)
			nullLabel:setPosition(ccp(maxSize.width/2, maxSize.height - 50))
		end
	end
end


return StrengthEquipLayer
