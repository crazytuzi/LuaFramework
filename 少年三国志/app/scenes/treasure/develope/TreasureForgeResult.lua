local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local TreasureForgeResult = class("TreasureForgeResult", UFCCSModelLayer)

function TreasureForgeResult.show(treasureInfo, originAttrs, forgedAttrs, callback, ...)
	local result = require("app.scenes.treasure.develope.TreasureForgeResult").new("ui_layout/treasure_TreasureForgeResult.json", 
							_, treasureInfo, originAttrs, forgedAttrs, callback, ...)
	uf_notifyLayer:getModelNode():addChild(result)
end

function TreasureForgeResult:ctor(json, color, treasureInfo, originAttrs, forgedAttrs, callback, ...)
	self._treasureInfo	= treasureInfo
	self._originAttrs 	= originAttrs
	self._forgedAttrs 	= forgedAttrs
	self._callback		= callback
	self._clickToClose  = false

	self._greenArrows 	= {}
	for i = 1, 4 do
		self._greenArrows[i] = self:getImageViewByName("Image_GreenArrow" .. i)
	end

	self.super.ctor(self, ...)
end

function TreasureForgeResult:onLayerLoad(...)
	-- create strokes
	self:enableLabelStroke("Label_TreasureName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SkillDesc", Colors.strokeBrown, 1)

	-- set treasure name
	local nameLabel = self:getLabelByName("Label_TreasureName")
	nameLabel:setText(self._treasureInfo.name)
	nameLabel:setColor(Colors.qualityColors[self._treasureInfo.quality])

	-- set treasure attributes
	self:_setAttrs()

	-- flicker green arrows
	self:_flickerGreenArrows()
end

function TreasureForgeResult:onLayerEnter(...)
	self:registerKeypadEvent(1, 0)
	self:adapterWithScreen()

    local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.KNIGHT_SPECIAL)

    self:showWidgetByName("Label_StrLevel_New", false)
	self:showWidgetByName("Label_StrAttr1_New", false)
	self:showWidgetByName("Label_StrAttr2_New", false)
	self:showWidgetByName("Label_RefLevel_New", false)
	self:showWidgetByName("Label_RefAttr1_New", false)
	self:showWidgetByName("Label_RefAttr2_New", false)
	self:showWidgetByName("Panel_BottomInfo", false)

	for i = 1, 4 do
		self._greenArrows[i]:setVisible(false)
	end	

    -- fly into the UI
    GlobalFunc.flyDown({self:getWidgetByName("Image_TitleBoard")}, 0.3, 0, 3, function ( ... )
		self:showWidgetByName("Panel_BottomInfo", true)
		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_StrLevel"), 
                    self:getWidgetByName("Panel_StrAttr1"),
                    self:getWidgetByName("Panel_StrAttr2"), 
                    self:getWidgetByName("Panel_RefLevel"), 
                    self:getWidgetByName("Panel_RefAttr1"), 
                    self:getWidgetByName("Panel_RefAttr2")}, true, 0.3, 2, 50, function ( ... )

                    	self:showWidgetByName("Label_StrLevel_New", true)

						GlobalFunc.flyDown({self:getWidgetByName("Label_StrLevel_New"),
							self:getWidgetByName("Label_StrAttr1_New"),
							self:getWidgetByName("Label_StrAttr2_New"),
							self:getWidgetByName("Label_RefLevel_New"),
							self:getWidgetByName("Label_RefAttr1_New"),
							self:getWidgetByName("Label_RefAttr2_New")}, 0.2, 0.1, 3, function ( ... )
								for i = 1, 4 do
									self._greenArrows[i]:setVisible(self._greenArrows[i]:getTag() == 1)
								end	

								self:showWidgetByName("Image_ClickContinue", true)
                    			EffectSingleMoving.run(self:getWidgetByName("Image_ClickContinue"), "smoving_wait", nil , {position = true} )

                    			self._clickToClose = true
                    			self:closeAtReturn(true)
                    			self:setClickClose(true)
						end)                    	
        end)
	end)
end

