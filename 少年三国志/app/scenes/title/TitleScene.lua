-- TitleScene

local TitleScene = class("TitleScene", UFCCSBaseScene)

function TitleScene:ctor(itemVaule)
	TitleScene.super.ctor(self)
	
	-- __Log("TitleScene:ctor itemVaule: %d", itemVaule)

	local layer = require("app.scenes.title.TitleMainLayer").create(itemVaule)
	-- local layer = require("app.scenes.title.TitleLayer").create(itemVaule)
	self:addUILayerComponent("TitleLayer", layer, true)

    layer:adapterWithScreen()
end

function TitleScene:onSceneEnter( ... )
	local roleInfo = G_commonLayerModel:getShopRoleInfoLayer()
    self:addUILayerComponent("RoleInfoUI", roleInfo, true)
    
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar, true)
end

function TitleScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
end

return TitleScene
