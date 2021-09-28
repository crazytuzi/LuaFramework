local GoldNotEnoughDialog = class("GoldNotEnoughDialog",UFCCSModelLayer)
--[[
	title为文字，可以不传则默认
	G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH")
]]
function GoldNotEnoughDialog.show(title,zorder)
	local layer = GoldNotEnoughDialog.new("ui_layout/shop_GoldNotEnoughDialog.json",title,zorder)
	if zorder and type(zorder) == "number" then
		uf_sceneManager:getCurScene():addChild(layer,zorder)
	else
		uf_sceneManager:getCurScene():addChild(layer)
	end
	return layer
end

function GoldNotEnoughDialog:ctor(_,title,zorder)
	self._zorder = zorder or 0
	title = title or G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH")
	self.super.ctor(self)
	self:showAtCenter(true)
	self:getLabelByName("Label_title"):setText(title)
	self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
	self:registerBtnClickEvent("Button_01",function()
		self:animationToClose()
	    end)
	G_GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
	self:registerBtnClickEvent("Button_02",function()
		if self._zorder ~= 0 then
			local layer = require("app.scenes.shop.recharge.RechargeLayer").create()
			uf_sceneManager:getCurScene():addChild(layer,self._zorder+1)
		else
			require("app.scenes.shop.recharge.RechargeLayer").show()
		end
		self:animationToClose()
	    end)
end

function GoldNotEnoughDialog:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return GoldNotEnoughDialog