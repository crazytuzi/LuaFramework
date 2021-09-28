--HeroFoster.lua


local HeroFosterScene = class ("HeroFosterScene", UFCCSBaseScene)


function HeroFosterScene:ctor( style, detailKnight, scenePack, ... )
	self._sceneIsEnter = false
	self.super.ctor( self, style, detailKnight, scenePack, ...)

end

function HeroFosterScene:onSceneLoad( style, detailKnight, scenePack, ... )
	self._mainBody = require("app.scenes.herofoster.HeroFosterLayer").new("ui_layout/HeroStrengthen_Main.json",nil, style,detailKnight,scenePack, ...)
	self:addUILayerComponent("HeroFosterLayer", self._mainBody, false)
end

function HeroFosterScene:onSceneEnter(  )
	self._headerInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self._speedBar:setSelectBtn()
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    self:addUILayerComponent("Header",self._headerInfo,true)
	self:adapterLayerHeight(self._mainBody, self._headerInfo, self._speedBar, -10, -15)

	if not self._sceneIsEnter then
		self._mainBody:adapterLayer()
	end

	self._sceneIsEnter = true
end

function HeroFosterScene:onSceneExit( ... )
	self:removeComponent(SCENE_COMPONENT_GUI, "Header")
	self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return HeroFosterScene

