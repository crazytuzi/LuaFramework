require("app.cfg.bullet_screen_info")
local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPSendBulletScreenLayer = class("CrossPVPSendBulletScreenLayer", UFCCSModelLayer)

--[[
	TEXT_TYPE = {
		HEIGHT_LIGHT = 1,
		NORMAL = 2,
	},
]]

function CrossPVPSendBulletScreenLayer.create(nField, ...)
	local tLayer = CrossPVPSendBulletScreenLayer.new("ui_layout/crosspvp_SendBulletScreenLayer.json", Colors.modelColor, nField, ...)
	uf_sceneManager:getCurScene():addChild(tLayer)
	return tLayer
end

function CrossPVPSendBulletScreenLayer:ctor(json, param, nField, ...)
	self._nTextType = CrossPVPConst.TEXT_TYPE.NORMAL
	self._nField = nField or 1
	self._szCheckBoxName = ""
	self._szPreinstallText = ""
	self._szInputText = ""

	self._isContentFieldAttach = false
	self._layerMoveOffset = 0
  	self._isAndroidPlatform = (CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid)

  	self._tTmpl = bullet_screen_info.get(1)
  	self._nCost = 99999999

	self.super.ctor(self, json, param, ...)
end

function CrossPVPSendBulletScreenLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
end

function CrossPVPSendBulletScreenLayer:onLayerEnter()
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_BkgPanel"), "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_SEND_BULLET_SCREEN_SUCC, self._onSendBulletScreenSucc, self)
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseSelf, self)
end

function CrossPVPSendBulletScreenLayer:onLayerExit()
	
end

function CrossPVPSendBulletScreenLayer:onLayerUnload()
	G_Me.crossPVPData:setSelectedPreInstall(0)
end

function CrossPVPSendBulletScreenLayer:_initView()
	G_GlobalFunc.updateLabel(self, "Label_HeightLight", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Normal", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_GoldNum", {stroke=Colors.strokeBrown})
end

function CrossPVPSendBulletScreenLayer:_initWidgets()
	self:_bindCheckBoxGroup()
	self:registerBtnClickEvent("Button_Preinstall", handler(self, self._onOpenPreinstall))
	self:registerBtnClickEvent("Button_Send", handler(self, self._onSendBulletScreen))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))

	local textfield = self:getTextFieldByName("TextField_Input")
	if textfield then
		textfield:setMaxLengthEnabled(true)
		textfield:setMaxLength(60)
	end

	self:registerTextfieldEvent("TextField_Input",function ( textfield, eventType )
		self:callAfterFrameCount(1, function ( ... )
			self:_onInputContentFieldEvent(eventType)
		end)
    end)
    self:showWidgetByName("TextField_Input", false)

    self:registerWidgetClickEvent("Image_Content", function(sender)
		local textfield = self:getTextFieldByName("TextField_Input")
		if textfield then 
			textfield:setVisible(true)
		end
		self:callAfterFrameCount(1, function ( ... )
			textfield:openKeyboard()
			self:_onInputContentFieldEvent(CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME)
			self:_onInputContentFieldEvent(CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW)
		end)
    end)

    G_GlobalFunc.updateLabel(self, "Label_Input", {stroke=Colors.strokeBrown})
end

function CrossPVPSendBulletScreenLayer:_bindCheckBoxGroup()
	self:addCheckBoxGroupItem(1, "CheckBox_HeightLight")
    self:addCheckBoxGroupItem(1, "CheckBox_Normal")
    
    self:registerCheckBoxGroupEvent(function(groupId, oldName, newName, widget )
        if groupId == 1 then
            self._szCheckBoxName = newName
            if newName == "CheckBox_HeightLight" then  
                self:_handleCheckedHeightLight()
            elseif newName == "CheckBox_Normal" then  
                self:_handleCheckedNormal()
            end
        end
    end)
    self:setCheckStatus(1, (self._nTextType == CrossPVPConst.TEXT_TYPE.HEIGHT_LIGHT) and "CheckBox_HeightLight" or "CheckBox_Normal")
end

