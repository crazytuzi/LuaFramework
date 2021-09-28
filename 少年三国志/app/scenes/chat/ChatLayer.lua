--ChatLayer.lua


require("app.cfg.knight_info")
require("app.cfg.title_info")
require("app.cfg.frame_info")

local storage = require("app.storage.storage")
local ChatLayer = class ("ChatLayer", UFCCSModelLayer)


function ChatLayer:ctor( json, func, channel, param, func, ... )
	self._worldRichtext = nil 
	self._unionMsgList = nil 
	self._someoneMsgList = nil 
	self._channeId = channel or 1
	self._func = func

	self._selfChatKid = 0
	self._selfChatName = ""

	self._curMsgContent = ""
	self._defaultColor = ccc3(0x50, 0x3e, 0x32)

	self._sendRichText = nil
	self._layerMoveOffset = 0

	self._isNameFieldAttach = false
	self._isContentFieldAttach = false

	local sharedApplication = CCApplication:sharedApplication()
  	local target = sharedApplication:getTargetPlatform()
  	self._isAndroidPlatform = (target == kTargetAndroid)

	self.super.ctor(self, json, func, channel, param, ...)

	uf_sceneManager:getCurScene():addChild(self, 10)
	self:showAtCenter(true)



	-- 1: world channel
	-- 2: union channel
	-- 3: someone channel
end

function ChatLayer:onLayerLoad( json, func, channel, param, ... )
	self:registerWidgetClickEvent("Image_input_back", function ( ... )
		self:onClickInputBox()
	end)

	--self:enableLabelStroke("Label_someone_name", Colors.strokeBrown, 1 )
	local createStroke = function ( name )
        local label = self:getLabelByName(name)
        if label then 
            label:createStroke(Colors.strokeBrown, 1)
        end
    end
    --createStroke("Label_to")
    --createStroke("Label_say")
    --createStroke("Label_input_label")

    self._checkLabel = self:getLabelByName("Label_world_check")

    self:enableLabelStroke("Label_world_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_someone_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_union_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_team_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_choose_tip", Colors.strokeBrown, 1)

	self:addCheckNodeWithStatus("CheckBox_world", "Label_world_check", true)
    self:addCheckNodeWithStatus("CheckBox_world", "Label_world_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_world", "Panel_msg_list_world", true)

    self:addCheckNodeWithStatus("CheckBox_someone", "Label_someone_check", true)
    self:addCheckNodeWithStatus("CheckBox_someone", "Label_someone_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_someone", "Panel_chat_someone", true)

    self:addCheckNodeWithStatus("CheckBox_union", "Label_union_check", true)
    self:addCheckNodeWithStatus("CheckBox_union", "Label_union_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_union", "Panel_list_union", true)
    self:addCheckNodeWithStatus("CheckBox_union", "Label_union_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_team", "Label_team_check", true)
    self:addCheckNodeWithStatus("CheckBox_team", "Label_team_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_team", "Panel_list_team", true)
    self:addCheckNodeWithStatus("CheckBox_team", "Label_team_disable", false, false)

	self:addCheckBoxGroupItem(1, "CheckBox_world")
	self:addCheckBoxGroupItem(1, "CheckBox_someone")
	self:addCheckBoxGroupItem(1, "CheckBox_union")
	self:addCheckBoxGroupItem(1, "CheckBox_team")

	self:enableWidgetByName("CheckBox_union", G_Me.legionData:hasCorp())
	self:enableWidgetByName("CheckBox_team", G_Me.dailyPvpData:inTeam())

	self:registerBtnClickEvent("btn_close", function ( widget )
		self:onBackKeyEvent()
	end)
	self:registerCheckboxEvent("CheckBox_world", function ( widget, type, isCheck )
		self:_onSwitchWorldChanel()
	end)
	self:registerCheckboxEvent("CheckBox_someone", function ( widget, type, isCheck )
		self:_onSwitchSomeoneChanel()
	end)
	self:registerCheckboxEvent("CheckBox_union", function ( widget, type, isCheck )
		self:_onSwitchUnionChanel()
	end)
	self:registerCheckboxEvent("CheckBox_team", function ( widget, type, isCheck )
		self:_onSwitchTeamChanel()
	end)

	self:registerWidgetClickEvent("Button_send", function ( widget )
		self:_doSendChatMsg()
	end)

	-- self:registerWidgetClickEvent("Image_someone_back", function ( ... )
	-- 	self:_onInputChatName()
	-- end)
	self:registerTextfieldEvent("TextField_input_name",function ( textfield, eventType )
		self:callAfterFrameCount(1, function ( ... )
		        self:_onInputFieldEvent(eventType)
		end)
     end)
	self:registerTextfieldEvent("TextField_input_content",function ( textfield, eventType )
		self:callAfterFrameCount(1, function ( ... )
			self:_onInputContentFieldEvent(eventType)
		end)
        
     end)

	-- if self._isAndroidPlatform then
		local bkImg = self:getImageViewByName("Image_someone_back")
		if bkImg then 
			bkImg:setTouchEnabled(true)
		end
		self:showWidgetByName("TextField_input_name", false)

		self:registerWidgetClickEvent("Image_someone_back", function ( ... )
			local textfield = self:getTextFieldByName("TextField_input_name")
			if textfield then 
				textfield:setVisible(true)
			end
			self:callAfterFrameCount(1, function ( ... )
				textfield:openKeyboard()
				self:_onInputFieldEvent(CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME)
				self:_onInputFieldEvent(CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW)
			end)
		end)

		local bkImg = self:getImageViewByName("Image_input_back")
		if bkImg then 
			bkImg:setTouchEnabled(true)
		end
		self:showWidgetByName("TextField_input_content", false)

		self:registerWidgetClickEvent("Image_input_back", function ( ... )
			local textfield = self:getTextFieldByName("TextField_input_content")
			if textfield then 
				textfield:setVisible(true)
			end
			self:callAfterFrameCount(1, function ( ... )
				textfield:openKeyboard()
				self:_onInputContentFieldEvent(CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME)
				self:_onInputContentFieldEvent(CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW)
			end)
		end)
	-- end

	self:registerBtnClickEvent("Button_face", function ( widget )
		local border = self:getWidgetByName("Button_face")
		local borderSize = border:getSize()
		local anchorPt = border:getAnchorPoint()
		local faceTopPosx = - anchorPt.x*borderSize.width
		local faceTopPosy = (1 - anchorPt.y)*borderSize.height
		faceTopPosx, faceTopPosy = border:convertToWorldSpaceXY(faceTopPosx, faceTopPosy)

		local facePanel = require("app.scenes.chat.ChatFaceLayer")
		facePanel.showFaceLayer(self, faceTopPosx, faceTopPosy, self._onChooseFace, self)
	end)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_CHAT_REQUEST_RET, self.onReceiveChatRequestRet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_CHAT_MSG, self.onReceiveChatMessage, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_NOTIFY, self.onReceiveNotify, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED, self._onReceiveChatMsgFlagChange, self)

	self:showTextWithLabel("Label_someone_name", "")

	self:attachImageTextForBtn("Button_send", "Image_43")

	local textfield = self:getTextFieldByName("TextField_input_name")
	if textfield then 
		textfield:setText(" ")
		textfield:setMaxLengthEnabled(true)
		textfield:setMaxLength(18)
	end
	textfield = self:getTextFieldByName("TextField_input_content")
	if textfield then 
		textfield:setText(" ")
		textfield:setMaxLengthEnabled(true)
		textfield:setMaxLength(120)
	end

	self:callAfterFrameCount(1, function ( ... )
		if self._channeId == 2 then 
			self:setCheckStatus(1, "CheckBox_someone")
			if type(param) == "string" then 
				self:showTextWithLabel("Label_someone_name", param)
			elseif type(param) == "table" then
				local label = self:getLabelByName("Label_someone_name")
				if label then 
					label:setColor(self:_getColorForKid(param[2], true))
					label:setText(param[1])
				end
			end
		elseif self._channeId == 3 then 
			self:setCheckStatus(1, "CheckBox_union")
		elseif self._channeId == 4 then
			self:setCheckStatus(1, "CheckBox_team")
		else
			self:setCheckStatus(1, "CheckBox_world")
		end

		self:_onReceiveChatMsgFlagChange()	
	end)	

	local info = storage.load(storage.path("setting.data"))
    -- 鑱婂ぉ鎮诞鏄惁寮€鍚?
    local defaulsShowChat = (G_Setting:get("default_show_chat") == "1")
    local showBtn = (info and info.show_chat_enable and info.show_chat_enable == 1)
    if defaulsShowChat then 
        showBtn = not (info and info.show_chat_enable and info.show_chat_enable ~= 1 ) 
    end
    local ckbox = self:getCheckBoxByName("CheckBox_choose")
    if ckbox then 
    	ckbox:setSelectedState(showBtn)
    end
    self:registerCheckboxEvent("CheckBox_choose", function ( widget, type, isCheck )
    	self:_onChatFloatShow(isCheck)
    end)

	self:_initSendBtn()
