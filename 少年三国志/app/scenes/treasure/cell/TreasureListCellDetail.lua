--TreasureListCellDetail.lua
local EquipmentConst = require("app.const.EquipmentConst")
local funLevelConst = require("app.const.FunctionLevelConst")
local BagConst = require("app.const.BagConst")

local TreasureListCellDetail = class("TreasureListCellDetail", function (  )
	return CCSItemCellBase:create("ui_layout/treasure_TreasureListCellDetail.json")
end)


function TreasureListCellDetail.create(  )
	return TreasureListCellDetail.new()
end

function TreasureListCellDetail:getEquipment()
	return self._equipment
end

function TreasureListCellDetail:ctor( ... )
	-- 如果到了可预览铸造的等级，显示铸造按钮
	local canPreviewForge = G_moduleUnlock:canPreviewModule(funLevelConst.TREASURE_FORGE)
	self:showWidgetByName("Button_forge", canPreviewForge)

	if canPreviewForge then
		-- 把强化和精炼按钮往前移
		local btnStrength = self:getButtonByName("Button_strength")
		local btnXilian = self:getButtonByName("Button_xilian")
		local interval = btnXilian:getPositionX() - btnStrength:getPositionX()
		btnStrength:setPositionX(btnStrength:getPositionX() - interval)
		btnXilian:setPositionX(btnXilian:getPositionX() - interval)
	end

	self:registerBtnClickEvent("Button_strength", handler(self, self._onStrengthClick))
	self:registerBtnClickEvent("Button_xilian", handler(self, self._onXilianClick))
	self:registerBtnClickEvent("Button_forge", handler(self, self._onForgeClick))
	self:registerBtnClickEvent("Button_rob", handler(self, self._onRobClick))
end

function TreasureListCellDetail:updateDetail( equipment )
	self._equipment = equipment

	
	local level = equipment.level
	local maxLevel = equipment:getMaxStrengthLevel()
	if not G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_STRENGTH) then 
		self:showWidgetByName("Label_strength_level", true)
		print(1)
		self:showTextWithLabel("Label_strength_level", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.TREASURE_STRENGTH)}))
	elseif level >= maxLevel then 
		self:showWidgetByName("Label_strength_level", true)
		print(2)
		self:showTextWithLabel("Label_strength_level", G_lang:get("LANG_MAX_VALUE"))
	else
		self:showWidgetByName("Label_strength_level", false)
	end


	local refining_level = equipment.refining_level
	local maxRefineLevel = equipment:getMaxRefineLevel()
	if not G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_TRAINING) then 
		self:showWidgetByName("Label_xilian_level", true)
		self:showTextWithLabel("Label_xilian_level", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.TREASURE_TRAINING)}))
	elseif refining_level >= maxRefineLevel then 
		self:showWidgetByName("Label_xilian_level", true)
		self:showTextWithLabel("Label_xilian_level", G_lang:get("LANG_MAX_VALUE"))
	else
		self:showWidgetByName("Label_xilian_level", false)
	end

	local info = equipment:getInfo()
	if info.type == 3 then 
	    -- 经验宝物
		self:getLabelByName("Label_strength_level"):setText(G_lang:get("LANG_CANNOT_STRENGTH"))
		self:getLabelByName("Label_xilian_level"):setText(G_lang:get("LANG_CANNOT_REFINE"))
		self:showWidgetByName("Label_strength_level", true)
		self:showWidgetByName("Label_xilian_level", true)
	end

	self:showWidgetByName("Label_cannot_forge", info.type == 3 or info.quality ~= BagConst.QUALITY_TYPE.ORANGE)
	self:showWidgetByName("ImageView_rob_level", false)

end

function TreasureListCellDetail:_onStrengthClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_STRENGTH) then 
		return 
	end
	require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.StrengthMode)
end


function TreasureListCellDetail:_onXilianClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_TRAINING) then 
		return 
	end
	require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.RefineMode)
end

function TreasureListCellDetail:_onForgeClick( ... )
	local treasureInfo = self._equipment:getInfo()

	-- 经验宝物不可铸造
	if treasureInfo.type == 3 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_EXP_CANNOT_FORGE"))
		return
	end

	-- 非橙色宝物不可铸造
	if self._equipment:getInfo().quality ~= BagConst.QUALITY_TYPE.ORANGE then
		G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_FORGE_CONDITION"))
		return
	end

	if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_FORGE) then
		require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.ForgeMode)
	end
end

function TreasureListCellDetail:_onRobClick( ... )
	require("app.cfg.function_level_info")
	local levelLimit = function_level_info.get(require("app.const.LevelLimitConst").DUO_BAO ).level
	-- uf_sceneManager:pushScene(require("app.scenes.treasure.TreasureRobMainScene").new())
	if G_Me.userData.level < levelLimit then
	    G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_PLUNDER_TIPS",{level=levelLimit}))
	    return
	end
	
	--uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new())
	uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil, nil, nil, nil,
		GlobalFunc.sceneToPack("app.scenes.treasure.TreasureMainScene",{}),true))
end
return TreasureListCellDetail
