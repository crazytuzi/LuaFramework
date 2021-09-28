-- 仅仅显示称号信息的弹窗

require("app.cfg.title_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local TitleDetailDialogInfo = class("TitleDetailDialogInfo", UFCCSModelLayer)

function TitleDetailDialogInfo.create(index, dialogType, ...)
	return TitleDetailDialogInfo.new("ui_layout/title_dialog_info.json",Colors.modelColor, index, dialogType, ...)
end

function TitleDetailDialogInfo:ctor(json, colors, index, dialogType, ...)
	self.super.ctor(self, ...)

	self:showAtCenter(true)
	self:registerTouchEvent(false, true, 0)

	self._titleIndex = index

	-- local titleInfo = title_info.indexOf(self._titleIndex)
	local titleInfo = title_info.get(self._titleIndex)

	-- 该称号对应的背景图片
	local titleNameBg = self:getImageViewByName("Image_Title_Bg")
	-- dump(titleInfo)
	local uiResName = titleInfo.picture
	titleNameBg:loadTexture(uiResName, UI_TEX_TYPE_LOCAL)

	-- 初始化称号名
	local titleName = titleInfo.name
	local titleNameLabel = self:getLabelByName("Label_Title_Name")
	local quality = titleInfo.quality
	titleNameLabel:setColor(Colors.getColor(quality))
	titleNameLabel:setText(titleName) 
	titleNameLabel:createStroke(Colors.strokeBrown, 3)

	-- 具体描述
	local titleDetail = titleInfo.directions2
	self:getLabelByName("Label_Title_Detail"):setText(titleDetail)

	-- 属性名
	-- local  valueString =  G_lang.getGrowthValue(type, value)
  	-- local  typeString = G_lang.getGrowthTypeName(type) 
	local typeAIncrease = titleInfo.strength_type_1
	self:getLabelByName("Label_Health"):setText(G_lang.getGrowthTypeName(typeAIncrease) .. ":")
	local typeBIncrease = titleInfo.strength_type_2
	self:getLabelByName("Label_Attack"):setText(G_lang.getGrowthTypeName(typeBIncrease) .. ":")

	-- 属性增加值
	local valueAIncrease = titleInfo.strength_value_1
	self:getLabelByName("Label_Health_Increase_Value"):setText(G_lang.getGrowthValue(typeAIncrease, valueAIncrease))
	local valueBIncrease = titleInfo.strength_value_2
	self:getLabelByName("Label_Attack_Increase_Value"):setText(G_lang.getGrowthValue(typeBIncrease, valueBIncrease))

	if dialogType == 0 then
		-- 未激活状态显示去获取按钮
		__Log("dialogType 0")
		self:showWidgetByName("Button_Equip", false)
		self:showWidgetByName("Button_Unequip", false)
		self:showWidgetByName("Button_Get", true)
		local effectTimeLabel = self:getLabelByName("Label_Effect_Time_Des")
		effectTimeLabel:setVisible(true)
		-- 称号有效时限
		local effectTime = titleInfo.effect_time / (60 * 60 * 24)
		if effectTime < 1 then
			effectTime = string.format("%.2f", effectTime) 
		end
		effectTimeLabel:setText("令牌可激活称号" .. effectTime .. "天")
		-- effectTimeLabel:createStroke(Colors.strokeBrown, 1)

		self:registerBtnClickEvent("Button_Get", function ( ... )
			-- 如果是活动称号
			if titleInfo.type1 == 4 then
				G_MovingTip:showMovingTip(G_lang:get("LANG_TITLE_ACTIVITY_DUANWU"))
				return
			elseif titleInfo.type1 == 5 then
				local FunctionLevelConst = require("app.const.FunctionLevelConst")
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CROSS_PVP) then 
					-- self._scenePack = GlobalFunc.generateScenePack()
					-- require("app.scenes.crosspvp.CrossPVP").launch(self._scenePack)
					G_MovingTip:showMovingTip(G_lang:get("LANG_TITLE_ACTIVITY_DUANWU"))
				end
				return
			end				
			self._scenePack = GlobalFunc.generateScenePack()
			uf_sceneManager:replaceScene(require("app.scenes.crosswar.CrossWarScene").new(nil, nil, nil, nil, nil, self._scenePack))
		end)

		--TODO: 创建continue图片
    	-- self:_showContinue(300)
    	-- self:setClickClose(true)
	elseif dialogType == 1 then
		-- 装备
		-- self:getButtonByName("Button_Equip"):setVisible(true)
		-- self:getButtonByName("Button_Unequip"):setVisible(false)
		self:showWidgetByName("Button_Equip", true)
		self:showWidgetByName("Button_Unequip", false)
		self:showWidgetByName("Button_Get", false)

		self:registerBtnClickEvent("Button_Equip", function ( ... )
			self:_onEquipClick()
		end)
	elseif dialogType == 2 then
		-- 卸下
		-- self:getButtonByName("Button_Equip"):setVisible(false)
		-- self:getButtonByName("Button_Unequip"):setVisible(true)
		self:showWidgetByName("Button_Equip", false)
		self:showWidgetByName("Button_Unequip", true)
		self:showWidgetByName("Button_Get", false)

		self:registerBtnClickEvent("Button_Unequip", function ( ... )
			self:_onUnequipClick()
		end)
	else
		self:showWidgetByName("Button_Equip", false)
		self:showWidgetByName("Button_Unequip", false)
		self:showWidgetByName("Button_Get", false)
	end
end


function TitleDetailDialogInfo:_onEquipClick( ... )
	G_HandlersManager.titleHandler:sendChangeTitle(self._titleIndex)
	self:animationToClose()
end

function TitleDetailDialogInfo:_onUnequipClick( ... )
	G_HandlersManager.titleHandler:sendChangeTitle(0)
	self:animationToClose()
end

function TitleDetailDialogInfo:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getImageViewByName("Image_Continue"), "smoving_wait", nil , {position = true} )
end

function TitleDetailDialogInfo:onTouchEnd( xpos, ypos )
    self:animationToClose()
end


return TitleDetailDialogInfo