end

function ChatLayer:_onChatFloatShow( check )
	local info = storage.load(storage.path("setting.data")) or {}
	if check then 		
		info.show_chat_enable = 1
		storage.save(storage.path("setting.data"), info)
	else
		info.show_chat_enable = 0
		storage.save(storage.path("setting.data"), info )
	end

	if G_topLayer then 
		G_topLayer:showChatBtn(check)
	end
end

function ChatLayer:_initSendBtn( ... )
	local lastChatTime = G_HandlersManager.chatHandler:getLastChatTime()
	local localTime = os.time()
	local canChat = (localTime - lastChatTime >= 5)

--__Log("lastChatTime:%d, localTime:%d, offset:%d, canChat:%d", 
--	lastChatTime, localTime, 20 + lastChatTime - localTime, canChat and 1 or 0)

	self:enableWidgetByName("Button_send", canChat)
	self:showWidgetByName("Image_43", canChat)
	self:showWidgetByName("Label_seconds", not canChat)
	self:showTextWithLabel("Label_seconds", G_lang:get("LANG_CHAT_COUNT_DOWN_TIME_FORMAT", 
		{secondCount = canChat and 0 or 5 + lastChatTime - localTime}))

	local _doUpdateTime = nil
	local _delaySecond = function ( ... )
		self:callAfterDelayTime(0.5, nil, function ( ... )
			if _doUpdateTime then
				_doUpdateTime()
			end
		end)
	end

	_doUpdateTime = function ( ... )
		local localTime = os.time()
		local canChat = (localTime - lastChatTime >= 5)
--		__Log("lastChatTime:%d, localTime:%d, offset:%d, canChat:%d", 
--	lastChatTime, localTime, 20 + lastChatTime - localTime, canChat and 1 or 0)
		if not canChat then 
			self:showTextWithLabel("Label_seconds", G_lang:get("LANG_CHAT_COUNT_DOWN_TIME_FORMAT", 
				{secondCount = canChat and 0 or 5 + lastChatTime - localTime}))
			if _delaySecond then
				_delaySecond()
			end
		else
			self:_initSendBtn()
		end
	end

	if not canChat then 
		_delaySecond()
	end
end

