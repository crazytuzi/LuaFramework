local CrossPVPIntroLayer = class("CrossPVPIntroLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function CrossPVPIntroLayer.create(...)
	return CrossPVPIntroLayer.new("ui_layout/crosspvp_IntroLayer.json",
		Colors.modelColor, ...)
end

function CrossPVPIntroLayer:ctor(jsonFile, color, ...)
	self.super.ctor(self, jsonFile, color, ...)
end

function CrossPVPIntroLayer:onLayerLoad(...)
	-- create strokes
	for i = 1, 4 do
		self:enableLabelStroke("Label_Intro_" .. i, Colors.strokeBrown, 1)
	end

	EffectSingleMoving.run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_Touch_To_Continue"), "smoving_wait", nil, {position = true})
end

function CrossPVPIntroLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)
end

return CrossPVPIntroLayer