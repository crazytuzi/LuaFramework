--HeroGuanghuanTipLayer.lua

local HeroGuanghuanTipLayer = class("HeroGuanghuanTipLayer",  UFCCSMessageBox)


function HeroGuanghuanTipLayer:ctor( ... )
	self.super.ctor(self, ...)

	self:showAtCenter(true)
end

function HeroGuanghuanTipLayer:onLayerLoad( ... )
	self.super.onLayerLoad(self, ...)

	self:registerYesBtn("Button_continue")
	self:registerNoBtn("Button_leave")
end

function HeroGuanghuanTipLayer:onLayerEnter( ... )
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function HeroGuanghuanTipLayer.showGuanghuanTip( yesHandler, noHandler, target )
	local msgbox = HeroGuanghuanTipLayer.new("ui_layout/HeroGuanghuan_Tip.json", Colors.modelColor)
	msgbox:setYesCallback(yesHandler, target)
	msgbox:setNoCallback(noHandler, target)
	msgbox:setShowModel(false)

	msgbox:show()
end

return HeroGuanghuanTipLayer