function ChatLayer:onLayerEnter( ... )
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")

	local label = self:getLabelByName("Label_input_label")
	if label then 
		local size = label:getSize()
		self._sendRichText = CCSRichText:create(size.width, size.height)
    	self._sendRichText:setFontSize(label:getFontSize())
    	self._sendRichText:setFontName(label:getFontName())
    	local color = label:getColor()

    	self._defaultColor = ccc3(color.r, color.g, color.b)
    	self._sendRichText:setColor(self._defaultColor)
    	self._sendRichText:setShowTextFromTop(true)
    	self._sendRichText:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)
    	local backImg = self:getWidgetByName("Image_input_back")
    	if backImg then 
    		backImg:addChild(self._sendRichText)
    	else
    		__LogError("Image_input_back is nil!")
    	end
    	self._sendRichText:setPosition(ccp(label:getPosition()))
    	self._sendRichText:setVisible(false)

    	--浣?鐐瑰嚮杈撳叆鏂囧瓧"鎻愮ず灞呬腑鏄剧ず锛屼粎鍦ㄦ病鏈夎緭鍏ユ儏鍐典笅璋冩暣
    	label:setPosition(ccp(label:getPositionX(), label:getPositionY()-8))
	end
end

function ChatLayer:onBackKeyEvent( ... )
	if self._func then 
		self._func()
		self._func = nil
	end

	self:animationToClose()
	return true
end

function ChatLayer:showChat( show )
	self:setVisible(show or false)
end

function ChatLayer:showWithChannel( channel, param )
	channel = channel or 1 
	if channel == 2 then 
		self:setCheckStatus(1, "CheckBox_someone")
		if type(param) == "string" then 
			self:showTextWithLabel("Label_someone_name", param)
		elseif type(param) == "table" then
			local label = self:getLabelByName("Label_someone_name")
		if label then 
			label:setColor(self:_getColorForKid(param[2], true))
			label:setText(param[1])
		end
	end

	elseif channel == 3 then 
		self:setCheckStatus(1, "CheckBox_union")
	elseif channel == 4 then 
		self:setCheckStatus(1, "CheckBox_team")
	else
		self:setCheckStatus(1, "CheckBox_world")
	end
end

-- function ChatLayer:_onInputChatName( ... )
-- 	if device.platform == "ios" then
-- 		local glbalConst = require("app.const.GlobalConst")
-- 		local input = require("app.scenes.createrole.InputLayer").create( glbalConst.USER_NAME_LENGTH_MAX, 
-- 			self:getTextWithLabel("Label_someone_name"), function ( txt )
--     	   		local label = self:getLabelByName("Label_someone_name")
--     	   		if label then 
--     	   			label:setColor(ccc3(255, 255, 153))
--     	   			label:setText(txt)
--     	   		end
--      	 	end)   
--     	uf_sceneManager:getCurScene():addChild(input, 100)
-- 	else
-- 		self:showWidgetByName("Label_someone_name", false)
-- 		local textfield = self:getTextFieldByName("TextField_input_name") 
-- 		if textfield then 
-- 			textfield:setMaxLength(18)
-- 			textfield:setVisible(true)
-- 			textfield:openKeyboard()
-- 		end
-- 	end
-- end


function ChatLayer:_onChooseFace( fileName )
	if fileName == nil or fileName == "" then
		return 
	end

	self._curMsgContent = self._curMsgContent or ""
	local face = string.format("[%s]", fileName)
	self._curMsgContent = self._curMsgContent..face
	
	self:_updateChatMsg(self._curMsgContent)
end

function ChatLayer:_onInputFieldEvent( eventType )
	local textfield = self:getTextFieldByName("TextField_input_name")
	local sharedApplication = CCApplication:sharedApplication()
	local target = sharedApplication:getTargetPlatform()

	if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
		if not self._isNameFieldAttach then 
			return 
		end
		self:showWidgetByName("Label_someone_name", false)
		if textfield then 
			local label = self:getLabelByName("Label_someone_name")
			textfield:setText(label and label:getStringValue() or "")
		end
		if target == kTargetIphone or target == kTargetIpad then 
			if self._layerMoveOffset < 1 and textfield then 
        		--G_keyboardShowTimes = G_keyboardShowTimes + 1
				--self:callAfterFrameCount(G_keyboardShowTimes > 1 and 15 or 40, function ( ... )
					local textSize = textfield:getSize()
					local screenPosx, screenPosy = textfield:convertToWorldSpaceXY(0, 0)
					local keyboardHeight = textfield:getKeyboardHeight()
          			if display.contentScaleFactor >= 2 then 
            			keyboardHeight = keyboardHeight/2
          			end
					if keyboardHeight > screenPosy - 2*textSize.height then 
						self._layerMoveOffset = keyboardHeight - screenPosy + 2*textSize.height
					end

					if self._layerMoveOffset > 0 then 
						self:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
						textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
					end
				--end)
			end
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME then 
		self._isNameFieldAttach = true
	elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then
		self._isNameFieldAttach = false
		self:showWidgetByName("Label_someone_name", true)
		if self._layerMoveOffset > 0 then 
			self:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
			textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
			self._layerMoveOffset = 0
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
		self:showWidgetByName("Label_someone_name", true)
		if textfield then 
			local text = textfield:getStringValue()
			if device.platform == "wp8" or device.platform == "winrt" then
				text = self._checkLabel:deleteInvalidChars(text)
			else
				text = FTLabelManager:getInstance():deleteInvalidChars(text)
				--local text = textfield:getStringValue()
			end
			self:showTextWithLabel("Label_someone_name", text)
			if self._isAndroidPlatform then 
				textfield:setVisible(false)
			else
				textfield:setText(" ")
			end
		end
	end
end

