-- HeroSoulShopScene

local HeroSoulShopScene = class("HeroSoulShopScene", UFCCSBaseScene)

function HeroSoulShopScene:ctor(scenePack)
    
    HeroSoulShopScene.super.ctor(self)
    
    self.layer = require("app.scenes.herosoul.HeroSoulShopLayer").create(scenePack)
    self:addUILayerComponent("HeroSoulShopLayer", self.layer, true)
end

function HeroSoulShopScene:onSceneEnter()
    local roleInfo = G_commonLayerModel:getShopRoleInfoLayer()
    self:addUILayerComponent("RoleInfoUI", roleInfo, true)
    
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar, true)
    
    -- 扣除roleInfo和speedBar的位置
    self:adapterLayerHeight(self.layer, roleInfo, speedBar, -10, -20)
    -- 调整Panel_content至屏幕中央
    self.layer:adapterWidgetHeight("Panel_content", "Panel_117", "Panel_261", 0, 0)
end

function HeroSoulShopScene:onSceneExit()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return HeroSoulShopScene