function TreasureForgeResult:_setAttrs()
	-- original attributes
	local oldAttr = self._originAttrs
	self:showTextWithLabel("Label_StrLevel_Old", oldAttr[1].levelString)
	self:showTextWithLabel("Label_StrAttr1", oldAttr[1][1].typeString .. "：")
	self:showTextWithLabel("Label_StrAttr1_Old", oldAttr[1][1].valueString)
	self:showTextWithLabel("Label_StrAttr2", oldAttr[1][2].typeString .. "：")
	self:showTextWithLabel("Label_StrAttr2_Old", "+" .. oldAttr[1][2].valueString)

	self:showTextWithLabel("Label_RefLevel_Old", oldAttr[2].levelString)
	self:showTextWithLabel("Label_RefAttr1", oldAttr[2][1].typeString .. "：")
	self:showTextWithLabel("Label_RefAttr1_Old", oldAttr[2][1].valueString)
	self:showTextWithLabel("Label_RefAttr2", oldAttr[2][2].typeString .. "：")
	self:showTextWithLabel("Label_RefAttr2_Old", "+" .. oldAttr[2][2].valueString)

	-- forged attributes
	local newAttr = self._forgedAttrs
	self:showTextWithLabel("Label_StrLevel_New", newAttr[1].levelString)
	self:showTextWithLabel("Label_StrAttr1_New", newAttr[1][1].valueString)
	self:showTextWithLabel("Label_StrAttr2_New", "+" .. newAttr[1][2].valueString)

	self:showTextWithLabel("Label_RefLevel_New", newAttr[2].levelString)
	self:showTextWithLabel("Label_RefAttr1_New", newAttr[2][1].valueString)
	self:showTextWithLabel("Label_RefAttr2_New", "+" .. newAttr[2][2].valueString)

	-- if new attribute is larger then previous, show green arrow
	local isStrAttr1Larger = newAttr[1][1].value > oldAttr[1][1].value
	local isStrAttr2Larger = newAttr[1][2].value > oldAttr[1][2].value
	local isRefAttr1Larger = newAttr[2][1].value > oldAttr[2][1].value
	local isRefAttr2Larger = newAttr[2][2].value > oldAttr[2][2].value
	self:getLabelByName("Label_StrAttr1_New"):setColor(isStrAttr1Larger and Colors.lightColors.ATTRIBUTE or Colors.lightColors.DESCRIPTION)
	self:getLabelByName("Label_StrAttr2_New"):setColor(isStrAttr2Larger and Colors.lightColors.ATTRIBUTE or Colors.lightColors.DESCRIPTION)
	self:getLabelByName("Label_RefAttr1_New"):setColor(isRefAttr1Larger and Colors.lightColors.ATTRIBUTE or Colors.lightColors.DESCRIPTION)
	self:getLabelByName("Label_RefAttr2_New"):setColor(isRefAttr2Larger and Colors.lightColors.ATTRIBUTE or Colors.lightColors.DESCRIPTION)

	self._greenArrows[1]:setTag(isStrAttr1Larger and 1 or 0)
	self._greenArrows[2]:setTag(isStrAttr2Larger and 1 or 0)
	self._greenArrows[3]:setTag(isRefAttr1Larger and 1 or 0)
	self._greenArrows[4]:setTag(isRefAttr2Larger and 1 or 0)
end

function TreasureForgeResult:_flickerGreenArrows()
	for i = 1, 4 do
		local arrow = self._greenArrows[i]
		local arrowX, arrowY = arrow:getPosition()
		local moveDistUp = 10
		local startPosy = (arrowY - moveDistUp/2)

		local arr = CCArray:create()
		arr:addObject(CCResetPosition:create(arrow, ccp(arrowX, startPosy)))
		arr:addObject(CCResetOpacity:create(arrow, 255))
		local moveby = CCMoveBy:create(0.8, ccp(0, moveDistUp))
		arr:addObject(CCEaseIn:create(moveby, 0.3))
		arr:addObject(CCFadeOut:create(0.2))
			
		arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
end

function TreasureForgeResult:_onClose()
	if not self._clickToClose then 
		return true
	end

    if self._callback then 
    	self._callback()
    end

    self:close()
	return true
end

function TreasureForgeResult:onBackKeyEvent( ... )
	return self:_onClose()
end

function TreasureForgeResult:onClickClose( ... )
	return self:_onClose()
end

return TreasureForgeResult