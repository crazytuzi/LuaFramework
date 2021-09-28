--FriendMailInputLayer.lua


local FriendMailInputLayer = class ("FriendMailInputLayer", UFCCSModelLayer)


function FriendMailInputLayer:ctor( ... )
	self._inputRichText = nil
	self._curInputContent = ""
	self._defaultColor = ccc3(255, 255, 255)
	self.super.ctor(self, ...)

	self:adapterWithScreen()
	--self:setClickClose(true)

	self._callback = nil
	self._target = nil
end

function FriendMailInputLayer:onLayerEnter( ... )
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	-- self:showWidgetByName("ImageView_input_back", false)
	-- self:showWidgetByName("Button_ok", false)
	-- self:showWidgetByName("Button_face", false)
	-- GlobalFunc.flyFromMiddleToSize(self:getWidgetByName("ImageView_back"), 0.3, 0, function ( ... )
	-- 	self:showWidgetByName("ImageView_input_back", true)
	-- 	self:showWidgetByName("Button_ok", true)
	-- 	self:showWidgetByName("Button_face", true)
 --            end)

	
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_back"), "smoving_bounce")
end

function FriendMailInputLayer:onBackKeyEvent( ... )
    self:_onChangeInputText()
    return true
end

function FriendMailInputLayer:_enableSendBtn( enable )
	self:enableWidgetByName("Button_ok", enable)
end

function FriendMailInputLayer:onLayerLoad( )
    --self:registerTouchEvent(false,true,0)
    local createStroke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 1)
        end
    end
    -- createStroke("Label_model")

    self._editbox = self:getTextFieldByName("TextField_input")
    if self._editbox then 
    	self._editbox:setText("")
    	local glbalConst = require("app.const.GlobalConst")
    	self._editbox:setMaxLengthEnabled(true)
    	self._editbox:setMaxLength( glbalConst.CHAT_MSG_LENGTH_MAX )
    	self._editbox:setReturnType(kCCSKeyboardReturnTypeDone)
    end
	self:registerTextfieldEvent("TextField_input", function ( ... )
		self:_onTextFieldEvent( ... )
	end)

	local label = self:getLabelByName("Label_model")
	if label then 
		local size = label:getSize()
		self._inputRichText = CCSRichText:create(size.width, size.height)
    	self._inputRichText:setFontSize(label:getFontSize())
    	self._inputRichText:setFontName(label:getFontName())
    	local color = label:getColor()
    	self._defaultColor = ccc3(color.r, color.g, color.b)
    	self._inputRichText:setColor(self._defaultColor)
    	self._inputRichText:setShowTextFromTop(true)
    	-- self._inputRichText:enableStroke(Colors.strokeBrown)
    	self._inputRichText:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)
    	local backImg = self:getWidgetByName("ImageView_input_back")
    	if backImg then 
    		backImg:addChild(self._inputRichText)
    	else
    		__LogError("ImageView_input_back is nil!")
    	end
    	self._inputRichText:setVisible(false)
	end

	self:registerWidgetClickEvent("ImageView_input_back", function ( ... )
		self:_onShowInputBox( true )
	end)

	self:registerBtnClickEvent("Button_ok", function ( widget )
		self:_onChangeInputText(true)
	end)

	self:registerBtnClickEvent("Button_cancel", function ( widget )
		self:_onChangeInputText()
	end)
end

function FriendMailInputLayer:_initChatObject( userName, userKid )

	if type(userName) ~= "string" or not userKid then 
		return 
	end

	if #userName <= 0 or userKid <= 0 then 
		return
	end


	local getColorForKid = function( kid )
		kid = kid or 0
		if kid <= 0 then 
			local mainKnight = G_Me.bagData.knightsData:getMainKightInfo()
			kid = mainKnight and mainKnight["base_id"] or 0
		end

		local quality = 1
		local knightInfo = knight_info.get(kid or 0)
		if knightInfo then 
			quality = knightInfo.quality
		end

		local clr = Colors.getColor(knightInfo.quality)
		return 0xb1* 256*256 + 0xef*256 + 0x65
		-- return clr.r * 256*256 + clr.g*256 + clr.b
	end

	local text = G_lang:get("LANG_CHAT_TIP_SAY_TO_SOMEBODY", {receive_name = userName, clrValue=getColorForKid(userKid)})
	local panel = self:getWidgetByName("Panel_to_someone")
	local rect = panel:getSize()
	-- local label = GlobalFunc.createGameRichtext(text, 24, ccc3(255, 255, 255), Colors.strokeBrown)
	local richtext = CCSRichText:create(rect.width, rect.height)
	richtext:setFontSize(24)
	richtext:setFontName("ui/font/FZYiHei-M20S.ttf")
	richtext:setColor(ccc3(255, 255, 255))
	richtext:enableStroke(Colors.strokeBrown)
	richtext:setShowTextFromTop(true)
	richtext:appendContent(text, ccc3(255, 255, 255))
	richtext:reloadData()
	richtext:adapterContent()
	
	if panel then 
		local size = panel:getSize()
		local labelSize = richtext:getSize()
		panel:addChild(richtext)
		richtext:setPosition(ccp(labelSize.width/2, size.height/2))
	end
