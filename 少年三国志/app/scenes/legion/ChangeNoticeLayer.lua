--ChangeNoticeLayer.lua

local ChangeNoticeLayer = class("ChangeNoticeLayer", UFCCSModelLayer)


function ChangeNoticeLayer.show( ... )
	local changeNotice = ChangeNoticeLayer.new("ui_layout/legion_ChangeNotice.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(changeNotice)
end

function ChangeNoticeLayer:ctor( ... )
	self._maxCharLength = 0
	self.super.ctor(self, ...)
end

function ChangeNoticeLayer:onLayerLoad( _, _, noticeType )
	self:closeAtReturn(true)
	self:registerBtnClickEvent("Button_cancel", handler(self, self._onCancelClick))
	self:registerWidgetClickEvent("Label_input_text", handler(self, self._onBeginEditNotice))
	self:registerTextfieldEvent("TextField_input",function ( textfield, eventType )
		self:_onInputNoticeEvent(eventType)     
     end)

	noticeType = noticeType or 1
	self:showWidgetByName("Image_title_1", noticeType == 2)
	self:showWidgetByName("Image_title_2", noticeType == 1)
	self._placeHolder = G_lang:get((noticeType == 1) and "LANG_LEGION_CHANGE_DESC_PLACEHOLDER" or "LANG_LEGION_CHANGE_NOTICE_PLACEHOLDER")

	local maxTextLen = (noticeType == 1) and 40 or 20
	self._maxCharLength = maxTextLen
	self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_MAX_DESC_LENGTH", {maxLength = maxTextLen}))
	local textfield = self:getTextFieldByName("TextField_input")
	if textfield then 
		textfield:setMaxLengthEnabled(true)
		textfield:setMaxLength(self._maxCharLength*3)
		textfield:setPlaceHolder(self._placeHolder)
	end

	self:registerBtnClickEvent("Button_save", function ( ... )
		self:_onChangeNotify( noticeType )
	end)

	self:showWidgetByName("TextField_input", true)
	self:showWidgetByName("Label_input_text", false)
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if not detailCorp then 
		self:showTextWithLabel("Label_input_text", self._placeHolder)
	else
		local text = noticeType == 1 and detailCorp.notification or detailCorp.announcement
		self:showTextWithLabel("Label_input_text", text == "" and self._placeHolder or text)
		local textfield = self:getTextFieldByName("TextField_input")
		if textfield then 
			textfield:setText(text)
		end
	end    
end

function ChangeNoticeLayer:onLayerEnter( ... )
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce", function ( ... )
		local textfield = self:getTextFieldByName("TextField_input")
		if textfield then 
			textfield:openKeyboard()
		end
	end)
	
end

function ChangeNoticeLayer:_onCancelClick( ... )
	self:animationToClose()
end

function ChangeNoticeLayer:_onChangeNotify( noticeType )
	local textfield = self:getTextFieldByName("TextField_input")
	if not textfield then 
		return 
	end

	local text = textfield:getStringValue() or ""
	if G_GlobalFunc.matchText(text) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_INVALID_NAME"))
	end

	__Log("self._maxCharLength:%d, textlength:%d", self._maxCharLength, string.utf8len(text))
	if self._maxCharLength > 0 and string.utf8len(text) > self._maxCharLength then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_EXCEED_MAX_LENGTH", {maxLength = self._maxCharLength}))
	end

	if #text < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_INPUT_TEXT_NULL"))
	end

	local detailCorp = G_Me.legionData:getCorpDetail() 
	if detailCorp then 
		G_HandlersManager.legionHandler:sendModifyCorp(noticeType == 2 and text or detailCorp.announcement, 
			detailCorp.icon_pic, detailCorp.icon_frame, noticeType == 1 and text or detailCorp.notification)
		self:animationToClose()
	end
end

function ChangeNoticeLayer:_onBeginEditNotice( ... )
	self:showWidgetByName("Label_input_text", false)
	self:showWidgetByName("TextField_input", true)
	self:callAfterFrameCount(2, function ( ... )
		local textfield = self:getTextFieldByName("TextField_input")
		if textfield then 
			textfield:openKeyboard()
		end
	end)
end

function ChangeNoticeLayer:_onInputNoticeEvent( eventType )
	if eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then 
		self:showWidgetByName("Label_input_text", true)
		self:showWidgetByName("TextField_input", false)

		local textfield = self:getTextFieldByName("TextField_input")
		if textfield then 
			local text = textfield:getStringValue()
			self:showTextWithLabel("Label_input_text", text == "" and self._placeHolder or text)
		end
	end
end

return ChangeNoticeLayer

