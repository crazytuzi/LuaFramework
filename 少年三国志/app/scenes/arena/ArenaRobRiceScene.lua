-- 竞技场争粮战

local ArenaRobRiceScene = class("ArenaRobRiceScene", UFCCSBaseScene)


function ArenaRobRiceScene:ctor( ... )
 	ArenaRobRiceScene.super.ctor(self)

 	local layer = require("app.scenes.arena.ArenaRobRiceLayer").create()
 	self:addUILayerComponent("RobRiceLayer", layer, true)

 	layer:adapterWithScreen()
	local roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self:addUILayerComponent("RoleInfoUI", roleInfo, true)
    
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar, true)

 end

function ArenaRobRiceScene:onSceneEnter( ... )
end

function ArenaRobRiceScene:onSceneExit( ... )
end

function ArenaRobRiceScene:onSceneLoad( ... )
end

function ArenaRobRiceScene:onSceneUnload( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
 	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
end

return ArenaRobRiceScene