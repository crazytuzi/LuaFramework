local CityPatrolStyleLayer = class("CityPatrolStyleLayer", UFCCSModelLayer)

local CityConst = require("app.const.CityConst")

function CityPatrolStyleLayer.show(callback)
	local layer = CityPatrolStyleLayer.new("ui_layout/city_PatrolStyleLayer.json", Colors.modelColor, callback)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CityPatrolStyleLayer:ctor(json, color, callback)
	self._callback = callback
	self.super.ctor(self, json, color)
end

function CityPatrolStyleLayer:onLayerLoad()
	-- initialize UI
	self:_initContent()	

	-- register button click events
	self:registerBtnClickEvent("Button_close", handler(self, self.animationToClose))
    self:registerBtnClickEvent("Button_close1", handler(self, self.animationToClose))

    for i = 1, 3 do
    	self:registerBtnClickEvent("Button_patrol" .. i, function()
    		if self._callback then
    			self._callback(i)
    		end
    		self:animationToClose()
    	end)
    end
end

function CityPatrolStyleLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function CityPatrolStyleLayer:_initContent()
	for i = 1, 3 do
		-- patrol harvest interval description
		local desc = G_lang:get("LANG_CITY_PATROL_STYPE_GET_DESC", {minute=CityConst.PATROL_EVENT_INTERVAL[i]})
        self:showTextWithLabel("Label_patrol_get_desc" .. i, desc)
            
        -- vip limit
        local vipLimit = CityConst.PATROL_VIP_LIMIT[i]
        local enable = G_Me.userData.vip >= vipLimit
        self:getButtonByName("Button_patrol" .. i):setEnabled(enable)
            
        if i > 1 then
        	local vipLabel = self:getLabelByName("Label_vip_limit" .. i)
        	vipLabel:setVisible(not enable)

        	if not enable then
        		vipLabel:setText(G_lang:get("LANG_CITY_PATROL_VIP_LIMIT_DESC", {level=vipLimit}))
        	end
		end
    end
end

return CityPatrolStyleLayer