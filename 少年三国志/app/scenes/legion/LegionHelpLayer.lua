--LegionHelpLayer.lua


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local LegionHelpLayer = class("LegionHelpLayer", UFCCSModelLayer)



function LegionHelpLayer.show( ... )
	local helpLayer = LegionHelpLayer.new("ui_layout/legion_HelpLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(helpLayer)
end

function LegionHelpLayer:ctor( ... )
	self.super.ctor(self, ...)
end

function LegionHelpLayer:onLayerLoad( _, _, title, desc )
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 2 )

	self:showTextWithLabel("Label_title", title or "")
	self:showTextWithLabel("Label_desc", desc or "")
end

function LegionHelpLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_35"), "smoving_wait", nil , {position = true} )
end


return LegionHelpLayer