function CrossPVPSendBulletScreenLayer:_handleCheckedHeightLight()
	self._nTextType = CrossPVPConst.TEXT_TYPE.HEIGHT_LIGHT
	self._nCost = self._tTmpl.cost_2
	local tColor = self:_isGoldEnough(self._nCost) and Colors.darkColors.DESCRIPTION or Colors.lightColors.TIPS_01

	G_GlobalFunc.updateLabel(self, "Label_GoldNum", {text=self._nCost, color=tColor})
	self:_autoAlignGoldPicAndNum()

	G_GlobalFunc.updateLabel(self, "Label_Input", {color=Colors.darkColors.TITLE_01})
end

function CrossPVPSendBulletScreenLayer:_handleCheckedNormal()
	self._nTextType = CrossPVPConst.TEXT_TYPE.NORMAL
	self._nCost = self._tTmpl.cost_1
	local tColor = self:_isGoldEnough(self._nCost) and Colors.darkColors.DESCRIPTION or Colors.lightColors.TIPS_01
	
	G_GlobalFunc.updateLabel(self, "Label_GoldNum", {text=self._nCost, color=tColor})
	self:_autoAlignGoldPicAndNum()

	G_GlobalFunc.updateLabel(self, "Label_Input", {color=Colors.darkColors.DESCRIPTION})
end

function CrossPVPSendBulletScreenLayer:_autoAlignGoldPicAndNum()
    local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getImageViewByName('Image_Gold'),
        self:getLabelByName('Label_GoldNum'),
    }, "C")
    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_GoldNum'):setPositionXY(alignFunc(2))

    G_GlobalFunc.updateLabel(self, "Label_Input", {color=tColor})
end

-- 打开选择预设的弹幕词
function CrossPVPSendBulletScreenLayer:_onOpenPreinstall()
	local CrossPVPPreinstallInfoLayer = require("app.scenes.crosspvp.CrossPVPPreinstallInfoLayer")
	CrossPVPPreinstallInfoLayer.create(function(szContent)
		self._szPreinstallText = szContent or ""
		self._szInputText = self._szPreinstallText
		self:getTextFieldByName("TextField_Input"):setText(self._szPreinstallText)
		self:getLabelByName("Label_Input"):setText(self._szPreinstallText)
	end)
end

function CrossPVPSendBulletScreenLayer:_onSendBulletScreen()
	if self._szInputText == "" then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CHAT_TIP_NULL_MSG"))
		return
	end
	if not self:_isGoldEnough(self._nCost) then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
		return
	end

	if string.utf8len(self._szInputText) > 20 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_BULLET_SCREENT_EXCEED_20"))
		return
	end

	local nId = 1
	local szContent = G_GlobalFunc.filterText(self._szInputText)
	local nBsType = self._nTextType
	local nBattlefield = self._nField
	G_HandlersManager.crossPVPHandler:sendSendBulletScreenInfo(nId, szContent, nBsType, nBattlefield)
end

function CrossPVPSendBulletScreenLayer:_onInputContentFieldEvent( eventType )
	local textfield = self:getTextFieldByName("TextField_Input")
	local sharedApplication = CCApplication:sharedApplication()
	local target = sharedApplication:getTargetPlatform()

	if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
		if not self._isContentFieldAttach then 
			return 
		end
		self:showWidgetByName("Label_Input", false)
		if target == kTargetIphone or target == kTargetIpad then 
			if self._layerMoveOffset < 1 and textfield then 
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
			end
		end
	elseif eventType == CCSTEXTFIELDEX_EVENT_ATTACH_WITH_IME then 
		self._isContentFieldAttach = true
	elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then  
		self._isContentFieldAttach = false

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
			end
			self._szInputText = text
			self:showTextWithLabel("Label_Input", self._szInputText)
			self:showWidgetByName("Label_Input", true)
			textfield:setVisible(false)
		end
	end
end

function CrossPVPSendBulletScreenLayer:_onSendBulletScreenSucc(tData)
	self:close()
end

function CrossPVPSendBulletScreenLayer:_onCloseWindow()
	self:animationToClose()
end

function CrossPVPSendBulletScreenLayer:_isGoldEnough(nCost)
	return G_Me.userData.gold >= nCost
end

function CrossPVPSendBulletScreenLayer:_onCloseSelf()
	self:close()
end

return CrossPVPSendBulletScreenLayer