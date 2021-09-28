local TimeDungeonMainScene = class("TimeDungeonMainScene", UFCCSBaseScene)

function TimeDungeonMainScene:ctor(scenePack, isAutoOpenDesc, ...)
--	__Log("nChapterId = %d, nEndTime = %d", nChapterId, nEndTime)
	self.super.ctor(self, ...)
--	nEndTime = 1427443660
	local hasDungeon, nChapterId, nEndTime = G_Me.timeDungeonData:currentTimeHasDungeon()
	__Log("---nChapterId = %d", nChapterId)
	self._tMainLayer = require("app.scenes.timedungeon.TimeDungeonMainLayer").create(nChapterId, nEndTime, scenePack, isAutoOpenDesc)

	self:addUILayerComponent("TimeDungeonMainLayer", self._tMainLayer, true)
	self:_addCommonUIComponent()
end

function TimeDungeonMainScene:onSceneEnter()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
end

function TimeDungeonMainScene:onSceneExit()
	self:_removeCommonUIComponent()
end

function TimeDungeonMainScene:_addCommonUIComponent()
	local tRoleInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
	local tSpeedBar = G_commonLayerModel:getSpeedbarLayer()
	self:addUILayerComponent("RoleInfoUI", tRoleInfo, true)
	self:addUILayerComponent("SpeedBar", tSpeedBar, true)
	self:adapterLayerHeight(self._tMainLayer, nil, tSpeedBar, -8, -56)
end

function TimeDungeonMainScene:_removeCommonUIComponent()
	self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end


return TimeDungeonMainScene