-- 百战沙场场景

local CrusadeScene = class("CrusadeScene", UFCCSBaseScene)


function CrusadeScene:ctor(_, _, _, _, scenePack, win, jumpToAward, ...)

	self.super.ctor(self, ...)

    self._win = win or false

    self._autoJumpToAward = jumpToAward or false

 	self._mainBody = require("app.scenes.crusade.CrusadeMainLayer").create(scenePack)
 	self:addUILayerComponent("CrusadeMainLayer", self._mainBody, true)

    self._roleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)   

 end

function CrusadeScene:onSceneEnter( ... )
	self:adapterLayerHeight(self._mainBody, nil, self._speedBar, 0, -20)

	GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.2, 2, 100)

    self._mainBody:updateView(self._win)

    if self._autoJumpToAward then
        self._mainBody:callAfterFrameCount(1, function ( ... )
            self._mainBody:onClickTreasure()
        end)    
    end
    self._autoJumpToAward = false   --避免战斗回来一直弹奖励
end

function CrusadeScene:onSceneExit( ... )
end

function CrusadeScene:onSceneLoad( ... )
end

function CrusadeScene:onSceneUnload( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
 	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
end

return CrusadeScene