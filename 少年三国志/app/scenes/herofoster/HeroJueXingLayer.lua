--HeroJueXingLayer.lua


local HeroJueXingLayer = class("HeroJueXingLayer", UFCCSNormalLayer)


function HeroJueXingLayer.create( ...)
	return HeroJueXingLayer.new("ui_layout/HeroStrengthen_Strengthen.json", nil, ...)
end

function HeroJueXingLayer:ctor( ... )
	self._mainKnightId = 0


	self.super.ctor(self, ...)
end

function HeroJueXingLayer:onLayerLoad( _, _, knightId )
	self._mainKnightId = knightId
end


function HeroJueXingLayer:adapterLayer( ... )
end

return HeroJueXingLayer