function ChatLayer:_onInputContentFieldEvent( eventType )
	local textfield = self:getTextFieldByName("TextField_input_content")
	local sharedApplication = CCApplication:sharedApplication()
	local target = sharedApplication:getTargetPlatform()

	if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
		if not self._isContentFieldAttach then 
			return 
		end

		if self._sendRichText then 
			self._sendRichText:setVisible(false)
		end
		self:showWidgetByName("Label_input_label", false)
		if textfield then 
			-- textfield:setText(self._curMsgContent or "")
		end
		if target == kTargetIphone or target == kTargetIpad then 
			if self._layerMoveOffset < 1 and textfield then 
        		--G_keyboardShowTimes = G_keyboardShowTimes + 1
				--self:callAfterFrameCount(G_keyboardShowTimes > 1 and 15 or 40, function ( ... )
					local textSize = textfield:getSize()
					local screenPosx, screenPosy = textfield:convertToWorldSpaceXY(0, 0)
					local keyboardHeight = textfield:getKeyboardHeight()
          			if display.contentScaleFactor >= 2 then 
            			keyboardHeight = keyboardHeight/2
          			end
					if keyboardHeight > screenPosy - 2*textSize.height then 
						self._layerMoveOffset = keyboardHeight - screenPosy + 2*textSize.height
					end

					if self._layerMoveOffset > 0 then 
						self:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
						textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
					end
				--end)
			end
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME then 
		self._isContentFieldAttach = true
	elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then  
		self._isContentFieldAttach = false
		if self._sendRichText then 
			self._sendRichText:setVisible(true)
		end
		if self._layerMoveOffset > 0 then 
			self:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
			textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
			self._layerMoveOffset = 0
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
		if textfield then 
			local text = textfield:getStringValue()
			if device.platform == "wp8" or device.platform == "winrt" then
				text = self._checkLabel:deleteInvalidChars(text)
			else
				text = FTLabelManager:getInstance():deleteInvalidChars(text)
				--local text = textfield:getStringValue()
			end
			self:_updateChatMsg(text)
			--local text = textfield:getStringValue()
			--self:showTextWithLabel("Label_someone_name", textfield:getStringValue())
			textfield:setVisible(false)
			-- if self._isAndroidPlatform then 
				
			-- else
			-- 	textfield:setText(" ")
			-- end
		end
	end
end

function ChatLayer:_onReceiveChatMsgFlagChange( isDirty )
	--uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
		local arr = G_HandlersManager.chatHandler:getNewMsgChannel() or {}
		local channels = {}
		for key, value in pairs(arr) do
			if value then 
				channels[value] = 1
			end
		end
		self:showWidgetByName("Image_tip_world", channels[1] and true or false)
		self:showWidgetByName("Image_tip_someone", channels[2]and true or false)
		self:showWidgetByName("Image_tip_union", channels[3] and true or false)
		self:showWidgetByName("Image_tip_team", channels[4] and true or false)
	--end)
end

function ChatLayer:_updateInputBack( ... )
	self:showWidgetByName("Image_double", self._channeId == 2)
	self:showWidgetByName("Image_single", self._channeId ~= 2)
end

function ChatLayer:_onSwitchWorldChanel( ... )
	self._channeId = 1
	self:_updateInputBack()
	if not self._worldRichtext then 
		local panel = self:getPanelByName("Panel_msg_list_world")
		if panel then
			local size = panel:getSize()
			self._worldRichtext = CCSRichText:create(size.width - 10, size.height -20)
    		self._worldRichtext:setVerticalSpacing(0)
    		self._worldRichtext:setWidthPercent(70)
    		self._worldRichtext:setPosition(ccp(size.width/2, size.height/2))
    		self._worldRichtext:setTouchEnabled(true)
    		self._worldRichtext:setFontSize(22)
			self._worldRichtext:setFontName("ui/font/FZYiHei-M20S.ttf")
    		self._worldRichtext:setMaxRowCount(30)
    		self._worldRichtext:setPrefixStroke(Colors.strokeBrown)
    		self._worldRichtext:addBubble("ui/chat/normal_back_left.png", CCRectMake(31, 38, 20, 1))
    		self._worldRichtext:addBubble("ui/chat/normal_back_right.png", CCRectMake(12, 38, 1, 20))
    		self._worldRichtext:addBubble("ui/chat/vip_back_left.png", CCRectMake(54, 42, 18, 4))
    		self._worldRichtext:addBubble("ui/chat/vip_back_right.png", CCRectMake(66, 42, 5, 18))
    		self._worldRichtext:forceRefresh(false)
    		--self._worldRichtext:setBubble("ui/chat/normal_back_left.png", "ui/chat/normal_back_right.png");
    		panel:addChild(self._worldRichtext)

    		self._worldRichtext:setClickHandler(function ( widget, x, y, type, tag )
    			self:onRichTextClick( widget, x, y, type, tag )
   			end)

    		self._worldRichtext:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)    
			self:_initChatMsgList(1)
		end  
	end  

	G_HandlersManager.chatHandler:setMsgFlag(1, false)
end

function ChatLayer:_onSwitchSomeoneChanel( ... )
	self._channeId = 2
	self:_updateInputBack()
	if not self._someoneMsgList then 
		local panel = self:getPanelByName("Panel_list_someone")
		if panel then
			local size = panel:getSize()
			self._someoneMsgList = CCSRichText:create(size.width - 10, size.height -20)
    		self._someoneMsgList:setVerticalSpacing(0)
    		self._someoneMsgList:setWidthPercent(70)
    		self._someoneMsgList:setPosition(ccp(size.width/2, size.height/2))
    		self._someoneMsgList:setTouchEnabled(true)
    		self._someoneMsgList:setFontSize(22)
			self._someoneMsgList:setFontName("ui/font/FZYiHei-M20S.ttf")
    		self._someoneMsgList:setMaxRowCount(30)
    		self._someoneMsgList:setPrefixStroke(Colors.strokeBrown)
    		self._someoneMsgList:addBubble("ui/chat/normal_back_left.png", CCRectMake(31, 38, 20, 1))
    		self._someoneMsgList:addBubble("ui/chat/normal_back_right.png", CCRectMake(12, 38, 1, 20))
    		self._someoneMsgList:addBubble("ui/chat/vip_back_left.png", CCRectMake(54, 42, 18, 4))
    		self._someoneMsgList:addBubble("ui/chat/vip_back_right.png", CCRectMake(66, 42, 5, 18))
    		self._someoneMsgList:forceRefresh(false)
    		--self._someoneMsgList:setBubble("ui/chat/normal_back_left.png", "ui/chat/normal_back_right.png");
    		panel:addChild(self._someoneMsgList)

    		self._someoneMsgList:setClickHandler(function ( widget, x, y, type, tag )
    			self:onRichTextClick( widget, x, y, type, tag )
   			end)

    		self._someoneMsgList:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)   
			self:_initChatMsgList(2) 
		end  
	end  

	G_HandlersManager.chatHandler:setMsgFlag(2, false)
