local CrossPVPBetAwardLayer = class("CrossPVPBetAwardLayer", UFCCSModelLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPBetResult = require("app.scenes.crosspvp.CrossPVPBetResult")

function CrossPVPBetAwardLayer.show()
	local layer = CrossPVPBetAwardLayer.new("ui_layout/crosspvp_BetAwardLayer.json", Colors.modelColor)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPBetAwardLayer:ctor(json, color)
	self.super.ctor(self, json, color)
end

function CrossPVPBetAwardLayer:onLayerLoad()
	-- add flower bet result
	local flowerResult = CrossPVPBetResult.create(CrossPVPConst.BET_FLOWER)
	self:getPanelByName("Panel_FlowerAward"):addNode(flowerResult)

	-- add egg bet result
	local eggResult = CrossPVPBetResult.create(CrossPVPConst.BET_EGG)
	self:getPanelByName("Panel_EggAward"):addNode(eggResult)

	-- register button click events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClickClose))
end

function CrossPVPBetAwardLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

		-- pop in
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- register event listner
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onClickClose, self)
end

function CrossPVPBetAwardLayer:_onClickClose()
	self:animationToClose()
end

return CrossPVPBetAwardLayer