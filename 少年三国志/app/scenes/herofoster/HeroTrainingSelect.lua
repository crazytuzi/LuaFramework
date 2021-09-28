--HeroTrainingSelect.lua


local HeroTrainingSelect = class ("HeroTrainingSelect", UFCCSModelLayer)

function HeroTrainingSelect:ctor( ... )
	self._handler = nil
	self._target = nil
	self._params = nil

	self.super.ctor(self, ...)
end

function HeroTrainingSelect:onLayerLoad( ... )
	self:enableLabelStroke("Label_1_1", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_1_0", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_1", Colors.strokeBlack, 2)

	self:closeAtReturn(true)
	self:registerBtnClickEvent("Button_close", function ( widget )
		self:animationToClose()
	end)

	self:registerBtnClickEvent("Button_1", function ( widget )
		self:_onTrainingTimesSelect(1)
	end)

	self:registerBtnClickEvent("Button_5", function ( widget )
		self:_onTraining5TimesSelect()
	end)

	self:registerBtnClickEvent("Button_10", function ( widget )
		self:_onTraining10TimesSelect()
	end)

	if G_Me.userData.vip < 4 then
		local label = self:getLabelByName("Label_tip_5")
		if label  then
			label:setColor(ccc3(0xf2, 0x79, 0x0d))
			label:setText(G_lang:get("LANG_KNIGHT_TRAINING_VIP", {vip_num="4"}))
		end

		-- local btn = self:getButtonByName("Button_5")
		-- if btn then
		-- 	btn:loadTextureNormal("board_gray.png", UI_TEX_TYPE_PLIST)
		-- end
	end

	if G_Me.userData.vip < 5 then
		local label = self:getLabelByName("Label_tip_10")
		if label  then
			label:setColor(ccc3(0xf2, 0x79, 0x0d))
			label:setText(G_lang:get("LANG_KNIGHT_TRAINING_VIP", {vip_num="5"}))
		else
			label:setColor(Colors.titleRed)
			label:setText(label:getStringValue())
		end
		-- local btn = self:getButtonByName("Button_10")
		-- if btn then
		-- 	btn:loadTextureNormal("board_gray.png", UI_TEX_TYPE_PLIST)
		-- end
	end
end

function HeroTrainingSelect:onLayerEnter( ... )
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function HeroTrainingSelect:_onTrainingTimesSelect( count )
	count = count or 1
	self:_excuteCallback( count or 1 )
	--self:close()
	self:animationToClose()
end

function HeroTrainingSelect:_onTraining5TimesSelect( ... )
	if G_Me.userData.vip < 4 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_MSGBOX_TRAINING_VIP_ALERT", 
			{vip_level = G_lang:get("LANG_MSGBOX_TRAINING_VIP_4"), xilian_times = G_lang:get("LANG_MSGBOX_TRAINING_XILIAN_5")}))
		--return MessageBoxEx.showCustomMessage(nil, G_lang:get("LANG_MSGBOX_TRAINING_VIP_ALERT", 
			--{vip_level = G_lang:get("LANG_MSGBOX_TRAINING_VIP_2"), xilian_times = G_lang:get("LANG_MSGBOX_TRAINING_XILIAN_5")}),
			--MessageBoxEx.CustomButton.CustomButton_Pay, self._onPayClick, nil, self)
	end
	self:_onTrainingTimesSelect(5)
end

function HeroTrainingSelect:_onTraining10TimesSelect( ... )
	if G_Me.userData.vip < 5 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_MSGBOX_TRAINING_VIP_ALERT", 
			{vip_level = G_lang:get("LANG_MSGBOX_TRAINING_VIP_5"), xilian_times = G_lang:get("LANG_MSGBOX_TRAINING_XILIAN_10")}))
		--return MessageBoxEx.showCustomMessage(nil, G_lang:get("LANG_MSGBOX_TRAINING_VIP_ALERT", 
		--	{vip_level = G_lang:get("LANG_MSGBOX_TRAINING_VIP_4"), xilian_times = G_lang:get("LANG_MSGBOX_TRAINING_XILIAN_10")}),
		--MessageBoxEx.CustomButton.CustomButton_Pay, self._onPayClick, nil, self)
	end

	self:_onTrainingTimesSelect(10)
end

function HeroTrainingSelect:_onPayClick( ... )
	__Log("_onPayClick")
end

function HeroTrainingSelect:initCallback( func, target, ... )
	self._handler = func
 	self._target = target
 	self._params = {...}
end

function HeroTrainingSelect:_excuteCallback( index )
	if self._handler ~= nil and self._target ~= nil then
 		self._handler(self._target, index, self._params )
 	elseif self._handler ~= nil then
 		self._handler(index, self._params)
 	else
 		__Log("all is nil")
 	end
end

function HeroTrainingSelect.showTrainingSelectLayer( parent, func, target, ... )
	if parent == nil then 
		return 
	end

	local traingingSelect = require("app.scenes.herofoster.HeroTrainingSelect").new("ui_layout/HeroTraining_Select.json", Colors.modelColor)
 	traingingSelect:initCallback(func, target, ...)

 	parent:addChild(traingingSelect)
 	traingingSelect:showAtCenter(true)
end

return HeroTrainingSelect