end

function FriendMailInputLayer:_onShowInputBox( show )
	self:showWidgetByName("Label_model", #self._curInputContent < 1 and not show)
	if self._inputRichText then
		self._inputRichText:setVisible(#self._curInputContent > 0 and not show)
	end
	self._editbox:setVisible(show)
	if show then 
		self._editbox:setText(self._curInputContent)
		self:callAfterFrameCount(2, function ( ... )
			self._editbox:openKeyboard()
		end)
	end
end


function FriendMailInputLayer:_onParseFace( content )
	if content == nil or content == "" then
		return
	end

	local faceFile = string.format("ui/chat/face/%s", content)
	faceFile = CCFileUtils:sharedFileUtils():fullPathForFilename(faceFile)
	if not CCFileUtils:sharedFileUtils():isFileExist(faceFile) then
		__LogError("file is not exist:%s", faceFile)
		return
	end

	local faceImg = ImageView:create()
	faceImg:loadTexture(faceFile, UI_TEX_TYPE_LOCAL) 

	return faceImg
end

function FriendMailInputLayer:onChooseFace( fileName )
	if fileName == nil or fileName == "" then
		return 
	end

	self._curInputContent = self._curInputContent or ""
	local face = string.format("[%s]", fileName)
	self._curInputContent = self._curInputContent..face
	
	self:_updateRichText()
	self:_onShowInputBox()
end

function FriendMailInputLayer:_updateRichText( ... )
	if self._inputRichText then 
		self._inputRichText:clearRichElement()
		self._inputRichText:appendContent(self._curInputContent, self._defaultColor)
		self._inputRichText:reloadData()
	end
end

function FriendMailInputLayer:_onTextFieldEvent( textfield, eventType )
	if eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
		local text = self._editbox:getStringValue()
		if device.platform == "wp8" or device.platform == "winrt" then
			local label = self:getLabelByName("Label_model")
        	text = label:deleteInvalidChars(text)
        else
			text = FTLabelManager:getInstance():deleteInvalidChars(text)
		end
		self._curInputContent = text
		self:_updateRichText()
		self:_onShowInputBox( false )
	elseif eventType == CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME then 
		self:_enableSendBtn(false)
	elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then 
		self:_enableSendBtn(true)

	end
end

function FriendMailInputLayer.showInputLayer( parent, text, userName, userKid, callback, target )
	if parent == nil then
		return 
	end

	local inputPanel = FriendMailInputLayer.new("ui_layout/friend_FriendMailInput.json", ccc4(0, 0, 0, 100))
	parent:addChild(inputPanel)
	inputPanel._callback = callback
	inputPanel._target = target

	inputPanel._curInputContent = text
	inputPanel:_updateRichText()
	inputPanel:_initChatObject(userName, userKid)
	inputPanel:_onShowInputBox( false )
end

function FriendMailInputLayer:_onChangeInputText( send )
	send = send or false

	if send and G_GlobalFunc then 
		if G_GlobalFunc.matchText(self._curInputContent) then 
		        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_INVALID_TEXT"))
		        return false
		end
		self._curInputContent = G_GlobalFunc.filterText(self._curInputContent)
	end
	
	if self._callback ~= nil and self._target ~= nil then
 		self._callback(self._target, self._curInputContent, send)
 	elseif self._callback ~= nil then
 		self._callback(self._curInputContent, send)
 	end

 	self:animationToClose()
end

function FriendMailInputLayer:onTouchEnd( xpos, ypos )
	local clickPanel = true
	local backImg = self:getWidgetByName("ImageView_back")
	if backImg then 
		local posx, posy = backImg:getPosition()
		local size = backImg:getSize()
		local rect = CCRectMake(posx - size.width/2, posy - size.height/2, size.width, size.height)
		--clickPanel = rect:containsPoint(ccp(xpos, ypos))
		clickPanel =  G_WP8.CCRectContainXY(rect, xpos, ypos)
	end

	if not clickPanel then 
		self:_onChangeInputText()
	end
end

return FriendMailInputLayer