end

function ChatLayer:_onSwitchUnionChanel( ... )
	self._channeId = 3
	self:_updateInputBack()
	if not self._unionMsgList then 
		local panel = self:getPanelByName("Panel_list_union")
		if panel then
			local size = panel:getSize()
			self._unionMsgList = CCSRichText:create(size.width - 10, size.height -20)
    		self._unionMsgList:setVerticalSpacing(0)
    		self._unionMsgList:setWidthPercent(70)
    		self._unionMsgList:setPosition(ccp(size.width/2, size.height/2))
    		self._unionMsgList:setTouchEnabled(true)
    		self._unionMsgList:setFontSize(22)
			self._unionMsgList:setFontName("ui/font/FZYiHei-M20S.ttf")
    		self._unionMsgList:setMaxRowCount(30)
    		self._unionMsgList:setPrefixStroke(Colors.strokeBrown)
    		self._unionMsgList:addBubble("ui/chat/normal_back_left.png", CCRectMake(31, 38, 20, 1))
    		self._unionMsgList:addBubble("ui/chat/normal_back_right.png", CCRectMake(12, 38, 1, 20))
    		self._unionMsgList:addBubble("ui/chat/vip_back_left.png", CCRectMake(54, 42, 18, 4))
    		self._unionMsgList:addBubble("ui/chat/vip_back_right.png", CCRectMake(66, 42, 5, 18))
    		self._unionMsgList:forceRefresh(false)
    		--self._unionMsgList:setBubble("ui/chat/normal_back_left.png", "ui/chat/normal_back_right.png");
    		panel:addChild(self._unionMsgList)

    		self._unionMsgList:setClickHandler(function ( widget, x, y, type, tag )
    			self:onRichTextClick( widget, x, y, type, tag )
   			end)

    		self._unionMsgList:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)    

			self:_initChatMsgList(3)
		end  
	end  

	G_HandlersManager.chatHandler:setMsgFlag(3, false)
end


function ChatLayer:_onSwitchTeamChanel( ... )
	self._channeId = 4
	self:_updateInputBack()
	if not self._teamMsgList then 
		local panel = self:getPanelByName("Panel_list_team")
		if panel then
			local size = panel:getSize()
		self._teamMsgList = CCSRichText:create(size.width - 10, size.height -20)
    		self._teamMsgList:setVerticalSpacing(0)
    		self._teamMsgList:setWidthPercent(70)
    		self._teamMsgList:setPosition(ccp(size.width/2, size.height/2))
    		self._teamMsgList:setTouchEnabled(true)
    		self._teamMsgList:setFontSize(22)
		self._teamMsgList:setFontName("ui/font/FZYiHei-M20S.ttf")
    		self._teamMsgList:setMaxRowCount(30)
    		self._teamMsgList:setPrefixStroke(Colors.strokeBrown)
    		self._teamMsgList:addBubble("ui/chat/normal_back_left.png", CCRectMake(31, 38, 20, 1))
    		self._teamMsgList:addBubble("ui/chat/normal_back_right.png", CCRectMake(12, 38, 1, 20))
    		self._teamMsgList:addBubble("ui/chat/vip_back_left.png", CCRectMake(54, 42, 18, 4))
    		self._teamMsgList:addBubble("ui/chat/vip_back_right.png", CCRectMake(66, 42, 5, 18))
    		self._teamMsgList:forceRefresh(false)
    		--self._unionMsgList:setBubble("ui/chat/normal_back_left.png", "ui/chat/normal_back_right.png");
    		panel:addChild(self._teamMsgList)

    		self._teamMsgList:setClickHandler(function ( widget, x, y, type, tag )
    			self:onRichTextClick( widget, x, y, type, tag )
   			end)

    		self._teamMsgList:setParseFaceHandler(function ( content )
    			return self:_onParseFace( content )
    		end)    

			self:_initChatMsgList(4)
		end  
	end  

	G_HandlersManager.chatHandler:setMsgFlag(4, false)
end

