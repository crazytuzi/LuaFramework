
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTopBarCell = class("QUIWidgetTopBarCell", QUIWidget)

local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetEnergyPrompt = import("..widgets.QUIWidgetEnergyPrompt")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetTopBarCell.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetTopBarCell:ctor(options)
	local ccbFile = "ccb/Widget_tap.ccbi"
	local callBacks = {
        {ccbCallbackName = "onPlus", callback = handler(self, QUIWidgetTopBarCell._onPlus)}
    }
	QUIWidgetTopBarCell.super.ctor(self,ccbFile,callBacks,options)
	self._kind = options.kind
	self._ccbOwner.plus:setVisible(options.isShowAdd == true)
	self._soundEffect = options.soundEffect

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if self._kind == ITEM_TYPE.MAGICHERB_UPLEVEL then
    	self._ccbOwner.sprite_energy:setScale(0.85)
    end
    self._ccbOwner.sprite_rune:setVisible(false)
    self._ccbOwner.ccb_rune:setVisible(false)
    self._ccbOwner.sprite_gold:setVisible(false)
    self._ccbOwner.ccb_gold:setVisible(false)
    self._ccbOwner.sprite_energy:setVisible(true)
    self._ccbOwner.ccb_energy:setVisible(false)
    self._ccbOwner.sprite_battle:setVisible(false)

    self._ccbOwner.node_buff_up:setVisible(false)
    self._ccbOwner.node_fire:setVisible(false)
	self._ccbOwner.tf_buff_num:setString("")

	self._effectTime = 1
	self._scale = 1

	self._text1Update = QTextFiledScrollUtils.new()
end

function QUIWidgetTopBarCell:onEnter( ... )
	self._ccbOwner.prompt:setTouchEnabled(true)
  	self._ccbOwner.prompt:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
  	self._ccbOwner.prompt:setTouchSwallowEnabled(true)
  	self._ccbOwner.prompt:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetTopBarCell._onTouch))
end

function QUIWidgetTopBarCell:onExit()
	self._ccbOwner.prompt:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
	self._text1Update:stopUpdate()
	if self._actionHandler ~= nil then
		self._showIcon:stopAction(self._actionHandler)
	end
	
	if self._effect ~= nil then 
		self._effect:disappear()
		self._effect = nil
	end
end

function QUIWidgetTopBarCell:getIcon()
	return self._ccbOwner.sprite_energy
end

function QUIWidgetTopBarCell:getIconEffectNode()
	return self._ccbOwner.node_effect
end

function QUIWidgetTopBarCell:getBubbleNode()
	return self._ccbOwner.node_bubble
end

function QUIWidgetTopBarCell:getText1()
	return  self._ccbOwner.tf_midnum
end

function QUIWidgetTopBarCell:getText2()
	return  self._ccbOwner.tf_leftNum
end

function QUIWidgetTopBarCell:getText3()
	return  self._ccbOwner.tf_rightNum
end

--设置是否播放音效
function QUIWidgetTopBarCell:setSoundEffect(isSound)
	self.isSound = isSound
	if self.isSound == false then
		if self._soundHandler ~= nil then
			app.sound:stopSound(self._soundHandler)
			self._soundHandler = nil
		end
	end
end

function QUIWidgetTopBarCell:setText(text1,text2)
	if text1 == nil or text1 == "nil" or tonumber(text1) == nil then
		text1 = "0"
	end
	self._text1 = text1
	self._text2 = text2

	local value1,unitStr1 = q.convertLargerNumber(text1)
	if unitStr1 == nil then unitStr1 = "" end
	local value2,unitStr2
	if text2 ~= nil then
		value2,unitStr2 = q.convertLargerNumber(text2)
		if unitStr2 == nil then unitStr2 = "" end
	end

	if self._text2 ~= nil then
      	self._ccbOwner.tf_midnum:setString("")
		if tonumber(self._text1) >= tonumber(self._text2) then
			self._ccbOwner.tf_leftNum:setString(value1..unitStr1)
			self._ccbOwner.tf_rightNum:setString("/" ..value2..unitStr2)
		else
			self._ccbOwner.tf_leftNum:setString("")
			self._ccbOwner.tf_rightNum:setString(value1..unitStr1.."/" ..value2..unitStr2)
		end
	else
	    local wordLen = q.wordLen(value1..unitStr1, 42, 21)
	    if wordLen > 147 then
	      	self._scale = 147/wordLen
	     	self._ccbOwner.tf_midnum:setScale(147/wordLen)
	    else
	      	self._scale = 1
          	self._ccbOwner.tf_midnum:setScale(1)
    	end
      	self._ccbOwner.tf_midnum:setString(value1..unitStr1)
    	self._ccbOwner.tf_leftNum:setString("")
    	self._ccbOwner.tf_rightNum:setString("")
	end 
end

