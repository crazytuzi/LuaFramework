--LegionCreateLayer.lua

local LegionCreateLayer = class("LegionCreateLayer", UFCCSModelLayer)

LegionCreateLayer.DEFAULT_ICON_BACK = 1
LegionCreateLayer.DEFAULT_GOLD_COST = 100

function LegionCreateLayer.createLegion( ... )
	local legionLayer = LegionCreateLayer.new("ui_layout/legion_CreateLegion.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionCreateLayer:ctor( ... )
	require("app.cfg.corps_value_info")
	LegionCreateLayer.DEFAULT_GOLD_COST = corps_value_info.get(1).value
	self.super.ctor(self, ...)
	self._defaultIcon = 0
end

function LegionCreateLayer:onLayerLoad( ... )
	self:closeAtReturn(true)
	self:registerBtnClickEvent("Button_cancel", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_create", handler(self, self._onCreateClick))

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_10", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_cost_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_cost_value", Colors.strokeBrown, 1 )

	self:showTextWithLabel("Label_cost_value", LegionCreateLayer.DEFAULT_GOLD_COST)

	self:registerWidgetClickEvent("Image_icon_back_1", function ( ... )
		self:_onSelectIconBack( 1 )
	end)
	self:registerWidgetClickEvent("Image_icon_back_2", function ( ... )
		self:_onSelectIconBack( 2 )
	end)
	self:registerWidgetClickEvent("Image_icon_back_3", function ( ... )
		self:_onSelectIconBack( 3 )
	end)
	self:_onSelectIconBack(LegionCreateLayer.DEFAULT_ICON_BACK)
end

function LegionCreateLayer:onLayerEnter( ... )
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function LegionCreateLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionCreateLayer:_onCreateClick( ... )
	local textfield = self:getTextFieldByName("TextField_legion")
	if textfield then 
		local text = textfield:getStringValue() or ""
		if G_GlobalFunc.matchText(text) then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_INVALID_NAME"))
		end

		if string.utf8len(text) < 2 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_NAME_TOOSHORT"))
		end

		if string.utf8len(text) > 18 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_NAME_TOOLONG"))
		end

		if G_Me.userData.gold < LegionCreateLayer.DEFAULT_GOLD_COST then 
			return require("app.scenes.shop.GoldNotEnoughDialog").show()
			--return G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
		end

		MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_BE_SURE_CREATE_LEGION", {costValue=LegionCreateLayer.DEFAULT_GOLD_COST or 100}), false, function ( ... )
			G_HandlersManager.legionHandler:sendCreateCorp(text, self._defaultIcon, 1)
			self:animationToClose()
		end, 
		function ( ... )
			--self:animationToClose()
		end)	
	end	
end

function LegionCreateLayer:_onSelectIconBack( index )
	index = index or 1

	if index == self._defaultIcon then 
		return 
	end

	self._defaultIcon = index
	self:showWidgetByName("Image_choose_1", index == 1)
	self:showWidgetByName("Image_choose_2", index == 2)
	self:showWidgetByName("Image_choose_3", index == 3)
end

return LegionCreateLayer

