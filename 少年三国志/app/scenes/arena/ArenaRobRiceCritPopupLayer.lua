-- 暴击获得粮草提示

local ArenaRobRiceCritPopupLayer = class("ArenaRobRiceCritPopupLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function ArenaRobRiceCritPopupLayer.show( riceAmount, ... )
	local layer = ArenaRobRiceCritPopupLayer.new("ui_layout/arena_RobRiceCritRiceLayer.json", Colors.modelColor, riceAmount, ... )
	uf_notifyLayer:getModelNode():addChild(layer)
end

function ArenaRobRiceCritPopupLayer:ctor( json, color, riceAmount, ... )
	self.super.ctor(self, json, color, ...)

	self:registerTouchEvent(false, true, 0)

	local riceAmountLabel = self:getLabelByName("Label_Rice_Amount")
	riceAmountLabel:setText(tostring(riceAmount))
	

	riceAmountLabel:createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Tag_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Tag_2"):createStroke(Colors.strokeBrown, 1)
end

function ArenaRobRiceCritPopupLayer:onLayerEnter(  )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	EffectSingleMoving.run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getImageViewByName("Image_Continue"), "smoving_wait", nil , {position = true} )

	local riceAmountLabel = self:getLabelByName("Label_Rice_Amount")
	self:getLabelByName("Label_Tag_2"):setPositionX(riceAmountLabel:getPositionX() + riceAmountLabel:getContentSize().width + 2)
end

function ArenaRobRiceCritPopupLayer:onTouchEnd( xpos, ypos )
	self:animationToClose()
end




return ArenaRobRiceCritPopupLayer