function ChatLayer:_initChatMsgList( channel )
	if not channel or channel > 4 or channel < 1 then 
		return
	end

	local richText = nil 
	local msgList = nil 
	if channel == 1 then 
		richText = self._worldRichtext
		msgList = G_HandlersManager.chatHandler:getWorldMsgList()
	elseif channel == 2 then
		richText = self._someoneMsgList
		msgList = G_HandlersManager.chatHandler:getSomeoneMsgList()
	elseif channel == 3 then
		richText = self._unionMsgList
		msgList = G_HandlersManager.chatHandler:getUnionMsgList()
	else
		richText = self._teamMsgList
		msgList = G_HandlersManager.chatHandler:getTeamMsgList()
	end

	if not richText or not msgList then 
		return 
	end

	richText:clearRichElement()

	local length = #msgList
	local loopi = 1
	for loopi = length, 1, -1 do 
		local value = msgList[loopi]

		if value then 
			if channel == 1 then
				self:appendWorldMsg(value.msg_sender, value.msg_senderId, value.msg_kid, value.msg_content, value.msg_vip and value.msg_vip > 0, value.dress_id, value.title_id, value.frameId,value.clid,value.cltm ,value.clop)
			elseif channel == 2 then
				if value.msg_senderId == G_Me.userData.id then 
					self:addMyMsg(value.msg_content, value.msg_receive, value.msg_kid, value.msg_vip and value.msg_vip > 0, value.dress_id, G_Me.userData:getTitleId(), G_Me.userData:getFrameId(),G_Me.userData:getClothId(), G_Me.userData.cloth_time, G_Me.userData.cloth_open)
				else
					self:appendSelfMsg(value.msg_sender, value.msg_senderId, value.msg_kid, value.msg_content, value.msg_vip and value.msg_vip > 0, value.dress_id, value.title_id, value.frameId,value.clid,value.cltm ,value.clop)
				end
			elseif channel == 3 then 
				self:appendUnionMsg(value.msg_sender, value.msg_senderId, value.msg_kid, value.msg_content, value.msg_vip and value.msg_vip > 0, value.dress_id, value.title_id, value.frameId,value.clid,value.cltm ,value.clop)
			elseif channel == 4 then 
				self:appendTeamMsg(value.msg_sender, value.msg_senderId, value.msg_kid, value.msg_content, value.msg_vip and value.msg_vip > 0, value.dress_id, value.title_id, value.frameId,value.clid,value.cltm ,value.clop)
			end
		end
	end
end

