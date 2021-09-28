local PetBagConst = require("app.const.PetBagConst")

local PetBagMainScene = class("PetBagMainScene", UFCCSBaseScene)

function PetBagMainScene:ctor(nTabType, ...)
	self.super.ctor(self, ...)

	nTabType = nTabType or PetBagConst.TabType.PET
	self._tMainLayer = require("app.scenes.pet.bag.PetBagMainLayer").create(nTabType)
	self:addUILayerComponent("PetBagMainLayer", self._tMainLayer, true)

end

function PetBagMainScene:onSceneEnter()
	self:_addCommonUIComponent()

	self._tMainLayer:_adaterLayer()
end

function PetBagMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function PetBagMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, tRoleInfo, tSpeedBar, -2, -50)

--	GlobalFunc.flyIntoScreenLR( { tRoleInfo }, true, 0.4, 2, 100)
end

function PetBagMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return PetBagMainScene
