local CityPatrolTimeLayer = class("CityPatrolTimeLayer", UFCCSModelLayer)

function CityPatrolTimeLayer.show(callback)
	local layer = CityPatrolTimeLayer.new("ui_layout/city_PatrolTimeLayer.json", Colors.modelColor, callback)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CityPatrolTimeLayer:ctor(json, color, callback)
	self._callback = callback
	self.super.ctor(self, json, color)
end

function CityPatrolTimeLayer:onLayerLoad()
	-- label strokes & register button click events
	for i = 1, 3 do
		self:enableLabelStroke("Label_Time_" .. i, Colors.strokeBrown, 1)
		self:registerBtnClickEvent("Button_Time_" .. i, function()
			if self._callback then
				self._callback(i)
			end
			self:animationToClose()
		end)
	end

	self:registerBtnClickEvent("Button_Close", handler(self, self.animationToClose))
    self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self.animationToClose))
end

function CityPatrolTimeLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

return CityPatrolTimeLayer