function ChatLayer:_updateChatMsg( content )
	self._curMsgContent = content or ""
	if self._sendRichText then 
		self._sendRichText:clearRichElement()

		if #self._curMsgContent > 0 then
			self._sendRichText:appendContent(self._curMsgContent, self._defaultColor)
			self._sendRichText:reloadData()
		end

		self._sendRichText:setVisible(#self._curMsgContent > 0)
	end

	self:showWidgetByName("Label_input_label", #self._curMsgContent < 1)

	--if self._isAndroidPlatform then 
		local textfield = self:getTextFieldByName("TextField_input_content")
		if textfield then 
			textfield:setText(content)
		end
	--end
end

function ChatLayer:_doSendChatMsg( ... )
	local receive = ""
	if self._channeId == 2 then
		local label = self:getLabelByName("Label_someone_name")
		receive = label:getStringValue()
		if receive == nil or receive == "" then
			return G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_TIP_NULL_CHAT_OBJECT"))
		elseif receive == G_Me.userData.name then
			return G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_TIP_CANNOT_CHAT_SELF")) 
		end

		--if G_GlobalFunc and G_GlobalFunc.matchText(receive) then 
        --	G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_NAME_INVALID_TEXT"))
        --	return 
    	--end
	end		

	if not self._curMsgContent or #self._curMsgContent < 1 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_TIP_NULL_MSG"))
		--MessageBoxEx.showOkMessage("璀?   鍛?, "娌℃湁瑕佸彂閫佺殑鍐呭锛岃杈撳叆瑕佸彂閫佺殑鏂囧瓧鍝︼紝浜诧紒")
		return
	end

	if G_GlobalFunc then
		self._curMsgContent = G_GlobalFunc.filterText(self._curMsgContent)
	end
	
	__Log("send content:%s channid=%d, receive:%s", self._curMsgContent, self._channeId, receive)
	G_HandlersManager.chatHandler:sendChatRequest(self._channeId, self._curMsgContent, receive, self._selfChatKid)
	local textfield = self:getTextFieldByName("TextField_input_content")
	if textfield then
		textfield:setText("")
	end
	
	if self._channeId == 2 then
		--self:addMyMsg(self._curMsgContent, receive, self._selfChatKid)
	end
end

function ChatLayer:onClickInputBox(  )
	local ChatInputPanel = require("app.scenes.chat.ChatInputLayer")
	ChatInputPanel.showInputLayer(self, self._curMsgContent, 
		self._channeId == 2 and self._selfChatName or nil, 
		self._channeId == 2 and self._selfChatKid or nil, function ( text, send )
		--self._curMsgContent = text or ""
		self:_updateChatMsg(text)

		if send then 
			self:_doSendChatMsg()
		end
	end)
end

function ChatLayer:onLayerUnload( )
	uf_eventManager:removeListenerWithTarget()

	if self._func then 
		self._func()
		self._func = nil
	end
end

function ChatLayer:onRichTextClick( widget, x, y, atlas_type, tag )
	if atlas_type == CCS_ATLAS_TYPE_HEADER then
		local senderId = widget:getTag()
		local userObj = widget:getUserObject()
		local userName = ""
		if userObj ~= nil then
			userObj = tolua.cast(userObj, "CCString")
			if userObj ~= nil then
				userName = userObj:getCString()
			end
		end
		local kid = 0
		local icon = widget:getChildByTag(1)
		if icon then
			userObj = icon:getUserObject()
			if userObj ~= nil then
				if device.platform == "wp8" or device.platform == "winrt" then
					userObj = tolua.cast(userObj, "cc.__Integer")
				else
					userObj = tolua.cast(userObj, "CCInteger")
				end
				if userObj ~= nil then
					kid = userObj:getValue()
				end
			end
		end
		self:onUserHeadClick( senderId, userName, kid)
	end
end

function ChatLayer:_onParseFace( content )
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

function ChatLayer:onUserHeadClick( senderId, senderName, kid ) 
	senderId = senderId or 0

	if self._channeId == 4 then
		return 
	end

	if senderId == G_Me.userData.id then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_TIP_CANNOT_CHAT_SELF"))
	end

	local FriendInfoConst = require("app.const.FriendInfoConst")
	local input = require("app.scenes.friend.FriendInfoLayer").createByName(senderId, senderName,function ( index )
            if index == FriendInfoConst.CHAT then
				self:setCheckStatus(1, "CheckBox_someone")
				local label = self:getLabelByName("Label_someone_name")
				if label then 
					label:setColor(self:_getColorForKid(kid, true))
					label:setText(senderName)
				end
				self._selfChatKid = kid
				self._selfChatName = senderName

				return true
			end

            return false
     end, 
     function ( ... )
        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
     end)
     self:addChild(input)
end

function ChatLayer:onReceiveChatRequestRet( ret )
	if ret == NetMsg_ERROR.RET_OK then
		self:_updateChatMsg("")

		if self._channeId == 2 or self._channeId == 3 then 
			local msg = self._channeId == 2 and G_HandlersManager.chatHandler:getSomeoneMsgByIndex(1) or 
			G_HandlersManager.chatHandler:getUnionMsgByIndex(1)
			if msg and msg.msg_senderId == G_Me.userData.id then 
				if self._channeId == 2 then 
					local dress_id = 0
					if G_Me.dressData:getDressed() then 
						dress_id = G_Me.dressData:getDressed().base_id
					end 
					self:addMyMsg(msg.msg_content, msg.msg_receive, msg.msg_kid, G_Me.userData.vip > 0, 
						dress_id, G_Me.userData:getTitleId(), G_Me.userData:getFrameId(),
						 G_Me.userData:getClothId(), G_Me.userData.cloth_time, G_Me.userData.cloth_open)
				--elseif self._channeId == 3 then 
				--	self:appendUnionMsg(msg.msg_sender, G_Me.userData.id, msg.msg_kid, msg.msg_content, G_Me.userData.vip > 0)
				end
			end
		end

		self:_initSendBtn()
	end
end

function ChatLayer:onReceiveChatMessage( channel, sender, senderId, kid, content, vip, dressId, titleId, frameId ,clid,cltm ,clop)
__Log("channel:%d, kid:%d, content:%s, vip:%d, dressId:%d , clid:%d,cltm:%d ", channel, kid, content, vip, dressId ,clid , cltm)
	if channel == 1 then
		--if self._channeId == 1 then 
			self:appendWorldMsg(sender, senderId, kid, content, vip and vip > 0, dressId, titleId, frameId,clid,cltm  ,clop)
		--end
	elseif channel == 2 then
		--if self._channeId == 2 then 
			self:appendSelfMsg(sender, senderId, kid, content, vip and vip > 0, dressId, titleId, frameId,clid,cltm ,clop)
		--end
	elseif channel == 3 then
		--if self._channeId == 3 then  
			self:appendUnionMsg(sender, senderId, kid, content, vip and vip > 0, dressId, titleId, frameId,clid,cltm ,clop)
		--end
	elseif channel == 4 then
		--if self._channeId == 3 then  
			self:appendTeamMsg(sender, senderId, kid, content, vip and vip > 0, dressId, titleId, frameId,clid,cltm ,clop)
		--end
	end

	G_HandlersManager.chatHandler:setMsgFlag(self._channeId, false)
end

function ChatLayer:onReceiveNotify( buffer )
	-- body
end


function ChatLayer:_createUserHead( sender, senderId, kid, isVip, dressId, titleId, frameId,clid,cltm ,clop)
	kid = kid or 0
	local mainKnight = G_Me.bagData.knightsData:getMainKightInfo()
	if kid <= 0 then 		
		kid = mainKnight and mainKnight["base_id"] or 0
	end

	local knightInfo = knight_info.get(kid or 0)
	if not knightInfo then 
		return nil 
	end

	local resId = knightInfo and knightInfo.res_id or 10011

    resId = G_Me.dressData:getDressedResidWithClidAndCltm(kid, dressId or 0,clid,cltm ,clop)


	local iconPath = G_Path.getKnightIcon(resId)	

	local backImg = ImageView:create()
	backImg:loadTexture("putong_bg.png", UI_TEX_TYPE_PLIST)
    backImg:setTag(senderId)
    backImg:setUserObject(CCString:create(sender))

	local pingji = ImageView:create()
	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))
    pingji:setTag(senderId)
    pingji:setUserObject(CCString:create(sender))

	local headImage = ImageView:create()
    headImage:loadTexture(iconPath, UI_TEX_TYPE_LOCAL)
    headImage:setUserObject(CCInteger:create(kid))
    local headSize = headImage:getSize()

    if isVip then 
    	local vipTag = ImageView:create()
    	vipTag:loadTexture(G_Path.getChatVipPiece())
    	pingji:addChild(vipTag,4)
    	local vipSize = vipTag:getSize()
    	if senderId == G_Me.userData.id then 
    		vipTag:setRotation(60)
    		vipTag:setPositionXY(vipSize.width/2+10, headSize.height/2 - 10)
    	else
    		--vipTag:setRotation(-30)
    		vipTag:setPositionXY(-vipSize.width/2-10, headSize.height/2 - 10)
    	end
    end

    if type(titleId) == "number" then 
    	local titleInfo = title_info.get(titleId)
    	if titleInfo then 
    		local titleImg  = ImageView:create()
			titleImg:loadTexture(titleInfo.picture2, UI_TEX_TYPE_LOCAL)
			pingji:addChild(titleImg, 3)
			titleImg:setPositionXY(0, headSize.height/2 + 10)
			titleImg:setScale(0.8)
    	end
    end 

    -- local backSize = pingji:getSize()
    -- local userName = GlobalFunc.createGameLabel(sender or "[name]", 20, Colors.getColor(knightInfo.quality), Colors.strokeBrown)
    -- local labelSize = userName:getSize()
    -- userName:setPosition(ccp(0, -(backSize.height + labelSize.height)/2 - 2))

    pingji:addChild(headImage, 1, 1)
    backImg:addChild(pingji)
    --pingji:addChild(userName)

    --add by kaka 
    if frameId and type(frameId) == "number" then 
    	local frameInfo = frame_info.get(frameId)
    	if frameInfo then 
    		local frameImg  = ImageView:create()
			frameImg:loadTexture(G_Path.getAvatarFrame(frameInfo.res_id))
			G_GlobalFunc.addHeadIcon(frameImg,frameInfo.vip_level)
			pingji:addChild(frameImg, 2)
			frameImg:setPositionXY(0, 1)
    	end
    end 

    return backImg
end

function ChatLayer:_getColorForKid( kid, rgbFormat )
	rgbFormat = rgbFormat or false
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
	if rgbFormat then 
		return clr 
	else
		return clr.r * 256*256 + clr.g*256 + clr.b
	end
end

function ChatLayer:appendWorldMsg( sender, senderId, kid, content, isVip, dressId, titleId, frameId ,clid,cltm ,clop)
	if not self._worldRichtext then 
		return
	end
	local isMyMsg = false
    if G_Me.userData.id == senderId then
    	isMyMsg = true
	end

    local prefix = ""
    if isMyMsg then
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    else
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    end

	local bubblePath = ""
	if isVip then 
		bubblePath = isMyMsg and "ui/chat/vip_back_right.png" or "ui/chat/vip_back_left.png"
	else
		bubblePath = isMyMsg and "ui/chat/normal_back_right.png" or "ui/chat/normal_back_left.png"
	end

	self._worldRichtext:appendContent(content, ccc3(0x50, 0x3e, 0x32), 1, 
		prefix, self:_createUserHead(sender, senderId, kid, isVip, dressId, isMyMsg and G_Me.userData:getTitleId() or titleId, frameId,clid,cltm ,clop), isMyMsg, bubblePath)
	self._worldRichtext:reloadData()
end

function ChatLayer:appendSelfMsg( sender, senderId, kid, content, isVip, dressId, titleId, frameId ,clid,cltm ,clop)
	if self._someoneMsgList then 
		local prefix = G_lang:get("LANG_CHAT_TIP_SAY_TO_ME", {sender_name = sender, clrValue=self:_getColorForKid(kid)})
    	--local prefix = string.format("<prefix><text value=".."  '%s'".."color='%d'/><text value='瀵规垜璇?  '  color='16777215'/></prefix>", sender, self:_getColorForKid(kid) )
		self._someoneMsgList:appendContent(content, ccc3(0x50, 0x3e, 0x32), 1, 
			prefix, self:_createUserHead(sender, senderId, kid, isVip, dressId, titleId, frameId,clid,cltm ,clop), false, 
			isVip and "ui/chat/vip_back_left.png" or "ui/chat/normal_back_left.png")
		self._someoneMsgList:reloadData()
	end
end

function ChatLayer:appendUnionMsg( sender, senderId, kid, content, isVip, dressId, titleId, frameId ,clid,cltm ,clop)
	if not self._unionMsgList then 
		return
	end
	local isMyMsg = false
    if G_Me.userData.id == senderId then
    	isMyMsg = true
	end

    local prefix = ""
    if isMyMsg then
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    else
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    end

	local bubblePath = ""
	if isVip then 
		bubblePath = isMyMsg and "ui/chat/vip_back_right.png" or "ui/chat/vip_back_left.png"
	else
		bubblePath = isMyMsg and "ui/chat/normal_back_right.png" or "ui/chat/normal_back_left.png"
	end

	self._unionMsgList:appendContent(content, ccc3(0x50, 0x3e, 0x32), 1, 
		prefix, self:_createUserHead(sender, senderId, kid, isVip, dressId, isMyMsg and G_Me.userData:getTitleId() or titleId, frameId,clid,cltm ,clop), isMyMsg, bubblePath)
	self._unionMsgList:reloadData()
end


function ChatLayer:appendTeamMsg( sender, senderId, kid, content, isVip, dressId, titleId, frameId,clid,cltm ,clop)
	if not self._teamMsgList then 
		return
	end
	local isMyMsg = false
    if G_Me.userData.id == senderId then
    	isMyMsg = true
	end

    local prefix = ""
    if isMyMsg then
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    else
    	prefix = string.format("<prefix><text value=".."' %s '".."color='%d'/></prefix>", sender, self:_getColorForKid(kid) )
    end

	local bubblePath = ""
	if isVip then 
		bubblePath = isMyMsg and "ui/chat/vip_back_right.png" or "ui/chat/vip_back_left.png"
	else
		bubblePath = isMyMsg and "ui/chat/normal_back_right.png" or "ui/chat/normal_back_left.png"
	end

	self._teamMsgList:appendContent(content, ccc3(0x50, 0x3e, 0x32), 1, 
		prefix, self:_createUserHead(sender, senderId, kid, isVip, dressId, isMyMsg and G_Me.userData:getTitleId() or titleId, frameId,clid,cltm ,clop), isMyMsg, bubblePath)
	self._teamMsgList:reloadData()
end

function ChatLayer:addMyMsg( content, receiver, receive_kid, isVip, dressId, titleId, frameId,clid,cltm ,clop)
	if self._someoneMsgList then 
		local prefix = G_lang:get("LANG_CHAT_TIP_SAY_TO_SOMEBODY", {receive_name = receiver, clrValue=self:_getColorForKid(receive_kid)})
    	--local prefix = string.format("<prefix><text value='  鎴戝' color='16777215' /><text value=".."'%s'".." color='%d'/><text value='璇? color='16777215'/></prefix>", receiver, self:_getColorForKid(receive_kid) )
    	self._someoneMsgList:appendContent(content, ccc3(0x50, 0x3e, 0x32), 1, 
    		prefix, self:_createUserHead(G_Me.userData.name, G_Me.userData.id, receive_kid, isVip, dressId, titleId, frameId,clid,cltm ,clop), true, 
    		isVip and "ui/chat/vip_back_right.png" or "ui/chat/normal_back_right.png")
		self._someoneMsgList:reloadData()
	end
end

return ChatLayer