function QUIWidgetTopBarCell:update(text1, text2, isOnlyShowUp)
	if isOnlyShowUp and not remote.sunWar:getIsBuffEffectPlaying() then
		self._orginValue1 = text1
		self._orginValue2 = text2

		if self._text1 == nil then
			self:setText(text1,text2)
			return 
		end

		if text1 ~= nil and tonumber(self._text1) ~= tonumber(text1) then
			self._text1Update:stopUpdate()
			if tonumber(self._text1) <= tonumber(text1) then
				self:setText(text1,text2)
			else
	    		self:setText(text1,text2)
			end
		end

		return
	end

	if self._orginValue1 ~= nil then
		if self._orginValue1 ~= text1 and text1 ~= nil then
			self:showTipsAnimation(tonumber(text1) - tonumber(self._orginValue1))
		end
		if self._orginValue1 < text1 then
			scheduler.performWithDelayGlobal(function ()
				if self._soundEffect ~= nil and self:isVisible() == true and self.isSound == true then
					self._soundHandler = app.sound:playSound(self._soundEffect, false)
				end
			end,0)
		end
	end
	self._orginValue1 = text1
	self._orginValue2 = text2

	if self._text1 == nil then
		self:setText(text1,text2)
		return 
	end

	if text1 ~= nil and tonumber(self._text1) ~= tonumber(text1) then
		self._text1Update:stopUpdate()
		if tonumber(self._text1) <= tonumber(text1) then
			self._text1Update:addUpdate(self._text1, text1, handler(self, self.textFiledUpdate), self._effectTime, function ()
				self:setText(text1,text2)
			end)
		else
			if text2 ~= nil then
				if tonumber(text1) >= tonumber(text2) then
					self:nodeEffect(self._ccbOwner.tf_leftNum) 
				else
					self:nodeEffect(self._ccbOwner.tf_rightNum)
				end
			else
				self:nodeEffect(self._ccbOwner.tf_midnum)
			end
    		self:setText(text1,text2)
		end
	end
end

function QUIWidgetTopBarCell:showTipsAnimation(value)
	if self._effect ~= nil then 
		self._effect:disappear()
		self._effect:removeFromParent()
		self._effect = nil
	end
	local effectName = nil
	if value > 0 then
		effectName = "effects/Tips_add.ccbi"
	elseif value < 0 then 
		effectName = "effects/Tips_Decrease.ccbi"
	end

	if effectName then
		local content = (value > 0) and ("+" .. value) or value

		self._effect = QUIWidgetAnimationPlayer.new()
		self:addChild(self._effect)
		self._effect:setPosition(ccp(-100, -70))
		self._effect:playAnimation(effectName, function(ccbOwner)
			ccbOwner.content:setString(content)
		end, function()
        	self._effect:disappear()
        end)
	end
end

function QUIWidgetTopBarCell:setFntFile(color, font)
	-- if font == nil then 
	-- 	font = "font/FontBattleFire_Big_white.fnt"
	-- end
	self._color = color
	local color = string.split(color, ";")

	-- self._ccbOwner.tf_midnum:setFntFile(font)
	-- self._ccbOwner.tf_leftNum:setFntFile(font)
	-- self._ccbOwner.tf_rightNum:setFntFile(font)

	self._ccbOwner.tf_midnum:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.tf_leftNum:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.tf_rightNum:setColor(ccc3(color[1], color[2], color[3]))
end

function QUIWidgetTopBarCell:setTouchType(isCanTouch)
	self._isCanTouch = isCanTouch
end

function QUIWidgetTopBarCell:textFiledUpdate(value)
	if self._text2 == nil then
		self:tfMidUpdate(value)
	else
		self:tfLeftUpdate(value)
	end
end

function QUIWidgetTopBarCell:tfMidUpdate(value)
	self:setText(math.ceil(value),nil)
end

function QUIWidgetTopBarCell:tfLeftUpdate(value)
	self._text1 = math.ceil(value)
	if tonumber(self._text1) >= tonumber(self._text2) then
		self._ccbOwner.tf_leftNum:setString(self._text1)
		self._ccbOwner.tf_rightNum:setString("/" ..self._text2)
	else
		self._ccbOwner.tf_leftNum:setString("")
		self._ccbOwner.tf_rightNum:setString(self._text1.."/" ..self._text2)
	end
end

function QUIWidgetTopBarCell:tfRightUpdate(value)
	self._text2 = value
	self._ccbOwner.tf_rightNum:setString("/" ..math.ceil(value))
end

function QUIWidgetTopBarCell:nodeEffect(node)
	if node ~= nil then
		node:setScale(self._scale)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, self._scale + 1))
        actionArrayIn:addObject(CCScaleTo:create(0.23, self._scale))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIWidgetTopBarCell:showIcon(kind)
end

function QUIWidgetTopBarCell:_onTouch(event)
  	if event.name == "began" then
  		if self._isCanTouch == true then 
      		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetEnergyPrompt.EVENT_BEGAIN , eventTarget = self, kind = self._kind})
      	else
      		self._ccbOwner.plus:setHighlighted(true)
      	end
    	return true
  	elseif event.name == "ended" or event.name == "cancelled" then 
  		if self._isCanTouch == true then
   			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetEnergyPrompt.EVENT_END , eventTarget = self, kind = self._kind})
   		else
   			self._ccbOwner.plus:setHighlighted(false)
   			-- Don't trigger function if touch is moved out of area
   			if self:touchInArea(self._ccbOwner.prompt, ccp(event.x, event.y)) then
   				self:_onPlus(event)
   			end
   		end
    	return true
  	end
end

function QUIWidgetTopBarCell:touchInArea(ccbElement, touchPoint)
	local position = ccbElement:convertToWorldSpaceAR(ccp(0, 0))
	local size = ccbElement:getContentSize()
	if touchPoint.x > position.x and touchPoint.x < (position.x + size.width) and touchPoint.y > position.y and touchPoint.y < (position.y + size.height) then
		return true
	end

	return false  
end

function QUIWidgetTopBarCell:_onPlus(event)
	if q.buttonEventShadow(event,self._ccbOwner.plus) == false then return end 
	self:dispatchEvent({name=QUIWidgetTopBarCell.EVENT_CLICK,kind = self._kind})
    app.sound:playSound("common_increase")
end

return QUIWidgetTopBarCell