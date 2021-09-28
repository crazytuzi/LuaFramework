local ShopScoreScene = class("ShopScoreScene",UFCCSBaseScene)


function ShopScoreScene:ctor(...)
	self.super.ctor(self,...)
end

function ShopScoreScene:onSceneLoad(_type, func, functionValue, chapterId, scenePack, ...)
	self._scoreShopLayer = require("app.scenes.shop.score.ShopScoreLayer").create(_type or chapterId, scenePack)
    self:addUILayerComponent("ShopScoreLayer", self._scoreShopLayer, true)
    
    self._roleInfo  = G_commonLayerModel:getBagRoleInfoLayer()
    self:addUILayerComponent("roleInfo", self._roleInfo,true)

    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)

    self:adapterLayerHeight(self._scoreShopLayer, self._roleInfo, self._speedbar, 0, 140)
    self._scoreShopLayer:adapterLayer()
end

--移除通用模块
function ShopScoreScene:onSceneExit( ... )
    self:removeComponent(SCENE_COMPONENT_GUI, "roleInfo")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end
return ShopScoreScene 