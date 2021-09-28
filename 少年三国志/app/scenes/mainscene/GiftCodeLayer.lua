local GiftCodeLayer = class("GiftCodeLayer",UFCCSModelLayer)

function GiftCodeLayer.show()
	local layer = GiftCodeLayer.new("ui_layout/setting_GiftCodeLayer.json",Colors.modelColor)
	--设置位置中上
	local widget = layer:getWidgetByName("Panel_15")
	local mainSize = CCDirector:sharedDirector():getWinSize()
	local size = widget:getContentSize()
	local x = (mainSize.width-size.width)/2
	local y = (mainSize.height-size.height)/2 + 200
	widget:setPosition(ccp(x,y))
	uf_sceneManager:getCurScene():addChild(layer)
end

function GiftCodeLayer:ctor( ... )
	self.super.ctor(self,...)
	-- self:showAtCenter(true)
	self._editbox = self:getTextFieldByName("TextField_giftcode")
    if self._editbox then 
    	self._editbox:setText("")
    	self._editbox:setReturnType(kCCSKeyboardReturnTypeDone)
    end

	self:_initEvent()
end

function GiftCodeLayer:_initEvent()
	self:registerTextfieldEvent("TextField_giftcode", function ( ... )

	end)
	self:registerBtnClickEvent("Button_ok",function()
		local code = self._editbox:getStringValue()
		if not code or code == "" then
			G_MovingTip:showMovingTip(G_lang:get("LANG_GET_GIFT_CODE_IS_NIL"))
			return
		end
		G_HandlersManager.bagHandler:sendGiftCode(code)
		end)
	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_no",function()
		self:animationToClose()
		end)
	self:registerWidgetClickEvent("Panel_input",function()

		end)
end

function GiftCodeLayer:onLayerEnter( ... )
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_CODE_INFO, self._onGiftCode, self)
end

function GiftCodeLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function GiftCodeLayer:_onGiftCode(data)
	if data and data.ret == 1 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_GET_GIFT_CODE_SUCCESS"))
	end
end

return GiftCodeLayer