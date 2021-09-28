-- 更改角色名

local ChangeNameLayer = class("ChangeNameLayer", UFCCSModelLayer)

require("app.cfg.shop_price_info")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
ChangeNameLayer.CHANGE_NAME_SHOP_PRICE_ID = 32
ChangeNameLayer.MAX_PRICE = 1500
ChangeNameLayer.MIN_CHARS = 2
ChangeNameLayer.MAX_CHARS = 6

function ChangeNameLayer.show( ... )
	local layer = ChangeNameLayer.new("ui_layout/createrole_ChangeNameLayer.json", Colors.modelColor, nil, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ChangeNameLayer:ctor( json, color, func, ... )

	self._layerMoveOffset = 0
  
  self._price = 0

  local priceInfo = shop_price_info.get(ChangeNameLayer.CHANGE_NAME_SHOP_PRICE_ID, G_Me.userData:getChangeNameCnt() +1)
  if priceInfo then
    self._price = priceInfo.price
  else
    -- 取不到说明超过6次了
    self._price = ChangeNameLayer.MAX_PRICE
  end

	self.super.ctor(self, json)
end

function ChangeNameLayer:onLayerLoad( ... )
	
end

function ChangeNameLayer:onLayerEnter( ... )
  	EffectSingleMoving.run(self:getImageViewByName("Image_Root"), "smoving_bounce")

  	self:closeAtReturn(true)
  	self:showAtCenter(true)

  	self:getLabelByName("Label_Cost_Num"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_Cost_Num"):setText(self._price)

  	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseBtnClicked))
  	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirmBtnClicked))
  	self:registerTextfieldEvent("TextField_Name",function ( textfield, eventType )
        self:callAfterFrameCount(2, function ( ... )
        	self:_onInputFieldEvent(eventType)
        end)
    end)

    local nameField = self:getTextFieldByName("TextField_Name")
    if nameField then 
        nameField:setMaxLengthEnabled(true)
        nameField:setMaxLength(18)
    end

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_ROLE_NAME_SUCCEED, self._onChangeRoleNameSucceed, self)

    -- if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHANGE_ROLE_NAME) then
    --   local result = G_moduleUnlock:setModuleEntered(FunctionLevelConst.CHANGE_ROLE_NAME)
    --   if result then
    --       uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION, nil, false)
    --   end
    -- end
end

function ChangeNameLayer:onLayerExit( ... )
	
end

function ChangeNameLayer:onLayerUnload( ... )
	
end

function ChangeNameLayer:_onChangeRoleNameSucceed(  )
    G_MovingTip:showMovingTip(G_lang:get("LANG_CHANGE_NAME_SUCCEED"))
  	self:animationToClose()
end

function ChangeNameLayer:_onInputFieldEvent( eventType )
  	local textfield = self:getTextFieldByName("TextField_Name")
  	local sharedApplication = CCApplication:sharedApplication()
  	local target = sharedApplication:getTargetPlatform()

  	if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
    	if target == kTargetIphone or target == kTargetIpad then 
      		if self._layerMoveOffset < 1 and textfield then 
       			-- G_keyboardShowTimes = G_keyboardShowTimes + 1
       			-- self:callAfterFrameCount(G_keyboardShowTimes > 1 and 15 or 40, function ( ... )
          		local textSize = textfield:getSize()
          		local screenPos = textfield:convertToWorldSpace(ccp(0, 0))
          		local keyboardHeight = textfield:getKeyboardHeight()
          		if display.contentScaleFactor >= 2 then 
            		keyboardHeight = keyboardHeight/2
          		end
          		if keyboardHeight > screenPos.y - 4*textSize.height then 
            		self._layerMoveOffset = keyboardHeight - screenPos.y + 4*textSize.height
          		end

          		__Log("screenPos:(%d), keyboardHeight:%d, _layerMoveOffset:%d", screenPos.y, keyboardHeight, self._layerMoveOffset)

          		if self._layerMoveOffset > 0 then 
            		self:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
            		textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
          		end
      		end
    	end
  	elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then 
    	if self._layerMoveOffset > 0 then 
      		self:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
      		textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
      		self._layerMoveOffset = 0
    	end
  	elseif eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
    	if textfield then
      		local text = textfield:getStringValue()
      		if device.platform == "wp8" or device.platform == "winrt" then
        		local label = self:getLabelByName("Label_Name")
            if label then
        		  text = label:deleteInvalidChars(text)
            end
      		else
        		text = FTLabelManager:getInstance():deleteInvalidChars(text)
      		end
      		textfield:setText(text)
    	end
  	end
end

function ChangeNameLayer:_checkName(txt)
    if txt == "" then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_EMPTY"))
        return false
    end
    if string.utf8len(txt) < ChangeNameLayer.MIN_CHARS then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_TOOSHORT"))
        return false
    end
    if string.utf8len(txt) > ChangeNameLayer.MAX_CHARS then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_TOOLONG"))
        return false
    end
    if self:_checkSpecial(txt) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_NOTQUALIFIED"))
        return false
    end

    if G_GlobalFunc and G_GlobalFunc.matchText(txt) then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_INVALID_TEXT"))
        return false
    end

    if txt == G_Me.userData.name then
       G_MovingTip:showMovingTip(G_lang:get("LANG_CHANGE_NAME_SAME_AS_NOW")) 
      return false
    end
    
    return true
end

function ChangeNameLayer:_checkSpecial(txt)
    if string.find(txt," ") then
        return true
    end
    if string.find(txt,"\'") then
        return true
    end
    if string.find(txt,"\"") then
        return true
    end
    if string.find(txt,"\\") then
        return true
    end
    if string.find(txt,"~") then
        return true
    end
    if string.find(txt,"`") then
        return true
    end
    if string.find(txt,"<") then
        return true
    end
    if string.find(txt,">") then
        return true
    end
    if string.find(txt,",") then
        return true
    end
    if string.find(txt, "%%") then
      return true
    end
    return false
end

function ChangeNameLayer:_onCloseBtnClicked( ... )
	   self:animationToClose()
end


function ChangeNameLayer:_onConfirmBtnClicked( ... )
    if G_Me.userData.gold < self._price then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
        return
    end
    
    local textfield = self:getTextFieldByName("TextField_Name")
    local txt = ""
    if textfield then 
        txt = textfield:getStringValue()
    end
    if self:_checkName(txt) then
        G_HandlersManager.changeNameHandler:sendChangeName( txt )
    end
end


return ChangeNameLayer