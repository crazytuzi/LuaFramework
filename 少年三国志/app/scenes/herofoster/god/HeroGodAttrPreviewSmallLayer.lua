-- HeroGodAttrPreviewSmallLayer.lua

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local HeroGodAttrPreviewSmallLayer = class("HeroGodAttrPreviewSmallLayer", UFCCSModelLayer)
require "app.cfg.knight_info"


function HeroGodAttrPreviewSmallLayer.show( ... )
	local layer = HeroGodAttrPreviewSmallLayer.new("ui_layout/HeroGod_AttrPreview1.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroGodAttrPreviewSmallLayer:ctor( json, color, godInfo, preGodInfo, ... )
	self._godInfo = godInfo
	self._preGodInfo = preGodInfo
	self.super.ctor(self, json, ...)
end

function HeroGodAttrPreviewSmallLayer:onLayerLoad( ... )
	self:_initWiget()
	
end

function HeroGodAttrPreviewSmallLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_click_continue"), "smoving_wait", nil , {position = true} )
end

function HeroGodAttrPreviewSmallLayer:_initWiget()
	
	local attrValues = 
	{
		self._godInfo.pulse_att - (self._preGodInfo and self._preGodInfo.pulse_att or 0), 
		self._godInfo.pulse_hp - (self._preGodInfo and self._preGodInfo.pulse_hp or 0), 
		self._godInfo.pulse_phy_def - (self._preGodInfo and self._preGodInfo.pulse_phy_def or 0), 
		self._godInfo.pulse_mag_def - (self._preGodInfo and self._preGodInfo.pulse_mag_def or 0),
	}

	
	local pts = {
		ccp(self:getPanelByName("Panel_attrinfo1"):getPosition()),
		ccp(self:getPanelByName("Panel_attrinfo2"):getPosition()),
		ccp(self:getPanelByName("Panel_attrinfo3"):getPosition()),
		ccp(self:getPanelByName("Panel_attrinfo4"):getPosition()),
	}
	local idx = 1
	local theOnePanel = nil
	for i = 1, #attrValues do
		local label = self:getLabelByName("Label_value" .. i)
		local panel = self:getPanelByName("Panel_attrinfo" .. i)
		if attrValues[i] > 0 then
			label:setText('+' .. attrValues[i])
			panel:setPositionXY(pts[idx].x, pts[idx].y)
			idx = idx + 1
			theOnePanel = panel
		else
			panel:setVisible(false)
		end
	end

	if idx == 2 and theOnePanel then
		theOnePanel:setPositionXY( (pts[4].x - pts[1].x) / 2 +  pts[1].x + 30, (pts[1].y - pts[4].y) / 2 +  pts[4].y)
	end

	self:enableLabelStroke("Label_attr_header", Colors.strokeBrown, 2)

end

return HeroGodAttrPreviewSmallLayer